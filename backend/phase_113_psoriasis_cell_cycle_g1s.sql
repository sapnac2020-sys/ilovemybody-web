-- Phase 113: Psoriasis cell-cycle G1/S first-principles bridge
-- Rule: no free fitted biology. Numeric values remain NULL until sourced or independently derived.

CREATE TABLE IF NOT EXISTS ilb_psoriasis_cellcycle_reaction (
  reaction_id VARCHAR(64) PRIMARY KEY,
  reaction_name VARCHAR(128) NOT NULL,
  upstream_state VARCHAR(128) NOT NULL,
  downstream_state VARCHAR(128) NOT NULL,
  equation_text TEXT NOT NULL,
  mechanism_status VARCHAR(32) NOT NULL,
  numeric_status VARCHAR(32) NOT NULL,
  source_note TEXT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_psoriasis_cellcycle_primitive (
  primitive_code VARCHAR(64) PRIMARY KEY,
  primitive_name VARCHAR(160) NOT NULL,
  unit_text VARCHAR(64) NULL,
  value_numeric DOUBLE NULL,
  source_status VARCHAR(32) NOT NULL DEFAULT 'UNSOURCED',
  context_requirement TEXT NOT NULL,
  may_be_fitted_as_final_biology TINYINT(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO ilb_psoriasis_cellcycle_reaction VALUES
('CC01','Cyclin D induction','EGFR_p/MAPK/YAP/NFkB','CyclinD','d[CD]/dt = k_CD_prod*F_signal - k_CD_deg*[CD]','SUPPORTED','STRUCTURE_ONLY','Psoriatic keratinocyte proliferation pathways support EGFR/MAPK/YAP involvement; universal human quantitative transfer not established'),
('CC02','Cyclin D-CDK4/6 assembly','CyclinD + CDK46','CD_CDK46','d[CD_CDK46]/dt = k_on_CD46*[CD]*[CDK46] - k_off_CD46*[CD_CDK46]','ESTABLISHED_CELL_CYCLE','STRUCTURE_ONLY','Mass-action assembly structure'),
('CC03','Rb phosphorylation','CD_CDK46 + Rb','RbP','d[RbP]/dt = k_Rb_phos*[CD_CDK46]*([Rb_tot]-[RbP]) - k_Rb_dephos*[RbP]','ESTABLISHED_CELL_CYCLE','STRUCTURE_ONLY','G1 restriction-point control'),
('CC04','E2F release','RbP','E2F_free','[E2F_free] = [E2F_tot] * [RbP]/(K_RbE2F + [RbP])','ESTABLISHED_CELL_CYCLE','STRUCTURE_ONLY','Saturable release approximation; K requires source'),
('CC05','Cyclin E induction','E2F_free','CyclinE','d[CE]/dt = k_CE_tx*[E2F_free] - k_CE_deg*[CE]','ESTABLISHED_CELL_CYCLE','STRUCTURE_ONLY','E2F-driven G1/S transcription'),
('CC06','Cyclin E-CDK2 assembly','CyclinE + CDK2','CE_CDK2','d[CE_CDK2]/dt = k_on_CE2*[CE]*[CDK2] - k_off_CE2*[CE_CDK2]','ESTABLISHED_CELL_CYCLE','STRUCTURE_ONLY','Mass-action assembly structure'),
('CC07','S-phase entry hazard','CE_CDK2','lambda_S','lambda_S = k_Sgate * H([CE_CDK2]-theta_S)','MODEL_BRIDGE','NOT_NUMERICALLY_CLOSED','Threshold/hazard form; threshold and scale cannot be invented'),
('CC08','G1 duration','lambda_S','T_G1','T_G1 = 1/lambda_S for memoryless hazard approximation','MODEL_BRIDGE','NOT_NUMERICALLY_CLOSED','Only valid if hazard approximation is accepted for matched context'),
('CC09','Total cycle time','T_G1,T_S,T_G2,T_M','T_cycle','T_cycle = T_G1 + T_S + T_G2 + T_M','IDENTITY','DERIVED','Exact phase-time sum'),
('CC10','Self-renewal rate','T_cycle','r_self','r_self = ln(2)/T_cycle * f_selfrenew','CONSERVATION_BRIDGE','NOT_NUMERICALLY_CLOSED','f_selfrenew must be independently specified from lineage/commitment balance');

INSERT INTO ilb_psoriasis_cellcycle_primitive
(primitive_code,primitive_name,unit_text,value_numeric,source_status,context_requirement,may_be_fitted_as_final_biology) VALUES
('k_CD_prod','Cyclin D production constant','state^-1 time^-1',NULL,'UNSOURCED','Human keratinocyte, matched signaling context',0),
('k_CD_deg','Cyclin D degradation constant','time^-1',NULL,'UNSOURCED','Human keratinocyte, matched protein half-life context',0),
('k_on_CD46','Cyclin D-CDK4/6 association constant',NULL,NULL,'UNSOURCED','Matched isoforms and biochemical conditions',0),
('k_off_CD46','Cyclin D-CDK4/6 dissociation constant','time^-1',NULL,'UNSOURCED','Matched isoforms and biochemical conditions',0),
('k_Rb_phos','Rb phosphorylation constant',NULL,NULL,'UNSOURCED','Matched CDK complex and substrate conditions',0),
('k_Rb_dephos','Rb dephosphorylation constant','time^-1',NULL,'UNSOURCED','Matched keratinocyte phosphatase context',0),
('K_RbE2F','RbP/E2F release half-saturation','concentration',NULL,'UNSOURCED','Human keratinocyte nuclear context',0),
('k_CE_tx','Cyclin E transcription/production constant',NULL,NULL,'UNSOURCED','Human keratinocyte E2F response context',0),
('k_CE_deg','Cyclin E degradation constant','time^-1',NULL,'UNSOURCED','Human keratinocyte matched phase context',0),
('k_on_CE2','Cyclin E-CDK2 association constant',NULL,NULL,'UNSOURCED','Matched proteins and biochemical conditions',0),
('k_off_CE2','Cyclin E-CDK2 dissociation constant','time^-1',NULL,'UNSOURCED','Matched proteins and biochemical conditions',0),
('theta_S','Cyclin E-CDK2 S-entry threshold','concentration',NULL,'UNSOURCED','Human keratinocyte G1/S context',0),
('k_Sgate','S-entry hazard scaling constant','time^-1',NULL,'UNSOURCED','Human keratinocyte matched context',0),
('T_S','S-phase duration','time',NULL,'UNSOURCED','Cycling human epidermal keratinocyte context',0),
('T_G2','G2 duration','time',NULL,'UNSOURCED','Cycling human epidermal keratinocyte context',0),
('T_M','M-phase duration','time',NULL,'UNSOURCED','Cycling human epidermal keratinocyte context',0),
('f_selfrenew','Fraction of divisions retained in proliferative pool','dimensionless',NULL,'UNSOURCED','Must come from lineage/commitment balance, not arbitrary fitting',0);

CREATE OR REPLACE VIEW v_ilb_psoriasis_cellcycle_readiness AS
SELECT
  COUNT(*) AS reaction_count,
  SUM(numeric_status='NOT_NUMERICALLY_CLOSED') AS unresolved_reactions,
  (SELECT COUNT(*) FROM ilb_psoriasis_cellcycle_primitive) AS primitive_count,
  (SELECT COUNT(*) FROM ilb_psoriasis_cellcycle_primitive WHERE value_numeric IS NOT NULL) AS populated_primitives,
  'DERIVED_STRUCTURE_NOT_NUMERICALLY_CLOSED' AS readiness_status
FROM ilb_psoriasis_cellcycle_reaction;
