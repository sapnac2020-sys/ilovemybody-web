-- Phase 79: exact external identities for psoriasis agents and human molecular targets.
START TRANSACTION;

CREATE TABLE IF NOT EXISTS ilb_psoriasis_target_component (
 target_key varchar(100) NOT NULL,
 component_key varchar(100) NOT NULL,
 component_role varchar(100) NOT NULL,
 external_system varchar(40) NOT NULL,
 external_id varchar(180) NOT NULL,
 organism_taxon_id int unsigned NOT NULL,
 source_url varchar(1000) NOT NULL,
 verification_status enum('SOURCE_VERIFIED','REVIEW_REQUIRED','REJECTED') NOT NULL,
 verified_at timestamp NULL,
 computation_eligible tinyint(1) NOT NULL DEFAULT 0,
 PRIMARY KEY(target_key,component_key,external_system,external_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ilb_psoriasis_external_resolution_run (
 run_key varchar(120) NOT NULL,
 source_system varchar(40) NOT NULL,
 source_endpoint varchar(1000) NOT NULL,
 requested_count int unsigned NOT NULL,
 verified_count int unsigned NOT NULL,
 rejected_count int unsigned NOT NULL,
 patient_rows_read int unsigned NOT NULL DEFAULT 0,
 patient_rows_modified int unsigned NOT NULL DEFAULT 0,
 run_status enum('PASSED','FAILED') NOT NULL,
 completed_at timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
 PRIMARY KEY(run_key,source_system)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

COMMIT;
