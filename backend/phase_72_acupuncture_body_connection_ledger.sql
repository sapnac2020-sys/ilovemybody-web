-- Phase 72: acupuncture as a sourced body-connection reference layer.
-- This is not an acupuncture treatment catalogue. It records point-to-body relationships
-- with their source, type, and verification state so they can join the ILMB body model.

START TRANSACTION;

CREATE TABLE IF NOT EXISTS ilb_acupuncture_body_connection (
  connection_id bigint unsigned NOT NULL AUTO_INCREMENT,
  acupuncture_point_id bigint unsigned NOT NULL,
  target_system varchar(64) NOT NULL,
  target_entity_type enum('BODY','TISSUE','CELL','CHEMICAL','NUTRIENT','PATHWAY','PHENOTYPE','TEST','OTHER') NOT NULL,
  target_external_id varchar(255) NOT NULL,
  relationship_type enum(
    'LOCATED_IN','OVERLIES','NEAR_NERVE','NEAR_VESSEL','NEAR_MUSCLE',
    'TRADITIONAL_ASSOCIATION','PHYSIOLOGICAL_HYPOTHESIS','MEASUREMENT_CANDIDATE'
  ) NOT NULL,
  claim_text text NOT NULL,
  evidence_state enum(
    'SOURCE_RECORDED','ANATOMY_VERIFIED','MECHANISM_PENDING',
    'MEASUREMENT_PENDING','VERIFIED'
  ) NOT NULL DEFAULT 'SOURCE_RECORDED',
  source_bibliography_id bigint unsigned NOT NULL,
  source_batch_id char(36) NULL,
  source_locator varchar(1200) NULL,
  reviewed_at datetime(6) NULL,
  created_at datetime(6) NOT NULL DEFAULT current_timestamp(6),
  PRIMARY KEY (connection_id),
  UNIQUE KEY uq_ilb_acupuncture_body_connection (
    acupuncture_point_id,target_system,target_entity_type,target_external_id,relationship_type
  ),
  KEY ix_ilb_acupuncture_body_target (
    target_system,target_entity_type,target_external_id,evidence_state
  ),
  KEY ix_ilb_acupuncture_body_state (evidence_state,relationship_type),
  KEY ix_ilb_acupuncture_body_source_batch (source_batch_id),
  CONSTRAINT fk_ilb_acupuncture_body_point
    FOREIGN KEY (acupuncture_point_id) REFERENCES ilb_acupuncture_point(point_id),
  CONSTRAINT fk_ilb_acupuncture_body_bibliography
    FOREIGN KEY (source_bibliography_id) REFERENCES ilb_bibliography_entry(bibliography_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE OR REPLACE VIEW v_ilb_acupuncture_body_connection_coverage AS
SELECT
  relationship_type,
  evidence_state,
  COUNT(*) AS connections,
  COUNT(DISTINCT acupuncture_point_id) AS acupuncture_points_covered,
  COUNT(DISTINCT CONCAT(target_system,'|',target_entity_type,'|',target_external_id)) AS body_targets_covered,
  SUM(CASE WHEN source_bibliography_id IS NULL THEN 1 ELSE 0 END) AS missing_bibliography,
  SUM(CASE WHEN source_locator IS NULL OR source_locator='' THEN 1 ELSE 0 END) AS missing_locator
FROM ilb_acupuncture_body_connection
GROUP BY relationship_type,evidence_state;

COMMIT;
