-- Phase 60: subject-entered laboratory result ledger.
-- Keeps a report exactly as supplied; exact test identity is optional and only
-- accepted when an approved ILMB candidate-to-LOINC crosswalk exists.
START TRANSACTION;
CREATE TABLE IF NOT EXISTS ilb_subject_test_result_ledger (
  result_id bigint unsigned NOT NULL AUTO_INCREMENT,
  subject_key varchar(128) NOT NULL,
  source_document_id bigint unsigned NULL,
  observed_on date NOT NULL,
  reported_test_name varchar(500) NOT NULL,
  reported_value_text varchar(500) NOT NULL,
  reported_numeric_value decimal(24,10) NULL,
  reported_unit varchar(120) NULL,
  reported_specimen_text varchar(255) NULL,
  laboratory_name varchar(255) NULL,
  reported_reference_range_text varchar(500) NULL,
  exact_loinc_num varchar(20) NULL,
  exact_crosswalk_id bigint unsigned NULL,
  identity_status enum('UNLINKED','EXACT_MATCHED','NEEDS_REVIEW') NOT NULL DEFAULT 'UNLINKED',
  entry_status enum('ACTIVE','VOID') NOT NULL DEFAULT 'ACTIVE',
  created_at datetime(6) NOT NULL DEFAULT current_timestamp(6),
  updated_at datetime(6) NOT NULL DEFAULT current_timestamp(6) ON UPDATE current_timestamp(6),
  PRIMARY KEY(result_id),
  KEY idx_ilb_subject_result_ledger_subject_date(subject_key,observed_on),
  KEY idx_ilb_subject_result_ledger_loinc(exact_loinc_num),
  KEY idx_ilb_subject_result_ledger_document(source_document_id),
  CONSTRAINT fk_ilb_subject_result_crosswalk
    FOREIGN KEY(exact_crosswalk_id) REFERENCES ilb_test_atlas_loinc_crosswalk(crosswalk_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE OR REPLACE VIEW v_ilb_subject_test_result_visible AS
SELECT result_id,subject_key,source_document_id,observed_on,reported_test_name,
       reported_value_text,reported_numeric_value,reported_unit,reported_specimen_text,
       laboratory_name,reported_reference_range_text,exact_loinc_num,exact_crosswalk_id,
       identity_status,entry_status,created_at,updated_at
  FROM ilb_subject_test_result_ledger
 WHERE entry_status='ACTIVE';
COMMIT;