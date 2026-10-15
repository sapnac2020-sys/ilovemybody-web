-- ILMB Paralysis governed schema v1.0
CREATE TABLE IF NOT EXISTS ilmb_par_module (
  module_id VARCHAR(40) PRIMARY KEY,
  module_name VARCHAR(160) NOT NULL,
  layer VARCHAR(20) NOT NULL,
  purpose TEXT NOT NULL,
  status VARCHAR(30) NOT NULL,
  import_order INT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS ilmb_par_motor_node (
  node_id VARCHAR(20) PRIMARY KEY,
  node_order INT NOT NULL,
  motor_node VARCHAR(160) NOT NULL,
  normal_function TEXT,
  failure_pattern TEXT,
  ontology_json JSON NULL
);
CREATE TABLE IF NOT EXISTS ilmb_par_cause (
  cause_id VARCHAR(20) PRIMARY KEY,
  module_id VARCHAR(40) NOT NULL,
  mechanism_class VARCHAR(80),
  example_cause VARCHAR(160),
  primary_failure_node VARCHAR(160),
  diagnostic_proof_layer TEXT,
  reversible_component TEXT,
  status VARCHAR(30) NOT NULL,
  FOREIGN KEY (module_id) REFERENCES ilmb_par_module(module_id)
);
CREATE TABLE IF NOT EXISTS ilmb_par_measure (
  measure_id VARCHAR(20) PRIMARY KEY,
  module_id VARCHAR(40) NOT NULL,
  domain VARCHAR(80) NOT NULL,
  measurement VARCHAR(160) NOT NULL,
  unit_scale VARCHAR(80),
  method TEXT,
  measured_or_derived VARCHAR(30) NOT NULL,
  external_id VARCHAR(160),
  FOREIGN KEY (module_id) REFERENCES ilmb_par_module(module_id)
);
CREATE TABLE IF NOT EXISTS ilmb_par_formula (
  formula_id VARCHAR(20) PRIMARY KEY,
  module_id VARCHAR(40) NOT NULL,
  name VARCHAR(160) NOT NULL,
  equation TEXT NOT NULL,
  inputs TEXT NOT NULL,
  units_check TEXT,
  purpose TEXT,
  coefficient_rule TEXT NOT NULL,
  validation_state VARCHAR(40) NOT NULL,
  source_basis TEXT,
  FOREIGN KEY (module_id) REFERENCES ilmb_par_module(module_id)
);
CREATE TABLE IF NOT EXISTS ilmb_par_parameter (
  parameter_id VARCHAR(20) PRIMARY KEY,
  module_id VARCHAR(40) NOT NULL,
  name VARCHAR(160) NOT NULL,
  symbol VARCHAR(80),
  unit VARCHAR(80),
  source_type VARCHAR(40) NOT NULL,
  source_value_method TEXT,
  patient_specific BOOLEAN NOT NULL DEFAULT TRUE,
  allowed_in_equation BOOLEAN NOT NULL DEFAULT FALSE,
  notes TEXT,
  FOREIGN KEY (module_id) REFERENCES ilmb_par_module(module_id)
);
CREATE TABLE IF NOT EXISTS ilmb_par_intervention (
  intervention_id VARCHAR(20) PRIMARY KEY,
  module_id VARCHAR(40) NOT NULL,
  intervention VARCHAR(200) NOT NULL,
  category VARCHAR(80) NOT NULL,
  body_target TEXT,
  mechanism TEXT,
  required_proof_before_use TEXT,
  key_measurement TEXT,
  benefit_path TEXT,
  risk_constraint TEXT,
  source_url TEXT,
  FOREIGN KEY (module_id) REFERENCES ilmb_par_module(module_id)
);
CREATE TABLE IF NOT EXISTS ilmb_par_emergency_gate (
  gate_id VARCHAR(20) PRIMARY KEY,
  trigger_text TEXT NOT NULL,
  why_time_critical TEXT NOT NULL,
  immediate_system_action TEXT NOT NULL,
  source_url TEXT
);
CREATE TABLE IF NOT EXISTS ilmb_par_crosswalk (
  crosswalk_id VARCHAR(20) PRIMARY KEY,
  internal_term VARCHAR(160) NOT NULL,
  internal_id VARCHAR(80) NOT NULL,
  external_system VARCHAR(80) NOT NULL,
  external_id VARCHAR(160),
  relationship_type VARCHAR(40),
  approval_state VARCHAR(30) NOT NULL DEFAULT 'REVIEW',
  notes TEXT
);
CREATE TABLE IF NOT EXISTS ilmb_par_case_observation (
  observation_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  case_id VARCHAR(80) NOT NULL,
  observed_at DATETIME NOT NULL,
  module_id VARCHAR(40) NOT NULL,
  phenotype VARCHAR(160),
  localization VARCHAR(160),
  cause_status VARCHAR(80),
  emergency_gate_status VARCHAR(20) NOT NULL,
  measure_id VARCHAR(20),
  value_num DECIMAL(20,8) NULL,
  value_text TEXT NULL,
  unit VARCHAR(80),
  source_text TEXT,
  confidence VARCHAR(20),
  FOREIGN KEY (module_id) REFERENCES ilmb_par_module(module_id),
  FOREIGN KEY (measure_id) REFERENCES ilmb_par_measure(measure_id)
);
CREATE TABLE IF NOT EXISTS ilmb_par_case_action (
  action_row_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  case_id VARCHAR(80) NOT NULL,
  action_at DATETIME NOT NULL,
  module_id VARCHAR(40) NOT NULL,
  intervention_id VARCHAR(20) NOT NULL,
  rationale TEXT,
  response TEXT,
  next_measure_id VARCHAR(20),
  FOREIGN KEY (module_id) REFERENCES ilmb_par_module(module_id),
  FOREIGN KEY (intervention_id) REFERENCES ilmb_par_intervention(intervention_id)
);
CREATE TABLE IF NOT EXISTS ilmb_par_evidence (
  evidence_id VARCHAR(20) PRIMARY KEY,
  module_id VARCHAR(40) NOT NULL,
  topic VARCHAR(160),
  claim_used TEXT NOT NULL,
  source_url TEXT NOT NULL,
  source_type VARCHAR(80),
  accessed_date DATE,
  FOREIGN KEY (module_id) REFERENCES ilmb_par_module(module_id)
);
-- HARD RULES:
-- Do not promote unsourced coefficients.
-- Do not issue a personalized action plan if emergency_gate_status='STOP'.
-- Do not auto-convert potassium concentration differences into oral/IV dosing.
-- External IDs remain staged until explicitly approved.
