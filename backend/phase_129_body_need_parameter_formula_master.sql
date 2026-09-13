-- ILoveMyBody Phase 129: Canonical Body Need Parameter + Formula Master
-- One governed layer linking observations, common parameters, terminology IDs,
-- formulas and person-specific body-need outputs.
-- No target, coefficient or clinical recommendation is invented here.

CREATE TABLE IF NOT EXISTS ilmb_parameter_master (
    parameter_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    parameter_key VARCHAR(191) NOT NULL,
    canonical_name VARCHAR(255) NOT NULL,
    parameter_domain VARCHAR(64) NOT NULL,
    value_kind ENUM('numeric','integer','boolean','text','coded','ratio','rate') NOT NULL DEFAULT 'numeric',
    canonical_ucum_unit VARCHAR(64) NULL,
    specimen_or_context VARCHAR(255) NULL,
    body_scope VARCHAR(255) NULL,
    definition_text TEXT NULL,
    source_system VARCHAR(64) NULL,
    source_record_key VARCHAR(191) NULL,
    status ENUM('ACTIVE','REVIEW','DEPRECATED') NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_ilmb_parameter_key (parameter_key),
    KEY ix_ilmb_parameter_domain (parameter_domain),
    KEY ix_ilmb_parameter_name (canonical_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilmb_parameter_identifier (
    parameter_identifier_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    parameter_id BIGINT UNSIGNED NOT NULL,
    identifier_system VARCHAR(32) NOT NULL,
    identifier_code VARCHAR(191) NOT NULL,
    identifier_label VARCHAR(255) NULL,
    mapping_type ENUM('EXACT','NARROWER','BROADER','RELATED','CANDIDATE') NOT NULL DEFAULT 'CANDIDATE',
    verification_status ENUM('APPROVED','REVIEW','REJECTED') NOT NULL DEFAULT 'REVIEW',
    source_url VARCHAR(1024) NULL,
    source_version VARCHAR(64) NULL,
    verified_at DATETIME NULL,
    verified_by VARCHAR(191) NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_ilmb_parameter_identifier (identifier_system, identifier_code, parameter_id),
    KEY ix_ilmb_identifier_parameter (parameter_id),
    CONSTRAINT fk_ilmb_identifier_parameter FOREIGN KEY (parameter_id) REFERENCES ilmb_parameter_master(parameter_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilmb_formula_master (
    formula_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    formula_key VARCHAR(191) NOT NULL,
    formula_name VARCHAR(255) NOT NULL,
    formula_domain VARCHAR(64) NOT NULL,
    output_parameter_id BIGINT UNSIGNED NULL,
    expression_text TEXT NOT NULL,
    expression_language ENUM('ILMB_EXPR_V1','SQL','PYTHON_REFERENCE','EQUATION_TEXT') NOT NULL DEFAULT 'ILMB_EXPR_V1',
    purpose ENUM('MEASUREMENT_NORMALIZATION','DERIVATION','TARGET_GAP','REQUIREMENT','PHYSICS','CHEMISTRY','PHYSIOLOGY','OTHER') NOT NULL,
    evidence_class ENUM('FIRST_PRINCIPLES','MEASURED_PERSON','AUTHORITATIVE_REFERENCE','PUBLISHED_MODEL','EXPLORATORY') NOT NULL,
    source_citation TEXT NULL,
    source_url VARCHAR(1024) NULL,
    source_version VARCHAR(64) NULL,
    formula_status ENUM('DRAFT','VERIFIED','APPROVED','DEPRECATED') NOT NULL DEFAULT 'DRAFT',
    unit_checked TINYINT(1) NOT NULL DEFAULT 0,
    dimensional_analysis_text TEXT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_ilmb_formula_key (formula_key),
    KEY ix_ilmb_formula_domain (formula_domain),
    CONSTRAINT fk_ilmb_formula_output_parameter FOREIGN KEY (output_parameter_id) REFERENCES ilmb_parameter_master(parameter_id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilmb_formula_input (
    formula_input_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    formula_id BIGINT UNSIGNED NOT NULL,
    symbol_name VARCHAR(64) NOT NULL,
    parameter_id BIGINT UNSIGNED NOT NULL,
    role ENUM('MEASURED','TARGET','CONSTANT','COEFFICIENT','DERIVED','CONTEXT') NOT NULL,
    required_flag TINYINT(1) NOT NULL DEFAULT 1,
    expected_ucum_unit VARCHAR(64) NULL,
    ordinal INT NOT NULL DEFAULT 1,
    notes TEXT NULL,
    UNIQUE KEY uq_ilmb_formula_symbol (formula_id, symbol_name),
    KEY ix_ilmb_formula_input_parameter (parameter_id),
    CONSTRAINT fk_ilmb_formula_input_formula FOREIGN KEY (formula_id) REFERENCES ilmb_formula_master(formula_id) ON DELETE CASCADE,
    CONSTRAINT fk_ilmb_formula_input_parameter FOREIGN KEY (parameter_id) REFERENCES ilmb_parameter_master(parameter_id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilmb_parameter_duplicate_candidate (
    duplicate_candidate_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    left_parameter_id BIGINT UNSIGNED NOT NULL,
    right_parameter_id BIGINT UNSIGNED NOT NULL,
    reason_code ENUM('SAME_IDENTIFIER','NORMALIZED_NAME_UNIT','SAME_SOURCE_KEY','FORMULA_EQUIVALENT','MANUAL') NOT NULL,
    confidence DECIMAL(6,5) NULL,
    evidence_json JSON NULL,
    disposition ENUM('OPEN','SAME','DISTINCT','MERGED','IGNORED') NOT NULL DEFAULT 'OPEN',
    reviewed_at DATETIME NULL,
    reviewed_by VARCHAR(191) NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_ilmb_duplicate_pair (left_parameter_id, right_parameter_id, reason_code),
    CONSTRAINT fk_ilmb_duplicate_left FOREIGN KEY (left_parameter_id) REFERENCES ilmb_parameter_master(parameter_id) ON DELETE CASCADE,
    CONSTRAINT fk_ilmb_duplicate_right FOREIGN KEY (right_parameter_id) REFERENCES ilmb_parameter_master(parameter_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilmb_body_need_run (
    body_need_run_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    subject_key VARCHAR(191) NOT NULL,
    formula_id BIGINT UNSIGNED NOT NULL,
    observation_cutoff_at DATETIME NULL,
    input_snapshot_json JSON NOT NULL,
    output_value DECIMAL(30,12) NULL,
    output_ucum_unit VARCHAR(64) NULL,
    execution_status ENUM('READY','BLOCKED_MISSING_INPUT','BLOCKED_UNVERIFIED_TARGET','BLOCKED_UNIT_MISMATCH','COMPUTED','ERROR') NOT NULL,
    blocking_reason TEXT NULL,
    provenance_json JSON NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    KEY ix_ilmb_body_need_subject (subject_key, created_at),
    CONSTRAINT fk_ilmb_body_need_formula FOREIGN KEY (formula_id) REFERENCES ilmb_formula_master(formula_id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE OR REPLACE VIEW vw_ilmb_common_parameter_master AS
SELECT p.parameter_id,p.parameter_key,p.canonical_name,p.parameter_domain,p.value_kind,p.canonical_ucum_unit,p.specimen_or_context,p.body_scope,
 MAX(CASE WHEN i.identifier_system='LOINC' AND i.verification_status='APPROVED' THEN i.identifier_code END) AS loinc_code,
 MAX(CASE WHEN i.identifier_system='CHEBI' AND i.verification_status='APPROVED' THEN i.identifier_code END) AS chebi_code,
 MAX(CASE WHEN i.identifier_system='UBERON' AND i.verification_status='APPROVED' THEN i.identifier_code END) AS uberon_code,
 MAX(CASE WHEN i.identifier_system='CL' AND i.verification_status='APPROVED' THEN i.identifier_code END) AS cl_code,
 MAX(CASE WHEN i.identifier_system='GO' AND i.verification_status='APPROVED' THEN i.identifier_code END) AS go_code,
 MAX(CASE WHEN i.identifier_system='HPO' AND i.verification_status='APPROVED' THEN i.identifier_code END) AS hpo_code,
 MAX(CASE WHEN i.identifier_system='REACTOME' AND i.verification_status='APPROVED' THEN i.identifier_code END) AS reactome_code
FROM ilmb_parameter_master p
LEFT JOIN ilmb_parameter_identifier i ON i.parameter_id=p.parameter_id
WHERE p.status <> 'DEPRECATED'
GROUP BY p.parameter_id;

INSERT IGNORE INTO ilmb_parameter_duplicate_candidate
(left_parameter_id,right_parameter_id,reason_code,confidence,evidence_json)
SELECT LEAST(a.parameter_id,b.parameter_id),GREATEST(a.parameter_id,b.parameter_id),'SAME_IDENTIFIER',1.00000,
 JSON_OBJECT('system',a.identifier_system,'code',a.identifier_code)
FROM ilmb_parameter_identifier a
JOIN ilmb_parameter_identifier b ON b.identifier_system=a.identifier_system AND b.identifier_code=a.identifier_code AND b.parameter_id>a.parameter_id
WHERE a.verification_status='APPROVED' AND b.verification_status='APPROVED';
