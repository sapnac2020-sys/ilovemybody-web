-- Phase 84: exact aggregate outcome objects from ClinicalTrials.gov results.
START TRANSACTION;
CREATE TABLE IF NOT EXISTS ilb_psoriasis_aggregate_outcome (
 agent_key varchar(80) NOT NULL,
 nct_id varchar(20) NOT NULL,
 outcome_index int unsigned NOT NULL,
 outcome_class enum('PASI','IGA_PGA','DLQI','WITHDRAWAL_RELAPSE','OTHER') NOT NULL,
 outcome_type varchar(80) NULL,
 title text NOT NULL,
 description text NULL,
 time_frame text NULL,
 units varchar(500) NULL,
 param_type varchar(120) NULL,
 dispersion_type varchar(120) NULL,
 outcome_json longtext NOT NULL,
 outcome_sha256 char(64) NOT NULL,
 source_trial_sha256 char(64) NOT NULL,
 computation_eligible tinyint(1) NOT NULL DEFAULT 0,
 extracted_at timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
 PRIMARY KEY(agent_key,nct_id,outcome_index),
 KEY idx_p84_class(agent_key,outcome_class),
 KEY idx_p84_nct(nct_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
COMMIT;
