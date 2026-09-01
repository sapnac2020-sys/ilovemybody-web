START TRANSACTION;

CREATE TABLE IF NOT EXISTS sp_cosmos_freeze_kernel (
  artifact_id VARCHAR(64) PRIMARY KEY, artifact_type VARCHAR(32) NOT NULL,
  file_name VARCHAR(255) NOT NULL, sha256 CHAR(64) NOT NULL, bytes BIGINT UNSIGNED NOT NULL,
  source_url TEXT NOT NULL, coverage_or_version VARCHAR(255), publisher VARCHAR(128) NOT NULL,
  status VARCHAR(32) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS sp_cosmos_spice_validation (
  validation_id VARCHAR(64) PRIMARY KEY, object_code VARCHAR(32) NOT NULL,
  target_naif_id INT NOT NULL, epoch_jd_tdb DECIMAL(16,7) NOT NULL,
  center VARCHAR(32) NOT NULL, frame VARCHAR(64) NOT NULL, correction VARCHAR(32) NOT NULL,
  reference_solution VARCHAR(128) NOT NULL, comparison_solution VARCHAR(128) NOT NULL,
  position_difference_km DOUBLE NOT NULL, velocity_difference_km_s DOUBLE NOT NULL,
  position_tolerance_km DOUBLE NOT NULL, velocity_tolerance_km_s DOUBLE NOT NULL,
  status VARCHAR(32) NOT NULL, reference_source_id VARCHAR(64) NOT NULL,
  comparison_source_id VARCHAR(64) NOT NULL,
  INDEX idx_spice_object_epoch (target_naif_id, epoch_jd_tdb), INDEX idx_spice_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS sp_cosmos_coverage_exception (
  exception_id VARCHAR(64) PRIMARY KEY, object_code VARCHAR(32) NOT NULL,
  target_naif_id INT NOT NULL, epoch_jd_tdb DECIMAL(16,7) NOT NULL,
  reason TEXT NOT NULL, authoritative_fallback TEXT NOT NULL,
  classification VARCHAR(64) NOT NULL, status VARCHAR(32) NOT NULL,
  INDEX idx_coverage_object_epoch (target_naif_id, epoch_jd_tdb)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS sp_cosmos_observer_request (
  request_id VARCHAR(64) PRIMARY KEY, target_object_code VARCHAR(32) NOT NULL,
  target_naif_id INT NOT NULL, center_code VARCHAR(64) NOT NULL,
  site_geodetic_lon_lat_alt_km VARCHAR(128), epoch_specification VARCHAR(255) NOT NULL,
  time_scale VARCHAR(16) NOT NULL, ephemeris_type VARCHAR(32) NOT NULL,
  quantities VARCHAR(128) NOT NULL, csv_format VARCHAR(16) NOT NULL,
  source_id VARCHAR(64) NOT NULL, status VARCHAR(32) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS sp_cosmos_observer_response (
  response_id VARCHAR(64) PRIMARY KEY, request_id VARCHAR(64) NOT NULL,
  api_source VARCHAR(128) NOT NULL, api_version VARCHAR(32) NOT NULL,
  raw_response_sha256 CHAR(64) NOT NULL, raw_bytes BIGINT UNSIGNED NOT NULL,
  raw_file_name VARCHAR(255) NOT NULL, retrieved_at_utc VARCHAR(40) NOT NULL,
  status VARCHAR(32) NOT NULL, UNIQUE KEY uq_observer_hash (raw_response_sha256),
  CONSTRAINT fk_observer_response_request FOREIGN KEY (request_id)
    REFERENCES sp_cosmos_observer_request(request_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS sp_cosmos_apparent_observation (
  observation_id VARCHAR(64) PRIMARY KEY, response_id VARCHAR(64) NOT NULL,
  request_id VARCHAR(64) NOT NULL, target_object_code VARCHAR(32) NOT NULL,
  target_naif_id INT NOT NULL, observer_mode VARCHAR(32) NOT NULL,
  epoch_calendar_utc VARCHAR(40) NOT NULL, ra_icrf_deg DOUBLE NOT NULL,
  dec_icrf_deg DOUBLE NOT NULL, azimuth_apparent_deg DOUBLE NULL,
  elevation_apparent_deg DOUBLE NULL, range_au DOUBLE NOT NULL,
  range_rate_km_s DOUBLE NOT NULL, solar_elongation_deg DOUBLE NOT NULL,
  phase_angle_deg DOUBLE NOT NULL, reference_frame VARCHAR(64) NOT NULL,
  correction_class VARCHAR(32) NOT NULL, range_unit VARCHAR(16) NOT NULL,
  range_rate_unit VARCHAR(16) NOT NULL, angle_unit VARCHAR(16) NOT NULL,
  source_id VARCHAR(64) NOT NULL, row_status VARCHAR(32) NOT NULL,
  INDEX idx_observation_target_epoch (target_naif_id, epoch_calendar_utc),
  INDEX idx_observation_mode (observer_mode),
  CONSTRAINT fk_apparent_response FOREIGN KEY (response_id)
    REFERENCES sp_cosmos_observer_response(response_id),
  CONSTRAINT fk_apparent_request FOREIGN KEY (request_id)
    REFERENCES sp_cosmos_observer_request(request_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS sp_cosmos_freeze_manifest (
  gate_id VARCHAR(32) PRIMARY KEY, gate_name VARCHAR(255) NOT NULL,
  expected_value VARCHAR(128) NOT NULL, actual_value VARCHAR(128) NOT NULL,
  status VARCHAR(32) NOT NULL, evidence TEXT NOT NULL,
  INDEX idx_freeze_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

COMMIT;
