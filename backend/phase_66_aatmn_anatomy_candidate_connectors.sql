-- Phase 66: anatomy candidate connectors for the Aatmn point verification process.
-- A candidate is a literal source-text match only. It is not an anatomical verification
-- and it cannot be used as a clinical, causal, diagnostic, or treatment connector.
START TRANSACTION;

CREATE TABLE IF NOT EXISTS ilb_aatmn_anatomy_candidate (
  candidate_id bigint unsigned NOT NULL AUTO_INCREMENT,
  point_id bigint unsigned NOT NULL,
  anatomy_item_id bigint unsigned NULL,
  anatomy_code varchar(120) NOT NULL,
  anatomy_name varchar(500) NOT NULL,
  stated_position_snapshot text NOT NULL,
  match_method enum('LITERAL_NAME_IN_SOURCE_TEXT') NOT NULL,
  candidate_status enum('CANDIDATE','ACCEPTED','REJECTED','SUPERSEDED') NOT NULL DEFAULT 'CANDIDATE',
  reviewed_by varchar(255) NULL,
  reviewer_note text NULL,
  reviewed_at datetime(6) NULL,
  created_at datetime(6) NOT NULL DEFAULT current_timestamp(6),
  PRIMARY KEY(candidate_id),
  UNIQUE KEY uq_ilb_aatmn_candidate(point_id,anatomy_code,match_method),
  KEY idx_ilb_aatmn_candidate_status(candidate_status),
  CONSTRAINT fk_ilb_aatmn_candidate_point FOREIGN KEY(point_id)
    REFERENCES ilb_aatmn_parmar_point_source(point_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO ilb_aatmn_anatomy_candidate
(point_id,anatomy_item_id,anatomy_code,anatomy_name,stated_position_snapshot,match_method)
SELECT p.point_id,a.id,a.code,a.name,p.stated_position_text,'LITERAL_NAME_IN_SOURCE_TEXT'
FROM ilb_aatmn_parmar_point_source p
JOIN anatomy_items a ON CHAR_LENGTH(a.name)>=3
  AND LOCATE(LOWER(a.name),LOWER(p.stated_position_text))>0
WHERE a.status='active'
ON DUPLICATE KEY UPDATE
  anatomy_item_id=VALUES(anatomy_item_id),
  anatomy_name=VALUES(anatomy_name),
  stated_position_snapshot=VALUES(stated_position_snapshot);

CREATE OR REPLACE VIEW v_ilb_aatmn_anatomy_candidate_queue AS
SELECT p.point_id,p.point_code,p.point_name,p.stated_position_text,
       c.candidate_id,c.anatomy_code,c.anatomy_name,c.match_method,c.candidate_status,
       c.reviewer_note,c.reviewed_at
FROM ilb_aatmn_parmar_point_source p
LEFT JOIN ilb_aatmn_anatomy_candidate c ON c.point_id=p.point_id
ORDER BY p.point_code,c.anatomy_name;

COMMIT;