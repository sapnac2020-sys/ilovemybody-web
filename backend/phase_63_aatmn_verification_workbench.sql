-- Phase 63: separate verification outcomes for the Aatmn Parmar source points.
-- No status is promoted automatically. Anatomy, source-rule consistency and
-- claimed outcome evidence are independent checks.
START TRANSACTION;
CREATE TABLE IF NOT EXISTS ilb_aatmn_point_verification (
  point_id bigint unsigned NOT NULL,
  anatomical_location_status enum('PENDING','IDENTIFIABLE','AMBIGUOUS','NOT_ANATOMICAL','NOT_FOUND') NOT NULL DEFAULT 'PENDING',
  anatomical_identifier_system varchar(80) NULL,
  anatomical_identifier varchar(255) NULL,
  anatomical_evidence_locator varchar(1200) NULL,
  pairing_rule_status enum('PENDING','CONSISTENT','INCONSISTENT','NOT_DEFINED') NOT NULL DEFAULT 'PENDING',
  pairing_evidence_locator varchar(1200) NULL,
  claimed_effect_status enum('PENDING','NO_TESTABLE_CLAIM','UNVERIFIED','SUPPORTED','CONTRADICTED') NOT NULL DEFAULT 'PENDING',
  claimed_effect_evidence_locator varchar(1200) NULL,
  reviewer_note text NULL,
  reviewed_at datetime(6) NULL,
  PRIMARY KEY(point_id),
  CONSTRAINT fk_ilb_aatmn_verification_point FOREIGN KEY(point_id)
    REFERENCES ilb_aatmn_parmar_point_source(point_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO ilb_aatmn_point_verification(point_id)
SELECT point_id FROM ilb_aatmn_parmar_point_source
ON DUPLICATE KEY UPDATE point_id=VALUES(point_id);
CREATE OR REPLACE VIEW v_ilb_aatmn_verification_queue AS
SELECT p.point_id,p.point_code,p.point_name,p.stated_position_text,p.stated_foundation_keyword,
       v.anatomical_location_status,v.anatomical_identifier_system,v.anatomical_identifier,
       v.pairing_rule_status,v.claimed_effect_status,v.reviewer_note
FROM ilb_aatmn_parmar_point_source p
JOIN ilb_aatmn_point_verification v ON v.point_id=p.point_id
ORDER BY p.point_code;
COMMIT;