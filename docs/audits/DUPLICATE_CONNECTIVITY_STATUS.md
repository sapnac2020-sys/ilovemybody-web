# ILMB Duplicate & Connectivity Audit

Generated: 2026-09-13T10:59:53+00:00
Objects: 1634
Base tables: 1249
Views: 385
Empty base tables: 256
FK-disconnected base tables: 810
Suspicious named tables: 10
Duplicate schema groups: 3
Duplicate view groups: 0
Open parameter duplicates: 0
Open formula duplicates: 0
Exchange duplicate file groups: 0
Exchange unreferenced Excel/CSV: 61
Public duplicate file groups: 0
Public suspicious named files: 11

## Strong disconnected table candidates: empty + no incoming/outgoing FK
- ilb_anatomical_coordinate_evidence_master
- ilb_anatomical_coordinate_extraction_queue
- ilb_anatomical_coordinate_source_intake
- ilb_anatomical_coordinate_source_validation
- ilb_anatomical_coordinate_transform
- ilb_anatomical_coordinate_validation
- ilb_anatomical_coordinate_value
- ilb_anatomical_landmark_master
- ilb_anatomical_path_intersection
- ilb_arrival
- ilb_coordinate_candidate_landmark_intake
- ilb_coordinate_evidence_generation_queue
- ilb_derivation_cycle
- ilb_evidence_source_verification_log
- ilb_geometry_unlock_audit_master
- ilb_geometry_unlock_rule_result
- ilb_gita_calculated_result
- ilb_gita_candidate_mapping
- ilb_gita_contradiction
- ilb_gita_formula
- ilb_gita_formula_test
- ilb_gita_gloss
- ilb_gita_hypothesis
- ilb_gita_import_batch
- ilb_gita_measurement
- ilb_gita_observation
- ilb_gita_parse
- ilb_gita_personal_protocol
- ilb_gita_prediction
- ilb_gita_proof_gate
- ilb_gita_proposition
- ilb_gita_replication
- ilb_gita_source_text
- ilb_gita_token
- ilb_internal_body_function_master
- ilb_internal_lab_mapping_gap_queue
- ilb_internal_lab_result_body_mapping
- ilb_internal_ph_environment_function
- ilb_internal_sugar_analysis_results
- ilb_internal_sugar_analysis_runs
- ilb_internal_sugar_datasets
- ilb_internal_sugar_dataset_variables
- ilb_internal_sugar_data_quality_issues
- ilb_internal_sugar_effect_estimates
- ilb_internal_sugar_foods
- ilb_internal_sugar_food_composition
- ilb_internal_sugar_food_exposures
- ilb_internal_sugar_measurements
- ilb_internal_sugar_measurement_contexts
- ilb_internal_sugar_medications
- ilb_internal_sugar_medication_exposures
- ilb_internal_sugar_outcomes
- ilb_internal_sugar_raw_records
- ilb_internal_sugar_recipes
- ilb_internal_sugar_recipe_ingredients
- ilb_internal_sugar_reference_ranges
- ilb_internal_sugar_reports
- ilb_internal_sugar_studies
- ilb_internal_sugar_study_arms
- ilb_internal_sugar_study_exposures
- ilb_internal_sugar_subjects
- ilb_ixekizumab_dose_event
- ilb_order_panel_member
- ilb_paired_observation
- ilb_path_permission_unlock_log
- ilb_pattern_signature
- ilb_psoriasis_acupuncture_observation
- ilb_psoriasis_master_primitive
- ilb_psoriasis_pasi_observation
- ilb_psoriasis_ph_observation
- ilb_psoriasis_treatment_episode
- ilb_pso_primitive_quantity
- ilb_reference_coordinate_mapping
- ilb_reference_coordinate_mapping_candidate
- ilb_reference_coordinate_mapping_candidate_validation
- ilb_reference_coordinate_mapping_validation
- ilb_reproductive_ph_path_intersection
- ilb_reproductive_ph_path_intersection_party
- ilb_reproductive_ph_path_master
- ilb_reproductive_ph_path_point
- ilb_respiratory_path_master
- ilb_respiratory_path_point
- ilb_signature_observation
- ilb_study_prompt
- ilb_subject_appearance
- ilmb_canonical_record_history
- ilmb_entity_crosswalk_history

## Suspicious named tables
- ilb_courage_centre_test | rows=49 | inFK=0 | outFK=0
- ilb_formula_test | rows=34 | inFK=0 | outFK=0
- ilb_gita_formula_test | rows=0 | inFK=0 | outFK=0
- ilb_internal_case_equilibrium_assumption_test | rows=5 | inFK=0 | outFK=0
- ilb_ordered_test | rows=6 | inFK=0 | outFK=0
- ilb_subject_test_result_ledger | rows=0 | inFK=0 | outFK=1
- ilb_test_atlas_candidate | rows=123 | inFK=0 | outFK=0
- ilb_test_atlas_loinc_crosswalk | rows=0 | inFK=1 | outFK=0
- ilb_test_consideration | rows=0 | inFK=0 | outFK=1
- ilb_test_topic_catalog | rows=18 | inFK=1 | outFK=0

## Duplicate table-schema groups
- ilb_acupressure_session_reference, ilb_acupuncture_session_reference
- vw_ilb_cell_state, vw_ilb_cell_state_now
- vw_ilb_cell_supply, vw_ilb_cell_supply_now

## Duplicate public-file groups

## Suspicious public files
- ops/deploy-psoriasis-through-127-v2.php
- ops/run-online-test-topic-migration.php
- ops/run-subject-test-result-ledger.php
- ops/run-test-atlas-loinc-crosswalk-migration.php
- docs/PSORIASIS_PROSPECTIVE_EXECUTION_V1.md
- app/test-results.php
- app/test-results-api.php
- backend/phase_69_legacy_source_verification_access.sql
- backend/phase_60_subject_test_result_ledger.sql
- backend/phase_56_test_atlas_loinc_crosswalk.sql
- backend/phase_55_online_test_topic_engine.sql

## Exchange disconnected Excel/CSV
- db-mirror/releases/20260913T103945Z/00_CONTROL_ROOM.xlsx
- db-mirror/releases/20260913T103945Z/DB_Mirror_057.xlsx
- db-mirror/releases/20260913T103945Z/DB_Mirror_016.xlsx
- db-mirror/releases/20260913T103945Z/DB_Mirror_052.xlsx
- db-mirror/releases/20260913T103945Z/DB_Mirror_024.xlsx
- db-mirror/releases/20260913T103945Z/DB_Mirror_028.xlsx
- db-mirror/releases/20260913T103945Z/DB_Mirror_033.xlsx
- db-mirror/releases/20260913T103945Z/DB_Mirror_047.xlsx
- db-mirror/releases/20260913T103945Z/DB_Mirror_038.xlsx
- db-mirror/releases/20260913T103945Z/DB_Mirror_032.xlsx
- db-mirror/releases/20260913T103945Z/DB_Mirror_005.xlsx
- db-mirror/releases/20260913T103945Z/DB_Mirror_002.xlsx
- db-mirror/releases/20260913T103945Z/DB_Mirror_041.xlsx
- db-mirror/releases/20260913T103945Z/DB_Mirror_023.xlsx
- db-mirror/releases/20260913T103945Z/DB_Mirror_008.xlsx
- db-mirror/releases/20260913T103945Z/DB_Mirror_003.xlsx
- db-mirror/releases/20260913T103945Z/DB_Mirror_001.xlsx
- db-mirror/releases/20260913T103945Z/DB_Mirror_055.xlsx
- db-mirror/releases/20260913T103945Z/DB_Mirror_017.xlsx
- db-mirror/releases/20260913T103945Z/DB_Mirror_035.xlsx
- db-mirror/releases/20260913T103945Z/DB_Mirror_030.xlsx
- db-mirror/releases/20260913T103945Z/DB_Mirror_031.xlsx
- db-mirror/releases/20260913T103945Z/DB_Mirror_051.xlsx
- db-mirror/releases/20260913T103945Z/DB_Mirror_040.xlsx
- db-mirror/releases/20260913T103945Z/DB_Mirror_048.xlsx
- db-mirror/releases/20260913T103945Z/DB_Mirror_009.xlsx
- db-mirror/releases/20260913T103945Z/DB_Mirror_037.xlsx
- db-mirror/releases/20260913T103945Z/DB_Mirror_060.xlsx
- db-mirror/releases/20260913T103945Z/DB_Mirror_013.xlsx
- db-mirror/releases/20260913T103945Z/DB_Mirror_007.xlsx
- db-mirror/releases/20260913T103945Z/DB_Mirror_043.xlsx
- db-mirror/releases/20260913T103945Z/DB_Mirror_053.xlsx
- db-mirror/releases/20260913T103945Z/DB_Mirror_027.xlsx
- db-mirror/releases/20260913T103945Z/DB_Mirror_025.xlsx
- db-mirror/releases/20260913T103945Z/DB_Mirror_046.xlsx
- db-mirror/releases/20260913T103945Z/DB_Mirror_015.xlsx
- db-mirror/releases/20260913T103945Z/DB_Mirror_010.xlsx
- db-mirror/releases/20260913T103945Z/DB_Mirror_014.xlsx
- db-mirror/releases/20260913T103945Z/DB_Mirror_042.xlsx
- db-mirror/releases/20260913T103945Z/DB_Mirror_022.xlsx
- db-mirror/releases/20260913T103945Z/DB_Mirror_020.xlsx
- db-mirror/releases/20260913T103945Z/DB_Mirror_012.xlsx
- db-mirror/releases/20260913T103945Z/DB_Mirror_004.xlsx
- db-mirror/releases/20260913T103945Z/DB_Mirror_045.xlsx
- db-mirror/releases/20260913T103945Z/DB_Mirror_006.xlsx
- db-mirror/releases/20260913T103945Z/DB_Mirror_011.xlsx
- db-mirror/releases/20260913T103945Z/DB_Mirror_058.xlsx
- db-mirror/releases/20260913T103945Z/DB_Mirror_054.xlsx
- db-mirror/releases/20260913T103945Z/DB_Mirror_056.xlsx
- db-mirror/releases/20260913T103945Z/DB_Mirror_021.xlsx
- db-mirror/releases/20260913T103945Z/DB_Mirror_026.xlsx
- db-mirror/releases/20260913T103945Z/DB_Mirror_039.xlsx
- db-mirror/releases/20260913T103945Z/DB_Mirror_018.xlsx
- db-mirror/releases/20260913T103945Z/DB_Mirror_059.xlsx
- db-mirror/releases/20260913T103945Z/DB_Mirror_049.xlsx
- db-mirror/releases/20260913T103945Z/DB_Mirror_029.xlsx
- db-mirror/releases/20260913T103945Z/DB_Mirror_036.xlsx
- db-mirror/releases/20260913T103945Z/DB_Mirror_034.xlsx
- db-mirror/releases/20260913T103945Z/DB_Mirror_019.xlsx
- db-mirror/releases/20260913T103945Z/DB_Mirror_050.xlsx
- db-mirror/releases/20260913T103945Z/DB_Mirror_044.xlsx

Candidates only. Nothing was deleted or altered.
