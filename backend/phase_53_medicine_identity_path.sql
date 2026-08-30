-- Phase 53: governed non-patient medicine identity and mechanism path.
-- No name-based NLEM-to-RxNorm/ChEBI inference. Draft clinical examples are excluded.
START TRANSACTION;

INSERT INTO ilmb_crosswalk_endpoint
(system_id,entity_type,external_id,source_name,source_version,source_locator,verified_at,active)
SELECT 'NLEM','MEDICINE',c.source_key,'NLEM medicine identity','NLEM 2022',
       CONCAT('ilmb_canonical_record:',c.canonical_id),NOW(6),1
FROM ilmb_canonical_record c
WHERE c.system_id='SYS-018' AND c.sheet_name='Medicine_Master' AND c.active=1
ON DUPLICATE KEY UPDATE source_name=VALUES(source_name),source_version=VALUES(source_version),
 source_locator=VALUES(source_locator),verified_at=VALUES(verified_at),active=1;

INSERT INTO ilmb_crosswalk_endpoint
(system_id,entity_type,external_id,source_name,source_version,source_locator,verified_at,active)
SELECT 'ILMB','DRUG',d.drug_key,d.generic_name,'live ilb_drug',
       CONCAT('ilb_drug:',d.drug_id),NOW(6),1
FROM ilb_drug d WHERE d.status='active'
ON DUPLICATE KEY UPDATE source_name=VALUES(source_name),source_version=VALUES(source_version),
 source_locator=VALUES(source_locator),verified_at=VALUES(verified_at),active=1;

INSERT INTO ilmb_crosswalk_endpoint
(system_id,entity_type,external_id,source_name,source_version,source_locator,verified_at,active)
SELECT 'RXNORM','INGREDIENT',i.external_code,i.external_label,'RxNorm identifier registry',
       i.canonical_url,NOW(6),1
FROM ilb_drug_identifier i JOIN ilb_drug d ON d.drug_id=i.drug_id AND d.status='active'
WHERE i.status='active' AND i.external_code<>'' AND i.canonical_url LIKE '%RXCUI%'
ON DUPLICATE KEY UPDATE source_name=VALUES(source_name),source_version=VALUES(source_version),
 source_locator=VALUES(source_locator),verified_at=VALUES(verified_at),active=1;

INSERT INTO ilmb_crosswalk_endpoint
(system_id,entity_type,external_id,source_name,source_version,source_locator,verified_at,active)
SELECT 'ILMB','MECHANISM',m.drug_key,CONCAT(m.generic_name,' mechanism'),'live ilb_medicine_mechanism',
       CONCAT('ilb_medicine_mechanism:',m.drug_key),NOW(6),1
FROM ilb_medicine_mechanism m JOIN ilb_drug d ON d.drug_key=m.drug_key AND d.status='active'
ON DUPLICATE KEY UPDATE source_name=VALUES(source_name),source_version=VALUES(source_version),
 source_locator=VALUES(source_locator),verified_at=VALUES(verified_at),active=1;

INSERT INTO ilmb_entity_crosswalk
(mapping_id,source_system,source_entity_type,source_id,predicate,target_system,target_entity_type,target_id,
 match_type,status,evidence_source,evidence_version,evidence_locator,confidence,
 source_endpoint_resolved,target_endpoint_resolved,computation_eligible,source_batch_id,row_hash,effective_at,retired_at)
SELECT SHA2(CONCAT_WS('|','ILMB','DRUG',d.drug_key,'HAS_RXNORM_ID','RXNORM','INGREDIENT',i.external_code),256),
 'ILMB','DRUG',d.drug_key,'HAS_RXNORM_ID','RXNORM','INGREDIENT',i.external_code,
 'EXACT','APPROVED','Existing governed drug identifier','live ilb_drug_identifier',i.canonical_url,1.00000,
 1,1,1,NULL,SHA2(CONCAT_WS('|',d.drug_id,i.external_code,i.external_label,i.canonical_url),256),NOW(6),NULL
FROM ilb_drug d JOIN ilb_drug_identifier i ON i.drug_id=d.drug_id
WHERE d.status='active' AND i.status='active' AND i.external_code<>'' AND i.canonical_url LIKE '%RXCUI%'
ON DUPLICATE KEY UPDATE evidence_source=VALUES(evidence_source),evidence_version=VALUES(evidence_version),
 evidence_locator=VALUES(evidence_locator),confidence=1.00000,source_endpoint_resolved=1,
 target_endpoint_resolved=1,computation_eligible=1,row_hash=VALUES(row_hash),effective_at=VALUES(effective_at),retired_at=NULL;

INSERT INTO ilmb_entity_crosswalk
(mapping_id,source_system,source_entity_type,source_id,predicate,target_system,target_entity_type,target_id,
 match_type,status,evidence_source,evidence_version,evidence_locator,confidence,
 source_endpoint_resolved,target_endpoint_resolved,computation_eligible,source_batch_id,row_hash,effective_at,retired_at)
SELECT SHA2(CONCAT_WS('|','ILMB','DRUG',d.drug_key,'HAS_MECHANISM','ILMB','MECHANISM',m.drug_key),256),
 'ILMB','DRUG',d.drug_key,'HAS_MECHANISM','ILMB','MECHANISM',m.drug_key,
 'EXACT','APPROVED','Existing mechanism record keyed to canonical ILMB drug','live ilb_medicine_mechanism',
 CONCAT('ilb_medicine_mechanism:',m.drug_key),1.00000,1,1,0,NULL,
 SHA2(CONCAT_WS('|',m.drug_key,m.generic_name,m.what_it_does_in_the_body,m.warrant),256),NOW(6),NULL
FROM ilb_drug d JOIN ilb_medicine_mechanism m ON m.drug_key=d.drug_key
WHERE d.status='active'
ON DUPLICATE KEY UPDATE evidence_source=VALUES(evidence_source),evidence_version=VALUES(evidence_version),
 evidence_locator=VALUES(evidence_locator),confidence=1.00000,source_endpoint_resolved=1,
 target_endpoint_resolved=1,computation_eligible=0,row_hash=VALUES(row_hash),effective_at=VALUES(effective_at),retired_at=NULL;

CREATE OR REPLACE VIEW v_ilmb_medicine_identity_proof AS
SELECT d.drug_key,d.generic_name,d.drug_class,d.description,
 i.external_code rxnorm_id,i.external_label rxnorm_label,i.canonical_url rxnorm_url,
 m.what_it_does_in_the_body mechanism_description,m.warrant mechanism_warrant,
 CASE WHEN i.external_code IS NULL THEN 'blocked_missing_authoritative_identifier' ELSE 'exact_approved' END rxnorm_status
FROM ilb_drug d
LEFT JOIN ilb_drug_identifier i ON i.drug_id=d.drug_id AND i.status='active' AND i.canonical_url LIKE '%RXCUI%'
LEFT JOIN ilb_medicine_mechanism m ON m.drug_key=d.drug_key
WHERE d.status='active';

COMMIT;
