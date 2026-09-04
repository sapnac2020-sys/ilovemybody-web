-- Phase 78: governed end-to-end psoriasis research programme.
-- Additive only. No patient data, prescribing rule, efficacy threshold or invented coefficient.
START TRANSACTION;

CREATE TABLE IF NOT EXISTS ilb_psoriasis_program (
 program_key varchar(80) NOT NULL,
 programme_name varchar(240) NOT NULL,
 declared_use varchar(1200) NOT NULL,
 prohibited_use varchar(1200) NOT NULL,
 model_key varchar(100) NOT NULL,
 status enum('RESEARCH_OPERATIONAL','EVIDENCE_INCOMPLETE','VALIDATED_FOR_DECLARED_USE') NOT NULL,
 PRIMARY KEY(program_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ilb_psoriasis_formula_registry (
 formula_key varchar(100) NOT NULL,
 layer enum('PUBLISHED_DISEASE','PHARMACOKINETIC','TARGET_ENGAGEMENT','PERSISTENCE','OBSERVATION','DECISION') NOT NULL,
 lhs varchar(300) NOT NULL,
 rhs text NOT NULL,
 formula_role varchar(600) NOT NULL,
 provenance enum('SOURCE_EXACT','STANDARD_MODEL_STRUCTURE','EVIDENCE_SUPPORTED_HYPOTHESIS','DECISION_IDENTITY') NOT NULL,
 numerical_status enum('EXECUTABLE','PARAMETERS_REQUIRED','OBSERVATIONS_REQUIRED','RESEARCH_ONLY') NOT NULL,
 source_key varchar(160) DEFAULT NULL,
 patient_use_allowed tinyint(1) NOT NULL DEFAULT 0,
 PRIMARY KEY(formula_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ilb_psoriasis_pharma_agent (
 agent_key varchar(80) NOT NULL,
 ingredient_name varchar(180) NOT NULL,
 molecule_class enum('MONOCLONAL_ANTIBODY','FUSION_PROTEIN') NOT NULL,
 administration_route enum('SUBCUTANEOUS','INTRAVENOUS') NOT NULL,
 mechanism_class varchar(180) NOT NULL,
 identity_status enum('EXACT_APPROVED','SOURCE_CONFIRMATION_REQUIRED') NOT NULL,
 calculation_status enum('IDENTITY_ONLY','PARAMETER_INCOMPLETE','EXECUTABLE') NOT NULL DEFAULT 'IDENTITY_ONLY',
 PRIMARY KEY(agent_key),
 UNIQUE KEY uq_p78_agent_name(ingredient_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ilb_psoriasis_pharma_identifier (
 agent_key varchar(80) NOT NULL,
 identifier_system varchar(40) NOT NULL,
 identifier_value varchar(180) NOT NULL,
 match_type enum('EXACT','CANDIDATE') NOT NULL,
 approval_status enum('APPROVED','REVIEW_REQUIRED') NOT NULL,
 computation_eligible tinyint(1) NOT NULL DEFAULT 0,
 evidence_url varchar(1000) DEFAULT NULL,
 PRIMARY KEY(agent_key,identifier_system,identifier_value)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ilb_psoriasis_pharma_target (
 agent_key varchar(80) NOT NULL,
 target_key varchar(100) NOT NULL,
 intervention_operator enum('NEUTRALISE_LIGAND','BLOCK_RECEPTOR','INTERCEPT_LIGAND') NOT NULL,
 model_quantity varchar(180) NOT NULL,
 mapping_status enum('STRUCTURAL_EXACT','EXTERNAL_ID_REQUIRED') NOT NULL,
 computation_eligible tinyint(1) NOT NULL DEFAULT 0,
 PRIMARY KEY(agent_key,target_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ilb_psoriasis_pharma_parameter (
 agent_key varchar(80) NOT NULL,
 parameter_code varchar(40) NOT NULL,
 parameter_role varchar(300) NOT NULL,
 required_flag tinyint(1) NOT NULL,
 parameter_value decimal(30,12) DEFAULT NULL,
 unit_ucum varchar(80) DEFAULT NULL,
 population_context varchar(500) DEFAULT NULL,
 source_url varchar(1000) DEFAULT NULL,
 evidence_status enum('MISSING','SOURCE_EXACT_REFERENCE','APPROVED_FOR_RESEARCH') NOT NULL DEFAULT 'MISSING',
 patient_value_flag tinyint(1) NOT NULL DEFAULT 0,
 PRIMARY KEY(agent_key,parameter_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ilb_psoriasis_persistence_state (
 state_key varchar(40) NOT NULL,
 symbol varchar(20) NOT NULL,
 state_name varchar(240) NOT NULL,
 state_equation text NOT NULL,
 biological_scope varchar(700) NOT NULL,
 ontology_identity_status enum('EXACT','PARTIAL','UNRESOLVED') NOT NULL,
 parameter_status enum('MISSING','PARTIAL','EXECUTABLE') NOT NULL,
 causal_status enum('CANDIDATE','SUPPORTED_ASSOCIATION','VALIDATED_CAUSAL') NOT NULL DEFAULT 'CANDIDATE',
 patient_use_allowed tinyint(1) NOT NULL DEFAULT 0,
 PRIMARY KEY(state_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ilb_psoriasis_virtual_experiment (
 experiment_key varchar(100) NOT NULL,
 experiment_order smallint unsigned NOT NULL,
 experiment_name varchar(300) NOT NULL,
 intervention_definition varchar(1200) NOT NULL,
 required_outputs varchar(1200) NOT NULL,
 pass_rule varchar(1800) NOT NULL,
 execution_status enum('DEFINED','INPUT_REQUIRED','EXECUTABLE','PASSED','FAILED') NOT NULL,
 patient_data_required tinyint(1) NOT NULL DEFAULT 0,
 PRIMARY KEY(experiment_key),
 UNIQUE KEY uq_p78_experiment_order(experiment_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ilb_psoriasis_release_gate (
 gate_code varchar(80) NOT NULL,
 gate_order smallint unsigned NOT NULL,
 gate_name varchar(300) NOT NULL,
 machine_requirement varchar(1800) NOT NULL,
 status enum('PASSED','OPEN','BLOCKED','NOT_APPLICABLE') NOT NULL,
 patient_execution_blocked tinyint(1) NOT NULL DEFAULT 1,
 evidence_note varchar(1800) NOT NULL,
 PRIMARY KEY(gate_code),
 UNIQUE KEY uq_p78_release_gate_order(gate_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO ilb_psoriasis_program VALUES
('PSORIASIS_E2E_V1','ILMB governed psoriasis in-silico research programme','Reproduce the published disease model, register pharmaceutical perturbations, test competing persistence hypotheses, and report evidence/readiness without recruiting a patient.','Must not diagnose, prescribe, select a patient treatment, claim cure, or convert population/reference parameters into patient values.','SHMAROV_2022_FULL','RESEARCH_OPERATIONAL')
ON DUPLICATE KEY UPDATE programme_name=VALUES(programme_name),declared_use=VALUES(declared_use),prohibited_use=VALUES(prohibited_use),model_key=VALUES(model_key),status=VALUES(status);

INSERT INTO ilb_psoriasis_formula_registry VALUES
('F_DISEASE_MASTER','PUBLISHED_DISEASE','dx/dt','S * v_published(x, theta_published)','Exact SBML reaction system retained as MathML in Phase 77.','SOURCE_EXACT','RESEARCH_ONLY','SHMAROV_2022_FULL',0),
('F_PK_DEPOT','PHARMACOKINETIC','dA_depot/dt','-ka*A_depot + Dose(t)','Subcutaneous absorption depot.','STANDARD_MODEL_STRUCTURE','PARAMETERS_REQUIRED',NULL,0),
('F_PK_CENTRAL','PHARMACOKINETIC','dC_c/dt','(ka*A_depot - CL*C_c - Q*(C_c-C_p))/V_c','Two-compartment central concentration.','STANDARD_MODEL_STRUCTURE','PARAMETERS_REQUIRED',NULL,0),
('F_PK_PERIPHERAL','PHARMACOKINETIC','dC_p/dt','Q*(C_c-C_p)/V_p','Two-compartment peripheral concentration.','STANDARD_MODEL_STRUCTURE','PARAMETERS_REQUIRED',NULL,0),
('F_BINDING','TARGET_ENGAGEMENT','dX_j/dt','kon_j*C_c*(L_total-X_j) - koff_j*X_j','Reversible drug-target complex formation.','STANDARD_MODEL_STRUCTURE','PARAMETERS_REQUIRED',NULL,0),
('F_FREE_TARGET','TARGET_ENGAGEMENT','L_free','L_total-X_j','Free target identity supplied to disease reactions.','DECISION_IDENTITY','PARAMETERS_REQUIRED',NULL,0),
('F_MEMORY_TRM','PERSISTENCE','dR/dt','f_R(IL23,P)-mu_R*R','Resident-memory inflammatory state candidate.','EVIDENCE_SUPPORTED_HYPOTHESIS','PARAMETERS_REQUIRED',NULL,0),
('F_MEMORY_KC','PERSISTENCE','dE/dt','f_E(IL17,TNF,P)-mu_E*E','Keratinocyte inflammatory-memory candidate.','EVIDENCE_SUPPORTED_HYPOTHESIS','PARAMETERS_REQUIRED',NULL,0),
('F_MEMORY_STROMA','PERSISTENCE','dF/dt','f_F(IL17,IL23,P)-mu_F*F','Fibroblast/stromal persistence candidate.','EVIDENCE_SUPPORTED_HYPOTHESIS','PARAMETERS_REQUIRED',NULL,0),
('F_MEMORY_TRIGGER','PERSISTENCE','dP/dt','S_persistent+f_P(E,F)-mu_P*P','Persistent local trigger candidate.','EVIDENCE_SUPPORTED_HYPOTHESIS','PARAMETERS_REQUIRED',NULL,0),
('F_OBSERVATION','OBSERVATION','y(t)','h(z(t))+epsilon(t)','Connect model state to declared aggregate observations.','STANDARD_MODEL_STRUCTURE','OBSERVATIONS_REQUIRED',NULL,0),
('F_FIT','DECISION','theta_hat_H','argmin_theta sum_s,o,t ((yhat_H-s,o,t-y_s,o,t)/sigma_s,o,t)^2','Fit a hypothesis only to sourced aggregate observations with reported uncertainty.','DECISION_IDENTITY','OBSERVATIONS_REQUIRED',NULL,0),
('F_FIM','DECISION','I(theta)','S(theta)^T*W*S(theta)','Identifiability diagnostic; rank deficiency blocks mechanistic selection.','DECISION_IDENTITY','OBSERVATIONS_REQUIRED',NULL,0),
('F_STABILITY','DECISION','stability(z*)','max_i Re(lambda_i(dF/dz at z*)) < 0','Local stability gate at a declared equilibrium.','DECISION_IDENTITY','PARAMETERS_REQUIRED',NULL,0),
('F_ROOT_RESET','DECISION','root_reset','Dose=0 AND C->0 AND X->0 AND z->z_healthy AND stability(z_healthy)','Post-washout reset definition; every conjunct must be measured or computed.','DECISION_IDENTITY','PARAMETERS_REQUIRED',NULL,0)
ON DUPLICATE KEY UPDATE layer=VALUES(layer),lhs=VALUES(lhs),rhs=VALUES(rhs),formula_role=VALUES(formula_role),provenance=VALUES(provenance),numerical_status=VALUES(numerical_status),source_key=VALUES(source_key),patient_use_allowed=VALUES(patient_use_allowed);

INSERT INTO ilb_psoriasis_pharma_agent
(agent_key,ingredient_name,molecule_class,administration_route,mechanism_class,identity_status,calculation_status) VALUES
('IXEKIZUMAB','ixekizumab','MONOCLONAL_ANTIBODY','SUBCUTANEOUS','IL17A ligand neutralisation','EXACT_APPROVED','PARAMETER_INCOMPLETE'),
('SECUKINUMAB','secukinumab','MONOCLONAL_ANTIBODY','SUBCUTANEOUS','IL17A ligand neutralisation','SOURCE_CONFIRMATION_REQUIRED','IDENTITY_ONLY'),
('BRODALUMAB','brodalumab','MONOCLONAL_ANTIBODY','SUBCUTANEOUS','IL17 receptor blockade','SOURCE_CONFIRMATION_REQUIRED','IDENTITY_ONLY'),
('BIMEKIZUMAB','bimekizumab','MONOCLONAL_ANTIBODY','SUBCUTANEOUS','IL17A and IL17F ligand neutralisation','SOURCE_CONFIRMATION_REQUIRED','IDENTITY_ONLY'),
('GUSELKUMAB','guselkumab','MONOCLONAL_ANTIBODY','SUBCUTANEOUS','IL23 p19 blockade','SOURCE_CONFIRMATION_REQUIRED','IDENTITY_ONLY'),
('RISANKIZUMAB','risankizumab','MONOCLONAL_ANTIBODY','SUBCUTANEOUS','IL23 p19 blockade','SOURCE_CONFIRMATION_REQUIRED','IDENTITY_ONLY'),
('TILDRAKIZUMAB','tildrakizumab','MONOCLONAL_ANTIBODY','SUBCUTANEOUS','IL23 p19 blockade','SOURCE_CONFIRMATION_REQUIRED','IDENTITY_ONLY'),
('USTEKINUMAB','ustekinumab','MONOCLONAL_ANTIBODY','SUBCUTANEOUS','IL12 and IL23 p40 blockade','SOURCE_CONFIRMATION_REQUIRED','IDENTITY_ONLY'),
('ADALIMUMAB','adalimumab','MONOCLONAL_ANTIBODY','SUBCUTANEOUS','TNF ligand neutralisation','SOURCE_CONFIRMATION_REQUIRED','IDENTITY_ONLY'),
('INFLIXIMAB','infliximab','MONOCLONAL_ANTIBODY','INTRAVENOUS','TNF ligand neutralisation','SOURCE_CONFIRMATION_REQUIRED','IDENTITY_ONLY'),
('ETANERCEPT','etanercept','FUSION_PROTEIN','SUBCUTANEOUS','TNF interception','SOURCE_CONFIRMATION_REQUIRED','IDENTITY_ONLY')
ON DUPLICATE KEY UPDATE ingredient_name=VALUES(ingredient_name),molecule_class=VALUES(molecule_class),administration_route=VALUES(administration_route),mechanism_class=VALUES(mechanism_class),identity_status=VALUES(identity_status),calculation_status=VALUES(calculation_status);

INSERT INTO ilb_psoriasis_pharma_identifier VALUES
('IXEKIZUMAB','RXNORM','1745099','EXACT','APPROVED',1,'https://rxnav.nlm.nih.gov/REST/rxcui/1745099/allProperties.json')
ON DUPLICATE KEY UPDATE match_type=VALUES(match_type),approval_status=VALUES(approval_status),computation_eligible=VALUES(computation_eligible),evidence_url=VALUES(evidence_url);

INSERT INTO ilb_psoriasis_pharma_target VALUES
('IXEKIZUMAB','IL17A','NEUTRALISE_LIGAND','IL17A_free','STRUCTURAL_EXACT',1),
('SECUKINUMAB','IL17A','NEUTRALISE_LIGAND','IL17A_free','EXTERNAL_ID_REQUIRED',0),
('BRODALUMAB','IL17_RECEPTOR','BLOCK_RECEPTOR','IL17_signalling_available','EXTERNAL_ID_REQUIRED',0),
('BIMEKIZUMAB','IL17A_IL17F','NEUTRALISE_LIGAND','IL17A_free_and_IL17F_free','EXTERNAL_ID_REQUIRED',0),
('GUSELKUMAB','IL23_P19','NEUTRALISE_LIGAND','IL23_effective','EXTERNAL_ID_REQUIRED',0),
('RISANKIZUMAB','IL23_P19','NEUTRALISE_LIGAND','IL23_effective','EXTERNAL_ID_REQUIRED',0),
('TILDRAKIZUMAB','IL23_P19','NEUTRALISE_LIGAND','IL23_effective','EXTERNAL_ID_REQUIRED',0),
('USTEKINUMAB','IL12_IL23_P40','NEUTRALISE_LIGAND','IL23_effective','EXTERNAL_ID_REQUIRED',0),
('ADALIMUMAB','TNF','NEUTRALISE_LIGAND','TNF_free','EXTERNAL_ID_REQUIRED',0),
('INFLIXIMAB','TNF','NEUTRALISE_LIGAND','TNF_free','EXTERNAL_ID_REQUIRED',0),
('ETANERCEPT','TNF','INTERCEPT_LIGAND','TNF_signalling_available','EXTERNAL_ID_REQUIRED',0)
ON DUPLICATE KEY UPDATE intervention_operator=VALUES(intervention_operator),model_quantity=VALUES(model_quantity),mapping_status=VALUES(mapping_status),computation_eligible=VALUES(computation_eligible);

INSERT INTO ilb_psoriasis_pharma_parameter
(agent_key,parameter_code,parameter_role,required_flag)
SELECT a.agent_key,p.parameter_code,p.parameter_role,
 CASE WHEN a.administration_route='INTRAVENOUS' AND p.parameter_code='ka' THEN 0 ELSE 1 END
FROM ilb_psoriasis_pharma_agent a
CROSS JOIN (
 SELECT 'CL' parameter_code,'clearance' parameter_role UNION ALL
 SELECT 'ka','absorption rate' UNION ALL SELECT 'Q','intercompartmental clearance' UNION ALL
 SELECT 'V_c','central volume' UNION ALL SELECT 'V_p','peripheral volume' UNION ALL
 SELECT 'kon','association rate' UNION ALL SELECT 'koff','dissociation rate' UNION ALL
 SELECT 'L_total','declared target abundance or concentration'
) p
ON DUPLICATE KEY UPDATE parameter_role=VALUES(parameter_role),required_flag=VALUES(required_flag);

INSERT INTO ilb_psoriasis_persistence_state VALUES
('TRM17','R','Cutaneous resident-memory IL17-capable immune state','dR/dt=f_R(IL23,P)-mu_R*R','Candidate local cellular reservoir capable of restarting the IL23/IL17 inflammatory circuit.','PARTIAL','MISSING','SUPPORTED_ASSOCIATION',0),
('KC_EPIGENETIC','E','Keratinocyte inflammatory epigenetic-memory state','dE/dt=f_E(IL17,TNF,P)-mu_E*E','Candidate durable keratinocyte transcriptional or epigenetic programme after visible resolution.','PARTIAL','MISSING','SUPPORTED_ASSOCIATION',0),
('STROMAL','F','Fibroblast and stromal persistence state','dF/dt=f_F(IL17,IL23,P)-mu_F*F','Candidate pathogenic stromal state maintaining local inflammatory susceptibility.','UNRESOLVED','MISSING','CANDIDATE',0),
('LOCAL_TRIGGER','P','Persistent local trigger state','dP/dt=S_persistent+f_P(E,F)-mu_P*P','Unresolved local antigenic, microbial, barrier, neural or damage-associated driver; alternatives must remain separate until identified.','UNRESOLVED','MISSING','CANDIDATE',0)
ON DUPLICATE KEY UPDATE symbol=VALUES(symbol),state_name=VALUES(state_name),state_equation=VALUES(state_equation),biological_scope=VALUES(biological_scope),ontology_identity_status=VALUES(ontology_identity_status),parameter_status=VALUES(parameter_status),causal_status=VALUES(causal_status),patient_use_allowed=VALUES(patient_use_allowed);

INSERT INTO ilb_psoriasis_virtual_experiment VALUES
('E01_SOURCE_REPRODUCTION',1,'Published source reproduction','Run the unmodified source SBML with its declared initial conditions and parameter set.','All source species, declared assignments and PASI proxy.','Report raw trajectory differences against source outputs; no invented tolerance.','DEFINED',0),
('E02_IL17_KNOCKOUT',2,'IL17 pathway knockout','Set effective IL17 signalling input to zero within the declared intervention interval.','SC,TA,D,T,DC,IL23,IL17,TNF,PASI.','Return the full trajectory and equilibrium; no efficacy claim.','INPUT_REQUIRED',0),
('E03_IL23_KNOCKOUT',3,'IL23 pathway knockout','Set effective IL23 signalling input to zero within the declared intervention interval.','SC,TA,D,T,DC,IL23,IL17,TNF,PASI.','Return the full trajectory and equilibrium; no efficacy claim.','INPUT_REQUIRED',0),
('E04_TNF_KNOCKOUT',4,'TNF pathway knockout','Set effective TNF signalling input to zero within the declared intervention interval.','SC,TA,D,T,DC,IL23,IL17,TNF,PASI.','Return the full trajectory and equilibrium; no efficacy claim.','INPUT_REQUIRED',0),
('E05_CLASS_COMPARISON',5,'Pharmaceutical class comparison','Apply source-exact PK and target engagement independently for IL17, IL23 and TNF classes.','Concentration, occupancy, free target and all disease states.','Only agents with complete approved parameters may run.','INPUT_REQUIRED',0),
('E06_WASHOUT',6,'Complete drug washout','Set Dose(t)=0 after suppression and integrate until drug and complex clearance are demonstrated.','C_c,C_p,X_j and all disease/persistence states.','Do not evaluate reset until C and X approach their numerically declared integration tolerance.','INPUT_REQUIRED',0),
('E07_PERSISTENCE_ABLATION',7,'Persistence-state ablation','Ablate R,E,F,P one at a time and in preregistered combinations after washout.','Post-washout equilibrium, relapse attractor and sensitivity matrix.','A candidate advances only if its removal changes the post-washout attractor robustly.','INPUT_REQUIRED',0),
('E08_IDENTIFIABILITY',8,'Structural and practical identifiability','Compute sensitivity matrix and Fisher information for each fitted hypothesis.','Rank, singular values, parameter profiles and uncertainty.','Rank-deficient mechanisms must be reported as not identifiable.','INPUT_REQUIRED',0),
('E09_HOLDOUT_VALIDATION',9,'Independent-study validation','Evaluate against aggregate studies excluded from fitting.','Predicted and observed trajectories with source-reported uncertainty.','Report error and coverage from the held-out evidence; do not invent an acceptance threshold.','INPUT_REQUIRED',0),
('E10_STABILITY_ROBUSTNESS',10,'Post-washout stability and robustness','Calculate Jacobian eigenvalues at declared equilibria over the source-supported parameter set.','Eigenvalues, equilibrium identity and parameter-set provenance.','Healthy local stability requires max real eigenvalue below zero for every claimed supported parameter set.','INPUT_REQUIRED',0)
ON DUPLICATE KEY UPDATE experiment_order=VALUES(experiment_order),experiment_name=VALUES(experiment_name),intervention_definition=VALUES(intervention_definition),required_outputs=VALUES(required_outputs),pass_rule=VALUES(pass_rule),execution_status=VALUES(execution_status),patient_data_required=VALUES(patient_data_required);

INSERT INTO ilb_psoriasis_release_gate VALUES
('G01_SOURCE_ARTIFACT',1,'Published model artifact exact','Phase 77 source digest and structural counts must match.','PASSED',1,'Production has exact SHA-256 and 25 species, 62 parameters, 35 reactions, 72 participants.'),
('G02_FORMULA_REGISTRY',2,'Complete formula registry','Every disease, PK, target, persistence, observation and decision layer must be registered.','PASSED',1,'Phase 78 registers the complete calculation topology without supplying missing coefficients.'),
('G03_PHARMA_IDENTITIES',3,'Pharmaceutical identities','Every registered agent must have an exact approved external ingredient identity.','OPEN',1,'Ixekizumab is exact; remaining agents require governed RxNorm resolution.'),
('G04_PK_BINDING',4,'PK and binding parameters','Every required parameter must have value, UCUM unit, population context and exact source.','BLOCKED',1,'No missing value may be imputed or treated as a patient value.'),
('G05_TARGET_CROSSWALK',5,'Target crosswalk','Every drug target must have an exact approved molecular identity and executable model-state mapping.','OPEN',1,'Only the existing exact IL17A/ixekizumab connection is currently eligible.'),
('G06_PERSISTENCE_PARAMETERS',6,'Persistence-state parameterisation','R,E,F,P identities, observation functions and parameters must be source-supported and identifiable.','BLOCKED',1,'Hypotheses are registered but coefficients are intentionally absent.'),
('G07_AGGREGATE_EVIDENCE',7,'Aggregate longitudinal evidence','Training and holdout datasets must store outcome, time, uncertainty, population context and source.','BLOCKED',1,'No patient recruitment is required; source-exact aggregate evidence is required.'),
('G08_IDENTIFIABILITY',8,'Mechanism identifiability','Sensitivity/Fisher-information analysis must distinguish the claimed mechanism.','BLOCKED',1,'No root mechanism may be selected while parameter effects are non-identifiable.'),
('G09_WASHOUT_RESET',9,'Drug-free reset','Root reset must persist after Dose=0, C=0 and target complex=0.','BLOCKED',1,'Symptom suppression during pharmacological exposure is insufficient.'),
('G10_EXTERNAL_VALIDATION',10,'Independent validation','Predictions must be evaluated against unused evidence and an external non-human experimental system.','BLOCKED',1,'In-silico results alone cannot establish biological causality.'),
('G11_CLINICAL_RELEASE',11,'Clinical release','Declared-use clinical validation, safety and accountable human review must pass.','BLOCKED',1,'Autonomous diagnosis or prescribing remains disabled.')
ON DUPLICATE KEY UPDATE gate_order=VALUES(gate_order),gate_name=VALUES(gate_name),machine_requirement=VALUES(machine_requirement),status=VALUES(status),patient_execution_blocked=VALUES(patient_execution_blocked),evidence_note=VALUES(evidence_note);

CREATE OR REPLACE VIEW v_ilmb_psoriasis_agent_readiness AS
SELECT a.agent_key,a.ingredient_name,a.identity_status,a.calculation_status,
 COUNT(p.parameter_code) parameter_slots,
 SUM(CASE WHEN p.required_flag=1 THEN 1 ELSE 0 END) required_parameters,
 SUM(CASE WHEN p.required_flag=1 AND (p.parameter_value IS NULL OR p.unit_ucum IS NULL OR p.source_url IS NULL OR p.evidence_status<>'APPROVED_FOR_RESEARCH') THEN 1 ELSE 0 END) missing_or_unapproved_parameters,
 MAX(CASE WHEN t.computation_eligible=1 THEN 1 ELSE 0 END) executable_target_mapping,
 CASE WHEN a.identity_status='EXACT_APPROVED'
   AND SUM(CASE WHEN p.required_flag=1 AND (p.parameter_value IS NULL OR p.unit_ucum IS NULL OR p.source_url IS NULL OR p.evidence_status<>'APPROVED_FOR_RESEARCH') THEN 1 ELSE 0 END)=0
   AND MAX(CASE WHEN t.computation_eligible=1 THEN 1 ELSE 0 END)=1
 THEN 1 ELSE 0 END research_execution_enabled
FROM ilb_psoriasis_pharma_agent a
LEFT JOIN ilb_psoriasis_pharma_parameter p ON p.agent_key=a.agent_key
LEFT JOIN ilb_psoriasis_pharma_target t ON t.agent_key=a.agent_key
GROUP BY a.agent_key,a.ingredient_name,a.identity_status,a.calculation_status;

CREATE OR REPLACE VIEW v_ilmb_psoriasis_end_to_end_readiness AS
SELECT p.program_key,p.status,
 (SELECT COUNT(*) FROM ilb_psoriasis_formula_registry) formula_count,
 (SELECT COUNT(*) FROM ilb_psoriasis_pharma_agent) pharma_agent_count,
 (SELECT COUNT(*) FROM ilb_psoriasis_persistence_state) persistence_state_count,
 (SELECT COUNT(*) FROM ilb_psoriasis_virtual_experiment) experiment_count,
 (SELECT COUNT(*) FROM ilb_psoriasis_release_gate WHERE status='PASSED') passed_gates,
 (SELECT COUNT(*) FROM ilb_psoriasis_release_gate WHERE status IN ('OPEN','BLOCKED')) open_or_blocked_gates,
 (SELECT COUNT(*) FROM v_ilmb_psoriasis_agent_readiness WHERE research_execution_enabled=1) executable_pharma_agents,
 1 research_structure_operational,
 CASE WHEN NOT EXISTS (SELECT 1 FROM ilb_psoriasis_release_gate WHERE status<>'PASSED') THEN 1 ELSE 0 END validated_declared_use_enabled,
 CASE WHEN NOT EXISTS (SELECT 1 FROM ilb_psoriasis_release_gate WHERE patient_execution_blocked=1) THEN 1 ELSE 0 END patient_execution_enabled
FROM ilb_psoriasis_program p;

COMMIT;
