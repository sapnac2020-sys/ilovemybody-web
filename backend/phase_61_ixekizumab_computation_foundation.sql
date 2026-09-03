-- Phase 61: ixekizumab molecule-to-patient computation foundation.
-- Creates definitions and empty longitudinal ledgers; reads/writes no existing patient record.
START TRANSACTION;

CREATE TABLE IF NOT EXISTS ilb_ixekizumab_connector (
 connector_key varchar(100) NOT NULL, source_system varchar(80) NOT NULL, source_id varchar(120) NOT NULL,
 entity_type varchar(60) NOT NULL, label varchar(240) NOT NULL, predicate varchar(80) NOT NULL,
 target_system varchar(80) NOT NULL, target_id varchar(120) NOT NULL, target_label varchar(240) NOT NULL,
 evidence_url varchar(1000) NOT NULL, match_type enum('EXACT','RELATED','BLOCKED') NOT NULL,
 approval_status enum('APPROVED','REVIEW','BLOCKED') NOT NULL, computation_eligible tinyint(1) NOT NULL DEFAULT 0,
 decision_note varchar(1800) NOT NULL, PRIMARY KEY(connector_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO ilb_ixekizumab_connector VALUES
('IXE_RXNORM','ILMB','ixekizumab','DRUG','Ixekizumab','HAS_RXNORM_ID','RXNORM','1745099','ixekizumab','https://mor.nlm.nih.gov/RxNav/search?searchBy=RXCUI&searchTerm=1745099','EXACT','APPROVED',1,'Exact ingredient identity.'),
('IXE_ATC','ILMB','ixekizumab','DRUG','Ixekizumab','HAS_ATC_CODE','ATC','L04AC13','ixekizumab','https://atcddd.fhi.no/atc_ddd_index/?code=L04AC13','EXACT','APPROVED',1,'WHO ATC interleukin inhibitor identity.'),
('IXE_TARGET','ILMB','ixekizumab','DRUG','Ixekizumab','BINDS_TARGET','UNIPROT','Q16552','Interleukin-17A','https://www.uniprot.org/uniprotkb/Q16552/entry','EXACT','APPROVED',1,'Regulatory label states selective binding to IL-17A; UniProt identifies the human protein.'),
('IL17A_GENE','UNIPROT','Q16552','PROTEIN','Interleukin-17A','ENCODED_BY','NCBI_GENE','3605','IL17A','https://www.ncbi.nlm.nih.gov/gene/3605','EXACT','APPROVED',1,'Exact human gene/protein identity.'),
('IXE_CHEBI_BLOCK','ILMB','ixekizumab','DRUG','Ixekizumab','HAS_CHEBI_ID','CHEBI','','No verified ChEBI entity','','BLOCKED','BLOCKED',0,'Engineered monoclonal antibody; no exact approved ChEBI identifier may be inferred.'),
('IXE_ACUPUNCTURE_BLOCK','ILMB','ixekizumab','DRUG','Ixekizumab','INTERACTS_WITH','ILMB_ACUPUNCTURE','','No verified drug-point interaction','','BLOCKED','BLOCKED',0,'No approved point-to-node mapping, exact acupuncture XYZ, compatible pH frame, or measured ixekizumab interaction is available.')
ON DUPLICATE KEY UPDATE source_system=VALUES(source_system),source_id=VALUES(source_id),entity_type=VALUES(entity_type),label=VALUES(label),predicate=VALUES(predicate),target_system=VALUES(target_system),target_id=VALUES(target_id),target_label=VALUES(target_label),evidence_url=VALUES(evidence_url),match_type=VALUES(match_type),approval_status=VALUES(approval_status),computation_eligible=VALUES(computation_eligible),decision_note=VALUES(decision_note);

CREATE TABLE IF NOT EXISTS ilb_ixekizumab_equation (
 equation_key varchar(100) NOT NULL, equation_name varchar(240) NOT NULL, equation_text varchar(3000) NOT NULL,
 model_layer enum('PK','BINDING','INFLAMMATION','PASI','PH','EXPOSURE_RESPONSE') NOT NULL,
 input_contract varchar(2500) NOT NULL, output_contract varchar(1500) NOT NULL,
 evidence_url varchar(1000) NOT NULL, validation_status enum('ESTABLISHED','MODEL_STRUCTURE','RESEARCH_ONLY','BLOCKED') NOT NULL,
 patient_execution_gate varchar(2000) NOT NULL, status enum('active','retired') NOT NULL DEFAULT 'active',
 PRIMARY KEY(equation_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO ilb_ixekizumab_equation VALUES
('PK_DEPOT','First-order subcutaneous absorption','dA_D/dt = -ka*A_D','PK','Dose amount A_D and sourced absorption-rate constant ka.','Amount remaining in injection depot versus time.','https://pubmed.ncbi.nlm.nih.gov/34378230/','MODEL_STRUCTURE','Execute only with an applicable sourced parameter set and declared population; never infer ka from dose.','active'),
('PK_CENTRAL','Two-compartment central amount','dA_C/dt = F*ka*A_D - (CL/V_C + Q/V_C)*A_C + (Q/V_P)*A_P','PK','A_D,A_C,A_P,F,ka,CL,Q,V_C,V_P with units and source.','Central amount versus time.','https://pubmed.ncbi.nlm.nih.gov/34378230/','MODEL_STRUCTURE','All parameters, population and units must resolve before execution.','active'),
('PK_PERIPHERAL','Two-compartment peripheral amount','dA_P/dt = (Q/V_C)*A_C - (Q/V_P)*A_P','PK','A_C,A_P,Q,V_C,V_P with units and source.','Peripheral amount versus time.','https://pubmed.ncbi.nlm.nih.gov/34378230/','MODEL_STRUCTURE','All parameters, population and units must resolve before execution.','active'),
('PK_CONCENTRATION','Central concentration','C(t) = A_C(t)/V_C','PK','Central amount and central volume in compatible units.','Serum concentration versus time.','https://pubmed.ncbi.nlm.nih.gov/34378230/','ESTABLISHED','Compatible units and applicable PK model required.','active'),
('BINDING_MASS_ACTION','Reversible target binding','d[DL]/dt = kon*[D]*[L] - koff*[DL]','BINDING','Free drug, free IL-17A, complex, kon and koff from an applicable assay.','Drug-target complex versus time.','https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=ac96658a-d7dc-4c7c-8928-2adcdf4318b2','MODEL_STRUCTURE','No patient execution without measured/sourced free concentrations and kinetic constants.','active'),
('PH_DEFINITION','Hydrogen activity definition','pH = -log10(a_H+)','PH','Measured hydrogen-ion activity a_H+ in a declared compartment, method, temperature and time.','Compartment-specific pH.','','ESTABLISHED','Never substitute saliva, urine, blood, skin-surface or geometric pH for another compartment.','active'),
('PASI_TOTAL','Psoriasis Area and Severity Index','PASI = 0.1*(Eh+Ih+Dh)*Ah + 0.2*(Eu+Iu+Du)*Au + 0.3*(Et+It+Dt)*At + 0.4*(El+Il+Dl)*Al','PASI','Clinician-scored erythema, induration, desquamation and area category for head, upper limbs, trunk and lower limbs.','PASI score 0-72.','https://www.nice.org.uk/guidance/cg153/chapter/1-recommendations','ESTABLISHED','Require complete components, valid ranges, trained assessor and assessment date.','active'),
('PASI_CHANGE','PASI percentage improvement','100*(PASI_baseline-PASI_t)/PASI_baseline','EXPOSURE_RESPONSE','Verified baseline PASI > 0 and follow-up PASI using the same method.','Percentage change from baseline.','https://pubmed.ncbi.nlm.nih.gov/34378230/','ESTABLISHED','Do not label PASI100 as permanent cure; report measured clearance at the assessment.','active')
ON DUPLICATE KEY UPDATE equation_name=VALUES(equation_name),equation_text=VALUES(equation_text),model_layer=VALUES(model_layer),input_contract=VALUES(input_contract),output_contract=VALUES(output_contract),evidence_url=VALUES(evidence_url),validation_status=VALUES(validation_status),patient_execution_gate=VALUES(patient_execution_gate),status=VALUES(status);

CREATE TABLE IF NOT EXISTS ilb_ixekizumab_parameter (
 parameter_set_key varchar(100) NOT NULL, equation_key varchar(100) NOT NULL, population_key varchar(120) NOT NULL,
 parameter_name varchar(80) NOT NULL, parameter_value decimal(24,10) DEFAULT NULL, unit_ucum varchar(80) DEFAULT NULL,
 source_url varchar(1000) NOT NULL, source_location varchar(500) NOT NULL,
 verification_status enum('VERIFIED','MISSING','NOT_APPLICABLE') NOT NULL,
 PRIMARY KEY(parameter_set_key,parameter_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO ilb_ixekizumab_parameter VALUES
('IXE_ADULT_PSO_PENDING','PK_CENTRAL','adult_moderate_severe_plaque_psoriasis','ka',NULL,NULL,'https://pubmed.ncbi.nlm.nih.gov/24752880/','Exact published model parameter table required','MISSING'),
('IXE_ADULT_PSO_PENDING','PK_CENTRAL','adult_moderate_severe_plaque_psoriasis','CL',NULL,NULL,'https://pubmed.ncbi.nlm.nih.gov/24752880/','Exact published model parameter table required','MISSING'),
('IXE_ADULT_PSO_PENDING','PK_CENTRAL','adult_moderate_severe_plaque_psoriasis','Q',NULL,NULL,'https://pubmed.ncbi.nlm.nih.gov/24752880/','Exact published model parameter table required','MISSING'),
('IXE_ADULT_PSO_PENDING','PK_CENTRAL','adult_moderate_severe_plaque_psoriasis','V_C',NULL,NULL,'https://pubmed.ncbi.nlm.nih.gov/24752880/','Exact published model parameter table required','MISSING'),
('IXE_ADULT_PSO_PENDING','PK_CENTRAL','adult_moderate_severe_plaque_psoriasis','V_P',NULL,NULL,'https://pubmed.ncbi.nlm.nih.gov/24752880/','Exact published model parameter table required','MISSING'),
('IXE_ADULT_PSO_PENDING','BINDING_MASS_ACTION','human_IL17A_assay','kon',NULL,NULL,'','Exact ixekizumab/IL-17A kinetic assay required','MISSING'),
('IXE_ADULT_PSO_PENDING','BINDING_MASS_ACTION','human_IL17A_assay','koff',NULL,NULL,'','Exact ixekizumab/IL-17A kinetic assay required','MISSING')
ON DUPLICATE KEY UPDATE equation_key=VALUES(equation_key),population_key=VALUES(population_key),parameter_value=VALUES(parameter_value),unit_ucum=VALUES(unit_ucum),source_url=VALUES(source_url),source_location=VALUES(source_location),verification_status=VALUES(verification_status);

CREATE TABLE IF NOT EXISTS ilb_psoriasis_treatment_episode (
 episode_id bigint unsigned NOT NULL AUTO_INCREMENT, subject_key varchar(80) NOT NULL,
 confirmed_condition_key varchar(80) NOT NULL, prescriber_reference varchar(255) NOT NULL,
 started_at datetime NOT NULL, ended_at datetime DEFAULT NULL, status enum('planned','active','paused','completed','stopped') NOT NULL,
 created_at timestamp NOT NULL DEFAULT current_timestamp(), PRIMARY KEY(episode_id), KEY idx_p61_episode_subject(subject_key,started_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ilb_ixekizumab_dose_event (
 dose_event_id bigint unsigned NOT NULL AUTO_INCREMENT, episode_id bigint unsigned NOT NULL,
 medicine_key varchar(80) NOT NULL DEFAULT 'ixekizumab', product_brand varchar(180) NOT NULL,
 dose_value decimal(12,4) NOT NULL, dose_unit varchar(30) NOT NULL, route varchar(40) NOT NULL,
 administered_at datetime NOT NULL, evidence_document_key varchar(160) DEFAULT NULL,
 verification_status enum('patient_reported','prescription_verified','administration_verified') NOT NULL,
 PRIMARY KEY(dose_event_id), KEY idx_p61_dose_episode(episode_id,administered_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ilb_psoriasis_pasi_observation (
 pasi_observation_id bigint unsigned NOT NULL AUTO_INCREMENT, episode_id bigint unsigned NOT NULL,
 observed_at datetime NOT NULL, assessor_reference varchar(160) NOT NULL,
 head_e tinyint unsigned NOT NULL,head_i tinyint unsigned NOT NULL,head_d tinyint unsigned NOT NULL,head_a tinyint unsigned NOT NULL,
 upper_e tinyint unsigned NOT NULL,upper_i tinyint unsigned NOT NULL,upper_d tinyint unsigned NOT NULL,upper_a tinyint unsigned NOT NULL,
 trunk_e tinyint unsigned NOT NULL,trunk_i tinyint unsigned NOT NULL,trunk_d tinyint unsigned NOT NULL,trunk_a tinyint unsigned NOT NULL,
 lower_e tinyint unsigned NOT NULL,lower_i tinyint unsigned NOT NULL,lower_d tinyint unsigned NOT NULL,lower_a tinyint unsigned NOT NULL,
 method_version varchar(80) NOT NULL, source_document_key varchar(160) DEFAULT NULL,
 PRIMARY KEY(pasi_observation_id), KEY idx_p61_pasi_episode(episode_id,observed_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE OR REPLACE VIEW v_ilmb_psoriasis_pasi_calculated AS
SELECT p.*,ROUND(
 0.1*(head_e+head_i+head_d)*head_a+
 0.2*(upper_e+upper_i+upper_d)*upper_a+
 0.3*(trunk_e+trunk_i+trunk_d)*trunk_a+
 0.4*(lower_e+lower_i+lower_d)*lower_a,2) AS pasi_score,
 CASE WHEN head_e<=4 AND head_i<=4 AND head_d<=4 AND head_a<=6
 AND upper_e<=4 AND upper_i<=4 AND upper_d<=4 AND upper_a<=6
 AND trunk_e<=4 AND trunk_i<=4 AND trunk_d<=4 AND trunk_a<=6
 AND lower_e<=4 AND lower_i<=4 AND lower_d<=4 AND lower_a<=6 THEN 1 ELSE 0 END AS range_gate_passed
FROM ilb_psoriasis_pasi_observation p;

CREATE TABLE IF NOT EXISTS ilb_psoriasis_ph_observation (
 ph_observation_id bigint unsigned NOT NULL AUTO_INCREMENT, episode_id bigint unsigned NOT NULL,
 observed_at datetime NOT NULL, compartment enum('skin_surface_lesion','skin_surface_nonlesion','blood_arterial','blood_venous','saliva','urine','other') NOT NULL,
 anatomical_site varchar(180) DEFAULT NULL, ph_value decimal(8,5) NOT NULL,
 instrument_id varchar(160) NOT NULL, calibration_reference varchar(255) NOT NULL,
 temperature_c decimal(8,3) DEFAULT NULL, protocol_context varchar(1200) NOT NULL,
 comparison_eligible tinyint(1) NOT NULL DEFAULT 0, PRIMARY KEY(ph_observation_id),
 KEY idx_p61_ph_episode(episode_id,observed_at,compartment)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ilb_psoriasis_acupuncture_observation (
 session_id bigint unsigned NOT NULL AUTO_INCREMENT, episode_id bigint unsigned NOT NULL,
 session_at datetime NOT NULL, practitioner_reference varchar(160) NOT NULL,
 point_code varchar(40) NOT NULL, laterality varchar(30) DEFAULT NULL,
 stimulation_method varchar(120) NOT NULL, duration_minutes decimal(8,2) DEFAULT NULL,
 anatomy_mapping_status enum('APPROVED','BLOCKED') NOT NULL DEFAULT 'BLOCKED',
 exact_xyz_status enum('APPROVED','BLOCKED') NOT NULL DEFAULT 'BLOCKED',
 ph_frame_compatible tinyint(1) NOT NULL DEFAULT 0, causal_claim_allowed tinyint(1) NOT NULL DEFAULT 0,
 source_document_key varchar(160) DEFAULT NULL, PRIMARY KEY(session_id),
 KEY idx_p61_acu_episode(episode_id,session_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE OR REPLACE VIEW v_ilmb_ixekizumab_computation_readiness AS
SELECT
 (SELECT COUNT(*) FROM ilb_ixekizumab_connector WHERE approval_status='APPROVED' AND computation_eligible=1) approved_connectors,
 (SELECT COUNT(*) FROM ilb_ixekizumab_connector WHERE approval_status='BLOCKED') blocked_connectors,
 (SELECT COUNT(*) FROM ilb_ixekizumab_equation WHERE validation_status IN ('ESTABLISHED','MODEL_STRUCTURE') AND status='active') registered_equations,
 (SELECT COUNT(*) FROM ilb_ixekizumab_parameter WHERE verification_status='VERIFIED') verified_parameters,
 (SELECT COUNT(*) FROM ilb_ixekizumab_parameter WHERE verification_status='MISSING') missing_parameters,
 CASE WHEN (SELECT COUNT(*) FROM ilb_ixekizumab_parameter WHERE verification_status='MISSING')=0 THEN 1 ELSE 0 END pk_pd_patient_execution_enabled,
 1 AS pasi_execution_enabled,
 1 AS compartment_ph_recording_enabled,
 0 AS acupuncture_causal_execution_enabled;

COMMIT;