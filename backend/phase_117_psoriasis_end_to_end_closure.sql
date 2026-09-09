-- Phase 117: Psoriasis end-to-end project closure
-- Orchestration only. Reuses existing intake, observations, modality, formula and primitive registries.
-- Rule: DERIVE -> PREDICT -> VERIFY. No treatment-equivalence or cure claim is created here.

CREATE TABLE IF NOT EXISTS ilb_psoriasis_episode (
  episode_id VARCHAR(96) PRIMARY KEY,
  subject_key VARCHAR(255) NOT NULL,
  opened_at DATETIME(6) NOT NULL,
  closed_at DATETIME(6) NULL,
  phenotype_code VARCHAR(64) NULL,
  severity_class VARCHAR(64) NULL,
  episode_status ENUM('INTAKE','BASELINE','PLAN','ACTIVE','FOLLOWUP','CLOSED','URGENT_EXIT') NOT NULL DEFAULT 'INTAKE',
  formula_version VARCHAR(64) NOT NULL DEFAULT 'P115',
  primitive_version VARCHAR(64) NOT NULL DEFAULT 'P116',
  notes TEXT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_psoriasis_safety_screen (
  safety_screen_id VARCHAR(96) PRIMARY KEY,
  episode_id VARCHAR(96) NOT NULL,
  screened_at DATETIME(6) NOT NULL,
  generalized_pustular_flag TINYINT(1) NOT NULL DEFAULT 0,
  erythrodermic_flag TINYINT(1) NOT NULL DEFAULT 0,
  infection_signal_flag TINYINT(1) NOT NULL DEFAULT 0,
  psoriatic_arthritis_signal_flag TINYINT(1) NOT NULL DEFAULT 0,
  urgent_exit_required TINYINT(1) NOT NULL DEFAULT 0,
  disposition ENUM('CONTINUE','CLINICIAN_REVIEW','URGENT_MEDICAL_ASSESSMENT') NOT NULL,
  rationale TEXT NOT NULL,
  CONSTRAINT fk_p117_safety_episode FOREIGN KEY (episode_id) REFERENCES ilb_psoriasis_episode(episode_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_psoriasis_baseline_state (
  baseline_id VARCHAR(96) PRIMARY KEY,
  episode_id VARCHAR(96) NOT NULL,
  measured_at DATETIME(6) NOT NULL,
  pasi DECIMAL(12,4) NULL,
  bsa_percent DECIMAL(12,4) NULL,
  itch_nrs DECIMAL(12,4) NULL,
  dlqi DECIMAL(12,4) NULL,
  lesion_area_m2 DECIMAL(24,12) NULL,
  epidermal_thickness_m DECIMAL(24,12) NULL,
  tewl_g_m2_h DECIMAL(24,12) NULL,
  target_plaque_area_cm2 DECIMAL(24,12) NULL,
  standard_photo_ref TEXT NULL,
  baseline_complete TINYINT(1) NOT NULL DEFAULT 0,
  provenance_note TEXT NULL,
  CONSTRAINT fk_p117_baseline_episode FOREIGN KEY (episode_id) REFERENCES ilb_psoriasis_episode(episode_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_psoriasis_intervention_plan (
  plan_id VARCHAR(96) PRIMARY KEY,
  episode_id VARCHAR(96) NOT NULL,
  created_at DATETIME(6) NOT NULL,
  plan_status ENUM('DRAFT','APPROVED','ACTIVE','STOPPED','COMPLETED') NOT NULL DEFAULT 'DRAFT',
  plan_objective TEXT NOT NULL,
  direct_non_drug_reference VARCHAR(160) NULL,
  clinician_review_required TINYINT(1) NOT NULL DEFAULT 1,
  CONSTRAINT fk_p117_plan_episode FOREIGN KEY (episode_id) REFERENCES ilb_psoriasis_episode(episode_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_psoriasis_intervention_plan_item (
  plan_item_id VARCHAR(96) PRIMARY KEY,
  plan_id VARCHAR(96) NOT NULL,
  modality_code VARCHAR(96) NOT NULL,
  target_node_code VARCHAR(96) NULL,
  action_class VARCHAR(64) NOT NULL,
  directness ENUM('DIRECT','INDIRECT','HYPOTHESIS','VERIFICATION_ONLY') NOT NULL,
  evidence_status VARCHAR(48) NOT NULL,
  intended_direction VARCHAR(64) NULL,
  measurement_endpoint VARCHAR(160) NOT NULL,
  biological_claim_boundary TEXT NOT NULL,
  start_at DATETIME(6) NULL,
  stop_at DATETIME(6) NULL,
  CONSTRAINT fk_p117_planitem_plan FOREIGN KEY (plan_id) REFERENCES ilb_psoriasis_intervention_plan(plan_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_psoriasis_model_prediction (
  prediction_id VARCHAR(96) PRIMARY KEY,
  episode_id VARCHAR(96) NOT NULL,
  predicted_at DATETIME(6) NOT NULL,
  horizon_days DECIMAL(12,4) NULL,
  endpoint_code VARCHAR(96) NOT NULL,
  predicted_value DECIMAL(30,12) NULL,
  unit VARCHAR(64) NULL,
  formula_stage_code VARCHAR(96) NOT NULL,
  primitive_readiness ENUM('READY','PARTIAL','BLOCKED') NOT NULL,
  blocked_reason TEXT NULL,
  CONSTRAINT fk_p117_prediction_episode FOREIGN KEY (episode_id) REFERENCES ilb_psoriasis_episode(episode_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_psoriasis_outcome_checkpoint (
  checkpoint_id VARCHAR(96) PRIMARY KEY,
  episode_id VARCHAR(96) NOT NULL,
  observed_at DATETIME(6) NOT NULL,
  pasi DECIMAL(12,4) NULL,
  bsa_percent DECIMAL(12,4) NULL,
  itch_nrs DECIMAL(12,4) NULL,
  dlqi DECIMAL(12,4) NULL,
  lesion_area_m2 DECIMAL(24,12) NULL,
  epidermal_thickness_m DECIMAL(24,12) NULL,
  tewl_g_m2_h DECIMAL(24,12) NULL,
  target_plaque_area_cm2 DECIMAL(24,12) NULL,
  standard_photo_ref TEXT NULL,
  adverse_event_flag TINYINT(1) NOT NULL DEFAULT 0,
  CONSTRAINT fk_p117_checkpoint_episode FOREIGN KEY (episode_id) REFERENCES ilb_psoriasis_episode(episode_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_psoriasis_prediction_verification (
  verification_id VARCHAR(96) PRIMARY KEY,
  prediction_id VARCHAR(96) NOT NULL,
  checkpoint_id VARCHAR(96) NOT NULL,
  observed_value DECIMAL(30,12) NULL,
  predicted_value DECIMAL(30,12) NULL,
  residual DECIMAL(30,12) NULL,
  absolute_error DECIMAL(30,12) NULL,
  relative_error DECIMAL(30,12) NULL,
  verification_status ENUM('PENDING','CONSISTENT','INCONSISTENT','NOT_COMPARABLE') NOT NULL DEFAULT 'PENDING',
  interpretation TEXT NULL,
  CONSTRAINT fk_p117_ver_prediction FOREIGN KEY (prediction_id) REFERENCES ilb_psoriasis_model_prediction(prediction_id),
  CONSTRAINT fk_p117_ver_checkpoint FOREIGN KEY (checkpoint_id) REFERENCES ilb_psoriasis_outcome_checkpoint(checkpoint_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_psoriasis_project_gate (
  gate_code VARCHAR(96) PRIMARY KEY,
  gate_order INT NOT NULL,
  gate_name VARCHAR(160) NOT NULL,
  gate_status ENUM('PASS','PARTIAL','BLOCKED','FAIL') NOT NULL,
  reason_text TEXT NOT NULL,
  evidence_ref TEXT NULL,
  checked_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO ilb_psoriasis_project_gate(gate_code,gate_order,gate_name,gate_status,reason_text,evidence_ref) VALUES
('P117-G01',1,'Encyclopedia architecture','PASS','Phenotype, biology, pathways, treatments, modalities, safety and measurement architecture exists.','Phase 106'),
('P117-G02',2,'Genetic-to-modifiable pathway','PASS','Fixed genetic susceptibility is separated from modifiable biological state.','Phase 107'),
('P117-G03',3,'Formula structure','PASS','End-to-end formula chain from IL-17 mass balance through plaque geometry and resolution conditions is structurally complete.','Phases 108-115'),
('P117-G04',4,'Primitive numeric closure','PARTIAL','Primitive registry exists; some context-specific values are sourced, but several kinetic and person-specific primitives remain unresolved or measurement-required.','Phase 116'),
('P117-G05',5,'Verification isolation','PASS','External modality workbooks are verification-only unless an independent mechanism is derived.','Phase 109'),
('P117-G06',6,'Patient execution flow','PASS','Episode, safety, baseline, plan, prediction, checkpoint and residual-verification orchestration is implemented.','Phase 117'),
('P117-G07',7,'Universal alternate cure claim','BLOCKED','No universal alternate cure has been established and no such claim is permitted.','Evidence governance'),
('P117-G08',8,'Production database verification','BLOCKED','Repository architecture is complete but production/GCP synchronization must be independently verified.','Deployment proof required')
ON DUPLICATE KEY UPDATE gate_status=VALUES(gate_status),reason_text=VALUES(reason_text),evidence_ref=VALUES(evidence_ref),checked_at=CURRENT_TIMESTAMP;

CREATE OR REPLACE VIEW v_ilb_psoriasis_episode_readiness AS
SELECT e.episode_id,e.subject_key,e.episode_status,
  (SELECT COUNT(*) FROM ilb_psoriasis_safety_screen s WHERE s.episode_id=e.episode_id) AS safety_screens,
  (SELECT COUNT(*) FROM ilb_psoriasis_baseline_state b WHERE b.episode_id=e.episode_id AND b.baseline_complete=1) AS complete_baselines,
  (SELECT COUNT(*) FROM ilb_psoriasis_intervention_plan p WHERE p.episode_id=e.episode_id AND p.plan_status IN ('APPROVED','ACTIVE','COMPLETED')) AS governed_plans,
  (SELECT COUNT(*) FROM ilb_psoriasis_model_prediction p WHERE p.episode_id=e.episode_id) AS predictions,
  (SELECT COUNT(*) FROM ilb_psoriasis_outcome_checkpoint c WHERE c.episode_id=e.episode_id) AS checkpoints,
  (SELECT COUNT(*) FROM ilb_psoriasis_prediction_verification v JOIN ilb_psoriasis_model_prediction p ON p.prediction_id=v.prediction_id WHERE p.episode_id=e.episode_id) AS verifications
FROM ilb_psoriasis_episode e;

CREATE OR REPLACE VIEW v_ilb_psoriasis_project_readiness AS
SELECT
  COUNT(*) AS gate_count,
  SUM(gate_status='PASS') AS pass_count,
  SUM(gate_status='PARTIAL') AS partial_count,
  SUM(gate_status='BLOCKED') AS blocked_count,
  SUM(gate_status='FAIL') AS fail_count,
  CASE
    WHEN SUM(gate_status='FAIL')>0 THEN 'FAIL'
    WHEN SUM(gate_status='BLOCKED')>0 THEN 'STRUCTURE_COMPLETE_EXECUTION_BLOCKED'
    WHEN SUM(gate_status='PARTIAL')>0 THEN 'EXECUTABLE_WITH_PARTIAL_NUMERIC_CLOSURE'
    ELSE 'END_TO_END_READY'
  END AS readiness_status
FROM ilb_psoriasis_project_gate;
