-- Phase 42: PRE-10 Complete Clarity assessment engine
-- Target: u756742628_ilovemybody
-- Prerequisite: database export dated 2026-07-22 / phases through 41.
--
-- Design boundaries:
-- 1. PRE-10 gathers information before the N.A.I.V.E. journey.
-- 2. It asks, connects and reflects. It does not label or diagnose.
-- 3. Validated instruments remain distinct from ILB discovery assessments.
-- 4. Existing subject, consent, document, psych, direction and NAIVE tables remain authoritative.
-- 5. Nothing in this migration changes or deletes existing patient data.
-- 6. Safe to rerun.

START TRANSACTION;

CREATE TABLE IF NOT EXISTS `ilb_pre10_dimension` (
  `dimension_key` varchar(80) NOT NULL,
  `dimension_order` tinyint(3) unsigned NOT NULL,
  `dimension_name` varchar(160) NOT NULL,
  `patient_prompt` varchar(500) NOT NULL,
  `scope_note` varchar(1000) NOT NULL,
  `status` enum('review','active','retired') NOT NULL DEFAULT 'review',
  PRIMARY KEY (`dimension_key`),
  UNIQUE KEY `uq_p42_dimension_order` (`dimension_order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `ilb_pre10_plan` (
  `plan_key` varchar(80) NOT NULL,
  `plan_name` varchar(200) NOT NULL,
  `version_label` varchar(40) NOT NULL,
  `duration_days` tinyint(3) unsigned NOT NULL DEFAULT 10,
  `purpose_text` varchar(1500) NOT NULL,
  `result_name` varchar(200) NOT NULL DEFAULT 'Complete Clarity Map',
  `tonality_rule` varchar(1500) NOT NULL,
  `clinical_boundary` varchar(1500) NOT NULL,
  `status` enum('draft','review','active','retired') NOT NULL DEFAULT 'review',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`plan_key`,`version_label`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `ilb_pre10_day` (
  `plan_key` varchar(80) NOT NULL,
  `version_label` varchar(40) NOT NULL,
  `day_number` tinyint(3) unsigned NOT NULL,
  `day_key` varchar(80) NOT NULL,
  `day_name` varchar(200) NOT NULL,
  `invitation_text` varchar(700) NOT NULL,
  `completion_message` varchar(700) NOT NULL,
  `is_required` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`plan_key`,`version_label`,`day_number`),
  UNIQUE KEY `uq_p42_day_key` (`plan_key`,`version_label`,`day_key`),
  CONSTRAINT `fk_p42_day_plan`
    FOREIGN KEY (`plan_key`,`version_label`)
    REFERENCES `ilb_pre10_plan` (`plan_key`,`version_label`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `ilb_pre10_assessment` (
  `assessment_key` varchar(100) NOT NULL,
  `assessment_name` varchar(255) NOT NULL,
  `patient_name` varchar(255) NOT NULL,
  `assessment_class` enum('validated','ilb_discovery','information_collection','professional_result_import') NOT NULL,
  `construct_key` varchar(100) NOT NULL,
  `purpose_text` varchar(1000) NOT NULL,
  `administration_route` enum('native','official_external','result_import','document_upload','qualified_professional') NOT NULL,
  `item_storage_rule` enum('stored','official_source_only','result_only','not_applicable') NOT NULL,
  `psych_instrument_version_id` int(10) unsigned DEFAULT NULL,
  `direction_instrument_key` varchar(100) DEFAULT NULL,
  `source_reference_id` bigint(20) unsigned DEFAULT NULL,
  `source_label` varchar(500) NOT NULL,
  `source_url` varchar(1000) DEFAULT NULL,
  `version_label` varchar(100) NOT NULL,
  `recall_period` varchar(160) DEFAULT NULL,
  `scoring_method` varchar(1000) DEFAULT NULL,
  `result_rule` varchar(1500) NOT NULL,
  `diagnostic_status` enum('not_diagnostic','screening_only','professional_context_only') NOT NULL DEFAULT 'not_diagnostic',
  `safety_review_possible` tinyint(1) NOT NULL DEFAULT 0,
  `status` enum('draft','review','active','retired') NOT NULL DEFAULT 'review',
  PRIMARY KEY (`assessment_key`),
  KEY `idx_p42_assessment_psych` (`psych_instrument_version_id`),
  KEY `idx_p42_assessment_direction` (`direction_instrument_key`),
  KEY `idx_p42_assessment_reference` (`source_reference_id`),
  CONSTRAINT `fk_p42_assessment_psych`
    FOREIGN KEY (`psych_instrument_version_id`)
    REFERENCES `ilb_psych_instrument_version` (`instrument_version_id`),
  CONSTRAINT `fk_p42_assessment_direction`
    FOREIGN KEY (`direction_instrument_key`)
    REFERENCES `ilb_direction_instrument_registry` (`direction_instrument_key`),
  CONSTRAINT `fk_p42_assessment_reference`
    FOREIGN KEY (`source_reference_id`)
    REFERENCES `ilb_reference` (`reference_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `ilb_pre10_day_assessment` (
  `plan_key` varchar(80) NOT NULL,
  `version_label` varchar(40) NOT NULL,
  `day_number` tinyint(3) unsigned NOT NULL,
  `assessment_key` varchar(100) NOT NULL,
  `display_order` smallint(5) unsigned NOT NULL,
  `requirement_level` enum('required_for_safety','recommended','optional','conditional') NOT NULL DEFAULT 'optional',
  `condition_note` varchar(1000) DEFAULT NULL,
  PRIMARY KEY (`plan_key`,`version_label`,`day_number`,`assessment_key`),
  CONSTRAINT `fk_p42_day_assessment_day`
    FOREIGN KEY (`plan_key`,`version_label`,`day_number`)
    REFERENCES `ilb_pre10_day` (`plan_key`,`version_label`,`day_number`),
  CONSTRAINT `fk_p42_day_assessment_assessment`
    FOREIGN KEY (`assessment_key`)
    REFERENCES `ilb_pre10_assessment` (`assessment_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `ilb_pre10_assessment_dimension` (
  `assessment_key` varchar(100) NOT NULL,
  `dimension_key` varchar(80) NOT NULL,
  `mapping_role` enum('primary','secondary','context') NOT NULL DEFAULT 'secondary',
  `weight_hint` decimal(8,6) DEFAULT NULL,
  PRIMARY KEY (`assessment_key`,`dimension_key`),
  CONSTRAINT `fk_p42_assessment_dimension_assessment`
    FOREIGN KEY (`assessment_key`)
    REFERENCES `ilb_pre10_assessment` (`assessment_key`),
  CONSTRAINT `fk_p42_assessment_dimension_dimension`
    FOREIGN KEY (`dimension_key`)
    REFERENCES `ilb_pre10_dimension` (`dimension_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `ilb_pre10_item` (
  `item_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `assessment_key` varchar(100) NOT NULL,
  `item_key` varchar(120) NOT NULL,
  `item_order` smallint(5) unsigned NOT NULL,
  `question_text` varchar(1500) NOT NULL,
  `help_text` varchar(1000) DEFAULT NULL,
  `response_type` enum('single_choice','multi_choice','scale','rank','short_text','long_text','yes_no_unsure','date','number','document') NOT NULL,
  `scale_min` decimal(12,4) DEFAULT NULL,
  `scale_max` decimal(12,4) DEFAULT NULL,
  `scale_step` decimal(12,4) DEFAULT NULL,
  `scale_low_label` varchar(300) DEFAULT NULL,
  `scale_high_label` varchar(300) DEFAULT NULL,
  `is_optional` tinyint(1) NOT NULL DEFAULT 1,
  `is_sensitive` tinyint(1) NOT NULL DEFAULT 0,
  `safety_relevant` tinyint(1) NOT NULL DEFAULT 0,
  `neutral_reflection_template` varchar(1500) DEFAULT NULL,
  `status` enum('review','active','retired') NOT NULL DEFAULT 'review',
  PRIMARY KEY (`item_id`),
  UNIQUE KEY `uq_p42_item_key` (`assessment_key`,`item_key`),
  UNIQUE KEY `uq_p42_item_order` (`assessment_key`,`item_order`),
  CONSTRAINT `fk_p42_item_assessment`
    FOREIGN KEY (`assessment_key`)
    REFERENCES `ilb_pre10_assessment` (`assessment_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `ilb_pre10_option` (
  `option_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `item_id` bigint(20) unsigned NOT NULL,
  `option_key` varchar(100) NOT NULL,
  `option_order` smallint(5) unsigned NOT NULL,
  `option_text` varchar(700) NOT NULL,
  `numeric_value` decimal(12,6) DEFAULT NULL,
  `meaning_note` varchar(1000) DEFAULT NULL,
  PRIMARY KEY (`option_id`),
  UNIQUE KEY `uq_p42_option_key` (`item_id`,`option_key`),
  UNIQUE KEY `uq_p42_option_order` (`item_id`,`option_order`),
  CONSTRAINT `fk_p42_option_item`
    FOREIGN KEY (`item_id`)
    REFERENCES `ilb_pre10_item` (`item_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `ilb_pre10_enrollment` (
  `pre10_enrollment_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `subject_key` varchar(80) NOT NULL,
  `plan_key` varchar(80) NOT NULL,
  `version_label` varchar(40) NOT NULL,
  `linked_protocol_enrollment_id` bigint(20) unsigned DEFAULT NULL,
  `started_at` datetime DEFAULT NULL,
  `target_completion_date` date DEFAULT NULL,
  `completed_at` datetime DEFAULT NULL,
  `status` enum('draft','awaiting_consent','active','paused','completed','withdrawn') NOT NULL DEFAULT 'draft',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`pre10_enrollment_id`),
  KEY `idx_p42_enrollment_subject` (`subject_key`),
  KEY `idx_p42_enrollment_protocol` (`linked_protocol_enrollment_id`),
  CONSTRAINT `fk_p42_enrollment_subject`
    FOREIGN KEY (`subject_key`) REFERENCES `ilb_subject` (`subject_key`),
  CONSTRAINT `fk_p42_enrollment_plan`
    FOREIGN KEY (`plan_key`,`version_label`)
    REFERENCES `ilb_pre10_plan` (`plan_key`,`version_label`),
  CONSTRAINT `fk_p42_enrollment_protocol`
    FOREIGN KEY (`linked_protocol_enrollment_id`)
    REFERENCES `ilb_protocol_enrollment` (`enrollment_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `ilb_pre10_session` (
  `pre10_session_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `pre10_enrollment_id` bigint(20) unsigned NOT NULL,
  `assessment_key` varchar(100) NOT NULL,
  `day_number` tinyint(3) unsigned NOT NULL,
  `started_at` datetime NOT NULL,
  `last_saved_at` datetime DEFAULT NULL,
  `submitted_at` datetime DEFAULT NULL,
  `administration_mode` enum('self_web','self_mobile','assisted','professional','imported') NOT NULL DEFAULT 'self_web',
  `completion_status` enum('started','partial','submitted','withdrawn','invalid') NOT NULL DEFAULT 'started',
  `source_result_id` varchar(255) DEFAULT NULL,
  `raw_score` decimal(16,6) DEFAULT NULL,
  `transformed_score` decimal(16,6) DEFAULT NULL,
  `quality_note` varchar(1000) DEFAULT NULL,
  PRIMARY KEY (`pre10_session_id`),
  UNIQUE KEY `uq_p42_session` (`pre10_enrollment_id`,`assessment_key`),
  CONSTRAINT `fk_p42_session_enrollment`
    FOREIGN KEY (`pre10_enrollment_id`)
    REFERENCES `ilb_pre10_enrollment` (`pre10_enrollment_id`),
  CONSTRAINT `fk_p42_session_assessment`
    FOREIGN KEY (`assessment_key`)
    REFERENCES `ilb_pre10_assessment` (`assessment_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `ilb_pre10_result` (
  `pre10_result_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `pre10_session_id` bigint(20) unsigned NOT NULL,
  `result_key` varchar(120) NOT NULL,
  `raw_value` decimal(20,8) DEFAULT NULL,
  `normalized_value` decimal(20,8) DEFAULT NULL,
  `result_band` varchar(120) DEFAULT NULL,
  `patient_language` varchar(1500) NOT NULL,
  `source_language` varchar(1500) DEFAULT NULL,
  `calculation_json` longtext DEFAULT NULL,
  `calculated_at` datetime NOT NULL,
  `review_status` enum('automatic_draft','reviewed','approved','hidden') NOT NULL DEFAULT 'automatic_draft',
  PRIMARY KEY (`pre10_result_id`),
  UNIQUE KEY `uq_p42_result` (`pre10_session_id`,`result_key`),
  CONSTRAINT `fk_p42_result_session`
    FOREIGN KEY (`pre10_session_id`)
    REFERENCES `ilb_pre10_session` (`pre10_session_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `ilb_pre10_response` (
  `response_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `pre10_session_id` bigint(20) unsigned NOT NULL,
  `item_id` bigint(20) unsigned NOT NULL,
  `option_id` bigint(20) unsigned DEFAULT NULL,
  `numeric_value` decimal(20,8) DEFAULT NULL,
  `text_value` text DEFAULT NULL,
  `answered_at` datetime NOT NULL,
  `response_status` enum('answered','skipped','prefer_not_to_answer','withdrawn') NOT NULL DEFAULT 'answered',
  `revision_number` smallint(5) unsigned NOT NULL DEFAULT 1,
  PRIMARY KEY (`response_id`),
  KEY `idx_p42_response_session` (`pre10_session_id`,`item_id`),
  CONSTRAINT `fk_p42_response_session`
    FOREIGN KEY (`pre10_session_id`)
    REFERENCES `ilb_pre10_session` (`pre10_session_id`),
  CONSTRAINT `fk_p42_response_item`
    FOREIGN KEY (`item_id`)
    REFERENCES `ilb_pre10_item` (`item_id`),
  CONSTRAINT `fk_p42_response_option`
    FOREIGN KEY (`option_id`)
    REFERENCES `ilb_pre10_option` (`option_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `ilb_pre10_reflection` (
  `reflection_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `pre10_enrollment_id` bigint(20) unsigned NOT NULL,
  `dimension_key` varchar(80) DEFAULT NULL,
  `generated_at` datetime NOT NULL,
  `reflection_type` enum('question','connection_to_explore','strength_noticed','difference_noticed','missing_information','patient_wording') NOT NULL,
  `reflection_text` varchar(2000) NOT NULL,
  `generation_basis` longtext NOT NULL,
  `review_status` enum('automatic_draft','reviewed','approved','hidden') NOT NULL DEFAULT 'automatic_draft',
  `reviewed_by` varchar(100) DEFAULT NULL,
  `reviewed_at` datetime DEFAULT NULL,
  PRIMARY KEY (`reflection_id`),
  KEY `idx_p42_reflection_enrollment` (`pre10_enrollment_id`,`generated_at`),
  CONSTRAINT `fk_p42_reflection_enrollment`
    FOREIGN KEY (`pre10_enrollment_id`)
    REFERENCES `ilb_pre10_enrollment` (`pre10_enrollment_id`),
  CONSTRAINT `fk_p42_reflection_dimension`
    FOREIGN KEY (`dimension_key`)
    REFERENCES `ilb_pre10_dimension` (`dimension_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `ilb_pre10_day_progress` (
  `pre10_enrollment_id` bigint(20) unsigned NOT NULL,
  `day_number` tinyint(3) unsigned NOT NULL,
  `opened_at` datetime DEFAULT NULL,
  `last_activity_at` datetime DEFAULT NULL,
  `completed_at` datetime DEFAULT NULL,
  `completion_status` enum('not_started','started','enough_for_now','completed','skipped','withdrawn') NOT NULL DEFAULT 'not_started',
  `patient_note` varchar(1500) DEFAULT NULL,
  PRIMARY KEY (`pre10_enrollment_id`,`day_number`),
  CONSTRAINT `fk_p42_progress_enrollment`
    FOREIGN KEY (`pre10_enrollment_id`)
    REFERENCES `ilb_pre10_enrollment` (`pre10_enrollment_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Ten connected dimensions. They organise questions; they do not define a person.
INSERT INTO `ilb_pre10_dimension`
 (`dimension_key`,`dimension_order`,`dimension_name`,`patient_prompt`,`scope_note`,`status`)
VALUES
 ('physical_medical',1,'Physical and medical','What is your body experiencing, and what medical information would you like us to understand?','History, current diagnoses, operations, reports, medicines, symptoms, sleep, movement and physical function.','active'),
 ('thoughts_attention',2,'Thoughts and attention','What has your mind been returning to lately?','Recurring thoughts, attention, memory, mental load, imagination and present concerns; never used to infer diagnosis by itself.','active'),
 ('beliefs_meaning',3,'Beliefs and meaning','What feels true to you about yourself, your body, health and possibility?','Personal beliefs and interpretations are recorded as the participant’s perspective, not objective fact.','active'),
 ('feelings_regulation',4,'Feelings and expression','What are you feeling, and how do those feelings move through your life?','Mood, feelings, triggers, expression, suppression, guilt, shame, blame, anger, fear, joy and emotional needs.','active'),
 ('personality_values',5,'Personality and values','What matters to you, and what feels naturally like you?','Trait tendencies, values, strengths, interests and preferences; no fixed type or identity label.','active'),
 ('lifestyle_choices',6,'Lifestyle and choices','How are you currently living each day?','Routines, rest, sleep, work pattern, hygiene, movement, substances, digital life, comfort zones and repeated choices.','active'),
 ('relationships_belonging',7,'Relationships and belonging','How do your relationships currently feel to you?','Support, belonging, loneliness, reciprocity, conflict, boundaries, family, partner, friendship and community.','active'),
 ('intimacy_sexuality',8,'Intimacy and sexuality','What feels comfortable, wanted, safe or unexplored in intimacy?','Touch, closeness, desire, pleasure, consent, boundaries, safety and sexual wellbeing; always optional and private.','active'),
 ('work_dreams_direction',9,'Work, dreams and direction','What would you love to experience, create or become?','Occupation, contribution, abilities, aspirations, dreams, purpose, curiosity and desired future.','active'),
 ('instinct_courage_selftrust',10,'Instinct, courage and self-trust','What do you sense, what do you fear, and what feels worth moving towards?','Inner signals, self-trust, approach despite fear, confidence, willingness and love-led versus fear-led choices.','active')
ON DUPLICATE KEY UPDATE
 `dimension_order`=VALUES(`dimension_order`),
 `dimension_name`=VALUES(`dimension_name`),
 `patient_prompt`=VALUES(`patient_prompt`),
 `scope_note`=VALUES(`scope_note`),
 `status`=VALUES(`status`);

INSERT INTO `ilb_pre10_plan`
 (`plan_key`,`plan_name`,`version_label`,`duration_days`,`purpose_text`,`result_name`,`tonality_rule`,`clinical_boundary`,`status`)
VALUES
 ('pre10_clarity','PRE-10 Complete Clarity','1.0',10,
  'Gather a person’s present medical context, thoughts, beliefs, feelings, personality, values, lifestyle, relationships, intimacy, desires, dreams, direction, instinct, courage and self-trust before the N.A.I.V.E. journey begins.',
  'Complete Clarity Map',
  'Ask without judging. Preserve the participant’s wording. Reflect patterns as questions, possibilities and differences to explore. Never write “you are”, “your problem is”, “this proves”, “good”, “bad”, “normal personality” or a psychiatric identity.',
  'PRE-10 is information gathering and self-discovery. Validated screens are not diagnoses. Clinical interpretation, diagnosis and treatment remain with qualified professionals. Safety-relevant responses follow the existing consent and safety workflow.',
  'active')
ON DUPLICATE KEY UPDATE
 `plan_name`=VALUES(`plan_name`),
 `duration_days`=VALUES(`duration_days`),
 `purpose_text`=VALUES(`purpose_text`),
 `result_name`=VALUES(`result_name`),
 `tonality_rule`=VALUES(`tonality_rule`),
 `clinical_boundary`=VALUES(`clinical_boundary`),
 `status`=VALUES(`status`);

INSERT INTO `ilb_pre10_day`
 (`plan_key`,`version_label`,`day_number`,`day_key`,`day_name`,`invitation_text`,`completion_message`,`is_required`)
VALUES
 ('pre10_clarity','1.0',1,'where_i_am','Where I am today','Let us begin with what is happening in your life and body today. Share only what feels right.','Thank you. We have begun with your present—not an assumption about you.',0),
 ('pre10_clarity','1.0',2,'mind_today','What occupies my mind','Notice the thoughts, concerns and possibilities your mind returns to.','You have recorded what is present. Nothing here defines you.',0),
 ('pre10_clarity','1.0',3,'beliefs_body','What I believe','Explore what you currently believe about yourself, your body, health, responsibility and possibility.','Beliefs can be noticed without being judged or defended.',0),
 ('pre10_clarity','1.0',4,'feelings_expression','What I feel','Name what you feel, what seems to affect it and how you usually express it.','Every feeling is information. You decide what it means for you.',0),
 ('pre10_clarity','1.0',5,'personality_values','What feels like me','Explore your natural preferences, strengths, interests, self-worth and values.','A profile is a starting question—not a box or label.',0),
 ('pre10_clarity','1.0',6,'lifestyle_comfort','How I live','Look gently at your routines, choices, comfort zones and everyday environment.','Awareness comes before change. No routine is graded here.',0),
 ('pre10_clarity','1.0',7,'relationships','How I relate','Consider connection, belonging, conflict, support and the relationships that matter to you.','Relationships can hold several truths at the same time.',0),
 ('pre10_clarity','1.0',8,'intimacy_desire','Closeness, touch and desire','Explore closeness, touch, boundaries, desire and safety only to the extent you choose.','Thank you for trusting your own boundaries.',0),
 ('pre10_clarity','1.0',9,'dreams_courage','What calls me forward','Explore dreams, direction, instinct, self-trust and what you may choose even when fear is present.','A dream can begin as a question before it becomes an action.',0),
 ('pre10_clarity','1.0',10,'complete_clarity','Seeing the connections','Review what you shared and choose what you would like to understand more deeply.','This is your Complete Clarity Map—a living beginning, not a final verdict.',0)
ON DUPLICATE KEY UPDATE
 `day_name`=VALUES(`day_name`),
 `invitation_text`=VALUES(`invitation_text`),
 `completion_message`=VALUES(`completion_message`),
 `is_required`=VALUES(`is_required`);

-- Validated and existing routes are registered, not duplicated.
INSERT INTO `ilb_reference`
 (`reference_type`,`title`,`authors_or_group`,`publisher_or_journal`,`canonical_url`,
  `quality_status`,`accessed_on`,`status`,`notes`)
SELECT
 'instrument','Rosenberg Self-Esteem Scale','Morris Rosenberg',
 'University of Maryland, Department of Sociology',
 'https://socy.umd.edu/about-us/using-rosenberg-self-esteem-scale',
 'authoritative',CURRENT_DATE,'active',
 'Official scoring and use page. Ten items, four response choices. Use as a measure of current global self-esteem; never as a label of personal worth.'
WHERE NOT EXISTS (
 SELECT 1 FROM `ilb_reference`
 WHERE `canonical_url`='https://socy.umd.edu/about-us/using-rosenberg-self-esteem-scale'
);

INSERT INTO `ilb_pre10_assessment`
 (`assessment_key`,`assessment_name`,`patient_name`,`assessment_class`,`construct_key`,`purpose_text`,
  `administration_route`,`item_storage_rule`,`psych_instrument_version_id`,`direction_instrument_key`,
  `source_reference_id`,`source_label`,`source_url`,`version_label`,`recall_period`,`scoring_method`,
  `result_rule`,`diagnostic_status`,`safety_review_possible`,`status`)
VALUES
 ('validated_who5','WHO-5 Well-Being Index','How have the past two weeks felt?','validated','wellbeing',
  'Repeatable measure of subjective wellbeing using the official version.',
  'official_external','official_source_only',1,NULL,196,'World Health Organization WHO-5 (2024)',
  'https://www.who.int/publications/m/item/WHO-UCN-MSD-MHE-2024.01','WHO 2024 English','Past two weeks',
  'Existing ilb_psych_assessment scoring: raw sum 0-25; percentage raw*4.',
  'Display the official result with its source and ask what the participant notices. Never infer a diagnosis.','not_diagnostic',0,'active'),
 ('validated_phq9','Patient Health Questionnaire-9','How have some difficult experiences shown up recently?','validated','depression_symptoms',
  'Optional validated symptom screen when appropriate and consented.',
  'official_external','official_source_only',2,NULL,197,'Kroenke, Spitzer and Williams (2001)',
  'https://pubmed.ncbi.nlm.nih.gov/11556941/','Original validation English','Past two weeks',
  'Existing ilb_psych_assessment scoring: raw sum 0-27.',
  'Do not display a psychiatric identity. Present as an optional screen requiring appropriate review and retain item-level safety handling.','screening_only',1,'active'),
 ('validated_gad7','Generalized Anxiety Disorder-7','How has worry or tension appeared recently?','validated','anxiety_symptoms',
  'Optional validated symptom screen when appropriate and consented.',
  'official_external','official_source_only',3,NULL,198,'Spitzer, Kroenke, Williams and Löwe (2006)',
  'https://pubmed.ncbi.nlm.nih.gov/16717171/','Original validation English','Past two weeks',
  'Existing ilb_psych_assessment scoring: raw sum 0-21.',
  'Do not display a psychiatric identity. Present as an optional screen and a possible reason to seek further assessment.','screening_only',0,'active'),
 ('validated_ipip','IPIP personality inventory','My natural preferences','validated','personality',
  'Describe broad trait tendencies using one frozen public-domain IPIP scale and scoring key.',
  'native','stored',NULL,'ipip_personality',259,'International Personality Item Pool, Oregon Research Institute',
  'https://ipip.ori.org/','Exact scale version must be frozen before administration',NULL,
  'Use existing ilb_direction_assessment and ilb_direction_score.',
  'Describe tendencies as questions and ranges. Never assign a fixed personality type or capability judgment.','not_diagnostic',0,'active'),
 ('medical_information','Medical reports, prescriptions and medicines','My medical starting point','information_collection','medical_context',
  'Collect existing medical documents and medicine context before NAIVE begins.',
  'document_upload','not_applicable',NULL,NULL,NULL,'Participant-provided medical records and existing ILB document tables',
  NULL,'PRE-10 1.0','Current and historical','No composite score.',
  'Show what was provided, what date it represents and what remains unclear. Medical interpretation remains with clinicians.','professional_context_only',1,'active'),
 ('current_reality','ILB Present Reality Discovery','Where I am today','ilb_discovery','present_reality',
  'Understand why the participant has arrived and what currently asks for attention.',
  'native','stored',NULL,NULL,NULL,'I Love My Body original discovery assessment',NULL,'1.0','Today',
  'No total score. Preserve selected answers and words.',
  'Return only questions, differences to explore, strengths noticed and information still missing.','not_diagnostic',1,'active'),
 ('thought_patterns','ILB Thought and Attention Discovery','What occupies my mind','ilb_discovery','thoughts_attention',
  'Notice recurring thoughts, attention, mental load and imagination without judging their content.',
  'native','stored',NULL,NULL,NULL,'I Love My Body original discovery assessment',NULL,'1.0','Recent weeks',
  'Optional descriptive counts only; no clinical cut-off.',
  'Reflect frequency and context as questions. Never infer disorder, truth or causality.','not_diagnostic',0,'active'),
 ('beliefs_body','ILB Beliefs and Body Relationship Discovery','What I believe about myself and my body','ilb_discovery','beliefs_body',
  'Explore beliefs about worth, body, health, responsibility, love and possibility.',
  'native','stored',NULL,NULL,NULL,'I Love My Body original discovery assessment',NULL,'1.0','Current perspective',
  'No total score. Compare importance, certainty and lived alignment only.',
  'Ask whether each belief feels supportive, restrictive, inherited, chosen or ready to be explored.','not_diagnostic',0,'active'),
 ('feelings_expression','ILB Feelings and Expression Discovery','What I feel and how I express it','ilb_discovery','feelings_expression',
  'Explore feelings, triggers, expression, suppression and unmet emotional needs.',
  'native','stored',NULL,NULL,NULL,'I Love My Body original discovery assessment',NULL,'1.0','Recent weeks',
  'No diagnostic score. Descriptive frequency and context only.',
  'Reflect what was selected and ask what the participant would like to understand.','not_diagnostic',1,'active'),
 ('body_relationship','ILB Body Relationship Discovery','How I relate to my body','ilb_discovery','body_relationship',
  'Explore attention, touch, care, appreciation, judgement and responsiveness to body signals.',
  'native','stored',NULL,NULL,NULL,'I Love My Body original discovery assessment',NULL,'1.0','Current perspective',
  'No total score. Retain item-level responses.',
  'Ask how the relationship feels today and what the participant may wish to experience differently.','not_diagnostic',0,'active'),
 ('values_alignment','ILB Values and Lived Alignment Discovery','What matters—and how I am living','ilb_discovery','values_alignment',
  'Separate stated importance from current lived alignment without declaring correct values.',
  'native','stored',NULL,NULL,NULL,'I Love My Body original values discovery; stored in ilb_person_value_profile',NULL,'1.0','Current life',
  'Rank selected values; record importance and lived-alignment separately.',
  'Show gaps as questions: “This matters to you; how does its current place in your life feel?”','not_diagnostic',0,'active'),
 ('lifestyle_comfort','ILB Lifestyle and Comfort-Zone Discovery','How I live each day','ilb_discovery','lifestyle_choices',
  'Explore routines, hygiene, sleep, work pattern, substances, digital life, rest and comfort zones.',
  'native','stored',NULL,NULL,NULL,'I Love My Body original discovery assessment',NULL,'1.0','Usual recent pattern',
  'No total score. Context-first descriptive pattern.',
  'Ask what feels chosen, automatic, comforting, draining or ready to be explored.','not_diagnostic',1,'active'),
 ('relationships_belonging','ILB Relationships and Belonging Discovery','How my relationships feel','ilb_discovery','relationships_belonging',
  'Explore support, reciprocity, conflict, boundaries, loneliness and belonging.',
  'native','stored',NULL,NULL,NULL,'I Love My Body original discovery assessment',NULL,'1.0','Current relationships',
  'No relationship quality grade. Retain person-specific contexts privately.',
  'Reflect several truths without assigning blame or defining another person.','not_diagnostic',1,'active'),
 ('intimacy_desire','ILB Intimacy, Touch and Desire Discovery','Closeness, touch and desire','ilb_discovery','intimacy_sexuality',
  'Offer an optional private exploration of intimacy, touch, desire, boundaries, consent and safety.',
  'native','stored',NULL,NULL,NULL,'I Love My Body original discovery assessment',NULL,'1.0','Current and chosen history',
  'No total score. Prefer-not-to-answer is valid for every item.',
  'Reflect only the participant’s wording. Never grade desire, frequency, identity or relationship form.','not_diagnostic',1,'active'),
 ('dreams_direction','ILB Dreams and Direction Discovery','What I would love to experience','ilb_discovery','dreams_direction',
  'Explore aspirations, curiosity, work, contribution, creativity and desired future.',
  'native','stored',NULL,NULL,NULL,'I Love My Body original discovery assessment',NULL,'1.0','Present and imagined future',
  'No success score. Rank attraction, importance and willingness separately.',
  'Ask what feels alive, possible, postponed or worth experimenting with.','not_diagnostic',0,'active'),
 ('courage_selftrust','ILB Instinct, Courage and Self-Trust Discovery','What I sense—and what I may choose','ilb_discovery','courage_selftrust',
  'Explore instinct, fear, confidence, self-trust and approach despite fear.',
  'native','stored',NULL,NULL,NULL,'I Love My Body original discovery assessment inspired by courage-as-action research; not a validated Courage Measure',NULL,'1.0','Current patterns',
  'No courage grade. Keep instinct, fear, willingness and action as separate variables.',
  'Ask what the participant senses, fears, values and may be willing to try.','not_diagnostic',1,'active'),
 ('complete_clarity','ILB Complete Clarity Review','What do I see now?','ilb_discovery','complete_clarity',
  'Let the participant review connections and choose what deserves attention before NAIVE.',
  'native','stored',NULL,NULL,NULL,'I Love My Body original discovery assessment',NULL,'1.0','PRE-10 responses',
  'No overall human score. Completeness is data availability, not personal quality.',
  'Generate a participant-owned map of questions, connections, strengths and chosen priorities.','not_diagnostic',1,'active')
ON DUPLICATE KEY UPDATE
 `assessment_name`=VALUES(`assessment_name`),
 `patient_name`=VALUES(`patient_name`),
 `purpose_text`=VALUES(`purpose_text`),
 `source_label`=VALUES(`source_label`),
 `source_url`=VALUES(`source_url`),
 `result_rule`=VALUES(`result_rule`),
 `status`=VALUES(`status`);

INSERT INTO `ilb_pre10_assessment`
 (`assessment_key`,`assessment_name`,`patient_name`,`assessment_class`,`construct_key`,`purpose_text`,
  `administration_route`,`item_storage_rule`,`source_reference_id`,`source_label`,`source_url`,
  `version_label`,`recall_period`,`scoring_method`,`result_rule`,`diagnostic_status`,
  `safety_review_possible`,`status`)
SELECT
 'validated_rses','Rosenberg Self-Esteem Scale','How I currently see and value myself',
 'validated','global_self_esteem',
 'Optional repeatable measure of current global self-esteem, kept separate from self-confidence and courage.',
 'official_external','official_source_only',r.`reference_id`,
 'Rosenberg Self-Esteem Scale — University of Maryland',
 'https://socy.umd.edu/about-us/using-rosenberg-self-esteem-scale',
 'Official ten-item version','Current perspective',
 'Ten items on a four-point agreement scale with reverse scoring as defined by the official source.',
 'Show change over time and invite reflection. Never describe the score as the person’s actual worth or as a diagnosis.',
 'not_diagnostic',0,'active'
FROM `ilb_reference` r
WHERE r.`canonical_url`='https://socy.umd.edu/about-us/using-rosenberg-self-esteem-scale'
  AND NOT EXISTS (
    SELECT 1 FROM `ilb_pre10_assessment` a
    WHERE a.`assessment_key`='validated_rses'
  )
LIMIT 1;

-- Day routing. Nothing except consent/safety is compulsory.
INSERT INTO `ilb_pre10_day_assessment`
 (`plan_key`,`version_label`,`day_number`,`assessment_key`,`display_order`,`requirement_level`,`condition_note`)
VALUES
 ('pre10_clarity','1.0',1,'medical_information',10,'recommended','Reports and medicines may be added whenever available.'),
 ('pre10_clarity','1.0',1,'current_reality',20,'recommended',NULL),
 ('pre10_clarity','1.0',1,'validated_who5',30,'optional','Use only with consent and official form/version.'),
 ('pre10_clarity','1.0',2,'thought_patterns',10,'recommended',NULL),
 ('pre10_clarity','1.0',3,'beliefs_body',10,'recommended',NULL),
 ('pre10_clarity','1.0',3,'body_relationship',20,'recommended',NULL),
 ('pre10_clarity','1.0',4,'feelings_expression',10,'recommended',NULL),
 ('pre10_clarity','1.0',4,'validated_phq9',20,'conditional','Offer only when clinically appropriate, consented and safety workflow is available.'),
 ('pre10_clarity','1.0',4,'validated_gad7',30,'conditional','Offer only when clinically appropriate and consented.'),
 ('pre10_clarity','1.0',5,'validated_ipip',10,'optional','Use one frozen public-domain scale version.'),
 ('pre10_clarity','1.0',5,'validated_rses',20,'optional','A self-esteem measure, never a measure of the person’s true worth.'),
 ('pre10_clarity','1.0',5,'values_alignment',30,'recommended',NULL),
 ('pre10_clarity','1.0',6,'lifestyle_comfort',10,'recommended',NULL),
 ('pre10_clarity','1.0',7,'relationships_belonging',10,'recommended',NULL),
 ('pre10_clarity','1.0',8,'intimacy_desire',10,'optional','Every question supports prefer-not-to-answer.'),
 ('pre10_clarity','1.0',9,'dreams_direction',10,'recommended',NULL),
 ('pre10_clarity','1.0',9,'courage_selftrust',20,'recommended',NULL),
 ('pre10_clarity','1.0',10,'complete_clarity',10,'recommended',NULL)
ON DUPLICATE KEY UPDATE
 `display_order`=VALUES(`display_order`),
 `requirement_level`=VALUES(`requirement_level`),
 `condition_note`=VALUES(`condition_note`);

-- Assessment-to-dimension map. Weights are hints only; no composite human score is authorised.
INSERT INTO `ilb_pre10_assessment_dimension`
 (`assessment_key`,`dimension_key`,`mapping_role`,`weight_hint`)
VALUES
 ('medical_information','physical_medical','primary',NULL),
 ('current_reality','physical_medical','secondary',NULL),
 ('current_reality','thoughts_attention','secondary',NULL),
 ('current_reality','feelings_regulation','secondary',NULL),
 ('validated_who5','feelings_regulation','primary',NULL),
 ('validated_phq9','feelings_regulation','primary',NULL),
 ('validated_gad7','feelings_regulation','primary',NULL),
 ('validated_ipip','personality_values','primary',NULL),
 ('validated_rses','personality_values','primary',NULL),
 ('thought_patterns','thoughts_attention','primary',NULL),
 ('beliefs_body','beliefs_meaning','primary',NULL),
 ('body_relationship','physical_medical','primary',NULL),
 ('body_relationship','beliefs_meaning','secondary',NULL),
 ('feelings_expression','feelings_regulation','primary',NULL),
 ('values_alignment','personality_values','primary',NULL),
 ('values_alignment','work_dreams_direction','secondary',NULL),
 ('lifestyle_comfort','lifestyle_choices','primary',NULL),
 ('relationships_belonging','relationships_belonging','primary',NULL),
 ('intimacy_desire','intimacy_sexuality','primary',NULL),
 ('dreams_direction','work_dreams_direction','primary',NULL),
 ('courage_selftrust','instinct_courage_selftrust','primary',NULL),
 ('complete_clarity','physical_medical','context',NULL),
 ('complete_clarity','thoughts_attention','context',NULL),
 ('complete_clarity','beliefs_meaning','context',NULL),
 ('complete_clarity','feelings_regulation','context',NULL),
 ('complete_clarity','personality_values','context',NULL),
 ('complete_clarity','lifestyle_choices','context',NULL),
 ('complete_clarity','relationships_belonging','context',NULL),
 ('complete_clarity','intimacy_sexuality','context',NULL),
 ('complete_clarity','work_dreams_direction','context',NULL),
 ('complete_clarity','instinct_courage_selftrust','context',NULL)
ON DUPLICATE KEY UPDATE
 `mapping_role`=VALUES(`mapping_role`),
 `weight_hint`=VALUES(`weight_hint`);

-- Original discovery item bank. Questions are invitations, not conclusions.
INSERT INTO `ilb_pre10_item`
 (`assessment_key`,`item_key`,`item_order`,`question_text`,`help_text`,`response_type`,`is_optional`,`is_sensitive`,`safety_relevant`,`neutral_reflection_template`,`status`)
VALUES
 ('current_reality','reason_here',1,'What brings you here today?',NULL,'multi_choice',1,0,0,'Would you like to tell us more about what brought you here?','active'),
 ('current_reality','hardest_now',2,'What feels most difficult right now?',NULL,'multi_choice',1,1,1,'What seems to make this feel more or less difficult?','active'),
 ('current_reality','understand_now',3,'What would you most like to understand?',NULL,'multi_choice',1,0,0,'Which part would you like to explore first?','active'),
 ('current_reality','desired_change',4,'If something could feel different, what would you want it to be?',NULL,'long_text',1,1,0,'What would that difference make possible for you?','active'),
 ('current_reality','present_words',5,'Which words feel closest to your present experience?',NULL,'multi_choice',1,0,0,'You chose these words. What do they mean in your life today?','active'),
 ('current_reality','support_now',6,'Who or what currently helps you feel supported?',NULL,'multi_choice',1,1,0,'How would you like support to feel?','active'),

 ('thought_patterns','mind_returns',1,'What does your mind return to most often?',NULL,'multi_choice',1,1,0,'When do you notice these thoughts most?','active'),
 ('thought_patterns','mental_space',2,'How much space do your thoughts seem to leave for the present moment?',NULL,'scale',1,0,0,'What helps create more space?','active'),
 ('thought_patterns','thought_tone',3,'How do you usually speak to yourself inside your mind?',NULL,'single_choice',1,1,0,'Would you like your inner voice to sound different?','active'),
 ('thought_patterns','decision_style',4,'When a decision matters, what do you usually notice first?',NULL,'multi_choice',1,0,0,'Which part of your decision process do you trust most?','active'),
 ('thought_patterns','imagination_direction',5,'Where does your imagination travel more easily?',NULL,'single_choice',1,0,0,'What happens in your body when you imagine each direction?','active'),
 ('thought_patterns','unfinished_thought',6,'Is there a thought or question that feels unfinished?',NULL,'long_text',1,1,0,'What would help you sit with this question safely?','active'),

 ('beliefs_body','body_belief',1,'Which statement feels closest to what you believe about your body today?',NULL,'single_choice',1,1,0,'Where do you think this belief came from?','active'),
 ('beliefs_body','health_belief',2,'What do you currently believe has the greatest influence on your health?',NULL,'multi_choice',1,0,0,'How has this belief shaped your choices?','active'),
 ('beliefs_body','responsibility_belief',3,'What does “my body is my responsibility” mean to you?',NULL,'single_choice',1,1,0,'How would responsibility feel without blame?','active'),
 ('beliefs_body','possibility_belief',4,'When you think about change, what feels possible?',NULL,'scale',1,0,0,'What increases or reduces that sense of possibility?','active'),
 ('beliefs_body','inherited_belief',5,'Are there beliefs about your body or life that may have come from other people?',NULL,'yes_no_unsure',1,1,0,'Would you like to examine which beliefs still feel like yours?','active'),
 ('beliefs_body','love_fear_choice',6,'When an important choice appears, what seems to lead more often?',NULL,'single_choice',1,1,0,'How do love-led and fear-led choices feel different in your body?','active'),

 ('feelings_expression','feelings_present',1,'Which feelings have visited you most often recently?',NULL,'multi_choice',1,1,1,'What seems to be happening when these feelings arrive?','active'),
 ('feelings_expression','feeling_location',2,'Where do you notice feelings in your body?',NULL,'multi_choice',1,0,0,'Does the location or sensation change with the feeling?','active'),
 ('feelings_expression','expression_style',3,'What do you usually do when a feeling becomes strong?',NULL,'multi_choice',1,1,1,'Which responses feel helpful, and which would you like to understand?','active'),
 ('feelings_expression','safe_feelings',4,'With whom, if anyone, do your feelings feel safe to express?',NULL,'multi_choice',1,1,0,'What helps emotional safety feel possible?','active'),
 ('feelings_expression','difficult_feeling',5,'Is any feeling especially difficult to allow or express?',NULL,'multi_choice',1,1,1,'What have you learned about showing this feeling?','active'),
 ('feelings_expression','wanted_feeling',6,'What would you love to feel more often?',NULL,'multi_choice',1,0,0,'What already gives you a glimpse of that feeling?','active'),

 ('body_relationship','body_words',1,'Which words describe your relationship with your body today?',NULL,'multi_choice',1,1,0,'Which word would you most like to understand?','active'),
 ('body_relationship','body_judgement',2,'When you look at your body, what do you tend to notice first?',NULL,'single_choice',1,1,0,'How does noticing this affect the way you treat your body?','active'),
 ('body_relationship','body_touch',3,'How comfortable do you feel touching and caring for your own body?',NULL,'scale',1,1,0,'What makes touch feel comfortable, uncomfortable or neutral?','active'),
 ('body_relationship','body_signals',4,'When your body sends a signal, what do you usually do?',NULL,'multi_choice',1,0,1,'Which body signals feel easiest or hardest to hear?','active'),
 ('body_relationship','body_appreciation',5,'What, if anything, do you appreciate about your body today?',NULL,'long_text',1,1,0,'How does appreciation feel when you allow it?','active'),
 ('body_relationship','body_need',6,'What might your body be asking for more—or less—of?',NULL,'multi_choice',1,0,1,'What makes you think your body may be asking for this?','active'),

 ('values_alignment','values_select',1,'Which values matter most to you at this stage of life?',NULL,'multi_choice',1,0,0,'Which selected value feels most alive right now?','active'),
 ('values_alignment','values_rank',2,'How would you rank the values you selected?',NULL,'rank',1,0,0,'How does this order feel when you see it?','active'),
 ('values_alignment','value_lived',3,'Which important value feels most present in the way you currently live?',NULL,'single_choice',1,0,0,'What helps you live this value?','active'),
 ('values_alignment','value_gap',4,'Which important value has the least space in your current life?',NULL,'single_choice',1,1,0,'How does that difference feel to you?','active'),
 ('values_alignment','value_choice',5,'When values compete, what usually decides your choice?',NULL,'multi_choice',1,1,0,'Would you like anything to guide that choice differently?','active'),

 ('lifestyle_comfort','day_rhythm',1,'How does the rhythm of an ordinary day feel?',NULL,'single_choice',1,0,0,'Which part of the day feels most supportive or demanding?','active'),
 ('lifestyle_comfort','rest_sleep',2,'How do rest and sleep currently fit into your life?',NULL,'single_choice',1,0,1,'What appears to help or disturb rest?','active'),
 ('lifestyle_comfort','self_care',3,'Which acts of personal care happen naturally for you?',NULL,'multi_choice',1,0,0,'Which acts feel comforting, difficult or unimportant today?','active'),
 ('lifestyle_comfort','comfort_zone',4,'What does your comfort zone currently protect you from?',NULL,'multi_choice',1,1,0,'What does it give you, and what might it prevent?','active'),
 ('lifestyle_comfort','automatic_choice',5,'Which choices feel most automatic in your daily life?',NULL,'multi_choice',1,1,1,'When do you first notice the choice becoming automatic?','active'),
 ('lifestyle_comfort','environment_effect',6,'Which parts of your surroundings seem to affect you most?',NULL,'multi_choice',1,0,0,'What change in your surroundings would feel supportive?','active'),

 ('relationships_belonging','relationship_feel',1,'How do your closest relationships generally feel today?',NULL,'multi_choice',1,1,1,'Which relationship feeling would you like to understand?','active'),
 ('relationships_belonging','support_receive',2,'How comfortable are you receiving support?',NULL,'scale',1,1,0,'What makes receiving support easier or harder?','active'),
 ('relationships_belonging','support_give',3,'How often do you give more than feels comfortable?',NULL,'scale',1,1,0,'What do you notice before you cross your own limit?','active'),
 ('relationships_belonging','boundary_voice',4,'When something does not feel right, how easy is it to say so?',NULL,'scale',1,1,1,'What helps your voice feel safer?','active'),
 ('relationships_belonging','belonging_place',5,'Where do you currently experience belonging?',NULL,'multi_choice',1,1,0,'What creates that feeling of belonging?','active'),
 ('relationships_belonging','relationship_wish',6,'What would you like to experience differently in a relationship?',NULL,'long_text',1,1,1,'What would that difference feel like for you?','active'),

 ('intimacy_desire','closeness_meaning',1,'What does intimacy mean to you today?',NULL,'multi_choice',1,1,0,'Has your meaning of intimacy changed over time?','active'),
 ('intimacy_desire','touch_comfort',2,'How does affectionate touch generally feel to you?',NULL,'single_choice',1,1,1,'What helps touch feel safe, wanted or comfortable?','active'),
 ('intimacy_desire','desire_space',3,'How much space does desire currently have in your life?',NULL,'scale',1,1,0,'How do you feel about the space desire currently has?','active'),
 ('intimacy_desire','boundary_comfort',4,'How comfortable are you expressing a boundary or preference?',NULL,'scale',1,1,1,'What might make honest expression feel safer?','active'),
 ('intimacy_desire','closeness_wish',5,'Is there any kind of closeness you would like more—or less—of?',NULL,'long_text',1,1,1,'What would respectful closeness look like for you?','active'),
 ('intimacy_desire','prefer_not',6,'Would you prefer to leave this subject here for now?',NULL,'yes_no_unsure',1,1,0,'Your boundary is complete information.','active'),

 ('dreams_direction','dream_present',1,'What dream, desire or possibility keeps returning to you?',NULL,'long_text',1,1,0,'What feels alive when you imagine it?','active'),
 ('dreams_direction','work_energy',2,'Which kinds of activity make you lose track of time?',NULL,'multi_choice',1,0,0,'What qualities do these activities share?','active'),
 ('dreams_direction','postponed_self',3,'Is there a part of yourself that has been postponed?',NULL,'yes_no_unsure',1,1,0,'What might that part of you want to say?','active'),
 ('dreams_direction','desired_contribution',4,'How would you love to contribute to another person or the world?',NULL,'long_text',1,0,0,'What is one small form that contribution could take?','active'),
 ('dreams_direction','dream_constraint',5,'What seems to stand between you and this direction?',NULL,'multi_choice',1,1,0,'Which constraint feels fixed, and which may be testable?','active'),
 ('dreams_direction','experiment_interest',6,'Would you be willing to try a small, reversible experiment in this direction?',NULL,'yes_no_unsure',1,0,0,'What experiment would feel small enough and meaningful enough?','active'),

 ('courage_selftrust','instinct_signal',1,'How does your instinct usually get your attention?',NULL,'multi_choice',1,0,0,'When has this signal felt useful to notice?','active'),
 ('courage_selftrust','instinct_trust',2,'How much do you currently trust your own inner signal?',NULL,'scale',1,1,0,'What increases or reduces that trust?','active'),
 ('courage_selftrust','fear_response',3,'When fear appears, what do you tend to do first?',NULL,'multi_choice',1,1,1,'What does fear appear to protect?','active'),
 ('courage_selftrust','worthy_fear',4,'What feels important enough to approach even if fear remains?',NULL,'long_text',1,1,0,'What value makes this worth approaching?','active'),
 ('courage_selftrust','confidence_source',5,'Where does confidence seem to come from for you?',NULL,'multi_choice',1,0,0,'Which source feels most available today?','active'),
 ('courage_selftrust','next_choice',6,'What is one choice you may be willing to make from love rather than fear?',NULL,'long_text',1,1,1,'What support would make this choice feel safer and more possible?','active'),

 ('complete_clarity','noticed_connection',1,'What connection have you noticed that you had not seen before?',NULL,'long_text',1,1,0,'Would you like this connection included in your Clarity Map?','active'),
 ('complete_clarity','still_unclear',2,'What still feels unclear or unanswered?',NULL,'long_text',1,1,1,'What kind of information or experience might help?','active'),
 ('complete_clarity','strength_seen',3,'What strength or support have you noticed in yourself or your life?',NULL,'long_text',1,0,0,'How might this strength support your journey?','active'),
 ('complete_clarity','priority_choose',4,'What would you like to understand first during your NAIVE journey?',NULL,'multi_choice',1,0,0,'Why does this feel important now?','active'),
 ('complete_clarity','ready_willing',5,'What are you genuinely willing to notice, practise or experiment with?',NULL,'long_text',1,1,0,'What would make this willingness sustainable?','active'),
 ('complete_clarity','map_words',6,'Which words would you choose for your starting point?',NULL,'multi_choice',1,0,0,'These are your words. Would you like to change or add anything?','active')
ON DUPLICATE KEY UPDATE
 `question_text`=VALUES(`question_text`),
 `help_text`=VALUES(`help_text`),
 `response_type`=VALUES(`response_type`),
 `is_optional`=VALUES(`is_optional`),
 `is_sensitive`=VALUES(`is_sensitive`),
 `safety_relevant`=VALUES(`safety_relevant`),
 `neutral_reflection_template`=VALUES(`neutral_reflection_template`),
 `status`=VALUES(`status`);

-- Common options are attached only where the wording is genuinely shared.
-- Interface-specific option libraries can be expanded without changing the item definitions.
INSERT INTO `ilb_pre10_option` (`item_id`,`option_key`,`option_order`,`option_text`,`numeric_value`,`meaning_note`)
SELECT i.`item_id`, x.`option_key`, x.`option_order`, x.`option_text`, x.`numeric_value`, x.`meaning_note`
FROM `ilb_pre10_item` i
JOIN (
  SELECT 'thought_patterns' assessment_key,'thought_tone' item_key,'kind' option_key,1 option_order,'Kind and encouraging' option_text,NULL numeric_value,NULL meaning_note
  UNION ALL SELECT 'thought_patterns','thought_tone','demanding',2,'Demanding or critical',NULL,NULL
  UNION ALL SELECT 'thought_patterns','thought_tone','worried',3,'Worried or protective',NULL,NULL
  UNION ALL SELECT 'thought_patterns','thought_tone','mixed',4,'It changes',NULL,NULL
  UNION ALL SELECT 'thought_patterns','thought_tone','unsure',5,'I am not sure',NULL,NULL
  UNION ALL SELECT 'thought_patterns','imagination_direction','possibility',1,'Towards possibility',NULL,NULL
  UNION ALL SELECT 'thought_patterns','imagination_direction','risk',2,'Towards what may go wrong',NULL,NULL
  UNION ALL SELECT 'thought_patterns','imagination_direction','past',3,'Towards the past',NULL,NULL
  UNION ALL SELECT 'thought_patterns','imagination_direction','present',4,'Towards the present',NULL,NULL
  UNION ALL SELECT 'thought_patterns','imagination_direction','varies',5,'It varies',NULL,NULL
  UNION ALL SELECT 'beliefs_body','responsibility_belief','care',1,'An opportunity to care for myself',NULL,NULL
  UNION ALL SELECT 'beliefs_body','responsibility_belief','pressure',2,'A pressure I carry',NULL,NULL
  UNION ALL SELECT 'beliefs_body','responsibility_belief','blame',3,'Something that can feel like blame',NULL,NULL
  UNION ALL SELECT 'beliefs_body','responsibility_belief','choice',4,'The freedom to make my own choices',NULL,NULL
  UNION ALL SELECT 'beliefs_body','responsibility_belief','unsure',5,'I am still discovering what it means',NULL,NULL
  UNION ALL SELECT 'beliefs_body','love_fear_choice','love',1,'Love more often',NULL,NULL
  UNION ALL SELECT 'beliefs_body','love_fear_choice','fear',2,'Fear more often',NULL,NULL
  UNION ALL SELECT 'beliefs_body','love_fear_choice','both',3,'A mixture of both',NULL,NULL
  UNION ALL SELECT 'beliefs_body','love_fear_choice','context',4,'It depends on the situation',NULL,NULL
  UNION ALL SELECT 'beliefs_body','love_fear_choice','unsure',5,'I am not sure yet',NULL,NULL
  UNION ALL SELECT 'intimacy_desire','touch_comfort','welcome',1,'Welcome and comforting',NULL,NULL
  UNION ALL SELECT 'intimacy_desire','touch_comfort','context',2,'It depends on the person or situation',NULL,NULL
  UNION ALL SELECT 'intimacy_desire','touch_comfort','neutral',3,'Mostly neutral',NULL,NULL
  UNION ALL SELECT 'intimacy_desire','touch_comfort','uncomfortable',4,'Often uncomfortable',NULL,NULL
  UNION ALL SELECT 'intimacy_desire','touch_comfort','unsure',5,'I am not sure',NULL,NULL
) x ON x.`assessment_key`=i.`assessment_key` AND x.`item_key`=i.`item_key`
WHERE NOT EXISTS (
  SELECT 1 FROM `ilb_pre10_option` o
  WHERE o.`item_id`=i.`item_id` AND o.`option_key`=x.`option_key`
);

-- Every native scale is explicitly anchored. A higher number means "more of
-- the wording in the question", not better, healthier or more worthy.
UPDATE `ilb_pre10_item`
SET `scale_min`=0, `scale_max`=10, `scale_step`=1,
    `scale_low_label`='Not at all',
    `scale_high_label`='Completely'
WHERE `response_type`='scale'
  AND `assessment_key` IN (
    'thought_patterns','beliefs_body','body_relationship',
    'relationships_belonging','intimacy_desire','courage_selftrust'
  );

-- Three neutral answers plus an explicit boundary are available on every
-- yes/no/unsure discovery question.
INSERT INTO `ilb_pre10_option`
 (`item_id`,`option_key`,`option_order`,`option_text`,`numeric_value`,`meaning_note`)
SELECT i.`item_id`,x.`option_key`,x.`option_order`,x.`option_text`,x.`numeric_value`,x.`meaning_note`
FROM `ilb_pre10_item` i
JOIN (
 SELECT 'yes' `option_key`,1 `option_order`,'Yes' `option_text`,1 `numeric_value`,NULL `meaning_note`
 UNION ALL SELECT 'no',2,'No',0,NULL
 UNION ALL SELECT 'unsure',3,'I am not sure',NULL,NULL
 UNION ALL SELECT 'prefer_not',4,'I prefer not to answer',NULL,'A valid boundary; never treated as missing cooperation.'
) x
WHERE i.`response_type`='yes_no_unsure'
  AND NOT EXISTS (
    SELECT 1 FROM `ilb_pre10_option` o
    WHERE o.`item_id`=i.`item_id` AND o.`option_key`=x.`option_key`
  );

COMMIT;

-- Verification: no personal data is returned.
SELECT COUNT(*) AS `pre10_dimensions` FROM `ilb_pre10_dimension` WHERE `status`='active';
SELECT COUNT(*) AS `pre10_days` FROM `ilb_pre10_day`
 WHERE `plan_key`='pre10_clarity' AND `version_label`='1.0';
SELECT
  COUNT(*) AS `assessments`,
  SUM(`assessment_class`='validated') AS `validated`,
  SUM(`assessment_class`='ilb_discovery') AS `ilb_discovery`,
  SUM(`assessment_class`='information_collection') AS `information_collection`
FROM `ilb_pre10_assessment`;
SELECT COUNT(*) AS `discovery_items` FROM `ilb_pre10_item`;
SELECT
 SUM(CASE WHEN `response_type`='scale'
               AND (`scale_min` IS NULL OR `scale_max` IS NULL)
          THEN 1 ELSE 0 END) AS `scales_missing_anchors`,
 SUM(CASE WHEN `response_type` IN ('single_choice','multi_choice','yes_no_unsure')
               AND NOT EXISTS (
                 SELECT 1 FROM `ilb_pre10_option` o WHERE o.`item_id`=i.`item_id`
               )
          THEN 1 ELSE 0 END) AS `choice_items_missing_options`
FROM `ilb_pre10_item` i;
SELECT COUNT(*) AS `day_assessment_routes` FROM `ilb_pre10_day_assessment`
 WHERE `plan_key`='pre10_clarity' AND `version_label`='1.0';
