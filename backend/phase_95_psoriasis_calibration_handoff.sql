-- Phase 95: laboratory-ready, non-patient calibration handoff.
-- Values that depend on the selected reagent, assay or model remain deliberately blank.
START TRANSACTION;

CREATE TABLE IF NOT EXISTS ilb_psoriasis_calibration_study (
 calibration_key varchar(100) NOT NULL,
 experiment_key varchar(80) NOT NULL,
 study_order tinyint unsigned NOT NULL,
 study_name varchar(200) NOT NULL,
 objective text NOT NULL,
 model_system varchar(255) NOT NULL,
 participant_treatment tinyint(1) NOT NULL DEFAULT 0,
 status enum('SPECIFIED','RUNNING','COMPLETE','LOCKED') NOT NULL DEFAULT 'SPECIFIED',
 PRIMARY KEY(calibration_key),
 CONSTRAINT fk_p95_cal_experiment FOREIGN KEY(experiment_key)
  REFERENCES ilb_psoriasis_experiment(experiment_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO ilb_psoriasis_calibration_study VALUES
('CAL01_REAGENT_IDENTITY','EXP_PSO_RESET_001',1,'Reagent and barrier-candidate identity lock','Record exact intervention identity, lot, purity, formulation, target and chemical or protein identifiers before calibration.','T-cell-enriched full-thickness 3D psoriatic skin equivalent',0,'SPECIFIED'),
('CAL02_DOSE_RESPONSE','EXP_PSO_RESET_001',2,'Same-model concentration-response calibration','Determine target engagement, five-state response and tissue quality for the exact IL-17 blocker, IL-23 blocker and barrier candidate.','T-cell-enriched full-thickness 3D psoriatic skin equivalent',0,'SPECIFIED'),
('CAL03_TIME_COURSE','EXP_PSO_RESET_001',3,'Intervention and renewal time course','Measure response onset, plateau, intervention-free renewal and tissue quality in the selected model.','T-cell-enriched full-thickness 3D psoriatic skin equivalent',0,'SPECIFIED'),
('CAL04_WASHOUT_ASSAY','EXP_PSO_RESET_001',4,'Matrix-specific washout assay validation','Validate detection of each exact intervention in culture matrix and determine DL and QL under the locked analytical procedure.','Culture medium and tissue matrix from the selected 3D model',0,'SPECIFIED'),
('CAL05_RECHALLENGE','EXP_PSO_RESET_001',5,'Matched rechallenge calibration','Choose stimulus, concentration and duration that reproducibly separates controls while preserving tissue quality.','T-cell-enriched full-thickness 3D psoriatic skin equivalent',0,'SPECIFIED'),
('CAL06_EQUIVALENCE','EXP_PSO_RESET_001',6,'Assay precision and equivalence-margin lock','Estimate measurement repeatability and simultaneous healthy-control variation and preregister state-specific equivalence margins.','Locked assays on simultaneous healthy and psoriatic control tissues',0,'SPECIFIED')
ON DUPLICATE KEY UPDATE study_order=VALUES(study_order),study_name=VALUES(study_name),objective=VALUES(objective),model_system=VALUES(model_system),participant_treatment=VALUES(participant_treatment),status=VALUES(status);

CREATE TABLE IF NOT EXISTS ilb_psoriasis_calibration_control (
 control_key varchar(100) NOT NULL,
 calibration_key varchar(100) NOT NULL,
 control_name varchar(180) NOT NULL,
 purpose text NOT NULL,
 required tinyint(1) NOT NULL DEFAULT 1,
 PRIMARY KEY(control_key),
 CONSTRAINT fk_p95_control_cal FOREIGN KEY(calibration_key)
  REFERENCES ilb_psoriasis_calibration_study(calibration_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO ilb_psoriasis_calibration_control VALUES
('CTL_ID_DOCUMENT','CAL01_REAGENT_IDENTITY','Identity documentation','Prevents an intervention class name from being treated as an executable reagent.',1),
('CTL_HEALTHY_MATCHED','CAL02_DOSE_RESPONSE','Simultaneous healthy-model control','Defines the within-run healthy state for every observable.',1),
('CTL_PSORIATIC_UNTREATED','CAL02_DOSE_RESPONSE','Simultaneous untreated psoriatic-model control','Defines the within-run disease state and spontaneous drift.',1),
('CTL_VEHICLE_OR_ISOTYPE','CAL02_DOSE_RESPONSE','Matched vehicle or isotype control','Separates target-specific response from vehicle or antibody-format effects.',1),
('CTL_MATRIX_BLANK','CAL04_WASHOUT_ASSAY','Blank culture matrix','Measures matrix background without intervention.',1),
('CTL_MATRIX_SPIKE','CAL04_WASHOUT_ASSAY','Matrix-matched intervention standards','Provides calibration, recovery and matrix-effect evidence.',1),
('CTL_PRE_RECHALLENGE','CAL05_RECHALLENGE','Matched unstimulated tissues','Defines change attributable to rechallenge.',1),
('CTL_RECHALLENGE_HEALTHY','CAL05_RECHALLENGE','Rechallenged healthy-model control','Measures stimulus response outside the psoriatic state.',1),
('CTL_RECHALLENGE_PSORIATIC','CAL05_RECHALLENGE','Rechallenged psoriatic-model control','Confirms the stimulus can reproduce the prespecified disease response.',1),
('CTL_REPEATABILITY','CAL06_EQUIVALENCE','Replicated simultaneous controls','Provides assay and control repeatability used to derive equivalence margins.',1)
ON DUPLICATE KEY UPDATE calibration_key=VALUES(calibration_key),control_name=VALUES(control_name),purpose=VALUES(purpose),required=VALUES(required);

CREATE TABLE IF NOT EXISTS ilb_psoriasis_parameter_acquisition (
 parameter_key varchar(100) NOT NULL,
 calibration_key varchar(100) NOT NULL,
 measured_output varchar(255) NOT NULL,
 promotion_gate text NOT NULL,
 promoted_numeric_value decimal(20,8) NULL,
 promoted_unit varchar(80) NULL,
 promoted_text_value varchar(500) NULL,
 evidence_record_id varchar(120) NULL,
 approval_state enum('EMPTY','MEASURED','QC_PASSED','PREREGISTERED','PROMOTED','REJECTED') NOT NULL DEFAULT 'EMPTY',
 PRIMARY KEY(parameter_key),
 CONSTRAINT fk_p95_acq_parameter FOREIGN KEY(parameter_key)
  REFERENCES ilb_psoriasis_experiment_parameter(parameter_key),
 CONSTRAINT fk_p95_acq_cal FOREIGN KEY(calibration_key)
  REFERENCES ilb_psoriasis_calibration_study(calibration_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO ilb_psoriasis_parameter_acquisition(parameter_key,calibration_key,measured_output,promotion_gate) VALUES
('BARRIER_CANDIDATE_ID','CAL01_REAGENT_IDENTITY','Locked candidate identity and compatible-model functional barrier evidence','Identity, purity, provenance, ChEBI identifier when applicable, and barrier observable mapping complete.'),
('IL17_BLOCK_CONCENTRATION','CAL02_DOSE_RESPONSE','Lowest tested concentration satisfying the preregistered target-engagement, tissue-quality and state-response gates','Same-model result passes QC; clinical dose conversion is absent.'),
('IL23_BLOCK_CONCENTRATION','CAL02_DOSE_RESPONSE','Lowest tested concentration satisfying the preregistered target-engagement, tissue-quality and state-response gates','Same-model result passes QC; binding affinity alone and clinical dose conversion are absent.'),
('INTERVENTION_DURATION','CAL03_TIME_COURSE','Locked response sampling time','Onset and plateau are observed while tissue-quality gates pass.'),
('WASHOUT_DETECTION_ASSAY','CAL04_WASHOUT_ASSAY','Locked analytical procedure identifier','Specificity, range, accuracy, precision, matrix effect, recovery and system suitability are documented as applicable.'),
('WASHOUT_DETECTION_LIMIT','CAL04_WASHOUT_ASSAY','Validated DL in the locked matrix and procedure','DL approach is prespecified, calculated from calibration data and confirmed near the limit.'),
('RENEWAL_DURATION','CAL03_TIME_COURSE','Measured intervention-free model renewal window','The prespecified epidermal renewal event is observed and tissue quality remains acceptable.'),
('RECHALLENGE_STIMULUS','CAL05_RECHALLENGE','Locked stimulus identity and concentration','Reproducible control separation and tissue-quality gates pass.'),
('RECHALLENGE_DURATION','CAL05_RECHALLENGE','Locked post-stimulus observation time','The prespecified response window is captured with valid controls.'),
('PASS_TOLERANCE','CAL06_EQUIVALENCE','State-specific equivalence margin record','Margins are derived from locked assay/control repeatability and preregistered before treatment identities are unblinded.')
ON DUPLICATE KEY UPDATE calibration_key=VALUES(calibration_key),measured_output=VALUES(measured_output),promotion_gate=VALUES(promotion_gate);

CREATE TABLE IF NOT EXISTS ilb_psoriasis_calibration_measurement (
 measurement_id bigint unsigned NOT NULL AUTO_INCREMENT,
 calibration_key varchar(100) NOT NULL,
 run_id varchar(100) NOT NULL,
 tissue_id varchar(100) NOT NULL,
 control_or_candidate_key varchar(120) NOT NULL,
 parameter_key varchar(100) NULL,
 observable_key varchar(80) NOT NULL,
 time_value decimal(20,8) NULL,
 time_unit varchar(40) NULL,
 exposure_value decimal(20,8) NULL,
 exposure_unit varchar(80) NULL,
 measured_value decimal(30,12) NULL,
 measured_unit varchar(80) NULL,
 below_detection_limit tinyint(1) NULL,
 qc_status enum('PENDING','PASS','FAIL','EXCLUDED') NOT NULL DEFAULT 'PENDING',
 exclusion_reason varchar(500) NULL,
 source_record_uri varchar(1000) NULL,
 recorded_at timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
 PRIMARY KEY(measurement_id),
 KEY idx_p95_run(run_id),
 KEY idx_p95_parameter(parameter_key),
 CONSTRAINT fk_p95_measure_cal FOREIGN KEY(calibration_key)
  REFERENCES ilb_psoriasis_calibration_study(calibration_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ilb_psoriasis_calibration_formula (
 formula_key varchar(100) NOT NULL,
 formula_latex text NOT NULL,
 definition text NOT NULL,
 source_id varchar(100) NULL,
 source_url varchar(1000) NULL,
 invented_coefficient_count int unsigned NOT NULL DEFAULT 0,
 PRIMARY KEY(formula_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO ilb_psoriasis_calibration_formula VALUES
('F_CAL_NORMALISE','N_{a,j,t}=(X_{a,j,t}-H_{j,t})/(P_{j,t}-H_{j,t})','Existing within-run normalization; invalid when P-H equals zero.',NULL,NULL,0),
('F_LIVE_FRACTION','V=n_{live}/n_{total}','Observed live fraction; its acceptance threshold must be preregistered from the validated tissue-quality assay.',NULL,NULL,0),
('F_ICH_DL','DL=3.3\\sigma/S','ICH Q2(R2) estimate using response standard deviation sigma and calibration-curve slope S; the selected estimation approach must be justified and confirmed.','ICH:Q2(R2)','https://database.ich.org/sites/default/files/ICH_Q2%28R2%29_Guideline_2023_1130.pdf',0),
('F_ICH_QL','QL=10\\sigma/S','ICH Q2(R2) estimate using response standard deviation sigma and calibration-curve slope S; QL must be confirmed using samples near the limit.','ICH:Q2(R2)','https://database.ich.org/sites/default/files/ICH_Q2%28R2%29_Guideline_2023_1130.pdf',0),
('F_EQUIVALENCE','CI(\\Delta_{a,j})\\subseteq[-\\delta_j,+\\delta_j]','Equivalence passes only when the confidence interval for the arm-control difference lies entirely inside the preregistered state-specific margin.',NULL,NULL,0),
('F_EXECUTABLE','E=\\bigwedge_{i=1}^{18}R_i','The reset experiment is executable only when every required parameter has source-exact or promoted validated provenance.',NULL,NULL,0)
ON DUPLICATE KEY UPDATE formula_latex=VALUES(formula_latex),definition=VALUES(definition),source_id=VALUES(source_id),source_url=VALUES(source_url),invented_coefficient_count=VALUES(invented_coefficient_count);

COMMIT;
