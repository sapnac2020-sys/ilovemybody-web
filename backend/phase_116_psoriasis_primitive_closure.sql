-- Phase 116: Psoriasis primitive closure
-- Rule: DERIVE -> PREDICT -> VERIFY. No verification workbook may create biology or coefficients.

CREATE TABLE IF NOT EXISTS ilb_psoriasis_primitive_value (
  primitive_id VARCHAR(96) PRIMARY KEY,
  symbol VARCHAR(96) NOT NULL,
  quantity_name VARCHAR(160) NOT NULL,
  subsystem VARCHAR(64) NOT NULL,
  primitive_class VARCHAR(48) NOT NULL,
  numeric_value DECIMAL(30,12) NULL,
  unit VARCHAR(64) NULL,
  context_scope VARCHAR(255) NOT NULL,
  source_status VARCHAR(48) NOT NULL,
  source_citation TEXT NULL,
  may_use_as_universal_patient_constant TINYINT(1) NOT NULL DEFAULT 0,
  derivation_formula TEXT NULL,
  verification_only TINYINT(1) NOT NULL DEFAULT 0,
  notes TEXT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO ilb_psoriasis_primitive_value
(primitive_id,symbol,quantity_name,subsystem,primitive_class,numeric_value,unit,context_scope,source_status,source_citation,may_use_as_universal_patient_constant,derivation_formula,verification_only,notes)
VALUES
('P116-KD-IL17A-RA','K_D,IL17A:RA','IL-17A first-site affinity for IL-17RA','IL17_BINDING','SOURCED_CONTEXT_SPECIFIC',2.8,'nM','SPR, recombinant extracellular-domain construct; first receptor-binding event','SOURCED','Ely et al., Structural basis of receptor sharing by interleukin 17 cytokines',0,'K_D=k_off/k_on',0,'Do not treat as in-vivo patient constant without matching construct/context.'),
('P116-KD-IL17A-RC','K_D,IL17A:RC','IL-17A first-site affinity for IL-17RC','IL17_BINDING','SOURCED_CONTEXT_SPECIFIC',1.2,'nM','SPR, recombinant extracellular-domain construct; first receptor-binding event','SOURCED','Ely et al., Structural basis of receptor sharing by interleukin 17 cytokines',0,'K_D=k_off/k_on',0,'Do not treat as in-vivo patient constant without matching construct/context.'),
('P116-KD-IL17A-RA2','K_D,IL17A:RA2','Second IL-17RA binding event after IL-17A capture','IL17_BINDING','SOURCED_CONTEXT_SPECIFIC',3100,'nM','SPR stepwise second receptor-binding event','SOURCED','Ely et al., Structural basis of receptor sharing by interleukin 17 cytokines',0,'K_D=k_off/k_on',0,'Shows receptor assembly is not equivalent to a single one-site affinity.'),
('P116-KD-IL17A-RC2','K_D,IL17A:RC2','Second IL-17RC binding event after IL-17A capture','IL17_BINDING','SOURCED_CONTEXT_SPECIFIC',174,'nM','SPR stepwise second receptor-binding event after IL-17RA capture','SOURCED','Ely et al., Structural basis of receptor sharing by interleukin 17 cytokines',0,'K_D=k_off/k_on',0,'Context-specific assembly primitive.'),
('P116-TG1-NORMAL','T_G1','Normal human epidermal cycling-cell G1 duration','CELL_CYCLE','SOURCED_CONTEXT_SPECIFIC',7.6,'h','In-vivo IdUrd study, normal epidermal cycling population','SOURCED','Growth kinetics study PMID 8844104',0,NULL,1,'Verification/context only; not a universal psoriasis constant.'),
('P116-TS-NORMAL','T_S','Normal human epidermal cycling-cell S-phase duration','CELL_CYCLE','SOURCED_CONTEXT_SPECIFIC',9.7,'h','In-vivo IdUrd study, normal epidermal cycling population','SOURCED','Growth kinetics study PMID 8844104',0,NULL,1,'Verification/context only.'),
('P116-TG2M-NORMAL','T_G2M','Normal human epidermal cycling-cell G2/M duration','CELL_CYCLE','SOURCED_CONTEXT_SPECIFIC',11.1,'h','In-vivo IdUrd study, normal epidermal cycling population','SOURCED','Growth kinetics study PMID 8844104',0,NULL,1,'Verification/context only.'),
('P116-TCYCLE-NORMAL','T_cycle','Normal human epidermal cycling-cell total cycle duration','CELL_CYCLE','DERIVED_FROM_SOURCED',28.4,'h','Same in-vivo cycling population','DERIVED','PMID 8844104',0,'T_cycle=T_G1+T_S+T_G2+T_M (study reports combined G2M)',1,'Context only; population definition matters.'),
('P116-KDEG-IL17','k_deg,IL17','IL-17 effective first-order loss constant','IL17_MASS_BALANCE','DERIVABLE',NULL,'time^-1','Exact ligand and tissue compartment must match','UNRESOLVED',NULL,0,'k_deg=ln(2)/t_half',0,'Need matched IL-17A/F effective half-life in skin/interstitial context.'),
('P116-KON-IL17RA','k_on,IL17RA','IL-17A to IL-17RA association rate','IL17_BINDING','SOURCED_OR_DERIVABLE',NULL,'M^-1 s^-1','Exact SPR construct and temperature required','UNRESOLVED',NULL,0,NULL,0,'K_D alone does not determine k_on and k_off separately.'),
('P116-KOFF-IL17RA','k_off,IL17RA','IL-17A to IL-17RA dissociation rate','IL17_BINDING','SOURCED_OR_DERIVABLE',NULL,'s^-1','Exact SPR construct and temperature required','UNRESOLVED',NULL,0,'k_off=K_D*k_on',0,'Only derivable after matched k_on is sourced.'),
('P116-RECEPTOR-DENSITY','N_R/cell','Available IL-17 receptor abundance per keratinocyte','IL17_BINDING','PERSON_OR_TISSUE_MEASURED',NULL,'receptors/cell','Lesional keratinocyte, matched receptor subunit and state','MEASURE_REQUIRED',NULL,0,NULL,0,'Must distinguish IL-17RA and IL-17RC abundance/availability.'),
('P116-LESION-AREA','A_lesion','Lesion area','GEOMETRY','PERSON_MEASURED',NULL,'m^2','Patient lesion at time t','MEASURE_REQUIRED',NULL,0,NULL,0,'Can be derived from calibrated image/planimetry.'),
('P116-HEPI','h_epi','Epidermal thickness','GEOMETRY','PERSON_MEASURED',NULL,'m','Matched lesion at time t','MEASURE_REQUIRED',NULL,0,'h_epi=V_epi/A_lesion',0,'May be measured by histology/OCT where appropriate.'),
('P116-TEWL','J_water','Transepidermal water loss','BARRIER','PERSON_MEASURED',NULL,'g m^-2 h^-1','Same anatomical site, controlled ambient conditions','MEASURE_REQUIRED',NULL,0,'B=J_water/J_water,matched_normal',0,'Population TEWL studies are verification ranges only, not patient constants.'),
('P116-RCOMMIT','r_commit','Keratinocyte commitment/differentiation rate','KERATINOCYTE_POPULATION','DERIVABLE_IF_PHASE_TRANSITIONS_KNOWN',NULL,'time^-1','Matched epidermal compartment','UNRESOLVED',NULL,0,NULL,0,'Must be decomposed from transition-time/flux primitives; no fitted free coefficient.'),
('P116-RCORN','r_corn','Cornification transition rate','DIFFERENTIATION','DERIVABLE_IF_TRANSITION_TIME_KNOWN',NULL,'time^-1','Matched viable-to-corneocyte transition','UNRESOLVED',NULL,0,NULL,0,'Prefer transition-time derivation over regression.'),
('P116-RSHED','r_shed','Corneocyte shedding rate','DESQUAMATION','DERIVABLE_FROM_PROTEOLYSIS_AND_POOL',NULL,'time^-1','Matched stratum corneum site/state','UNRESOLVED',NULL,0,'r_shed=v_cleave/(CDS_per_cell*N_c)',0,'Psoriasis has altered CDSN/desmosomal proteolysis; numeric kinetic closure still unresolved.')
ON DUPLICATE KEY UPDATE numeric_value=VALUES(numeric_value), unit=VALUES(unit), context_scope=VALUES(context_scope), source_status=VALUES(source_status), notes=VALUES(notes);

CREATE OR REPLACE VIEW v_ilb_psoriasis_primitive_closure AS
SELECT
  COUNT(*) AS primitive_count,
  SUM(numeric_value IS NOT NULL AND verification_only=0) AS model_numeric_context_values,
  SUM(source_status='UNRESOLVED') AS unresolved_count,
  SUM(source_status='MEASURE_REQUIRED') AS measure_required_count,
  SUM(verification_only=1) AS verification_only_count,
  SUM(may_use_as_universal_patient_constant=1) AS universal_patient_constants
FROM ilb_psoriasis_primitive_value;
