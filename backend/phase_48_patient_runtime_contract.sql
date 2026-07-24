-- Phase 48: patient runtime, registration, preferences and dashboard contract
-- Target: u756742628_ilovemybody
-- Prerequisite: Phase 47.
-- Safe to rerun. Existing canonical medical and PRE-10 tables remain primary.

START TRANSACTION;

CREATE TABLE IF NOT EXISTS `ilb_account` (
  `account_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `subject_key` varchar(80) NOT NULL,
  `mobile_e164_hash` char(64) NOT NULL,
  `mobile_last4` char(4) NOT NULL,
  `pin_hash` varchar(255) NOT NULL,
  `display_name` varchar(160) DEFAULT NULL,
  `preferred_locale` varchar(12) NOT NULL DEFAULT 'en',
  `failed_login_count` smallint(5) unsigned NOT NULL DEFAULT 0,
  `locked_until` datetime DEFAULT NULL,
  `last_login_at` datetime DEFAULT NULL,
  `status` enum('pending','active','locked','withdrawn','deleted') NOT NULL DEFAULT 'pending',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`account_id`),
  UNIQUE KEY `uq_p48_account_subject` (`subject_key`),
  UNIQUE KEY `uq_p48_account_mobile_hash` (`mobile_e164_hash`),
  KEY `idx_p48_account_status` (`status`,`locked_until`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `ilb_account_session` (
  `account_session_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `account_id` bigint(20) unsigned NOT NULL,
  `token_hash` char(64) NOT NULL,
  `csrf_token_hash` char(64) NOT NULL,
  `issued_at` datetime NOT NULL,
  `expires_at` datetime NOT NULL,
  `last_seen_at` datetime DEFAULT NULL,
  `revoked_at` datetime DEFAULT NULL,
  `client_fingerprint_hash` char(64) DEFAULT NULL,
  `status` enum('active','expired','revoked') NOT NULL DEFAULT 'active',
  PRIMARY KEY (`account_session_id`),
  UNIQUE KEY `uq_p48_session_token` (`token_hash`),
  KEY `idx_p48_session_account` (`account_id`,`status`,`expires_at`),
  CONSTRAINT `fk_p48_session_account`
    FOREIGN KEY (`account_id`) REFERENCES `ilb_account` (`account_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `ilb_registration_state` (
  `registration_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `account_id` bigint(20) unsigned NOT NULL,
  `current_stage` enum('identity','reason','consent','profile','complete') NOT NULL DEFAULT 'identity',
  `identity_complete` tinyint(1) NOT NULL DEFAULT 0,
  `reason_complete` tinyint(1) NOT NULL DEFAULT 0,
  `consent_complete` tinyint(1) NOT NULL DEFAULT 0,
  `profile_complete` tinyint(1) NOT NULL DEFAULT 0,
  `completed_at` datetime DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`registration_id`),
  UNIQUE KEY `uq_p48_registration_account` (`account_id`),
  CONSTRAINT `fk_p48_registration_account`
    FOREIGN KEY (`account_id`) REFERENCES `ilb_account` (`account_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `ilb_subject_preference` (
  `subject_key` varchar(80) NOT NULL,
  `theme_key` varchar(80) NOT NULL DEFAULT 'neon_pink',
  `background_mode` enum('soft_light','colour_wash','soft_dark','system') NOT NULL DEFAULT 'colour_wash',
  `text_size` enum('compact','comfortable','large') NOT NULL DEFAULT 'comfortable',
  `reduced_motion` tinyint(1) NOT NULL DEFAULT 0,
  `high_contrast` tinyint(1) NOT NULL DEFAULT 0,
  `font_mode` enum('elegant','classic','clear') NOT NULL DEFAULT 'clear',
  `reminder_opt_in` tinyint(1) NOT NULL DEFAULT 0,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`subject_key`),
  KEY `idx_p48_preference_theme` (`theme_key`),
  CONSTRAINT `fk_p48_preference_theme`
    FOREIGN KEY (`theme_key`) REFERENCES `ilb_theme_option` (`theme_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `ilb_patient_journey` (
  `patient_journey_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `subject_key` varchar(80) NOT NULL,
  `journey_template_key` varchar(80) NOT NULL,
  `version_label` varchar(40) NOT NULL,
  `current_stage_key` varchar(80) NOT NULL,
  `stage_started_on` date NOT NULL,
  `journey_started_at` datetime NOT NULL,
  `last_activity_at` datetime DEFAULT NULL,
  `paused_at` datetime DEFAULT NULL,
  `completed_at` datetime DEFAULT NULL,
  `status` enum('draft','active','paused','completed','withdrawn') NOT NULL DEFAULT 'draft',
  PRIMARY KEY (`patient_journey_id`),
  KEY `idx_p48_journey_subject` (`subject_key`,`status`),
  KEY `idx_p48_journey_stage` (`journey_template_key`,`version_label`,`current_stage_key`),
  CONSTRAINT `fk_p48_journey_stage`
    FOREIGN KEY (`journey_template_key`,`version_label`,`current_stage_key`)
    REFERENCES `ilb_journey_stage` (`journey_template_key`,`version_label`,`stage_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `ilb_journey_stage_event` (
  `journey_stage_event_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `patient_journey_id` bigint(20) unsigned NOT NULL,
  `stage_key` varchar(80) NOT NULL,
  `event_type` enum('entered','progressed','paused','resumed','completed','skipped','withdrawn') NOT NULL,
  `occurred_at` datetime NOT NULL,
  `actor_type` enum('participant','staff','system') NOT NULL,
  `reason_text` varchar(1500) DEFAULT NULL,
  `receipt_json` longtext DEFAULT NULL,
  PRIMARY KEY (`journey_stage_event_id`),
  KEY `idx_p48_stage_event_journey` (`patient_journey_id`,`occurred_at`),
  CONSTRAINT `fk_p48_stage_event_journey`
    FOREIGN KEY (`patient_journey_id`) REFERENCES `ilb_patient_journey` (`patient_journey_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `ilb_journal_entry` (
  `journal_entry_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `subject_key` varchar(80) NOT NULL,
  `patient_journey_id` bigint(20) unsigned DEFAULT NULL,
  `entry_at` datetime NOT NULL,
  `prompt_key` varchar(100) DEFAULT NULL,
  `title_text` varchar(300) DEFAULT NULL,
  `entry_text` longtext NOT NULL,
  `participant_visibility` enum('private','share_with_selected_reviewer') NOT NULL DEFAULT 'private',
  `status` enum('draft','saved','shared','withdrawn') NOT NULL DEFAULT 'saved',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`journal_entry_id`),
  KEY `idx_p48_journal_subject` (`subject_key`,`entry_at`),
  KEY `idx_p48_journal_journey` (`patient_journey_id`),
  CONSTRAINT `fk_p48_journal_journey`
    FOREIGN KEY (`patient_journey_id`) REFERENCES `ilb_patient_journey` (`patient_journey_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `ilb_intent_choice_event` (
  `choice_event_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `subject_key` varchar(80) NOT NULL,
  `patient_journey_id` bigint(20) unsigned DEFAULT NULL,
  `occurred_at` datetime NOT NULL,
  `context_text` text DEFAULT NULL,
  `trigger_text` text DEFAULT NULL,
  `noticed_intent_text` text DEFAULT NULL,
  `intent_awareness` enum('not_known','partly_known','clear','retrospective') NOT NULL DEFAULT 'not_known',
  `choice_text` text NOT NULL,
  `choice_mode` enum('automatic_reaction','fear_led','mixed','love_led','not_classified') NOT NULL DEFAULT 'not_classified',
  `change_stage_key` varchar(80) DEFAULT NULL,
  `confidence_score` tinyint(3) unsigned DEFAULT NULL,
  `status` enum('draft','saved','withdrawn') NOT NULL DEFAULT 'saved',
  PRIMARY KEY (`choice_event_id`),
  KEY `idx_p48_choice_subject` (`subject_key`,`occurred_at`),
  KEY `idx_p48_choice_journey` (`patient_journey_id`),
  KEY `idx_p48_choice_change` (`change_stage_key`),
  CONSTRAINT `fk_p48_choice_journey`
    FOREIGN KEY (`patient_journey_id`) REFERENCES `ilb_patient_journey` (`patient_journey_id`),
  CONSTRAINT `fk_p48_choice_change`
    FOREIGN KEY (`change_stage_key`) REFERENCES `ilb_change_stage` (`change_stage_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `ilb_choice_action` (
  `choice_action_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `choice_event_id` bigint(20) unsigned NOT NULL,
  `action_at` datetime DEFAULT NULL,
  `action_text` text NOT NULL,
  `action_type` enum('food','water','rest','sleep','movement','breathing','expression','conversation','work','environment','self_touch','professional_help','medicine_as_prescribed','other','no_action') NOT NULL,
  `completion_state` enum('intended','started','completed','not_done','not_applicable') NOT NULL DEFAULT 'intended',
  `barrier_text` varchar(1200) DEFAULT NULL,
  PRIMARY KEY (`choice_action_id`),
  KEY `idx_p48_action_choice` (`choice_event_id`,`action_at`),
  CONSTRAINT `fk_p48_action_choice`
    FOREIGN KEY (`choice_event_id`) REFERENCES `ilb_intent_choice_event` (`choice_event_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `ilb_action_consequence` (
  `consequence_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `choice_action_id` bigint(20) unsigned NOT NULL,
  `observed_at` datetime NOT NULL,
  `observation_window` varchar(160) DEFAULT NULL,
  `body_effect_text` text DEFAULT NULL,
  `feeling_effect_text` text DEFAULT NULL,
  `thought_effect_text` text DEFAULT NULL,
  `relationship_effect_text` text DEFAULT NULL,
  `practical_effect_text` text DEFAULT NULL,
  `direction` enum('helped','no_noticeable_change','mixed','did_not_help','unclear') NOT NULL DEFAULT 'unclear',
  `participant_meaning_text` text DEFAULT NULL,
  `causal_claim_allowed` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`consequence_id`),
  KEY `idx_p48_consequence_action` (`choice_action_id`,`observed_at`),
  CONSTRAINT `fk_p48_consequence_action`
    FOREIGN KEY (`choice_action_id`) REFERENCES `ilb_choice_action` (`choice_action_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `ilb_bot_conversation` (
  `conversation_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `public_session_hash` char(64) NOT NULL,
  `subject_key` varchar(80) DEFAULT NULL,
  `started_at` datetime NOT NULL,
  `last_message_at` datetime DEFAULT NULL,
  `public_question_count` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `registration_gate_shown_at` datetime DEFAULT NULL,
  `status` enum('public','registration_required','registered','closed') NOT NULL DEFAULT 'public',
  PRIMARY KEY (`conversation_id`),
  UNIQUE KEY `uq_p48_bot_public_session` (`public_session_hash`),
  KEY `idx_p48_bot_subject` (`subject_key`,`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `ilb_bot_message` (
  `message_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `conversation_id` bigint(20) unsigned NOT NULL,
  `message_order` smallint(5) unsigned NOT NULL,
  `sender_type` enum('visitor','bot','system') NOT NULL,
  `message_text` text NOT NULL,
  `intent_key` varchar(100) DEFAULT NULL,
  `source_payload_json` longtext DEFAULT NULL,
  `safety_route_key` varchar(100) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  PRIMARY KEY (`message_id`),
  UNIQUE KEY `uq_p48_bot_message_order` (`conversation_id`,`message_order`),
  CONSTRAINT `fk_p48_bot_message_conversation`
    FOREIGN KEY (`conversation_id`) REFERENCES `ilb_bot_conversation` (`conversation_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `ilb_data_contract` (
  `contract_key` varchar(100) NOT NULL,
  `contract_version` varchar(40) NOT NULL,
  `http_method` enum('GET','POST','PATCH','DELETE') NOT NULL,
  `route_path` varchar(200) NOT NULL,
  `access_level` enum('public','registered','consented','staff','reviewer') NOT NULL,
  `request_schema_json` longtext DEFAULT NULL,
  `response_schema_json` longtext NOT NULL,
  `handler_rule` varchar(2000) NOT NULL,
  `status` enum('draft','active','retired') NOT NULL DEFAULT 'active',
  PRIMARY KEY (`contract_key`,`contract_version`),
  UNIQUE KEY `uq_p48_contract_route` (`http_method`,`route_path`,`contract_version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `ilb_data_contract`
 (`contract_key`,`contract_version`,`http_method`,`route_path`,`access_level`,
  `request_schema_json`,`response_schema_json`,`handler_rule`,`status`)
VALUES
 ('public_bootstrap','1.0','GET','/v1/public/bootstrap','public',NULL,
  '{"brand":"object","content":"array","navigation":"array","departments":"array","settings":"object"}',
  'Return active public-readable records only; never return patient data.','active'),
 ('registration_start','1.0','POST','/v1/registration','public',
  '{"mobile_e164":"string","pin":"six_digits","display_name":"optional_string"}',
  '{"registration_id":"integer","next_stage":"string"}',
  'Normalize mobile, store only a keyed hash plus last four digits, hash PIN with password_hash, rate-limit, and do not log raw credentials.','active'),
 ('login','1.0','POST','/v1/session','public',
  '{"mobile_e164":"string","pin":"six_digits"}',
  '{"authenticated":"boolean","csrf_token":"string","expires_at":"datetime"}',
  'Rate-limit by account and network, use constant-time password verification, rotate session and CSRF tokens, and return a generic failure message.','active'),
 ('patient_dashboard','1.0','GET','/v1/me/dashboard','registered',NULL,
  '{"profile":"object","journey":"object","next_action":"object","progress":"object","navigation":"array","preference":"object"}',
  'Resolve subject only from the authenticated session; never accept subject_key from the browser.','active'),
 ('patient_preference','1.0','PATCH','/v1/me/preference','registered',
  '{"theme_key":"string","background_mode":"enum","text_size":"enum","reduced_motion":"boolean","font_mode":"enum"}',
  '{"preference":"object"}',
  'Validate against active theme and declared enumerations.','active'),
 ('patient_journal','1.0','POST','/v1/me/journal','registered',
  '{"entry_text":"string","prompt_key":"optional_string","visibility":"enum"}',
  '{"journal_entry_id":"integer","saved_at":"datetime"}',
  'Store participant text verbatim, protect it as private by default, and never send it to analytics or a reviewer without explicit sharing state.','active'),
 ('choice_consequence','1.0','POST','/v1/me/choice','registered',
  '{"trigger":"optional_string","intent":"optional_string","choice":"string","choice_mode":"enum","action":"optional_object","consequence":"optional_object"}',
  '{"choice_event_id":"integer","next_prompt":"object"}',
  'Record participant classifications without moral judgement or causal inference.','active'),
 ('bot_message','1.0','POST','/v1/bot/message','public',
  '{"public_session":"string","message":"string"}',
  '{"answer":"string","sources":"array","questions_remaining":"integer","registration_required":"boolean"}',
  'After three visitor questions set registration_required and return the registration gate; safety routing overrides the ordinary gate.','active')
ON DUPLICATE KEY UPDATE
 `http_method`=VALUES(`http_method`),`route_path`=VALUES(`route_path`),
 `access_level`=VALUES(`access_level`),`request_schema_json`=VALUES(`request_schema_json`),
 `response_schema_json`=VALUES(`response_schema_json`),`handler_rule`=VALUES(`handler_rule`),
 `status`=VALUES(`status`);

DROP VIEW IF EXISTS `v_ilb_public_hospital_bootstrap`;
CREATE VIEW `v_ilb_public_hospital_bootstrap` AS
SELECT 'setting' AS `record_type`,s.`setting_group` AS `record_group`,
       s.`setting_key` AS `record_key`,s.`setting_value` AS `label_text`,
       s.`description` AS `detail_text`,NULL AS `route_key`,0 AS `display_order`
FROM `ilb_product_setting` s
WHERE s.`status`='active' AND s.`public_readable`=1
UNION ALL
SELECT 'department',d.`layer_type`,d.`department_key`,d.`department_name`,
       d.`short_purpose`,d.`route_key`,d.`display_order`
FROM `ilb_hospital_department` d WHERE d.`status`='active'
UNION ALL
SELECT 'navigation',n.`navigation_group`,n.`navigation_key`,n.`label_text`,
       n.`icon_key`,n.`route_key`,n.`display_order`
FROM `ilb_navigation_item` n
WHERE n.`status`='active' AND n.`access_level`='public'
UNION ALL
SELECT 'content',c.`surface_key`,c.`content_key`,
       COALESCE(c.`heading_text`,c.`eyebrow_text`),
       c.`body_text`,c.`primary_action_route`,c.`display_order`
FROM `ilb_content_block` c
WHERE c.`status`='active' AND c.`locale_code`='en';

DROP VIEW IF EXISTS `v_ilb_journey_contract`;
CREATE VIEW `v_ilb_journey_contract` AS
SELECT t.`journey_template_key`,t.`version_label`,t.`journey_name`,
       s.`stage_key`,s.`display_order`,s.`stage_name`,s.`duration_days`,
       s.`duration_rule`,s.`purpose_text`,s.`entry_rule`,s.`completion_rule`,
       s.`next_stage_key`,s.`is_optional`
FROM `ilb_journey_template` t
JOIN `ilb_journey_stage` s
  ON s.`journey_template_key`=t.`journey_template_key`
 AND s.`version_label`=t.`version_label`
WHERE t.`status`='active' AND s.`status`='active';

DROP VIEW IF EXISTS `v_ilb_connection_contract`;
CREATE VIEW `v_ilb_connection_contract` AS
SELECT c.`component_key`,c.`component_group`,c.`display_order`,
       c.`component_name`,c.`plain_language_text`,c.`scientific_boundary`,
       e.`to_component_key`,e.`edge_type`,e.`directionality`,
       e.`meaning_text` AS `edge_meaning`,e.`causal_status`
FROM `ilb_connection_component` c
LEFT JOIN `ilb_connection_edge` e
  ON e.`from_component_key`=c.`component_key` AND e.`status`='active'
WHERE c.`status`='active';

DROP VIEW IF EXISTS `v_ilb_patient_dashboard`;
CREATE VIEW `v_ilb_patient_dashboard` AS
SELECT j.`subject_key`,j.`patient_journey_id`,j.`status` AS `journey_status`,
       j.`current_stage_key`,s.`stage_name`,s.`purpose_text`,
       s.`duration_days`,s.`completion_rule`,s.`next_stage_key`,
       j.`stage_started_on`,j.`last_activity_at`,
       DATEDIFF(CURRENT_DATE,j.`stage_started_on`)+1 AS `stage_day_number`,
       CASE
         WHEN s.`duration_days` IS NULL THEN NULL
         WHEN DATEDIFF(CURRENT_DATE,j.`stage_started_on`)+1 < 1 THEN 0
         WHEN DATEDIFF(CURRENT_DATE,j.`stage_started_on`)+1 > s.`duration_days` THEN 100
         ELSE ROUND((DATEDIFF(CURRENT_DATE,j.`stage_started_on`)+1) * 100 / s.`duration_days`,0)
       END AS `time_progress_percent`,
       p.`theme_key`,p.`background_mode`,p.`text_size`,
       p.`font_mode`,p.`reduced_motion`
FROM `ilb_patient_journey` j
JOIN `ilb_journey_stage` s
  ON s.`journey_template_key`=j.`journey_template_key`
 AND s.`version_label`=j.`version_label`
 AND s.`stage_key`=j.`current_stage_key`
LEFT JOIN `ilb_subject_preference` p ON p.`subject_key`=j.`subject_key`
WHERE j.`status` IN ('draft','active','paused');

COMMIT;

SELECT COUNT(*) AS `active_api_contracts`
FROM `ilb_data_contract` WHERE `status`='active';
SELECT COUNT(*) AS `active_themes`
FROM `ilb_theme_option` WHERE `status`='active';
