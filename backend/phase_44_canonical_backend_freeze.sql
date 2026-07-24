-- Phase 44: canonical backend freeze and legacy isolation
-- Target: u756742628_ilovemybody
-- Prerequisites: Phases 42, 42B, 42C and 43.
-- Safe to rerun.
--
-- This migration does not delete evidence, references or participant data.
-- Superseded objects are removed from the frontend contract through an
-- explicit registry. Historical rows remain available for audit.

START TRANSACTION;

CREATE TABLE IF NOT EXISTS `ilb_backend_release` (
  `release_key` varchar(80) NOT NULL,
  `release_name` varchar(255) NOT NULL,
  `released_at` datetime NOT NULL,
  `schema_contract_version` varchar(40) NOT NULL,
  `content_contract_version` varchar(40) NOT NULL,
  `calculation_contract_version` varchar(40) NOT NULL,
  `release_note` varchar(2000) NOT NULL,
  `status` enum('candidate','frozen','superseded','withdrawn') NOT NULL DEFAULT 'candidate',
  PRIMARY KEY (`release_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `ilb_backend_object_registry` (
  `object_name` varchar(160) NOT NULL,
  `object_type` enum('table','view','formula','assessment','content_source','workflow') NOT NULL,
  `domain_key` varchar(80) NOT NULL,
  `canonical_role` varchar(500) NOT NULL,
  `frontend_access` enum('read_write_contract','read_contract','internal_only','blocked') NOT NULL,
  `lifecycle_status` enum('canonical','review','superseded','retired','blocked') NOT NULL,
  `replacement_object_name` varchar(160) DEFAULT NULL,
  `decision_note` varchar(2000) NOT NULL,
  `release_key` varchar(80) NOT NULL,
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`object_name`,`object_type`),
  KEY `idx_p44_registry_release` (`release_key`),
  KEY `idx_p44_registry_lifecycle` (`lifecycle_status`,`frontend_access`),
  CONSTRAINT `fk_p44_registry_release`
    FOREIGN KEY (`release_key`) REFERENCES `ilb_backend_release` (`release_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `ilb_backend_freeze_issue` (
  `issue_key` varchar(100) NOT NULL,
  `domain_key` varchar(80) NOT NULL,
  `issue_title` varchar(255) NOT NULL,
  `issue_detail` varchar(2000) NOT NULL,
  `resolution_rule` varchar(2000) NOT NULL,
  `severity` enum('information','review','blocker') NOT NULL,
  `blocks_frontend` tinyint(1) NOT NULL DEFAULT 0,
  `status` enum('open','resolved','accepted','retired') NOT NULL DEFAULT 'open',
  `resolved_at` datetime DEFAULT NULL,
  `resolution_note` varchar(2000) DEFAULT NULL,
  PRIMARY KEY (`issue_key`),
  KEY `idx_p44_issue_status` (`status`,`severity`,`blocks_frontend`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `ilb_reference_lifecycle` (
  `reference_id` bigint(20) unsigned NOT NULL,
  `lifecycle_status` enum('current','duplicate','superseded','retired','rejected') NOT NULL DEFAULT 'current',
  `canonical_reference_id` bigint(20) unsigned DEFAULT NULL,
  `frontend_visible` tinyint(1) NOT NULL DEFAULT 1,
  `decision_note` varchar(1500) NOT NULL DEFAULT 'Current stored reference.',
  `reviewed_by` varchar(100) DEFAULT NULL,
  `reviewed_at` datetime DEFAULT NULL,
  PRIMARY KEY (`reference_id`),
  KEY `idx_p44_reference_canonical` (`canonical_reference_id`),
  KEY `idx_p44_reference_visible` (`frontend_visible`,`lifecycle_status`),
  CONSTRAINT `fk_p44_reference_lifecycle_reference`
    FOREIGN KEY (`reference_id`) REFERENCES `ilb_reference` (`reference_id`),
  CONSTRAINT `fk_p44_reference_lifecycle_canonical`
    FOREIGN KEY (`canonical_reference_id`) REFERENCES `ilb_reference` (`reference_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `ilb_backend_release`
 (`release_key`,`release_name`,`released_at`,`schema_contract_version`,
  `content_contract_version`,`calculation_contract_version`,`release_note`,`status`)
VALUES
 ('ilb_backend_2026_07_24',
  'I Love My Body canonical participant backend',
  CURRENT_TIMESTAMP,'44.0','43.0','42C',
  'Freezes the participant route, PRE-10, ten dimensions, evidence provenance and seven-week journey contract. Legacy experiments are isolated from frontend use without deleting audit history.',
  'frozen')
ON DUPLICATE KEY UPDATE
 `release_name`=VALUES(`release_name`),
 `schema_contract_version`=VALUES(`schema_contract_version`),
 `content_contract_version`=VALUES(`content_contract_version`),
 `calculation_contract_version`=VALUES(`calculation_contract_version`),
 `release_note`=VALUES(`release_note`),
 `status`=VALUES(`status`);

-- Canonical contract exposed to the application.
INSERT INTO `ilb_backend_object_registry`
 (`object_name`,`object_type`,`domain_key`,`canonical_role`,`frontend_access`,
  `lifecycle_status`,`replacement_object_name`,`decision_note`,`release_key`)
VALUES
 ('ilb_subject','table','identity','Canonical participant identity.','read_write_contract','canonical',NULL,'Retain private identifiers behind access control.','ilb_backend_2026_07_24'),
 ('ilb_subject_consent_event','table','consent','Canonical consent and withdrawal history.','read_write_contract','canonical',NULL,'Consent is event based and never inferred.','ilb_backend_2026_07_24'),
 ('ilb_subject_document','table','medical_baseline','Canonical uploaded report and prescription record.','read_write_contract','canonical',NULL,'Extraction remains a draft until confirmed.','ilb_backend_2026_07_24'),
 ('ilb_subject_measurement','table','medical_baseline','Canonical confirmed clinical measurement.','read_write_contract','canonical',NULL,'Raw values and source documents remain primary.','ilb_backend_2026_07_24'),
 ('ilb_subject_medicine_report','table','medical_baseline','Canonical participant-reported medicine record.','read_write_contract','canonical',NULL,'No automated dose or discontinuation decision.','ilb_backend_2026_07_24'),
 ('ilb_human_state_snapshot','table','daily_observation','Canonical time-stamped human-state snapshot.','read_write_contract','canonical',NULL,'Optional participant observations; missingness is explicit.','ilb_backend_2026_07_24'),
 ('ilb_body_signal_event','table','daily_observation','Canonical body-signal observation.','read_write_contract','canonical',NULL,'Records the participant experience without assigning a cause.','ilb_backend_2026_07_24'),
 ('ilb_response_action_event','table','daily_observation','Canonical action following a signal or choice.','read_write_contract','canonical',NULL,'Supports before/after personal observation.','ilb_backend_2026_07_24'),
 ('ilb_pre10_dimension','table','pre10','Canonical ten connected dimensions.','read_contract','canonical',NULL,'The ten dimensions remain separate and are not collapsed into a diagnostic identity.','ilb_backend_2026_07_24'),
 ('ilb_pre10_assessment','table','pre10','Canonical assessment registry.','read_contract','canonical',NULL,'Validated instruments and original ILB discovery routes remain distinguishable.','ilb_backend_2026_07_24'),
 ('ilb_pre10_assessment_item','table','pre10','Canonical assessment item bank.','read_contract','canonical',NULL,'Wording, source and optionality are backend owned.','ilb_backend_2026_07_24'),
 ('ilb_pre10_enrollment','table','pre10','Canonical ten-day information-gathering enrollment.','read_write_contract','canonical',NULL,'PRE-10 precedes the first seven weeks.','ilb_backend_2026_07_24'),
 ('ilb_protocol_enrollment','table','journey','Canonical journey enrollment.','read_write_contract','canonical',NULL,'First seven weeks, reassessment, then optional second seven weeks.','ilb_backend_2026_07_24'),
 ('ilb_app_flow','table','application','Canonical backend-owned participant flow.','read_contract','canonical',NULL,'Frontend renders this contract and does not invent routes.','ilb_backend_2026_07_24'),
 ('ilb_app_step','table','application','Canonical ordered participant steps.','read_contract','canonical',NULL,'One current step is returned for one active enrollment.','ilb_backend_2026_07_24'),
 ('ilb_app_enrollment_state','table','application','Canonical current participant state.','read_write_contract','canonical',NULL,'The dashboard derives progress from this state.','ilb_backend_2026_07_24'),
 ('ilb_reference','table','evidence','Immutable bibliographic source catalogue.','internal_only','canonical',NULL,'References are never physically deleted merely because a newer source exists.','ilb_backend_2026_07_24'),
 ('ilb_reference_lifecycle','table','evidence','Canonical lifecycle filter for stored references.','internal_only','canonical',NULL,'Controls which sources reach the frontend while retaining audit history.','ilb_backend_2026_07_24'),
 ('ilb_claim','table','evidence','Canonical structured claim catalogue.','internal_only','canonical',NULL,'Claims retain scope, status and provenance.','ilb_backend_2026_07_24'),
 ('ilb_claim_reference','table','evidence','Canonical claim-to-source relationship.','internal_only','canonical',NULL,'Every participant-facing sourced explanation resolves through provenance.','ilb_backend_2026_07_24'),
 ('ilb_case_formula_definition','table','calculation','Canonical formula registry.','internal_only','canonical',NULL,'Only active, applicable formulas with complete inputs may execute.','ilb_backend_2026_07_24'),
 ('v_ilb_app_current_step','view','application','Canonical current-step read contract.','read_contract','canonical',NULL,'Primary route entry for the private application.','ilb_backend_2026_07_24'),
 ('v_ilb_backend_readiness','view','application','Canonical PRE-10 structural readiness contract.','internal_only','canonical',NULL,'Must contain no structural blockers for the active release.','ilb_backend_2026_07_24')
ON DUPLICATE KEY UPDATE
 `domain_key`=VALUES(`domain_key`),
 `canonical_role`=VALUES(`canonical_role`),
 `frontend_access`=VALUES(`frontend_access`),
 `lifecycle_status`=VALUES(`lifecycle_status`),
 `replacement_object_name`=VALUES(`replacement_object_name`),
 `decision_note`=VALUES(`decision_note`),
 `release_key`=VALUES(`release_key`);

-- Known early experiments are preserved but excluded from all frontend/API
-- contracts. This is the safe meaning of "remove old references".
INSERT INTO `ilb_backend_object_registry`
 (`object_name`,`object_type`,`domain_key`,`canonical_role`,`frontend_access`,
  `lifecycle_status`,`replacement_object_name`,`decision_note`,`release_key`)
VALUES
 ('hh_energy_centres','table','legacy','Early ten-label energy-centre experiment.','blocked','superseded','ilb_pre10_dimension','Not an authenticated Redikall point map and not the canonical ten-dimension model.','ilb_backend_2026_07_24'),
 ('hh_magicians','table','legacy','Early practitioner naming experiment.','blocked','retired',NULL,'The word magician is retired. Practitioner publication requires a reviewed mentor registry and explicit approval.','ilb_backend_2026_07_24'),
 ('hh_method','table','legacy','Early website-copy container.','blocked','superseded','ilb_app_flow','Frontend wording is now owned by the versioned application flow and content contracts.','ilb_backend_2026_07_24'),
 ('body_points','table','legacy','Unverified mixed point catalogue.','blocked','superseded','ilb_acupuncture_point','Mixed acupuncture, acupressure, marma and reflexology points cannot be treated as one standard.','ilb_backend_2026_07_24'),
 ('acupuncture_mappings','table','legacy','Unstructured organ-to-meridian experiment.','blocked','superseded','ilb_acupuncture_point','Use the sourced acupuncture point, claim and reference tables.','ilb_backend_2026_07_24'),
 ('acupressure_mappings','table','legacy','Unstructured acupressure experiment.','blocked','superseded','ilb_acupressure_protocol','Use sourced protocols, point links, sessions and responses.','ilb_backend_2026_07_24'),
 ('allopathy_mappings','table','legacy','Unstructured medical mapping experiment.','blocked','superseded','ilb_claim','Use structured claims, evidence, medicines, markers and references.','ilb_backend_2026_07_24'),
 ('ayurveda_mappings','table','legacy','Unstructured Ayurveda mapping experiment.','blocked','superseded','ilb_ayurveda_construct','Use the scoped Ayurveda construct and observation tables.','ilb_backend_2026_07_24'),
 ('homeopathy_mappings','table','legacy','Unstructured homeopathy mapping experiment.','blocked','retired',NULL,'Do not expose remedy mappings without a separately reviewed provenance and safety contract.','ilb_backend_2026_07_24'),
 ('domain_target_attainment','formula','legacy_calculation','Seven-domain target-attainment hypothesis.','blocked','superseded',NULL,'Superseded because the frozen model has ten dimensions and no universal target score.','ilb_backend_2026_07_24'),
 ('naive_alignment_geomean','formula','legacy_calculation','Seven-body combined alignment hypothesis.','blocked','retired',NULL,'A single combined human score is outside the frozen calculation boundary.','ilb_backend_2026_07_24')
ON DUPLICATE KEY UPDATE
 `canonical_role`=VALUES(`canonical_role`),
 `frontend_access`=VALUES(`frontend_access`),
 `lifecycle_status`=VALUES(`lifecycle_status`),
 `replacement_object_name`=VALUES(`replacement_object_name`),
 `decision_note`=VALUES(`decision_note`),
 `release_key`=VALUES(`release_key`);

-- Retire only the two known superseded formula definitions. No calculated
-- result or participant observation is deleted.
UPDATE `ilb_case_formula_definition`
SET `status`='retired'
WHERE `case_formula_key` IN ('domain_target_attainment','naive_alignment_geomean');

-- Existing references default to current. A duplicate/superseded decision must
-- be explicit and must identify its canonical replacement.
INSERT INTO `ilb_reference_lifecycle`
 (`reference_id`,`lifecycle_status`,`canonical_reference_id`,`frontend_visible`,
  `decision_note`,`reviewed_by`,`reviewed_at`)
SELECT r.`reference_id`,'current',NULL,1,
       'Retained as current until an explicit source-level review supersedes it.',
       'Phase 44 canonical freeze',CURRENT_TIMESTAMP
FROM `ilb_reference` r
WHERE NOT EXISTS (
  SELECT 1 FROM `ilb_reference_lifecycle` l
  WHERE l.`reference_id`=r.`reference_id`
);

INSERT INTO `ilb_backend_freeze_issue`
 (`issue_key`,`domain_key`,`issue_title`,`issue_detail`,`resolution_rule`,
  `severity`,`blocks_frontend`,`status`)
VALUES
 ('ipip_exact_version','pre10','Exact IPIP version is not frozen',
  'IPIP is registered, but one exact public-domain form, item order and scoring key must be selected before administration.',
  'Record the exact instrument/version, immutable item set, source URL and scoring key; then resolve this issue.',
  'blocker',1,'open'),
 ('acupuncture_361_catalogue','traditional_maps','The 361-point acupuncture catalogue is not yet verified complete',
  'The structured point schema exists, but completeness, coordinates, WHO provenance and safety review must be verified before map publication.',
  'Load and review all 361 standard points, attach source provenance, verify coordinates and activate only reviewed points.',
  'review',1,'open'),
 ('redikall_point_licence','traditional_maps','Aatmn/Redikall micro-points are not licensed or authenticated',
  'The early energy-centre rows are not a verified copy of Aatmn Parmar’s 250+ micro-point system.',
  'Obtain permission and ten authenticated point definitions for a pilot; store them as a separate sourced system.',
  'blocker',1,'open'),
 ('reference_deduplication','evidence','Reference deduplication requires source-level review',
  'Similar titles or URLs must not be automatically deleted because different versions, editions and roles may matter.',
  'Review candidate duplicates, select a canonical reference, repoint dependent links, then set lifecycle status to duplicate or superseded.',
  'review',0,'open')
ON DUPLICATE KEY UPDATE
 `domain_key`=VALUES(`domain_key`),
 `issue_title`=VALUES(`issue_title`),
 `issue_detail`=VALUES(`issue_detail`),
 `resolution_rule`=VALUES(`resolution_rule`),
 `severity`=VALUES(`severity`),
 `blocks_frontend`=VALUES(`blocks_frontend`);

DROP VIEW IF EXISTS `v_ilb_frontend_object_contract`;
CREATE VIEW `v_ilb_frontend_object_contract` AS
SELECT `object_name`,`object_type`,`domain_key`,`canonical_role`,
       `frontend_access`,`decision_note`,`release_key`
FROM `ilb_backend_object_registry`
WHERE `lifecycle_status`='canonical'
  AND `frontend_access` IN ('read_write_contract','read_contract');

DROP VIEW IF EXISTS `v_ilb_active_reference_catalog`;
CREATE VIEW `v_ilb_active_reference_catalog` AS
SELECT r.*
FROM `ilb_reference` r
JOIN `ilb_reference_lifecycle` l
  ON l.`reference_id`=r.`reference_id`
WHERE l.`lifecycle_status`='current'
  AND l.`frontend_visible`=1;

DROP VIEW IF EXISTS `v_ilb_formula_freeze_status`;
CREATE VIEW `v_ilb_formula_freeze_status` AS
SELECT f.`case_formula_key`,f.`formula_name`,f.`formula_class`,
       f.`expression_text`,f.`meaning_text`,f.`limitation_text`,
       f.`minimum_observations`,f.`status`,
       COUNT(i.`input_key`) AS `declared_inputs`,
       SUM(i.`required_flag`=1) AS `required_inputs`,
       CASE
         WHEN f.`status`='active' AND COUNT(i.`input_key`)>0 THEN 'available_when_inputs_exist'
         WHEN f.`status`='retired' THEN 'retired'
         ELSE 'not_frontend_executable'
       END AS `execution_state`
FROM `ilb_case_formula_definition` f
LEFT JOIN `ilb_case_formula_input` i
  ON i.`case_formula_key`=f.`case_formula_key`
GROUP BY f.`case_formula_key`,f.`formula_name`,f.`formula_class`,
         f.`expression_text`,f.`meaning_text`,f.`limitation_text`,
         f.`minimum_observations`,f.`status`;

DROP VIEW IF EXISTS `v_ilb_backend_freeze_status`;
CREATE VIEW `v_ilb_backend_freeze_status` AS
SELECT r.`release_key`,r.`release_name`,r.`status` AS `release_status`,
       SUM(o.`lifecycle_status`='canonical') AS `canonical_objects`,
       SUM(o.`lifecycle_status` IN ('superseded','retired')) AS `isolated_legacy_objects`,
       (SELECT COUNT(*) FROM `ilb_backend_freeze_issue` i
         WHERE i.`status`='open' AND i.`blocks_frontend`=1) AS `open_frontend_blockers`,
       (SELECT COUNT(*) FROM `ilb_reference_lifecycle` l
         WHERE l.`lifecycle_status`='current' AND l.`frontend_visible`=1) AS `current_visible_references`
FROM `ilb_backend_release` r
LEFT JOIN `ilb_backend_object_registry` o
  ON o.`release_key`=r.`release_key`
WHERE r.`release_key`='ilb_backend_2026_07_24'
GROUP BY r.`release_key`,r.`release_name`,r.`status`;

COMMIT;

SELECT * FROM `v_ilb_backend_freeze_status`;
SELECT * FROM `ilb_backend_freeze_issue`
WHERE `status`='open'
ORDER BY `blocks_frontend` DESC, FIELD(`severity`,'blocker','review','information'),`issue_key`;
SELECT * FROM `v_ilb_formula_freeze_status`
ORDER BY FIELD(`execution_state`,'available_when_inputs_exist','not_frontend_executable','retired'),
         `case_formula_key`;
