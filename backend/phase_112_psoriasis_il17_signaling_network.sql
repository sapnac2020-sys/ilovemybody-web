-- Phase 112: Psoriasis IL-17 intracellular signaling network
-- Purpose: replace the black-box IL17 signal -> keratinocyte proliferation transfer with explicit reaction structure.
-- Rule: formula-first. No unsourced numeric constants.

CREATE TABLE IF NOT EXISTS ilb_pso112_reaction (
  reaction_id VARCHAR(64) PRIMARY KEY,
  reaction_name VARCHAR(160) NOT NULL,
  reaction_law VARCHAR(64) NOT NULL,
  equation_text TEXT NOT NULL,
  source_state VARCHAR(32) NOT NULL,
  biological_status VARCHAR(32) NOT NULL,
  notes TEXT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_pso112_primitive (
  primitive_id VARCHAR(64) PRIMARY KEY,
  symbol VARCHAR(64) NOT NULL,
  meaning_text TEXT NOT NULL,
  unit_text VARCHAR(64) NULL,
  numeric_value DECIMAL(30,12) NULL,
  source_status VARCHAR(32) NOT NULL DEFAULT 'UNRESOLVED',
  context_requirement TEXT NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_pso112_state (
  state_id VARCHAR(64) PRIMARY KEY,
  symbol VARCHAR(64) NOT NULL,
  state_name VARCHAR(160) NOT NULL,
  layer_name VARCHAR(64) NOT NULL,
  measurement_route TEXT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO ilb_pso112_state(state_id,symbol,state_name,layer_name,measurement_route) VALUES
('S112-01','LR','Occupied IL-17 receptor complex','RECEPTOR','Ligand/receptor binding or occupancy assay'),
('S112-02','A','Active ACT1 complex','ADAPTOR','ACT1 recruitment/complex abundance'),
('S112-03','T6','Active TRAF6 complex','ADAPTOR','TRAF6 recruitment/ubiquitination state'),
('S112-04','IKK','Active IKK complex','KINASE','Phospho-IKK or equivalent'),
('S112-05','NFkB','Nuclear active NF-kB','TRANSCRIPTION','Nuclear p65/DNA binding/transcriptional activity'),
('S112-06','MAPK','Aggregate ERK/p38/JNK activity','KINASE','Phospho-ERK/p38/JNK, preferably separate channels'),
('S112-07','YAPn','Nuclear active YAP','TRANSCRIPTION','Nuclear YAP'),
('S112-08','AREG','Amphiregulin abundance','LIGAND','AREG protein/transcript'),
('S112-09','EGFRp','Activated EGFR','RECEPTOR','Phospho-EGFR'),
('S112-10','CC','Cell-cycle drive','CELL_CYCLE','Cyclin/CDK/Ki67/S-phase markers')
ON DUPLICATE KEY UPDATE state_name=VALUES(state_name),measurement_route=VALUES(measurement_route);

INSERT INTO ilb_pso112_reaction(reaction_id,reaction_name,reaction_law,equation_text,source_state,biological_status,notes) VALUES
('R112-01','IL17 receptor complex recruits ACT1','MASS_ACTION','dA/dt = k_A_on*LR*(A_tot-A) - k_A_off*A','RECEPTOR_OCCUPANCY','SUPPORTED','IL-17RA/RC recruits ACT1 via SEFIR interactions.'),
('R112-02','ACT1 recruits/activates TRAF6','MASS_ACTION','dT6/dt = k_T6_on*A*(T6_tot-T6) - k_T6_off*T6','ACT1','SUPPORTED','ACT1 functions as adaptor/docking platform for TRAF6.'),
('R112-03','TRAF6 activates IKK','ACTIVATION_DEACTIVATION','dIKK/dt = k_IKK_act*T6*(IKK_tot-IKK) - k_IKK_deact*IKK','TRAF6','SUPPORTED','TRAF6 contributes to IKK/NF-kB activation.'),
('R112-04','IKK releases NF-kB activity','ACTIVATION_DEACTIVATION','dNFkB/dt = k_NF_act*IKK*(NF_tot-NFkB) - k_NF_off*NFkB','IKK','SUPPORTED','Simplified conservation form; exact intermediates include IkB turnover.'),
('R112-05','ACT1/TRAF network activates MAPKs','ACTIVATION_DEACTIVATION','dMAPK/dt = k_MAPK_act*T6*(MAPK_tot-MAPK) - k_MAPK_off*MAPK','TRAF6','SUPPORTED','ERK, p38 and JNK should be split when primitives are available.'),
('R112-06','IL17-associated signaling raises nuclear YAP activity','ACTIVATION_DEACTIVATION','dYAPn/dt = k_YAP_act*S_IL17*(YAP_tot-YAPn) - k_YAP_off*YAPn','IL17_SIGNAL','SUPPORTED_LIMITED','YAP/AREG axis is associated with psoriatic keratinocyte proliferation; exact direct transfer law is not established.'),
('R112-07','YAP drives AREG production','PRODUCTION_DECAY','dAREG/dt = k_AREG_tx*YAPn - k_AREG_deg*AREG','YAP','SUPPORTED','AREG is a YAP transcriptional target in psoriasis models.'),
('R112-08','AREG activates EGFR','MASS_ACTION','dEGFRp/dt = k_EGFR_on*AREG*(EGFR_tot-EGFRp) - k_EGFR_off*EGFRp','AREG','SUPPORTED','AREG is an EGFR ligand; context-specific kinetics required.'),
('R112-09','Signaling network generates cell-cycle drive','CONSERVATION_INPUT_SUM','CC = w_NF*NFkB + w_M*MAPK + w_E*EGFRp','SIGNAL_INTEGRATION','NOT_NUMERICALLY_CLOSED','Weights are forbidden as free fitted coefficients; must be decomposed into molecular promoter/cyclin-control reactions or sourced transfer functions.'),
('R112-10','Cell-cycle drive maps to cycling rate','CELL_CYCLE','r_self = ln(2)/T_cycle(CC)','CELL_CYCLE','NOT_NUMERICALLY_CLOSED','T_cycle(CC) remains the critical unresolved transfer function; no universal numeric law inserted.')
ON DUPLICATE KEY UPDATE equation_text=VALUES(equation_text),biological_status=VALUES(biological_status),notes=VALUES(notes);

INSERT INTO ilb_pso112_primitive(primitive_id,symbol,meaning_text,unit_text,numeric_value,source_status,context_requirement) VALUES
('P112-01','k_A_on','ACT1 recruitment association rate','context dependent',NULL,'UNRESOLVED','Human keratinocyte IL-17RA/RC-ACT1 construct/context'),
('P112-02','k_A_off','ACT1 complex dissociation rate','1/time',NULL,'UNRESOLVED','Matched receptor/adaptor context'),
('P112-03','k_T6_on','TRAF6 recruitment/activation rate','context dependent',NULL,'UNRESOLVED','Human keratinocyte ACT1-TRAF6 context'),
('P112-04','k_T6_off','TRAF6 complex deactivation/dissociation rate','1/time',NULL,'UNRESOLVED','Matched context'),
('P112-05','k_IKK_act','TRAF6 to IKK activation rate','context dependent',NULL,'UNRESOLVED','Human keratinocyte signaling context'),
('P112-06','k_IKK_deact','IKK deactivation rate','1/time',NULL,'UNRESOLVED','Matched context'),
('P112-07','k_NF_act','IKK to NF-kB activation rate','context dependent',NULL,'UNRESOLVED','Human keratinocyte context'),
('P112-08','k_NF_off','NF-kB deactivation/export rate','1/time',NULL,'UNRESOLVED','Human keratinocyte context'),
('P112-09','k_MAPK_act','TRAF6 to MAPK activation rate','context dependent',NULL,'UNRESOLVED','Prefer ERK/p38/JNK-specific constants'),
('P112-10','k_MAPK_off','MAPK deactivation rate','1/time',NULL,'UNRESOLVED','Prefer ERK/p38/JNK-specific constants'),
('P112-11','k_YAP_act','IL-17-associated YAP activation rate','context dependent',NULL,'UNRESOLVED','Exact causal route/context must be matched'),
('P112-12','k_YAP_off','YAP deactivation/export rate','1/time',NULL,'UNRESOLVED','Human keratinocyte context'),
('P112-13','k_AREG_tx','YAP-dependent AREG production rate','amount/time/state',NULL,'UNRESOLVED','Human keratinocyte transcription context'),
('P112-14','k_AREG_deg','AREG degradation/removal rate','1/time',NULL,'UNRESOLVED','Local epidermal context'),
('P112-15','k_EGFR_on','AREG-EGFR activation association constant','context dependent',NULL,'UNRESOLVED','Human keratinocyte EGFR context'),
('P112-16','k_EGFR_off','EGFR deactivation/dissociation rate','1/time',NULL,'UNRESOLVED','Matched context')
ON DUPLICATE KEY UPDATE meaning_text=VALUES(meaning_text),context_requirement=VALUES(context_requirement);

CREATE OR REPLACE VIEW v_ilb_pso112_readiness AS
SELECT
 (SELECT COUNT(*) FROM ilb_pso112_reaction) AS reactions,
 (SELECT COUNT(*) FROM ilb_pso112_state) AS states,
 (SELECT COUNT(*) FROM ilb_pso112_primitive) AS primitives,
 (SELECT COUNT(*) FROM ilb_pso112_primitive WHERE numeric_value IS NOT NULL) AS numeric_primitives,
 (SELECT COUNT(*) FROM ilb_pso112_reaction WHERE biological_status='NOT_NUMERICALLY_CLOSED') AS unresolved_transfer_steps,
 'DERIVED_REACTION_NETWORK_NOT_NUMERICALLY_CLOSED' AS readiness_status;
