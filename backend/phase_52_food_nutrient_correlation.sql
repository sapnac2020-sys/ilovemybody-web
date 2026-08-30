-- Phase 52: governed IFCT food -> nutrient composition path.
-- Uses only promoted canonical IFCT identifiers and values. No name-based mapping.
-- Reads or changes no patient-authored rows.

START TRANSACTION;

CREATE TABLE IF NOT EXISTS ilb_food_nutrient_composition (
 food_system varchar(32) NOT NULL,
 food_id varchar(180) NOT NULL,
 nutrient_system varchar(32) NOT NULL,
 nutrient_id varchar(180) NOT NULL,
 amount decimal(30,12) NOT NULL,
 amount_unit varchar(40) NOT NULL,
 basis_quantity decimal(20,8) NOT NULL,
 basis_unit varchar(40) NOT NULL,
 correction_rule varchar(500) NULL,
 source_record_key varchar(512) NOT NULL,
 source_batch_id char(36) NOT NULL,
 row_hash char(64) NOT NULL,
 active tinyint(1) NOT NULL DEFAULT 1,
 effective_at datetime(6) NOT NULL,
 PRIMARY KEY(food_system,food_id,nutrient_system,nutrient_id),
 KEY idx_food_nutrient_target(nutrient_system,nutrient_id),
 KEY idx_food_nutrient_positive(amount)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO ilmb_crosswalk_endpoint
(system_id,entity_type,external_id,source_name,source_version,source_locator,verified_at,active)
SELECT 'IFCT','FOOD',c.source_key,'IFCT promoted canonical food identity',
       COALESCE((SELECT MAX(file_name) FROM ilmb_sync_batch WHERE system_id='SYS-003' AND status='PROMOTED'),'promoted canonical release'),
       CONCAT('ilmb_canonical_record:',c.canonical_id),NOW(6),1
FROM ilmb_canonical_record c
WHERE c.system_id='SYS-003' AND c.sheet_name='10_IFCT_FOODS' AND c.active=1
ON DUPLICATE KEY UPDATE source_name=VALUES(source_name),source_version=VALUES(source_version),
 source_locator=VALUES(source_locator),verified_at=VALUES(verified_at),active=1;

INSERT INTO ilmb_crosswalk_endpoint
(system_id,entity_type,external_id,source_name,source_version,source_locator,verified_at,active)
SELECT 'IFCT','NUTRIENT',c.source_key,'IFCT promoted canonical component identity',
       COALESCE((SELECT MAX(file_name) FROM ilmb_sync_batch WHERE system_id='SYS-003' AND status='PROMOTED'),'promoted canonical release'),
       CONCAT('ilmb_canonical_record:',c.canonical_id),NOW(6),1
FROM ilmb_canonical_record c
WHERE c.system_id='SYS-003' AND c.sheet_name='11_IFCT_COMPONENTS' AND c.active=1
ON DUPLICATE KEY UPDATE source_name=VALUES(source_name),source_version=VALUES(source_version),
 source_locator=VALUES(source_locator),verified_at=VALUES(verified_at),active=1;

INSERT INTO ilb_food_nutrient_composition
(food_system,food_id,nutrient_system,nutrient_id,amount,amount_unit,basis_quantity,basis_unit,
 correction_rule,source_record_key,source_batch_id,row_hash,active,effective_at)
SELECT 'IFCT',
       JSON_UNQUOTE(JSON_EXTRACT(c.payload_json,'$.ingredient_key')),
       'IFCT',
       JSON_UNQUOTE(JSON_EXTRACT(c.payload_json,'$.component_key')),
       CAST(JSON_UNQUOTE(JSON_EXTRACT(c.payload_json,'$.corrected_value_amount')) AS DECIMAL(30,12)),
       JSON_UNQUOTE(JSON_EXTRACT(c.payload_json,'$.value_unit')),
       CAST(JSON_UNQUOTE(JSON_EXTRACT(c.payload_json,'$.basis_quantity')) AS DECIMAL(20,8)),
       JSON_UNQUOTE(JSON_EXTRACT(c.payload_json,'$.basis_unit')),
       JSON_UNQUOTE(JSON_EXTRACT(c.payload_json,'$.correction_rule')),
       c.source_key,c.source_batch_id,c.row_hash,1,NOW(6)
FROM ilmb_canonical_record c
WHERE c.system_id='SYS-003' AND c.sheet_name='12_IFCT_VALUES' AND c.active=1
  AND JSON_UNQUOTE(JSON_EXTRACT(c.payload_json,'$.ingredient_key')) IS NOT NULL
  AND JSON_UNQUOTE(JSON_EXTRACT(c.payload_json,'$.component_key')) IS NOT NULL
  AND JSON_UNQUOTE(JSON_EXTRACT(c.payload_json,'$.corrected_value_amount')) IS NOT NULL
ON DUPLICATE KEY UPDATE amount=VALUES(amount),amount_unit=VALUES(amount_unit),
 basis_quantity=VALUES(basis_quantity),basis_unit=VALUES(basis_unit),
 correction_rule=VALUES(correction_rule),source_record_key=VALUES(source_record_key),
 source_batch_id=VALUES(source_batch_id),row_hash=VALUES(row_hash),active=1,effective_at=VALUES(effective_at);

INSERT INTO ilmb_entity_crosswalk
(mapping_id,source_system,source_entity_type,source_id,predicate,target_system,target_entity_type,target_id,
 match_type,status,evidence_source,evidence_version,evidence_locator,confidence,
 source_endpoint_resolved,target_endpoint_resolved,computation_eligible,source_batch_id,row_hash,effective_at,retired_at)
SELECT SHA2(CONCAT_WS('|','IFCT','FOOD',c.food_id,'CONTAINS','IFCT','NUTRIENT',c.nutrient_id),256),
       'IFCT','FOOD',c.food_id,'CONTAINS','IFCT','NUTRIENT',c.nutrient_id,
       'EXACT','APPROVED','Promoted IFCT composition value',
       COALESCE((SELECT MAX(file_name) FROM ilmb_sync_batch WHERE system_id='SYS-003' AND status='PROMOTED'),'promoted canonical release'),
       c.source_record_key,1.00000,1,1,1,c.source_batch_id,c.row_hash,NOW(6),NULL
FROM ilb_food_nutrient_composition c
WHERE c.active=1 AND c.amount>0
ON DUPLICATE KEY UPDATE evidence_source=VALUES(evidence_source),evidence_version=VALUES(evidence_version),
 evidence_locator=VALUES(evidence_locator),confidence=VALUES(confidence),
 source_endpoint_resolved=1,target_endpoint_resolved=1,computation_eligible=1,
 source_batch_id=VALUES(source_batch_id),row_hash=VALUES(row_hash),effective_at=VALUES(effective_at),retired_at=NULL;

CREATE OR REPLACE VIEW v_ilmb_food_nutrient_compute AS
SELECT c.food_id,
       JSON_UNQUOTE(JSON_EXTRACT(f.payload_json,'$.primary_name')) food_name,
       c.nutrient_id,
       JSON_UNQUOTE(JSON_EXTRACT(n.payload_json,'$.component_name')) nutrient_name,
       c.amount,c.amount_unit,c.basis_quantity,c.basis_unit,c.correction_rule,
       x.mapping_id,x.match_type,x.status,x.computation_eligible,
       c.source_record_key,c.source_batch_id,c.row_hash
FROM ilb_food_nutrient_composition c
JOIN ilmb_entity_crosswalk x
 ON x.source_system='IFCT' AND x.source_entity_type='FOOD' AND x.source_id=c.food_id
 AND x.predicate='CONTAINS' AND x.target_system='IFCT' AND x.target_entity_type='NUTRIENT'
 AND x.target_id=c.nutrient_id AND x.match_type='EXACT' AND x.status='APPROVED'
 AND x.computation_eligible=1
JOIN ilmb_canonical_record f
 ON f.system_id='SYS-003' AND f.sheet_name='10_IFCT_FOODS' AND f.source_key=c.food_id AND f.active=1
JOIN ilmb_canonical_record n
 ON n.system_id='SYS-003' AND n.sheet_name='11_IFCT_COMPONENTS' AND n.source_key=c.nutrient_id AND n.active=1
WHERE c.active=1 AND c.amount>0;

COMMIT;
