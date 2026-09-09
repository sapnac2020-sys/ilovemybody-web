-- Phase 120: Final psoriasis discovery conclusion
-- Source basis: independently derived formula stack + ILMB_Psoriasis_Genuine_Discovery_Program_v1.8 verification workbook.
-- Rule: DERIVE -> PREDICT -> VERIFY. This phase freezes the conclusion; it does not invent new biology.

CREATE TABLE IF NOT EXISTS ilb_psoriasis_final_conclusion (
  conclusion_id VARCHAR(96) PRIMARY KEY,
  conclusion_code VARCHAR(64) NOT NULL UNIQUE,
  conclusion_text TEXT NOT NULL,
  mathematical_form TEXT NULL,
  evidence_level VARCHAR(32) NOT NULL,
  status VARCHAR(32) NOT NULL,
  claim_boundary TEXT NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_psoriasis_final_path_component (
  component_id VARCHAR(96) PRIMARY KEY,
  component_code VARCHAR(64) NOT NULL UNIQUE,
  component_name VARCHAR(160) NOT NULL,
  role_class VARCHAR(64) NOT NULL,
  target_zone VARCHAR(96) NOT NULL,
  evidence_status VARCHAR(48) NOT NULL,
  inclusion_status VARCHAR(48) NOT NULL,
  verification_requirement TEXT NOT NULL,
  claim_boundary TEXT NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO ilb_psoriasis_final_conclusion
(conclusion_id,conclusion_code,conclusion_text,mathematical_form,evidence_level,status,claim_boundary)
VALUES
('P120-C001','MASTER_DISEASE_MODEL','Psoriasis is a coupled immune-epidermal-barrier system with fixed genetic susceptibility and modifiable active disease state.','dX/dt=F(X,U,G), dG/dt=0; X includes immune, keratinocyte-compartment, barrier and plaque states.','HIGH','FINAL','Does not mean genetics are irrelevant; it means active disease is not identical to genotype.'),
('P120-C002','MASTER_THERAPEUTIC_TARGET','The common therapeutic target is stable epidermal-immune homeostasis, not one named modality or one cytokine concentration.','V_excess=A_lesion*max(h_epi-h_normal,0); success requires dV_excess/dt<0 until V_excess->0 with barrier_index->1.','HIGH','FINAL','Complete skin normalization is not the same as proven permanent cure.'),
('P120-C003','NODE_BASED_ALTERNATIVE_DISCOVERY','Alternative/non-drug discovery must be node-based: an intervention is upgraded only when a measured node change precedes and predicts lesion regression.','U -> Δnode -> Δcompartment_flux -> dV_excess/dt<0.','HIGH','FINAL','Similar PASI outcomes do not prove the same mechanism.'),
('P120-C004','NONDRUG_REFERENCE_PATH','Controlled NB-UVB/phototherapy is the strongest established direct non-drug reference path; barrier support, conditional metabolic correction, and stress/autonomic interventions are modifiers/support layers when relevant.','U_total={U_UV,U_barrier,U_metabolic,U_neuro}; each term is retained only if its target node and outcome are measured.','HIGH','FINAL','This is a research/clinical architecture, not a universal prescription for every patient.'),
('P120-C005','UNIVERSAL_ALTERNATE_CURE','No single alternative modality or universal alternate cure is established by the current evidence.','No modality satisfies all required mechanistic and durability gates universally.','HIGH','FINAL','Homeopathy/Bach/Louise Hay/Redikall remain verification or narrative layers; acupuncture/EMDR remain research adjuncts unless upgraded by measurements.'),
('P120-C006','DURABILITY_ENDPOINT','Durability is a separate required endpoint: response alone cannot distinguish temporary suppression from stable homeostasis.','T_R=time-to-relapse; end-state vector X_end must be tested as a predictor of T_R.','HIGH','FINAL','PASI75/90/100 is not by itself evidence of cure.')
ON DUPLICATE KEY UPDATE conclusion_text=VALUES(conclusion_text),mathematical_form=VALUES(mathematical_form),evidence_level=VALUES(evidence_level),status=VALUES(status),claim_boundary=VALUES(claim_boundary);

INSERT INTO ilb_psoriasis_final_path_component
(component_id,component_code,component_name,role_class,target_zone,evidence_status,inclusion_status,verification_requirement,claim_boundary)
VALUES
('P120-P001','NB_UVB','Controlled NB-UVB / phototherapy','DIRECT_NONDRUG_REFERENCE','IMMUNE + EPIDERMAL','ESTABLISHED','CORE_REFERENCE','Dose/exposure, lesion response, barrier/epidermal measures; track relapse.','Dose-response is patient/context dependent; not a universal numeric coefficient.'),
('P120-P002','BARRIER','Barrier-directed care','DOWNSTREAM_SUPPORT','BARRIER','SUPPORTED','CORE_SUPPORT','TEWL/hydration or equivalent barrier measure plus lesion outcome.','Barrier improvement alone does not prove upstream immune normalization.'),
('P120-P003','METABOLIC','Weight/metabolic correction when measured abnormality exists','CONDITIONAL_MODIFIER','METABOLIC_UPSTREAM','SUPPORTED_SUBGROUP','CONDITIONAL','Use only when eligibility/abnormality is measured; track weight/metabolic variables and PASI/V_excess.','Not a universal psoriasis mechanism or universal diet.'),
('P120-P004','STRESS_AUTONOMIC','CBT/mindfulness/stress-autonomic correction','UPSTREAM_MODIFIER','NEURO_STRESS','SUPPORTED_MODIFIER','CONDITIONAL','Repeated state measurement must precede and predict skin outcome for mechanistic upgrade.','Does not prove stress is the sole root cause.'),
('P120-P005','EMDR','EMDR','RESEARCH_UPSTREAM_MODIFIER','NEURO_STRESS','HYPOTHESIS','RESEARCH_ONLY','Require repeated trauma/stress/autonomic state plus psoriasis outcomes and mediation/lag evidence.','No direct IL-17 or keratinocyte claim.'),
('P120-P006','ACUPUNCTURE','Acupuncture/acupoint stimulation','RESEARCH_ADJUNCT','UNRESOLVED_NODE','LOW_MIXED','RESEARCH_ONLY','Require exact protocol, measured mediator and reproducible psoriasis outcome.','No verified IL-17-to-cell-flow bridge.'),
('P120-P007','HOMEOPATHY','Homeopathy','VERIFICATION_ONLY','OUTCOME_ONLY','LOW_SIGNAL','VERIFICATION_ONLY','Prospective exact remedy/exposure plus standardized outcomes; any mechanism requires independent node measurement.','Selection logic and PASI signal cannot create a biological mechanism.'),
('P120-P008','BACH','Bach flower remedies','VERIFICATION_ONLY','EMOTIONAL_STATE','VERY_LOW','VERIFICATION_ONLY','Test state-match -> emotional-state change -> psoriasis outcome, if studied.','No established psoriasis-specific biological effect.'),
('P120-P009','LOUISE_HAY','Louise Hay emotional narrative','NARRATIVE_HYPOTHESIS','EMOTIONAL_MEANING','ANECDOTAL','NARRATIVE_ONLY','May be recorded as patient narrative; biological causality requires separate evidence.','Must never be promoted to a verified psoriasis cause.'),
('P120-P010','REDIKALL','Redikall / emotional mapping','NARRATIVE_HYPOTHESIS','EMOTIONAL_MEANING','ANECDOTAL','NARRATIVE_ONLY','May be recorded as patient narrative; biological causality requires separate evidence.','Must never be promoted to a verified psoriasis cause.')
ON DUPLICATE KEY UPDATE role_class=VALUES(role_class),target_zone=VALUES(target_zone),evidence_status=VALUES(evidence_status),inclusion_status=VALUES(inclusion_status),verification_requirement=VALUES(verification_requirement),claim_boundary=VALUES(claim_boundary);

CREATE OR REPLACE VIEW v_ilb_psoriasis_final_discovery_conclusion AS
SELECT
  (SELECT COUNT(*) FROM ilb_psoriasis_final_conclusion WHERE status='FINAL') AS final_conclusions,
  (SELECT COUNT(*) FROM ilb_psoriasis_final_path_component) AS path_components,
  (SELECT COUNT(*) FROM ilb_psoriasis_final_path_component WHERE inclusion_status='CORE_REFERENCE') AS direct_nondrug_reference_count,
  (SELECT COUNT(*) FROM ilb_psoriasis_final_path_component WHERE inclusion_status='VERIFICATION_ONLY') AS verification_only_count,
  (SELECT COUNT(*) FROM ilb_psoriasis_final_path_component WHERE inclusion_status='NARRATIVE_ONLY') AS narrative_only_count,
  'RESTORE_EPIDERMAL_IMMUNE_HOMEOSTASIS' AS project_conclusion,
  'NO_UNIVERSAL_ALTERNATE_CURE_ESTABLISHED' AS cure_claim_status,
  'NUMERIC_PRIMITIVE_CLOSURE_AND_PROSPECTIVE_VERIFICATION_REMAIN' AS next_gate;
