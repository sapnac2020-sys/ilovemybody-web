-- Phase 57: single source-data master register for all live ILMB data objects.
-- This imports only database metadata. No source, evidence, or relationship is inferred.
START TRANSACTION;
CREATE TABLE IF NOT EXISTS ilb_source_data_object_registry (
  source_object_registry_id bigint unsigned NOT NULL AUTO_INCREMENT,
  object_name varchar(255) NOT NULL,
  object_type enum('TABLE','VIEW') NOT NULL,
  domain_key varchar(80) NULL,
  canonical_role varchar(500) NULL,
  source_name varchar(255) NULL,
  source_release varchar(120) NULL,
  source_url varchar(1000) NULL,
  native_identity_status enum('UNKNOWN','PARTIAL','EXACT') NOT NULL DEFAULT 'UNKNOWN',
  provenance_status enum('UNCLASSIFIED','SOURCE_BACKED') NOT NULL DEFAULT 'UNCLASSIFIED',
  connection_status enum('UNMAPPED','PARTIAL','CONNECTED') NOT NULL DEFAULT 'UNMAPPED',
  usability_status enum('INVENTORIED','REFERENCE_READY','COMPUTABLE') NOT NULL DEFAULT 'INVENTORIED',
  discovered_at datetime(6) NOT NULL DEFAULT current_timestamp(6),
  updated_at datetime(6) NOT NULL DEFAULT current_timestamp(6) ON UPDATE current_timestamp(6),
  PRIMARY KEY(source_object_registry_id),
  UNIQUE KEY uq_ilb_source_object_name(object_name),
  KEY idx_ilb_source_object_status(provenance_status,connection_status,usability_status),
  KEY idx_ilb_source_object_domain(domain_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO ilb_source_data_object_registry (
  object_name,object_type,domain_key,canonical_role
)
SELECT
  t.table_name,
  CASE WHEN t.table_type='BASE TABLE' THEN 'TABLE' ELSE 'VIEW' END,
  r.domain_key,
  r.canonical_role
FROM information_schema.tables t
LEFT JOIN ilb_backend_object_registry r ON r.object_name=t.table_name
WHERE t.table_schema=DATABASE()
  AND t.table_name <> 'ilb_source_data_object_registry'
ON DUPLICATE KEY UPDATE
  object_type=VALUES(object_type),
  domain_key=COALESCE(VALUES(domain_key),ilb_source_data_object_registry.domain_key),
  canonical_role=COALESCE(VALUES(canonical_role),ilb_source_data_object_registry.canonical_role);

CREATE OR REPLACE VIEW v_ilb_source_data_master AS
SELECT object_name,object_type,domain_key,canonical_role,source_name,source_release,source_url,
       native_identity_status,provenance_status,connection_status,usability_status,discovered_at,updated_at
FROM ilb_source_data_object_registry;

INSERT INTO ilb_backend_object_registry(object_name,object_type,domain_key,canonical_role,frontend_access,lifecycle_status,replacement_object_name,decision_note,release_key) VALUES
('ilb_source_data_object_registry','table','governance','Central register of all live ILMB database tables and views.','internal_only','canonical',NULL,'Unknown source/provenance is retained as unclassified until a source record is attached.','ilmb_backend_2026_09_01_source_master'),
('v_ilb_source_data_master','view','governance','Read model for the ILMB source-data master register.','read_contract','canonical',NULL,'Reports source, identity, connection and usability status without inventing evidence.','ilmb_backend_2026_09_01_source_master')
ON DUPLICATE KEY UPDATE object_type=VALUES(object_type),domain_key=VALUES(domain_key),canonical_role=VALUES(canonical_role),frontend_access=VALUES(frontend_access),lifecycle_status=VALUES(lifecycle_status),replacement_object_name=VALUES(replacement_object_name),decision_note=VALUES(decision_note),release_key=VALUES(release_key);
COMMIT;
