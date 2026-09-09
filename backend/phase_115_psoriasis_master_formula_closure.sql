-- Phase 115: Psoriasis Master Formula Closure
-- Purpose: consolidate Phases 110-114 into one governed end-to-end formula registry.
-- Rule: DERIVE -> PREDICT -> VERIFY. No external verification dataset may supply mechanism or coefficients.

CREATE TABLE IF NOT EXISTS ilb_psoriasis_master_formula_stage (
  stage_no INT PRIMARY KEY,
  stage_code VARCHAR(64) NOT NULL UNIQUE,
  stage_name VARCHAR(160) NOT NULL,
  governing_equation TEXT NOT NULL,
  input_state TEXT NOT NULL,
  output_state TEXT NOT NULL,
  closure_status VARCHAR(48) NOT NULL,
  numeric_status VARCHAR(48) NOT NULL,
  source_phase VARCHAR(32) NOT NULL,
  governance_note TEXT NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_psoriasis_master_primitive (
  primitive_code VARCHAR(96) PRIMARY KEY,
  primitive_name VARCHAR(192) NOT NULL,
  symbol VARCHAR(96) NOT NULL,
  unit_text VARCHAR(96) NULL,
  primitive_class VARCHAR(64) NOT NULL,
  acquisition_rule VARCHAR(64) NOT NULL,
  value_numeric DECIMAL(30,12) NULL,
  source_reference TEXT NULL,
  context_requirement TEXT NOT NULL,
  source_phase VARCHAR(32) NOT NULL,
  status VARCHAR(48) NOT NULL DEFAULT 'UNRESOLVED',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_psoriasis_resolution_condition (
  condition_code VARCHAR(64) PRIMARY KEY,
  condition_name VARCHAR(160) NOT NULL,
  inequality_text TEXT NOT NULL,
  biological_meaning TEXT NOT NULL,
  status VARCHAR(48) NOT NULL,
  source_phase VARCHAR(32) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO ilb_psoriasis_master_formula_stage
(stage_no,stage_code,stage_name,governing_equation,input_state,output_state,closure_status,numeric_status,source_phase,governance_note)
VALUES
(1,'PSO-MF-01','Genetic susceptibility boundary','dG/dt = 0','genotype','fixed susceptibility','STRUCTURALLY_CLOSED','PERSON_SPECIFIC_INPUT','107','Genetics modifies susceptibility; it is not equated with active plaque.'),
(2,'PSO-MF-02','IL-17 production and mass balance','dN_IL17/dt = SUM(N_s*r_s) - k_deg*N_IL17 - J_out*A + J_in*A - R_bind','IL-17-producing cell populations and tissue transport','free IL-17 amount/concentration','STRUCTURALLY_CLOSED','PRIMITIVES_PENDING','110','Production, loss, transport and binding must each be independently sourced or derived.'),
(3,'PSO-MF-03','IL-17 decay','k_deg = ln(2)/t_half','matched compartment half-life','first-order decay constant','CLOSED_BY_IDENTITY','PRIMITIVE_PENDING','110','Half-life must match cytokine species and compartment.'),
(4,'PSO-MF-04','Tissue diffusion','J = -D*dC/dx','diffusion coefficient and concentration gradient','molecular flux','CLOSED_BY_FICKS_LAW','PRIMITIVES_PENDING','110','No fitted transport coefficient accepted when geometry and D are available.'),
(5,'PSO-MF-05','IL-17 receptor binding','dLR/dt = k_on*L*R - k_off*LR; K_D = k_off/k_on','free ligand and receptor','ligand-receptor complex','CLOSED_BY_MASS_ACTION','PRIMITIVES_PENDING','110','Antibody affinity may not substitute for receptor-ligand kinetics.'),
(6,'PSO-MF-06','Receptor occupancy','theta = L/(K_D + L); N_LR = theta*N_R_available','ligand concentration, KD, receptor abundance','occupied receptor count','CLOSED_UNDER_ONE_SITE_APPROX','PRIMITIVES_PENDING','110','Approximation valid only for matched binding assumptions.'),
(7,'PSO-MF-07','ACT1/TRAF6 signaling','dA/dt = k_Aon*LR*(A_tot-A)-k_Aoff*A; dT6/dt = k_T6on*A*(T6_tot-T6)-k_T6off*T6','occupied receptor complexes','ACT1/TRAF6 active states','STRUCTURALLY_CLOSED','PRIMITIVES_PENDING','112','Explicit reaction states; no free signaling weights.'),
(8,'PSO-MF-08','NF-kB/MAPK/YAP/EGFR signaling','mass-action/activation-deactivation balances for IKK, NF-kB, MAPK, YAP, AREG and EGFR','ACT1/TRAF6 state','cell-cycle signaling state','STRUCTURALLY_CLOSED','PRIMITIVES_PENDING','112','Mechanistic direction is represented; universal human kinetic values remain unresolved.'),
(9,'PSO-MF-09','G1/S restriction-point machinery','CyclinD -> CDK4/6 -> Rb_P -> E2F -> CyclinE/CDK2 -> S-entry','cell-cycle signaling state','S-phase entry hazard','STRUCTURALLY_CLOSED','PRIMITIVES_PENDING','113','No empirical signal-to-cycle multiplier accepted as final biology.'),
(10,'PSO-MF-10','Cell-cycle time','T_cycle = T_G1 + T_S + T_G2 + T_M; r_self = ln(2)/T_cycle*f_selfrenew','cell-cycle phase durations and self-renewal fraction','keratinocyte self-renewal rate','CLOSED_BY_TIME_BALANCE','PRIMITIVES_PENDING','113','Phase durations must match the relevant keratinocyte population/context.'),
(11,'PSO-MF-11','Keratinocyte population conservation','dNp/dt=(r_self-r_commit-r_apop,p)Np; dNd/dt=r_commit*Np-(r_corn+r_apop,d)Nd; dNc/dt=r_corn*Nd-r_shed*Nc','proliferation, commitment, cornification, apoptosis, shedding','cell population state','CLOSED_BY_POPULATION_BALANCE','PRIMITIVES_PENDING','111/114','Population terms are mechanistic rates, not free psoriasis coefficients.'),
(12,'PSO-MF-12','Cornification and desquamation','v_TGM=Vmax*S/(Km+S); v_cleave=k_KLK*E_KLK*CDS; r_shed=v_cleave/(CDS*Nc)','cornified-envelope substrate, protease activity, corneodesmosomes','cornification and shedding rates','STRUCTURALLY_CLOSED','PRIMITIVES_PENDING','114','Michaelis-Menten only where enzyme assumptions apply.'),
(13,'PSO-MF-13','Barrier transport','R_barrier=L_SC/(D_water*K_part); J_water=DeltaC_water/R_barrier; B=J_water/J_water,normal','stratum-corneum geometry and transport properties','water flux/barrier defect','CLOSED_BY_TRANSPORT_LAW','PRIMITIVES_PENDING','114','TEWL can verify predicted water flux but cannot generate unrelated immune coefficients.'),
(14,'PSO-MF-14','Epidermal geometry','V_epi=Np*v_p+Nd*v_d+Nc*v_c; h_epi=V_epi/A_lesion','cell counts, cell volumes, lesion area','epidermal thickness','CLOSED_BY_GEOMETRY','PERSON_GEOMETRY_PENDING','111/114','Cell volumes and lesion area must be measured or sourced for context.'),
(15,'PSO-MF-15','Physical plaque excess','V_excess=A_lesion*MAX(h_epi-h_normal,0)','epidermal thickness, normal thickness, lesion area','excess plaque volume','CLOSED_BY_GEOMETRY','PERSON_GEOMETRY_PENDING','114','Primary physical endpoint for formula prediction; PASI remains external clinical verification.'),
(16,'PSO-MF-16','Master normalization criterion','dV_excess/dt < 0 until h_epi -> h_normal','all upstream derived states','normalizing plaque state','STRUCTURALLY_CLOSED','PRIMITIVES_PENDING','114/115','This is a necessary physical normalization target, not a claim of cure or recurrence prevention.')
ON DUPLICATE KEY UPDATE
 stage_name=VALUES(stage_name), governing_equation=VALUES(governing_equation), input_state=VALUES(input_state), output_state=VALUES(output_state), closure_status=VALUES(closure_status), numeric_status=VALUES(numeric_status), source_phase=VALUES(source_phase), governance_note=VALUES(governance_note);

INSERT INTO ilb_psoriasis_resolution_condition
(condition_code,condition_name,inequality_text,biological_meaning,status,source_phase)
VALUES
('PSO-RC-01','Proliferating-pool contraction','r_commit + r_apop,p > r_self','Exit/loss from the proliferating pool exceeds self-renewal.','NECESSARY','114'),
('PSO-RC-02','Differentiated-pool contraction','(r_corn + r_apop,d)*Nd > r_commit*Np','Cornification/loss exceeds inflow from the proliferating pool.','NECESSARY','114'),
('PSO-RC-03','Corneocyte-pool contraction','r_shed*Nc > r_corn*Nd','Desquamation exceeds corneocyte generation.','NECESSARY','114'),
('PSO-RC-04','Plaque-volume regression','dV_excess/dt < 0','Physical excess epidermal/plaque volume is shrinking.','MASTER','114/115'),
('PSO-RC-05','Thickness normalization','h_epi -> h_normal','Predicted epidermal thickness approaches matched normal/reference thickness.','MASTER_TARGET','114/115')
ON DUPLICATE KEY UPDATE condition_name=VALUES(condition_name), inequality_text=VALUES(inequality_text), biological_meaning=VALUES(biological_meaning), status=VALUES(status), source_phase=VALUES(source_phase);

CREATE OR REPLACE VIEW v_ilb_psoriasis_master_formula_readiness AS
SELECT
  COUNT(*) AS formula_stages,
  SUM(CASE WHEN closure_status LIKE '%CLOSED%' OR closure_status='STRUCTURALLY_CLOSED' THEN 1 ELSE 0 END) AS structurally_closed_stages,
  SUM(CASE WHEN numeric_status IN ('PRIMITIVES_PENDING','PRIMITIVE_PENDING','PERSON_GEOMETRY_PENDING') THEN 1 ELSE 0 END) AS stages_awaiting_primitives,
  (SELECT COUNT(*) FROM ilb_psoriasis_resolution_condition) AS resolution_conditions,
  CASE
    WHEN COUNT(*) >= 16
     AND (SELECT COUNT(*) FROM ilb_psoriasis_resolution_condition) >= 5
    THEN 'STRUCTURAL_FORMULA_COMPLETE_NUMERIC_CLOSURE_PENDING'
    ELSE 'INCOMPLETE'
  END AS readiness_status
FROM ilb_psoriasis_master_formula_stage;
