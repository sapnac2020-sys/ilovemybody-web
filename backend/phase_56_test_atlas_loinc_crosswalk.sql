-- Phase 56: exact test-atlas to LOINC crosswalk storage.
-- No candidate is mapped or promoted by this migration.
START TRANSACTION;
CREATE TABLE IF NOT EXISTS ilb_test_atlas_loinc_crosswalk (
 crosswalk_id bigint unsigned NOT NULL AUTO_INCREMENT,
 candidate_id bigint NOT NULL,
 loinc_num varchar(20) NOT NULL,
 specimen_text varchar(120) NULL,
 mapping_evidence varchar(1200) NOT NULL,
 evidence_locator varchar(600) NOT NULL,
 mapping_status enum('PENDING','APPROVED','REJECTED') NOT NULL DEFAULT 'PENDING',
 mapped_at datetime(6) NOT NULL DEFAULT current_timestamp(6),
 approved_at datetime(6) NULL,
 PRIMARY KEY(crosswalk_id),
 UNIQUE KEY uq_ilb_test_atlas_loinc(candidate_id,loinc_num,specimen_text),
 KEY idx_ilb_test_atlas_loinc_status(mapping_status,loinc_num)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE OR REPLACE VIEW v_ilb_test_atlas_compute_ready AS
SELECT c.candidate_id,c.domain,c.area,c.test_short_name,c.full_name,c.what_it_measures,
       x.loinc_num,x.specimen_text,x.mapping_evidence,x.evidence_locator
FROM ilb_test_atlas_candidate c
JOIN ilb_test_atlas_loinc_crosswalk x ON x.candidate_id=c.candidate_id AND x.mapping_status='APPROVED'
WHERE c.validation_state='approved';
CREATE OR REPLACE VIEW v_ilb_test_atlas_mapping_queue AS
SELECT c.candidate_id,c.domain,c.area,c.test_short_name,c.full_name,c.what_it_measures,c.validation_state,
       COUNT(x.crosswalk_id) AS exact_loinc_links,
       SUM(x.mapping_status='APPROVED') AS approved_loinc_links
FROM ilb_test_atlas_candidate c
LEFT JOIN ilb_test_atlas_loinc_crosswalk x ON x.candidate_id=c.candidate_id
GROUP BY c.candidate_id,c.domain,c.area,c.test_short_name,c.full_name,c.what_it_measures,c.validation_state;
INSERT INTO ilb_backend_object_registry(object_name,object_type,domain_key,canonical_role,frontend_access,lifecycle_status,replacement_object_name,decision_note,release_key) VALUES
('ilb_test_atlas_loinc_crosswalk','table','diagnostics','Exact source-backed test-atlas to LOINC mapping store.','internal_only','canonical',NULL,'Candidate descriptions become computable only after an approved exact LOINC mapping.','ilb_backend_2026_07_24_complete'),
('v_ilb_test_atlas_compute_ready','view','diagnostics','Approved computable test-atlas read model.','read_contract','canonical',NULL,'Contains only approved candidate-to-LOINC links.','ilb_backend_2026_07_24_complete'),
('v_ilb_test_atlas_mapping_queue','view','diagnostics','Test-atlas mapping work queue.','internal_only','canonical',NULL,'Shows mapping coverage without creating mappings.','ilb_backend_2026_07_24_complete')
ON DUPLICATE KEY UPDATE object_type=VALUES(object_type),domain_key=VALUES(domain_key),canonical_role=VALUES(canonical_role),frontend_access=VALUES(frontend_access),lifecycle_status=VALUES(lifecycle_status),replacement_object_name=VALUES(replacement_object_name),decision_note=VALUES(decision_note),release_key=VALUES(release_key);
COMMIT;