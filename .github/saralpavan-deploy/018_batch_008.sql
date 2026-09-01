-- Saral Pavan source-first cosmos foundation, Batch 008 only.
-- JPL Horizons state vectors, geometry/event definitions, uncertainty and lineage.

CREATE TABLE IF NOT EXISTS sp_cosmos_horizons_request (
  request_id VARCHAR(64) PRIMARY KEY,
  target_object_code VARCHAR(32) NOT NULL,
  target_naif_id VARCHAR(32) NOT NULL,
  center_code VARCHAR(32) NOT NULL,
  ephemeris_type VARCHAR(24) NOT NULL,
  epoch_specification TEXT NOT NULL,
  epoch_mode VARCHAR(24) NOT NULL,
  reference_plane VARCHAR(32) NOT NULL,
  reference_system VARCHAR(32) NOT NULL,
  output_units VARCHAR(24) NOT NULL,
  vector_table VARCHAR(16) NOT NULL,
  csv_format VARCHAR(8) NOT NULL,
  source_id VARCHAR(64) NOT NULL,
  canonical_parameter_string TEXT NOT NULL,
  request_status VARCHAR(24) NOT NULL,
  KEY ix_hreq_target (target_naif_id), KEY ix_hreq_source (source_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS sp_cosmos_horizons_response (
  response_id VARCHAR(64) PRIMARY KEY,
  request_id VARCHAR(64) NOT NULL,
  api_source VARCHAR(128) NOT NULL,
  api_version VARCHAR(32) NULL,
  raw_response_sha256 CHAR(64) NOT NULL,
  raw_bytes BIGINT UNSIGNED NOT NULL,
  header_sha256 CHAR(64) NOT NULL,
  ephemeris_release VARCHAR(64) NULL,
  retrieved_at_utc VARCHAR(40) NOT NULL,
  raw_file_name VARCHAR(255) NOT NULL,
  validation_status VARCHAR(24) NOT NULL,
  UNIQUE KEY uq_hres_hash (raw_response_sha256), KEY ix_hres_request (request_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS sp_cosmos_ephemeris_state (
  state_id VARCHAR(128) PRIMARY KEY,
  response_id VARCHAR(64) NOT NULL,
  request_id VARCHAR(64) NOT NULL,
  target_object_code VARCHAR(32) NOT NULL,
  target_naif_id VARCHAR(32) NOT NULL,
  center_object_code VARCHAR(32) NOT NULL,
  center_naif_id VARCHAR(32) NOT NULL,
  epoch_jd_tdb DECIMAL(18,9) NOT NULL,
  calendar_tdb VARCHAR(48) NOT NULL,
  time_scale VARCHAR(16) NOT NULL,
  reference_frame VARCHAR(32) NOT NULL,
  aberration_correction VARCHAR(32) NOT NULL,
  x_km DOUBLE NOT NULL, y_km DOUBLE NOT NULL, z_km DOUBLE NOT NULL,
  vx_km_s DOUBLE NOT NULL, vy_km_s DOUBLE NOT NULL, vz_km_s DOUBLE NOT NULL,
  position_unit VARCHAR(16) NOT NULL,
  velocity_unit VARCHAR(16) NOT NULL,
  ephemeris_release VARCHAR(64) NULL,
  source_id VARCHAR(64) NOT NULL,
  row_status VARCHAR(24) NOT NULL,
  UNIQUE KEY uq_state_geometry (target_naif_id,center_naif_id,epoch_jd_tdb,reference_frame,aberration_correction),
  KEY ix_state_epoch (epoch_jd_tdb), KEY ix_state_response (response_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS sp_cosmos_event_definition (
  event_code VARCHAR(64) PRIMARY KEY,
  event_name VARCHAR(160) NOT NULL,
  mathematical_definition TEXT NOT NULL,
  input_contract TEXT NOT NULL,
  authoritative_method VARCHAR(160) NOT NULL,
  source_id VARCHAR(64) NOT NULL,
  validation_requirement TEXT NOT NULL,
  status VARCHAR(24) NOT NULL,
  KEY ix_event_source (source_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS sp_cosmos_uncertainty_rule (
  uncertainty_rule_id VARCHAR(64) PRIMARY KEY,
  name VARCHAR(160) NOT NULL,
  rule_expression TEXT NOT NULL,
  applies_to VARCHAR(160) NOT NULL,
  method_or_constraint TEXT NOT NULL,
  source_id VARCHAR(64) NOT NULL,
  status VARCHAR(24) NOT NULL,
  KEY ix_uq_source (source_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS sp_cosmos_data_lineage (
  lineage_id VARCHAR(64) PRIMARY KEY,
  child_table VARCHAR(128) NOT NULL,
  child_key_column VARCHAR(128) NOT NULL,
  parent_key VARCHAR(160) NOT NULL,
  parent_table VARCHAR(128) NOT NULL,
  parent_key_column VARCHAR(128) NOT NULL,
  source_id VARCHAR(64) NOT NULL,
  source_sha256 CHAR(64) NOT NULL,
  epoch_jd_tdb DECIMAL(18,9) NULL,
  transformation VARCHAR(64) NOT NULL,
  status VARCHAR(24) NOT NULL,
  KEY ix_lineage_child (child_table,child_key_column), KEY ix_lineage_parent (parent_table,parent_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS sp_cosmos_validation_record (
  validation_id VARCHAR(96) PRIMARY KEY,
  validation_type VARCHAR(96) NOT NULL,
  subject_key VARCHAR(160) NOT NULL,
  test_definition TEXT NOT NULL,
  expected_value TEXT NULL,
  actual_value TEXT NULL,
  absolute_difference VARCHAR(64) NULL,
  tolerance TEXT NOT NULL,
  status VARCHAR(24) NOT NULL,
  source_id VARCHAR(64) NOT NULL,
  validated_at_utc VARCHAR(40) NOT NULL,
  KEY ix_validation_status (status), KEY ix_validation_subject (subject_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
