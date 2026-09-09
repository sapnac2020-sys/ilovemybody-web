-- Phase 108: Psoriasis Governing Equations + Coefficient Governance
-- Purpose: formalize the 9-state psoriasis ODE system without inventing coefficients.
-- Numeric values are admitted only when directly reported in a source and remain context-labelled.
-- Unknown patient/model coefficients are NULL and must be estimated from measurements or sourced experiments.

CREATE TABLE IF NOT EXISTS ilb_psoriasis_equation (
  equation_id VARCHAR(64) PRIMARY KEY,
  equation_code VARCHAR(32) NOT NULL UNIQUE,
  state_variable VARCHAR(32) NOT NULL,
  state_name VARCHAR(128) NOT NULL,
  equation_text TEXT NOT NULL,
  biological_interpretation TEXT NOT NULL,
  model_status VARCHAR(32) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_psoriasis_parameter (
  parameter_id VARCHAR(64) PRIMARY KEY,
  parameter_symbol VARCHAR(64) NOT NULL UNIQUE,
  parameter_name VARCHAR(160) NOT NULL,
  equation_code VARCHAR(32) NOT NULL,
  parameter_role VARCHAR(64) NOT NULL,
  value_numeric DECIMAL(24,10) NULL,
  unit VARCHAR(64) NULL,
  value_status VARCHAR(32) NOT NULL,
  evidence_status VARCHAR(32) NOT NULL,
  estimation_scope VARCHAR(64) NOT NULL,
  context_note TEXT NOT NULL,
  source_id VARCHAR(64) NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_psoriasis_kinetic_observation (
  observation_id VARCHAR(64) PRIMARY KEY,
  metric_code VARCHAR(64) NOT NULL,
  metric_name VARCHAR(160) NOT NULL,
  population_context VARCHAR(160) NOT NULL,
  value_numeric DECIMAL(24,10) NOT NULL,
  unit VARCHAR(64) NOT NULL,
  observation_status VARCHAR(32) NOT NULL,
  model_use_status VARCHAR(32) NOT NULL,
  source_id VARCHAR(64) NOT NULL,
  context_note TEXT NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_psoriasis_equation_measurement (
  mapping_id VARCHAR(64) PRIMARY KEY,
  equation_code VARCHAR(32) NOT NULL,
  variable_or_parameter VARCHAR(64) NOT NULL,
  measurement_name VARCHAR(160) NOT NULL,
  measurement_class VARCHAR(64) NOT NULL,
  unit_or_scale VARCHAR(64) NULL,
  availability_status VARCHAR(32) NOT NULL,
  use_role VARCHAR(64) NOT NULL,
  measurement_note TEXT NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_psoriasis_math_source (
  source_id VARCHAR(64) PRIMARY KEY,
  citation_text TEXT NOT NULL,
  source_url TEXT NOT NULL,
  source_type VARCHAR(32) NOT NULL,
  evidence_scope TEXT NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO ilb_psoriasis_math_source
(source_id,citation_text,source_url,source_type,evidence_scope)
VALUES
('PSO-MATH-S001','Weinstein GD, McCullough JL, Ross P. Cell kinetic basis for pathophysiology of psoriasis. J Invest Dermatol. 1985;85(6):579-583. PMID 4067329.','https://pubmed.ncbi.nlm.nih.gov/4067329/','PRIMARY','Historical in-vivo psoriatic epidermal cell-cycle kinetics; reports psoriatic Tc about 36 h.'),
('PSO-MATH-S002','Weinstein et al. Cell proliferation in normal epidermis. PMID 6725985.','https://pubmed.ncbi.nlm.nih.gov/6725985/','PRIMARY','Historical normal epidermal kinetic model; reports whole-epidermis turnover about 39 d and model Tc about 311 h; definitions are not interchangeable with later cycling-pool studies.'),
('PSO-MATH-S003','Cell cycle kinetics in normal human skin by in vivo iododeoxyuridine. PMID 8844104.','https://pubmed.ncbi.nlm.nih.gov/8844104/','PRIMARY','Normal epidermal cycling-pool kinetics; reports calculated cycling-cell Tc about 28.4 h and S phase 9.7 h; not a whole-epidermis turnover constant.'),
('PSO-MATH-S004','Cell kinetic characterization of cultured human keratinocytes from normal and psoriatic individuals. PMID 8816923.','https://pubmed.ncbi.nlm.nih.gov/8816923/','PRIMARY','Cultured-cell study found no gross overall Tc difference in its model, demonstrating context dependence of kinetic constants.'),
('PSO-MATH-S005','Cytokine Modulators in Plaque Psoriasis - review of IL-23/IL-17 biology.','https://pmc.ncbi.nlm.nih.gov/articles/PMC9558046/','REVIEW','Supports IL-23 -> IL-17 and IL-17 -> keratinocyte proliferation/pro-inflammatory feedback structure; does not provide universal patient ODE coefficients.'),
('PSO-MATH-S006','Cellular Mechanisms of Psoriasis Pathogenesis: A Systemic Review.','https://pmc.ncbi.nlm.nih.gov/articles/PMC10506593/','REVIEW','Supports positive feedback between immune cells and keratinocytes and abnormal proliferation/differentiation.'),
('PSO-MATH-S007','Interleukin-17A and Keratinocytes in Psoriasis. PMID 32070069.','https://pubmed.ncbi.nlm.nih.gov/32070069/','REVIEW','Supports IL-17A driven keratinocyte proliferation and chemokine-mediated feed-forward recruitment.')
ON DUPLICATE KEY UPDATE citation_text=VALUES(citation_text),source_url=VALUES(source_url),evidence_scope=VALUES(evidence_scope);

INSERT INTO ilb_psoriasis_equation
(equation_id,equation_code,state_variable,state_name,equation_text,biological_interpretation,model_status)
VALUES
('PSO-EQ-001','EQ_G','G','Genetic susceptibility','dG/dt = 0','Inherited susceptibility is treated as fixed over the clinical time horizon; it changes response gain/thresholds rather than constituting plaque itself.','STRUCTURE_SUPPORTED'),
('PSO-EQ-002','EQ_D','D','Dendritic/innate activation','dD/dt = A_D(G)*F_U(U) + eta_K*F_K(K) - delta_D*D','External/internal inputs and keratinocyte feedback activate innate/dendritic signalling; resolution removes activation.','STRUCTURE_SUPPORTED'),
('PSO-EQ-003','EQ_H','H','Effective IL-23 signalling','dH/dt = alpha_H*D - delta_H*H','Activated dendritic/myeloid signalling drives IL-23; turnover/resolution removes effective signal.','STRUCTURE_SUPPORTED'),
('PSO-EQ-004','EQ_T','T','Pathogenic type-17 activity','dT/dt = alpha_T*H/(K_H + H) - delta_T*T','IL-23 sustains type-17 activity with a saturable response; deactivation/loss opposes it.','MODEL_FORM_HYPOTHESIS'),
('PSO-EQ-005','EQ_L','L','Effective IL-17A/F signalling','dL/dt = alpha_L*T - delta_L*L','Type-17 cells generate effective IL-17 signalling; clearance/receptor disengagement reduces it.','STRUCTURE_SUPPORTED'),
('PSO-EQ-006','EQ_K','K','Abnormal keratinocyte activation/proliferation','dK/dt = alpha_K*F_L(L) + alpha_KN*F_LN(L,N) - rho_K*K','IL-17 and interacting inflammatory signals promote keratinocyte activation/proliferation; normalization opposes it.','MODEL_FORM_HYPOTHESIS'),
('PSO-EQ-007','EQ_Q','Q','Abnormal keratinocyte differentiation','dQ/dt = alpha_Q*L + beta_Q*K - rho_Q*Q','Inflammation and hyperactivation promote abnormal differentiation; recovery drives Q toward zero.','MODEL_FORM_HYPOTHESIS'),
('PSO-EQ-008','EQ_B','B','Barrier dysfunction','dB/dt = alpha_B*K + beta_B*Q - rho_B*R_B*B','Hyperactivation and abnormal differentiation worsen barrier dysfunction; barrier-repair capacity promotes recovery.','MODEL_FORM_HYPOTHESIS'),
('PSO-EQ-009','EQ_P','P','Observable plaque burden','dP/dt = alpha_P*K + beta_P*Q + gamma_P*B - delta_P*P','Plaque burden is downstream of proliferation, differentiation and barrier pathology and resolves when recovery exceeds formation.','MODEL_FORM_HYPOTHESIS')
ON DUPLICATE KEY UPDATE equation_text=VALUES(equation_text),biological_interpretation=VALUES(biological_interpretation),model_status=VALUES(model_status);

-- Governing coefficients: deliberately NULL until directly sourced for the same biological compartment/model
-- or estimated from a patient's longitudinal measurements. No population value is silently converted into a patient coefficient.
INSERT INTO ilb_psoriasis_parameter
(parameter_id,parameter_symbol,parameter_name,equation_code,parameter_role,value_numeric,unit,value_status,evidence_status,estimation_scope,context_note,source_id)
VALUES
('PSO-PAR-001','A_D_G','Genotype-dependent innate activation gain','EQ_D','GAIN',NULL,NULL,'UNKNOWN','MECHANISM_SUPPORTED','PATIENT_OR_EXPERIMENT','Functional form exists; no universal human psoriasis coefficient established.','PSO-MATH-S006'),
('PSO-PAR-002','eta_K','Keratinocyte-to-immune feedback gain','EQ_D','GAIN',NULL,NULL,'UNKNOWN','MECHANISM_SUPPORTED','PATIENT_OR_EXPERIMENT','Positive feedback is established biologically; numeric gain is not universal.','PSO-MATH-S006'),
('PSO-PAR-003','delta_D','Innate/dendritic resolution rate','EQ_D','DECAY_RATE',NULL,'1/time','UNKNOWN','UNSOURCED_NUMERIC','PATIENT_OR_EXPERIMENT','Requires compartment-specific longitudinal data.','PSO-MATH-S006'),
('PSO-PAR-004','alpha_H','IL-23 production/effective signalling gain','EQ_H','GAIN',NULL,NULL,'UNKNOWN','MECHANISM_SUPPORTED','PATIENT_OR_EXPERIMENT','Direction supported; no validated universal ODE coefficient.','PSO-MATH-S005'),
('PSO-PAR-005','delta_H','Effective IL-23 decay/resolution rate','EQ_H','DECAY_RATE',NULL,'1/time','UNKNOWN','UNSOURCED_NUMERIC','PATIENT_OR_EXPERIMENT','Do not substitute serum cytokine half-life for lesional effective signalling without validation.','PSO-MATH-S005'),
('PSO-PAR-006','alpha_T','IL-23 to type-17 maximum activation gain','EQ_T','GAIN',NULL,NULL,'UNKNOWN','MECHANISM_SUPPORTED','PATIENT_OR_EXPERIMENT','Saturating model form is a modelling choice; coefficient must be estimated.','PSO-MATH-S005'),
('PSO-PAR-007','K_H','IL-23 half-saturation constant','EQ_T','HALF_SATURATION',NULL,'concentration_or_signal','UNKNOWN','MODEL_HYPOTHESIS','EXPERIMENT','No universal clinical psoriasis value identified.','PSO-MATH-S005'),
('PSO-PAR-008','delta_T','Type-17 deactivation/loss rate','EQ_T','DECAY_RATE',NULL,'1/time','UNKNOWN','UNSOURCED_NUMERIC','PATIENT_OR_EXPERIMENT','Requires cell-state kinetics.','PSO-MATH-S005'),
('PSO-PAR-009','alpha_L','Type-17 to effective IL-17 signalling gain','EQ_L','GAIN',NULL,NULL,'UNKNOWN','MECHANISM_SUPPORTED','PATIENT_OR_EXPERIMENT','Production direction supported; numeric mapping not universal.','PSO-MATH-S007'),
('PSO-PAR-010','delta_L','Effective IL-17 signalling decay rate','EQ_L','DECAY_RATE',NULL,'1/time','UNKNOWN','UNSOURCED_NUMERIC','PATIENT_OR_EXPERIMENT','Tissue signalling lifetime cannot be replaced by a generic plasma half-life.','PSO-MATH-S007'),
('PSO-PAR-011','alpha_K','IL-17 to keratinocyte activation gain','EQ_K','GAIN',NULL,NULL,'UNKNOWN','MECHANISM_SUPPORTED','PATIENT_OR_EXPERIMENT','IL-17 accelerates keratinocyte activation/proliferation; numeric gain remains unknown.','PSO-MATH-S007'),
('PSO-PAR-012','alpha_KN','IL-17 interaction/synergy gain','EQ_K','GAIN',NULL,NULL,'UNKNOWN','MECHANISM_SUPPORTED','PATIENT_OR_EXPERIMENT','Synergy exists with inflammatory partners; coefficient is context-specific.','PSO-MATH-S005'),
('PSO-PAR-013','rho_K','Keratinocyte normalization/removal rate','EQ_K','RECOVERY_RATE',NULL,'1/time','UNKNOWN','PARTIAL_KINETIC_EVIDENCE','PATIENT_OR_EXPERIMENT','Historical cell-cycle observations constrain scale but do not identify this ODE parameter directly.','PSO-MATH-S001'),
('PSO-PAR-014','alpha_Q','Inflammatory drive to abnormal differentiation','EQ_Q','GAIN',NULL,NULL,'UNKNOWN','MECHANISM_SUPPORTED','PATIENT_OR_EXPERIMENT','Abnormal differentiation is supported; numeric mapping unknown.','PSO-MATH-S006'),
('PSO-PAR-015','beta_Q','Keratinocyte activation to abnormal differentiation gain','EQ_Q','GAIN',NULL,NULL,'UNKNOWN','MODEL_HYPOTHESIS','PATIENT_OR_EXPERIMENT','Requires biomarker-linked longitudinal data.','PSO-MATH-S006'),
('PSO-PAR-016','rho_Q','Differentiation recovery rate','EQ_Q','RECOVERY_RATE',NULL,'1/time','UNKNOWN','UNSOURCED_NUMERIC','PATIENT_OR_EXPERIMENT','Must be estimated from differentiation markers or histology over time.',NULL),
('PSO-PAR-017','alpha_B','Keratinocyte activation to barrier dysfunction gain','EQ_B','GAIN',NULL,NULL,'UNKNOWN','MECHANISM_SUPPORTED','PATIENT_OR_EXPERIMENT','Numeric gain unknown.','PSO-MATH-S006'),
('PSO-PAR-018','beta_B','Abnormal differentiation to barrier dysfunction gain','EQ_B','GAIN',NULL,NULL,'UNKNOWN','MECHANISM_SUPPORTED','PATIENT_OR_EXPERIMENT','Numeric gain unknown.','PSO-MATH-S006'),
('PSO-PAR-019','rho_B','Barrier recovery coefficient','EQ_B','RECOVERY_RATE',NULL,'1/time','UNKNOWN','UNSOURCED_NUMERIC','PATIENT','Estimate from repeated barrier measurements under controlled care.',NULL),
('PSO-PAR-020','alpha_P','Keratinocyte contribution to plaque formation','EQ_P','GAIN',NULL,NULL,'UNKNOWN','MODEL_HYPOTHESIS','PATIENT','Fit to repeated plaque measurements.',NULL),
('PSO-PAR-021','beta_P','Differentiation contribution to plaque formation','EQ_P','GAIN',NULL,NULL,'UNKNOWN','MODEL_HYPOTHESIS','PATIENT','Fit to repeated plaque measurements.',NULL),
('PSO-PAR-022','gamma_P','Barrier contribution to plaque burden','EQ_P','GAIN',NULL,NULL,'UNKNOWN','MODEL_HYPOTHESIS','PATIENT','Fit to repeated plaque measurements.',NULL),
('PSO-PAR-023','delta_P','Clinical plaque resolution rate','EQ_P','RECOVERY_RATE',NULL,'1/time','UNKNOWN','PATIENT_ESTIMABLE','PATIENT','Can be fitted from serial standardized lesion measurements when inputs are recorded.',NULL)
ON DUPLICATE KEY UPDATE parameter_name=VALUES(parameter_name),value_numeric=VALUES(value_numeric),value_status=VALUES(value_status),evidence_status=VALUES(evidence_status),context_note=VALUES(context_note),source_id=VALUES(source_id);

-- Literature observations are constraints/context only, NOT automatic ODE coefficients.
INSERT INTO ilb_psoriasis_kinetic_observation
(observation_id,metric_code,metric_name,population_context,value_numeric,unit,observation_status,model_use_status,source_id,context_note)
VALUES
('PSO-KIN-001','PSO_TC_HIST','Psoriatic epidermal cell cycle duration','Human psoriatic epidermis; historical in-vivo FLM study',36.0,'h','REPORTED','CONTEXT_ONLY','PSO-MATH-S001','Historical Tc estimate. Do not assign directly to rho_K; later experimental models report different kinetic relationships.'),
('PSO-KIN-002','NORMAL_TC_HIST','Normal epidermal cell cycle duration','Historical normal epidermal kinetic model',311.0,'h','REPORTED','CONTEXT_ONLY','PSO-MATH-S002','Model-derived normal Tc in historical whole-tissue framework; not interchangeable with cycling-pool Tc.'),
('PSO-KIN-003','NORMAL_TURNOVER_HIST','Whole epidermal turnover time','Normal epidermis; historical kinetic model',39.0,'d','REPORTED','CONTEXT_ONLY','PSO-MATH-S002','Whole-tissue turnover time, not cell-cycle duration.'),
('PSO-KIN-004','NORMAL_TC_CYCLING_POOL','Cycling epidermal cell cycle duration','Normal human epidermis; in-vivo IdUrd cycling-cell analysis',28.4,'h','REPORTED','CONTEXT_ONLY','PSO-MATH-S003','Calculated cycling-pool Tc; different denominator/compartment from historical whole-tissue model.'),
('PSO-KIN-005','NORMAL_S_PHASE','S-phase duration','Normal human epidermis; in-vivo IdUrd cycling-cell analysis',9.7,'h','REPORTED','CONTEXT_ONLY','PSO-MATH-S003','Measured S-phase duration with reported uncertainty in source; not a psoriasis-specific coefficient.')
ON DUPLICATE KEY UPDATE value_numeric=VALUES(value_numeric),unit=VALUES(unit),model_use_status=VALUES(model_use_status),context_note=VALUES(context_note);

INSERT INTO ilb_psoriasis_equation_measurement
(mapping_id,equation_code,variable_or_parameter,measurement_name,measurement_class,unit_or_scale,availability_status,use_role,measurement_note)
VALUES
('PSO-MEAS-001','EQ_G','G','Genotype / psoriasis susceptibility variants','GENETIC','variant calls / PRS','OPTIONAL','BOUNDARY_CONDITION','Useful for susceptibility research; not required to establish active plaque state.'),
('PSO-MEAS-002','EQ_D','D','Lesional innate/dendritic activation panel','TISSUE_BIOMARKER','cell count / marker panel','RESEARCH','STATE_OBSERVATION','Requires biopsy or validated tissue assay; not a routine proxy from symptoms.'),
('PSO-MEAS-003','EQ_H','H','Lesional IL-23 pathway measurement','TISSUE_BIOMARKER','assay-specific','RESEARCH','STATE_OBSERVATION','Prefer lesional/tissue signalling measures over serum substitution.'),
('PSO-MEAS-004','EQ_T','T','Lesional Th17/Tc17 activity','CELLULAR_BIOMARKER','cell count / activation markers','RESEARCH','STATE_OBSERVATION','Requires cellular phenotyping.'),
('PSO-MEAS-005','EQ_L','L','Lesional IL-17A/F signalling','TISSUE_BIOMARKER','assay-specific','RESEARCH','STATE_OBSERVATION','Do not infer exact IL-17 state from PASI alone.'),
('PSO-MEAS-006','EQ_K','K','Keratinocyte proliferation index','HISTOLOGY','Ki-67 or validated proliferation metric','RESEARCH','STATE_OBSERVATION','Serial biopsy is research-grade; clinical plaque thickness can be a downstream proxy only.'),
('PSO-MEAS-007','EQ_Q','Q','Keratinocyte differentiation panel','HISTOLOGY','K10/involucrin/filaggrin or validated panel','RESEARCH','STATE_OBSERVATION','Marker selection must be protocol-defined before fitting.'),
('PSO-MEAS-008','EQ_B','B','Transepidermal water loss','BARRIER','g/m2/h','AVAILABLE','STATE_OBSERVATION','Useful direct barrier-function measurement when standardized.'),
('PSO-MEAS-009','EQ_B','B','Stratum corneum hydration','BARRIER','device-specific','AVAILABLE','STATE_OBSERVATION','Use same calibrated device and site longitudinally.'),
('PSO-MEAS-010','EQ_P','P','PASI','CLINICAL','0-72','AVAILABLE','OUTCOME','Whole-patient severity outcome; not a molecular state variable.'),
('PSO-MEAS-011','EQ_P','P','BSA affected','CLINICAL','percent','AVAILABLE','OUTCOME','Extent measurement.'),
('PSO-MEAS-012','EQ_P','P','Target plaque thickness/scaling/erythema','CLINICAL','standardized ordinal or instrumented','AVAILABLE','LONGITUDINAL_FIT','Prefer one fixed target lesion plus standardized photography for parameter fitting.'),
('PSO-MEAS-013','EQ_P','delta_P','Serial target-plaque trajectory','DERIVED','change/time','AVAILABLE','PARAMETER_ESTIMATION','Estimate only after repeated standardized observations with intervention timing logged.'),
('PSO-MEAS-014','EQ_D','U','Trigger/input timeline','EXPOSURE','timestamped categorical/quantitative','AVAILABLE','INPUT','Records infection, skin injury, stress, medication changes, smoking/alcohol and other predeclared inputs without assigning unsupported weights.'),
('PSO-MEAS-015','EQ_B','R_B','Barrier-care exposure/adherence','INTERVENTION','dose/frequency','AVAILABLE','CONTROL_INPUT','Needed to estimate barrier recovery rather than attributing spontaneous change to treatment.')
ON DUPLICATE KEY UPDATE measurement_name=VALUES(measurement_name),availability_status=VALUES(availability_status),use_role=VALUES(use_role),measurement_note=VALUES(measurement_note);

CREATE OR REPLACE VIEW v_ilb_psoriasis_math_readiness AS
SELECT
  (SELECT COUNT(*) FROM ilb_psoriasis_equation) AS equation_count,
  (SELECT COUNT(*) FROM ilb_psoriasis_parameter) AS parameter_count,
  (SELECT COUNT(*) FROM ilb_psoriasis_parameter WHERE value_numeric IS NULL AND value_status='UNKNOWN') AS unknown_parameter_count,
  (SELECT COUNT(*) FROM ilb_psoriasis_parameter WHERE value_numeric IS NOT NULL) AS numeric_parameter_count,
  (SELECT COUNT(*) FROM ilb_psoriasis_kinetic_observation) AS kinetic_observation_count,
  (SELECT COUNT(*) FROM ilb_psoriasis_equation_measurement) AS measurement_mapping_count,
  (SELECT COUNT(*) FROM ilb_psoriasis_math_source) AS source_count,
  CASE
    WHEN (SELECT COUNT(*) FROM ilb_psoriasis_equation)=9
     AND (SELECT COUNT(*) FROM ilb_psoriasis_parameter)>=23
     AND (SELECT COUNT(*) FROM ilb_psoriasis_parameter WHERE value_numeric IS NOT NULL)=0
     AND (SELECT COUNT(*) FROM ilb_psoriasis_kinetic_observation)>=5
     AND (SELECT COUNT(*) FROM ilb_psoriasis_equation_measurement)>=15
    THEN 'STRUCTURE_READY_COEFFICIENTS_UNFIT'
    ELSE 'INCOMPLETE'
  END AS readiness_status;

CREATE OR REPLACE VIEW v_ilb_psoriasis_clearance_condition AS
SELECT
  'EQ_P' AS equation_code,
  'alpha_P*K + beta_P*Q + gamma_P*B < delta_P*P' AS regression_condition,
  'Plaque burden regresses when downstream formation pressure is lower than the plaque resolution term. This is a symbolic condition until coefficients and states are measured.' AS interpretation,
  'NO_CURE_CLAIM' AS governance_status;
