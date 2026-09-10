-- Phase 128: Formula-first psoriasis body-environment standard and convergence read models.
-- Human outcome data is not used to derive or activate formulas in this phase.
START TRANSACTION;

CREATE OR REPLACE VIEW v_ilb_psoriasis_body_coordinate_standard AS
SELECT
  canonical_id,
  source_key,
  JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Coordinate Level"')) AS coordinate_level,
  JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."ILMB Code Prefix"')) AS ilmb_code_prefix,
  JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Meaning"')) AS meaning,
  JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Primary External Standard"')) AS primary_external_standard,
  JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Formula Role"')) AS formula_role,
  JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Governance Rule"')) AS governance_rule,
  source_batch_id, version_no, effective_at
FROM ilmb_canonical_record
WHERE system_id='SYS-018' AND sheet_name='24_BODY_COORD_STANDARD' AND active=1;

CREATE OR REPLACE VIEW v_ilb_psoriasis_environment_state AS
SELECT
  canonical_id,
  source_key,
  JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Environment Code"')) AS environment_code,
  JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Environment Class"')) AS environment_class,
  JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Canonical Variable"')) AS canonical_variable,
  JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Physical Meaning"')) AS physical_meaning,
  JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Minimum Primitive Set"')) AS minimum_primitive_set,
  JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Typical Unit"')) AS typical_unit,
  JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Equation Family"')) AS equation_family,
  JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Formula-First Status"')) AS formula_first_status,
  source_batch_id, version_no, effective_at
FROM ilmb_canonical_record
WHERE system_id='SYS-018' AND sheet_name='25_ENVIRONMENT_STATES' AND active=1;

CREATE OR REPLACE VIEW v_ilb_psoriasis_body_map AS
SELECT
  canonical_id,
  source_key,
  JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Node Key"')) AS node_key,
  JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Body System"')) AS body_system,
  JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Organ"')) AS organ,
  JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Region/Tissue"')) AS region_tissue,
  JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Compartment"')) AS compartment,
  JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Cell Type"')) AS cell_type,
  JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Protein/Chemical"')) AS protein_chemical,
  JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Pathway/Process"')) AS pathway_process,
  JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Environment State"')) AS environment_state,
  JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Equation Variable"')) AS equation_variable,
  JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Formula Status"')) AS formula_status,
  source_batch_id, version_no, effective_at
FROM ilmb_canonical_record
WHERE system_id='SYS-018' AND sheet_name='26_PSO_BODY_MAP' AND active=1;

CREATE OR REPLACE VIEW v_ilb_psoriasis_master_modality AS
SELECT
  canonical_id,
  source_key,
  JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Modality Key"')) AS modality_key,
  JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Modality Family"')) AS modality_family,
  JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Specific Modality / Intervention"')) AS modality_name,
  JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Input Type"')) AS input_type,
  JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Primary Route"')) AS primary_route,
  JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."First Body System"')) AS first_body_system,
  JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."First Organ/Tissue"')) AS first_organ_tissue,
  JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."First Environment State"')) AS first_environment_state,
  JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Mechanism Class"')) AS mechanism_class,
  JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Formula Eligibility"')) AS formula_eligibility,
  JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Human Data Pre-Formula"')) AS human_data_pre_formula,
  JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Convergence Group"')) AS convergence_group,
  JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Status"')) AS status,
  source_batch_id, version_no, effective_at
FROM ilmb_canonical_record
WHERE system_id='SYS-018' AND sheet_name='32_MASTER_MODALITY_REGISTRY' AND active=1;

CREATE OR REPLACE VIEW v_ilb_psoriasis_modality_coordinate AS
SELECT
  canonical_id,
  source_key,
  JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Modality Key"')) AS modality_key,
  JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Modality"')) AS modality,
  JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Physical/Chemical Input"')) AS physical_chemical_input,
  JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."First Body Coordinate"')) AS first_body_coordinate,
  JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."First Environment State"')) AS first_environment_state,
  JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."First Mechanism Class"')) AS first_mechanism_class,
  JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Candidate Downstream Coordinates"')) AS candidate_downstream_coordinates,
  JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Pre-Formula Numeric Use"')) AS pre_formula_numeric_use,
  JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Convergence Eligibility"')) AS convergence_eligibility,
  source_batch_id, version_no, effective_at
FROM ilmb_canonical_record
WHERE system_id='SYS-018' AND sheet_name='27_MODALITY_BODY_COORD' AND active=1;

CREATE OR REPLACE VIEW v_ilb_psoriasis_convergence_relation AS
SELECT
  canonical_id,
  source_key,
  JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Relationship Key"')) AS relationship_key,
  JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Modality Key"')) AS modality_key,
  JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Input Coordinate"')) AS input_coordinate,
  JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Body Coordinate"')) AS body_coordinate,
  JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Environment State"')) AS environment_state,
  JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Mechanism/Process"')) AS mechanism_process,
  JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Target Coordinate"')) AS target_coordinate,
  JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Numeric Primitive Source"')) AS numeric_primitive_source,
  JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Formula Eligibility"')) AS formula_eligibility,
  JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Convergence Key"')) AS convergence_key,
  source_batch_id, version_no, effective_at
FROM ilmb_canonical_record
WHERE system_id='SYS-018' AND sheet_name='30_CONVERGENCE_ENGINE' AND active=1;

CREATE OR REPLACE VIEW v_ilb_psoriasis_formula_gate AS
SELECT
  canonical_id,
  source_key,
  JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Gate"')) AS gate_key,
  JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Object"')) AS governed_object,
  JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Status"')) AS gate_status,
  JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."What Must Be True"')) AS pass_condition,
  JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."What Blocks Promotion"')) AS block_condition,
  JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Current State"')) AS current_state,
  source_batch_id, version_no, effective_at
FROM ilmb_canonical_record
WHERE system_id='SYS-018' AND sheet_name='34_END_TO_END_GATES' AND active=1;

INSERT INTO ilb_backend_object_registry
(object_name,object_type,domain_key,canonical_role,frontend_access,lifecycle_status,replacement_object_name,decision_note,release_key)
VALUES
('v_ilb_psoriasis_body_coordinate_standard','view','pharmaceutical','Formula-first standardized body-coordinate read model.','read_contract','canonical',NULL,'Human outcome values cannot define this ontology.','ilb_backend_2026_09_10_phase128'),
('v_ilb_psoriasis_environment_state','view','pharmaceutical','Formula-first body-environment-state read model.','read_contract','canonical',NULL,'Environment states require physical meaning and primitive contracts.','ilb_backend_2026_09_10_phase128'),
('v_ilb_psoriasis_body_map','view','pharmaceutical','Psoriasis disease nodes mapped into standardized body coordinates.','read_contract','canonical',NULL,'No real-person initial conditions before formula verification.','ilb_backend_2026_09_10_phase128'),
('v_ilb_psoriasis_master_modality','view','pharmaceutical','World modality registry mapped by physical/chemical/neural input type.','read_contract','canonical',NULL,'Unresolved modalities remain unresolved; no doctrine-only mechanism promotion.','ilb_backend_2026_09_10_phase128'),
('v_ilb_psoriasis_modality_coordinate','view','pharmaceutical','Modality-to-body-coordinate mapping read model.','read_contract','canonical',NULL,'Clinical efficacy does not define pre-formula mechanism.','ilb_backend_2026_09_10_phase128'),
('v_ilb_psoriasis_convergence_relation','view','pharmaceutical','Formula-first convergence relationship read model.','read_contract','canonical',NULL,'Only standardized body coordinates participate in convergence.','ilb_backend_2026_09_10_phase128'),
('v_ilb_psoriasis_formula_gate','view','pharmaceutical','Formula-first phase gate read model.','read_contract','canonical',NULL,'Human validation and real-person entry remain blocked until formula lock.','ilb_backend_2026_09_10_phase128')
ON DUPLICATE KEY UPDATE canonical_role=VALUES(canonical_role),decision_note=VALUES(decision_note),release_key=VALUES(release_key);

COMMIT;
