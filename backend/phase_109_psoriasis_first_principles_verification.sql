-- Phase 109: Psoriasis first-principles derivation + independent verification isolation
-- RULE: derivation first -> prediction -> verification. Verification datasets never supply model mechanisms or coefficients.

CREATE TABLE IF NOT EXISTS ilb_pso_primitive_quantity (
  primitive_id VARCHAR(64) PRIMARY KEY,
  symbol VARCHAR(64) NOT NULL,
  quantity_name VARCHAR(160) NOT NULL,
  unit_text VARCHAR(96) NOT NULL,
  source_class VARCHAR(32) NOT NULL,
  value_num DECIMAL(30,12) NULL,
  value_text VARCHAR(255) NULL,
  source_url TEXT NULL,
  context_note TEXT NOT NULL,
  governance_status VARCHAR(32) NOT NULL DEFAULT 'SOURCE_REQUIRED'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_pso_derivation_tree (
  derivation_id VARCHAR(64) PRIMARY KEY,
  derived_symbol VARCHAR(64) NOT NULL,
  equation_text TEXT NOT NULL,
  primitive_dependencies TEXT NOT NULL,
  law_class VARCHAR(64) NOT NULL,
  dimensional_rule TEXT NOT NULL,
  biological_scope TEXT NOT NULL,
  derivation_status VARCHAR(32) NOT NULL,
  source_note TEXT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_pso_reaction_law (
  reaction_id VARCHAR(64) PRIMARY KEY,
  reaction_name VARCHAR(160) NOT NULL,
  reaction_text TEXT NOT NULL,
  governing_equation TEXT NOT NULL,
  parameter_derivation TEXT NOT NULL,
  output_symbol VARCHAR(64) NOT NULL,
  evidence_status VARCHAR(32) NOT NULL,
  rule_note TEXT NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_pso_verification_dataset (
  dataset_id VARCHAR(64) PRIMARY KEY,
  dataset_name VARCHAR(180) NOT NULL,
  modality_code VARCHAR(64) NULL,
  source_file_name VARCHAR(255) NULL,
  role_class VARCHAR(32) NOT NULL DEFAULT 'VERIFICATION_ONLY',
  may_supply_coefficients TINYINT(1) NOT NULL DEFAULT 0,
  may_supply_mechanism TINYINT(1) NOT NULL DEFAULT 0,
  allowed_fields TEXT NOT NULL,
  forbidden_fields TEXT NOT NULL,
  governance_note TEXT NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_pso_prediction_verification (
  verification_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  dataset_id VARCHAR(64) NOT NULL,
  subject_ref VARCHAR(128) NULL,
  observation_time DATETIME NULL,
  endpoint_code VARCHAR(64) NOT NULL,
  predicted_value DECIMAL(30,12) NULL,
  observed_value DECIMAL(30,12) NULL,
  unit_text VARCHAR(64) NULL,
  residual_value DECIMAL(30,12) GENERATED ALWAYS AS (CASE WHEN predicted_value IS NULL OR observed_value IS NULL THEN NULL ELSE observed_value-predicted_value END) STORED,
  verification_status VARCHAR(32) NOT NULL DEFAULT 'PENDING',
  interpretation_note TEXT NULL,
  CONSTRAINT fk_pso_verify_dataset FOREIGN KEY (dataset_id) REFERENCES ilb_pso_verification_dataset(dataset_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO ilb_pso_derivation_tree
(derivation_id,derived_symbol,equation_text,primitive_dependencies,law_class,dimensional_rule,biological_scope,derivation_status,source_note)
VALUES
('DER-DECAY','k_deg','k_deg = LN(2) / t_half','t_half','FIRST_ORDER_DECAY','[time^-1] = 1/[time]','Cytokine/protein loss where first-order decay is justified','FORMULA_READY','Primitive half-life must be sourced for the exact molecule/compartment'),
('DER-BIND-KD','K_D','K_D = k_off / k_on','k_off,k_on','MASS_ACTION','[concentration] = [time^-1] / [concentration^-1 time^-1]','Ligand-receptor equilibrium','FORMULA_READY','Use exact ligand/receptor pair and assay context'),
('DER-OCC','theta','theta = L / (K_D + L)','L,K_D','LANGMUIR_OCCUPANCY','dimensionless','Single-site receptor occupancy approximation','FORMULA_READY','Only where binding assumptions apply'),
('DER-FICK','J','J = -D_diff * dC_dx','D_diff,dC_dx','FICK_FIRST_LAW','[amount area^-1 time^-1]','Skin/tissue molecular transport','FORMULA_READY','Geometry and concentration gradient required'),
('DER-FLUX','n_dot','n_dot = J * A','J,A','CONSERVATION_FLUX','[amount time^-1]','Transport across defined tissue area','FORMULA_READY','Area must be measured/derived'),
('DER-CELL-DIV','r_cycle','r_cycle = LN(2) / T_cycle','T_cycle','POPULATION_KINETICS','[time^-1]','Cycling-cell proliferation approximation','FORMULA_READY','T_cycle must refer to the correct epidermal cell pool'),
('DER-TEWL','J_water','J_water = m_water / (A * dt)','m_water,A,dt','FLUX_DEFINITION','[mass area^-1 time^-1]','Barrier verification via transepidermal water loss','FORMULA_READY','Measurement equation, not a causal psoriasis coefficient'),
('DER-ERROR','epsilon','epsilon = Y_observed - Y_predicted','Y_observed,Y_predicted','VERIFICATION_RESIDUAL','same unit as endpoint','Independent model verification','FORMULA_READY','Residual is verification only; never backfills a mechanism automatically')
ON DUPLICATE KEY UPDATE equation_text=VALUES(equation_text), derivation_status=VALUES(derivation_status);

INSERT INTO ilb_pso_reaction_law
(reaction_id,reaction_name,reaction_text,governing_equation,parameter_derivation,output_symbol,evidence_status,rule_note)
VALUES
('RXN-IL17R','IL-17 ligand receptor binding','L + R <-> LR','d[LR]/dt = k_on[L][R] - k_off[LR]','K_D=k_off/k_on; theta=L/(K_D+L)','LR','ESTABLISHED_PHYSICAL_LAW','Does not assert numeric IL-17 psoriasis kinetics until exact primitives are sourced'),
('RXN-CYT-DECAY','Cytokine first-order loss','C -> cleared','dC/dt = -k_deg*C','k_deg=LN(2)/t_half','C','CONDITIONAL','Apply only when first-order approximation is justified for that compartment'),
('RXN-KC-POP','Keratinocyte population balance','cycling -> division -> differentiation/loss','dN_K/dt = r_div*N_cycling - r_diff*N_K - r_loss*N_K','r_cycle=LN(2)/T_cycle; remaining rates require derivation trees','N_K','MODEL_STRUCTURE','No universal 36-hour coefficient; cell-pool context is mandatory'),
('RXN-BARRIER-WATER','Barrier water flux','water crosses stratum corneum','J_water = m_water/(A*dt)','Direct from measured mass flux, area and time','J_water','ESTABLISHED_MEASUREMENT','TEWL is an observed barrier endpoint, not proof of upstream mechanism')
ON DUPLICATE KEY UPDATE governing_equation=VALUES(governing_equation), rule_note=VALUES(rule_note);

INSERT INTO ilb_pso_verification_dataset
(dataset_id,dataset_name,modality_code,source_file_name,role_class,may_supply_coefficients,may_supply_mechanism,allowed_fields,forbidden_fields,governance_note)
VALUES
('VERIFY-HOMEO-001','Psoriasis Homeopathy Mathematics v1.0','HOMEOPATHY','ILMB_Psoriasis_Homeopathy_Mathematics_v1.0 (2).xlsx','VERIFICATION_ONLY',0,0,
'PASI, BSA where present, itch, pain/burning, sleep, DLQI, nail/joint outcome fields, time-series outcomes, N-of-1 observed endpoints',
'remedy scoring, repertory weights, similarity scores, potency assumptions, mechanism claims, remedy-to-cytokine links as model inputs',
'Independent external verification only. The homeopathy workbook cannot create or calibrate psoriasis biological coefficients or mechanisms.')
ON DUPLICATE KEY UPDATE role_class='VERIFICATION_ONLY',may_supply_coefficients=0,may_supply_mechanism=0;

CREATE OR REPLACE VIEW v_ilb_pso_phase109_readiness AS
SELECT
 (SELECT COUNT(*) FROM ilb_pso_derivation_tree) AS derivations,
 (SELECT COUNT(*) FROM ilb_pso_reaction_law) AS reaction_laws,
 (SELECT COUNT(*) FROM ilb_pso_verification_dataset WHERE role_class='VERIFICATION_ONLY') AS verification_datasets,
 (SELECT COUNT(*) FROM ilb_pso_verification_dataset WHERE may_supply_coefficients<>0 OR may_supply_mechanism<>0) AS isolation_violations,
 CASE WHEN
   (SELECT COUNT(*) FROM ilb_pso_derivation_tree) >= 8
   AND (SELECT COUNT(*) FROM ilb_pso_reaction_law) >= 4
   AND (SELECT COUNT(*) FROM ilb_pso_verification_dataset WHERE role_class='VERIFICATION_ONLY') >= 1
   AND (SELECT COUNT(*) FROM ilb_pso_verification_dataset WHERE may_supply_coefficients<>0 OR may_supply_mechanism<>0) = 0
 THEN 'FORMULA_FIRST_READY' ELSE 'NOT_READY' END AS readiness_status;
