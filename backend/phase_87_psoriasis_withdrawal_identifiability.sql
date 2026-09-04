-- Phase 87: determine whether aggregate withdrawal outcomes identify persistence states.
START TRANSACTION;
CREATE TABLE IF NOT EXISTS ilb_psoriasis_withdrawal_identifiability (
 agent_key varchar(80) NOT NULL,
 nct_id varchar(20) NOT NULL,
 outcome_index int unsigned NOT NULL,
 outcome_title text NOT NULL,
 time_frame text NULL,
 measurement_count int unsigned NOT NULL,
 candidate_R tinyint(1) NOT NULL DEFAULT 0,
 candidate_E tinyint(1) NOT NULL DEFAULT 0,
 candidate_F tinyint(1) NOT NULL DEFAULT 0,
 candidate_L tinyint(1) NOT NULL DEFAULT 0,
 identifies_persistence_state tinyint(1) NOT NULL DEFAULT 0,
 decision enum('CLINICAL_RELAPSE_ONLY','STATE_CANDIDATE_TEXT','STATE_IDENTIFIED') NOT NULL,
 computation_eligible tinyint(1) NOT NULL DEFAULT 0,
 source_url varchar(1000) NOT NULL,
 PRIMARY KEY(agent_key,nct_id,outcome_index),
 KEY idx_p87_decision(decision)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
COMMIT;
