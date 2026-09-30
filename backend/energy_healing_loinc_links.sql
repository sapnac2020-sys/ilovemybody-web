-- Apply after energy_healing_department.sql and existing phases 56/60.
-- Private research tables/views: never expose through public department API.
-- Reuses the existing test-result ledger and approved LOINC crosswalk.
CREATE TABLE IF NOT EXISTS ilb_ehr_session (
 session_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 session_key VARCHAR(120) NOT NULL UNIQUE,
 practice_code VARCHAR(64) NOT NULL,
 subject_key VARCHAR(128) NOT NULL,
 started_at DATETIME(6) NOT NULL,
 ended_at DATETIME(6) NULL,
 delivery_mode ENUM('PROXIMITY','TOUCH','DISTANCE','SELF_PRACTICE') NOT NULL,
 provider_key VARCHAR(128) NULL,
 protocol_code VARCHAR(120) NULL,
 status ENUM('PLANNED','COMPLETED','STOPPED','CANCELLED') NOT NULL DEFAULT 'PLANNED',
 created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
 FOREIGN KEY (practice_code) REFERENCES ilb_ehr_practice(practice_code),
 FOREIGN KEY (protocol_code) REFERENCES ilb_ehr_protocol(protocol_code),
 CHECK (ended_at IS NULL OR ended_at >= started_at),
 KEY idx_ehr_session_subject_time (subject_key,started_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_ehr_session_result_link (
 session_id BIGINT UNSIGNED NOT NULL,
 result_id BIGINT UNSIGNED NOT NULL,
 timing_role ENUM('BASELINE','PRE_SESSION','POST_SESSION','FOLLOW_UP') NOT NULL,
 linkage_reason TEXT NOT NULL,
 linked_by VARCHAR(255) NOT NULL,
 linked_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
 PRIMARY KEY (session_id,result_id),
 FOREIGN KEY (session_id) REFERENCES ilb_ehr_session(session_id),
 FOREIGN KEY (result_id) REFERENCES ilb_subject_test_result_ledger(result_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Inner joins prevent cross-subject links from appearing.
-- Recheck mapping approval at read time so revoked mappings are excluded.
-- Keep qualitative/text results: do not assume every LOINC observation is numeric.
CREATE OR REPLACE VIEW v_ilb_ehr_session_loinc_result AS
SELECT s.session_id,s.session_key,s.practice_code,s.subject_key,
 s.started_at,s.ended_at,s.delivery_mode,l.timing_role,
 r.result_id,r.observed_on,r.reported_test_name,r.reported_value_text,
 r.reported_numeric_value,r.reported_unit,r.reported_specimen_text,
 r.reported_reference_range_text,r.laboratory_name,r.source_document_id,
 r.exact_loinc_num,x.mapping_evidence,x.evidence_locator
FROM ilb_ehr_session s
JOIN ilb_ehr_session_result_link l ON l.session_id=s.session_id
JOIN ilb_subject_test_result_ledger r ON r.result_id=l.result_id
 AND CONVERT(r.subject_key USING utf8mb4) COLLATE utf8mb4_bin
   = CONVERT(s.subject_key USING utf8mb4) COLLATE utf8mb4_bin
 AND r.entry_status='ACTIVE' AND r.identity_status='EXACT_MATCHED'
JOIN ilb_test_atlas_loinc_crosswalk x ON x.crosswalk_id=r.exact_crosswalk_id
 AND x.mapping_status='APPROVED'
 AND CONVERT(x.loinc_num USING utf8mb4) COLLATE utf8mb4_bin
   = CONVERT(r.exact_loinc_num USING utf8mb4) COLLATE utf8mb4_bin
JOIN ilb_test_atlas_candidate c ON c.candidate_id=x.candidate_id
 AND c.validation_state='approved'
WHERE s.status='COMPLETED';

-- Integrity audit: must return no rows before using links.
-- Application writes must reject mismatched subjects; FK alone cannot do that.
SELECT l.session_id,l.result_id
FROM ilb_ehr_session_result_link l
JOIN ilb_ehr_session s ON s.session_id=l.session_id
JOIN ilb_subject_test_result_ledger r ON r.result_id=l.result_id
WHERE CONVERT(r.subject_key USING utf8mb4) COLLATE utf8mb4_bin
 <> CONVERT(s.subject_key USING utf8mb4) COLLATE utf8mb4_bin;
