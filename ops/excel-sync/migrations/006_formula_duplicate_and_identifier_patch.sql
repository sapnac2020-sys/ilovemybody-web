CREATE TABLE IF NOT EXISTS ilmb_formula_duplicate_candidate (
 formula_duplicate_candidate_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 left_formula_id BIGINT UNSIGNED NOT NULL,
 right_formula_id BIGINT UNSIGNED NOT NULL,
 reason_code ENUM('NORMALIZED_EXPRESSION','SAME_OUTPUT_AND_INPUTS','SAME_SOURCE_KEY','MANUAL') NOT NULL,
 confidence DECIMAL(6,5) NULL,
 evidence_json JSON NULL,
 disposition ENUM('OPEN','SAME','DISTINCT','MERGED','IGNORED') NOT NULL DEFAULT 'OPEN',
 reviewed_at DATETIME NULL,
 reviewed_by VARCHAR(191) NULL,
 created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 UNIQUE KEY uq_ilmb_formula_duplicate_pair (left_formula_id,right_formula_id,reason_code),
 CONSTRAINT fk_ilmb_formula_duplicate_left FOREIGN KEY (left_formula_id) REFERENCES ilmb_formula_master(formula_id) ON DELETE CASCADE,
 CONSTRAINT fk_ilmb_formula_duplicate_right FOREIGN KEY (right_formula_id) REFERENCES ilmb_formula_master(formula_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

ALTER TABLE ilmb_body_need_run
  MODIFY execution_status ENUM('READY','BLOCKED_MISSING_INPUT','BLOCKED_UNVERIFIED_FORMULA','BLOCKED_UNVERIFIED_TARGET','BLOCKED_UNIT_MISMATCH','COMPUTED','ERROR') NOT NULL;

CREATE OR REPLACE VIEW vw_ilmb_common_parameter_master AS
SELECT p.parameter_id,p.parameter_key,p.canonical_name,p.parameter_domain,p.value_kind,p.canonical_ucum_unit,p.specimen_or_context,p.body_scope,
 MAX(CASE WHEN i.identifier_system='LOINC' AND i.verification_status='APPROVED' THEN i.identifier_code END) loinc_code,
 MAX(CASE WHEN i.identifier_system='CHEBI' AND i.verification_status='APPROVED' THEN i.identifier_code END) chebi_code,
 MAX(CASE WHEN i.identifier_system='UBERON' AND i.verification_status='APPROVED' THEN i.identifier_code END) uberon_code,
 MAX(CASE WHEN i.identifier_system='CL' AND i.verification_status='APPROVED' THEN i.identifier_code END) cl_code,
 MAX(CASE WHEN i.identifier_system='GO' AND i.verification_status='APPROVED' THEN i.identifier_code END) go_code,
 MAX(CASE WHEN i.identifier_system='HPO' AND i.verification_status='APPROVED' THEN i.identifier_code END) hpo_code,
 MAX(CASE WHEN i.identifier_system='REACTOME' AND i.verification_status='APPROVED' THEN i.identifier_code END) reactome_code,
 MAX(CASE WHEN i.identifier_system='RXNORM' AND i.verification_status='APPROVED' THEN i.identifier_code END) rxnorm_code,
 MAX(CASE WHEN i.identifier_system='SNOMED_CT' AND i.verification_status='APPROVED' THEN i.identifier_code END) snomed_ct_code,
 MAX(CASE WHEN i.identifier_system='UNIPROT' AND i.verification_status='APPROVED' THEN i.identifier_code END) uniprot_code,
 MAX(CASE WHEN i.identifier_system='HGNC' AND i.verification_status='APPROVED' THEN i.identifier_code END) hgnc_code
FROM ilmb_parameter_master p
LEFT JOIN ilmb_parameter_identifier i ON i.parameter_id=p.parameter_id
WHERE p.status<>'DEPRECATED'
GROUP BY p.parameter_id;
