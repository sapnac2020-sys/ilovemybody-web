-- Synthetic CI records only; never apply to production.
CREATE TABLE ilb_test_atlas_candidate(candidate_id BIGINT PRIMARY KEY,validation_state VARCHAR(20));
CREATE TABLE ilb_test_atlas_loinc_crosswalk(crosswalk_id BIGINT UNSIGNED PRIMARY KEY,candidate_id BIGINT,loinc_num VARCHAR(20),mapping_status VARCHAR(20),mapping_evidence TEXT,evidence_locator TEXT);
CREATE TABLE ilb_subject_test_result_ledger(result_id BIGINT UNSIGNED PRIMARY KEY,subject_key VARCHAR(128),observed_on DATE,reported_test_name VARCHAR(255),reported_value_text VARCHAR(255),reported_numeric_value DECIMAL(24,10),reported_unit VARCHAR(120),reported_specimen_text VARCHAR(255),reported_reference_range_text VARCHAR(255),laboratory_name VARCHAR(255),source_document_id BIGINT UNSIGNED,exact_loinc_num VARCHAR(20),exact_crosswalk_id BIGINT UNSIGNED,identity_status VARCHAR(30),entry_status VARCHAR(20));
CREATE VIEW v_ilb_subject_test_result_visible AS SELECT * FROM ilb_subject_test_result_ledger WHERE entry_status='ACTIVE';
CREATE TABLE ilb_participant_login(login_id VARCHAR(128),public_case_key VARCHAR(128),subject_key VARCHAR(128),must_change_pin INT,status VARCHAR(20));
CREATE TABLE ilb_subject_frontend_alias(public_case_key VARCHAR(128),frontend_label VARCHAR(128),allowed_age_display VARCHAR(128),allowed_sex_display VARCHAR(128),status VARCHAR(20));
INSERT INTO ilb_participant_login VALUES('test-login','test-case','test-subject',0,'active');
INSERT INTO ilb_subject_frontend_alias VALUES('test-case','Synthetic test participant','','','active');
INSERT INTO ilb_test_atlas_candidate VALUES(1,'approved');
INSERT INTO ilb_test_atlas_loinc_crosswalk VALUES(1,1,'TEST-CODE','APPROVED','Synthetic test mapping, not a real LOINC code','CI fixture');
INSERT INTO ilb_subject_test_result_ledger VALUES
(1,'test-subject','2026-01-01','Synthetic observation','positive',NULL,NULL,NULL,NULL,NULL,NULL,'TEST-CODE',1,'EXACT_MATCHED','ACTIVE'),
(2,'other-subject','2026-01-01','Synthetic other observation','4',4,NULL,NULL,NULL,NULL,NULL,'TEST-CODE',1,'EXACT_MATCHED','ACTIVE');
