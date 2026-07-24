-- Phase 49: plug-and-play backend freeze and verification
-- Target: u756742628_ilovemybody
-- Prerequisites: Phases 47 and 48.
-- Safe to rerun.

START TRANSACTION;

INSERT INTO `ilb_backend_release`
 (`release_key`,`release_name`,`released_at`,`schema_contract_version`,
  `content_contract_version`,`calculation_contract_version`,`release_note`,`status`)
VALUES
 ('ilb_backend_2026_07_24_complete',
  'I Love My Body Self-Care Hospital plug-and-play backend',
  CURRENT_TIMESTAMP,'49.0','47.0','47.0',
  'Freezes the public hospital, departments, Connection Centre, patient runtime, registration, preferences, bot gate, 10C change path, journey timeline, metric definitions and frontend data contracts.',
  'frozen')
ON DUPLICATE KEY UPDATE
 `release_name`=VALUES(`release_name`),
 `schema_contract_version`=VALUES(`schema_contract_version`),
 `content_contract_version`=VALUES(`content_contract_version`),
 `calculation_contract_version`=VALUES(`calculation_contract_version`),
 `release_note`=VALUES(`release_note`),
 `status`=VALUES(`status`);

INSERT INTO `ilb_backend_object_registry`
 (`object_name`,`object_type`,`domain_key`,`canonical_role`,`frontend_access`,
  `lifecycle_status`,`replacement_object_name`,`decision_note`,`release_key`)
VALUES
 ('ilb_product_setting','table','product','Canonical product settings and durations.','read_contract','canonical',NULL,'Frontend must read rather than hard-code these values.','ilb_backend_2026_07_24_complete'),
 ('ilb_hospital_department','table','hospital','Canonical department directory.','read_contract','canonical',NULL,'Seven human departments, one Connection Centre and one Book department.','ilb_backend_2026_07_24_complete'),
 ('ilb_hospital_room','table','hospital','Canonical hospital rooms and access rules.','read_contract','canonical',NULL,'Rooms describe capabilities, routes and data contracts.','ilb_backend_2026_07_24_complete'),
 ('ilb_navigation_item','table','product','Canonical navigation for entrance, lobby and dashboard.','read_contract','canonical',NULL,'Frontend navigation is database owned.','ilb_backend_2026_07_24_complete'),
 ('ilb_content_block','table','content','Canonical participant-facing product wording.','read_contract','canonical',NULL,'Medical, evidence, book and encouragement classes remain separate.','ilb_backend_2026_07_24_complete'),
 ('ilb_theme_option','table','appearance','Canonical selectable accent themes.','read_contract','canonical',NULL,'One bright accent dominates softly with controlled light and dark surfaces.','ilb_backend_2026_07_24_complete'),
 ('ilb_journey_template','table','journey','Canonical journey identity and version.','read_contract','canonical',NULL,'Registration, baseline, ten days, seven weeks, two days, optional seven weeks and continuing.','ilb_backend_2026_07_24_complete'),
 ('ilb_journey_stage','table','journey','Canonical ordered patient timeline.','read_contract','canonical',NULL,'No fixed one-hundred-day claim.','ilb_backend_2026_07_24_complete'),
 ('ilb_connection_component','table','connection','Canonical incoming-centre-connector-memory-outgoing-feedback model.','read_contract','canonical',NULL,'Scientific boundaries are stored with each component.','ilb_backend_2026_07_24_complete'),
 ('ilb_connection_edge','table','connection','Canonical typed connections between components.','read_contract','canonical',NULL,'Causal status is explicit.','ilb_backend_2026_07_24_complete'),
 ('ilb_change_stage','table','change','Canonical 10C plus action, consequence and change path.','read_contract','canonical',NULL,'Clairvoyance is explicitly pattern-based foresight.','ilb_backend_2026_07_24_complete'),
 ('ilb_metric_definition','table','calculation','Canonical participant metric definitions and limitations.','read_contract','canonical',NULL,'No universal human, health, happiness or energy score.','ilb_backend_2026_07_24_complete'),
 ('ilb_account','table','access','Canonical private account record.','internal_only','canonical',NULL,'Raw mobile and PIN are never stored.','ilb_backend_2026_07_24_complete'),
 ('ilb_account_session','table','access','Canonical revocable authenticated session.','internal_only','canonical',NULL,'Session and CSRF tokens are stored only as hashes.','ilb_backend_2026_07_24_complete'),
 ('ilb_subject_preference','table','appearance','Canonical patient display preferences.','read_write_contract','canonical',NULL,'Theme, background and text size are persistent.','ilb_backend_2026_07_24_complete'),
 ('ilb_patient_journey','table','journey','Canonical active patient journey state.','read_write_contract','canonical',NULL,'The frontend derives the single dashboard from this record.','ilb_backend_2026_07_24_complete'),
 ('ilb_journal_entry','table','journal','Canonical private journal.','read_write_contract','canonical',NULL,'Private by default; sharing requires an explicit state.','ilb_backend_2026_07_24_complete'),
 ('ilb_intent_choice_event','table','change','Canonical intent and choice observation.','read_write_contract','canonical',NULL,'Participant language is recorded without judgement.','ilb_backend_2026_07_24_complete'),
 ('ilb_choice_action','table','change','Canonical action following a choice.','read_write_contract','canonical',NULL,'Barriers and non-action remain valid observations.','ilb_backend_2026_07_24_complete'),
 ('ilb_action_consequence','table','change','Canonical observed consequence.','read_write_contract','canonical',NULL,'Causal claims are disabled by default.','ilb_backend_2026_07_24_complete'),
 ('ilb_bot_conversation','table','bot','Canonical bot question counter and registration gate.','read_write_contract','canonical',NULL,'Three public visitor questions before registration.','ilb_backend_2026_07_24_complete'),
 ('ilb_data_contract','table','api','Canonical frontend/API contract registry.','read_contract','canonical',NULL,'Frontend integration begins here.','ilb_backend_2026_07_24_complete'),
 ('v_ilb_public_hospital_bootstrap','view','api','Public entrance and lobby bootstrap.','read_contract','canonical',NULL,'Contains no patient data.','ilb_backend_2026_07_24_complete'),
 ('v_ilb_patient_dashboard','view','api','Single private patient dashboard read model.','read_contract','canonical',NULL,'Subject resolution must occur through authenticated server context.','ilb_backend_2026_07_24_complete'),
 ('v_ilb_journey_contract','view','api','Ordered journey read model.','read_contract','canonical',NULL,'Frontend displays backend durations and rules.','ilb_backend_2026_07_24_complete'),
 ('v_ilb_connection_contract','view','api','Connection Centre read model.','read_contract','canonical',NULL,'Plain language and scientific boundaries travel together.','ilb_backend_2026_07_24_complete')
ON DUPLICATE KEY UPDATE
 `object_type`=VALUES(`object_type`),`domain_key`=VALUES(`domain_key`),
 `canonical_role`=VALUES(`canonical_role`),`frontend_access`=VALUES(`frontend_access`),
 `lifecycle_status`=VALUES(`lifecycle_status`),
 `replacement_object_name`=VALUES(`replacement_object_name`),
 `decision_note`=VALUES(`decision_note`),`release_key`=VALUES(`release_key`);

-- The photographed third-party micro-point study was explicitly excluded by
-- the owner. These names remain blocked even if an earlier partial migration
-- left registry rows behind. No sourced acupuncture objects are removed.
UPDATE `ilb_backend_object_registry`
SET `frontend_access`='blocked',`lifecycle_status`='retired',
    `replacement_object_name`=NULL,
    `decision_note`='Excluded from I Love My Body production by project-owner decision; retained only where database audit history requires it.',
    `release_key`='ilb_backend_2026_07_24_complete'
WHERE `object_name` IN (
  'ilb_energy_map_system','ilb_energy_map_source','ilb_energy_map_point',
  'ilb_energy_point_observation','ilb_energy_point_response',
  'v_ilb_energy_point_pilot','v_ilb_energy_point_personal_pattern'
);

UPDATE `ilb_backend_freeze_issue`
SET `status`='retired',`resolved_at`=COALESCE(`resolved_at`,CURRENT_TIMESTAMP),
    `resolution_note`='The third-party micro-point system is out of production scope. Standard sourced acupuncture/acupressure remains separate.'
WHERE `issue_key`='redikall_point_licence';

DROP VIEW IF EXISTS `v_ilb_plug_play_readiness`;
CREATE VIEW `v_ilb_plug_play_readiness` AS
SELECT e.`object_name`,e.`object_type`,
       CASE
         WHEN e.`object_type`='table' AND t.`table_name` IS NOT NULL THEN 'ready'
         WHEN e.`object_type`='view' AND v.`table_name` IS NOT NULL THEN 'ready'
         ELSE 'missing'
       END AS `readiness_status`,
       e.`purpose_text`
FROM (
  SELECT 'ilb_product_setting' `object_name`,'table' `object_type`,'Product settings' `purpose_text`
  UNION ALL SELECT 'ilb_hospital_department','table','Hospital departments'
  UNION ALL SELECT 'ilb_hospital_room','table','Hospital rooms'
  UNION ALL SELECT 'ilb_navigation_item','table','Navigation'
  UNION ALL SELECT 'ilb_content_block','table','Content'
  UNION ALL SELECT 'ilb_theme_option','table','Appearance'
  UNION ALL SELECT 'ilb_journey_template','table','Journey template'
  UNION ALL SELECT 'ilb_journey_stage','table','Journey stages'
  UNION ALL SELECT 'ilb_connection_component','table','Connection components'
  UNION ALL SELECT 'ilb_connection_edge','table','Connection edges'
  UNION ALL SELECT 'ilb_change_stage','table','Change stages'
  UNION ALL SELECT 'ilb_metric_definition','table','Metrics'
  UNION ALL SELECT 'ilb_account','table','Accounts'
  UNION ALL SELECT 'ilb_account_session','table','Sessions'
  UNION ALL SELECT 'ilb_registration_state','table','Registration'
  UNION ALL SELECT 'ilb_subject_preference','table','Preferences'
  UNION ALL SELECT 'ilb_patient_journey','table','Patient journeys'
  UNION ALL SELECT 'ilb_journal_entry','table','Journal'
  UNION ALL SELECT 'ilb_intent_choice_event','table','Intent and choices'
  UNION ALL SELECT 'ilb_choice_action','table','Actions'
  UNION ALL SELECT 'ilb_action_consequence','table','Consequences'
  UNION ALL SELECT 'ilb_bot_conversation','table','Bot gate'
  UNION ALL SELECT 'ilb_data_contract','table','API contracts'
  UNION ALL SELECT 'v_ilb_public_hospital_bootstrap','view','Public bootstrap'
  UNION ALL SELECT 'v_ilb_patient_dashboard','view','Patient dashboard'
  UNION ALL SELECT 'v_ilb_journey_contract','view','Journey read model'
  UNION ALL SELECT 'v_ilb_connection_contract','view','Connection read model'
) e
LEFT JOIN `information_schema`.`tables` t
  ON t.`table_schema`=DATABASE()
 AND t.`table_name`=e.`object_name`
 AND t.`table_type`='BASE TABLE'
LEFT JOIN `information_schema`.`views` v
  ON v.`table_schema`=DATABASE()
 AND v.`table_name`=e.`object_name`;

DROP VIEW IF EXISTS `v_ilb_release_summary`;
CREATE VIEW `v_ilb_release_summary` AS
SELECT r.`release_key`,r.`release_name`,r.`released_at`,r.`status`,
       (SELECT COUNT(*) FROM `v_ilb_plug_play_readiness`
         WHERE `readiness_status`='ready') AS `ready_objects`,
       (SELECT COUNT(*) FROM `v_ilb_plug_play_readiness`
         WHERE `readiness_status`='missing') AS `missing_objects`,
       (SELECT COUNT(*) FROM `ilb_hospital_department`
         WHERE `status`='active') AS `active_departments`,
       (SELECT COUNT(*) FROM `ilb_journey_stage`
         WHERE `status`='active') AS `active_journey_stages`,
       (SELECT COUNT(*) FROM `ilb_data_contract`
         WHERE `status`='active') AS `active_api_contracts`,
       (SELECT COUNT(*) FROM `ilb_metric_definition`
         WHERE `status`='active') AS `active_metric_definitions`
FROM `ilb_backend_release` r
WHERE r.`release_key`='ilb_backend_2026_07_24_complete';

COMMIT;

SELECT * FROM `v_ilb_release_summary`;
SELECT * FROM `v_ilb_plug_play_readiness`
WHERE `readiness_status`<>'ready'
ORDER BY `object_type`,`object_name`;
