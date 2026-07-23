-- Phase 43: backend-driven application flow
-- Target: u756742628_ilovemybody
-- Prerequisites: Phases 42, 42B and 42C.
-- The frontend is a renderer. It must not own sequence, wording, storage
-- destinations, calculation rules, evidence rules or safety rules.
-- Safe to rerun. No existing patient record is changed.

START TRANSACTION;

CREATE TABLE IF NOT EXISTS `ilb_app_pathway` (
  `pathway_key` varchar(80) NOT NULL,
  `display_order` tinyint(3) unsigned NOT NULL,
  `button_text` varchar(255) NOT NULL,
  `acknowledgement_text` varchar(700) NOT NULL,
  `scope_text` varchar(1200) NOT NULL,
  `allows_multiple` tinyint(1) NOT NULL DEFAULT 1,
  `status` enum('draft','review','active','retired') NOT NULL DEFAULT 'review',
  PRIMARY KEY (`pathway_key`),
  UNIQUE KEY `uq_p43_pathway_order` (`display_order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `ilb_app_flow` (
  `flow_key` varchar(80) NOT NULL,
  `version_label` varchar(40) NOT NULL,
  `flow_name` varchar(255) NOT NULL,
  `purpose_text` varchar(1500) NOT NULL,
  `entry_step_key` varchar(100) NOT NULL,
  `frontend_rule` varchar(1500) NOT NULL,
  `status` enum('draft','review','active','retired') NOT NULL DEFAULT 'review',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`flow_key`,`version_label`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `ilb_app_step` (
  `flow_key` varchar(80) NOT NULL,
  `version_label` varchar(40) NOT NULL,
  `step_key` varchar(100) NOT NULL,
  `step_order` smallint(5) unsigned NOT NULL,
  `phase_key` enum(
    'entry','consent','medical_baseline','pre10','clarity_map',
    'journey_1','reassessment','journey_2','continuing'
  ) NOT NULL,
  `screen_type` enum(
    'pathway_choice','consent','profile_form','document_upload',
    'medicine_capture','review_confirmation','assessment_route',
    'result_review','mentor_preference','journey_dashboard',
    'reassessment','completion'
  ) NOT NULL,
  `eyebrow_text` varchar(160) DEFAULT NULL,
  `title_text` varchar(500) NOT NULL,
  `instruction_text` varchar(1500) NOT NULL,
  `primary_action_text` varchar(200) NOT NULL,
  `secondary_action_text` varchar(200) DEFAULT NULL,
  `data_owner` varchar(100) NOT NULL,
  `read_contract` varchar(500) NOT NULL,
  `write_contract` varchar(500) NOT NULL,
  `completion_rule` varchar(1500) NOT NULL,
  `next_step_key` varchar(100) DEFAULT NULL,
  `back_step_key` varchar(100) DEFAULT NULL,
  `is_optional` tinyint(1) NOT NULL DEFAULT 0,
  `requires_authentication` tinyint(1) NOT NULL DEFAULT 1,
  `requires_consent` tinyint(1) NOT NULL DEFAULT 1,
  `safety_boundary` varchar(1500) NOT NULL,
  `status` enum('draft','review','active','retired') NOT NULL DEFAULT 'review',
  PRIMARY KEY (`flow_key`,`version_label`,`step_key`),
  UNIQUE KEY `uq_p43_step_order` (`flow_key`,`version_label`,`step_order`),
  CONSTRAINT `fk_p43_step_flow`
    FOREIGN KEY (`flow_key`,`version_label`)
    REFERENCES `ilb_app_flow` (`flow_key`,`version_label`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `ilb_app_step_pathway` (
  `flow_key` varchar(80) NOT NULL,
  `version_label` varchar(40) NOT NULL,
  `step_key` varchar(100) NOT NULL,
  `pathway_key` varchar(80) NOT NULL,
  `requirement_level` enum('required','recommended','optional','conditional') NOT NULL,
  `condition_text` varchar(1000) DEFAULT NULL,
  PRIMARY KEY (`flow_key`,`version_label`,`step_key`,`pathway_key`),
  CONSTRAINT `fk_p43_step_pathway_step`
    FOREIGN KEY (`flow_key`,`version_label`,`step_key`)
    REFERENCES `ilb_app_step` (`flow_key`,`version_label`,`step_key`),
  CONSTRAINT `fk_p43_step_pathway_path`
    FOREIGN KEY (`pathway_key`) REFERENCES `ilb_app_pathway` (`pathway_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `ilb_subject_pathway` (
  `subject_pathway_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `subject_key` varchar(80) NOT NULL,
  `pathway_key` varchar(80) NOT NULL,
  `selected_at` datetime NOT NULL,
  `priority_order` tinyint(3) unsigned NOT NULL DEFAULT 1,
  `participant_wording` varchar(1000) DEFAULT NULL,
  `status` enum('selected','paused','completed','withdrawn') NOT NULL DEFAULT 'selected',
  PRIMARY KEY (`subject_pathway_id`),
  UNIQUE KEY `uq_p43_subject_pathway` (`subject_key`,`pathway_key`,`status`),
  CONSTRAINT `fk_p43_subject_pathway_subject`
    FOREIGN KEY (`subject_key`) REFERENCES `ilb_subject` (`subject_key`),
  CONSTRAINT `fk_p43_subject_pathway_path`
    FOREIGN KEY (`pathway_key`) REFERENCES `ilb_app_pathway` (`pathway_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `ilb_app_enrollment_state` (
  `app_enrollment_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `subject_key` varchar(80) NOT NULL,
  `flow_key` varchar(80) NOT NULL,
  `version_label` varchar(40) NOT NULL,
  `current_step_key` varchar(100) NOT NULL,
  `pre10_enrollment_id` bigint(20) unsigned DEFAULT NULL,
  `protocol_enrollment_id` bigint(20) unsigned DEFAULT NULL,
  `journey_cycle` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `started_at` datetime NOT NULL,
  `last_activity_at` datetime DEFAULT NULL,
  `completed_at` datetime DEFAULT NULL,
  `status` enum('draft','active','paused','completed','withdrawn') NOT NULL DEFAULT 'draft',
  PRIMARY KEY (`app_enrollment_id`),
  UNIQUE KEY `uq_p43_active_flow` (`subject_key`,`flow_key`,`version_label`,`status`),
  KEY `idx_p43_state_pre10` (`pre10_enrollment_id`),
  KEY `idx_p43_state_protocol` (`protocol_enrollment_id`),
  CONSTRAINT `fk_p43_state_subject`
    FOREIGN KEY (`subject_key`) REFERENCES `ilb_subject` (`subject_key`),
  CONSTRAINT `fk_p43_state_step`
    FOREIGN KEY (`flow_key`,`version_label`,`current_step_key`)
    REFERENCES `ilb_app_step` (`flow_key`,`version_label`,`step_key`),
  CONSTRAINT `fk_p43_state_pre10`
    FOREIGN KEY (`pre10_enrollment_id`)
    REFERENCES `ilb_pre10_enrollment` (`pre10_enrollment_id`),
  CONSTRAINT `fk_p43_state_protocol`
    FOREIGN KEY (`protocol_enrollment_id`)
    REFERENCES `ilb_protocol_enrollment` (`enrollment_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `ilb_app_step_event` (
  `step_event_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `app_enrollment_id` bigint(20) unsigned NOT NULL,
  `step_key` varchar(100) NOT NULL,
  `event_type` enum(
    'opened','saved','submitted','completed','skipped',
    'returned','blocked','withdrawn'
  ) NOT NULL,
  `occurred_at` datetime NOT NULL,
  `payload_schema_version` varchar(40) NOT NULL DEFAULT '1.0',
  `storage_receipt_json` longtext DEFAULT NULL,
  `validation_status` enum('not_checked','valid','invalid','review_required') NOT NULL DEFAULT 'not_checked',
  `validation_note` varchar(1500) DEFAULT NULL,
  PRIMARY KEY (`step_event_id`),
  KEY `idx_p43_event_enrollment` (`app_enrollment_id`,`occurred_at`),
  CONSTRAINT `fk_p43_event_enrollment`
    FOREIGN KEY (`app_enrollment_id`)
    REFERENCES `ilb_app_enrollment_state` (`app_enrollment_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `ilb_app_pathway`
 (`pathway_key`,`display_order`,`button_text`,`acknowledgement_text`,
  `scope_text`,`allows_multiple`,`status`)
VALUES
 ('illness',1,'I have an illness',
  'Let us begin with your reports, medicines and what your body is experiencing.',
  'For a diagnosed or ongoing illness and post-operative recovery, alongside existing medical treatment.',1,'active'),
 ('stress',2,'I am anxious, tense or stressed',
  'Let us understand what is creating pressure and how it appears across your body and life.',
  'For anxiety, tension, stress and related preventive support; this selection is not a diagnosis.',1,'active'),
 ('addiction',3,'I am addicted',
  'Thank you for saying it directly. We will begin without judgement.',
  'For substance or behavioural dependence, urges, repeated comfort-seeking and recovery support; urgent withdrawal or safety needs require qualified medical help.',1,'active'),
 ('direction',4,'I am lost and seeking direction',
  'Let us understand your strengths, values, present reality and what may give your ability a meaningful direction.',
  'For purpose, work, relationships, confidence, identity, dreams and direction without assigning a personality label.',1,'active')
ON DUPLICATE KEY UPDATE
 `display_order`=VALUES(`display_order`),
 `button_text`=VALUES(`button_text`),
 `acknowledgement_text`=VALUES(`acknowledgement_text`),
 `scope_text`=VALUES(`scope_text`),
 `allows_multiple`=VALUES(`allows_multiple`),
 `status`=VALUES(`status`);

INSERT INTO `ilb_app_flow`
 (`flow_key`,`version_label`,`flow_name`,`purpose_text`,`entry_step_key`,
  `frontend_rule`,`status`)
VALUES
 ('participant_journey','1.0','I Love My Body participant journey',
  'One backend-owned route from reason for arrival through medical baseline, PRE-10, the first seven-week journey, reassessment and an optional second seven-week journey.',
  'reason_for_arrival',
  'The frontend renders the current backend step, requests its read contract, submits only to its write contract, and displays backend-returned wording, validation, evidence and next-step state. It must not duplicate business logic.',
  'active')
ON DUPLICATE KEY UPDATE
 `flow_name`=VALUES(`flow_name`),
 `purpose_text`=VALUES(`purpose_text`),
 `entry_step_key`=VALUES(`entry_step_key`),
 `frontend_rule`=VALUES(`frontend_rule`),
 `status`=VALUES(`status`);

INSERT INTO `ilb_app_step`
 (`flow_key`,`version_label`,`step_key`,`step_order`,`phase_key`,`screen_type`,
  `eyebrow_text`,`title_text`,`instruction_text`,`primary_action_text`,
  `secondary_action_text`,`data_owner`,`read_contract`,`write_contract`,
  `completion_rule`,`next_step_key`,`back_step_key`,`is_optional`,
  `requires_authentication`,`requires_consent`,`safety_boundary`,`status`)
VALUES
 ('participant_journey','1.0','reason_for_arrival',10,'entry','pathway_choice',
  'Begin here','Why are you here?',
  'Select one or more. Your answer begins the route; it does not define you.',
  'Continue',NULL,'ilb_subject_pathway',
  'v_ilb_app_active_pathway','ilb_subject_pathway',
  'At least one active pathway is selected.','privacy_and_consent',NULL,0,0,0,
  'This is route selection, not diagnosis or emergency triage.','active'),

 ('participant_journey','1.0','privacy_and_consent',20,'consent','consent',
  'Your information','Your permission comes first.',
  'Review what is collected, why it is used, who may see it, and how you can withdraw.',
  'Review and choose','Leave for now','ilb_subject_consent_event',
  'consent policy plus latest consent state','ilb_subject_consent_event',
  'The required current consent events are explicitly recorded.','basic_profile','reason_for_arrival',0,1,0,
  'No participation or analysis proceeds from implied consent.','active'),

 ('participant_journey','1.0','basic_profile',30,'medical_baseline','profile_form',
  'About you','Tell us the essentials.',
  'Add the basic information needed to understand reports and calculate only applicable medical formulas.',
  'Save and continue','Save for later','ilb_subject + ilb_subject_profile',
  'subject profile contract','ilb_subject_profile',
  'Required identity-separated profile fields are present.','medical_history','privacy_and_consent',0,1,1,
  'Private identity remains separated from frontend aliases and analytical records.','active'),

 ('participant_journey','1.0','medical_history',40,'medical_baseline','profile_form',
  'Medical starting point','What should we understand about your health?',
  'Record diagnosed conditions, operations, current symptoms and relevant history in your own words.',
  'Save and continue','I will add this later','ilb_subject_condition_report',
  'condition and operation history contract','ilb_subject_condition_report',
  'A submitted history or explicit “nothing to add yet” receipt exists.','medical_reports','basic_profile',0,1,1,
  'Patient wording is not converted into a new diagnosis.','active'),

 ('participant_journey','1.0','medical_reports',50,'medical_baseline','document_upload',
  'Your reports','Upload your latest available medical reports.',
  'Add current reports first. Older reports may be added to show change over time.',
  'Upload reports','I have no report to add now','ilb_subject_document + ilb_subject_lab_episode + ilb_subject_measurement',
  'existing report list','document upload and extraction-review contract',
  'At least one report is uploaded or an explicit no-report receipt exists.','medicines_and_prescriptions','medical_history',0,1,1,
  'Extraction is a draft until source and values are confirmed; the app never orders a test.','active'),

 ('participant_journey','1.0','medicines_and_prescriptions',60,'medical_baseline','medicine_capture',
  'Medicines','Add current medicines and prescriptions.',
  'Type the name or photograph the pack or prescription. Confirm what was read before saving.',
  'Add medicines','I take no medicine','ilb_subject_medicine_report + ilb_medicine_report_document',
  'current medicine list','medicine capture and confirmation contract',
  'Every reported medicine is confirmed, marked unknown, or an explicit no-medicine receipt exists.','baseline_review','medical_reports',0,1,1,
  'The platform records medicines but never starts, stops or changes a prescribed medicine.','active'),

 ('participant_journey','1.0','baseline_review',70,'medical_baseline','review_confirmation',
  'Connected starting picture','Let us review what you provided.',
  'See reports, measurements, medicines, formula outputs, sources, missing context and questions for professional review together.',
  'Confirm my starting information','Edit something','ilb_observation + ilb_formula + evidence tables',
  'connected baseline review contract','baseline confirmation receipt',
  'The participant confirms source documents and corrections; review-required items remain visibly flagged.','pre10_days','medicines_and_prescriptions',0,1,1,
  'Results are explained calmly; automated output does not diagnose, prescribe or declare cause.','active'),

 ('participant_journey','1.0','pre10_days',80,'pre10','assessment_route',
  'Ten days of complete clarity','Let us understand the person living in this body.',
  'Complete the scheduled tests and discovery questions at your pace. Sensitive questions may always be skipped.',
  'Begin or continue','View my progress','ilb_pre10_*',
  'PRE-10 day, assessment, item, option and progress views','PRE-10 response/session contracts',
  'Ten-day review is available when routed sessions are submitted or explicitly skipped.','clarity_map','baseline_review',0,1,1,
  'Validated screens remain separate from original discovery questions and retain their own safety rules.','active'),

 ('participant_journey','1.0','clarity_map',90,'clarity_map','result_review',
  'Your starting map','See what is present, connected and still unclear.',
  'Review your words, strengths, information coverage, source-defined results and questions worth exploring.',
  'Review my map','Return to an answer','PRE-10 result and source views',
  'v_ilb_pre10_assessment_progress + v_ilb_pre10_dimension_coverage + v_ilb_pre10_source_catalog',
  'participant clarity-map confirmation',
  'The participant confirms chosen priorities; no overall person score is required.','mentor_preference','pre10_days',0,1,1,
  'Coverage is not health, worth, happiness, diagnosis or energy.','active'),

 ('participant_journey','1.0','mentor_preference',100,'clarity_map','mentor_preference',
  'Human support','Who would you feel comfortable speaking with?',
  'Choose the kind of founder-selected professional or practitioner support you would like to explore.',
  'Choose preferences','Continue without choosing','mentor and referral registry',
  'active verified mentor types and availability','participant mentor preference',
  'A preference or explicit no-preference response is recorded.','journey_one','clarity_map',1,1,1,
  'Listing or selection does not replace verification, informed consent or professional scope.','active'),

 ('participant_journey','1.0','journey_one',110,'journey_1','journey_dashboard',
  'Seven weeks','Begin your first guided journey.',
  'Notice your daily experience, choose small actions, record what happened and see your own patterns over time.',
  'Begin seven weeks','Not now','ilb_protocol_enrollment + daily snapshot/action tables',
  'first-cycle journey contract','daily event and protocol contracts',
  'The first 49-day cycle reaches its declared checkpoint or is paused/withdrawn.','reassessment','mentor_preference',0,1,1,
  'Daily support continues alongside medical treatment and never promises cure.','active'),

 ('participant_journey','1.0','reassessment',120,'reassessment','reassessment',
  'Reassessment','What changed—and what did not?',
  'Compare like with like: participant experience, repeated assessments, available reports, medicines and measurement context.',
  'Review my comparison','Add information','checkpoint and comparison engine',
  'checkpoint comparison and source contract','reassessment confirmation',
  'Comparable and non-comparable results are clearly separated and reviewed.','journey_two','journey_one',0,1,1,
  'A changed report does not prove one action caused the change; medicine decisions remain clinical.','active'),

 ('participant_journey','1.0','journey_two',130,'journey_2','journey_dashboard',
  'If useful','Would another seven weeks help you explore further?',
  'Choose with your doctor or relevant professional where medical treatment is involved. A second cycle is optional.',
  'Plan another seven weeks','Complete for now','ilb_protocol_enrollment + protocol_status_audit',
  'second-cycle eligibility and participant choice','second-cycle enrollment or completion receipt',
  'A second-cycle choice or complete-for-now choice is recorded.','continuing_path','reassessment',1,1,1,
  'The platform does not decide medical need or medication changes.','active'),

 ('participant_journey','1.0','continuing_path',140,'continuing','completion',
  'Your information remains yours','Choose what comes next.',
  'Continue observing, speak with a selected professional, download your summary, pause or withdraw.',
  'View my options',NULL,'participant records and consent',
  'continuing options contract','participant continuation choice',
  'A continuation, pause, completion or withdrawal state is recorded.',NULL,'journey_two',0,1,1,
  'Urgent symptoms always follow configured medical and emergency routing.','active')
ON DUPLICATE KEY UPDATE
 `step_order`=VALUES(`step_order`),
 `phase_key`=VALUES(`phase_key`),
 `screen_type`=VALUES(`screen_type`),
 `eyebrow_text`=VALUES(`eyebrow_text`),
 `title_text`=VALUES(`title_text`),
 `instruction_text`=VALUES(`instruction_text`),
 `primary_action_text`=VALUES(`primary_action_text`),
 `secondary_action_text`=VALUES(`secondary_action_text`),
 `data_owner`=VALUES(`data_owner`),
 `read_contract`=VALUES(`read_contract`),
 `write_contract`=VALUES(`write_contract`),
 `completion_rule`=VALUES(`completion_rule`),
 `next_step_key`=VALUES(`next_step_key`),
 `back_step_key`=VALUES(`back_step_key`),
 `is_optional`=VALUES(`is_optional`),
 `requires_authentication`=VALUES(`requires_authentication`),
 `requires_consent`=VALUES(`requires_consent`),
 `safety_boundary`=VALUES(`safety_boundary`),
 `status`=VALUES(`status`);

INSERT INTO `ilb_app_step_pathway`
 (`flow_key`,`version_label`,`step_key`,`pathway_key`,`requirement_level`,`condition_text`)
SELECT 'participant_journey','1.0',s.`step_key`,p.`pathway_key`,
       CASE
         WHEN s.`step_key` IN ('medical_history','medical_reports','medicines_and_prescriptions','baseline_review')
           THEN 'required'
         WHEN s.`step_key`='mentor_preference' THEN 'optional'
         ELSE 'recommended'
       END,
       CASE
         WHEN p.`pathway_key`='addiction' AND s.`step_key`='mentor_preference'
           THEN 'Offer appropriately qualified addiction support; do not assume readiness or force referral.'
         ELSE NULL
       END
FROM `ilb_app_step` s
CROSS JOIN `ilb_app_pathway` p
WHERE s.`flow_key`='participant_journey' AND s.`version_label`='1.0'
ON DUPLICATE KEY UPDATE
 `requirement_level`=VALUES(`requirement_level`),
 `condition_text`=VALUES(`condition_text`);

DROP VIEW IF EXISTS `v_ilb_app_active_pathway`;
CREATE VIEW `v_ilb_app_active_pathway` AS
SELECT `pathway_key`,`display_order`,`button_text`,`acknowledgement_text`,
       `scope_text`,`allows_multiple`
FROM `ilb_app_pathway`
WHERE `status`='active'
ORDER BY `display_order`;

DROP VIEW IF EXISTS `v_ilb_app_flow_contract`;
CREATE VIEW `v_ilb_app_flow_contract` AS
SELECT
 f.`flow_key`,f.`version_label`,f.`flow_name`,f.`purpose_text`,
 s.`step_key`,s.`step_order`,s.`phase_key`,s.`screen_type`,
 s.`eyebrow_text`,s.`title_text`,s.`instruction_text`,
 s.`primary_action_text`,s.`secondary_action_text`,
 s.`data_owner`,s.`read_contract`,s.`write_contract`,
 s.`completion_rule`,s.`next_step_key`,s.`back_step_key`,
 s.`is_optional`,s.`requires_authentication`,s.`requires_consent`,
 s.`safety_boundary`
FROM `ilb_app_flow` f
JOIN `ilb_app_step` s
  ON s.`flow_key`=f.`flow_key` AND s.`version_label`=f.`version_label`
WHERE f.`status`='active' AND s.`status`='active';

DROP VIEW IF EXISTS `v_ilb_app_current_step`;
CREATE VIEW `v_ilb_app_current_step` AS
SELECT
 e.`app_enrollment_id`,e.`subject_key`,e.`status` AS `enrollment_status`,
 e.`journey_cycle`,e.`last_activity_at`,
 s.`step_key`,s.`step_order`,s.`phase_key`,s.`screen_type`,
 s.`eyebrow_text`,s.`title_text`,s.`instruction_text`,
 s.`primary_action_text`,s.`secondary_action_text`,
 s.`read_contract`,s.`write_contract`,s.`completion_rule`,
 s.`next_step_key`,s.`back_step_key`,s.`safety_boundary`
FROM `ilb_app_enrollment_state` e
JOIN `ilb_app_step` s
  ON s.`flow_key`=e.`flow_key`
 AND s.`version_label`=e.`version_label`
 AND s.`step_key`=e.`current_step_key`;

DROP VIEW IF EXISTS `v_ilb_app_backend_readiness`;
CREATE VIEW `v_ilb_app_backend_readiness` AS
SELECT 'active_pathways' AS `check_key`,COUNT(*) AS `actual_count`,4 AS `minimum_count`,
       CASE WHEN COUNT(*)=4 THEN 'ready' ELSE 'blocked' END AS `readiness_status`
FROM `ilb_app_pathway` WHERE `status`='active'
UNION ALL
SELECT 'active_flow_steps',COUNT(*),14,
       CASE WHEN COUNT(*)=14 THEN 'ready' ELSE 'blocked' END
FROM `ilb_app_step`
WHERE `flow_key`='participant_journey' AND `version_label`='1.0' AND `status`='active'
UNION ALL
SELECT 'pre10_backend',COUNT(*),8,
       CASE WHEN COUNT(*)>=8 THEN 'ready' ELSE 'blocked' END
FROM `v_ilb_backend_readiness` WHERE `readiness_status`='ready'
UNION ALL
SELECT 'formula_sources',COUNT(*),12,
       CASE WHEN COUNT(*)>=12 THEN 'ready' ELSE 'blocked' END
FROM `v_ilb_formula_source_catalog`;

COMMIT;

SELECT * FROM `v_ilb_app_backend_readiness` ORDER BY `check_key`;
SELECT COUNT(*) AS `frontend_flow_steps` FROM `v_ilb_app_flow_contract`;
