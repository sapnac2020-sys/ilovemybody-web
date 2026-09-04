-- Phase 94: classify every unresolved execution parameter by how it can be resolved.
-- No clinical dose is converted to an in-vitro concentration and no threshold is imputed.
START TRANSACTION;

CREATE TABLE IF NOT EXISTS ilb_psoriasis_parameter_resolution_plan (
 parameter_key varchar(100) NOT NULL,
 resolution_class enum(
  'SOURCE_EXTRACTABLE',
  'REAGENT_SPECIFIC',
  'ASSAY_VALIDATION_REQUIRED',
  'PREREGISTRATION_REQUIRED',
  'DESIGN_CHOICE'
 ) NOT NULL,
 acquisition_rule text NOT NULL,
 completion_evidence text NOT NULL,
 clinical_to_invitro_conversion_allowed tinyint(1) NOT NULL DEFAULT 0,
 patient_experiment_required tinyint(1) NOT NULL DEFAULT 0,
 status enum('OPEN','RESOLVED') NOT NULL DEFAULT 'OPEN',
 PRIMARY KEY(parameter_key),
 CONSTRAINT fk_p94_parameter FOREIGN KEY(parameter_key)
  REFERENCES ilb_psoriasis_experiment_parameter(parameter_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO ilb_psoriasis_parameter_resolution_plan VALUES
('BARRIER_CANDIDATE_ID','DESIGN_CHOICE','Select one chemically identified candidate only after evidence maps it to a prespecified functional barrier observable in the compatible 3D system.','Identity, purity, supplier or synthesis record, ChEBI identifier when available, and compatible-model barrier evidence are recorded.',0,0,'OPEN'),
('IL17_BLOCK_CONCENTRATION','REAGENT_SPECIFIC','Run a non-patient concentration-response calibration for the exact antibody lot in the selected 3D model; do not translate a clinical dose.','A prespecified concentration is supported by target-engagement and viability curves from the same model and reagent.',0,0,'OPEN'),
('IL23_BLOCK_CONCENTRATION','REAGENT_SPECIFIC','Run a non-patient concentration-response calibration for the exact antibody lot in the selected 3D model; do not translate a clinical dose or substitute binding affinity.','A prespecified concentration is supported by target-engagement and viability curves from the same model and reagent.',0,0,'OPEN'),
('INTERVENTION_DURATION','DESIGN_CHOICE','Choose the sampling window from a pilot time course that resolves onset and plateau without loss of tissue quality.','The time course, tissue-quality gate and selected duration are preregistered before the reset experiment.',0,0,'OPEN'),
('PASS_TOLERANCE','PREREGISTRATION_REQUIRED','Derive the equivalence margin from validated assay precision and simultaneous healthy-control repeatability; lock it before treatment identities are unblinded.','Signed analysis plan records the assay-derived margin and confidence-interval decision rule.',0,0,'OPEN'),
('RECHALLENGE_DURATION','DESIGN_CHOICE','Select from a non-patient time course of the exact rechallenge stimulus in the same model.','The chosen observation time captures the prespecified response window while passing tissue-quality controls.',0,0,'OPEN'),
('RECHALLENGE_STIMULUS','ASSAY_VALIDATION_REQUIRED','Choose and calibrate a matched inflammatory stimulus that reproducibly separates psoriatic and healthy controls without invalidating tissue viability.','Identity, concentration, exposure, response dynamic range and viability gate are validated and preregistered.',0,0,'OPEN'),
('RENEWAL_DURATION','DESIGN_CHOICE','Set an intervention-free observation window from measured epidermal turnover in the actual 3D model, not from a general claim about daily skin renewal.','The selected window spans the prespecified model renewal event and maintains tissue quality.',0,0,'OPEN'),
('WASHOUT_DETECTION_ASSAY','REAGENT_SPECIFIC','Validate an analytical assay for each intervention in the culture matrix; antibody and small-molecule assays are not interchangeable.','Specificity, recovery, matrix effect, calibration range and sample handling are documented for the exact intervention.',0,0,'OPEN'),
('WASHOUT_DETECTION_LIMIT','ASSAY_VALIDATION_REQUIRED','Estimate the detection and quantification limits from the validated washout assay under the locked analytical protocol.','LOD and LOQ calculations, raw calibration data and acceptance criteria are recorded before washout samples are tested.',0,0,'OPEN')
ON DUPLICATE KEY UPDATE
 resolution_class=VALUES(resolution_class),
 acquisition_rule=VALUES(acquisition_rule),
 completion_evidence=VALUES(completion_evidence),
 clinical_to_invitro_conversion_allowed=VALUES(clinical_to_invitro_conversion_allowed),
 patient_experiment_required=VALUES(patient_experiment_required),
 status=VALUES(status);

CREATE TABLE IF NOT EXISTS ilb_psoriasis_experiment_decision_rule (
 rule_key varchar(100) NOT NULL,
 experiment_key varchar(80) NOT NULL,
 outcome_class varchar(100) NOT NULL,
 boolean_rule text NOT NULL,
 interpretation text NOT NULL,
 claim_ceiling text NOT NULL,
 invented_coefficient_count int unsigned NOT NULL DEFAULT 0,
 PRIMARY KEY(rule_key),
 CONSTRAINT fk_p94_rule_experiment FOREIGN KEY(experiment_key)
  REFERENCES ilb_psoriasis_experiment(experiment_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO ilb_psoriasis_experiment_decision_rule VALUES
('R_EXECUTABLE','EXP_PSO_RESET_001','EXECUTABLE','AND over all required parameters: resolution = SOURCE_EXACT or resolution plan status = RESOLVED','Every execution-critical value has source or model-validation provenance.','Protocol executable; no biological conclusion.',0),
('R_CONTROL','EXP_PSO_RESET_001','CONTROL_ONLY','on_treatment_equivalent = TRUE AND postwashout_equivalent = FALSE','The intervention suppresses measured disease state only while present.','Control in this model.',0),
('R_DISEASE_MODIFY','EXP_PSO_RESET_001','DISEASE_MODIFICATION_CANDIDATE','postrenewal_all_five_states_equivalent = TRUE AND residual_intervention_below_LOD = TRUE','All five state groups remain within the preregistered healthy equivalence margins after measured renewal and analytical washout.','Disease-modification candidate in this model.',0),
('R_DURABLE_RESET','EXP_PSO_RESET_001','DURABLE_RESET_CANDIDATE','postrenewal_all_five_states_equivalent = TRUE AND postrechallenge_all_five_states_equivalent = TRUE AND residual_intervention_below_LOD = TRUE','The corrected state persists through renewal and matched rechallenge with no detectable intervention.','Durable-reset candidate in this model; not a human cure claim.',0),
('R_CURE_PROHIBITED','EXP_PSO_RESET_001','NO_CURE_CONCLUSION','TRUE','No result from a single in-vitro experiment establishes cure in people.','Never exceeds non-patient model evidence.',0)
ON DUPLICATE KEY UPDATE
 outcome_class=VALUES(outcome_class),
 boolean_rule=VALUES(boolean_rule),
 interpretation=VALUES(interpretation),
 claim_ceiling=VALUES(claim_ceiling),
 invented_coefficient_count=VALUES(invented_coefficient_count);

COMMIT;
