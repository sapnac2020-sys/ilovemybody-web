-- Phase 47: complete hospital product contract
-- Target: u756742628_ilovemybody
-- Prerequisites: Phases 42, 42B, 42C, 43, 44 and 46.
-- Purpose: make the entire public hospital and private patient experience
-- database-driven. Safe to rerun. Does not change patient-authored records.

START TRANSACTION;

CREATE TABLE IF NOT EXISTS `ilb_product_setting` (
  `setting_key` varchar(100) NOT NULL,
  `setting_group` varchar(60) NOT NULL,
  `value_type` enum('text','integer','decimal','boolean','json','url','colour') NOT NULL,
  `setting_value` longtext NOT NULL,
  `public_readable` tinyint(1) NOT NULL DEFAULT 0,
  `description` varchar(1000) NOT NULL,
  `status` enum('draft','active','retired') NOT NULL DEFAULT 'active',
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`setting_key`),
  KEY `idx_p47_setting_group` (`setting_group`,`status`,`public_readable`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `ilb_hospital_department` (
  `department_key` varchar(80) NOT NULL,
  `display_order` tinyint(3) unsigned NOT NULL,
  `department_name` varchar(160) NOT NULL,
  `short_purpose` varchar(500) NOT NULL,
  `layer_type` enum('human_department','connection_centre','content_department') NOT NULL,
  `route_key` varchar(100) NOT NULL,
  `icon_key` varchar(80) NOT NULL,
  `entry_question` varchar(500) NOT NULL,
  `scope_boundary` varchar(1200) NOT NULL,
  `status` enum('draft','active','retired') NOT NULL DEFAULT 'active',
  PRIMARY KEY (`department_key`),
  UNIQUE KEY `uq_p47_department_order` (`display_order`),
  UNIQUE KEY `uq_p47_department_route` (`route_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `ilb_hospital_room` (
  `room_key` varchar(100) NOT NULL,
  `department_key` varchar(80) NOT NULL,
  `display_order` smallint(5) unsigned NOT NULL,
  `room_name` varchar(180) NOT NULL,
  `room_purpose` varchar(800) NOT NULL,
  `route_key` varchar(100) NOT NULL,
  `data_contract` varchar(500) NOT NULL,
  `access_level` enum('public','registered','consented','staff','reviewer') NOT NULL,
  `status` enum('draft','active','retired') NOT NULL DEFAULT 'active',
  PRIMARY KEY (`room_key`),
  UNIQUE KEY `uq_p47_room_order` (`department_key`,`display_order`),
  UNIQUE KEY `uq_p47_room_route` (`route_key`),
  CONSTRAINT `fk_p47_room_department`
    FOREIGN KEY (`department_key`) REFERENCES `ilb_hospital_department` (`department_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `ilb_navigation_item` (
  `navigation_key` varchar(100) NOT NULL,
  `navigation_group` enum('public_entrance','hospital_lobby','patient_dashboard','footer','utility') NOT NULL,
  `display_order` smallint(5) unsigned NOT NULL,
  `label_text` varchar(160) NOT NULL,
  `route_key` varchar(100) NOT NULL,
  `icon_key` varchar(80) NOT NULL,
  `access_level` enum('public','registered','consented','staff','reviewer') NOT NULL,
  `opens_mode` enum('route','panel','modal','external') NOT NULL DEFAULT 'route',
  `parent_navigation_key` varchar(100) DEFAULT NULL,
  `status` enum('draft','active','retired') NOT NULL DEFAULT 'active',
  PRIMARY KEY (`navigation_key`),
  UNIQUE KEY `uq_p47_nav_order` (`navigation_group`,`display_order`),
  KEY `idx_p47_nav_parent` (`parent_navigation_key`),
  CONSTRAINT `fk_p47_nav_parent`
    FOREIGN KEY (`parent_navigation_key`) REFERENCES `ilb_navigation_item` (`navigation_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `ilb_content_block` (
  `content_key` varchar(120) NOT NULL,
  `surface_key` varchar(100) NOT NULL,
  `slot_key` varchar(100) NOT NULL,
  `locale_code` varchar(12) NOT NULL DEFAULT 'en',
  `eyebrow_text` varchar(180) DEFAULT NULL,
  `heading_text` varchar(700) DEFAULT NULL,
  `body_text` text DEFAULT NULL,
  `primary_action_text` varchar(180) DEFAULT NULL,
  `primary_action_route` varchar(100) DEFAULT NULL,
  `secondary_action_text` varchar(180) DEFAULT NULL,
  `secondary_action_route` varchar(100) DEFAULT NULL,
  `content_class` enum('brand','instruction','medical_boundary','safety','book','evidence','encouragement') NOT NULL,
  `display_order` smallint(5) unsigned NOT NULL DEFAULT 1,
  `status` enum('draft','review','active','retired') NOT NULL DEFAULT 'active',
  PRIMARY KEY (`content_key`,`locale_code`),
  UNIQUE KEY `uq_p47_content_slot` (`surface_key`,`slot_key`,`locale_code`,`display_order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `ilb_theme_option` (
  `theme_key` varchar(80) NOT NULL,
  `theme_name` varchar(120) NOT NULL,
  `accent_hex` char(7) NOT NULL,
  `accent_soft_hex` char(7) NOT NULL,
  `background_light_hex` char(7) NOT NULL DEFAULT '#fffafd',
  `background_dark_hex` char(7) NOT NULL DEFAULT '#0b070d',
  `text_light_hex` char(7) NOT NULL DEFAULT '#211a20',
  `text_dark_hex` char(7) NOT NULL DEFAULT '#fff9fc',
  `is_default` tinyint(1) NOT NULL DEFAULT 0,
  `display_order` tinyint(3) unsigned NOT NULL,
  `status` enum('active','retired') NOT NULL DEFAULT 'active',
  PRIMARY KEY (`theme_key`),
  UNIQUE KEY `uq_p47_theme_order` (`display_order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `ilb_journey_template` (
  `journey_template_key` varchar(80) NOT NULL,
  `version_label` varchar(40) NOT NULL,
  `journey_name` varchar(200) NOT NULL,
  `purpose_text` varchar(1200) NOT NULL,
  `status` enum('draft','active','retired') NOT NULL DEFAULT 'active',
  PRIMARY KEY (`journey_template_key`,`version_label`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `ilb_journey_stage` (
  `journey_template_key` varchar(80) NOT NULL,
  `version_label` varchar(40) NOT NULL,
  `stage_key` varchar(80) NOT NULL,
  `display_order` tinyint(3) unsigned NOT NULL,
  `stage_name` varchar(180) NOT NULL,
  `duration_days` smallint(5) unsigned DEFAULT NULL,
  `duration_rule` varchar(600) NOT NULL,
  `purpose_text` varchar(1200) NOT NULL,
  `entry_rule` varchar(1200) NOT NULL,
  `completion_rule` varchar(1200) NOT NULL,
  `next_stage_key` varchar(80) DEFAULT NULL,
  `is_optional` tinyint(1) NOT NULL DEFAULT 0,
  `status` enum('draft','active','retired') NOT NULL DEFAULT 'active',
  PRIMARY KEY (`journey_template_key`,`version_label`,`stage_key`),
  UNIQUE KEY `uq_p47_stage_order` (`journey_template_key`,`version_label`,`display_order`),
  CONSTRAINT `fk_p47_stage_template`
    FOREIGN KEY (`journey_template_key`,`version_label`)
    REFERENCES `ilb_journey_template` (`journey_template_key`,`version_label`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `ilb_connection_component` (
  `component_key` varchar(80) NOT NULL,
  `component_group` enum('incoming','centre','connector','memory','outgoing','feedback') NOT NULL,
  `display_order` tinyint(3) unsigned NOT NULL,
  `component_name` varchar(180) NOT NULL,
  `plain_language_text` varchar(1000) NOT NULL,
  `scientific_boundary` varchar(1500) NOT NULL,
  `status` enum('draft','active','retired') NOT NULL DEFAULT 'active',
  PRIMARY KEY (`component_key`),
  UNIQUE KEY `uq_p47_connection_order` (`component_group`,`display_order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `ilb_connection_edge` (
  `from_component_key` varchar(80) NOT NULL,
  `to_component_key` varchar(80) NOT NULL,
  `edge_type` enum('carries','integrates','influences','expresses','feeds_back') NOT NULL,
  `directionality` enum('directed','bidirectional') NOT NULL,
  `meaning_text` varchar(1200) NOT NULL,
  `causal_status` enum('mechanistic','causal_supported','association','hypothesis','philosophy') NOT NULL,
  `status` enum('draft','active','retired') NOT NULL DEFAULT 'active',
  PRIMARY KEY (`from_component_key`,`to_component_key`,`edge_type`),
  CONSTRAINT `fk_p47_edge_from`
    FOREIGN KEY (`from_component_key`) REFERENCES `ilb_connection_component` (`component_key`),
  CONSTRAINT `fk_p47_edge_to`
    FOREIGN KEY (`to_component_key`) REFERENCES `ilb_connection_component` (`component_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `ilb_change_stage` (
  `change_stage_key` varchar(80) NOT NULL,
  `display_order` tinyint(3) unsigned NOT NULL,
  `stage_name` varchar(120) NOT NULL,
  `stage_role` enum('state','bridge','process','capacity') NOT NULL,
  `meaning_text` varchar(1000) NOT NULL,
  `next_stage_key` varchar(80) DEFAULT NULL,
  `status` enum('draft','active','retired') NOT NULL DEFAULT 'active',
  PRIMARY KEY (`change_stage_key`),
  UNIQUE KEY `uq_p47_change_order` (`display_order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `ilb_metric_definition` (
  `metric_key` varchar(100) NOT NULL,
  `metric_name` varchar(200) NOT NULL,
  `metric_class` enum('completeness','frequency','proportion','within_person_change','association','safety') NOT NULL,
  `expression_text` varchar(2000) NOT NULL,
  `input_contract` text NOT NULL,
  `output_unit` varchar(80) NOT NULL,
  `minimum_observations` smallint(5) unsigned NOT NULL DEFAULT 1,
  `meaning_text` varchar(1500) NOT NULL,
  `limitation_text` varchar(2000) NOT NULL,
  `frontend_label` varchar(250) NOT NULL,
  `status` enum('draft','review','active','retired') NOT NULL DEFAULT 'review',
  PRIMARY KEY (`metric_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `ilb_product_setting`
 (`setting_key`,`setting_group`,`value_type`,`setting_value`,`public_readable`,`description`,`status`)
VALUES
 ('brand_name','brand','text','I Love My Body',1,'Canonical brand name.','active'),
 ('hospital_name','brand','text','I Love My Body Self-Care Hospital',1,'Canonical hospital name.','active'),
 ('hospital_descriptor','brand','text','Where Health Meets Happiness',1,'Hospital descriptor.','active'),
 ('tagline','brand','text','Everything is connected.',1,'Canonical tagline.','active'),
 ('public_promise','brand','text','Building the world’s first evidence-mapped hospital for non-invasive self-care alongside medical treatment.',1,'Public positioning.','active'),
 ('medical_boundary','safety','text','This platform does not diagnose, prescribe, or change medication. Medical decisions remain with the patient and qualified professionals.',1,'Mandatory boundary wherever treatment is discussed.','active'),
 ('pre_discovery_days','journey','integer','10',1,'Information-gathering period before the first journey.','active'),
 ('first_journey_days','journey','integer','49',1,'First seven-week journey.','active'),
 ('reassessment_days','journey','integer','2',1,'Formal reassessment interval.','active'),
 ('second_journey_days','journey','integer','49',1,'Optional second seven-week journey.','active'),
 ('bot_public_question_limit','bot','integer','3',1,'Registration is required after three public bot questions.','active'),
 ('default_theme_key','appearance','text','neon_pink',1,'Default patient theme.','active'),
 ('responsive_view_count','appearance','integer','7',1,'Required QA viewport families.','active'),
 ('formula_visibility','calculation','text','hidden_by_default',0,'Formula text is internal; source and plain-language meaning remain visible.','active')
ON DUPLICATE KEY UPDATE
 `setting_group`=VALUES(`setting_group`),`value_type`=VALUES(`value_type`),
 `setting_value`=VALUES(`setting_value`),`public_readable`=VALUES(`public_readable`),
 `description`=VALUES(`description`),`status`=VALUES(`status`);

INSERT INTO `ilb_hospital_department`
 (`department_key`,`display_order`,`department_name`,`short_purpose`,`layer_type`,
  `route_key`,`icon_key`,`entry_question`,`scope_boundary`,`status`)
VALUES
 ('connection_centre',1,'Connection Centre','The nervous-system hub that receives, integrates, remembers and responds.','connection_centre','connection','connection','What is your system receiving, remembering and expressing?','A model of communication and observation, not proof that one thought or emotion caused a medical condition.','active'),
 ('body_talk',2,'Body Talk','Physical signals, symptoms, systems and the body’s everyday language.','human_department','body-talk','body','What is your body telling you?','Records lived signals and medical context without assigning diagnosis or cause.','active'),
 ('vitality',3,'Vitality','Sleep, breath, oxygen, movement, nourishment, recovery and usable energy.','human_department','vitality','pulse','What gives you energy—and what uses it?','Personal observation is kept distinct from clinical oxygenation, cardiovascular and metabolic measurements.','active'),
 ('senses',4,'The Senses','Sight, hearing, smell, taste, touch and perception of the world.','human_department','senses','eye','What are you taking in through your senses?','Sensory experience and care do not replace examination for new loss, pain or neurological symptoms.','active'),
 ('feeling',5,'Feeling','Emotions and inner weather: joy, fear, sadness, anger, calm and overwhelm.','human_department','feeling','heart','What are you feeling?','Asks and reflects without labelling a person or converting feelings into diagnosis.','active'),
 ('mind',6,'The Mind','Thoughts, attention, memory, beliefs, imagination, self-talk and mental habits.','human_department','mind','mind','What is occupying your mind?','Discovery questions remain separate from validated clinical psychology instruments.','active'),
 ('expression',7,'Expression','Voice, creativity, boundaries, intimacy, sexuality and what remains unsaid.','human_department','expression','expression','What wants to be expressed?','Sensitive questions are optional, private and never assumed from body location or behaviour.','active'),
 ('self',8,'Self','Self-worth, body relationship, values, identity, meaning, purpose and conscious choice.','human_department','self','self','How are you relating to yourself?','Supports reflection and direction without ranking worth or assigning a personality type.','active'),
 ('book',9,'The Book','Author-owned philosophy, reflections, questions and scoped “Did you know?” content.','content_department','book','book','What would you like to explore from the book?','Book philosophy, encouragement and scientific evidence remain explicitly distinguishable.','active')
ON DUPLICATE KEY UPDATE
 `display_order`=VALUES(`display_order`),`department_name`=VALUES(`department_name`),
 `short_purpose`=VALUES(`short_purpose`),`layer_type`=VALUES(`layer_type`),
 `route_key`=VALUES(`route_key`),`icon_key`=VALUES(`icon_key`),
 `entry_question`=VALUES(`entry_question`),`scope_boundary`=VALUES(`scope_boundary`),
 `status`=VALUES(`status`);

INSERT INTO `ilb_hospital_room`
 (`room_key`,`department_key`,`display_order`,`room_name`,`room_purpose`,
  `route_key`,`data_contract`,`access_level`,`status`)
VALUES
 ('reception','connection_centre',1,'Reception & Registration','Create an account, choose why you are here, review privacy and begin.','reception','registration + pathway + consent','public','active'),
 ('my_dashboard','connection_centre',2,'My Dashboard','One calm view of today, the journey stage, next action, reports, journal and support.','dashboard','v_ilb_patient_dashboard','registered','active'),
 ('medical_records','body_talk',1,'Medical Records','Reports, prescriptions, procedures, medicines and confirmed measurements.','medical-records','subject documents + medicines + measurements','consented','active'),
 ('body_map','body_talk',2,'Body Map','Choose a body region and record a signal, location, intensity and context.','body-map','body signal contract','registered','active'),
 ('daily_checkin','vitality',1,'Daily Check-in','A quick optional check-in across body, feeling, action and context.','daily-checkin','daily snapshot contract','registered','active'),
 ('journal','mind',1,'Private Journal','Write thoughts, memories, desires, questions and reflections without judgement.','journal','journal entry contract','registered','active'),
 ('assessments','self',1,'10-Day Discovery','Scheduled sourced and ILB discovery assessments across the ten dimensions.','discovery','PRE-10 contract','consented','active'),
 ('journey','self',2,'My Journey','First seven weeks, two-day review, optional second seven weeks and continuing self-care.','journey','journey timeline contract','consented','active'),
 ('sources','connection_centre',3,'Evidence & Sources','Plain-language sources, applicability, limitations and review state.','sources','active source catalogue','registered','active'),
 ('book_library','book',1,'Book Library','Approved quotes, prompts and scoped Did You Know content.','book-library','content insight contract','registered','active')
ON DUPLICATE KEY UPDATE
 `department_key`=VALUES(`department_key`),`display_order`=VALUES(`display_order`),
 `room_name`=VALUES(`room_name`),`room_purpose`=VALUES(`room_purpose`),
 `route_key`=VALUES(`route_key`),`data_contract`=VALUES(`data_contract`),
 `access_level`=VALUES(`access_level`),`status`=VALUES(`status`);

INSERT INTO `ilb_navigation_item`
 (`navigation_key`,`navigation_group`,`display_order`,`label_text`,`route_key`,
  `icon_key`,`access_level`,`opens_mode`,`parent_navigation_key`,`status`)
VALUES
 ('enter_hospital','public_entrance',1,'Enter','hospital','enter','public','route',NULL,'active'),
 ('lobby_home','hospital_lobby',1,'Hospital Lobby','hospital','home','public','route',NULL,'active'),
 ('lobby_begin','hospital_lobby',2,'Begin at Reception','reception','reception','public','route',NULL,'active'),
 ('lobby_departments','hospital_lobby',3,'Departments','departments','departments','public','panel',NULL,'active'),
 ('lobby_how','hospital_lobby',4,'How It Works','how-it-works','journey','public','panel',NULL,'active'),
 ('lobby_evidence','hospital_lobby',5,'Evidence','evidence','evidence','public','panel',NULL,'active'),
 ('lobby_book','hospital_lobby',6,'The Book','book','book','public','panel',NULL,'active'),
 ('dashboard_home','patient_dashboard',1,'Today','dashboard','home','registered','panel',NULL,'active'),
 ('dashboard_journey','patient_dashboard',2,'My Journey','journey','journey','registered','panel',NULL,'active'),
 ('dashboard_checkin','patient_dashboard',3,'Check-in','daily-checkin','checkin','registered','panel',NULL,'active'),
 ('dashboard_journal','patient_dashboard',4,'Journal','journal','journal','registered','panel',NULL,'active'),
 ('dashboard_records','patient_dashboard',5,'Reports & Medicines','medical-records','records','registered','panel',NULL,'active'),
 ('dashboard_discovery','patient_dashboard',6,'Discovery','discovery','discovery','registered','panel',NULL,'active'),
 ('dashboard_sources','patient_dashboard',7,'Sources','sources','sources','registered','panel',NULL,'active'),
 ('dashboard_view','patient_dashboard',8,'My View','preferences','appearance','registered','modal',NULL,'active'),
 ('dashboard_help','patient_dashboard',9,'Help & Safety','help','help','registered','modal',NULL,'active')
ON DUPLICATE KEY UPDATE
 `navigation_group`=VALUES(`navigation_group`),`display_order`=VALUES(`display_order`),
 `label_text`=VALUES(`label_text`),`route_key`=VALUES(`route_key`),
 `icon_key`=VALUES(`icon_key`),`access_level`=VALUES(`access_level`),
 `opens_mode`=VALUES(`opens_mode`),`parent_navigation_key`=VALUES(`parent_navigation_key`),
 `status`=VALUES(`status`);

INSERT INTO `ilb_theme_option`
 (`theme_key`,`theme_name`,`accent_hex`,`accent_soft_hex`,`background_light_hex`,
  `background_dark_hex`,`text_light_hex`,`text_dark_hex`,`is_default`,`display_order`,`status`)
VALUES
 ('neon_pink','Neon Pink','#f20883','#ffd8eb','#fffafd','#0b070d','#211a20','#fff9fc',1,1,'active'),
 ('electric_blue','Electric Blue','#168cff','#dcecff','#fbfdff','#060b12','#18212b','#f8fbff',0,2,'active'),
 ('vivid_violet','Vivid Violet','#8b4dff','#eadfff','#fcfaff','#0c0712','#21182c','#fcf9ff',0,3,'active'),
 ('bright_green','Bright Green','#25c86a','#dcf8e7','#fbfffc','#06110b','#16261d','#f8fff9',0,4,'active'),
 ('neon_coral','Neon Coral','#ff536f','#ffe0e5','#fffafb','#130709','#2b181c','#fff9fa',0,5,'active'),
 ('sunny_yellow','Sunny Yellow','#f3c800','#fff4b8','#fffef8','#121005','#29240f','#fffef4',0,6,'active'),
 ('bright_cyan','Bright Cyan','#02c9e8','#d8f9fd','#f9feff','#051012','#12272b','#f7feff',0,7,'active')
ON DUPLICATE KEY UPDATE
 `theme_name`=VALUES(`theme_name`),`accent_hex`=VALUES(`accent_hex`),
 `accent_soft_hex`=VALUES(`accent_soft_hex`),`background_light_hex`=VALUES(`background_light_hex`),
 `background_dark_hex`=VALUES(`background_dark_hex`),`text_light_hex`=VALUES(`text_light_hex`),
 `text_dark_hex`=VALUES(`text_dark_hex`),`is_default`=VALUES(`is_default`),
 `display_order`=VALUES(`display_order`),`status`=VALUES(`status`);

INSERT INTO `ilb_journey_template`
 (`journey_template_key`,`version_label`,`journey_name`,`purpose_text`,`status`)
VALUES
 ('connected_self_care','1.0','Connected self-care journey',
  'A personal sequence that begins with medical context and ten days of discovery, continues through seven weeks of observation and love-led action, pauses for two days of reassessment, and offers a second seven weeks only when chosen and appropriate.',
  'active')
ON DUPLICATE KEY UPDATE
 `journey_name`=VALUES(`journey_name`),`purpose_text`=VALUES(`purpose_text`),`status`=VALUES(`status`);

INSERT INTO `ilb_journey_stage`
 (`journey_template_key`,`version_label`,`stage_key`,`display_order`,`stage_name`,
  `duration_days`,`duration_rule`,`purpose_text`,`entry_rule`,`completion_rule`,
  `next_stage_key`,`is_optional`,`status`)
VALUES
 ('connected_self_care','1.0','registration',1,'Reception & registration',NULL,'Completed at the participant’s pace.','Identity separation, pathway selection, consent and essential profile.','Public visitor chooses to register.','Required consent and essential profile are recorded.','medical_baseline',0,'active'),
 ('connected_self_care','1.0','medical_baseline',2,'Medical starting picture',NULL,'Completed at the participant’s pace.','Collect reports, prescriptions, medicines, procedures, history and confirmed measurements.','Registration and consent are current.','Participant confirms the available medical starting information or explicitly records what is unavailable.','pre10',0,'active'),
 ('connected_self_care','1.0','pre10',3,'10-Day Discovery',10,'Ten scheduled days; pause and resume are permitted.','Understand current life across the ten dimensions through sourced and original discovery routes.','Medical starting picture is acknowledged.','Scheduled items are completed, skipped or marked unavailable and the review is generated.','journey_one',0,'active'),
 ('connected_self_care','1.0','journey_one',4,'First seven weeks',49,'Forty-nine calendar days from activation, with optional daily observations.','Make small intentional choices, record action and consequence, and observe personal patterns.','Discovery review and chosen priorities are confirmed.','Checkpoint is reached, or the participant pauses or withdraws.','reassessment',0,'active'),
 ('connected_self_care','1.0','reassessment',5,'Two-day reassessment',2,'Two dedicated review days after the first journey.','Compare like with like across experience, assessments, reports, medicines and context.','First journey checkpoint is reached.','Comparable, non-comparable and missing information are separated and reviewed.','journey_two',0,'active'),
 ('connected_self_care','1.0','journey_two',6,'Optional second seven weeks',49,'Only created after an explicit participant decision and any required professional review.','Refine the next hypothesis and continue only what is useful.','Reassessment is confirmed and continuation is chosen.','Second checkpoint is reached, or the participant pauses or withdraws.','continuing',1,'active'),
 ('connected_self_care','1.0','continuing',7,'Continuing self-care',NULL,'No fixed duration.','Continue journaling, check-ins, reports, selected support and personal learning.','A journey is completed or paused.','Participant retains control of continuation, export and withdrawal.',NULL,0,'active')
ON DUPLICATE KEY UPDATE
 `display_order`=VALUES(`display_order`),`stage_name`=VALUES(`stage_name`),
 `duration_days`=VALUES(`duration_days`),`duration_rule`=VALUES(`duration_rule`),
 `purpose_text`=VALUES(`purpose_text`),`entry_rule`=VALUES(`entry_rule`),
 `completion_rule`=VALUES(`completion_rule`),`next_stage_key`=VALUES(`next_stage_key`),
 `is_optional`=VALUES(`is_optional`),`status`=VALUES(`status`);

INSERT INTO `ilb_connection_component`
 (`component_key`,`component_group`,`display_order`,`component_name`,
  `plain_language_text`,`scientific_boundary`,`status`)
VALUES
 ('exteroception','incoming',1,'Exteroception','Signals from the outside world through sight, sound, smell, taste and touch.','Established sensory physiology; interpretation depends on context and individual state.','active'),
 ('interoception','incoming',2,'Interoception','Signals about internal body state such as heartbeat, breathing, fullness, pain and temperature.','Established research construct; subjective accuracy varies and is not a diagnosis.','active'),
 ('proprioception','incoming',3,'Proprioception','Signals about body position, movement and effort.','Established sensory physiology; symptoms require appropriate clinical assessment.','active'),
 ('nervous_system','centre',1,'Nervous system','Carries and integrates signals and coordinates responses across the body.','Broad physiological description; the model does not reduce all illness to nervous-system state.','active'),
 ('gut','connector',1,'Gut','A major sensory, immune, metabolic and neural interface.','Gut–brain communication is bidirectional; a specific feeling does not prove a specific gut cause.','active'),
 ('heart','connector',2,'Heart','Circulation, rhythm and internal cardiovascular signals interact with nervous-system regulation.','Clinical heart symptoms and measurements retain medical priority.','active'),
 ('brain','connector',3,'Brain','Integrates perception, memory, prediction, emotion, cognition and action.','A systems description, not a localization of moral character or personal worth.','active'),
 ('memory','memory',1,'Memory & learned pattern','Past experience helps the system interpret present signals and predict what may happen next.','Memory can influence perception and behaviour; retrospective stories do not establish medical causality.','active'),
 ('somatic_expression','outgoing',1,'Somatic expression','Voluntary movement, posture, voice, facial expression and chosen action.','Observable output can have multiple causes and meanings.','active'),
 ('autonomic_response','outgoing',2,'Autonomic response','Changes in heart rate, breathing, digestion, sweating and arousal.','Physiological response varies; consumer measures have device and context limitations.','active'),
 ('neuroendocrine_immune','outgoing',3,'Neuroendocrine–immune response','Hormonal and immune signalling that helps coordinate adaptation.','Complex systems cannot be inferred from mood or a single symptom without measurement.','active'),
 ('consequence_feedback','feedback',1,'Consequence & feedback','What happens after an action becomes new information for learning.','Repeated within-person patterns generate hypotheses, not automatic causal proof.','active')
ON DUPLICATE KEY UPDATE
 `component_group`=VALUES(`component_group`),`display_order`=VALUES(`display_order`),
 `component_name`=VALUES(`component_name`),`plain_language_text`=VALUES(`plain_language_text`),
 `scientific_boundary`=VALUES(`scientific_boundary`),`status`=VALUES(`status`);

INSERT INTO `ilb_connection_edge`
 (`from_component_key`,`to_component_key`,`edge_type`,`directionality`,
  `meaning_text`,`causal_status`,`status`)
VALUES
 ('exteroception','nervous_system','carries','directed','External sensory information enters nervous-system processing.','mechanistic','active'),
 ('interoception','nervous_system','carries','directed','Internal body information enters nervous-system processing.','mechanistic','active'),
 ('proprioception','nervous_system','carries','directed','Position and movement information enters nervous-system processing.','mechanistic','active'),
 ('nervous_system','gut','influences','bidirectional','Neural, endocrine, immune and metabolic pathways support gut–brain communication.','mechanistic','active'),
 ('nervous_system','heart','influences','bidirectional','Autonomic and cardiovascular signals interact continuously.','mechanistic','active'),
 ('nervous_system','brain','integrates','bidirectional','Central and peripheral nervous processes coordinate perception and response.','mechanistic','active'),
 ('memory','brain','influences','bidirectional','Learned experience shapes interpretation, prediction and later memory.','causal_supported','active'),
 ('nervous_system','somatic_expression','expresses','directed','Integrated state can be expressed through voluntary action and movement.','mechanistic','active'),
 ('nervous_system','autonomic_response','expresses','directed','Integrated state can be expressed through autonomic change.','mechanistic','active'),
 ('nervous_system','neuroendocrine_immune','expresses','directed','Nervous, endocrine and immune systems communicate bidirectionally.','mechanistic','active'),
 ('somatic_expression','consequence_feedback','feeds_back','directed','Action creates consequences and new observations.','causal_supported','active'),
 ('autonomic_response','consequence_feedback','feeds_back','directed','Body response becomes new internal information.','mechanistic','active'),
 ('neuroendocrine_immune','consequence_feedback','feeds_back','directed','Physiological change contributes new system information.','mechanistic','active'),
 ('consequence_feedback','memory','feeds_back','directed','Observed consequences may update learning and later choices.','causal_supported','active')
ON DUPLICATE KEY UPDATE
 `directionality`=VALUES(`directionality`),`meaning_text`=VALUES(`meaning_text`),
 `causal_status`=VALUES(`causal_status`),`status`=VALUES(`status`);

INSERT INTO `ilb_change_stage`
 (`change_stage_key`,`display_order`,`stage_name`,`stage_role`,`meaning_text`,`next_stage_key`,`status`)
VALUES
 ('clutter',1,'Clutter','state','Too many competing signals, tasks, objects, thoughts or unresolved inputs.','confusion','active'),
 ('confusion',2,'Confusion','state','The person cannot yet see what matters, what connects or what to choose.','comfort_zone','active'),
 ('comfort_zone',3,'Comfort Zone','state','A familiar pattern offers short-term relief or certainty, even when it no longer helps.','action','active'),
 ('action',4,'Action','bridge','A choice becomes something done, avoided, expressed or repeated.','consequence','active'),
 ('consequence',5,'Consequence','bridge','The action creates an experience, result or cost that can be observed.','conscience','active'),
 ('conscience',6,'Conscience','capacity','The person notices whether the consequence aligns with values, responsibility and self-respect.','change','active'),
 ('change',7,'Change','process','A different choice is tried and its result is observed.','cleanliness','active'),
 ('cleanliness',8,'Cleanliness','capacity','Noise is reduced and physical, mental or relational space becomes easier to read.','cohesion','active'),
 ('cohesion',9,'Cohesion','capacity','Parts of life begin to work together rather than against one another.','class','active'),
 ('class',10,'Class','capacity','Dignity, grace and self-respect shape how choices are made and expressed.','clarity','active'),
 ('clarity',11,'Clarity','capacity','Intent, priorities, choices and likely consequences become more visible.','clairvoyance','active'),
 ('clairvoyance',12,'Clairvoyance','capacity','Pattern-based foresight: seeing a likely consequence earlier, without claiming supernatural prediction.','conscious_awareness','active'),
 ('conscious_awareness',13,'Conscious Awareness','capacity','The person can notice intent and choose a response rather than repeat an automatic reaction.','clutter','active')
ON DUPLICATE KEY UPDATE
 `display_order`=VALUES(`display_order`),`stage_name`=VALUES(`stage_name`),
 `stage_role`=VALUES(`stage_role`),`meaning_text`=VALUES(`meaning_text`),
 `next_stage_key`=VALUES(`next_stage_key`),`status`=VALUES(`status`);

INSERT INTO `ilb_metric_definition`
 (`metric_key`,`metric_name`,`metric_class`,`expression_text`,`input_contract`,
  `output_unit`,`minimum_observations`,`meaning_text`,`limitation_text`,
  `frontend_label`,`status`)
VALUES
 ('information_coverage','Information coverage','completeness','answered_or_explicitly_skipped_required_items / routed_required_items * 100','Routed assessment items and latest response status.','percent',1,'How much of the routed starting information is available.','Coverage is not health, happiness, worth, diagnosis or energy.','Your starting picture','active'),
 ('checkin_consistency','Check-in consistency','frequency','distinct_checkin_days / eligible_days * 100','Journey dates and submitted daily snapshots.','percent',7,'How often the participant chose to record an observation.','Missing check-ins may reflect choice, access or circumstance and must not be judged as failure.','Days you chose to check in','active'),
 ('love_led_choice_ratio','Love-led choice ratio','proportion','love_led_choices / classified_choices * 100','Participant-classified choice events only.','percent',5,'The share of classified choices the participant described as love-led.','Self-description is contextual and is not a clinical measure or moral score.','Choices led by love','active'),
 ('action_follow_through','Action follow-through','proportion','completed_intended_actions / actions_with_declared_intention * 100','Declared intention, action and completion state.','percent',5,'How often an intended action was recorded as attempted or completed.','Does not measure character, motivation or worth; barriers and missing data must remain visible.','Actions tried','active'),
 ('personal_response_delta','Personal response change','within_person_change','comparable_followup_value - comparable_baseline_value','Same marker or item, compatible unit, method, context and time window.','source_unit',2,'Change between comparable observations for the same person.','Change does not by itself show cause, cure or need for medication change.','What changed','active'),
 ('signal_action_pattern','Signal–action pattern frequency','association','matching_signal_action_outcome_sequences / eligible_sequences * 100','Timestamped signal, action and later outcome with declared windows.','percent',5,'How often a particular sequence appeared in this person’s records.','An observed sequence is a hypothesis for discussion, not proof that the action caused the outcome.','A pattern worth noticing','active'),
 ('safety_override','Safety override','safety','1 when any configured urgent rule is open, otherwise 0','Open safety flags and configured safety policy.','boolean',1,'Whether ordinary app feedback must be replaced by urgent routing.','The app cannot assess emergency severity; local emergency and clinical services take priority.','Please seek help now','active')
ON DUPLICATE KEY UPDATE
 `metric_name`=VALUES(`metric_name`),`metric_class`=VALUES(`metric_class`),
 `expression_text`=VALUES(`expression_text`),`input_contract`=VALUES(`input_contract`),
 `output_unit`=VALUES(`output_unit`),`minimum_observations`=VALUES(`minimum_observations`),
 `meaning_text`=VALUES(`meaning_text`),`limitation_text`=VALUES(`limitation_text`),
 `frontend_label`=VALUES(`frontend_label`),`status`=VALUES(`status`);

INSERT INTO `ilb_content_block`
 (`content_key`,`surface_key`,`slot_key`,`locale_code`,`eyebrow_text`,`heading_text`,
  `body_text`,`primary_action_text`,`primary_action_route`,`secondary_action_text`,
  `secondary_action_route`,`content_class`,`display_order`,`status`)
VALUES
 ('entrance_hero','public_entrance','hero','en','I LOVE MY BODY','Health & Happiness Hospital','Building the world’s first evidence-mapped hospital for non-invasive self-care alongside medical treatment.','ENTER','hospital',NULL,NULL,'brand',1,'active'),
 ('entrance_tagline','public_entrance','tagline','en',NULL,'Everything is connected.',NULL,NULL,NULL,NULL,NULL,'brand',1,'active'),
 ('lobby_welcome','hospital_lobby','hero','en','WELCOME','Where Health Meets Happiness','Begin at Reception, explore the hospital, or learn how the connected self-care journey works.','Begin at Reception','reception','Explore the hospital','departments','instruction',1,'active'),
 ('registration_reason','reception','reason','en','BEGIN HERE','Why are you here?','Choose one or more. These are starting points—not labels.','Continue','registration',NULL,NULL,'instruction',1,'active'),
 ('dashboard_today','patient_dashboard','hero','en','TODAY','One clear step at a time.','Your dashboard shows where you are, why the next step matters, and the one action you can take now.','Continue my next step','current-step','Quick check-in','daily-checkin','instruction',1,'active'),
 ('medical_boundary','global','medical_boundary','en',NULL,NULL,'No diagnosis or medicine change is made by automation. Medical decisions remain with you and qualified professionals.',NULL,NULL,NULL,NULL,'medical_boundary',1,'active'),
 ('bot_gate','bot','registration_gate','en','LET US CONTINUE PRIVATELY','Would you like to create your private space?','You may ask three public questions. Registration is required before continuing or saving personal information.','Create my private space','reception','Not now','hospital','instruction',1,'active')
ON DUPLICATE KEY UPDATE
 `surface_key`=VALUES(`surface_key`),`slot_key`=VALUES(`slot_key`),
 `eyebrow_text`=VALUES(`eyebrow_text`),`heading_text`=VALUES(`heading_text`),
 `body_text`=VALUES(`body_text`),`primary_action_text`=VALUES(`primary_action_text`),
 `primary_action_route`=VALUES(`primary_action_route`),
 `secondary_action_text`=VALUES(`secondary_action_text`),
 `secondary_action_route`=VALUES(`secondary_action_route`),
 `content_class`=VALUES(`content_class`),`display_order`=VALUES(`display_order`),
 `status`=VALUES(`status`);

COMMIT;

SELECT COUNT(*) AS `active_departments`
FROM `ilb_hospital_department` WHERE `status`='active';
SELECT COUNT(*) AS `active_navigation_items`
FROM `ilb_navigation_item` WHERE `status`='active';
SELECT COUNT(*) AS `active_journey_stages`
FROM `ilb_journey_stage` WHERE `status`='active';
SELECT COUNT(*) AS `active_connection_components`
FROM `ilb_connection_component` WHERE `status`='active';
SELECT COUNT(*) AS `active_change_stages`
FROM `ilb_change_stage` WHERE `status`='active';
