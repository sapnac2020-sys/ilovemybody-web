-- ILoveMyBody psoriasis hospital input and parameter contract.
-- Additive, nullable-by-design, and safe for repeated deployment.

CREATE TABLE IF NOT EXISTS ilb_model_input_definition (
  input_id CHAR(64) PRIMARY KEY,
  model_code VARCHAR(160) NOT NULL,
  input_code VARCHAR(160) NOT NULL,
  category_code VARCHAR(64) NOT NULL,
  label VARCHAR(512) NOT NULL,
  value_domain ENUM('NUMBER','INTEGER','BOOLEAN','CATEGORY','TEXT','DATETIME') NOT NULL,
  canonical_unit_code VARCHAR(64) NULL,
  time_basis VARCHAR(160) NULL,
  body_site_required BOOLEAN NOT NULL DEFAULT FALSE,
  provenance_required BOOLEAN NOT NULL DEFAULT TRUE,
  release_required BOOLEAN NOT NULL DEFAULT TRUE,
  UNIQUE KEY uq_model_input (model_code,input_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_subject_observation (
  observation_id CHAR(64) PRIMARY KEY,
  subject_key VARCHAR(255) NOT NULL,
  episode_key VARCHAR(255) NOT NULL,
  input_id CHAR(64) NOT NULL,
  observed_at DATETIME(6) NOT NULL,
  value_number DECIMAL(38,12) NULL,
  value_text TEXT NULL,
  unit_code VARCHAR(64) NULL,
  body_site VARCHAR(255) NULL,
  method_code VARCHAR(160) NULL,
  source_record_id CHAR(64) NULL,
  quality_status ENUM('UNVERIFIED','VALID','REJECTED') NOT NULL DEFAULT 'UNVERIFIED',
  entered_by VARCHAR(255) NULL,
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  CONSTRAINT fk_subject_observation_input FOREIGN KEY(input_id) REFERENCES ilb_model_input_definition(input_id),
  CHECK (value_number IS NOT NULL OR value_text IS NOT NULL)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_medicine_exposure (
  exposure_id CHAR(64) PRIMARY KEY,
  subject_key VARCHAR(255) NOT NULL,
  episode_key VARCHAR(255) NOT NULL,
  medicine_entity_id CHAR(64) NULL,
  medicine_name_as_recorded VARCHAR(512) NOT NULL,
  dose_value DECIMAL(38,12) NULL,
  dose_unit VARCHAR(64) NULL,
  route_code VARCHAR(64) NULL,
  start_at DATETIME(6) NULL,
  end_at DATETIME(6) NULL,
  schedule_text VARCHAR(512) NULL,
  prescribed_flag BOOLEAN NOT NULL DEFAULT FALSE,
  verification_status ENUM('PENDING','VERIFIED','REJECTED') NOT NULL DEFAULT 'PENDING',
  CONSTRAINT fk_medicine_exposure_entity FOREIGN KEY(medicine_entity_id) REFERENCES ilb_semantic_entity(entity_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_adverse_event_observation (
  adverse_event_id CHAR(64) PRIMARY KEY,
  subject_key VARCHAR(255) NOT NULL,
  episode_key VARCHAR(255) NOT NULL,
  exposure_id CHAR(64) NULL,
  event_label VARCHAR(512) NOT NULL,
  onset_at DATETIME(6) NULL,
  resolved_at DATETIME(6) NULL,
  severity ENUM('MILD','MODERATE','SEVERE','LIFE_THREATENING','UNKNOWN') NOT NULL DEFAULT 'UNKNOWN',
  seriousness_flag BOOLEAN NOT NULL DEFAULT FALSE,
  action_taken TEXT NULL,
  outcome_text TEXT NULL,
  attribution ENUM('UNASSESSED','UNLIKELY','POSSIBLE','PROBABLE','DEFINITE') NOT NULL DEFAULT 'UNASSESSED',
  clinician_review_status ENUM('PENDING','REVIEWED','REJECTED') NOT NULL DEFAULT 'PENDING',
  CONSTRAINT fk_adverse_event_exposure FOREIGN KEY(exposure_id) REFERENCES ilb_medicine_exposure(exposure_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_model_parameter_definition (
  parameter_id CHAR(64) PRIMARY KEY,
  model_code VARCHAR(160) NOT NULL,
  parameter_code VARCHAR(160) NOT NULL,
  label VARCHAR(512) NOT NULL,
  equation_code VARCHAR(160) NULL,
  canonical_unit_code VARCHAR(128) NULL,
  parameter_role ENUM('INITIAL_STATE','KINETIC','PK','BINDING','OBJECTIVE','SAFETY','TRANSFER') NOT NULL,
  source_required BOOLEAN NOT NULL DEFAULT TRUE,
  UNIQUE KEY uq_model_parameter (model_code,parameter_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_model_parameter_value (
  parameter_value_id CHAR(64) PRIMARY KEY,
  parameter_id CHAR(64) NOT NULL,
  subject_key VARCHAR(255) NULL,
  value_number DECIMAL(38,12) NULL,
  unit_code VARCHAR(128) NULL,
  valid_from DATETIME(6) NULL,
  source_record_id CHAR(64) NULL,
  source_status ENUM('MISSING','MEASURED_PERSON','PHYSICS_CHEMISTRY','EXTERNAL_RANGE','HYPOTHESIS','VALIDATED') NOT NULL DEFAULT 'MISSING',
  approval_status ENUM('PENDING','APPROVED','REJECTED') NOT NULL DEFAULT 'PENDING',
  version_no INT UNSIGNED NOT NULL DEFAULT 1,
  CONSTRAINT fk_parameter_value_definition FOREIGN KEY(parameter_id) REFERENCES ilb_model_parameter_definition(parameter_id),
  CHECK ((source_status='MISSING' AND value_number IS NULL) OR source_status<>'MISSING')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_model_release_gate (
  model_code VARCHAR(160) NOT NULL,
  gate_code VARCHAR(64) NOT NULL,
  gate_order INT UNSIGNED NOT NULL,
  gate_status ENUM('PASS','BLOCKED','FAIL') NOT NULL DEFAULT 'BLOCKED',
  reason_text TEXT NOT NULL,
  checked_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY(model_code,gate_code),
  UNIQUE KEY uq_model_gate_order(model_code,gate_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO ilb_model_input_definition(input_id,model_code,input_code,category_code,label,value_domain,canonical_unit_code,time_basis,body_site_required,provenance_required,release_required) VALUES
(SHA2('PSO:IN:AGE',256),'PSO_COP_LIFESTYLE_V4','AGE','DEMOGRAPHY','Age','NUMBER','a','at assessment',FALSE,TRUE,TRUE),
(SHA2('PSO:IN:SEX',256),'PSO_COP_LIFESTYLE_V4','SEX_RECORDED','DEMOGRAPHY','Sex as recorded','CATEGORY',NULL,'at assessment',FALSE,TRUE,TRUE),
(SHA2('PSO:IN:HEIGHT',256),'PSO_COP_LIFESTYLE_V4','HEIGHT','ANTHROPOMETRY','Height','NUMBER','cm','at assessment',FALSE,TRUE,TRUE),
(SHA2('PSO:IN:WEIGHT',256),'PSO_COP_LIFESTYLE_V4','WEIGHT','ANTHROPOMETRY','Weight','NUMBER','kg','at assessment',FALSE,TRUE,TRUE),
(SHA2('PSO:IN:WAIST',256),'PSO_COP_LIFESTYLE_V4','WAIST','ANTHROPOMETRY','Waist circumference','NUMBER','cm','at assessment',FALSE,TRUE,FALSE),
(SHA2('PSO:IN:PASI',256),'PSO_COP_LIFESTYLE_V4','PASI','DISEASE_ACTIVITY','Psoriasis Area and Severity Index','NUMBER','1','assessment date',TRUE,TRUE,TRUE),
(SHA2('PSO:IN:BSA',256),'PSO_COP_LIFESTYLE_V4','BSA_PERCENT','DISEASE_ACTIVITY','Affected body surface area','NUMBER','%','assessment date',TRUE,TRUE,TRUE),
(SHA2('PSO:IN:PGA',256),'PSO_COP_LIFESTYLE_V4','PGA','DISEASE_ACTIVITY','Physician global assessment','NUMBER','1','assessment date',FALSE,TRUE,TRUE),
(SHA2('PSO:IN:PLAQUE',256),'PSO_COP_LIFESTYLE_V4','PLAQUE_TARGET','DISEASE_ACTIVITY','Target plaque measurement','NUMBER','cm2','assessment date',TRUE,TRUE,TRUE),
(SHA2('PSO:IN:ITCH',256),'PSO_COP_LIFESTYLE_V4','ITCH_NRS','SYMPTOM','Itch numeric rating','NUMBER','1','daily',FALSE,TRUE,TRUE),
(SHA2('PSO:IN:PAIN',256),'PSO_COP_LIFESTYLE_V4','PAIN_NRS','SYMPTOM','Pain numeric rating','NUMBER','1','daily',FALSE,TRUE,TRUE),
(SHA2('PSO:IN:BLEED',256),'PSO_COP_LIFESTYLE_V4','BLEEDING','SYMPTOM','Skin bleeding','BOOLEAN',NULL,'daily',TRUE,TRUE,FALSE),
(SHA2('PSO:IN:DLQI',256),'PSO_COP_LIFESTYLE_V4','DLQI','QUALITY_OF_LIFE','Dermatology Life Quality Index','INTEGER','1','assessment date',FALSE,TRUE,TRUE),
(SHA2('PSO:IN:SLEEPQ',256),'PSO_COP_LIFESTYLE_V4','SLEEP_QUALITY','QUALITY_OF_LIFE','Sleep quality rating','NUMBER','1','daily',FALSE,TRUE,TRUE),
(SHA2('PSO:IN:MOOD',256),'PSO_COP_LIFESTYLE_V4','MOOD_FUNCTION','QUALITY_OF_LIFE','Mood and functioning rating','NUMBER','1','daily',FALSE,TRUE,TRUE),
(SHA2('PSO:IN:BP_SYS',256),'PSO_COP_LIFESTYLE_V4','BP_SYSTOLIC','VITAL','Systolic blood pressure','NUMBER','mm[Hg]','assessment date',FALSE,TRUE,FALSE),
(SHA2('PSO:IN:BP_DIA',256),'PSO_COP_LIFESTYLE_V4','BP_DIASTOLIC','VITAL','Diastolic blood pressure','NUMBER','mm[Hg]','assessment date',FALSE,TRUE,FALSE),
(SHA2('PSO:IN:HR',256),'PSO_COP_LIFESTYLE_V4','HEART_RATE','VITAL','Heart rate','NUMBER','/min','assessment date',FALSE,TRUE,FALSE),
(SHA2('PSO:IN:CRP',256),'PSO_COP_LIFESTYLE_V4','CRP','LAB','C-reactive protein','NUMBER','mg/L','specimen time',FALSE,TRUE,FALSE),
(SHA2('PSO:IN:CBC',256),'PSO_COP_LIFESTYLE_V4','CBC_STATUS','LAB','Complete blood count result status','CATEGORY',NULL,'specimen time',FALSE,TRUE,FALSE),
(SHA2('PSO:IN:ALT',256),'PSO_COP_LIFESTYLE_V4','ALT','LAB','Alanine aminotransferase','NUMBER','U/L','specimen time',FALSE,TRUE,FALSE),
(SHA2('PSO:IN:AST',256),'PSO_COP_LIFESTYLE_V4','AST','LAB','Aspartate aminotransferase','NUMBER','U/L','specimen time',FALSE,TRUE,FALSE),
(SHA2('PSO:IN:CREAT',256),'PSO_COP_LIFESTYLE_V4','CREATININE','LAB','Creatinine','NUMBER','mg/dL','specimen time',FALSE,TRUE,FALSE),
(SHA2('PSO:IN:HBA1C',256),'PSO_COP_LIFESTYLE_V4','HBA1C','LAB','Glycated haemoglobin','NUMBER','%','specimen time',FALSE,TRUE,FALSE),
(SHA2('PSO:IN:LIPID',256),'PSO_COP_LIFESTYLE_V4','LIPID_STATUS','LAB','Lipid profile status','CATEGORY',NULL,'specimen time',FALSE,TRUE,FALSE),
(SHA2('PSO:IN:VITD',256),'PSO_COP_LIFESTYLE_V4','VITAMIN_D_25OH','LAB','25-hydroxy vitamin D','NUMBER','ng/mL','specimen time',FALSE,TRUE,FALSE),
(SHA2('PSO:IN:SMOKE',256),'PSO_COP_LIFESTYLE_V4','SMOKING','EXPOSURE','Smoking exposure','NUMBER','cigarettes/d','daily',FALSE,TRUE,TRUE),
(SHA2('PSO:IN:ALCOHOL',256),'PSO_COP_LIFESTYLE_V4','ALCOHOL','EXPOSURE','Alcohol exposure','NUMBER','g/d','daily',FALSE,TRUE,TRUE),
(SHA2('PSO:IN:TRAUMA',256),'PSO_COP_LIFESTYLE_V4','SKIN_TRAUMA','EXPOSURE','Mechanical skin trauma','INTEGER','events/wk','weekly',TRUE,TRUE,TRUE),
(SHA2('PSO:IN:UV',256),'PSO_COP_LIFESTYLE_V4','UV_DOSE','EXPOSURE','Skin-site effective UV dose','NUMBER','J/m2/d','daily',TRUE,TRUE,TRUE),
(SHA2('PSO:IN:DIET',256),'PSO_COP_LIFESTYLE_V4','DIET_LOG','LIFESTYLE','Time-stamped food and drink log','TEXT',NULL,'per intake',FALSE,TRUE,TRUE),
(SHA2('PSO:IN:SLEEP',256),'PSO_COP_LIFESTYLE_V4','SLEEP_LOG','LIFESTYLE','Sleep start, end and awakenings','TEXT',NULL,'nightly',FALSE,TRUE,TRUE),
(SHA2('PSO:IN:ACTIVITY',256),'PSO_COP_LIFESTYLE_V4','ACTIVITY_LOG','LIFESTYLE','Activity and sedentary log','TEXT',NULL,'daily',FALSE,TRUE,TRUE),
(SHA2('PSO:IN:STRESS',256),'PSO_COP_LIFESTYLE_V4','STRESS_LOG','LIFESTYLE','Threat, conflict and recovery log','TEXT',NULL,'event/daily',FALSE,TRUE,TRUE),
(SHA2('PSO:IN:EMOLLIENT',256),'PSO_COP_LIFESTYLE_V4','EMOLLIENT','LIFESTYLE','Emollient quantity and site','NUMBER','g/site/d','daily',TRUE,TRUE,TRUE),
(SHA2('PSO:IN:PHOTO',256),'PSO_COP_LIFESTYLE_V4','STANDARD_PHOTO','IMAGING','Standardised lesion photograph reference','TEXT',NULL,'assessment date',TRUE,TRUE,TRUE),
(SHA2('PSO:IN:MED',256),'PSO_COP_LIFESTYLE_V4','MEDICINE_SCHEDULE','MEDICINE','Verified medicine dose, route and schedule','TEXT',NULL,'per administration',FALSE,TRUE,TRUE),
(SHA2('PSO:IN:AE',256),'PSO_COP_LIFESTYLE_V4','ADVERSE_EVENT','SAFETY','Adverse event record','TEXT',NULL,'per event',FALSE,TRUE,TRUE),
(SHA2('PSO:IN:INFECTION',256),'PSO_COP_LIFESTYLE_V4','INFECTION_SIGNAL','SAFETY','Possible infection signal','BOOLEAN',NULL,'continuous/event',FALSE,TRUE,TRUE),
(SHA2('PSO:IN:URGENT',256),'PSO_COP_LIFESTYLE_V4','URGENT_SAFETY_SIGNAL','SAFETY','Urgent safety signal','BOOLEAN',NULL,'continuous/event',FALSE,TRUE,TRUE)
ON DUPLICATE KEY UPDATE label=VALUES(label),canonical_unit_code=VALUES(canonical_unit_code),release_required=VALUES(release_required);

INSERT INTO ilb_model_parameter_definition(parameter_id,model_code,parameter_code,label,equation_code,canonical_unit_code,parameter_role) VALUES
(SHA2('PSO:PAR:D0',256),'PSO_COP_LIFESTYLE_V4','D0','Initial immune balance',NULL,'1','INITIAL_STATE'),
(SHA2('PSO:PAR:I230',256),'PSO_COP_LIFESTYLE_V4','I230','Initial IL-23 state',NULL,'1','INITIAL_STATE'),
(SHA2('PSO:PAR:T170',256),'PSO_COP_LIFESTYLE_V4','T170','Initial Th17 state',NULL,'1','INITIAL_STATE'),
(SHA2('PSO:PAR:L170',256),'PSO_COP_LIFESTYLE_V4','L170','Initial free IL-17A',NULL,'pmol/L','INITIAL_STATE'),
(SHA2('PSO:PAR:KP0',256),'PSO_COP_LIFESTYLE_V4','Kp0','Initial proliferating keratinocytes',NULL,'cells/mm2','INITIAL_STATE'),
(SHA2('PSO:PAR:KD0',256),'PSO_COP_LIFESTYLE_V4','Kd0','Initial differentiating keratinocytes',NULL,'cells/mm2','INITIAL_STATE'),
(SHA2('PSO:PAR:B0',256),'PSO_COP_LIFESTYLE_V4','B0','Initial barrier injury',NULL,'1','INITIAL_STATE'),
(SHA2('PSO:PAR:P0',256),'PSO_COP_LIFESTYLE_V4','P0','Initial plaque burden',NULL,'1','INITIAL_STATE'),
(SHA2('PSO:PAR:N0',256),'PSO_COP_LIFESTYLE_V4','N0','Initial neurostress state',NULL,'1','INITIAL_STATE'),
(SHA2('PSO:PAR:M0',256),'PSO_COP_LIFESTYLE_V4','M0','Initial metabolic drive',NULL,'1','INITIAL_STATE'),
(SHA2('PSO:PAR:KA',256),'PSO_COP_LIFESTYLE_V4','ka','Absorption rate','PSO_M3_04','1/d','PK'),
(SHA2('PSO:PAR:FSC',256),'PSO_COP_LIFESTYLE_V4','Fsc','Subcutaneous bioavailability','PSO_M3_05','1','PK'),
(SHA2('PSO:PAR:MWIX',256),'PSO_COP_LIFESTYLE_V4','MWix','Ixekizumab molecular weight','PSO_M3_05','g/mol','PK'),
(SHA2('PSO:PAR:VIX',256),'PSO_COP_LIFESTYLE_V4','Vix','Distribution volume','PSO_M3_05','L','PK'),
(SHA2('PSO:PAR:KEL',256),'PSO_COP_LIFESTYLE_V4','kel','Elimination rate','PSO_M3_05','1/d','PK'),
(SHA2('PSO:PAR:KON',256),'PSO_COP_LIFESTYLE_V4','kon','Association rate','PSO_M3_06','L/pmol/d','BINDING'),
(SHA2('PSO:PAR:KOFF',256),'PSO_COP_LIFESTYLE_V4','koff','Dissociation rate','PSO_M3_06','1/d','BINDING'),
(SHA2('PSO:PAR:KINT',256),'PSO_COP_LIFESTYLE_V4','kint','Complex internalisation rate','PSO_M3_06','1/d','BINDING'),
(SHA2('PSO:PAR:NRMSE',256),'PSO_COP_LIFESTYLE_V4','NRMSE_TOL','Declared NRMSE tolerance','PSO_M3_15','1','OBJECTIVE'),
(SHA2('PSO:PAR:LP',256),'PSO_COP_LIFESTYLE_V4','LAMBDA_P','Plaque objective weight','PSO_M3_15','1','OBJECTIVE'),
(SHA2('PSO:PAR:LC',256),'PSO_COP_LIFESTYLE_V4','LAMBDA_C','Lifestyle burden weight','PSO_M3_15','1','OBJECTIVE')
ON DUPLICATE KEY UPDATE label=VALUES(label),canonical_unit_code=VALUES(canonical_unit_code),parameter_role=VALUES(parameter_role);

INSERT INTO ilb_model_parameter_value(parameter_value_id,parameter_id,subject_key,value_number,unit_code,source_status,approval_status,version_no)
SELECT SHA2(CONCAT('PSO:PARVAL:',parameter_code,':V1'),256),parameter_id,NULL,NULL,canonical_unit_code,'MISSING','PENDING',1
FROM ilb_model_parameter_definition WHERE model_code='PSO_COP_LIFESTYLE_V4'
ON DUPLICATE KEY UPDATE value_number=NULL,source_status='MISSING',approval_status='PENDING';

INSERT INTO ilb_model_release_gate(model_code,gate_code,gate_order,gate_status,reason_text) VALUES
('PSO_COP_LIFESTYLE_V4','IDENTITY_CONSENT',1,'BLOCKED','No consented subject episode has been created.'),
('PSO_COP_LIFESTYLE_V4','BASELINE_COMPLETE',2,'BLOCKED','Required disease, symptom, quality-of-life and lifestyle baselines are missing.'),
('PSO_COP_LIFESTYLE_V4','MEDICINE_EXPOSURE_VERIFIED',3,'BLOCKED','Dose, route, timing and prescription verification are missing.'),
('PSO_COP_LIFESTYLE_V4','PARAMETERS_SOURCED',4,'BLOCKED','Initial-state, kinetic, PK, binding and objective parameters are incomplete.'),
('PSO_COP_LIFESTYLE_V4','TRANSFER_COEFFICIENTS_SOURCED',5,'BLOCKED','All 182 lifestyle-to-node coefficients remain unknown.'),
('PSO_COP_LIFESTYLE_V4','DIMENSIONAL_VALIDATION',6,'BLOCKED','All equation terms and imported units must pass dimensional checks.'),
('PSO_COP_LIFESTYLE_V4','NUMERICAL_STABILITY',7,'BLOCKED','Solver stability, step-size and replay tests have not run.'),
('PSO_COP_LIFESTYLE_V4','BENEFIT_HARM_COMPLETE',8,'BLOCKED','Benefit and harm outputs are not both populated.'),
('PSO_COP_LIFESTYLE_V4','QOL_COMPLETE',9,'BLOCKED','Quality-of-life inputs and calculation are absent.'),
('PSO_COP_LIFESTYLE_V4','CLINICIAN_APPROVAL',10,'BLOCKED','No patient report may be released without clinician approval.')
ON DUPLICATE KEY UPDATE gate_status='BLOCKED',reason_text=VALUES(reason_text),checked_at=CURRENT_TIMESTAMP(6);

CREATE OR REPLACE VIEW v_ilb_psoriasis_input_readiness AS
SELECT
 (SELECT COUNT(*) FROM ilb_model_input_definition WHERE model_code='PSO_COP_LIFESTYLE_V4') input_definitions,
 (SELECT COUNT(*) FROM ilb_model_parameter_definition WHERE model_code='PSO_COP_LIFESTYLE_V4') parameter_definitions,
 (SELECT COUNT(*) FROM ilb_model_parameter_value pv JOIN ilb_model_parameter_definition pd ON pd.parameter_id=pv.parameter_id WHERE pd.model_code='PSO_COP_LIFESTYLE_V4' AND pv.value_number IS NULL) missing_parameters,
 (SELECT COUNT(*) FROM ilb_model_release_gate WHERE model_code='PSO_COP_LIFESTYLE_V4' AND gate_status<>'PASS') blocking_gates,
 CASE WHEN (SELECT COUNT(*) FROM ilb_model_release_gate WHERE model_code='PSO_COP_LIFESTYLE_V4' AND gate_status<>'PASS')=0 THEN 'READY_FOR_CALCULATION' ELSE 'BLOCKED_COLLECTION_REQUIRED' END readiness_status;
