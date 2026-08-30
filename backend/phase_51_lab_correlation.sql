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
SELECT 'CHEBI','CHEMICAL',
       CASE WHEN UPPER(JSON_UNQUOTE(JSON_EXTRACT(c.payload_json,'$.chebi_id'))) LIKE 'CHEBI:%'
            THEN UPPER(JSON_UNQUOTE(JSON_EXTRACT(c.payload_json,'$.chebi_id')))
            ELSE CONCAT('CHEBI:',JSON_UNQUOTE(JSON_EXTRACT(c.payload_json,'$.chebi_id'))) END,
       'ChEBI canonical promoted bulk release',
       COALESCE((SELECT MAX(file_name) FROM ilmb_sync_batch WHERE system_id='REF-CHEBI' AND status='PROMOTED'),'promoted canonical release'),
       CONCAT('ilmb_canonical_record:',c.canonical_id),NOW(6),1
FROM ilmb_canonical_record c
WHERE c.system_id='REF-CHEBI' AND c.sheet_name='Entities' AND c.active=1
  AND JSON_UNQUOTE(JSON_EXTRACT(c.payload_json,'$.chebi_id')) IS NOT NULL
  AND JSON_UNQUOTE(JSON_EXTRACT(c.payload_json,'$.chebi_id'))<>''
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
                JSON_UNQUOTE(JSON_EXTRACT(ch.payload_json,'$.NAME'))) AS chebi_name,
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
