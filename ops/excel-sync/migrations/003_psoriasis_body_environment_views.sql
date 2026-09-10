-- Excel Sync migration 003: psoriasis formula-first body-environment read models.
CREATE OR REPLACE VIEW v_ilb_psoriasis_body_coordinate_standard AS
SELECT canonical_id,source_key,
 JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Coordinate Level"')) coordinate_level,
 JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."ILMB Code Prefix"')) ilmb_code_prefix,
 JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Meaning"')) meaning,
 JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Primary External Standard"')) primary_external_standard,
 JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Formula Role"')) formula_role,
 JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Governance Rule"')) governance_rule,
 source_batch_id,version_no,effective_at
FROM ilmb_canonical_record
WHERE system_id='SYS-018' AND sheet_name='24_BODY_COORD_STANDARD' AND active=1;

CREATE OR REPLACE VIEW v_ilb_psoriasis_environment_state AS
SELECT canonical_id,source_key,
 JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Environment Code"')) environment_code,
 JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Environment Class"')) environment_class,
 JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Canonical Variable"')) canonical_variable,
 JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Physical Meaning"')) physical_meaning,
 JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Minimum Primitive Set"')) minimum_primitive_set,
 JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Typical Unit"')) typical_unit,
 JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Equation Family"')) equation_family,
 JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Formula-First Status"')) formula_first_status,
 source_batch_id,version_no,effective_at
FROM ilmb_canonical_record
WHERE system_id='SYS-018' AND sheet_name='25_ENVIRONMENT_STATES' AND active=1;

CREATE OR REPLACE VIEW v_ilb_psoriasis_body_map AS
SELECT canonical_id,source_key,
 JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Node Key"')) node_key,
 JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Body System"')) body_system,
 JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Organ"')) organ,
 JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Region/Tissue"')) region_tissue,
 JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Compartment"')) compartment,
 JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Cell Type"')) cell_type,
 JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Protein/Chemical"')) protein_chemical,
 JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Pathway/Process"')) pathway_process,
 JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Environment State"')) environment_state,
 JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Equation Variable"')) equation_variable,
 JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Formula Status"')) formula_status,
 source_batch_id,version_no,effective_at
FROM ilmb_canonical_record
WHERE system_id='SYS-018' AND sheet_name='26_PSO_BODY_MAP' AND active=1;

CREATE OR REPLACE VIEW v_ilb_psoriasis_master_modality AS
SELECT canonical_id,source_key,
 JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Modality Key"')) modality_key,
 JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Modality Family"')) modality_family,
 JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Specific Modality / Intervention"')) modality_name,
 JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Input Type"')) input_type,
 JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Primary Route"')) primary_route,
 JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."First Body System"')) first_body_system,
 JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."First Organ/Tissue"')) first_organ_tissue,
 JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."First Environment State"')) first_environment_state,
 JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Mechanism Class"')) mechanism_class,
 JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Formula Eligibility"')) formula_eligibility,
 JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Human Data Pre-Formula"')) human_data_pre_formula,
 JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Convergence Group"')) convergence_group,
 JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Status"')) status,
 source_batch_id,version_no,effective_at
FROM ilmb_canonical_record
WHERE system_id='SYS-018' AND sheet_name='32_MASTER_MODALITY_REGISTRY' AND active=1;

CREATE OR REPLACE VIEW v_ilb_psoriasis_modality_coordinate AS
SELECT canonical_id,source_key,
 JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Modality Key"')) modality_key,
 JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Modality"')) modality,
 JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Physical/Chemical Input"')) physical_chemical_input,
 JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."First Body Coordinate"')) first_body_coordinate,
 JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."First Environment State"')) first_environment_state,
 JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."First Mechanism Class"')) first_mechanism_class,
 JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Candidate Downstream Coordinates"')) candidate_downstream_coordinates,
 JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Pre-Formula Numeric Use"')) pre_formula_numeric_use,
 JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Convergence Eligibility"')) convergence_eligibility,
 source_batch_id,version_no,effective_at
FROM ilmb_canonical_record
WHERE system_id='SYS-018' AND sheet_name='27_MODALITY_BODY_COORD' AND active=1;

CREATE OR REPLACE VIEW v_ilb_psoriasis_convergence_relation AS
SELECT canonical_id,source_key,
 JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Relationship Key"')) relationship_key,
 JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Modality Key"')) modality_key,
 JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Input Coordinate"')) input_coordinate,
 JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Body Coordinate"')) body_coordinate,
 JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Environment State"')) environment_state,
 JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Mechanism/Process"')) mechanism_process,
 JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Target Coordinate"')) target_coordinate,
 JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Numeric Primitive Source"')) numeric_primitive_source,
 JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Formula Eligibility"')) formula_eligibility,
 JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Convergence Key"')) convergence_key,
 source_batch_id,version_no,effective_at
FROM ilmb_canonical_record
WHERE system_id='SYS-018' AND sheet_name='30_CONVERGENCE_ENGINE' AND active=1;

CREATE OR REPLACE VIEW v_ilb_psoriasis_formula_gate AS
SELECT canonical_id,source_key,
 JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Gate"')) gate_key,
 JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Object"')) governed_object,
 JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Status"')) gate_status,
 JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."What Must Be True"')) pass_condition,
 JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."What Blocks Promotion"')) block_condition,
 JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$."Current State"')) current_state,
 source_batch_id,version_no,effective_at
FROM ilmb_canonical_record
WHERE system_id='SYS-018' AND sheet_name='34_END_TO_END_GATES' AND active=1;
