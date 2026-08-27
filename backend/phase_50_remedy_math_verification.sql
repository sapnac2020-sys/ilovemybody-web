-- Phase 50: mathematics-governed remedy verification engine
-- Target: u756742628_ilovemybody
-- Prerequisite: Phase 49.
-- Safe to rerun. Additive only; no patient-authored record is deleted.
--
-- A remedy may be catalogued because it exists or is proposed. Catalogue
-- presence never establishes efficacy, causation, diagnosis or cure.
-- Personal numeric truth is restricted to PERSON_MEASURED,
-- MATHEMATICALLY_DERIVED or UNKNOWN.

START TRANSACTION;

CREATE TABLE IF NOT EXISTS `ilb_remedy_system` (
  `remedy_system_key` varchar(100) NOT NULL,
  `system_name` varchar(255) NOT NULL,
  `system_class` enum('conventional','rehabilitative','behavioural','environmental','nutritional','complementary','traditional','device','other') NOT NULL,
  `description_text` varchar(1500) NOT NULL,
  `verification_boundary` varchar(1500) NOT NULL,
  `status` enum('catalogued','restricted','retired') NOT NULL DEFAULT 'catalogued',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`remedy_system_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `ilb_remedy_catalogue` (
  `remedy_key` varchar(140) NOT NULL,
  `remedy_system_key` varchar(100) NOT NULL,
  `remedy_name` varchar(255) NOT NULL,
  `remedy_variant` varchar(255) DEFAULT NULL,
  `proposed_target_text` varchar(1500) DEFAULT NULL,
  `claimed_mechanism_text` varchar(2000) DEFAULT NULL,
  `claim_attribution` varchar(1000) DEFAULT NULL,
  `clinical_control` enum('clinician_required','practitioner_required','self_observation_only','not_applicable') NOT NULL,
  `catalogue_status` enum('catalogued','not_testable_yet','testable','restricted','retired') NOT NULL DEFAULT 'catalogued',
  `claim_truth_status` enum('unverified_claim','measurement_defined','personal_response_observed','repeated_personal_response','no_measurable_effect','contradictory','unsafe','rejected') NOT NULL DEFAULT 'unverified_claim',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`remedy_key`),
  KEY `idx_p50_remedy_system` (`remedy_system_key`,`catalogue_status`),
  CONSTRAINT `fk_p50_remedy_system` FOREIGN KEY (`remedy_system_key`)
    REFERENCES `ilb_remedy_system` (`remedy_system_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `ilb_remedy_variable` (
  `variable_key` varchar(140) NOT NULL,
  `variable_name` varchar(255) NOT NULL,
  `variable_role` enum('exposure','response','confounder','safety','context') NOT NULL,
  `canonical_unit` varchar(80) DEFAULT NULL,
  `dimension_signature` varchar(255) DEFAULT NULL,
  `measurement_definition` varchar(1500) NOT NULL,
  `allowed_truth_state` enum('PERSON_MEASURED','MATHEMATICALLY_DERIVED','UNKNOWN') NOT NULL,
  `status` enum('draft','controlled','retired') NOT NULL DEFAULT 'draft',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`variable_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `ilb_remedy_protocol` (
  `protocol_key` varchar(160) NOT NULL,
  `remedy_key` varchar(140) NOT NULL,
  `protocol_version` varchar(40) NOT NULL,
  `protocol_name` varchar(255) NOT NULL,
  `exposure_definition` varchar(2000) NOT NULL,
  `baseline_definition` varchar(1500) NOT NULL,
  `repeat_definition` varchar(1500) NOT NULL,
  `washout_definition` varchar(1500) DEFAULT NULL,
  `confounder_definition` varchar(1500) NOT NULL,
  `stop_rule` varchar(1500) NOT NULL,
  `minimum_repeats` int unsigned NOT NULL DEFAULT 1,
  `clinical_approval_required` tinyint(1) NOT NULL DEFAULT 0,
  `status` enum('draft','review','active','suspended','retired') NOT NULL DEFAULT 'draft',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`protocol_key`),
  UNIQUE KEY `uq_p50_protocol_version` (`remedy_key`,`protocol_version`),
  CONSTRAINT `fk_p50_protocol_remedy` FOREIGN KEY (`remedy_key`)
    REFERENCES `ilb_remedy_catalogue` (`remedy_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `ilb_remedy_protocol_variable` (
  `protocol_key` varchar(160) NOT NULL,
  `variable_key` varchar(140) NOT NULL,
  `protocol_role` enum('exposure','primary_response','secondary_response','confounder','safety','context') NOT NULL,
  `required_flag` tinyint(1) NOT NULL DEFAULT 1,
  `collection_timing` varchar(500) NOT NULL,
  PRIMARY KEY (`protocol_key`,`variable_key`,`protocol_role`),
  CONSTRAINT `fk_p50_pv_protocol` FOREIGN KEY (`protocol_key`)
    REFERENCES `ilb_remedy_protocol` (`protocol_key`),
  CONSTRAINT `fk_p50_pv_variable` FOREIGN KEY (`variable_key`)
    REFERENCES `ilb_remedy_variable` (`variable_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `ilb_personal_remedy_experiment` (
  `experiment_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `experiment_key` varchar(160) NOT NULL,
  `subject_key` varchar(100) NOT NULL,
  `protocol_key` varchar(160) NOT NULL,
  `consent_reference` varchar(160) NOT NULL,
  `started_at` datetime DEFAULT NULL,
  `ended_at` datetime DEFAULT NULL,
  `experiment_status` enum('planned','baseline','in_progress','washout','follow_up','completed','stopped','withdrawn') NOT NULL DEFAULT 'planned',
  `stop_reason` varchar(1500) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`experiment_id`),
  UNIQUE KEY `uq_p50_experiment_key` (`experiment_key`),
  KEY `idx_p50_experiment_subject` (`subject_key`,`experiment_status`),
  CONSTRAINT `fk_p50_experiment_protocol` FOREIGN KEY (`protocol_key`)
    REFERENCES `ilb_remedy_protocol` (`protocol_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `ilb_personal_remedy_observation` (
  `observation_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `experiment_id` bigint unsigned NOT NULL,
  `variable_key` varchar(140) NOT NULL,
  `phase` enum('baseline','intervention','washout','follow_up','safety_event') NOT NULL,
  `observed_at` datetime NOT NULL,
  `repeat_number` int unsigned NOT NULL DEFAULT 1,
  `truth_state` enum('PERSON_MEASURED','MATHEMATICALLY_DERIVED','UNKNOWN') NOT NULL,
  `numeric_value` decimal(30,12) DEFAULT NULL,
  `unit_code` varchar(80) DEFAULT NULL,
  `formula_key` varchar(160) DEFAULT NULL,
  `input_lineage_json` longtext DEFAULT NULL,
  `uncertainty_value` decimal(30,12) DEFAULT NULL,
  `uncertainty_unit` varchar(80) DEFAULT NULL,
  `measurement_method_key` varchar(160) DEFAULT NULL,
  `quality_status` enum('pending','usable','excluded','superseded') NOT NULL DEFAULT 'pending',
  `recorded_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`observation_id`),
  KEY `idx_p50_observation_experiment` (`experiment_id`,`variable_key`,`phase`,`observed_at`),
  CONSTRAINT `fk_p50_observation_experiment` FOREIGN KEY (`experiment_id`)
    REFERENCES `ilb_personal_remedy_experiment` (`experiment_id`),
  CONSTRAINT `fk_p50_observation_variable` FOREIGN KEY (`variable_key`)
    REFERENCES `ilb_remedy_variable` (`variable_key`),
  CONSTRAINT `chk_p50_observation_truth` CHECK (
    (`truth_state`='UNKNOWN' AND `numeric_value` IS NULL)
    OR (`truth_state` IN ('PERSON_MEASURED','MATHEMATICALLY_DERIVED') AND `numeric_value` IS NOT NULL)
  )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `ilb_remedy_verification_result` (
  `verification_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `experiment_id` bigint unsigned NOT NULL,
  `variable_key` varchar(140) NOT NULL,
  `calculation_version` varchar(40) NOT NULL,
  `baseline_n` int unsigned NOT NULL,
  `intervention_n` int unsigned NOT NULL,
  `baseline_value` decimal(30,12) DEFAULT NULL,
  `intervention_value` decimal(30,12) DEFAULT NULL,
  `absolute_change` decimal(30,12) DEFAULT NULL,
  `relative_change` decimal(30,12) DEFAULT NULL,
  `combined_uncertainty` decimal(30,12) DEFAULT NULL,
  `repeatability_value` decimal(30,12) DEFAULT NULL,
  `verification_status` enum('NOT_TESTABLE_YET','TEST_IN_PROGRESS','NO_MEASURABLE_EFFECT','PERSONAL_RESPONSE_OBSERVED','REPEATED_PERSONAL_RESPONSE','CONTRADICTORY','UNSAFE','REJECTED') NOT NULL,
  `calculation_json` longtext NOT NULL,
  `limitation_text` varchar(2000) NOT NULL,
  `calculated_at` datetime NOT NULL,
  PRIMARY KEY (`verification_id`),
  UNIQUE KEY `uq_p50_verification_version` (`experiment_id`,`variable_key`,`calculation_version`),
  CONSTRAINT `fk_p50_result_experiment` FOREIGN KEY (`experiment_id`)
    REFERENCES `ilb_personal_remedy_experiment` (`experiment_id`),
  CONSTRAINT `fk_p50_result_variable` FOREIGN KEY (`variable_key`)
    REFERENCES `ilb_remedy_variable` (`variable_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `ilb_remedy_system`
 (`remedy_system_key`,`system_name`,`system_class`,`description_text`,`verification_boundary`,`status`)
VALUES
 ('conventional','Conventional medicine','conventional','Medicines and clinician-controlled medical interventions.','Catalogue and measurement do not prescribe, diagnose, alter dose or replace clinical judgement.','catalogued'),
 ('rehabilitative','Rehabilitation and movement','rehabilitative','Physiotherapy, exercise and functional rehabilitation.','Only declared exposure and personal measured response may be verified.','catalogued'),
 ('behavioural','Behavioural and psychological practice','behavioural','Behavioural, cognitive, emotional and attention practices.','Human experience is preserved; no universal person score is permitted.','catalogued'),
 ('environmental','Environmental and sensory exposure','environmental','Light, sound, temperature, nature and other measurable exposures.','Exposure does not prove healing; intensity, duration and response must be measured.','catalogued'),
 ('nutritional','Food and nutrition','nutritional','Foods, nutrients and eating-pattern interventions.','Composition catalogues are scaffolding; personal intake and response require measurement.','catalogued'),
 ('complementary','Complementary practice','complementary','Complementary practices with measurable or definable exposure.','Claims remain unverified until a governed personal protocol produces repeatable measurements.','restricted'),
 ('traditional','Traditional and symbolic systems','traditional','Attributed traditional systems, including acupuncture, acupressure and authored mappings.','Reflection or hypothesis only; never anatomy truth, medical causation, diagnosis or cure.','restricted'),
 ('device','Device-mediated intervention','device','Interventions delivered through an identified device.','Device identity, calibration, settings, dose and safety controls are mandatory.','catalogued'),
 ('other','Other proposed remedy','other','A controlled holding class for proposed remedies not yet classified.','Remains NOT_TESTABLE_YET until variables, protocol, safety and measurement are declared.','restricted')
ON DUPLICATE KEY UPDATE
 `system_name`=VALUES(`system_name`),
 `system_class`=VALUES(`system_class`),
 `description_text`=VALUES(`description_text`),
 `verification_boundary`=VALUES(`verification_boundary`),
 `status`=VALUES(`status`);

DROP VIEW IF EXISTS `v_ilb_remedy_catalogue_contract`;
CREATE VIEW `v_ilb_remedy_catalogue_contract` AS
SELECT s.`remedy_system_key`,s.`system_name`,s.`system_class`,s.`verification_boundary`,
       r.`remedy_key`,r.`remedy_name`,r.`remedy_variant`,r.`proposed_target_text`,
       r.`claimed_mechanism_text`,r.`claim_attribution`,r.`clinical_control`,
       r.`catalogue_status`,r.`claim_truth_status`
FROM `ilb_remedy_system` s
JOIN `ilb_remedy_catalogue` r ON r.`remedy_system_key`=s.`remedy_system_key`
WHERE s.`status`<>'retired' AND r.`catalogue_status`<>'retired';

DROP VIEW IF EXISTS `v_ilb_remedy_experiment_readiness`;
CREATE VIEW `v_ilb_remedy_experiment_readiness` AS
SELECT p.`protocol_key`,p.`remedy_key`,p.`protocol_name`,p.`protocol_version`,p.`status`,
       COUNT(DISTINCT CASE WHEN pv.`protocol_role`='exposure' AND pv.`required_flag`=1 THEN pv.`variable_key` END) AS `required_exposure_variables`,
       COUNT(DISTINCT CASE WHEN pv.`protocol_role`='primary_response' AND pv.`required_flag`=1 THEN pv.`variable_key` END) AS `required_primary_responses`,
       COUNT(DISTINCT CASE WHEN pv.`protocol_role`='safety' AND pv.`required_flag`=1 THEN pv.`variable_key` END) AS `required_safety_variables`,
       CASE
         WHEN p.`status`<>'active' THEN 'NOT_TESTABLE_YET'
         WHEN COUNT(DISTINCT CASE WHEN pv.`protocol_role`='exposure' AND pv.`required_flag`=1 THEN pv.`variable_key` END)=0 THEN 'NOT_TESTABLE_YET'
         WHEN COUNT(DISTINCT CASE WHEN pv.`protocol_role`='primary_response' AND pv.`required_flag`=1 THEN pv.`variable_key` END)=0 THEN 'NOT_TESTABLE_YET'
         WHEN p.`stop_rule`='' OR p.`baseline_definition`='' OR p.`confounder_definition`='' THEN 'NOT_TESTABLE_YET'
         ELSE 'TESTABLE'
       END AS `readiness_status`
FROM `ilb_remedy_protocol` p
LEFT JOIN `ilb_remedy_protocol_variable` pv ON pv.`protocol_key`=p.`protocol_key`
GROUP BY p.`protocol_key`,p.`remedy_key`,p.`protocol_name`,p.`protocol_version`,p.`status`,
         p.`stop_rule`,p.`baseline_definition`,p.`confounder_definition`;

COMMIT;

SELECT COUNT(*) AS `remedy_systems` FROM `ilb_remedy_system` WHERE `status`<>'retired';
SELECT * FROM `v_ilb_remedy_experiment_readiness` ORDER BY `readiness_status`,`protocol_key`;
