-- Phase 85: source-exact aggregate measurement cells; values remain text until gated.
START TRANSACTION;
CREATE TABLE IF NOT EXISTS ilb_psoriasis_aggregate_measurement (
 agent_key varchar(80) NOT NULL,
 nct_id varchar(20) NOT NULL,
 outcome_index int unsigned NOT NULL,
 class_index int unsigned NOT NULL,
 category_index int unsigned NOT NULL,
 measurement_index int unsigned NOT NULL,
 outcome_class varchar(40) NOT NULL,
 class_title text NULL,
 category_title text NULL,
 measurement_title text NULL,
 value_text varchar(500) NULL,
 spread_text varchar(500) NULL,
 lower_limit_text varchar(500) NULL,
 upper_limit_text varchar(500) NULL,
 denominator_json longtext NULL,
 measurement_json longtext NOT NULL,
 measurement_sha256 char(64) NOT NULL,
 computation_eligible tinyint(1) NOT NULL DEFAULT 0,
 extracted_at timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
 PRIMARY KEY(agent_key,nct_id,outcome_index,class_index,category_index,measurement_index),
 KEY idx_p85_class(agent_key,outcome_class),
 KEY idx_p85_nct(nct_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
COMMIT;
