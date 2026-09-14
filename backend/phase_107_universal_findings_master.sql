-- ILoveMyBody Phase 107: Universal governed findings master
-- Additive only. MySQL 8 / MariaDB 10.5 compatible.
-- Findings are the primary governed knowledge product and attach to the existing
-- universal semantic graph, variables, equations, interventions and outcomes.

CREATE TABLE IF NOT EXISTS ilb_finding (
  finding_id CHAR(64) PRIMARY KEY,
  disease_entity_id CHAR(64) NULL,
  finding_code VARCHAR(160) NOT NULL,
  title VARCHAR(512) NOT NULL,
  finding_type ENUM(
    'MECHANISM','TREATMENT_MECHANISM','CLINICAL_LEVER','BIOMARKER','PLUMBING',
    'FORMULA_FINDING','NEGATIVE_FINDING','SAFETY_FINDING','STRUCTURAL_FACT'
  ) NOT NULL,
  finding_statement LONGTEXT NOT NULL,
  evidence_status ENUM(
    'PROPOSED','STRUCTURAL_VERIFIED','MECHANISTIC_SUPPORTED','QUANTIFIED',
    'VALIDATED','PERSON_MEASURED','NOT_QUANTIFIED','CONFLICTING','REJECTED','DEPRECATED'
  ) NOT NULL DEFAULT 'PROPOSED',
  quantification_status ENUM('NOT_QUANTIFIED','PARTIAL','QUANTIFIED','NOT_APPLICABLE') NOT NULL DEFAULT 'NOT_QUANTIFIED',
  clinical_actionability ENUM('NONE','LOW','CONDITIONAL','MODERATE','HIGH') NOT NULL DEFAULT 'NONE',
  magnitude_text TEXT NULL,
  timeframe_text VARCHAR(255) NULL,
  population_or_model TEXT NULL,
  conflict_or_limit TEXT NULL,
  next_data_needed TEXT NULL,
  lifecycle_status ENUM('DRAFT','STAGED','APPROVED','RETIRED') NOT NULL DEFAULT 'DRAFT',
  source_batch_id CHAR(36) NULL,
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  UNIQUE KEY uq_ilb_finding_code (finding_code),
  KEY ix_ilb_finding_disease (disease_entity_id),
  KEY ix_ilb_finding_type_status (finding_type,evidence_status),
  CONSTRAINT fk_ilb_finding_disease FOREIGN KEY (disease_entity_id) REFERENCES ilb_semantic_entity(entity_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_finding_edge (
  finding_edge_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  finding_id CHAR(64) NOT NULL,
  source_entity_id CHAR(64) NOT NULL,
  relation_code VARCHAR(64) NOT NULL,
  target_entity_id CHAR(64) NOT NULL,
  effect_sign ENUM('POSITIVE','NEGATIVE','MIXED','UNKNOWN','NOT_APPLICABLE') NOT NULL DEFAULT 'UNKNOWN',
  sequence_no INT UNSIGNED NOT NULL DEFAULT 1,
  relation_id CHAR(64) NULL,
  notes TEXT NULL,
  UNIQUE KEY uq_ilb_finding_edge (finding_id,source_entity_id,relation_code,target_entity_id,sequence_no),
  KEY ix_ilb_finding_edge_source (source_entity_id,relation_code),
  KEY ix_ilb_finding_edge_target (target_entity_id,relation_code),
  CONSTRAINT fk_ilb_finding_edge_finding FOREIGN KEY (finding_id) REFERENCES ilb_finding(finding_id),
  CONSTRAINT fk_ilb_finding_edge_source FOREIGN KEY (source_entity_id) REFERENCES ilb_semantic_entity(entity_id),
  CONSTRAINT fk_ilb_finding_edge_relation FOREIGN KEY (relation_code) REFERENCES ilb_relation_type(relation_code),
  CONSTRAINT fk_ilb_finding_edge_target FOREIGN KEY (target_entity_id) REFERENCES ilb_semantic_entity(entity_id),
  CONSTRAINT fk_ilb_finding_edge_relation_row FOREIGN KEY (relation_id) REFERENCES ilb_entity_relation(relation_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_finding_variable (
  finding_id CHAR(64) NOT NULL,
  variable_id CHAR(64) NOT NULL,
  variable_role ENUM('INPUT','OUTPUT','MEASURE','MEDIATOR','OUTCOME','CONSTRAINT') NOT NULL,
  PRIMARY KEY (finding_id,variable_id,variable_role),
  CONSTRAINT fk_ilb_finding_variable_finding FOREIGN KEY (finding_id) REFERENCES ilb_finding(finding_id),
  CONSTRAINT fk_ilb_finding_variable_variable FOREIGN KEY (variable_id) REFERENCES ilb_variable_definition(variable_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_finding_equation (
  finding_id CHAR(64) NOT NULL,
  equation_id CHAR(64) NOT NULL,
  equation_role ENUM('SUPPORTS','QUANTIFIES','PREDICTS','CONSTRAINS') NOT NULL DEFAULT 'SUPPORTS',
  PRIMARY KEY (finding_id,equation_id,equation_role),
  CONSTRAINT fk_ilb_finding_equation_finding FOREIGN KEY (finding_id) REFERENCES ilb_finding(finding_id),
  CONSTRAINT fk_ilb_finding_equation_equation FOREIGN KEY (equation_id) REFERENCES ilb_equation_definition(equation_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_evidence_reference (
  evidence_id CHAR(64) PRIMARY KEY,
  evidence_code VARCHAR(160) NOT NULL UNIQUE,
  title_or_claim TEXT NOT NULL,
  evidence_type VARCHAR(160) NOT NULL,
  population_or_model TEXT NULL,
  intervention_or_exposure TEXT NULL,
  comparator_text TEXT NULL,
  measured_signal TEXT NULL,
  magnitude_text TEXT NULL,
  timeframe_text VARCHAR(255) NULL,
  unit_text VARCHAR(255) NULL,
  source_url TEXT NULL,
  publication_year SMALLINT UNSIGNED NULL,
  quality_grade VARCHAR(160) NULL,
  notes TEXT NULL,
  lifecycle_status ENUM('DRAFT','STAGED','APPROVED','RETIRED') NOT NULL DEFAULT 'DRAFT',
  source_batch_id CHAR(36) NULL,
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_finding_evidence (
  finding_id CHAR(64) NOT NULL,
  evidence_id CHAR(64) NOT NULL,
  evidence_role ENUM('SUPPORTS','QUANTIFIES','CONFLICTS','LIMITS','VALIDATES') NOT NULL DEFAULT 'SUPPORTS',
  PRIMARY KEY (finding_id,evidence_id,evidence_role),
  CONSTRAINT fk_ilb_finding_evidence_finding FOREIGN KEY (finding_id) REFERENCES ilb_finding(finding_id),
  CONSTRAINT fk_ilb_finding_evidence_evidence FOREIGN KEY (evidence_id) REFERENCES ilb_evidence_reference(evidence_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_finding_intervention (
  finding_id CHAR(64) NOT NULL,
  intervention_entity_id CHAR(64) NOT NULL,
  relevance ENUM('DIRECT_TARGET','SUPPORTING','COMPARATOR','CONTRAINDICATED','RESEARCH_ONLY') NOT NULL DEFAULT 'SUPPORTING',
  PRIMARY KEY (finding_id,intervention_entity_id,relevance),
  CONSTRAINT fk_ilb_finding_intervention_finding FOREIGN KEY (finding_id) REFERENCES ilb_finding(finding_id),
  CONSTRAINT fk_ilb_finding_intervention_entity FOREIGN KEY (intervention_entity_id) REFERENCES ilb_semantic_entity(entity_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_finding_outcome (
  finding_id CHAR(64) NOT NULL,
  outcome_entity_id CHAR(64) NOT NULL,
  relevance ENUM('PRIMARY','SECONDARY','SURROGATE','SAFETY') NOT NULL DEFAULT 'PRIMARY',
  PRIMARY KEY (finding_id,outcome_entity_id,relevance),
  CONSTRAINT fk_ilb_finding_outcome_finding FOREIGN KEY (finding_id) REFERENCES ilb_finding(finding_id),
  CONSTRAINT fk_ilb_finding_outcome_entity FOREIGN KEY (outcome_entity_id) REFERENCES ilb_semantic_entity(entity_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT IGNORE INTO ilb_relation_type(relation_code,label,is_directional) VALUES
('BINDS_TO','binds to',TRUE),
('INCREASES','increases',TRUE),
('DECREASES','decreases',TRUE),
('CONVERTS_TO','converts to',TRUE),
('TRANSPORTS_TO','transports to',TRUE),
('ABSORBED_IN','absorbed in',TRUE),
('METABOLIZED_IN','metabolized in',TRUE),
('EXCRETED_BY','excreted by',TRUE),
('REQUIRES','requires',TRUE),
('PREDICTS','predicts',TRUE),
('MODULATES','modulates',TRUE),
('CONTRAINDICATED_IN','contraindicated in',TRUE);

INSERT IGNORE INTO ilb_semantic_type(type_code,label) VALUES
('MODALITY','Treatment modality'),
('EVIDENCE','Evidence reference');

CREATE OR REPLACE VIEW v_ilb_finding_readiness AS
SELECT
  f.finding_id,
  f.finding_code,
  f.title,
  f.finding_type,
  f.evidence_status,
  f.quantification_status,
  f.lifecycle_status,
  COUNT(DISTINCT fe.evidence_id) AS evidence_count,
  COUNT(DISTINCT fx.finding_edge_id) AS edge_count,
  COUNT(DISTINCT fv.variable_id) AS variable_count,
  COUNT(DISTINCT fq.equation_id) AS equation_count,
  CASE
    WHEN f.lifecycle_status <> 'APPROVED' THEN 'BLOCKED'
    WHEN COUNT(DISTINCT fe.evidence_id) = 0 THEN 'BLOCKED'
    WHEN f.finding_type IN ('MECHANISM','TREATMENT_MECHANISM','PLUMBING') AND COUNT(DISTINCT fx.finding_edge_id) = 0 THEN 'BLOCKED'
    WHEN f.quantification_status = 'QUANTIFIED' AND COUNT(DISTINCT fv.variable_id) = 0 THEN 'BLOCKED'
    ELSE 'READY'
  END AS readiness_status
FROM ilb_finding f
LEFT JOIN ilb_finding_evidence fe ON fe.finding_id=f.finding_id
LEFT JOIN ilb_finding_edge fx ON fx.finding_id=f.finding_id
LEFT JOIN ilb_finding_variable fv ON fv.finding_id=f.finding_id
LEFT JOIN ilb_finding_equation fq ON fq.finding_id=f.finding_id
GROUP BY f.finding_id,f.finding_code,f.title,f.finding_type,f.evidence_status,f.quantification_status,f.lifecycle_status;

-- Seed evidence records for the first psoriasis findings.
INSERT IGNORE INTO ilb_evidence_reference(
  evidence_id,evidence_code,title_or_claim,evidence_type,population_or_model,
  measured_signal,magnitude_text,timeframe_text,source_url,publication_year,quality_grade,notes,lifecycle_status
) VALUES
('EVD-PSO-0001','EVD-PSO-0001','IL-23/IL-17 axis central to psoriasis pathogenesis','review / disease primer','human psoriasis','IL-23/IL-17 axis; keratinocyte hyperproliferation','qualitative central-driver conclusion','chronic','https://www.nature.com/articles/s41572-025-00630-5',2025,'high-level review','Nature Reviews Disease Primers','STAGED'),
('EVD-PSO-0002','EVD-PSO-0002','IL-17 signaling acts on keratinocytes and induces inflammatory mediators','mechanistic review','human + experimental psoriasis','chemokines/AMPs/cytokines and proliferation','pathway-direction evidence','signaling timescale','https://www.nature.com/articles/s41392-023-01655-6',2023,'mechanistic review','Signal Transduction and Targeted Therapy','STAGED'),
('EVD-PSO-0003','EVD-PSO-0003','Keratinocyte feed-forward inflammatory circuits in psoriasis','mechanistic review','human + experimental psoriasis','inflammatory genes, chemokines, AMP production','pathway-direction evidence','chronic','https://www.nature.com/articles/s41419-022-04523-3',2022,'mechanistic review','Cell Death & Disease','STAGED'),
('EVD-PSO-0004','EVD-PSO-0004','Human single-cell psoriasis resolution after IL-23 blockade','human mechanistic study','psoriasis skin','IL-17-related gene programs in keratinocytes','FDR < 1e-4 in supra-spinous; < 1e-2 in spinous keratinocytes for reported enrichment','early treatment timepoints','https://www.nature.com/articles/s41467-024-44994-w',2024,'human tissue mechanistic','Nature Communications','STAGED'),
('EVD-PSO-0005','EVD-PSO-0005','Weight-loss interventions and psoriasis severity meta-analysis','systematic review/meta-analysis','psoriasis intervention cohorts','PASI, PASI75, DLQI','PASI MD -2.5; PASI75 RR 1.6; DLQI MD -5.0','study-dependent','https://pubmed.ncbi.nlm.nih.gov/41416383/',2025,'systematic review/meta-analysis','n=1,145 overall across 14 PASI comparisons; heterogeneity noted','STAGED');

-- Findings are seeded without forcing disease/entity foreign keys that may use different
-- canonical IDs in the live database. Projection/mapping should attach those after exact matching.
INSERT IGNORE INTO ilb_finding(
  finding_id,disease_entity_id,finding_code,title,finding_type,finding_statement,
  evidence_status,quantification_status,clinical_actionability,magnitude_text,timeframe_text,
  population_or_model,conflict_or_limit,next_data_needed,lifecycle_status
) VALUES
('FND-PSO-0001',NULL,'FND-PSO-0001','IL-23/IL-17 axis is a central psoriasis driver','MECHANISM','Psoriasis is strongly linked to dysregulation of the IL-23-Th17/IL-17 axis; IL-17 signaling acts directly on keratinocytes and amplifies inflammatory recruitment.','MECHANISTIC_SUPPORTED','NOT_QUANTIFIED','HIGH','Mechanistic direction established; no single universal coefficient.','chronic disease network','human disease + mechanistic evidence','Magnitude depends on compartment, phenotype and intervention.','Human quantitative mediator-to-skin response coefficients by defined compartment/time.','STAGED'),
('FND-PSO-0002',NULL,'FND-PSO-0002','IL-17 creates a feed-forward keratinocyte inflammatory circuit','MECHANISM','IL-17A/F signaling in keratinocytes induces antimicrobial peptides, chemokines and inflammatory genes that recruit additional immune cells and reinforce psoriasis inflammation.','MECHANISTIC_SUPPORTED','NOT_QUANTIFIED','HIGH','Direction and pathway supported; universal dose-response coefficient unavailable.','hours-to-days at signaling level','human tissue + mechanistic literature','Many reported effects are pathway/tissue specific, not a single clinical transfer function.','Defined IL-17 concentration-to-keratinocyte-output equations from human tissue.','STAGED'),
('FND-PSO-0003',NULL,'FND-PSO-0003','Keratinocytes are active amplifiers, not passive endpoints','MECHANISM','Activated keratinocytes produce cytokines, chemokines and antimicrobial peptides, feeding inflammatory loops and contributing to epidermal hyperplasia.','MECHANISTIC_SUPPORTED','NOT_QUANTIFIED','HIGH','Mechanism supported; no universal scalar strength.','chronic/recurrent','human + experimental models','Some causal detail comes from experimental models.','Human lesion time-series linking keratinocyte signals to immune recruitment.','STAGED'),
('FND-PSO-0004',NULL,'FND-PSO-0004','IL-23 blockade downregulates epidermal IL-17 signaling','TREATMENT_MECHANISM','Single-cell human skin analysis after IL-23 blockade showed marked downregulation of IL-17-related signaling in spinous and supra-spinous keratinocytes.','QUANTIFIED','PARTIAL','HIGH','IL-17-related gene enrichment reduced; study reports pathway-level statistics rather than a universal concentration coefficient.','early treatment timepoints','human psoriasis skin single-cell study','Specific to the studied IL-23 inhibitor/cohort and transcriptomic endpoints.','Translate transcriptomic changes into standardized ILMB pathway parameters.','STAGED'),
('FND-PSO-0005',NULL,'FND-PSO-0005','Weight-loss intervention can improve psoriasis severity in overweight/obese populations','CLINICAL_LEVER','A 2025 systematic review/meta-analysis found weight-loss interventions reduced PASI and increased the likelihood of PASI75 compared with control.','QUANTIFIED','QUANTIFIED','CONDITIONAL','Mean PASI difference -2.5; PASI75 RR 1.6; mean weight change approximately -6.7 to -7.3 kg across relevant analyses.','study-dependent follow-up','14 comparisons; 1,145 participants overall','High heterogeneity for continuous PASI; applies to studied populations/interventions, not every patient.','Mechanistic mediator measurements linking weight change to IL-23/IL-17/TNF nodes.','STAGED');

INSERT IGNORE INTO ilb_finding_evidence(finding_id,evidence_id,evidence_role) VALUES
('FND-PSO-0001','EVD-PSO-0001','SUPPORTS'),
('FND-PSO-0002','EVD-PSO-0002','SUPPORTS'),
('FND-PSO-0003','EVD-PSO-0003','SUPPORTS'),
('FND-PSO-0004','EVD-PSO-0004','QUANTIFIES'),
('FND-PSO-0005','EVD-PSO-0005','QUANTIFIES');
