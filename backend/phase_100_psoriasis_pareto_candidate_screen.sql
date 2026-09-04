-- Phase 100: no-weight, source-bound psoriasis candidate comparison.
-- Pareto status is evidence prioritisation only; it is not efficacy, treatment or cure ranking.
START TRANSACTION;

CREATE TABLE IF NOT EXISTS ilb_psoriasis_candidate_agent_map (
 candidate_key varchar(80) NOT NULL,
 agent_key varchar(80) NOT NULL,
 mapping_status enum('EXACT','REVIEW_REQUIRED') NOT NULL,
 source_url varchar(1000) NOT NULL,
 PRIMARY KEY(candidate_key,agent_key),
 CONSTRAINT fk_p100_candidate FOREIGN KEY(candidate_key) REFERENCES ilb_psoriasis_candidate(candidate_key),
 CONSTRAINT fk_p100_agent FOREIGN KEY(agent_key) REFERENCES ilb_psoriasis_pharma_agent(agent_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO ilb_psoriasis_candidate_agent_map VALUES
('GUSELKUMAB_IL23','GUSELKUMAB','EXACT','https://pmc.ncbi.nlm.nih.gov/articles/PMC8438891/'),
('SECUKINUMAB_IL17','SECUKINUMAB','EXACT','https://pubmed.ncbi.nlm.nih.gov/32199992/')
ON DUPLICATE KEY UPDATE mapping_status=VALUES(mapping_status),source_url=VALUES(source_url);

CREATE OR REPLACE VIEW v_ilmb_psoriasis_candidate_evidence_vector AS
SELECT c.candidate_key,c.candidate_name,c.domain,c.evidence_model,
 COUNT(DISTINCT CASE WHEN e.evidence_status='SUPPORTED_DIRECTION' THEN e.state_key END) supported_state_count,
 COUNT(DISTINCT CASE WHEN e.evidence_status='SUPPORTED_DIRECTION' AND e.direct_state_measurement=1 THEN e.state_key END) direct_supported_state_count,
 MAX(e.state_key='B' AND e.evidence_status='SUPPORTED_DIRECTION') barrier_supported,
 MAX(e.state_key='R' AND e.evidence_status='SUPPORTED_DIRECTION') persistence_supported,
 MAX(e.withdrawal_tested=1) withdrawal_tested,
 MAX(e.rechallenge_tested=1) rechallenge_tested,
 (c.evidence_model IN ('HUMAN','HUMAN_AND_3D')) human_evidence,
 MAX(CASE WHEN m.mapping_status='EXACT' THEN 1 ELSE 0 END) exact_agent_map,
 MAX(CASE WHEN a.identity_status='EXACT_APPROVED' THEN 1 ELSE 0 END) exact_approved_agent_identity,
 COUNT(DISTINCT CASE WHEN s.section_code IN ('WARNINGS','ADVERSE_REACTIONS','CONTRAINDICATIONS') AND s.extraction_status='SOURCE_EXACT_TEXT' THEN s.section_code END) safety_section_count,
 CASE WHEN MAX(e.withdrawal_tested=1)=1 AND MAX(e.rechallenge_tested=1)=1 THEN 1 ELSE 0 END durability_test_complete
FROM ilb_psoriasis_candidate c
LEFT JOIN ilb_psoriasis_candidate_state_evidence e ON e.candidate_key=c.candidate_key
LEFT JOIN ilb_psoriasis_candidate_agent_map m ON m.candidate_key=c.candidate_key
LEFT JOIN ilb_psoriasis_pharma_agent a ON a.agent_key=m.agent_key
LEFT JOIN ilb_psoriasis_regulatory_label_section s ON s.agent_key=m.agent_key
GROUP BY c.candidate_key,c.candidate_name,c.domain,c.evidence_model;

CREATE OR REPLACE VIEW v_ilmb_psoriasis_candidate_pareto AS
SELECT a.*,
 CASE WHEN EXISTS (
  SELECT 1 FROM v_ilmb_psoriasis_candidate_evidence_vector b
  WHERE b.candidate_key<>a.candidate_key
    AND b.supported_state_count>=a.supported_state_count
    AND b.direct_supported_state_count>=a.direct_supported_state_count
    AND b.barrier_supported>=a.barrier_supported
    AND b.persistence_supported>=a.persistence_supported
    AND b.withdrawal_tested>=a.withdrawal_tested
    AND b.rechallenge_tested>=a.rechallenge_tested
    AND b.human_evidence>=a.human_evidence
    AND (
      b.supported_state_count>a.supported_state_count OR
      b.direct_supported_state_count>a.direct_supported_state_count OR
      b.barrier_supported>a.barrier_supported OR
      b.persistence_supported>a.persistence_supported OR
      b.withdrawal_tested>a.withdrawal_tested OR
      b.rechallenge_tested>a.rechallenge_tested OR
      b.human_evidence>a.human_evidence
    )
 ) THEN 'DOMINATED' ELSE 'PARETO_FRONTIER' END evidence_priority,
 CASE
  WHEN durability_test_complete=0 THEN 'DURABILITY_EVIDENCE_REQUIRED'
  WHEN domain='PHARMACEUTICAL' AND exact_approved_agent_identity=0 THEN 'IDENTITY_APPROVAL_REQUIRED'
  WHEN domain='PHARMACEUTICAL' AND safety_section_count<3 THEN 'SAFETY_SECTION_COMPLETION_REQUIRED'
  ELSE 'ELIGIBLE_FOR_PROTOCOL_CALIBRATION'
 END advancement_gate,
 0 AS treatment_recommendation,
 0 AS cure_claim_allowed
FROM v_ilmb_psoriasis_candidate_evidence_vector a;

CREATE TABLE IF NOT EXISTS ilb_psoriasis_candidate_screen_rule (
 rule_key varchar(80) NOT NULL,
 rule_text text NOT NULL,
 invented_weight_count int unsigned NOT NULL DEFAULT 0,
 patient_use_allowed tinyint(1) NOT NULL DEFAULT 0,
 PRIMARY KEY(rule_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO ilb_psoriasis_candidate_screen_rule VALUES
('R01_NO_WEIGHTED_SCORE','Do not sum incomparable evidence dimensions into an arbitrary score.',0,0),
('R02_PARETO_DOMINANCE','Candidate B dominates A only when B is no worse on every registered evidence dimension and strictly better on at least one.',0,0),
('R03_DURABILITY_BLOCK','No candidate advances as disease-modifying without registered withdrawal and rechallenge evidence.',0,0),
('R04_IDENTITY_GATE','Pharmaceutical execution additionally requires an exact approved ingredient and target identity.',0,0),
('R05_SAFETY_GATE','Safety evidence remains a compulsory gate and is not traded against efficacy evidence.',0,0),
('R06_NO_PATIENT_DIRECTION','The screen cannot generate an individual treatment, dosage or cure instruction.',0,0)
ON DUPLICATE KEY UPDATE rule_text=VALUES(rule_text),invented_weight_count=VALUES(invented_weight_count),patient_use_allowed=VALUES(patient_use_allowed);

COMMIT;
