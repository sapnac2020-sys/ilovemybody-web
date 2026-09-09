-- Phase 119: Psoriasis conclusion and modality verdict registry
-- Rule: DERIVE -> PREDICT -> VERIFY. Evidence verdicts do not create biological coefficients.

CREATE TABLE IF NOT EXISTS ilb_psoriasis_modality_verdict (
  verdict_id VARCHAR(96) PRIMARY KEY,
  modality_code VARCHAR(96) NOT NULL,
  modality_name VARCHAR(160) NOT NULL,
  pathway_role VARCHAR(96) NOT NULL,
  direct_biological_node VARCHAR(160) NULL,
  clinical_outcome_evidence VARCHAR(48) NOT NULL,
  mechanistic_evidence VARCHAR(48) NOT NULL,
  formula_bridge_status VARCHAR(48) NOT NULL,
  verdict_class VARCHAR(64) NOT NULL,
  claim_boundary TEXT NOT NULL,
  source_summary TEXT NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_psoriasis_context_primitive (
  primitive_id VARCHAR(96) PRIMARY KEY,
  quantity_name VARCHAR(160) NOT NULL,
  numeric_value DECIMAL(30,12) NULL,
  unit VARCHAR(64) NULL,
  context_scope VARCHAR(255) NOT NULL,
  verification_only TINYINT(1) NOT NULL DEFAULT 1,
  source_summary TEXT NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO ilb_psoriasis_modality_verdict
(verdict_id,modality_code,modality_name,pathway_role,direct_biological_node,clinical_outcome_evidence,mechanistic_evidence,formula_bridge_status,verdict_class,claim_boundary,source_summary)
VALUES
('P119-NBUVB','NB_UVB','Narrow-band UVB phototherapy','DIRECT_NONDRUG_MEDICAL','Keratinocyte/immune/epidermal state','ESTABLISHED','SUPPORTED','PARTIAL_DIRECT','REFERENCE_DIRECT_PATH','Established non-drug medical psoriasis treatment; do not classify as alternative medicine and do not convert UV dose to a drug-equivalent dose.','AAD psoriasis guidance and phototherapy literature support psoriasis improvement and direct skin/immune effects.'),
('P119-BARRIER','BARRIER_CARE','Barrier care / emollient support','DOWNSTREAM_SUPPORT','Barrier/scale/fissure state','SUPPORTED','DIRECT_DOWNSTREAM','DIRECT_DOWNSTREAM','SUPPORTIVE_PATH','Can improve barrier-related outputs; does not by itself prove correction of the IL-23/IL-17 axis.','Barrier physiology and TEWL literature support direct downstream barrier measurement.'),
('P119-WEIGHT','WEIGHT_METABOLIC','Weight / metabolic correction when relevant','CONDITIONAL_MODIFIER','Metabolic/inflammatory modifier state','SUPPORTED_CONDITIONAL','INDIRECT','INDIRECT','CONDITIONAL_MODIFIER','Use only when overweight/obesity or a measured metabolic abnormality is present; no universal psoriasis diet coefficient.','RCT meta-analyses show weight-loss interventions reduce PASI in overweight/obese psoriasis populations.'),
('P119-MINDFUL','MINDFULNESS_STRESS','Mindfulness / stress regulation','UPSTREAM_MODIFIER','Stress/threat state','SUPPORTED_ADJUNCT','INDIRECT','INDIRECT','ADJUNCT_MODIFIER','May improve stress/QoL and can improve psoriasis severity in some trials; not a direct IL-17 treatment.','Systematic review of randomized studies found short-term saPASI and psychological improvements in several trials.'),
('P119-EMDR','EMDR','Eye Movement Desensitization and Reprocessing','UPSTREAM_MODIFIER','Threat/trauma/autonomic state','PRELIMINARY','INDIRECT','UNRESOLVED_TO_SKIN','RESEARCH_ADJUNCT','No direct IL-17 or keratinocyte-normalization claim. Psoriasis effect must be demonstrated prospectively through mediator and skin outcomes.','ILMB Phase 105 governance plus psoriasis stress literature; direct psoriasis-specific EMDR mechanism remains unestablished.'),
('P119-ACU','ACUPUNCTURE','Acupuncture / acupoint stimulation','CANDIDATE_ADJUNCT','Unresolved; symptom/neuroimmune candidates','LIMITED_CONFLICTING','UNRESOLVED','UNRESOLVED','RESEARCH_ADJUNCT','Do not infer cytokine or keratinocyte mechanism from traditional indications.','Systematic reviews report possible short-term benefit but weak methodology/conflicting results; stronger trials required.'),
('P119-HOM','HOMEOPATHY','Homeopathy','VERIFICATION_ONLY',NULL,'UNESTABLISHED','UNVALIDATED','NO_BRIDGE','VERIFICATION_ONLY','Outcome observations may test predictions; remedy/potency/repertory logic may not supply psoriasis mechanism or coefficients.','Uploaded ILMB mechanism-gap workbook explicitly marks remedy->IL-17A and remedy->keratinocyte normalization as unvalidated.'),
('P119-BACH','BACH','Bach flower framework','VERIFICATION_ONLY','Emotional-state construct','UNESTABLISHED_FOR_PSO','UNVALIDATED','NO_BRIDGE','VERIFICATION_ONLY','May be tested on emotional-state outcomes and mediation; no direct cytokine mapping.','Uploaded convergence workbook maps Bach primarily to emotional-state constructs and preserves molecular claim boundaries.'),
('P119-LOUISE','LOUISE_HAY','Louise Hay emotional narrative','NARRATIVE_HYPOTHESIS','Emotional/meaning construct','ANECDOTAL','UNVALIDATED','NO_BRIDGE','NARRATIVE_ONLY','Do not treat fear-of-hurt or self-criticism narratives as established biological causes of psoriasis.','User-supplied anecdotal narrative parked as hypothesis/meaning layer only.'),
('P119-REDIKALL','REDIKALL','Redikall / emotional framework','NARRATIVE_HYPOTHESIS','Emotional/meaning construct','ANECDOTAL_OR_SOURCE_ONLY','UNVALIDATED','NO_BRIDGE','NARRATIVE_ONLY','No direct biological mechanism claim without independent derivation and measurement.','ILMB governance requires hypothesis/verification-only treatment until a biological bridge exists.')
ON DUPLICATE KEY UPDATE pathway_role=VALUES(pathway_role),clinical_outcome_evidence=VALUES(clinical_outcome_evidence),mechanistic_evidence=VALUES(mechanistic_evidence),formula_bridge_status=VALUES(formula_bridge_status),verdict_class=VALUES(verdict_class),claim_boundary=VALUES(claim_boundary),source_summary=VALUES(source_summary);

INSERT INTO ilb_psoriasis_context_primitive
(primitive_id,quantity_name,numeric_value,unit,context_scope,verification_only,source_summary)
VALUES
('P119-FLUX-PROLIF-NORMAL','Normal epidermal proliferative-compartment turnover flux',1246,'cells/day/mm2','Historical kinetic model of normal human epidermis',1,'Weinstein et al. normal epidermal model; context/verification only.'),
('P119-FLUX-DIFF-NORMAL','Normal viable differentiated-compartment turnover flux',1417,'cells/day/mm2','Historical kinetic model of normal human epidermis',1,'Weinstein et al. normal epidermal model; context/verification only.'),
('P119-FLUX-SC-NORMAL','Normal stratum-corneum turnover flux',1490,'cells/day/mm2','Historical kinetic model of normal human epidermis',1,'Weinstein et al. normal epidermal model; context/verification only.'),
('P119-TURNOVER-NORMAL','Whole normal epidermal turnover time',39,'day','Historical kinetic model of normal human epidermis',1,'Context-only tissue turnover observation; not a universal patient constant.'),
('P119-TCYCLE-PSO-HIST','Historical psoriatic proliferative-cell cycle time',36,'h','Historical experimentally defined psoriatic proliferative population',1,'Context-only; population definitions and later studies differ.')
ON DUPLICATE KEY UPDATE numeric_value=VALUES(numeric_value),unit=VALUES(unit),context_scope=VALUES(context_scope),source_summary=VALUES(source_summary);

CREATE OR REPLACE VIEW v_ilb_psoriasis_project_conclusion AS
SELECT
  'EPIDERMAL_COMPARTMENT_HOMEOSTASIS' AS biological_target,
  'V_excess -> 0; h_epi -> h_normal; barrier_index -> 1' AS physical_success_condition,
  'FIXED_GENETIC_SUSCEPTIBILITY_COMPATIBLE_WITH_NORMAL_SKIN' AS genetics_conclusion,
  'NB_UVB_REFERENCE_DIRECT_PATH_PLUS_NODE_SPECIFIC_MODIFIERS' AS strongest_nondrug_conclusion,
  'NO_UNIVERSAL_ALTERNATE_CURE_ESTABLISHED' AS cure_claim_status,
  'DERIVE_PREDICT_VERIFY' AS governance_rule;
