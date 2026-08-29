CREATE TABLE IF NOT EXISTS ilmb_sync_file (
  drive_file_id VARCHAR(128) PRIMARY KEY,
  file_name VARCHAR(512) NOT NULL,
  system_id VARCHAR(32) NOT NULL,
  drive_modified_time DATETIME(6) NULL,
  last_seen_hash CHAR(64) NULL,
  last_seen_at DATETIME(6) NOT NULL,
  enabled BOOLEAN NOT NULL DEFAULT TRUE,
  INDEX ix_sync_file_system (system_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS ilmb_sync_batch (
  batch_id CHAR(36) PRIMARY KEY,
  drive_file_id VARCHAR(128) NOT NULL,
  file_name VARCHAR(512) NOT NULL,
  system_id VARCHAR(32) NOT NULL,
  content_hash CHAR(64) NOT NULL,
  drive_modified_time DATETIME(6) NULL,
  status ENUM('VALIDATING','REJECTED_VALIDATION','STAGED','APPROVED','REJECTED','PROMOTED','FAILED') NOT NULL,
  row_count INT NOT NULL DEFAULT 0,
  error_count INT NOT NULL DEFAULT 0,
  created_at DATETIME(6) NOT NULL,
  staged_at DATETIME(6) NULL,
  decided_at DATETIME(6) NULL,
  promoted_at DATETIME(6) NULL,
  decision_by VARCHAR(255) NULL,
  decision_reason TEXT NULL,
  UNIQUE KEY uq_sync_batch_hash (drive_file_id, content_hash),
  INDEX ix_sync_batch_status (status),
  CONSTRAINT fk_sync_batch_file FOREIGN KEY (drive_file_id) REFERENCES ilmb_sync_file(drive_file_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS ilmb_sync_stage_row (
  batch_id CHAR(36) NOT NULL,
  row_id CHAR(64) NOT NULL,
  system_id VARCHAR(32) NOT NULL,
  sheet_name VARCHAR(255) NOT NULL,
  source_row INT NOT NULL,
  source_key VARCHAR(512) NOT NULL,
  row_hash CHAR(64) NOT NULL,
  payload_json JSON NOT NULL,
  PRIMARY KEY (batch_id, row_id),
  INDEX ix_stage_source (system_id, sheet_name, source_key(255)),
  CONSTRAINT fk_stage_batch FOREIGN KEY (batch_id) REFERENCES ilmb_sync_batch(batch_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS ilmb_sync_validation_error (
  error_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  batch_id CHAR(36) NOT NULL,
  severity ENUM('ERROR','WARNING') NOT NULL,
  code VARCHAR(64) NOT NULL,
  sheet_name VARCHAR(255) NULL,
  source_row INT NULL,
  message TEXT NOT NULL,
  created_at DATETIME(6) NOT NULL,
  INDEX ix_validation_batch (batch_id),
  CONSTRAINT fk_validation_batch FOREIGN KEY (batch_id) REFERENCES ilmb_sync_batch(batch_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS ilmb_canonical_record (
  canonical_id CHAR(64) PRIMARY KEY,
  system_id VARCHAR(32) NOT NULL,
  sheet_name VARCHAR(255) NOT NULL,
  source_key VARCHAR(512) NOT NULL,
  payload_json JSON NOT NULL,
  row_hash CHAR(64) NOT NULL,
  source_batch_id CHAR(36) NOT NULL,
  version_no INT NOT NULL,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  effective_at DATETIME(6) NOT NULL,
  INDEX ix_canonical_source (system_id, sheet_name, source_key(255)),
  INDEX ix_canonical_batch (source_batch_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS ilmb_sync_audit (
  audit_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  event_time DATETIME(6) NOT NULL,
  actor VARCHAR(255) NOT NULL,
  event_type VARCHAR(64) NOT NULL,
  batch_id CHAR(36) NULL,
  details_json JSON NOT NULL,
  INDEX ix_audit_batch (batch_id),
  INDEX ix_audit_time (event_time)
) ENGINE=InnoDB;
