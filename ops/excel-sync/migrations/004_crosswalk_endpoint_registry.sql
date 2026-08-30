CREATE TABLE IF NOT EXISTS ilmb_crosswalk_endpoint (
  system_id VARCHAR(64) NOT NULL,
  entity_type VARCHAR(32) NOT NULL,
  external_id VARCHAR(255) NOT NULL,
  source_name VARCHAR(255) NOT NULL,
  source_version VARCHAR(128) NOT NULL,
  source_locator VARCHAR(512) NULL,
  verified_at DATETIME(6) NOT NULL,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  PRIMARY KEY (system_id, entity_type, external_id),
  INDEX ix_crosswalk_endpoint_active (active, system_id, entity_type)
) ENGINE=InnoDB;

ALTER TABLE ilmb_entity_crosswalk
  ADD COLUMN IF NOT EXISTS source_endpoint_resolved BOOLEAN NOT NULL DEFAULT FALSE AFTER confidence,
  ADD COLUMN IF NOT EXISTS target_endpoint_resolved BOOLEAN NOT NULL DEFAULT FALSE AFTER source_endpoint_resolved;

ALTER TABLE ilmb_entity_crosswalk_history
  ADD COLUMN IF NOT EXISTS source_endpoint_resolved BOOLEAN NOT NULL DEFAULT FALSE AFTER confidence,
  ADD COLUMN IF NOT EXISTS target_endpoint_resolved BOOLEAN NOT NULL DEFAULT FALSE AFTER source_endpoint_resolved;
