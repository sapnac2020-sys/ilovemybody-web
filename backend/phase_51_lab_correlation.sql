-- Phase 51: first governed LOINC -> ChEBI computation path.
-- Safe to rerun. Registers authoritative endpoints from promoted canonical
-- records only. Reads or changes no patient-authored rows.

START TRANSACTION;

INSERT INTO ilmb_crosswalk_endpoint
(system_id,entity_type,external_id,source_name,source_version,source_locator,verified_at,active)
SELECT 'LOINC','TEST',
       JSON_UNQUOTE(JSON_EXTRACT(c.payload_json,'$.LOINC_NUM')),
       'LOINC canonical promoted workbook',
       COALESCE((SELECT MAX(file_name) FROM ilmb_sync_batch WHERE system_id='SYS-001' AND status='PROMOTED'),'promoted canonical release'),
       CONCAT('ilmb_canonical_record:',c.canonical_id),NOW(6),1
FROM ilmb_canonical_record c
WHERE c.system_id='SYS-001' AND c.sheet_name='LOINC_Master' AND c.active=1
  AND JSON_UNQUOTE(JSON_EXTRACT(c.payload_json,'$.LOINC_NUM')) IS NOT NULL
  AND JSON_UNQUOTE(JSON_EXTRACT(c.payload_json,'$.LOINC_NUM'))<>''
ON DUPLICATE KEY UPDATE source_name=VALUES(source_name),source_version=VALUES(source_version),
 source_locator=VALUES(source_locator),verified_at=VALUES(verified_at),active=1;

INSERT INTO ilmb_crosswalk_endpoint
(system_id,entity_type,external_id,source_name,source_version,source_locator,verified_at,active)
SELECT 'CHEBI','CHEMICAL',ids.external_id,
       'ChEBI canonical promoted bulk release',
       COALESCE((SELECT MAX(file_name) FROM ilmb_sync_batch WHERE system_id='REF-CHEBI' AND status='PROMOTED'),'promoted canonical release'),
       CONCAT('ilmb_canonical_record:',ids.canonical_id),NOW(6),1
FROM (
 SELECT canonical_id,
        COALESCE(JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$.chebi_id')),
                 JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$.CHEBI_ID'))) AS external_id
 FROM ilmb_canonical_record
 WHERE system_id='REF-CHEBI' AND sheet_name='Entities' AND active=1
) ids
WHERE ids.external_id IS NOT NULL AND ids.external_id<>''
ON DUPLICATE KEY UPDATE source_name=VALUES(source_name),source_version=VALUES(source_version),
 source_locator=VALUES(source_locator),verified_at=VALUES(verified_at),active=1;

INSERT INTO ilmb_crosswalk_endpoint
(system_id,entity_type,external_id,source_name,source_version,source_locator,verified_at,active)
SELECT 'CHEBI','CHEMICAL',
       CASE WHEN UPPER(ids.external_id) LIKE 'CHEBI:%'
            THEN SUBSTRING_INDEX(ids.external_id,':',-1)
            ELSE CONCAT('CHEBI:',ids.external_id) END,
       'ChEBI canonical promoted bulk release',
       COALESCE((SELECT MAX(file_name) FROM ilmb_sync_batch WHERE system_id='REF-CHEBI' AND status='PROMOTED'),'promoted canonical release'),
       CONCAT('ilmb_canonical_record:',ids.canonical_id),NOW(6),1
FROM (
 SELECT canonical_id,
        COALESCE(JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$.chebi_id')),
                 JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$.CHEBI_ID'))) AS external_id
 FROM ilmb_canonical_record
 WHERE system_id='REF-CHEBI' AND sheet_name='Entities' AND active=1
) ids
WHERE ids.external_id IS NOT NULL AND ids.external_id<>''
ON DUPLICATE KEY UPDATE source_name=VALUES(source_name),source_version=VALUES(source_version),
 source_locator=VALUES(source_locator),verified_at=VALUES(verified_at),active=1;

UPDATE ilmb_entity_crosswalk x
SET source_endpoint_resolved=EXISTS(
      SELECT 1 FROM ilmb_crosswalk_endpoint e
      WHERE e.system_id=x.source_system AND e.entity_type=x.source_entity_type
        AND e.external_id=x.source_id AND e.active=1),
    target_endpoint_resolved=EXISTS(
      SELECT 1 FROM ilmb_crosswalk_endpoint e
      WHERE e.system_id=x.target_system AND e.entity_type=x.target_entity_type
        AND e.external_id=x.target_id AND e.active=1)
WHERE x.source_system='LOINC' AND x.target_system='CHEBI' AND x.predicate='MEASURES';

UPDATE ilmb_entity_crosswalk
SET computation_eligible=(
  match_type='EXACT' AND status='APPROVED'
  AND source_endpoint_resolved=1 AND target_endpoint_resolved=1
)
WHERE source_system='LOINC' AND target_system='CHEBI' AND predicate='MEASURES';

CREATE TABLE IF NOT EXISTS ilb_lab_correlation_rule (
 rule_key varchar(100) NOT NULL,
 version_label varchar(40) NOT NULL,
 rule_name varchar(200) NOT NULL,
 expression_text varchar(1000) NOT NULL,
 input_contract varchar(1500) NOT NULL,
 output_contract varchar(1000) NOT NULL,
 source_boundary varchar(1800) NOT NULL,
 status enum('draft','review','active','retired') NOT NULL DEFAULT 'review',
 created_at timestamp NOT NULL DEFAULT current_timestamp(),
 updated_at timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
 PRIMARY KEY(rule_key,version_label)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO ilb_lab_correlation_rule
(rule_key,version_label,rule_name,expression_text,input_contract,output_contract,source_boundary,status)
VALUES
('lab_reference_position','1.0','Position relative to a supplied laboratory interval',
 'below when value < low; within when low <= value <= high; above when value > high',
 'Numeric result, numeric low and high boundaries, and exactly matching case-sensitive UCUM unit codes. Low must not exceed high.',
 'below | within | above | blocked',
 'The comparison describes position against the explicitly supplied interval only. It is not a diagnosis, universal reference range, treatment recommendation, or reason to change medicine.','active')
ON DUPLICATE KEY UPDATE rule_name=VALUES(rule_name),expression_text=VALUES(expression_text),
 input_contract=VALUES(input_contract),output_contract=VALUES(output_contract),
 source_boundary=VALUES(source_boundary),status=VALUES(status);

CREATE TABLE IF NOT EXISTS ilb_lab_measurement_contract (
 loinc_num varchar(20) NOT NULL,
 canonical_specimen varchar(120) NULL,
 property_code varchar(40) NULL,
 scale_type varchar(40) NULL,
 example_ucum_unit varchar(120) NULL,
 unit_semantics varchar(500) NOT NULL,
 interval_semantics varchar(700) NOT NULL,
 source_system varchar(32) NOT NULL,
 source_locator varchar(600) NOT NULL,
 source_batch_id char(36) NOT NULL,
 active tinyint(1) NOT NULL DEFAULT 1,
 verified_at datetime(6) NOT NULL,
 PRIMARY KEY(loinc_num),
 KEY idx_lab_contract_specimen(canonical_specimen),
 KEY idx_lab_contract_unit(example_ucum_unit)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO ilb_lab_measurement_contract
(loinc_num,canonical_specimen,property_code,scale_type,example_ucum_unit,unit_semantics,
 interval_semantics,source_system,source_locator,source_batch_id,active,verified_at)
SELECT c.source_key,
       NULLIF(JSON_UNQUOTE(JSON_EXTRACT(c.payload_json,'$.SYSTEM')),''),
       NULLIF(JSON_UNQUOTE(JSON_EXTRACT(c.payload_json,'$.PROPERTY')),''),
       NULLIF(JSON_UNQUOTE(JSON_EXTRACT(c.payload_json,'$.SCALE_TYP')),''),
       NULLIF(JSON_UNQUOTE(JSON_EXTRACT(c.payload_json,'$.EXAMPLE_UCUM_UNITS')),''),
       'LOINC EXAMPLE_UCUM_UNITS is descriptive example metadata. It is not treated as the only valid unit and is never used for implicit conversion.',
       'Reference boundaries must come from the reporting laboratory or another explicitly governed population/method-specific source; no universal interval is inferred from LOINC.',
       'LOINC',
       CONCAT('ilmb_canonical_record:',c.canonical_id),
       c.source_batch_id,1,NOW(6)
FROM ilmb_canonical_record c
WHERE c.system_id='SYS-001' AND c.sheet_name='LOINC_Master' AND c.active=1
  AND c.source_key<>''
ON DUPLICATE KEY UPDATE canonical_specimen=VALUES(canonical_specimen),
 property_code=VALUES(property_code),scale_type=VALUES(scale_type),
 example_ucum_unit=VALUES(example_ucum_unit),unit_semantics=VALUES(unit_semantics),
 interval_semantics=VALUES(interval_semantics),source_locator=VALUES(source_locator),
 source_batch_id=VALUES(source_batch_id),active=1,verified_at=VALUES(verified_at);

UPDATE ilb_lab_correlation_rule
SET status='retired'
WHERE rule_key='lab_reference_position' AND version_label='1.0';

INSERT INTO ilb_lab_correlation_rule
(rule_key,version_label,rule_name,expression_text,input_contract,output_contract,source_boundary,status)
VALUES
('lab_reference_position','1.1','Specimen- and unit-gated position against a supplied laboratory interval',
 'block unless specimen equals the canonical LOINC specimen code and result unit equals reference unit exactly; otherwise below when value < low, within when low <= value <= high, above when value > high',
 'LOINC code with its canonical specimen code, numeric result, numeric low and high boundaries, and exactly matching case-sensitive result/reference unit codes. Low must not exceed high.',
 'below | within | above | blocked, with explicit specimen and unit gate results',
 'LOINC provides measurement identity and specimen metadata. EXAMPLE_UCUM_UNITS remains example metadata only. The interval must be explicitly supplied from a laboratory or other governed source. No universal interval, implicit unit conversion, diagnosis, or treatment inference is permitted.','active')
ON DUPLICATE KEY UPDATE rule_name=VALUES(rule_name),expression_text=VALUES(expression_text),
 input_contract=VALUES(input_contract),output_contract=VALUES(output_contract),
 source_boundary=VALUES(source_boundary),status=VALUES(status);

DROP VIEW IF EXISTS v_ilmb_loinc_chebi_compute;
CREATE VIEW v_ilmb_loinc_chebi_compute AS
SELECT x.mapping_id,x.source_id AS loinc_num,x.predicate,
       JSON_UNQUOTE(JSON_EXTRACT(l.payload_json,'$.LONG_COMMON_NAME')) AS loinc_name,
       JSON_UNQUOTE(JSON_EXTRACT(l.payload_json,'$.COMPONENT')) AS loinc_component,
       JSON_UNQUOTE(JSON_EXTRACT(l.payload_json,'$.PROPERTY')) AS loinc_property,
       JSON_UNQUOTE(JSON_EXTRACT(l.payload_json,'$.TIME_ASPCT')) AS loinc_time_aspect,
       JSON_UNQUOTE(JSON_EXTRACT(l.payload_json,'$.SYSTEM')) AS loinc_specimen_system,
       JSON_UNQUOTE(JSON_EXTRACT(l.payload_json,'$.SCALE_TYP')) AS loinc_scale_type,
       x.target_id AS chebi_id,
       COALESCE(JSON_UNQUOTE(JSON_EXTRACT(ch.payload_json,'$.name')),
                JSON_UNQUOTE(JSON_EXTRACT(ch.payload_json,'$.compound_name')),
                JSON_UNQUOTE(JSON_EXTRACT(ch.payload_json,'$.NAME')),
                JSON_UNQUOTE(JSON_EXTRACT(ch.payload_json,'$.COMPOUND_NAME'))) AS chebi_name,
       x.evidence_source,x.evidence_version,x.evidence_locator,x.confidence,
       x.match_type,x.status,x.computation_eligible,
       se.source_version AS loinc_release,te.source_version AS chebi_release
FROM ilmb_entity_crosswalk x
JOIN ilmb_crosswalk_endpoint se
 ON se.system_id=x.source_system AND se.entity_type=x.source_entity_type
 AND se.external_id=x.source_id AND se.active=1
JOIN ilmb_crosswalk_endpoint te
 ON te.system_id=x.target_system AND te.entity_type=x.target_entity_type
 AND te.external_id=x.target_id AND te.active=1
JOIN ilmb_canonical_record l
 ON l.system_id='SYS-001' AND l.sheet_name='LOINC_Master' AND l.active=1
 AND l.source_key=x.source_id
LEFT JOIN ilmb_canonical_record ch
 ON ch.system_id='REF-CHEBI' AND ch.sheet_name='Entities' AND ch.active=1
 AND ch.source_key IN (x.target_id,REPLACE(x.target_id,'CHEBI:',''))
WHERE x.source_system='LOINC' AND x.source_entity_type='TEST'
 AND x.predicate='MEASURES' AND x.target_system='CHEBI'
 AND x.target_entity_type='CHEMICAL' AND x.match_type='EXACT'
 AND x.status='APPROVED' AND x.computation_eligible=1;

COMMIT;
