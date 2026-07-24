-- Phase 45: ten-point Redikall/minor-chakra pilot
-- Target: u756742628_ilovemybody
-- Prerequisite: Phase 44.
-- Source supplied by the project owner as photographed printed pages 130-131
-- on 24 July 2026. Book title, edition and reuse permission are still pending.
-- Safe to rerun.
--
-- This is a separate traditional/proprietary map layer. It is not acupuncture,
-- anatomy, diagnosis, causation or a treatment recommendation.

START TRANSACTION;

CREATE TABLE IF NOT EXISTS `ilb_energy_map_system` (
  `energy_map_system_key` varchar(80) NOT NULL,
  `system_name` varchar(255) NOT NULL,
  `originator_or_tradition` varchar(255) DEFAULT NULL,
  `system_description` varchar(1500) NOT NULL,
  `evidence_class` enum('traditional','proprietary_framework','research_hypothesis','personal_observation') NOT NULL,
  `public_display_status` enum('blocked','internal_pilot','approved') NOT NULL DEFAULT 'blocked',
  `boundary_text` varchar(1500) NOT NULL,
  `status` enum('candidate','review','active','retired') NOT NULL DEFAULT 'review',
  PRIMARY KEY (`energy_map_system_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `ilb_energy_map_source` (
  `energy_map_source_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `energy_map_system_key` varchar(80) NOT NULL,
  `source_type` enum('book','course','app','card','website','owner_supplied_image','other') NOT NULL,
  `title` varchar(500) DEFAULT NULL,
  `creator` varchar(255) DEFAULT NULL,
  `edition_or_version` varchar(160) DEFAULT NULL,
  `source_locator` varchar(255) NOT NULL,
  `captured_at` datetime NOT NULL,
  `rights_status` enum('unknown','permission_requested','permission_granted','licensed','owner_created') NOT NULL DEFAULT 'unknown',
  `verification_status` enum('provisional','transcribed','double_checked','approved') NOT NULL DEFAULT 'provisional',
  `note` varchar(1500) DEFAULT NULL,
  PRIMARY KEY (`energy_map_source_id`),
  KEY `idx_p45_source_system` (`energy_map_system_key`),
  CONSTRAINT `fk_p45_source_system`
    FOREIGN KEY (`energy_map_system_key`)
    REFERENCES `ilb_energy_map_system` (`energy_map_system_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `ilb_energy_map_point` (
  `energy_map_point_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `energy_map_system_key` varchar(80) NOT NULL,
  `point_code` varchar(30) NOT NULL,
  `point_name` varchar(255) NOT NULL,
  `body_region` varchar(100) NOT NULL,
  `laterality` enum('centre','left','right','bilateral','not_applicable') NOT NULL,
  `position_text` varchar(700) NOT NULL,
  `foundation_keyword_text` varchar(1000) NOT NULL,
  `energy_map_source_id` bigint(20) unsigned NOT NULL,
  `source_locator` varchar(255) NOT NULL,
  `coordinate_status` enum('not_mapped','approximate','reviewed_2d','reviewed_3d') NOT NULL DEFAULT 'not_mapped',
  `map_x` decimal(8,5) DEFAULT NULL,
  `map_y` decimal(8,5) DEFAULT NULL,
  `frontend_status` enum('blocked','internal_pilot','active') NOT NULL DEFAULT 'blocked',
  `status` enum('candidate','review','active','retired') NOT NULL DEFAULT 'review',
  PRIMARY KEY (`energy_map_point_id`),
  UNIQUE KEY `uq_p45_system_point` (`energy_map_system_key`,`point_code`),
  KEY `idx_p45_point_source` (`energy_map_source_id`),
  CONSTRAINT `fk_p45_point_system`
    FOREIGN KEY (`energy_map_system_key`)
    REFERENCES `ilb_energy_map_system` (`energy_map_system_key`),
  CONSTRAINT `fk_p45_point_source`
    FOREIGN KEY (`energy_map_source_id`)
    REFERENCES `ilb_energy_map_source` (`energy_map_source_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `ilb_energy_point_observation` (
  `energy_point_observation_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `subject_key` varchar(80) NOT NULL,
  `energy_map_point_id` bigint(20) unsigned NOT NULL,
  `snapshot_id` bigint(20) unsigned DEFAULT NULL,
  `observed_at` datetime NOT NULL,
  `selection_method` enum('body_map_tap','search','practitioner_selected','imported') NOT NULL,
  `sensation_type` varchar(100) DEFAULT NULL,
  `intensity_score` tinyint(3) unsigned DEFAULT NULL,
  `thought_text` varchar(1500) DEFAULT NULL,
  `feeling_text` varchar(1500) DEFAULT NULL,
  `memory_text` varchar(2000) DEFAULT NULL,
  `preceding_context_text` varchar(2000) DEFAULT NULL,
  `participant_interpretation` varchar(2000) DEFAULT NULL,
  `certainty_score` tinyint(3) unsigned DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`energy_point_observation_id`),
  KEY `idx_p45_observation_subject_time` (`subject_key`,`observed_at`),
  KEY `idx_p45_observation_point` (`energy_map_point_id`,`observed_at`),
  CONSTRAINT `fk_p45_observation_subject`
    FOREIGN KEY (`subject_key`) REFERENCES `ilb_subject` (`subject_key`),
  CONSTRAINT `fk_p45_observation_point`
    FOREIGN KEY (`energy_map_point_id`)
    REFERENCES `ilb_energy_map_point` (`energy_map_point_id`),
  CONSTRAINT `fk_p45_observation_snapshot`
    FOREIGN KEY (`snapshot_id`)
    REFERENCES `ilb_human_state_snapshot` (`snapshot_id`),
  CONSTRAINT `chk_p45_observation_intensity`
    CHECK (`intensity_score` IS NULL OR `intensity_score` BETWEEN 0 AND 10),
  CONSTRAINT `chk_p45_observation_certainty`
    CHECK (`certainty_score` IS NULL OR `certainty_score` BETWEEN 0 AND 10)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `ilb_energy_point_response` (
  `energy_point_response_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `energy_point_observation_id` bigint(20) unsigned NOT NULL,
  `response_action_id` bigint(20) unsigned DEFAULT NULL,
  `measured_at` datetime NOT NULL,
  `elapsed_minutes` int(10) unsigned NOT NULL,
  `intensity_after` tinyint(3) unsigned DEFAULT NULL,
  `feeling_after_text` varchar(1500) DEFAULT NULL,
  `participant_change_text` varchar(2000) DEFAULT NULL,
  `response_certainty_score` tinyint(3) unsigned DEFAULT NULL,
  PRIMARY KEY (`energy_point_response_id`),
  UNIQUE KEY `uq_p45_response_window` (`energy_point_observation_id`,`measured_at`),
  KEY `idx_p45_response_action` (`response_action_id`),
  CONSTRAINT `fk_p45_response_observation`
    FOREIGN KEY (`energy_point_observation_id`)
    REFERENCES `ilb_energy_point_observation` (`energy_point_observation_id`),
  CONSTRAINT `fk_p45_response_action`
    FOREIGN KEY (`response_action_id`)
    REFERENCES `ilb_response_action_event` (`response_action_id`),
  CONSTRAINT `chk_p45_response_intensity`
    CHECK (`intensity_after` IS NULL OR `intensity_after` BETWEEN 0 AND 10),
  CONSTRAINT `chk_p45_response_certainty`
    CHECK (`response_certainty_score` IS NULL OR `response_certainty_score` BETWEEN 0 AND 10)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `ilb_energy_map_system`
 (`energy_map_system_key`,`system_name`,`originator_or_tradition`,
  `system_description`,`evidence_class`,`public_display_status`,
  `boundary_text`,`status`)
VALUES
 ('redikall_minor_chakra',
  'Redikall minor-chakra map',
  'Aatmn Parmar / Redikall',
  'A coded body-location framework linking named minor chakras with foundation keywords. Stored as a separate pilot layer for pattern observation.',
  'proprietary_framework','internal_pilot',
  'The stored keyword is the source framework’s interpretation. It is not a diagnosis, anatomical fact or proof that a thought or emotion caused a symptom.',
  'review')
ON DUPLICATE KEY UPDATE
 `system_name`=VALUES(`system_name`),
 `originator_or_tradition`=VALUES(`originator_or_tradition`),
 `system_description`=VALUES(`system_description`),
 `evidence_class`=VALUES(`evidence_class`),
 `public_display_status`=VALUES(`public_display_status`),
 `boundary_text`=VALUES(`boundary_text`),
 `status`=VALUES(`status`);

INSERT INTO `ilb_energy_map_source`
 (`energy_map_system_key`,`source_type`,`title`,`creator`,`edition_or_version`,
  `source_locator`,`captured_at`,`rights_status`,`verification_status`,`note`)
SELECT
 'redikall_minor_chakra','owner_supplied_image',NULL,'Aatmn Parmar / Redikall',NULL,
 'Printed pages 130-131; owner-supplied photographs dated 2026-07-24',
 CURRENT_TIMESTAMP,'unknown','transcribed',
 'Ten-point internal pilot. Add the title page, copyright page and written reuse permission before public display.'
WHERE NOT EXISTS (
 SELECT 1 FROM `ilb_energy_map_source`
 WHERE `energy_map_system_key`='redikall_minor_chakra'
   AND `source_locator`='Printed pages 130-131; owner-supplied photographs dated 2026-07-24'
);

SET @p45_source_id = (
 SELECT `energy_map_source_id`
 FROM `ilb_energy_map_source`
 WHERE `energy_map_system_key`='redikall_minor_chakra'
   AND `source_locator`='Printed pages 130-131; owner-supplied photographs dated 2026-07-24'
 ORDER BY `energy_map_source_id`
 LIMIT 1
);

INSERT INTO `ilb_energy_map_point`
 (`energy_map_system_key`,`point_code`,`point_name`,`body_region`,`laterality`,
  `position_text`,`foundation_keyword_text`,`energy_map_source_id`,
  `source_locator`,`coordinate_status`,`frontend_status`,`status`)
VALUES
 ('redikall_minor_chakra','CR1','Right relief chakra','chest','right',
  'Right shoulder joint','Need for freedom from the past',@p45_source_id,
  'Printed page 130','not_mapped','internal_pilot','review'),
 ('redikall_minor_chakra','CL2','Left relief chakra','chest','left',
  'Left shoulder joint','Worries and concerns',@p45_source_id,
  'Printed page 130','not_mapped','internal_pilot','review'),
 ('redikall_minor_chakra','CR3','Right fulfillment chakra','chest','right',
  'Clavicle (right side)','Unfulfilled feeling',@p45_source_id,
  'Printed page 130','not_mapped','internal_pilot','review'),
 ('redikall_minor_chakra','CL4','Left fulfillment chakra','chest','left',
  'Clavicle (left side)','Need to fulfill self and others',@p45_source_id,
  'Printed page 130','not_mapped','internal_pilot','review'),
 ('redikall_minor_chakra','CR5','Right courageous love chakra','chest','right',
  'Beginning of the clavicle (right side)','Need to courageously allow others to love',@p45_source_id,
  'Printed page 131','not_mapped','internal_pilot','review'),
 ('redikall_minor_chakra','CL6','Left courageous love chakra','chest','left',
  'Beginning of the clavicle (left side)','Need to love courageously',@p45_source_id,
  'Printed page 131','not_mapped','internal_pilot','review'),
 ('redikall_minor_chakra','CC7','Constructive compliance chakra','chest','centre',
  'PAB (passive aggressive behavior)','Need for constructive approach towards authority figures, masters, and God',@p45_source_id,
  'Printed page 131','not_mapped','internal_pilot','review'),
 ('redikall_minor_chakra','CR8','Right courage chakra','chest','right',
  'Center between nipple and shoulder joint (right side)','Need to receive courageously',@p45_source_id,
  'Printed page 131','not_mapped','internal_pilot','review'),
 ('redikall_minor_chakra','CL9','Left courage chakra','chest','left',
  'Center between nipple and shoulder joint (left side)','Need to contribute courageously',@p45_source_id,
  'Printed page 131','not_mapped','internal_pilot','review'),
 ('redikall_minor_chakra','CC10','Acceptance chakra','chest','centre',
  'Above the heart chakra (thymus)','Need for acceptance',@p45_source_id,
  'Printed page 131','not_mapped','internal_pilot','review')
ON DUPLICATE KEY UPDATE
 `point_name`=VALUES(`point_name`),
 `body_region`=VALUES(`body_region`),
 `laterality`=VALUES(`laterality`),
 `position_text`=VALUES(`position_text`),
 `foundation_keyword_text`=VALUES(`foundation_keyword_text`),
 `energy_map_source_id`=VALUES(`energy_map_source_id`),
 `source_locator`=VALUES(`source_locator`),
 `frontend_status`=VALUES(`frontend_status`),
 `status`=VALUES(`status`);

INSERT INTO `ilb_backend_object_registry`
 (`object_name`,`object_type`,`domain_key`,`canonical_role`,`frontend_access`,
  `lifecycle_status`,`replacement_object_name`,`decision_note`,`release_key`)
VALUES
 ('ilb_energy_map_system','table','traditional_maps','Separate registry for sourced energy-map systems.','internal_only','review',NULL,'Prevents proprietary or traditional maps from being mixed with acupuncture or clinical anatomy.','ilb_backend_2026_07_24'),
 ('ilb_energy_map_point','table','traditional_maps','Sourced coded points and map coordinates.','internal_only','review',NULL,'The ten Redikall pilot points remain internal until source rights and coordinates are approved.','ilb_backend_2026_07_24'),
 ('ilb_energy_point_observation','table','personal_observation','Participant-selected point, sensation and context.','read_write_contract','canonical',NULL,'Records what the participant notices without assigning causation.','ilb_backend_2026_07_24'),
 ('ilb_energy_point_response','table','personal_observation','Repeated response after a recorded action.','read_write_contract','canonical',NULL,'Supports within-person pattern testing at declared time windows.','ilb_backend_2026_07_24')
ON DUPLICATE KEY UPDATE
 `canonical_role`=VALUES(`canonical_role`),
 `frontend_access`=VALUES(`frontend_access`),
 `lifecycle_status`=VALUES(`lifecycle_status`),
 `decision_note`=VALUES(`decision_note`),
 `release_key`=VALUES(`release_key`);

INSERT INTO `ilb_backend_freeze_issue`
 (`issue_key`,`domain_key`,`issue_title`,`issue_detail`,`resolution_rule`,
  `severity`,`blocks_frontend`,`status`,`resolution_note`)
VALUES
 ('redikall_ten_point_coordinates','traditional_maps','Ten Redikall pilot points need reviewed map coordinates',
  'Codes, names, printed positions and foundation keywords are transcribed, but precise 2D coordinates have not been reviewed.',
  'Plot the ten points on a licensed front-body map, independently verify each coordinate, and record reviewed_2d status.',
  'review',1,'open',NULL)
ON DUPLICATE KEY UPDATE
 `issue_title`=VALUES(`issue_title`),
 `issue_detail`=VALUES(`issue_detail`),
 `resolution_rule`=VALUES(`resolution_rule`),
 `severity`=VALUES(`severity`),
 `blocks_frontend`=VALUES(`blocks_frontend`);

UPDATE `ilb_backend_freeze_issue`
SET `issue_detail`='Ten coded points from printed pages 130-131 are now transcribed for an internal pilot. Book identity, edition and public reuse permission remain pending.',
    `resolution_rule`='Record the title and copyright pages and obtain reuse permission before public display. Keep the pilot internal until then.',
    `severity`='review',
    `blocks_frontend`=1,
    `status`='open',
    `resolution_note`='Point authentication advanced from unknown labels to a ten-point provisional transcription on 2026-07-24.'
WHERE `issue_key`='redikall_point_licence';

DROP VIEW IF EXISTS `v_ilb_energy_point_pilot`;
CREATE VIEW `v_ilb_energy_point_pilot` AS
SELECT p.`point_code`,p.`point_name`,p.`body_region`,p.`laterality`,
       p.`position_text`,p.`foundation_keyword_text`,
       p.`coordinate_status`,p.`frontend_status`,p.`status`,
       s.`source_locator`,s.`rights_status`,s.`verification_status`
FROM `ilb_energy_map_point` p
JOIN `ilb_energy_map_source` s
  ON s.`energy_map_source_id`=p.`energy_map_source_id`
WHERE p.`energy_map_system_key`='redikall_minor_chakra';

DROP VIEW IF EXISTS `v_ilb_energy_point_personal_pattern`;
CREATE VIEW `v_ilb_energy_point_personal_pattern` AS
SELECT o.`subject_key`,p.`point_code`,p.`point_name`,
       COUNT(DISTINCT o.`energy_point_observation_id`) AS `observation_count`,
       AVG(o.`intensity_score`) AS `mean_intensity_before`,
       AVG(r.`intensity_after`) AS `mean_intensity_after`,
       AVG(CASE
             WHEN o.`intensity_score` IS NOT NULL AND r.`intensity_after` IS NOT NULL
             THEN r.`intensity_after`-o.`intensity_score`
           END) AS `mean_intensity_change`,
       MIN(o.`observed_at`) AS `first_observed_at`,
       MAX(o.`observed_at`) AS `last_observed_at`
FROM `ilb_energy_point_observation` o
JOIN `ilb_energy_map_point` p
  ON p.`energy_map_point_id`=o.`energy_map_point_id`
LEFT JOIN `ilb_energy_point_response` r
  ON r.`energy_point_observation_id`=o.`energy_point_observation_id`
GROUP BY o.`subject_key`,p.`point_code`,p.`point_name`;

COMMIT;

SELECT * FROM `v_ilb_energy_point_pilot` ORDER BY `point_code`;
