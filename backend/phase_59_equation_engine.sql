-- Phase 59: ILMB equation engine and complete data-object computational-role register.
START TRANSACTION;
CREATE TABLE IF NOT EXISTS ilb_equation_registry (
 equation_id bigint unsigned NOT NULL AUTO_INCREMENT,
 equation_key varchar(160) NOT NULL,
 equation_name varchar(500) NOT NULL,
 equation_class enum('CHEMISTRY','PHYSIOLOGY','MEASUREMENT','TREND','STATISTICAL','OTHER') NOT NULL,
 expression_text text NOT NULL,
 input_unit_contract text NOT NULL,
 output_unit_contract text NOT NULL,
 source_dataset_id bigint unsigned NULL,
 evidence_locator varchar(1000) NOT NULL,
 validation_status enum('DRAFT','VERIFIED','REJECTED') NOT NULL DEFAULT 'DRAFT',
 PRIMARY KEY(equation_id), UNIQUE KEY uq_ilb_equation_key(equation_key),
 CONSTRAINT fk_ilb_equation_source FOREIGN KEY(source_dataset_id) REFERENCES ilb_source_dataset(source_dataset_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE IF NOT EXISTS ilb_equation_object_binding (
 binding_id bigint unsigned NOT NULL AUTO_INCREMENT,
 equation_id bigint unsigned NOT NULL,
 object_name varchar(255) NOT NULL,
 field_name varchar(255) NULL,
 semantic_role enum('INPUT','LOOKUP','EVIDENCE','OUTPUT') NOT NULL,
 native_identifier varchar(255) NULL,
 unit_contract varchar(255) NULL,
 PRIMARY KEY(binding_id), UNIQUE KEY uq_ilb_equation_binding(equation_id,object_name,field_name,semantic_role),
 CONSTRAINT fk_ilb_binding_equation FOREIGN KEY(equation_id) REFERENCES ilb_equation_registry(equation_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE IF NOT EXISTS ilb_source_object_compute_role (
 object_name varchar(255) NOT NULL,
 compute_role enum('INPUT','LOOKUP','EVIDENCE','OUTPUT','NONCOMPUTATIONAL','UNCLASSIFIED') NOT NULL DEFAULT 'UNCLASSIFIED',
 assignment_status enum('PENDING','ASSIGNED') NOT NULL DEFAULT 'PENDING',
 PRIMARY KEY(object_name),
 CONSTRAINT fk_ilb_compute_object FOREIGN KEY(object_name) REFERENCES ilb_source_data_object_registry(object_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO ilb_source_object_compute_role(object_name)
SELECT object_name FROM ilb_source_data_object_registry
ON DUPLICATE KEY UPDATE object_name=VALUES(object_name);
COMMIT;