-- Phase 128: Psoriasis formula-first G7/G8 verification ledger
-- Governance: no human or patient outcome data may define, fit, calibrate, or activate these equations.
-- Inputs permitted here: derived equation structure, dimensions, conservation, limiting cases, and source-exact non-patient primitives.

START TRANSACTION;

CREATE TABLE IF NOT EXISTS ilb_psoriasis_formula_verification_test (
  test_id VARCHAR(32) PRIMARY KEY,
  stage_code VARCHAR(96) NOT NULL,
  test_type VARCHAR(48) NOT NULL,
  test_expression TEXT NOT NULL,
  expected_result TEXT NOT NULL,
  structural_result TEXT NOT NULL,
  verification_status ENUM('PASS','PASS_CONDITIONAL','BLOCKED','FAIL') NOT NULL,
  human_data_used TINYINT(1) NOT NULL DEFAULT 0,
  blocker_text TEXT NULL,
  next_action TEXT NULL,
  checked_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CHECK (human_data_used = 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_psoriasis_formula_lock_blocker (
  blocker_id VARCHAR(32) PRIMARY KEY,
  stage_code VARCHAR(96) NOT NULL,
  primitive_or_definition VARCHAR(255) NOT NULL,
  blocking_reason TEXT NOT NULL,
  closable_without_humans TINYINT(1) NOT NULL,
  current_decision VARCHAR(64) NOT NULL,
  lock_impact VARCHAR(64) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO ilb_psoriasis_formula_verification_test
(test_id,stage_code,test_type,test_expression,expected_result,structural_result,verification_status,human_data_used,blocker_text,next_action)
VALUES
('V001','GENETIC_STATE','DIMENSION','dG/dt and 0 have identical dimension','true','true','PASS',0,NULL,'LOCK_STRUCTURAL'),
('V002','IL17_BALANCE','DIMENSION','All RHS terms have dimension amount/time','true','Conditional on explicit J and R_bind unit contracts','PASS_CONDITIONAL',0,'J and R_bind exact unit contract','Define primitive unit contract'),
('V003','IL17_BALANCE','LIMIT','All production=0 and no influx implies dN/dt<=0 for k_deg>0','true','true','PASS',0,'k_deg numeric missing','Keep symbolic'),
('V004','IL17_BINDING','DIMENSION','k_on[L][R] and k_off[LR] have concentration/time','true','true','PASS',0,NULL,'LOCK_STRUCTURAL'),
('V005','IL17_BINDING','CONSERVATION','L+LR and R+LR conserved in closed binding-only subsystem','true','true','PASS',0,'External source/transport terms excluded from this subsystem','Document boundary'),
('V006','ACT1_SIGNAL','ZERO_INPUT','Upstream receptor signal=0 implies activation source terms=0','true','true by mass-action equation form','PASS',0,'Kinetic constants missing','Keep numeric open'),
('V007','G1S_GATE','DIMENSION','ln2/T_cycle*f_selfrenew has time^-1','true','true','PASS',0,NULL,'LOCK_STRUCTURAL'),
('V008','PROLIF_POOL','STABILITY','r_commit+r_apop_p>r_self implies decay of N_p','true','true','PASS',0,'Rates missing','Keep symbolic resolution condition'),
('V009','DIFF_POOL','BALANCE','Commitment is inflow; cornification/apoptosis are sinks','true','true','PASS',0,NULL,'LOCK_STRUCTURAL'),
('V010','CORNEOCYTE_POOL','LIMIT','N_d=0 and r_shed>0 implies monotone decrease of N_c','true','true','PASS',0,NULL,'LOCK_STRUCTURAL'),
('V011','DESQUAMATION','DIMENSION','r_shed reduces to time^-1','true','Not fully proven from current k_KLK/E_KLK/CDS symbol definitions','BLOCKED',0,'k_KLK, E_KLK, CDS unit definitions incomplete','Define exact enzymatic primitive units'),
('V012','BARRIER','LIMIT','D_water->0 or L_SC->infinity implies J_water->0','true','true','PASS',0,NULL,'LOCK_STRUCTURAL'),
('V013','BARRIER','NORMALIZATION','J_water=J_water_normal implies B=1','true','true','PASS',0,NULL,'LOCK_STRUCTURAL'),
('V014','GEOMETRY','DIMENSION','sum(N_i*v_i)/A has dimension length','true','true','PASS',0,NULL,'LOCK_STRUCTURAL'),
('V015','PLAQUE_VOLUME','NONNEGATIVITY','max(h-h_normal,0) implies V_excess>=0','true','true','PASS',0,NULL,'LOCK_STRUCTURAL'),
('V016','RESOLUTION','SIGN','Resolution inequalities each impose flux/rate toward lower plaque excess','true','true structurally','PASS',0,'Numeric rates missing','Keep as necessary conditions, not sufficient global proof')
ON DUPLICATE KEY UPDATE
  test_type=VALUES(test_type),test_expression=VALUES(test_expression),expected_result=VALUES(expected_result),
  structural_result=VALUES(structural_result),verification_status=VALUES(verification_status),human_data_used=0,
  blocker_text=VALUES(blocker_text),next_action=VALUES(next_action),checked_at=CURRENT_TIMESTAMP;

INSERT INTO ilb_psoriasis_formula_lock_blocker
(blocker_id,stage_code,primitive_or_definition,blocking_reason,closable_without_humans,current_decision,lock_impact)
VALUES
('B001','IL17_BALANCE','effective IL-17 loss/half-life in target compartment','Required for numeric k_deg',1,'OPEN_SOURCE','NUMERIC_LOCK_BLOCK'),
('B002','IL17_BINDING','matched IL-17RA/RC k_on and k_off','Required for transient occupancy kinetics',1,'OPEN_SOURCE','NUMERIC_LOCK_BLOCK'),
('B003','IL17_BINDING','absolute receptor abundance/density','Required for amount-based binding capacity',1,'OPEN_SOURCE','NUMERIC_LOCK_BLOCK'),
('B004','ACT1_SIGNAL','activation/deactivation constants and protein pools','Required for numeric signaling ODE',1,'OPEN_SOURCE','NUMERIC_LOCK_BLOCK'),
('B005','G1S_GATE','source-exact phase/gate kinetics','Required for numeric cell-cycle dynamics',1,'OPEN_SOURCE','NUMERIC_LOCK_BLOCK'),
('B006','PROLIF_POOL','r_commit and r_apop_p','Required for numeric proliferating pool',1,'OPEN_SOURCE','NUMERIC_LOCK_BLOCK'),
('B007','DIFF_POOL','r_corn and r_apop_d','Required for numeric differentiated pool',1,'OPEN_SOURCE','NUMERIC_LOCK_BLOCK'),
('B008','DESQUAMATION','k_KLK, E_KLK, CDS units and kinetic definition','Current equation not sufficiently dimensionally explicit to lock',1,'OPEN_DEFINITION','STRUCTURAL_LOCK_BLOCK'),
('B009','BARRIER','L_SC, D_water, K_part, DeltaC','Required for numeric water flux',1,'OPEN_SOURCE','NUMERIC_LOCK_BLOCK'),
('B010','GEOMETRY','cell volumes/counts and lesion area','Required for numeric geometry; real-person values remain prohibited',1,'OPEN_SOURCE_OR_SYMBOLIC','NUMERIC_LOCK_BLOCK'),
('B011','OPTIONAL_FIBROBLAST','fibroblast/NNMT decay','Open science gap',0,'KEEP_NULL','DO_NOT_BLOCK_CORE_SKIN_CHAIN'),
('B012','OPTIONAL_CROSSSYSTEM','a_x / Phi_insulin / Phi_LPS','No first-principles numeric closure yet',0,'KEEP_NULL','DO_NOT_BLOCK_CORE_CHAIN_IF_EXCLUDED')
ON DUPLICATE KEY UPDATE
  primitive_or_definition=VALUES(primitive_or_definition),blocking_reason=VALUES(blocking_reason),
  closable_without_humans=VALUES(closable_without_humans),current_decision=VALUES(current_decision),lock_impact=VALUES(lock_impact);

CREATE OR REPLACE VIEW v_ilb_psoriasis_formula_verification_summary AS
SELECT
  COUNT(*) AS tests_total,
  SUM(verification_status='PASS') AS tests_pass,
  SUM(verification_status='PASS_CONDITIONAL') AS tests_pass_conditional,
  SUM(verification_status='BLOCKED') AS tests_blocked,
  SUM(verification_status='FAIL') AS tests_fail,
  SUM(human_data_used<>0) AS human_data_violations,
  CASE
    WHEN SUM(human_data_used<>0)>0 THEN 'FAIL_HUMAN_DATA_GOVERNANCE'
    WHEN SUM(verification_status='FAIL')>0 THEN 'FAIL'
    WHEN SUM(verification_status='BLOCKED')>0 THEN 'PARTIAL_STRUCTURAL_VERIFICATION'
    ELSE 'STRUCTURAL_VERIFICATION_PASS'
  END AS verification_state
FROM ilb_psoriasis_formula_verification_test;

CREATE OR REPLACE VIEW v_ilb_psoriasis_formula_lock_readiness AS
SELECT
  SUM(lock_impact='STRUCTURAL_LOCK_BLOCK' AND current_decision NOT IN ('CLOSED','EXCLUDED')) AS structural_blockers,
  SUM(lock_impact='NUMERIC_LOCK_BLOCK' AND current_decision NOT IN ('CLOSED','EXCLUDED')) AS numeric_blockers,
  SUM(lock_impact LIKE 'DO_NOT_BLOCK%' AND current_decision='KEEP_NULL') AS frozen_optional_gaps,
  CASE
    WHEN SUM(lock_impact='STRUCTURAL_LOCK_BLOCK' AND current_decision NOT IN ('CLOSED','EXCLUDED'))>0 THEN 'STRUCTURAL_LOCK_BLOCKED'
    WHEN SUM(lock_impact='NUMERIC_LOCK_BLOCK' AND current_decision NOT IN ('CLOSED','EXCLUDED'))>0 THEN 'STRUCTURAL_LOCK_READY_NUMERIC_LOCK_BLOCKED'
    ELSE 'LOCK_READY'
  END AS lock_readiness
FROM ilb_psoriasis_formula_lock_blocker;

COMMIT;
