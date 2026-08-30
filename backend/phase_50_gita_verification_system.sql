-- Phase 50: Bhagavad Gita governed verification system
-- Target: u756742628_ilovemybody
-- Prerequisites: Phases 47-49.
-- Safe to rerun. This creates structure and controlled metadata only.
-- Corpus rows are loaded separately by phase_50a_gita_corpus.sql.

START TRANSACTION;

CREATE TABLE IF NOT EXISTS `ilb_gita_import_batch` (
  `batch_key` varchar(96) NOT NULL,
  `workbook_name` varchar(255) NOT NULL,
  `workbook_sha256` char(64) DEFAULT NULL,
  `source_scope` varchar(255) NOT NULL,
  `expected_verses` int unsigned NOT NULL,
  `expected_tokens` int unsigned DEFAULT NULL,
  `imported_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `imported_by` varchar(96) NOT NULL,
  `status` enum('staged','imported','verified','rejected') NOT NULL DEFAULT 'staged',
  `notes` text,
  PRIMARY KEY (`batch_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `ilb_gita_edition` (
  `edition_key` varchar(96) NOT NULL,
  `title` varchar(255) NOT NULL,
  `editor_institution` varchar(255) DEFAULT NULL,
  `script_name` varchar(64) NOT NULL,
  `verse_count` int unsigned NOT NULL,
  `numbering_system` varchar(255) NOT NULL,
  `source_location` text NOT NULL,
  `licence_permission` varchar(255) DEFAULT NULL,
  `source_hash` char(64) DEFAULT NULL,
  `status` enum('selected','candidate','retired','blocked') NOT NULL DEFAULT 'candidate',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`edition_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `ilb_gita_chapter` (
  `chapter_no` smallint unsigned NOT NULL,
  `verse_slots` smallint unsigned NOT NULL,
  `global_start` smallint unsigned NOT NULL,
  `global_end` smallint unsigned NOT NULL,
  `numbering_basis` varchar(255) NOT NULL,
  `source_status` varchar(64) NOT NULL,
  PRIMARY KEY (`chapter_no`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `ilb_gita_verse` (
  `verse_key` varchar(24) NOT NULL,
  `chapter_no` smallint unsigned NOT NULL,
  `verse_no` smallint unsigned NOT NULL,
  `global_sequence` smallint unsigned NOT NULL,
  `display_reference` varchar(24) NOT NULL,
  `edition_crosswalk` varchar(255) DEFAULT NULL,
  `priority_module` varchar(96) DEFAULT NULL,
  `source_status` enum('pending','imported','verified','blocked') NOT NULL DEFAULT 'pending',
  `token_status` enum('not_tokenised','machine_tokenised','human_reviewed') NOT NULL DEFAULT 'not_tokenised',
  `translation_status` enum('none','draft_only','reviewed') NOT NULL DEFAULT 'none',
  `release_status` enum('not_released','eligible','released') NOT NULL DEFAULT 'not_released',
  PRIMARY KEY (`verse_key`),
  UNIQUE KEY `uq_gita_verse_sequence` (`global_sequence`),
  UNIQUE KEY `uq_gita_chapter_verse` (`chapter_no`,`verse_no`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `ilb_gita_source_text` (
  `source_record_key` varchar(32) NOT NULL,
  `verse_key` varchar(24) NOT NULL,
  `edition_key` varchar(96) NOT NULL,
  `exact_devanagari` longtext NOT NULL,
  `original_line_breaks` longtext,
  `source_location` text NOT NULL,
  `source_sha256` char(64) NOT NULL,
  `batch_key` varchar(96) NOT NULL,
  `import_status` enum('imported','hash_verified','human_verified','rejected') NOT NULL DEFAULT 'imported',
  `imported_at` datetime DEFAULT NULL,
  `imported_by` varchar(96) DEFAULT NULL,
  PRIMARY KEY (`source_record_key`),
  UNIQUE KEY `uq_gita_source_edition_verse` (`edition_key`,`verse_key`),
  KEY `ix_gita_source_batch` (`batch_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `ilb_gita_token` (
  `token_key` varchar(32) NOT NULL,
  `verse_key` varchar(24) NOT NULL,
  `position_no` smallint unsigned NOT NULL,
  `surface_form` varchar(255) NOT NULL,
  `sandhi_option` varchar(255) DEFAULT NULL,
  `lemma_key` varchar(64) DEFAULT NULL,
  `parse_status` enum('machine_segmented','machine_draft','human_reviewed','rejected') NOT NULL DEFAULT 'machine_segmented',
  `reviewer` varchar(128) DEFAULT NULL,
  `notes` text,
  `batch_key` varchar(96) NOT NULL,
  PRIMARY KEY (`token_key`),
  KEY `ix_gita_token_verse_position` (`verse_key`,`position_no`),
  KEY `ix_gita_token_surface` (`surface_form`(128))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `ilb_gita_parse` (
  `parse_key` varchar(32) NOT NULL,
  `token_key` varchar(32) NOT NULL,
  `part_of_speech` varchar(255) DEFAULT NULL,
  `grammatical_case` varchar(64) DEFAULT NULL,
  `grammatical_number` varchar(64) DEFAULT NULL,
  `grammatical_gender` varchar(64) DEFAULT NULL,
  `grammatical_person` varchar(64) DEFAULT NULL,
  `tense_mood` varchar(128) DEFAULT NULL,
  `voice_name` varchar(64) DEFAULT NULL,
  `dhatu` varchar(255) DEFAULT NULL,
  `prefix_text` varchar(255) DEFAULT NULL,
  `suffix_text` varchar(255) DEFAULT NULL,
  `confidence_value` decimal(7,6) DEFAULT NULL,
  `review_status` enum('machine_draft','human_reviewed','rejected') NOT NULL DEFAULT 'machine_draft',
  PRIMARY KEY (`parse_key`),
  KEY `ix_gita_parse_token` (`token_key`,`review_status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `ilb_gita_gloss` (
  `gloss_key` varchar(32) NOT NULL,
  `token_key` varchar(32) DEFAULT NULL,
  `lemma_key` varchar(255) NOT NULL,
  `language_code` varchar(16) NOT NULL DEFAULT 'en',
  `gloss_text` text NOT NULL,
  `sense_note` text,
  `source_location` text,
  `reviewer` varchar(255) DEFAULT NULL,
  `review_status` enum('machine_draft','human_reviewed','approved','rejected') NOT NULL DEFAULT 'machine_draft',
  `reviewed_at` datetime DEFAULT NULL,
  PRIMARY KEY (`gloss_key`),
  KEY `ix_gita_gloss_token` (`token_key`,`language_code`,`review_status`),
  KEY `ix_gita_gloss_lemma` (`lemma_key`(128),`language_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `ilb_gita_source_variant` (
  `variant_key` varchar(48) NOT NULL,
  `source_chapter` varchar(16) NOT NULL,
  `source_verse` varchar(32) NOT NULL,
  `edition_key` varchar(96) NOT NULL,
  `variant_reference` varchar(64) NOT NULL,
  `variant_text` longtext,
  `difference_note` text NOT NULL,
  `source_location` text,
  `review_status` enum('candidate','reviewed','accepted','rejected') NOT NULL DEFAULT 'candidate',
  PRIMARY KEY (`variant_key`),
  KEY `ix_gita_variant_source` (`source_chapter`,`source_verse`,`edition_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `ilb_gita_translation` (
  `translation_key` varchar(48) NOT NULL,
  `verse_key` varchar(24) NOT NULL,
  `edition_key` varchar(96) NOT NULL,
  `language_code` varchar(16) NOT NULL DEFAULT 'en',
  `translation_type` enum('literal','readable','commentary') NOT NULL,
  `translation_text` longtext NOT NULL,
  `translator` varchar(255) DEFAULT NULL,
  `reviewer` varchar(255) DEFAULT NULL,
  `review_status` enum('machine_draft','human_draft','approved','rejected') NOT NULL DEFAULT 'machine_draft',
  `reviewed_at` datetime DEFAULT NULL,
  PRIMARY KEY (`translation_key`),
  KEY `ix_gita_translation_verse` (`verse_key`,`language_code`,`review_status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Backward compatibility for an earlier partial Gita translation table.
-- MariaDB on Hostinger supports idempotent ADD COLUMN IF NOT EXISTS.
ALTER TABLE `ilb_gita_translation`
  ADD COLUMN IF NOT EXISTS `review_status`
    enum('machine_draft','human_draft','approved','rejected')
    NOT NULL DEFAULT 'machine_draft' AFTER `reviewer`,
  ADD COLUMN IF NOT EXISTS `reviewed_at` datetime DEFAULT NULL AFTER `review_status`;

CREATE TABLE IF NOT EXISTS `ilb_gita_proposition` (
  `proposition_key` varchar(32) NOT NULL,
  `verse_key` varchar(24) NOT NULL,
  `exact_sanskrit_span` longtext NOT NULL,
  `token_keys_text` longtext,
  `literal_proposition` longtext NOT NULL,
  `statement_type` enum('physical','behavioural','experiential','metaphysical','mixed') NOT NULL,
  `text_reviewer` varchar(255) DEFAULT NULL,
  `text_status` enum('machine_draft','human_reviewed','frozen','rejected') NOT NULL DEFAULT 'machine_draft',
  `frozen_at` datetime DEFAULT NULL,
  `text_sha256` char(64) DEFAULT NULL,
  PRIMARY KEY (`proposition_key`),
  KEY `ix_gita_proposition_verse` (`verse_key`,`text_status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `ilb_gita_candidate_mapping` (
  `candidate_key` varchar(48) NOT NULL,
  `verse_key` varchar(24) NOT NULL,
  `candidate_domain` enum('body','food','behaviour','value','relationship','other') NOT NULL,
  `source_phrase` text NOT NULL,
  `candidate_target_label` varchar(255) NOT NULL,
  `canonical_target_table` varchar(128) DEFAULT NULL,
  `canonical_target_key` varchar(128) DEFAULT NULL,
  `mapping_basis` text NOT NULL,
  `claim_class` enum('textual','interpretive','hypothesis') NOT NULL DEFAULT 'interpretive',
  `approval_status` enum('candidate','reviewed','approved_for_testing','rejected') NOT NULL DEFAULT 'candidate',
  `reviewer` varchar(255) DEFAULT NULL,
  `reviewed_at` datetime DEFAULT NULL,
  PRIMARY KEY (`candidate_key`),
  KEY `ix_gita_candidate_domain` (`candidate_domain`,`approval_status`),
  KEY `ix_gita_candidate_target` (`canonical_target_table`,`canonical_target_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `ilb_gita_formula` (
  `formula_key` varchar(32) NOT NULL,
  `formula_name` varchar(255) NOT NULL,
  `mathematical_expression` longtext NOT NULL,
  `input_variables` longtext NOT NULL,
  `output_variable` varchar(255) NOT NULL,
  `input_units` varchar(255) DEFAULT NULL,
  `output_unit` varchar(96) NOT NULL,
  `assumptions` longtext NOT NULL,
  `uncertainty_formula` longtext,
  `edge_case_rule` longtext NOT NULL,
  `formula_version` varchar(32) NOT NULL,
  `formula_class` enum('text','experiment','uncertainty','replication','robustness') NOT NULL,
  `verification_status` enum('draft','arithmetic_tested','verified_for_use','retired') NOT NULL DEFAULT 'draft',
  `frozen_at` datetime DEFAULT NULL,
  PRIMARY KEY (`formula_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `ilb_gita_formula_test` (
  `test_key` varchar(32) NOT NULL,
  `formula_key` varchar(32) NOT NULL,
  `input_a` decimal(30,12) DEFAULT NULL,
  `input_b` decimal(30,12) DEFAULT NULL,
  `input_c` decimal(30,12) DEFAULT NULL,
  `calculated_value` decimal(30,12) DEFAULT NULL,
  `expected_value` decimal(30,12) DEFAULT NULL,
  `tolerance_value` decimal(30,12) NOT NULL,
  `test_status` enum('pass','fail','not_run') NOT NULL DEFAULT 'not_run',
  `tested_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`test_key`),
  KEY `ix_gita_formula_test_formula` (`formula_key`,`test_status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `ilb_gita_hypothesis` (
  `hypothesis_key` varchar(48) NOT NULL,
  `proposition_key` varchar(32) NOT NULL,
  `proposed_mapping` longtext NOT NULL,
  `formula_key` varchar(32) NOT NULL,
  `input_contract` longtext NOT NULL,
  `unit_contract` longtext NOT NULL,
  `falsification_rule` longtext NOT NULL,
  `evidence_class` enum('personal_observation','mechanistic_calculation','external_benchmark') NOT NULL,
  `status` enum('draft','reviewed','approved_for_preregistration','rejected','retired') NOT NULL DEFAULT 'draft',
  `clinical_use` enum('blocked','research_only','reviewed_support') NOT NULL DEFAULT 'blocked',
  PRIMARY KEY (`hypothesis_key`),
  KEY `ix_gita_hypothesis_proposition` (`proposition_key`,`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `ilb_gita_prediction` (
  `prediction_key` varchar(48) NOT NULL,
  `hypothesis_key` varchar(48) NOT NULL,
  `primary_outcome` varchar(255) NOT NULL,
  `predicted_direction` varchar(128) NOT NULL,
  `effect_threshold` varchar(128) NOT NULL,
  `time_window` varchar(128) NOT NULL,
  `control_definition` text NOT NULL,
  `confounders_frozen` text NOT NULL,
  `analysis_formula_key` varchar(32) NOT NULL,
  `preregistered_at` datetime DEFAULT NULL,
  `prediction_sha256` char(64) DEFAULT NULL,
  `status` enum('draft','preregistered','completed','withdrawn','rejected') NOT NULL DEFAULT 'draft',
  PRIMARY KEY (`prediction_key`),
  KEY `ix_gita_prediction_hypothesis` (`hypothesis_key`,`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `ilb_gita_personal_protocol` (
  `protocol_key` varchar(48) NOT NULL,
  `subject_key` varchar(96) NOT NULL,
  `prediction_key` varchar(48) NOT NULL,
  `baseline_contract` longtext NOT NULL,
  `intervention_contract` longtext NOT NULL,
  `washout_contract` longtext,
  `measurement_contract` longtext NOT NULL,
  `safety_contract` longtext NOT NULL,
  `consent_event_key` varchar(96) DEFAULT NULL,
  `started_at` datetime DEFAULT NULL,
  `ended_at` datetime DEFAULT NULL,
  `status` enum('draft','approved','active','paused','completed','withdrawn','stopped_for_safety') NOT NULL DEFAULT 'draft',
  PRIMARY KEY (`protocol_key`),
  KEY `ix_gita_protocol_subject` (`subject_key`,`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `ilb_gita_observation` (
  `observation_key` varchar(64) NOT NULL,
  `protocol_key` varchar(48) NOT NULL,
  `subject_key` varchar(96) NOT NULL,
  `observed_at` datetime NOT NULL,
  `phase_name` enum('baseline','intervention','washout','followup') NOT NULL,
  `exposure_value` decimal(20,8) DEFAULT NULL,
  `exposure_unit` varchar(64) DEFAULT NULL,
  `context_json` json DEFAULT NULL,
  `participant_note` longtext,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`observation_key`),
  KEY `ix_gita_observation_protocol_time` (`protocol_key`,`observed_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `ilb_gita_measurement` (
  `measurement_key` varchar(64) NOT NULL,
  `observation_key` varchar(64) NOT NULL,
  `variable_key` varchar(128) NOT NULL,
  `numeric_value` decimal(30,12) NOT NULL,
  `unit_code` varchar(64) NOT NULL,
  `standard_uncertainty` decimal(30,12) DEFAULT NULL,
  `method_key` varchar(128) NOT NULL,
  `device_key` varchar(128) DEFAULT NULL,
  `quality_status` enum('raw','verified','excluded') NOT NULL DEFAULT 'raw',
  `exclusion_reason` text,
  PRIMARY KEY (`measurement_key`),
  KEY `ix_gita_measurement_observation` (`observation_key`,`variable_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `ilb_gita_calculated_result` (
  `result_key` varchar(64) NOT NULL,
  `protocol_key` varchar(48) NOT NULL,
  `prediction_key` varchar(48) NOT NULL,
  `formula_key` varchar(32) NOT NULL,
  `formula_version` varchar(32) NOT NULL,
  `input_snapshot_json` json NOT NULL,
  `result_value` decimal(30,12) DEFAULT NULL,
  `result_unit` varchar(64) NOT NULL,
  `uncertainty_value` decimal(30,12) DEFAULT NULL,
  `calculation_status` enum('not_calculable','calculated','verified','rejected') NOT NULL,
  `calculated_at` datetime NOT NULL,
  `calculation_sha256` char(64) NOT NULL,
  PRIMARY KEY (`result_key`),
  KEY `ix_gita_result_prediction` (`prediction_key`,`calculation_status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `ilb_gita_replication` (
  `replication_key` varchar(64) NOT NULL,
  `prediction_key` varchar(48) NOT NULL,
  `protocol_key` varchar(48) NOT NULL,
  `replication_no` smallint unsigned NOT NULL,
  `support_class` enum('supports','contradicts','inconclusive') NOT NULL,
  `classification_rule` text NOT NULL,
  `reviewer` varchar(255) DEFAULT NULL,
  `reviewed_at` datetime DEFAULT NULL,
  PRIMARY KEY (`replication_key`),
  UNIQUE KEY `uq_gita_replication_protocol_no` (`protocol_key`,`replication_no`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `ilb_gita_contradiction` (
  `contradiction_key` varchar(64) NOT NULL,
  `prediction_key` varchar(48) NOT NULL,
  `result_key` varchar(64) DEFAULT NULL,
  `contradiction_text` longtext NOT NULL,
  `severity` enum('information','review','blocking') NOT NULL,
  `resolution_rule` longtext NOT NULL,
  `resolution_text` longtext,
  `status` enum('open','resolved','accepted_limitation') NOT NULL DEFAULT 'open',
  `resolved_at` datetime DEFAULT NULL,
  PRIMARY KEY (`contradiction_key`),
  KEY `ix_gita_contradiction_prediction` (`prediction_key`,`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `ilb_gita_proof_gate` (
  `prediction_key` varchar(48) NOT NULL,
  `text_frozen` tinyint(1) NOT NULL DEFAULT 0,
  `translation_reviewed` tinyint(1) NOT NULL DEFAULT 0,
  `prediction_preregistered` tinyint(1) NOT NULL DEFAULT 0,
  `formula_frozen` tinyint(1) NOT NULL DEFAULT 0,
  `personal_data_present` tinyint(1) NOT NULL DEFAULT 0,
  `uncertainty_calculated` tinyint(1) NOT NULL DEFAULT 0,
  `minimum_replication_met` tinyint(1) NOT NULL DEFAULT 0,
  `contradictions_resolved` tinyint(1) NOT NULL DEFAULT 0,
  `final_state` enum('blocked','testing','supported_personally','contradicted','inconclusive') NOT NULL DEFAULT 'blocked',
  `evaluated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`prediction_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP VIEW IF EXISTS `v_ilb_gita_verification_queue`;
CREATE VIEW `v_ilb_gita_verification_queue` AS
SELECT p.`prediction_key`,p.`hypothesis_key`,p.`primary_outcome`,p.`status` AS `prediction_status`,
       g.`text_frozen`,g.`translation_reviewed`,g.`prediction_preregistered`,
       g.`formula_frozen`,g.`personal_data_present`,g.`uncertainty_calculated`,
       g.`minimum_replication_met`,g.`contradictions_resolved`,g.`final_state`
FROM `ilb_gita_prediction` p
LEFT JOIN `ilb_gita_proof_gate` g ON g.`prediction_key`=p.`prediction_key`;

DROP VIEW IF EXISTS `v_ilb_gita_readiness`;
CREATE VIEW `v_ilb_gita_readiness` AS
SELECT
  (SELECT COUNT(*) FROM `ilb_gita_verse`) AS `verse_rows`,
  (SELECT COUNT(*) FROM `ilb_gita_source_text`) AS `source_rows`,
  (SELECT COUNT(*) FROM `ilb_gita_source_text` WHERE `source_sha256` IS NOT NULL) AS `hashed_source_rows`,
  (SELECT COUNT(DISTINCT `verse_key`) FROM `ilb_gita_token`) AS `tokenised_verses`,
  (SELECT COUNT(*) FROM `ilb_gita_translation` WHERE `review_status`='approved') AS `approved_translations`,
  (SELECT COUNT(*) FROM `ilb_gita_proposition` WHERE `text_status`='frozen') AS `frozen_propositions`,
  (SELECT COUNT(*) FROM `ilb_gita_formula` WHERE `verification_status` IN ('arithmetic_tested','verified_for_use')) AS `tested_formulas`,
  (SELECT COUNT(*) FROM `ilb_gita_formula_test` WHERE `test_status`='pass') AS `passing_formula_tests`,
  (SELECT COUNT(*) FROM `ilb_gita_prediction` WHERE `status`='preregistered') AS `preregistered_predictions`,
  (SELECT COUNT(*) FROM `ilb_gita_calculated_result` WHERE `calculation_status`='verified') AS `verified_results`,
  (SELECT COUNT(*) FROM `ilb_gita_proof_gate` WHERE `final_state`='supported_personally') AS `personally_supported_claims`;

COMMIT;

SELECT * FROM `v_ilb_gita_readiness`;
