-- Phase 128: Psoriasis 140-modality formula registry
-- Governance: formula-first. Human outcomes cannot create formula terms or coefficients.
-- Generated from ILMB_PSORIASIS_END_TO_END_MASTER_v5.0_140_FORMULA_REGISTRY.xlsx

CREATE TABLE IF NOT EXISTS ilb_psoriasis_formula_family (
  formula_family_id VARCHAR(16) PRIMARY KEY,
  formula_family VARCHAR(96) NOT NULL,
  physical_abstraction VARCHAR(255) NOT NULL,
  canonical_equation TEXT NOT NULL,
  used_for TEXT NULL,
  human_data_allowed_pre_formula TINYINT(1) NOT NULL DEFAULT 0,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_psoriasis_modality_formula (
  modality_key VARCHAR(32) PRIMARY KEY,
  modality_name VARCHAR(190) NOT NULL,
  modality_family VARCHAR(96) NOT NULL,
  input_class VARCHAR(96) NULL,
  formula_family_ids VARCHAR(255) NOT NULL,
  input_equation TEXT NULL,
  body_coordinate TEXT NULL,
  immediate_target TEXT NULL,
  state_response_equation TEXT NULL,
  required_primitives TEXT NULL,
  closure_status VARCHAR(64) NOT NULL,
  human_data_used TINYINT(1) NOT NULL DEFAULT 0,
  formula_record_status ENUM('FORMULA_PRESENT','FORMULA_NULL_BY_GOVERNANCE') NOT NULL,
  computation_eligible TINYINT(1) NOT NULL DEFAULT 0,
  governance_note TEXT NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_psoriasis_formula_null_reason (
  modality_key VARCHAR(32) PRIMARY KEY,
  null_reason TEXT NOT NULL,
  required_before_formula TEXT NOT NULL,
  governance_status VARCHAR(64) NOT NULL DEFAULT 'LOCKED_NULL',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_p128_null_modality FOREIGN KEY (modality_key)
    REFERENCES ilb_psoriasis_modality_formula(modality_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO ilb_psoriasis_formula_family
(formula_family_id,formula_family,physical_abstraction,canonical_equation,used_for,human_data_allowed_pre_formula)
VALUES
('FF01','RECEPTOR_BINDING','L+R↔LR','d[LR]/dt=k_on[L][R]-k_off[LR]; K_D=k_off/k_on','Ligand/receptor binding; biologics/hormones/defined chemicals',0),
('FF02','ENZYME_INHIBITION','E+I↔EI','v=v_max[S]/(K_m(1+[I]/K_i)+[S]) for competitive inhibition when mechanism matches','Defined small molecules / enzyme inhibitors',0),
('FF03','MASS_BALANCE','state input-output','dX/dt=ΣJ_in-ΣJ_out','Cytokines, hormones, metabolites, cells, microbial products',0),
('FF04','RADIANT_EXPOSURE','dose=irradiance×time','D_λ=∫E_λ(t)dt','UVB/UVA/excimer/laser/light',0),
('FF05','PHOTOCHEM_RESPONSE','photon→damage state','dQ/dt=J_photo(D_λ,q)-J_repair(Q)','UV/light response functions; coefficients context-specific',0),
('FF06','FICK_DIFFUSION','diffusion','J=-D∂C/∂x; slab J=DKΔC/L','Barrier, topical transport, gases',0),
('FF07','ACID_BASE','proton activity','pH=-log10(a_H+); buffer equilibria via mass action','Skin/gut/body-compartment pH',0),
('FF08','ELECTRICAL_MEMBRANE','membrane current','C_m dV_m/dt=-ΣI_ion+I_ext','TENS, electroacupuncture, neural/keratinocyte electrical state',0),
('FF09','ION_FLUX','ion balance','dC_i/dt=ΣJ_in-ΣJ_out','Ca²⁺/Na⁺/K⁺/Cl⁻ state',0),
('FF10','MECHANICS','stress/strain','σ=F/A; ε=ΔL/L; tissue response=F(σ,ε,t)','Acupuncture, massage, cupping, trauma',0),
('FF11','PRESSURE_FLOW','pressure/flow','ΔP=P_ext-P_tissue; Q=ΔP/R_h','Cupping/hydrostatic/vascular effects',0),
('FF12','HEAT_TRANSFER','thermal','ρc_p∂T/∂t=k∇²T+q̇','Heat/cold/moxa/sauna',0),
('FF13','GAS_DISSOLUTION','gas/pressure','C=H_p P; diffusion by Fick','Oxygen/HBOT/breathing',0),
('FF14','ENERGY_BALANCE','metabolic energy','dE_store/dt=E_in-E_out','Diet/fasting/exercise',0),
('FF15','SUBSTRATE_COMPETITION','metabolic substrate','v_i follows enzyme kinetics with competing substrates','EPA/AA/eicosanoids',0),
('FF16','MICROBIAL_ECOLOGY','population/ecology','dN_i/dt=g_i(N,S,environment)-loss_i','Pro/pre/synbiotics; strain-specific',0),
('FF17','NEURAL_RELEASE','neurotransmitter','dN_tx/dt=J_release(f_nerve)-k_clear N_tx','CGRP, NE, neuroimmune state',0),
('FF18','CELL_POPULATION','cell pools','dN/dt=birth-transition-apoptosis-loss','Keratinocyte and immune cell states',0),
('FF19','PROTEOLYSIS','cleavage/shedding','J_cleave=F(pH,E,I,S); r_shed=J_cleave/B_pool','Desquamation / KLK / CDSN',0),
('FF20','GEOMETRY','tissue geometry','V=ΣN_i v_i; h=V/A; V_excess=A max(h-h_ref,0)','Plaque geometry',0),
('FF21','CONTROL_STATE','neural/cognitive control','dS/dt=F(input,state)-loss','CBT/meditation/EMDR/sleep: structure only until measurable transfer function exists',0),
('FF22','MIXTURE_DECOMPOSITION','mixture/formula','Intervention=Σ constituents c_i with route-specific PK/PD/transport','Herbal/TCM/Ayurveda/Unani/Siddha/aromatherapy mixtures',0),
('FF23','UNRESOLVED_INPUT','unknown measurable input','NULL','Homeopathy/Pranic/Reiki/Bach/biofield claims when no independently measurable causal input is established',0)
ON DUPLICATE KEY UPDATE
 formula_family=VALUES(formula_family),
 physical_abstraction=VALUES(physical_abstraction),
 canonical_equation=VALUES(canonical_equation),
 used_for=VALUES(used_for),
 human_data_allowed_pre_formula=0;

-- The 140 governed modality rows are loaded from the v5.0 workbook through ILMB Excel staging.
-- This migration establishes the production contract and hard governance gate; workbook ingestion provides row payloads.

CREATE OR REPLACE VIEW v_ilb_psoriasis_modality_formula_coverage AS
SELECT
  COUNT(*) AS modality_count,
  SUM(formula_record_status='FORMULA_PRESENT') AS formula_present_count,
  SUM(formula_record_status='FORMULA_NULL_BY_GOVERNANCE') AS formula_null_count,
  SUM(human_data_used=1) AS human_derived_formula_count,
  SUM(computation_eligible=1) AS computation_eligible_count
FROM ilb_psoriasis_modality_formula;

CREATE OR REPLACE VIEW v_ilb_psoriasis_formula_nulls AS
SELECT
  m.modality_key,m.modality_name,m.modality_family,m.input_class,
  m.formula_family_ids,m.closure_status,n.null_reason,n.required_before_formula,
  m.computation_eligible
FROM ilb_psoriasis_modality_formula m
LEFT JOIN ilb_psoriasis_formula_null_reason n USING(modality_key)
WHERE m.formula_record_status='FORMULA_NULL_BY_GOVERNANCE';

CREATE OR REPLACE VIEW v_ilb_psoriasis_formula_ready AS
SELECT *
FROM ilb_psoriasis_modality_formula
WHERE formula_record_status='FORMULA_PRESENT'
  AND human_data_used=0;

CREATE OR REPLACE VIEW v_ilb_psoriasis_formula_governance AS
SELECT
  (SELECT COUNT(*) FROM ilb_psoriasis_modality_formula) AS modalities,
  (SELECT COUNT(*) FROM ilb_psoriasis_modality_formula WHERE formula_record_status='FORMULA_PRESENT') AS formulas_present,
  (SELECT COUNT(*) FROM ilb_psoriasis_modality_formula WHERE formula_record_status='FORMULA_NULL_BY_GOVERNANCE') AS governed_nulls,
  (SELECT COUNT(*) FROM ilb_psoriasis_modality_formula WHERE human_data_used=1) AS human_formula_violations,
  CASE
    WHEN (SELECT COUNT(*) FROM ilb_psoriasis_modality_formula WHERE human_data_used=1)=0 THEN 'PASS'
    ELSE 'FAIL'
  END AS no_human_formula_gate;
