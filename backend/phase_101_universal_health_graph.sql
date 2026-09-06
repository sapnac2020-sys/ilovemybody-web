-- ILoveMyBody universal semantic, calculation and hospital-report foundation.
-- Additive only. MySQL 8 / MariaDB 10.5 compatible.

CREATE TABLE IF NOT EXISTS ilb_semantic_type (
  type_code VARCHAR(64) PRIMARY KEY,
  label VARCHAR(160) NOT NULL,
  parent_type_code VARCHAR(64) NULL,
  description TEXT NULL,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  CONSTRAINT fk_semantic_type_parent FOREIGN KEY (parent_type_code) REFERENCES ilb_semantic_type(type_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_semantic_entity (
  entity_id CHAR(64) PRIMARY KEY,
  type_code VARCHAR(64) NOT NULL,
  canonical_code VARCHAR(255) NOT NULL,
  preferred_label VARCHAR(512) NOT NULL,
  definition TEXT NULL,
  lifecycle_status ENUM('DRAFT','STAGED','APPROVED','RETIRED') NOT NULL DEFAULT 'DRAFT',
  source_batch_id CHAR(36) NULL,
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  UNIQUE KEY uq_semantic_entity_code (type_code, canonical_code),
  KEY ix_semantic_entity_status (lifecycle_status),
  CONSTRAINT fk_semantic_entity_type FOREIGN KEY (type_code) REFERENCES ilb_semantic_type(type_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_entity_identifier (
  identifier_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  entity_id CHAR(64) NOT NULL,
  namespace_code VARCHAR(64) NOT NULL,
  identifier_value VARCHAR(512) NOT NULL,
  match_status ENUM('CANDIDATE','EXACT','REJECTED') NOT NULL DEFAULT 'CANDIDATE',
  approval_status ENUM('PENDING','APPROVED','REJECTED') NOT NULL DEFAULT 'PENDING',
  source_batch_id CHAR(36) NULL,
  UNIQUE KEY uq_entity_identifier (namespace_code, identifier_value),
  KEY ix_entity_identifier_entity (entity_id),
  CONSTRAINT fk_entity_identifier_entity FOREIGN KEY (entity_id) REFERENCES ilb_semantic_entity(entity_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_relation_type (
  relation_code VARCHAR(64) PRIMARY KEY,
  label VARCHAR(160) NOT NULL,
  source_type_code VARCHAR(64) NULL,
  target_type_code VARCHAR(64) NULL,
  inverse_relation_code VARCHAR(64) NULL,
  is_directional BOOLEAN NOT NULL DEFAULT TRUE,
  active BOOLEAN NOT NULL DEFAULT TRUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_entity_relation (
  relation_id CHAR(64) PRIMARY KEY,
  source_entity_id CHAR(64) NOT NULL,
  relation_code VARCHAR(64) NOT NULL,
  target_entity_id CHAR(64) NOT NULL,
  assertion_status ENUM('HYPOTHESIS','STRUCTURAL_FACT','MEASURED','CALCULATED','REJECTED') NOT NULL,
  verification_status ENUM('PENDING','APPROVED','REJECTED') NOT NULL DEFAULT 'PENDING',
  confidence_value DECIMAL(10,8) NULL,
  source_batch_id CHAR(36) NULL,
  valid_from DATETIME(6) NULL,
  valid_to DATETIME(6) NULL,
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  UNIQUE KEY uq_entity_relation (source_entity_id, relation_code, target_entity_id, source_batch_id),
  KEY ix_entity_relation_target (target_entity_id, relation_code),
  CONSTRAINT fk_entity_relation_source FOREIGN KEY (source_entity_id) REFERENCES ilb_semantic_entity(entity_id),
  CONSTRAINT fk_entity_relation_type FOREIGN KEY (relation_code) REFERENCES ilb_relation_type(relation_code),
  CONSTRAINT fk_entity_relation_target FOREIGN KEY (target_entity_id) REFERENCES ilb_semantic_entity(entity_id),
  CHECK (confidence_value IS NULL OR (confidence_value >= 0 AND confidence_value <= 1))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_field_mapping (
  mapping_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  system_id VARCHAR(32) NOT NULL,
  sheet_name_pattern VARCHAR(255) NOT NULL,
  source_field VARCHAR(255) NOT NULL,
  semantic_role ENUM('ENTITY_CODE','ENTITY_LABEL','IDENTIFIER','RELATION_SOURCE','RELATION_TARGET','RELATION_TYPE','VARIABLE','VALUE','UNIT','EQUATION','STATUS','PROVENANCE','IGNORE') NOT NULL,
  target_type_code VARCHAR(64) NULL,
  target_namespace_code VARCHAR(64) NULL,
  target_relation_code VARCHAR(64) NULL,
  required_flag BOOLEAN NOT NULL DEFAULT FALSE,
  transform_rule JSON NULL,
  mapping_version INT UNSIGNED NOT NULL DEFAULT 1,
  approval_status ENUM('DRAFT','APPROVED','RETIRED') NOT NULL DEFAULT 'DRAFT',
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  UNIQUE KEY uq_field_mapping_version (system_id, sheet_name_pattern, source_field, mapping_version)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_projection_run (
  projection_run_id CHAR(36) PRIMARY KEY,
  source_batch_id CHAR(36) NOT NULL,
  mapping_version INT UNSIGNED NOT NULL,
  status ENUM('VALIDATING','BLOCKED','READY','PROJECTED','FAILED') NOT NULL,
  staged_rows INT UNSIGNED NOT NULL DEFAULT 0,
  projected_entities INT UNSIGNED NOT NULL DEFAULT 0,
  projected_relations INT UNSIGNED NOT NULL DEFAULT 0,
  error_count INT UNSIGNED NOT NULL DEFAULT 0,
  started_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  completed_at DATETIME(6) NULL,
  UNIQUE KEY uq_projection_batch_mapping (source_batch_id, mapping_version)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_projection_error (
  projection_error_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  projection_run_id CHAR(36) NOT NULL,
  row_id CHAR(64) NULL,
  source_field VARCHAR(255) NULL,
  error_code VARCHAR(64) NOT NULL,
  message TEXT NOT NULL,
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  KEY ix_projection_error_run (projection_run_id),
  CONSTRAINT fk_projection_error_run FOREIGN KEY (projection_run_id) REFERENCES ilb_projection_run(projection_run_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_variable_definition (
  variable_id CHAR(64) PRIMARY KEY,
  variable_code VARCHAR(160) NOT NULL UNIQUE,
  entity_id CHAR(64) NULL,
  label VARCHAR(512) NOT NULL,
  quantity_kind VARCHAR(160) NULL,
  canonical_unit_code VARCHAR(64) NULL,
  value_domain ENUM('NUMBER','INTEGER','BOOLEAN','CATEGORY','TEXT','DATETIME') NOT NULL DEFAULT 'NUMBER',
  minimum_value DECIMAL(38,12) NULL,
  maximum_value DECIMAL(38,12) NULL,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  CONSTRAINT fk_variable_entity FOREIGN KEY (entity_id) REFERENCES ilb_semantic_entity(entity_id),
  CHECK (minimum_value IS NULL OR maximum_value IS NULL OR minimum_value <= maximum_value)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_equation_definition (
  equation_id CHAR(64) PRIMARY KEY,
  equation_code VARCHAR(160) NOT NULL,
  version_no INT UNSIGNED NOT NULL,
  label VARCHAR(512) NOT NULL,
  expression_language ENUM('ILMB_EXPR_V1','SQL','PYTHON','R','SBML','TEXT_ONLY') NOT NULL DEFAULT 'ILMB_EXPR_V1',
  expression_text LONGTEXT NOT NULL,
  output_variable_id CHAR(64) NOT NULL,
  evaluation_mode ENUM('ALGEBRAIC','ODE','RULE','AGGREGATION') NOT NULL,
  time_basis_unit_code VARCHAR(64) NULL,
  source_status ENUM('PHYSICS_CHEMISTRY','MEASURED_PERSON','STRUCTURAL','HYPOTHESIS','EXTERNAL_RANGE') NOT NULL,
  approval_status ENUM('DRAFT','APPROVED','RETIRED') NOT NULL DEFAULT 'DRAFT',
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  UNIQUE KEY uq_equation_version (equation_code, version_no),
  CONSTRAINT fk_equation_output FOREIGN KEY (output_variable_id) REFERENCES ilb_variable_definition(variable_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_equation_dependency (
  equation_id CHAR(64) NOT NULL,
  input_variable_id CHAR(64) NOT NULL,
  dependency_order INT UNSIGNED NOT NULL,
  required_flag BOOLEAN NOT NULL DEFAULT TRUE,
  lag_seconds DECIMAL(24,6) NOT NULL DEFAULT 0,
  PRIMARY KEY (equation_id, input_variable_id),
  UNIQUE KEY uq_equation_dependency_order (equation_id, dependency_order),
  CONSTRAINT fk_equation_dependency_equation FOREIGN KEY (equation_id) REFERENCES ilb_equation_definition(equation_id),
  CONSTRAINT fk_equation_dependency_variable FOREIGN KEY (input_variable_id) REFERENCES ilb_variable_definition(variable_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_equation_gate (
  gate_id CHAR(64) PRIMARY KEY,
  equation_id CHAR(64) NOT NULL,
  gate_code VARCHAR(64) NOT NULL,
  gate_status ENUM('PASS','BLOCKED','FAIL') NOT NULL DEFAULT 'BLOCKED',
  reason_text TEXT NULL,
  checked_at DATETIME(6) NULL,
  UNIQUE KEY uq_equation_gate (equation_id, gate_code),
  CONSTRAINT fk_equation_gate_equation FOREIGN KEY (equation_id) REFERENCES ilb_equation_definition(equation_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_calculation_run (
  calculation_run_id CHAR(36) PRIMARY KEY,
  subject_key VARCHAR(255) NULL,
  model_code VARCHAR(160) NOT NULL,
  model_version INT UNSIGNED NOT NULL,
  status ENUM('CREATED','BLOCKED','RUNNING','COMPLETED','FAILED') NOT NULL,
  input_hash CHAR(64) NOT NULL,
  engine_version VARCHAR(64) NOT NULL,
  started_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  completed_at DATETIME(6) NULL,
  UNIQUE KEY uq_calculation_replay (model_code, model_version, input_hash, engine_version)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_calculation_value (
  calculation_run_id CHAR(36) NOT NULL,
  variable_id CHAR(64) NOT NULL,
  time_offset_seconds DECIMAL(24,6) NOT NULL DEFAULT 0,
  value_number DECIMAL(38,12) NULL,
  value_text TEXT NULL,
  unit_code VARCHAR(64) NULL,
  value_origin ENUM('MEASURED','DERIVED','ASSUMPTION','MISSING') NOT NULL,
  source_record_id CHAR(64) NULL,
  PRIMARY KEY (calculation_run_id, variable_id, time_offset_seconds),
  CONSTRAINT fk_calculation_value_run FOREIGN KEY (calculation_run_id) REFERENCES ilb_calculation_run(calculation_run_id),
  CONSTRAINT fk_calculation_value_variable FOREIGN KEY (variable_id) REFERENCES ilb_variable_definition(variable_id),
  CHECK (value_number IS NOT NULL OR value_text IS NOT NULL OR value_origin = 'MISSING')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_hospital_report (
  report_id CHAR(36) PRIMARY KEY,
  subject_key VARCHAR(255) NOT NULL,
  report_version INT UNSIGNED NOT NULL,
  report_status ENUM('DRAFT','BLOCKED','CLINICIAN_REVIEW','APPROVED','SUPERSEDED') NOT NULL DEFAULT 'DRAFT',
  quality_of_life_variable_id CHAR(64) NULL,
  quality_of_life_value DECIMAL(18,8) NULL,
  generated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  generated_by VARCHAR(255) NOT NULL,
  approved_at DATETIME(6) NULL,
  approved_by VARCHAR(255) NULL,
  UNIQUE KEY uq_hospital_report_version (subject_key, report_version),
  CONSTRAINT fk_report_qol_variable FOREIGN KEY (quality_of_life_variable_id) REFERENCES ilb_variable_definition(variable_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_hospital_report_section (
  report_id CHAR(36) NOT NULL,
  section_code VARCHAR(64) NOT NULL,
  display_order INT UNSIGNED NOT NULL,
  section_status ENUM('READY','BLOCKED','NOT_APPLICABLE') NOT NULL,
  payload_json JSON NOT NULL,
  calculation_run_id CHAR(36) NULL,
  PRIMARY KEY (report_id, section_code),
  UNIQUE KEY uq_report_display_order (report_id, display_order),
  CONSTRAINT fk_report_section_report FOREIGN KEY (report_id) REFERENCES ilb_hospital_report(report_id),
  CONSTRAINT fk_report_section_calculation FOREIGN KEY (calculation_run_id) REFERENCES ilb_calculation_run(calculation_run_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_hospital_report_gate (
  report_id CHAR(36) NOT NULL,
  gate_code VARCHAR(64) NOT NULL,
  gate_status ENUM('PASS','BLOCKED','FAIL') NOT NULL,
  reason_text TEXT NULL,
  checked_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (report_id, gate_code),
  CONSTRAINT fk_report_gate_report FOREIGN KEY (report_id) REFERENCES ilb_hospital_report(report_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT IGNORE INTO ilb_semantic_type(type_code,label) VALUES
('BODY_SYSTEM','Body system'),('ORGAN','Organ'),('TISSUE','Tissue'),('CELL','Cell'),
('ORGANELLE','Organelle'),('MOLECULE','Molecule'),('PATHWAY','Pathway'),('GENE','Gene'),
('PROTEIN','Protein'),('PHENOTYPE','Phenotype'),('SYMPTOM','Symptom'),('DISEASE','Disease'),
('TEST','Diagnostic test'),('MEDICINE','Medicine'),('FOOD','Food'),('NUTRIENT','Nutrient'),
('INTERVENTION','Intervention'),('BEHAVIOUR','Behaviour'),('ENVIRONMENT','Environment'),
('OUTCOME','Outcome'),('QUALITY_OF_LIFE','Quality of life');

INSERT IGNORE INTO ilb_relation_type(relation_code,label,is_directional) VALUES
('PART_OF','part of',TRUE),('LOCATED_IN','located in',TRUE),('CONTAINS','contains',TRUE),
('MEASURES','measures',TRUE),('EXPRESSES','expresses',TRUE),('PARTICIPATES_IN','participates in',TRUE),
('CAUSES','causes',TRUE),('ASSOCIATED_WITH','associated with',FALSE),('MANIFESTS_AS','manifests as',TRUE),
('ACTS_ON','acts on',TRUE),('INHIBITS','inhibits',TRUE),('ACTIVATES','activates',TRUE),
('TREATS','treats',TRUE),('HAS_SIDE_EFFECT','has side effect',TRUE),('MODIFIES','modifies',TRUE),
('AFFECTS_QOL','affects quality of life',TRUE);

CREATE OR REPLACE VIEW v_ilb_equation_readiness AS
SELECT e.equation_id,e.equation_code,e.version_no,e.label,e.approval_status,
       COUNT(d.input_variable_id) AS dependency_count,
       SUM(CASE WHEN g.gate_status='PASS' THEN 1 ELSE 0 END) AS passing_gates,
       SUM(CASE WHEN g.gate_status<>'PASS' OR g.gate_status IS NULL THEN 1 ELSE 0 END) AS blocking_gates,
       CASE WHEN e.approval_status='APPROVED'
                 AND COUNT(d.input_variable_id)>0
                 AND SUM(CASE WHEN g.gate_status<>'PASS' OR g.gate_status IS NULL THEN 1 ELSE 0 END)=0
            THEN 'READY' ELSE 'BLOCKED' END AS readiness_status
FROM ilb_equation_definition e
LEFT JOIN ilb_equation_dependency d ON d.equation_id=e.equation_id
LEFT JOIN ilb_equation_gate g ON g.equation_id=e.equation_id
GROUP BY e.equation_id,e.equation_code,e.version_no,e.label,e.approval_status;

CREATE OR REPLACE VIEW v_ilb_hospital_report_readiness AS
SELECT r.report_id,r.subject_key,r.report_version,r.report_status,
       COUNT(DISTINCT s.section_code) AS section_count,
       SUM(CASE WHEN s.section_status='BLOCKED' THEN 1 ELSE 0 END) AS blocked_sections,
       SUM(CASE WHEN g.gate_status='PASS' THEN 1 ELSE 0 END) AS passing_gates,
       SUM(CASE WHEN g.gate_status<>'PASS' THEN 1 ELSE 0 END) AS blocking_gates,
       CASE WHEN COUNT(DISTINCT s.section_code)>0
                 AND SUM(CASE WHEN s.section_status='BLOCKED' THEN 1 ELSE 0 END)=0
                 AND SUM(CASE WHEN g.gate_status<>'PASS' THEN 1 ELSE 0 END)=0
            THEN 'READY_FOR_CLINICIAN_REVIEW' ELSE 'BLOCKED' END AS readiness_status
FROM ilb_hospital_report r
LEFT JOIN ilb_hospital_report_section s ON s.report_id=r.report_id
LEFT JOIN ilb_hospital_report_gate g ON g.report_id=r.report_id
GROUP BY r.report_id,r.subject_key,r.report_version,r.report_status;

CREATE OR REPLACE VIEW v_ilb_universal_platform_readiness AS
SELECT 'UNIVERSAL_FIELD_MAPPING' AS component,
       COUNT(*) AS object_count,
       SUM(approval_status='APPROVED') AS approved_count,
       CASE WHEN COUNT(*)>0 AND SUM(approval_status='APPROVED')>0 THEN 'PARTIAL' ELSE 'BLOCKED' END AS status
FROM ilb_field_mapping
UNION ALL
SELECT 'RELATIONAL_BODY_GRAPH',COUNT(*),SUM(verification_status='APPROVED'),
       CASE WHEN COUNT(*)>0 AND SUM(verification_status='APPROVED')>0 THEN 'PARTIAL' ELSE 'BLOCKED' END
FROM ilb_entity_relation
UNION ALL
SELECT 'EQUATION_DEPENDENCY_ENGINE',COUNT(*),SUM(readiness_status='READY'),
       CASE WHEN COUNT(*)>0 AND SUM(readiness_status='READY')>0 THEN 'PARTIAL' ELSE 'BLOCKED' END
FROM v_ilb_equation_readiness
UNION ALL
SELECT 'HOSPITAL_REPORT_ENGINE',COUNT(*),SUM(readiness_status='READY_FOR_CLINICIAN_REVIEW'),
       CASE WHEN COUNT(*)>0 AND SUM(readiness_status='READY_FOR_CLINICIAN_REVIEW')>0 THEN 'PARTIAL' ELSE 'BLOCKED' END
FROM v_ilb_hospital_report_readiness;
