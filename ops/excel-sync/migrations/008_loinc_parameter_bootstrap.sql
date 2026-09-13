-- Bootstrap canonical ILMB parameters from the existing approved Test Atlas -> LOINC crosswalk.
-- No name-based guessing is used. One canonical parameter is created per approved LOINC code.
-- Units remain NULL until an authoritative UCUM mapping is available; reported subject units stay on observations.

START TRANSACTION;

INSERT INTO ilmb_parameter_master (
  parameter_key,
  canonical_name,
  parameter_domain,
  value_kind,
  canonical_ucum_unit,
  specimen_or_context,
  body_scope,
  definition_text,
  source_system,
  source_record_key,
  status
)
SELECT
  CONCAT('loinc:', x.loinc_num),
  COALESCE(NULLIF(c.full_name,''), NULLIF(c.test_short_name,''), CONCAT('LOINC ',x.loinc_num)),
  'diagnostics',
  'numeric',
  NULL,
  NULLIF(x.specimen_text,''),
  NULL,
  NULLIF(c.what_it_measures,''),
  'LOINC',
  x.loinc_num,
  'ACTIVE'
FROM ilb_test_atlas_candidate c
JOIN ilb_test_atlas_loinc_crosswalk x
  ON x.candidate_id=c.candidate_id
 AND x.mapping_status='APPROVED'
WHERE c.validation_state='approved'
ON DUPLICATE KEY UPDATE
  canonical_name=VALUES(canonical_name),
  specimen_or_context=COALESCE(ilmb_parameter_master.specimen_or_context,VALUES(specimen_or_context)),
  definition_text=COALESCE(ilmb_parameter_master.definition_text,VALUES(definition_text)),
  status='ACTIVE',
  updated_at=CURRENT_TIMESTAMP;

INSERT INTO ilmb_parameter_identifier (
  parameter_id,
  identifier_system,
  identifier_code,
  identifier_label,
  mapping_type,
  verification_status,
  source_url,
  source_version,
  verified_at,
  verified_by
)
SELECT
  p.parameter_id,
  'LOINC',
  x.loinc_num,
  COALESCE(NULLIF(c.full_name,''),NULLIF(c.test_short_name,'')),
  'EXACT',
  'APPROVED',
  NULL,
  NULL,
  COALESCE(x.approved_at,x.mapped_at),
  'ILMB approved test-atlas crosswalk'
FROM ilb_test_atlas_candidate c
JOIN ilb_test_atlas_loinc_crosswalk x
  ON x.candidate_id=c.candidate_id
 AND x.mapping_status='APPROVED'
JOIN ilmb_parameter_master p
  ON p.parameter_key=CONCAT('loinc:',x.loinc_num)
WHERE c.validation_state='approved'
ON DUPLICATE KEY UPDATE
  identifier_label=VALUES(identifier_label),
  mapping_type='EXACT',
  verification_status='APPROVED',
  verified_at=VALUES(verified_at),
  verified_by=VALUES(verified_by);

CREATE OR REPLACE VIEW vw_ilmb_subject_parameter_observation AS
SELECT
  r.result_id,
  r.subject_key,
  r.observed_on,
  p.parameter_id,
  p.parameter_key,
  p.canonical_name,
  r.reported_numeric_value AS observed_value,
  r.reported_unit AS observed_unit,
  r.reported_specimen_text,
  r.laboratory_name,
  r.reported_reference_range_text,
  r.exact_loinc_num,
  r.source_document_id,
  'LOINC' AS identifier_system,
  r.exact_loinc_num AS identifier_code,
  1 AS verified_source
FROM v_ilb_subject_test_result_visible r
JOIN ilmb_parameter_identifier i
  ON i.identifier_system='LOINC'
 AND i.identifier_code=r.exact_loinc_num
 AND i.mapping_type='EXACT'
 AND i.verification_status='APPROVED'
JOIN ilmb_parameter_master p
  ON p.parameter_id=i.parameter_id
 AND p.status='ACTIVE'
WHERE r.identity_status='EXACT_MATCHED'
  AND r.reported_numeric_value IS NOT NULL;

COMMIT;
