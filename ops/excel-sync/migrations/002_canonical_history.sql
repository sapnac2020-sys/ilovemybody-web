CREATE TABLE IF NOT EXISTS ilmb_canonical_record_history (
  history_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  canonical_id CHAR(64) NOT NULL,
  system_id VARCHAR(32) NOT NULL,
  sheet_name VARCHAR(255) NOT NULL,
  source_key VARCHAR(512) NOT NULL,
  payload_json JSON NOT NULL,
  row_hash CHAR(64) NOT NULL,
  source_batch_id CHAR(36) NOT NULL,
  version_no INT NOT NULL,
  active BOOLEAN NOT NULL,
  effective_at DATETIME(6) NOT NULL,
  replaced_at DATETIME(6) NOT NULL,
  replaced_by_batch_id CHAR(36) NOT NULL,
  UNIQUE KEY uq_canonical_history_version (canonical_id, version_no),
  INDEX ix_canonical_history_source (system_id, sheet_name, source_key(255)),
  INDEX ix_canonical_history_batch (source_batch_id),
  INDEX ix_canonical_history_replacement (replaced_by_batch_id)
) ENGINE=InnoDB;
