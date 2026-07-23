-- Phase 42C: PRE-10 calculation, provenance and readiness contract
-- Target: u756742628_ilovemybody
-- Prerequisites: Phase 42 and Phase 42B.
--
-- This migration makes the PRE-10 backend operational without inventing a
-- single "human", "health" or "energy" score. It calculates only:
--   1. response completeness;
--   2. item-level normalization where a declared numeric scale exists;
--   3. validated/imported scores already calculated under their own rules;
--   4. coverage of the ten connected dimensions.
-- Every calculated result retains its method and source boundary.
-- Safe to rerun. No patient-authored response is deleted or overwritten.

START TRANSACTION;

CREATE TABLE IF NOT EXISTS `ilb_pre10_result_definition` (
  `result_definition_key` varchar(160) NOT NULL,
  `assessment_key` varchar(100) DEFAULT NULL,
  `result_type` enum(
    'completion','item_normalization','validated_score',
    'dimension_coverage','descriptive_only'
  ) NOT NULL,
  `display_name` varchar(255) NOT NULL,
  `expression_text` varchar(1500) NOT NULL,
  `output_min` decimal(20,8) DEFAULT NULL,
  `output_max` decimal(20,8) DEFAULT NULL,
  `output_unit` varchar(80) DEFAULT NULL,
  `higher_value_meaning` varchar(1000) NOT NULL,
  `patient_language_rule` varchar(1500) NOT NULL,
  `interpretation_boundary` varchar(1500) NOT NULL,
  `source_reference_id` bigint(20) unsigned DEFAULT NULL,
  `status` enum('draft','review','active','retired') NOT NULL DEFAULT 'review',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`result_definition_key`),
  KEY `idx_p42c_definition_assessment` (`assessment_key`),
  KEY `idx_p42c_definition_reference` (`source_reference_id`),
  CONSTRAINT `fk_p42c_definition_assessment`
    FOREIGN KEY (`assessment_key`) REFERENCES `ilb_pre10_assessment` (`assessment_key`),
  CONSTRAINT `fk_p42c_definition_reference`
    FOREIGN KEY (`source_reference_id`) REFERENCES `ilb_reference` (`reference_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `ilb_pre10_calculation_audit` (
  `calculation_audit_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `pre10_enrollment_id` bigint(20) unsigned NOT NULL,
  `pre10_session_id` bigint(20) unsigned DEFAULT NULL,
  `result_definition_key` varchar(160) NOT NULL,
  `calculated_at` datetime NOT NULL,
  `input_cutoff_at` datetime NOT NULL,
  `input_count` int(10) unsigned NOT NULL,
  `calculation_status` enum('calculated','not_enough_data','blocked','superseded') NOT NULL,
  `output_value` decimal(20,8) DEFAULT NULL,
  `calculation_json` longtext DEFAULT NULL,
  `quality_note` varchar(1500) NOT NULL,
  PRIMARY KEY (`calculation_audit_id`),
  KEY `idx_p42c_audit_enrollment` (`pre10_enrollment_id`,`calculated_at`),
  KEY `idx_p42c_audit_session` (`pre10_session_id`),
  KEY `idx_p42c_audit_definition` (`result_definition_key`),
  CONSTRAINT `fk_p42c_audit_enrollment`
    FOREIGN KEY (`pre10_enrollment_id`) REFERENCES `ilb_pre10_enrollment` (`pre10_enrollment_id`),
  CONSTRAINT `fk_p42c_audit_session`
    FOREIGN KEY (`pre10_session_id`) REFERENCES `ilb_pre10_session` (`pre10_session_id`),
  CONSTRAINT `fk_p42c_audit_definition`
    FOREIGN KEY (`result_definition_key`) REFERENCES `ilb_pre10_result_definition` (`result_definition_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `ilb_pre10_result_definition`
 (`result_definition_key`,`assessment_key`,`result_type`,`display_name`,
  `expression_text`,`output_min`,`output_max`,`output_unit`,
  `higher_value_meaning`,`patient_language_rule`,`interpretation_boundary`,
  `source_reference_id`,`status`)
VALUES
 ('pre10:assessment_completion',NULL,'completion','Assessment information available',
  '100 * answered_or_boundary_items / active_stored_items',
  0,100,'percent',
  'More of the assessment has a recorded answer or an explicit privacy boundary.',
  'Describe information availability only. Thank the participant; never grade effort or cooperation.',
  'Completion is not health, happiness, honesty, worth, readiness or treatment success.',
  NULL,'active'),
 ('pre10:item_normalization',NULL,'item_normalization','Item response position',
  '100 * (numeric_value - scale_min) / (scale_max - scale_min)',
  0,100,'percent_of_declared_scale',
  'More of the exact wording asked by that item. Direction differs by item.',
  'Repeat the item wording beside the number so direction cannot be mistaken.',
  'Item normalization does not make different questions equivalent and must not be averaged into a person score.',
  NULL,'active'),
 ('pre10:dimension_coverage',NULL,'dimension_coverage','Dimension information available',
  '100 * submitted_mapped_assessments / mapped_assessments',
  0,100,'percent',
  'More mapped assessments have been submitted for this dimension.',
  'Use “we have more information about…” rather than “you are better/worse in…”.',
  'Coverage measures data availability only; it is not the condition, quality or energy of a dimension.',
  NULL,'active')
ON DUPLICATE KEY UPDATE
 `display_name`=VALUES(`display_name`),
 `expression_text`=VALUES(`expression_text`),
 `output_min`=VALUES(`output_min`),
 `output_max`=VALUES(`output_max`),
 `output_unit`=VALUES(`output_unit`),
 `higher_value_meaning`=VALUES(`higher_value_meaning`),
 `patient_language_rule`=VALUES(`patient_language_rule`),
 `interpretation_boundary`=VALUES(`interpretation_boundary`),
 `status`=VALUES(`status`);

INSERT INTO `ilb_pre10_result_definition`
 (`result_definition_key`,`assessment_key`,`result_type`,`display_name`,
  `expression_text`,`output_min`,`output_max`,`output_unit`,
  `higher_value_meaning`,`patient_language_rule`,`interpretation_boundary`,
  `source_reference_id`,`status`)
SELECT
 CONCAT('pre10:validated:',a.`assessment_key`),
 a.`assessment_key`,
 'validated_score',
 CONCAT(a.`patient_name`,' — source-defined result'),
 COALESCE(a.`scoring_method`,'Calculated or imported under the named source/version rules.'),
 NULL,NULL,NULL,
 'Defined only by the named instrument and version.',
 a.`result_rule`,
 CONCAT('Keep this result separate from ILB discovery responses. ',a.`purpose_text`),
 a.`source_reference_id`,
 'active'
FROM `ilb_pre10_assessment` a
WHERE a.`assessment_class`='validated'
ON DUPLICATE KEY UPDATE
 `display_name`=VALUES(`display_name`),
 `expression_text`=VALUES(`expression_text`),
 `patient_language_rule`=VALUES(`patient_language_rule`),
 `interpretation_boundary`=VALUES(`interpretation_boundary`),
 `source_reference_id`=VALUES(`source_reference_id`),
 `status`=VALUES(`status`);

DROP VIEW IF EXISTS `v_ilb_pre10_latest_response`;
CREATE VIEW `v_ilb_pre10_latest_response` AS
SELECT r.*
FROM `ilb_pre10_response` r
JOIN (
  SELECT `pre10_session_id`,`item_id`,MAX(`revision_number`) AS `latest_revision`
  FROM `ilb_pre10_response`
  WHERE `response_status`<>'withdrawn'
  GROUP BY `pre10_session_id`,`item_id`
) latest
  ON latest.`pre10_session_id`=r.`pre10_session_id`
 AND latest.`item_id`=r.`item_id`
 AND latest.`latest_revision`=r.`revision_number`
WHERE r.`response_status`<>'withdrawn';

DROP VIEW IF EXISTS `v_ilb_pre10_assessment_progress`;
CREATE VIEW `v_ilb_pre10_assessment_progress` AS
SELECT
 s.`pre10_enrollment_id`,
 s.`pre10_session_id`,
 s.`assessment_key`,
 a.`patient_name`,
 s.`day_number`,
 s.`completion_status`,
 COUNT(DISTINCT i.`item_id`) AS `active_items`,
 COUNT(DISTINCT CASE
   WHEN r.`response_status` IN ('answered','skipped','prefer_not_to_answer')
   THEN i.`item_id` END) AS `items_with_recorded_choice`,
 ROUND(
   100 * COUNT(DISTINCT CASE
     WHEN r.`response_status` IN ('answered','skipped','prefer_not_to_answer')
     THEN i.`item_id` END)
   / NULLIF(COUNT(DISTINCT i.`item_id`),0), 2
 ) AS `information_available_percent`,
 MAX(CASE WHEN i.`safety_relevant`=1 AND r.`response_status`='answered' THEN 1 ELSE 0 END)
   AS `has_answered_safety_relevant_item`
FROM `ilb_pre10_session` s
JOIN `ilb_pre10_assessment` a ON a.`assessment_key`=s.`assessment_key`
LEFT JOIN `ilb_pre10_item` i
  ON i.`assessment_key`=s.`assessment_key` AND i.`status`='active'
LEFT JOIN `v_ilb_pre10_latest_response` r
  ON r.`pre10_session_id`=s.`pre10_session_id` AND r.`item_id`=i.`item_id`
GROUP BY
 s.`pre10_enrollment_id`,s.`pre10_session_id`,s.`assessment_key`,
 a.`patient_name`,s.`day_number`,s.`completion_status`;

DROP VIEW IF EXISTS `v_ilb_pre10_item_result`;
CREATE VIEW `v_ilb_pre10_item_result` AS
SELECT
 s.`pre10_enrollment_id`,
 r.`pre10_session_id`,
 i.`assessment_key`,
 i.`item_id`,
 i.`item_key`,
 i.`question_text`,
 r.`numeric_value` AS `raw_value`,
 CASE
   WHEN i.`response_type`='scale'
    AND i.`scale_min` IS NOT NULL
    AND i.`scale_max` IS NOT NULL
    AND i.`scale_max`>i.`scale_min`
    AND r.`numeric_value` IS NOT NULL
   THEN ROUND(100 * (r.`numeric_value`-i.`scale_min`)
                   / (i.`scale_max`-i.`scale_min`),2)
   ELSE NULL
 END AS `normalized_value`,
 i.`scale_low_label`,
 i.`scale_high_label`,
 'A higher value means more of this question’s exact wording; it is not inherently better or worse.'
   AS `interpretation_boundary`,
 r.`answered_at`
FROM `v_ilb_pre10_latest_response` r
JOIN `ilb_pre10_session` s ON s.`pre10_session_id`=r.`pre10_session_id`
JOIN `ilb_pre10_item` i ON i.`item_id`=r.`item_id`
WHERE r.`response_status`='answered';

DROP VIEW IF EXISTS `v_ilb_pre10_dimension_coverage`;
CREATE VIEW `v_ilb_pre10_dimension_coverage` AS
SELECT
 e.`pre10_enrollment_id`,
 d.`dimension_key`,
 d.`dimension_order`,
 d.`dimension_name`,
 COUNT(DISTINCT ad.`assessment_key`) AS `mapped_assessments`,
 COUNT(DISTINCT CASE WHEN s.`completion_status`='submitted' THEN s.`assessment_key` END)
   AS `submitted_assessments`,
 ROUND(
   100 * COUNT(DISTINCT CASE WHEN s.`completion_status`='submitted' THEN s.`assessment_key` END)
   / NULLIF(COUNT(DISTINCT ad.`assessment_key`),0), 2
 ) AS `information_available_percent`,
 'Coverage measures information availability, not health, worth, happiness or energy.'
   AS `interpretation_boundary`
FROM `ilb_pre10_enrollment` e
CROSS JOIN `ilb_pre10_dimension` d
LEFT JOIN `ilb_pre10_assessment_dimension` ad
  ON ad.`dimension_key`=d.`dimension_key`
LEFT JOIN `ilb_pre10_session` s
  ON s.`pre10_enrollment_id`=e.`pre10_enrollment_id`
 AND s.`assessment_key`=ad.`assessment_key`
WHERE d.`status`='active'
GROUP BY
 e.`pre10_enrollment_id`,d.`dimension_key`,d.`dimension_order`,d.`dimension_name`;

DROP VIEW IF EXISTS `v_ilb_pre10_source_catalog`;
CREATE VIEW `v_ilb_pre10_source_catalog` AS
SELECT
 a.`assessment_key`,
 a.`assessment_name`,
 a.`assessment_class`,
 a.`construct_key`,
 a.`source_label`,
 a.`source_url`,
 a.`version_label`,
 a.`scoring_method`,
 a.`result_rule`,
 a.`diagnostic_status`,
 r.`reference_id`,
 r.`reference_type`,
 r.`title` AS `reference_title`,
 r.`authors_or_group`,
 r.`publisher_or_journal`,
 r.`publication_year`,
 r.`canonical_url`,
 r.`quality_status`,
 r.`status` AS `reference_status`
FROM `ilb_pre10_assessment` a
LEFT JOIN `ilb_reference` r ON r.`reference_id`=a.`source_reference_id`;

DROP VIEW IF EXISTS `v_ilb_formula_source_catalog`;
CREATE VIEW `v_ilb_formula_source_catalog` AS
SELECT
 f.`formula_key`,
 f.`name` AS `formula_name`,
 f.`expression`,
 f.`input_markers`,
 f.`output_unit`,
 f.`what_it_means`,
 f.`reference_note`,
 f.`status` AS `formula_status`,
 fr.`support_role`,
 fr.`note` AS `formula_reference_note`,
 r.`reference_id`,
 r.`title` AS `reference_title`,
 r.`authors_or_group`,
 r.`publisher_or_journal`,
 r.`publication_year`,
 r.`canonical_url`,
 r.`quality_status`,
 r.`status` AS `reference_status`
FROM `ilb_formula` f
LEFT JOIN `ilb_formula_reference` fr ON fr.`formula_key`=f.`formula_key`
LEFT JOIN `ilb_reference` r ON r.`reference_id`=fr.`reference_id`;

DROP VIEW IF EXISTS `v_ilb_backend_readiness`;
CREATE VIEW `v_ilb_backend_readiness` AS
SELECT 'pre10_dimensions' AS `check_key`,
       COUNT(*) AS `actual_count`,10 AS `minimum_count`,
       CASE WHEN COUNT(*)>=10 THEN 'ready' ELSE 'blocked' END AS `readiness_status`
FROM `ilb_pre10_dimension` WHERE `status`='active'
UNION ALL
SELECT 'pre10_days',COUNT(*),10,CASE WHEN COUNT(*)>=10 THEN 'ready' ELSE 'blocked' END
FROM `ilb_pre10_day`
WHERE `plan_key`='pre10_clarity' AND `version_label`='1.0'
UNION ALL
SELECT 'pre10_assessments',COUNT(*),18,CASE WHEN COUNT(*)>=18 THEN 'ready' ELSE 'blocked' END
FROM `ilb_pre10_assessment` WHERE `status`='active'
UNION ALL
SELECT 'pre10_items',COUNT(*),70,CASE WHEN COUNT(*)>=70 THEN 'ready' ELSE 'blocked' END
FROM `ilb_pre10_item` WHERE `status`='active'
UNION ALL
SELECT 'choice_options',COUNT(*),150,CASE WHEN COUNT(*)>=150 THEN 'ready' ELSE 'blocked' END
FROM `ilb_pre10_option`
UNION ALL
SELECT 'source_linked_validated_assessments',
       COUNT(*),4,CASE WHEN COUNT(*)>=4 THEN 'ready' ELSE 'blocked' END
FROM `ilb_pre10_assessment`
WHERE `assessment_class`='validated' AND `source_reference_id` IS NOT NULL
UNION ALL
SELECT 'stored_scientific_formulas',COUNT(*),12,
       CASE WHEN COUNT(*)>=12 THEN 'ready' ELSE 'blocked' END
FROM `ilb_formula`
UNION ALL
SELECT 'formula_reference_links',COUNT(*),12,
       CASE WHEN COUNT(*)>=12 THEN 'ready' ELSE 'blocked' END
FROM `ilb_formula_reference`;

COMMIT;

-- Verification returns structure only; never patient-authored data.
SELECT * FROM `v_ilb_backend_readiness` ORDER BY `check_key`;
SELECT COUNT(*) AS `pre10_result_definitions` FROM `ilb_pre10_result_definition`
WHERE `status`='active';
SELECT COUNT(*) AS `pre10_source_catalog_rows` FROM `v_ilb_pre10_source_catalog`;
SELECT COUNT(*) AS `formula_source_catalog_rows` FROM `v_ilb_formula_source_catalog`;
