-- Phase 118: Psoriasis keratinocyte compartment correction
-- Scientific correction: keratinocytes are not a homogeneous proliferative pool.
-- KSC, ETA, LTA, differentiated and corneocyte compartments are modelled separately.
-- IL-17 response direction must be compartment/context specific; no universal positive proliferation coefficient is permitted.

CREATE TABLE IF NOT EXISTS ilb_psoriasis_keratinocyte_compartment (
  compartment_id VARCHAR(64) PRIMARY KEY,
  compartment_code VARCHAR(32) NOT NULL UNIQUE,
  compartment_name VARCHAR(160) NOT NULL,
  biological_role TEXT NOT NULL,
  proliferative_capacity VARCHAR(64) NOT NULL,
  differentiation_position INT NOT NULL,
  evidence_status VARCHAR(32) NOT NULL,
  notes TEXT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO ilb_psoriasis_keratinocyte_compartment
(compartment_id,compartment_code,compartment_name,biological_role,proliferative_capacity,differentiation_position,evidence_status,notes)
VALUES
('P118-KSC','KSC','Keratinocyte stem cell','Long-lived basal stem-cell compartment; self-renewal and production of early progenitors.','HIGH_SELF_RENEWAL_LOW_FREQUENCY',1,'SUPPORTED','Do not assume same IL-17 proliferation response as TA cells.'),
('P118-ETA','ETA','Early transit-amplifying keratinocyte','Early progenitor compartment with proliferative expansion and differentiation commitment.','TRANSIT_AMPLIFYING',2,'SUPPORTED','Recent human subpopulation work identifies distinct IL-17 receptor/expression behavior.'),
('P118-LTA','LTA','Late transit-amplifying keratinocyte','Later proliferative progenitor compartment approaching cell-cycle exit.','TRANSIT_AMPLIFYING',3,'SUPPORTED','Candidate compartment for disproportionate psoriatic expansion.'),
('P118-DIFF','DIFF','Viable differentiated keratinocyte','Post-mitotic viable differentiated epidermal compartment.','LOW/NONE',4,'ESTABLISHED','Feeds cornification.'),
('P118-CORN','CORN','Corneocyte','Cornified terminal compartment; removed by desquamation.','NONE',5,'ESTABLISHED','Barrier and shedding compartment.')
ON DUPLICATE KEY UPDATE biological_role=VALUES(biological_role),evidence_status=VALUES(evidence_status),notes=VALUES(notes);

CREATE TABLE IF NOT EXISTS ilb_psoriasis_compartment_response_rule (
  rule_id VARCHAR(80) PRIMARY KEY,
  compartment_code VARCHAR(32) NOT NULL,
  signal_code VARCHAR(64) NOT NULL,
  response_dimension VARCHAR(64) NOT NULL,
  direction VARCHAR(32) NOT NULL,
  evidence_status VARCHAR(32) NOT NULL,
  context_scope TEXT NOT NULL,
  claim_boundary TEXT NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO ilb_psoriasis_compartment_response_rule
(rule_id,compartment_code,signal_code,response_dimension,direction,evidence_status,context_scope,claim_boundary)
VALUES
('P118-R1','KSC','IL17A','PROLIFERATION','CONTEXT_DEPENDENT','SUPPORTED','Isolated human KSC/ETA subpopulation study reports IL-17A and IL-17A/F can decrease KSC proliferation and promote cell-cycle block.','Do not assign a universal positive IL-17->KSC proliferation coefficient.'),
('P118-R2','KSC','IL17A','DIFFERENTIATION_PROGRAM','MODULATES','SUPPORTED','Human keratinocyte subpopulation studies.','Direction depends on marker, ligand and compartment.'),
('P118-R3','ETA','IL17A','INFLAMMATORY_PROGRAM','INCREASES','SUPPORTED','CXCL1/CXCL8/DEFB4 response demonstrated in human KSC/ETA.','Inflammatory transcription response is not equivalent to net cell-number growth.'),
('P118-R4','ETA','IL17A','EPIDERMAL_THICKNESS','INCREASES_IN_3D_CONTEXT','SUPPORTED','KSC- and ETA-derived 3D reconstructions show increased epidermal thickness after IL-17A/IL-17A/F exposure.','Do not infer which transition rate changed without matched measurements.'),
('P118-R5','LTA','IL17_FAMILY','RECEPTOR_EXPRESSION','HETEROGENEOUS','SUPPORTED','IL-17 ligands/receptors vary across KSC, ETA and LTA.','Use compartment-specific receptor state.'),
('P118-R6','WHOLE_EPIDERMIS','IL17A','HYPERPLASIA','INCREASES','ESTABLISHED','Psoriatic lesions, standard keratinocyte systems, animal models and anti-IL-17 intervention data support epidermal hyperplasia/acanthosis linkage.','Whole-epidermis direction must not be copied blindly into every cellular compartment.')
ON DUPLICATE KEY UPDATE direction=VALUES(direction),evidence_status=VALUES(evidence_status),context_scope=VALUES(context_scope),claim_boundary=VALUES(claim_boundary);

CREATE TABLE IF NOT EXISTS ilb_psoriasis_compartment_equation (
  equation_code VARCHAR(64) PRIMARY KEY,
  compartment_code VARCHAR(32) NOT NULL,
  expression_text TEXT NOT NULL,
  interpretation TEXT NOT NULL,
  numeric_status VARCHAR(32) NOT NULL DEFAULT 'STRUCTURAL_ONLY'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO ilb_psoriasis_compartment_equation
(equation_code,compartment_code,expression_text,interpretation,numeric_status)
VALUES
('P118-EQ-KSC','KSC','dN_KSC/dt = r_KSC,self(S_KSC)*N_KSC - k_KSC_to_ETA*N_KSC - r_KSC,loss*N_KSC','Stem-cell population balance. S_KSC is compartment-specific signalling state, not generic IL-17 concentration.','STRUCTURAL_ONLY'),
('P118-EQ-ETA','ETA','dN_ETA/dt = k_KSC_to_ETA*N_KSC + r_ETA,self(S_ETA)*N_ETA - k_ETA_to_LTA*N_ETA - r_ETA,loss*N_ETA','Early transit-amplifying balance.','STRUCTURAL_ONLY'),
('P118-EQ-LTA','LTA','dN_LTA/dt = k_ETA_to_LTA*N_ETA + r_LTA,self(S_LTA)*N_LTA - k_LTA_to_DIFF*N_LTA - r_LTA,loss*N_LTA','Late transit-amplifying balance.','STRUCTURAL_ONLY'),
('P118-EQ-DIFF','DIFF','dN_DIFF/dt = k_LTA_to_DIFF*N_LTA - k_DIFF_to_CORN*N_DIFF - r_DIFF,loss*N_DIFF','Differentiated viable-cell balance.','STRUCTURAL_ONLY'),
('P118-EQ-CORN','CORN','dN_CORN/dt = k_DIFF_to_CORN*N_DIFF - r_shed*N_CORN','Terminal corneocyte balance.','STRUCTURAL_ONLY'),
('P118-EQ-GEOM','WHOLE_EPIDERMIS','h_epi = (N_KSC*v_KSC + N_ETA*v_ETA + N_LTA*v_LTA + N_DIFF*v_DIFF + N_CORN*v_CORN)/A_lesion','Compartment-resolved epidermal thickness.','STRUCTURAL_ONLY'),
('P118-EQ-EXCESS','WHOLE_EPIDERMIS','V_excess = A_lesion*max(h_epi-h_normal,0)','Physical plaque-excess endpoint retained.','STRUCTURAL_ONLY')
ON DUPLICATE KEY UPDATE expression_text=VALUES(expression_text),interpretation=VALUES(interpretation),numeric_status=VALUES(numeric_status);

CREATE OR REPLACE VIEW v_ilb_psoriasis_compartment_model_readiness AS
SELECT
  (SELECT COUNT(*) FROM ilb_psoriasis_keratinocyte_compartment) AS compartment_count,
  (SELECT COUNT(*) FROM ilb_psoriasis_compartment_response_rule) AS response_rule_count,
  (SELECT COUNT(*) FROM ilb_psoriasis_compartment_equation) AS equation_count,
  (SELECT COUNT(*) FROM ilb_psoriasis_compartment_response_rule WHERE direction='CONTEXT_DEPENDENT') AS context_dependent_rules,
  'COMPARTMENT_STRUCTURE_COMPLETE_NUMERIC_TRANSITIONS_PENDING' AS readiness_status;
