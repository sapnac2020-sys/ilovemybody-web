-- Phase 93: source-exact 3D psoriasis model parameters and explicit gaps.
START TRANSACTION;
CREATE TABLE IF NOT EXISTS ilb_psoriasis_experiment_parameter (
 parameter_key varchar(100) NOT NULL,
 experiment_key varchar(80) NOT NULL,
 stage_key varchar(80) NULL,
 parameter_name varchar(200) NOT NULL,
 numeric_value decimal(20,8) NULL,
 unit varchar(80) NULL,
 text_value varchar(500) NULL,
 source_id varchar(80) NULL,
 source_url varchar(1000) NULL,
 resolution enum('SOURCE_EXACT','UNRESOLVED') NOT NULL,
 required_for_execution tinyint(1) NOT NULL DEFAULT 1,
 PRIMARY KEY(parameter_key),
 CONSTRAINT fk_p93_experiment FOREIGN KEY(experiment_key) REFERENCES ilb_psoriasis_experiment(experiment_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO ilb_psoriasis_experiment_parameter VALUES
('MODEL_TCELL_TOTAL','EXP_PSO_RESET_001','S1_INDUCTION','T cells seeded per dermal sheet',500000,'cells/sheet',NULL,'PMCID:PMC9497242','https://pmc.ncbi.nlm.nih.gov/articles/PMC9497242/','SOURCE_EXACT',1),
('MODEL_TH1_TH17_RATIO','EXP_PSO_RESET_001','S1_INDUCTION','Polarized Th1 to Th17 ratio',NULL,NULL,'1:1','PMCID:PMC9497242','https://pmc.ncbi.nlm.nih.gov/articles/PMC9497242/','SOURCE_EXACT',1),
('MODEL_IL2','EXP_PSO_RESET_001','S1_INDUCTION','IL-2 concentration during additional submerged week',10,'U/mL',NULL,'PMCID:PMC9497242','https://pmc.ncbi.nlm.nih.gov/articles/PMC9497242/','SOURCE_EXACT',1),
('MODEL_IL23','EXP_PSO_RESET_001','S1_INDUCTION','IL-23 concentration during additional submerged week',20,'ng/mL',NULL,'PMCID:PMC9497242','https://pmc.ncbi.nlm.nih.gov/articles/PMC9497242/','SOURCE_EXACT',1),
('MODEL_TCELL_KC_SEPARATE_DAYS','EXP_PSO_RESET_001','S1_INDUCTION','Separate keratinocyte/T-cell culture with fibroblast sheets',7,'days',NULL,'PMCID:PMC10526348','https://pmc.ncbi.nlm.nih.gov/articles/PMC10526348/','SOURCE_EXACT',1),
('MODEL_AIR_LIQUID_DAYS','EXP_PSO_RESET_001','S1_INDUCTION','Culture at air-liquid interface after assembly',21,'days',NULL,'PMID:33857488','https://pubmed.ncbi.nlm.nih.gov/33857488/','SOURCE_EXACT',1),
('EPA_CONCENTRATION','EXP_PSO_RESET_001','S2_INTERVENTION','EPA concentration in culture medium',10,'micromol/L',NULL,'PMID:37597582','https://pubmed.ncbi.nlm.nih.gov/37597582/','SOURCE_EXACT',1),
('ALA_CONCENTRATION','EXP_PSO_RESET_001','S2_INTERVENTION','ALA concentration in culture medium',10,'micromol/L',NULL,'PMID:35563819','https://pubmed.ncbi.nlm.nih.gov/35563819/','SOURCE_EXACT',1),
('IL17_BLOCK_CONCENTRATION','EXP_PSO_RESET_001','S2_INTERVENTION','Anti-IL-17 comparator concentration',NULL,NULL,NULL,NULL,NULL,'UNRESOLVED',1),
('IL23_BLOCK_CONCENTRATION','EXP_PSO_RESET_001','S2_INTERVENTION','Anti-IL-23 candidate concentration',NULL,NULL,NULL,NULL,NULL,'UNRESOLVED',1),
('BARRIER_CANDIDATE_ID','EXP_PSO_RESET_001','S2_INTERVENTION','Barrier-directed experimental candidate identity',NULL,NULL,NULL,NULL,NULL,'UNRESOLVED',1),
('INTERVENTION_DURATION','EXP_PSO_RESET_001','S2_INTERVENTION','Intervention duration for reset comparison',NULL,NULL,NULL,NULL,NULL,'UNRESOLVED',1),
('WASHOUT_DETECTION_ASSAY','EXP_PSO_RESET_001','S3_WASHOUT','Analytical assay proving intervention removal',NULL,NULL,NULL,NULL,NULL,'UNRESOLVED',1),
('WASHOUT_DETECTION_LIMIT','EXP_PSO_RESET_001','S3_WASHOUT','Validated intervention detection limit',NULL,NULL,NULL,NULL,NULL,'UNRESOLVED',1),
('RENEWAL_DURATION','EXP_PSO_RESET_001','S4_RENEWAL','Intervention-free renewal observation duration',NULL,NULL,NULL,NULL,NULL,'UNRESOLVED',1),
('RECHALLENGE_STIMULUS','EXP_PSO_RESET_001','S5_RECHALLENGE','Matched inflammatory rechallenge identity and concentration',NULL,NULL,NULL,NULL,NULL,'UNRESOLVED',1),
('RECHALLENGE_DURATION','EXP_PSO_RESET_001','S5_RECHALLENGE','Post-rechallenge observation duration',NULL,NULL,NULL,NULL,NULL,'UNRESOLVED',1),
('PASS_TOLERANCE','EXP_PSO_RESET_001',NULL,'Preregistered equivalence tolerance against healthy control',NULL,NULL,NULL,NULL,NULL,'UNRESOLVED',1)
ON DUPLICATE KEY UPDATE stage_key=VALUES(stage_key),parameter_name=VALUES(parameter_name),numeric_value=VALUES(numeric_value),unit=VALUES(unit),text_value=VALUES(text_value),source_id=VALUES(source_id),source_url=VALUES(source_url),resolution=VALUES(resolution),required_for_execution=VALUES(required_for_execution);
COMMIT;

-- Deployment trigger: Phase 93 live verification.
