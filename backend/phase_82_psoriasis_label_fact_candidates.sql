-- Phase 82: source-bound numeric candidates from exact regulatory-label text.
-- Candidates are deliberately not computation eligible until reviewed and mapped.
START TRANSACTION;
CREATE TABLE IF NOT EXISTS ilb_psoriasis_label_fact_candidate (
 candidate_id bigint unsigned NOT NULL AUTO_INCREMENT,
 agent_key varchar(80) NOT NULL,
 set_id char(36) NOT NULL,
 section_code varchar(20) NOT NULL,
 candidate_kind enum('DOSING','PHARMACOKINETIC','IMMUNOGENICITY','SAFETY','OTHER') NOT NULL,
 exact_match varchar(255) NOT NULL,
 context_span text NOT NULL,
 numeric_value decimal(30,10) NOT NULL,
 source_unit varchar(40) NOT NULL,
 context_sha256 char(64) NOT NULL,
 source_section_sha256 char(64) NOT NULL,
 review_status enum('UNREVIEWED','ACCEPTED','REJECTED') NOT NULL DEFAULT 'UNREVIEWED',
 computation_eligible tinyint(1) NOT NULL DEFAULT 0,
 extracted_at timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
 PRIMARY KEY(candidate_id),
 UNIQUE KEY uq_p82_candidate(agent_key,set_id,section_code,context_sha256,exact_match),
 KEY idx_p82_agent_kind(agent_key,candidate_kind),
 KEY idx_p82_review(review_status,computation_eligible)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE OR REPLACE VIEW v_ilmb_psoriasis_label_fact_readiness AS
SELECT a.agent_key,
 COUNT(c.candidate_id) candidate_count,
 SUM(c.review_status='ACCEPTED') accepted_count,
 SUM(c.computation_eligible=1) computation_eligible_count,
 CASE
  WHEN SUM(c.computation_eligible=1)>0 THEN 'COMPUTATION_READY'
  WHEN COUNT(c.candidate_id)>0 THEN 'SOURCE_CANDIDATES_ONLY'
  ELSE 'NO_CANDIDATES'
 END readiness_status
FROM ilb_psoriasis_pharma_agent a
LEFT JOIN ilb_psoriasis_label_fact_candidate c ON c.agent_key=a.agent_key
GROUP BY a.agent_key;
COMMIT;
