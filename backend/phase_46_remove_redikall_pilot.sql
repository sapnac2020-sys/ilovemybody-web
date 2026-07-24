-- Phase 46: remove the Redikall study pilot from the production database
-- Target: u756742628_ilovemybody
-- Safe to rerun.
--
-- The Redikall material was supplied for conceptual study only. It must not
-- remain part of the I Love My Body production database or frontend contract.

START TRANSACTION;

DROP VIEW IF EXISTS `v_ilb_energy_point_personal_pattern`;
DROP VIEW IF EXISTS `v_ilb_energy_point_pilot`;

DELETE FROM `ilb_backend_object_registry`
WHERE `object_name` IN (
  'ilb_energy_map_system',
  'ilb_energy_map_point',
  'ilb_energy_point_observation',
  'ilb_energy_point_response'
);

DELETE FROM `ilb_backend_freeze_issue`
WHERE `issue_key` IN (
  'redikall_point_licence',
  'redikall_ten_point_coordinates'
);

DROP TABLE IF EXISTS `ilb_energy_point_response`;
DROP TABLE IF EXISTS `ilb_energy_point_observation`;
DROP TABLE IF EXISTS `ilb_energy_map_point`;
DROP TABLE IF EXISTS `ilb_energy_map_source`;
DROP TABLE IF EXISTS `ilb_energy_map_system`;

COMMIT;

SELECT COUNT(*) AS `redikall_named_tables`
FROM `information_schema`.`tables`
WHERE `table_schema`=DATABASE()
  AND (
    `table_name` LIKE 'ilb_energy_map_%'
    OR `table_name` LIKE 'ilb_energy_point_%'
  );

SELECT COUNT(*) AS `redikall_registry_rows`
FROM `ilb_backend_object_registry`
WHERE `object_name` IN (
  'ilb_energy_map_system',
  'ilb_energy_map_point',
  'ilb_energy_point_observation',
  'ilb_energy_point_response'
);

SELECT COUNT(*) AS `redikall_open_issues`
FROM `ilb_backend_freeze_issue`
WHERE `issue_key` LIKE 'redikall%';
