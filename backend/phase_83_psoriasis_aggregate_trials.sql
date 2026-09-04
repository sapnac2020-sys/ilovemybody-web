-- Phase 83: aggregate ClinicalTrials.gov records; no participant-level data.
START TRANSACTION;
CREATE TABLE IF NOT EXISTS ilb_psoriasis_aggregate_trial (
 agent_key varchar(80) NOT NULL,
 nct_id varchar(20) NOT NULL,
 brief_title text NOT NULL,
 overall_status varchar(80) NULL,
 phases_json json NULL,
 enrollment_count int unsigned NULL,
 enrollment_type varchar(40) NULL,
 has_results tinyint(1) NOT NULL,
 protocol_json longtext NOT NULL,
 results_json longtext NULL,
 source_url varchar(1000) NOT NULL,
 source_sha256 char(64) NOT NULL,
 source_updated_date varchar(40) NULL,
 computation_eligible tinyint(1) NOT NULL DEFAULT 0,
 retrieved_at timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
 PRIMARY KEY(agent_key,nct_id),
 KEY idx_p83_nct(nct_id),
 KEY idx_p83_results(agent_key,has_results)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
COMMIT;
