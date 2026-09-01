-- Phase 67: objective readiness audit for the full Aatmn location-verification queue.
-- This classifies only what is written in the supplied source. It does not verify
-- an anatomical point or a claimed biological effect.
START TRANSACTION;

CREATE TABLE IF NOT EXISTS ilb_aatmn_location_verification_readiness (
  point_id bigint unsigned NOT NULL,
  source_location_text_present tinyint(1) NOT NULL DEFAULT 0,
  anatomy_candidate_count int unsigned NOT NULL DEFAULT 0,
  controlled_landmark_reference_status enum('NOT_LOADED','AVAILABLE') NOT NULL DEFAULT 'NOT_LOADED',
  spatial_reference_grade enum('NONE','TEXT_ONLY','RELATIVE_ANCHOR','METRIC_OR_COORDINATE') NOT NULL DEFAULT 'NONE',
  laterality_stated tinyint(1) NOT NULL DEFAULT 0,
  next_required_step enum('ADD_LOCATION_TEXT','MAP_CONTROLLED_LANDMARK','REVIEW_CANDIDATE','ADD_AUTHORITATIVE_SOURCE') NOT NULL,
  audited_at datetime(6) NOT NULL DEFAULT current_timestamp(6),
  PRIMARY KEY(point_id),
  CONSTRAINT fk_ilb_aatmn_location_readiness_point FOREIGN KEY(point_id)
    REFERENCES ilb_aatmn_parmar_point_source(point_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO ilb_aatmn_location_verification_readiness
(point_id,source_location_text_present,anatomy_candidate_count,controlled_landmark_reference_status,
 spatial_reference_grade,laterality_stated,next_required_step,audited_at)
SELECT p.point_id,
  CASE WHEN TRIM(COALESCE(p.stated_position_text,''))<>'' THEN 1 ELSE 0 END,
  COALESCE(c.candidate_count,0),
  CASE WHEN EXISTS(SELECT 1 FROM ilb_anatomical_landmark_master) THEN 'AVAILABLE' ELSE 'NOT_LOADED' END,
  CASE
    WHEN LOWER(COALESCE(p.stated_position_text,'')) REGEXP '(^|[^a-z0-9])([0-9]+|one|two|three|four|five)[[:space:]]*(mm|cm|inch|inches|finger|fingers)([^a-z0-9]|$)'
      THEN 'METRIC_OR_COORDINATE'
    WHEN LOWER(COALESCE(p.stated_position_text,'')) REGEXP '(above|below|behind|beside|between|away|near|under|over|from)'
      THEN 'RELATIVE_ANCHOR'
    WHEN TRIM(COALESCE(p.stated_position_text,''))<>'' THEN 'TEXT_ONLY'
    ELSE 'NONE'
  END,
  CASE WHEN LOWER(COALESCE(p.stated_position_text,'')) REGEXP '(^|[^a-z])(left|right|midline|centre|center)([^a-z]|$)' THEN 1 ELSE 0 END,
  CASE
    WHEN TRIM(COALESCE(p.stated_position_text,''))='' THEN 'ADD_LOCATION_TEXT'
    WHEN COALESCE(c.candidate_count,0)>0 THEN 'REVIEW_CANDIDATE'
    WHEN EXISTS(SELECT 1 FROM ilb_anatomical_landmark_master) THEN 'MAP_CONTROLLED_LANDMARK'
    ELSE 'ADD_AUTHORITATIVE_SOURCE'
  END,
  CURRENT_TIMESTAMP(6)
FROM ilb_aatmn_parmar_point_source p
LEFT JOIN (
  SELECT point_id,COUNT(*) AS candidate_count
  FROM ilb_aatmn_anatomy_candidate
  WHERE candidate_status='CANDIDATE'
  GROUP BY point_id
) c ON c.point_id=p.point_id
ON DUPLICATE KEY UPDATE
 source_location_text_present=VALUES(source_location_text_present),
 anatomy_candidate_count=VALUES(anatomy_candidate_count),
 controlled_landmark_reference_status=VALUES(controlled_landmark_reference_status),
 spatial_reference_grade=VALUES(spatial_reference_grade),
 laterality_stated=VALUES(laterality_stated),
 next_required_step=VALUES(next_required_step),
 audited_at=VALUES(audited_at);

CREATE OR REPLACE VIEW v_ilb_aatmn_location_verification_queue AS
SELECT p.point_id,p.point_code,p.point_name,p.stated_position_text,
       r.source_location_text_present,r.anatomy_candidate_count,
       r.controlled_landmark_reference_status,r.spatial_reference_grade,
       r.laterality_stated,r.next_required_step,
       v.anatomical_location_status,v.anatomical_identifier_system,v.anatomical_identifier
FROM ilb_aatmn_parmar_point_source p
JOIN ilb_aatmn_location_verification_readiness r ON r.point_id=p.point_id
JOIN ilb_aatmn_point_verification v ON v.point_id=p.point_id
ORDER BY p.point_code;

COMMIT;