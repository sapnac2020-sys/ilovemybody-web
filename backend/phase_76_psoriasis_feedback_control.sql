-- Phase 76: psoriasis persistence, renewal and feedback-control mathematics.
START TRANSACTION;

CREATE TABLE IF NOT EXISTS ilb_psoriasis_feedback_segment (
 segment_key varchar(120) NOT NULL,
 sequence_no smallint unsigned NOT NULL,
 source_node_key varchar(100) NOT NULL,
 target_node_key varchar(100) NOT NULL,
 biological_role enum('INITIATION','AMPLIFICATION','EXECUTION','VISIBLE_OUTPUT','FEEDBACK','RESOLUTION') NOT NULL,
 gain_symbol varchar(120) NOT NULL,
 loss_symbol varchar(120) NOT NULL,
 directly_observable tinyint(1) NOT NULL DEFAULT 0,
 observable_key varchar(100) DEFAULT NULL,
 source_url varchar(1000) NOT NULL,
 status enum('active','retired') NOT NULL DEFAULT 'active',
 PRIMARY KEY(segment_key),
 KEY idx_p76_sequence(sequence_no),
 KEY idx_p76_source(source_node_key),
 KEY idx_p76_target(target_node_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ilb_psoriasis_control_equation (
 equation_key varchar(100) NOT NULL,
 equation_text varchar(3500) NOT NULL,
 result_meaning varchar(2200) NOT NULL,
 required_inputs varchar(2600) NOT NULL,
 result_gate varchar(2200) NOT NULL,
 evidence_basis enum('DEFINITION','CONTROL_THEORY','BIOLOGICAL_MODEL','CLINICAL_INDEX') NOT NULL,
 source_url varchar(1000) NOT NULL,
 execution_status enum('EXECUTABLE','PARAMETERS_REQUIRED','OBSERVATIONS_REQUIRED') NOT NULL,
 PRIMARY KEY(equation_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ilb_psoriasis_loop_observable (
 observable_key varchar(100) NOT NULL,
 label varchar(240) NOT NULL,
 db_object varchar(160) NOT NULL,
 db_field_or_formula varchar(1000) NOT NULL,
 unit_contract varchar(600) NOT NULL,
 time_contract varchar(800) NOT NULL,
 role enum('STATE','INPUT','OUTPUT','CONFOUNDING_CONTEXT') NOT NULL,
 readiness enum('READY','SOURCE_PARAMETER_REQUIRED','MEASUREMENT_REQUIRED') NOT NULL,
 PRIMARY KEY(observable_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO ilb_psoriasis_loop_observable VALUES
('DC_STATE','Activated dendritic-cell state','ilb_psoriasis_mechanism_node','D(t)','declared cell density or validated activation assay','same anatomical compartment and timestamps','STATE','MEASUREMENT_REQUIRED'),
('IL23_STATE','IL-23 state','ilb_psoriasis_mechanism_node','IL23(t)','declared concentration unit','same compartment, assay and timestamps','STATE','MEASUREMENT_REQUIRED'),
('TH17_STATE','Th17 state','ilb_psoriasis_mechanism_node','Th17(t)','declared cell density or proportion with denominator','same tissue/blood compartment and timestamps','STATE','MEASUREMENT_REQUIRED'),
('IL17A_STATE','Free IL-17A state','ilb_psoriasis_mechanism_node','IL17A_free(t)','declared molar or mass concentration','free-ligand assay, compartment and timestamps','STATE','MEASUREMENT_REQUIRED'),
('KC_STATE','Keratinocyte response','ilb_psoriasis_mechanism_node','KC(t)','validated proliferation/differentiation measure','same lesion and timestamps','STATE','MEASUREMENT_REQUIRED'),
('PLAQUE_STATE','Clinical plaque burden','v_ilmb_psoriasis_pasi_calculated','pasi_score','PASI 0-72','baseline and follow-up by same method','OUTPUT','READY'),
('PH_STATE','Hydrogen ion activity','ilb_psoriasis_ph_observation','ph_value and compartment','pH with calibration and temperature','never substitute one compartment for another','CONFOUNDING_CONTEXT','READY'),
('DRUG_INPUT','Ixekizumab exposure','ilb_ixekizumab_dose_event','dose_value,dose_unit,route,administered_at','verified dose and time','administration timestamp required','INPUT','READY'),
('ACUPUNCTURE_INPUT','Acupuncture exposure','ilb_psoriasis_acupuncture_observation','point_code,method,duration,session_at','point identity and exposure','anatomy mapping and exact session time','INPUT','MEASUREMENT_REQUIRED'),
('AUTONOMIC_STATE','Autonomic state','ilb_psoriasis_mechanism_edge','N(t)','declared validated physiological measure','timestamp aligned to immune and skin observations','CONFOUNDING_CONTEXT','MEASUREMENT_REQUIRED')
ON DUPLICATE KEY UPDATE label=VALUES(label),db_object=VALUES(db_object),db_field_or_formula=VALUES(db_field_or_formula),unit_contract=VALUES(unit_contract),time_contract=VALUES(time_contract),role=VALUES(role),readiness=VALUES(readiness);

INSERT INTO ilb_psoriasis_feedback_segment VALUES
('S01_DC_IL23',1,'DENDRITIC_CELL','IL23','INITIATION','k_DC_IL23','mu_IL23',0,'DC_STATE','https://pubmed.ncbi.nlm.nih.gov/23291100/','active'),
('S02_IL23_TH17',2,'IL23','TH17','AMPLIFICATION','k_IL23_TH17','mu_TH17',0,'IL23_STATE','https://pubmed.ncbi.nlm.nih.gov/23291100/','active'),
('S03_TH17_IL17A',3,'TH17','IL17A','AMPLIFICATION','k_TH17_IL17A','mu_IL17A',0,'TH17_STATE','https://pubmed.ncbi.nlm.nih.gov/23291100/','active'),
('S04_IL17A_RECEPTOR',4,'IL17A','IL17_RECEPTOR','EXECUTION','kon_R','koff_R',0,'IL17A_STATE','https://reactome.org/content/detail/R-HSA-447246','active'),
('S05_RECEPTOR_ACT1',5,'IL17_RECEPTOR','TRAF3IP2','EXECUTION','k_R_ACT1','mu_ACT1',0,NULL,'https://reactome.org/content/detail/R-HSA-8951104','active'),
('S06_ACT1_TRAF6',6,'TRAF3IP2','TRAF6','EXECUTION','k_ACT1_TRAF6','mu_TRAF6',0,NULL,'https://reactome.org/content/detail/R-HSA-8980293','active'),
('S07_SIGNAL_KC',7,'IL17_SIGNAL','KERATINOCYTE_RESPONSE','EXECUTION','k_SIGNAL_KC','mu_KC',0,'KC_STATE','https://pubmed.ncbi.nlm.nih.gov/23291100/','active'),
('S08_KC_PLAQUE',8,'KERATINOCYTE_RESPONSE','PSORIASIS_PLAQUE','VISIBLE_OUTPUT','k_KC_PLAQUE','mu_P',1,'PLAQUE_STATE','https://pubmed.ncbi.nlm.nih.gov/27883001/','active'),
('S09_KC_DC',9,'KERATINOCYTE_RESPONSE','DENDRITIC_CELL','FEEDBACK','k_feedback','mu_DC',0,'DC_STATE','https://pubmed.ncbi.nlm.nih.gov/23291100/','active')
ON DUPLICATE KEY UPDATE sequence_no=VALUES(sequence_no),source_node_key=VALUES(source_node_key),target_node_key=VALUES(target_node_key),biological_role=VALUES(biological_role),gain_symbol=VALUES(gain_symbol),loss_symbol=VALUES(loss_symbol),directly_observable=VALUES(directly_observable),observable_key=VALUES(observable_key),source_url=VALUES(source_url),status=VALUES(status);

INSERT INTO ilb_psoriasis_control_equation VALUES
('STATE_VECTOR','x(t) = [DC,IL23,Th17,IL17A_free,IL17R_signal,KC,P]^T','The complete persistence state; plaque P is the visible final component, not the complete disease state.','All seven states with compatible time and compartment definitions.','No end-to-end numerical claim unless every state is observed or a validated observation model supplies it.','DEFINITION','https://pubmed.ncbi.nlm.nih.gov/23291100/','OBSERVATIONS_REQUIRED'),
('SYSTEM_DYNAMICS','dx/dt = F(x,u,theta)','Each state changes through production/activation terms, removal/resolution terms and intervention inputs.','State vector x, input vector u and sourced parameter vector theta.','Executable only when units, parameters, population and initial conditions resolve.','BIOLOGICAL_MODEL','https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0334101','PARAMETERS_REQUIRED'),
('SKIN_RENEWAL','dP/dt = Formation(KC,IL17_signal) - Resolution(P)','A plaque persists when repeated inflammatory formation matches or exceeds resolution; persistence does not mean the same skin cells remain.','Keratinocyte response, IL-17 signal, plaque burden and time-aligned formation/resolution parameters.','P decreases only where the evaluated derivative is negative over the declared interval.','BIOLOGICAL_MODEL','https://pmc.ncbi.nlm.nih.gov/articles/PMC4305409/','PARAMETERS_REQUIRED'),
('PERSISTENCE_GATE','Persistent at t iff Formation(t) - Resolution(t) >= 0','Direct mathematical test of continued plaque production.','Formation and resolution in identical plaque-burden units per time.','Negative value supports resolution; zero indicates no net change; positive value supports persistence/growth.','DEFINITION','https://pmc.ncbi.nlm.nih.gov/articles/PMC4305409/','OBSERVATIONS_REQUIRED'),
('EQUILIBRIUM','F(x_star,u_star,theta) = 0','A healthy or psoriatic operating state is an equilibrium of the whole connected system.','Complete parameterized model and candidate state x_star.','Residual norm must be within a preregistered numerical tolerance.','CONTROL_THEORY','https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0334101','PARAMETERS_REQUIRED'),
('LOCAL_STABILITY','J = partial F/partial x at x_star; stable iff max(real(eigenvalues(J))) < 0','Tests whether the system returns toward an operating state after a small perturbation.','Differentiable F, parameter set and equilibrium x_star.','Negative dominant real eigenvalue means local return; positive means local divergence.','CONTROL_THEORY','https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0334101','PARAMETERS_REQUIRED'),
('LOOP_GAIN','G_local = product over loop edges of partial(target_rate)/partial(source_state) at x_star','Quantifies the strength of the closed immune-keratinocyte amplification loop near an operating state.','Every loop-edge derivative evaluated at the same state and units normalized consistently.','Compare interventions by their change in dominant eigenvalue and G_local, never by an invented universal cutoff.','CONTROL_THEORY','https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0334101','PARAMETERS_REQUIRED'),
('DRUG_CONTROL','IL17A_free = IL17A_total - D_IL17A_complex','Ixekizumab acts on free IL-17A availability downstream of IL-23 and Th17 production.','Total IL-17A and drug-ligand complex in compatible units.','This equation establishes target position; upstream-loop change requires upstream observations.','DEFINITION','https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=ac96658a-d7dc-4c7c-8928-2adcdf4318b2','OBSERVATIONS_REQUIRED'),
('INTERVENTION_EFFECT','Delta_loop = lambda_max(J_after) - lambda_max(J_before)','Measures whether an intervention moves local dynamics toward or away from resolution.','Matched before/after parameterized Jacobians under a declared intervention.','Delta_loop < 0 is the required mathematical direction; clinical benefit additionally requires Delta PASI < 0.','CONTROL_THEORY','https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0334101','PARAMETERS_REQUIRED'),
('CLINICAL_EFFECT','DeltaPASI_percent = 100*(PASI_baseline-PASI_t)/PASI_baseline','Measures change in visible clinical burden.','Verified baseline PASI greater than zero and matched follow-up PASI.','Reports measured clearance only; does not by itself prove feedback-loop removal.','CLINICAL_INDEX','https://www.nice.org.uk/guidance/cg153/chapter/1-recommendations','EXECUTABLE')
ON DUPLICATE KEY UPDATE equation_text=VALUES(equation_text),result_meaning=VALUES(result_meaning),required_inputs=VALUES(required_inputs),result_gate=VALUES(result_gate),evidence_basis=VALUES(evidence_basis),source_url=VALUES(source_url),execution_status=VALUES(execution_status);

CREATE OR REPLACE VIEW v_ilmb_psoriasis_feedback_control_readiness AS
SELECT
 (SELECT COUNT(*) FROM ilb_psoriasis_feedback_segment WHERE status='active') active_loop_segments,
 (SELECT COUNT(*) FROM ilb_psoriasis_loop_observable WHERE readiness='READY') ready_observables,
 (SELECT COUNT(*) FROM ilb_psoriasis_loop_observable WHERE readiness='MEASUREMENT_REQUIRED') measurement_required,
 (SELECT COUNT(*) FROM ilb_psoriasis_control_equation WHERE execution_status='EXECUTABLE') executable_equations,
 (SELECT COUNT(*) FROM ilb_psoriasis_control_equation WHERE execution_status='PARAMETERS_REQUIRED') parameter_gated_equations,
 CASE WHEN (SELECT COUNT(*) FROM ilb_psoriasis_feedback_segment WHERE status='active')=9 THEN 1 ELSE 0 END AS persistence_loop_structurally_complete,
 CASE WHEN
  (SELECT COUNT(*) FROM ilb_psoriasis_loop_observable WHERE observable_key IN ('DC_STATE','IL23_STATE','TH17_STATE','IL17A_STATE','KC_STATE','PLAQUE_STATE') AND readiness='READY')=6
  AND (SELECT COUNT(*) FROM ilb_psoriasis_control_equation WHERE equation_key IN ('SYSTEM_DYNAMICS','LOCAL_STABILITY','LOOP_GAIN') AND execution_status='EXECUTABLE')=3
 THEN 1 ELSE 0 END AS feedback_loop_numerically_identified;

COMMIT;
