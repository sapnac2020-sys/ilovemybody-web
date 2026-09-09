-- Phase 114b: Consolidated psoriasis first-principles master equation chain
-- This view joins the already-derived subsystems conceptually; it does not invent missing kinetics.

CREATE TABLE IF NOT EXISTS ilb_psoriasis_master_equation_stage (
  stage_no INT PRIMARY KEY,
  stage_code VARCHAR(64) NOT NULL UNIQUE,
  stage_name VARCHAR(160) NOT NULL,
  governing_expression TEXT NOT NULL,
  closure_status VARCHAR(48) NOT NULL,
  unresolved_inputs TEXT NULL,
  verification_endpoint TEXT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO ilb_psoriasis_master_equation_stage
(stage_no,stage_code,stage_name,governing_expression,closure_status,unresolved_inputs,verification_endpoint)
VALUES
(1,'GENETIC_STATE','Fixed genetic susceptibility','dG/dt = 0','STRUCTURALLY_CLOSED','variant effect context','genotype only'),
(2,'IL17_BALANCE','IL-17 production / loss / transport','dN_IL17/dt = SUM(N_s*r_s) - (ln2/t_half)*N_IL17 - J_out*A + J_in*A - R_bind','STRUCTURALLY_CLOSED','N_s,r_s,t_half,D,gradC,A','lesional IL-17 / pathway readouts'),
(3,'IL17_BINDING','IL-17 receptor binding','d[LR]/dt = k_on[L][R] - k_off[LR]; K_D=k_off/k_on; theta=[L]/(K_D+[L])','STRUCTURALLY_CLOSED','k_on,k_off,receptor abundance','receptor occupancy / signaling readouts'),
(4,'ACT1_SIGNAL','ACT1/TRAF6/NF-kB/MAPK/YAP-EGFR network','explicit mass-action activation/deactivation equations from Phase 112','STRUCTURALLY_CLOSED_NOT_NUMERIC','signaling kinetic constants,total protein pools','phospho/active pathway states'),
(5,'G1S_GATE','CyclinD-CDK4/6 -> Rb/E2F -> CyclinE-CDK2 -> S entry','T_cycle=T_G1+T_S+T_G2+T_M; r_self=ln2/T_cycle*f_selfrenew','STRUCTURALLY_CLOSED_NOT_NUMERIC','Cyclin/CDK kinetics,Rb/E2F kinetics,S-gate threshold,phase durations','Ki67/cell-cycle markers'),
(6,'PROLIF_POOL','Proliferating keratinocyte balance','dN_p/dt = (r_self-r_commit-r_apop_p)*N_p','STRUCTURALLY_CLOSED_NOT_NUMERIC','r_commit,r_apop_p','Ki67+ proliferating pool'),
(7,'DIFF_POOL','Differentiated keratinocyte balance','dN_d/dt = r_commit*N_p - (r_corn+r_apop_d)*N_d','STRUCTURALLY_CLOSED_NOT_NUMERIC','r_commit,r_corn,r_apop_d','K1/K10/IVL/LOR/FLG/TGM markers'),
(8,'CORNEOCYTE_POOL','Corneocyte balance','dN_c/dt = r_corn*N_d - r_shed*N_c','STRUCTURALLY_CLOSED_NOT_NUMERIC','r_corn,r_shed','stratum-corneum morphometry'),
(9,'DESQUAMATION','Corneodesmosome cleavage / shedding','v_cleave=k_KLK*E_KLK*CDS; r_shed=v_cleave/(CDS*N_c)','STRUCTURALLY_CLOSED_NOT_NUMERIC','KLK/cathepsin activity,pH,inhibitors,CDS abundance','desquamation / corneodesmosome markers'),
(10,'BARRIER','Barrier resistance / water flux','R_barrier=L_SC/(D_water*K_part); J_water=DeltaC_water/R_barrier; B=J_water/J_water_normal','STRUCTURALLY_CLOSED_NOT_NUMERIC','L_SC,D_water,K_part,DeltaC','TEWL/SCH'),
(11,'GEOMETRY','Epidermal geometry','h_epi=(N_p*v_p+N_d*v_d+N_c*v_c)/A_lesion','STRUCTURALLY_CLOSED_NOT_NUMERIC','cell volumes,cell counts,lesion area','epidermal thickness'),
(12,'PLAQUE_VOLUME','Physical plaque excess','V_excess=A_lesion*max(h_epi-h_normal,0)','STRUCTURALLY_CLOSED','h_epi,h_normal,A_lesion','target plaque thickness/volume'),
(13,'RESOLUTION','Necessary local resolution conditions','r_commit+r_apop_p>r_self AND (r_corn+r_apop_d)*N_d>r_commit*N_p AND r_shed*N_c>r_corn*N_d AND dV_excess/dt<0','STRUCTURALLY_CLOSED_NOT_NUMERIC','all upstream primitive rates','serial plaque regression')
ON DUPLICATE KEY UPDATE governing_expression=VALUES(governing_expression),closure_status=VALUES(closure_status),unresolved_inputs=VALUES(unresolved_inputs),verification_endpoint=VALUES(verification_endpoint);

CREATE OR REPLACE VIEW v_ilb_psoriasis_master_formula AS
SELECT
  COUNT(*) AS stages,
  SUM(closure_status='STRUCTURALLY_CLOSED') AS structurally_closed,
  SUM(closure_status='STRUCTURALLY_CLOSED_NOT_NUMERIC') AS structurally_closed_not_numeric,
  'GENETICS -> IL17 MASS BALANCE -> RECEPTOR BINDING -> SIGNALING -> G1/S -> CELL POPULATIONS -> CORNIFICATION/DESQUAMATION -> BARRIER -> GEOMETRY -> PLAQUE' AS master_chain,
  'DERIVE -> PREDICT -> VERIFY' AS governing_rule,
  'No unsourced coefficient or modality-derived mechanism may enter the first-principles chain.' AS safety_rule
FROM ilb_psoriasis_master_equation_stage;
