-- Phase 121: Psoriasis candidate non-drug treatment pattern
-- Purpose: convert the final disease conclusion into an executable, measurable research pathway.
-- Governance: this is a candidate research pattern, not a universal prescription or cure claim.

CREATE TABLE IF NOT EXISTS ilb_psoriasis_treatment_pattern_layer (
  layer_id VARCHAR(64) PRIMARY KEY,
  layer_order INT NOT NULL,
  layer_code VARCHAR(64) NOT NULL UNIQUE,
  layer_name VARCHAR(160) NOT NULL,
  required_class VARCHAR(32) NOT NULL,
  biological_role TEXT NOT NULL,
  entry_rule TEXT NOT NULL,
  success_measure TEXT NOT NULL,
  failure_rule TEXT NOT NULL,
  evidence_status VARCHAR(32) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_psoriasis_treatment_pattern_component (
  component_id VARCHAR(64) PRIMARY KEY,
  layer_id VARCHAR(64) NOT NULL,
  intervention_code VARCHAR(64) NOT NULL,
  intervention_name VARCHAR(160) NOT NULL,
  role_class VARCHAR(64) NOT NULL,
  target_nodes TEXT NOT NULL,
  required_measurements TEXT NOT NULL,
  evidence_status VARCHAR(32) NOT NULL,
  mechanism_status VARCHAR(32) NOT NULL,
  claim_boundary TEXT NOT NULL,
  stop_or_escalate_rule TEXT NOT NULL,
  UNIQUE KEY uq_psopat_component (layer_id,intervention_code),
  CONSTRAINT fk_psopat_layer FOREIGN KEY(layer_id) REFERENCES ilb_psoriasis_treatment_pattern_layer(layer_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_psoriasis_treatment_pattern_checkpoint (
  checkpoint_id VARCHAR(64) PRIMARY KEY,
  checkpoint_order INT NOT NULL,
  checkpoint_code VARCHAR(64) NOT NULL UNIQUE,
  checkpoint_name VARCHAR(160) NOT NULL,
  required_observation TEXT NOT NULL,
  decision_rule TEXT NOT NULL,
  durability_flag TINYINT(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO ilb_psoriasis_treatment_pattern_layer
(layer_id,layer_order,layer_code,layer_name,required_class,biological_role,entry_rule,success_measure,failure_rule,evidence_status)
VALUES
('P121-L1',1,'DIRECT_CONTROL','Direct skin/immune control','REFERENCE_REQUIRED','Reduce active lesional immune/epidermal drive sufficiently to permit regression.','Use a direct non-drug reference path when clinically appropriate and not excluded.','Target-lesion/PASI/BSA trajectory plus plaque-thickness/geometry change.','No objective regression or worsening -> re-evaluate disease state, adherence, diagnosis and treatment intensity.','ESTABLISHED_REFERENCE'),
('P121-L2',2,'BARRIER_REPAIR','Barrier repair','FOUNDATIONAL','Reduce downstream barrier dysfunction, scale/fissure burden and injury feedback.','Use when barrier disruption, dryness, fissuring or scaling is present.','TEWL/hydration where available plus scale/fissure/itch and lesion geometry.','Barrier measures or lesion outputs fail to improve -> reassess product, exposure, scratching/trauma and active inflammation.','SUPPORTED'),
('P121-L3',3,'AMPLIFIER_REMOVAL','Measured amplifier correction','CONDITIONAL','Remove measurable metabolic/exposure/trigger drivers that amplify disease activity.','Activate only when a measured abnormality/exposure exists.','Matched variable improves and psoriasis outcome improves in temporal sequence.','No relevant abnormality -> do not add generic lifestyle burden; no outcome response -> do not claim causality.','CONDITIONAL'),
('P121-L4',4,'UPSTREAM_REGULATION','Stress/autonomic regulation','CONDITIONAL','Reduce measured threat/stress/autonomic burden that may amplify flares or recovery failure.','Activate when a reproducible stress/threat/autonomic pattern is documented.','Stress/SUD/HRV/sleep trajectory plus skin outcome trajectory.','Psychological improvement without skin change -> classify as QoL benefit, not psoriasis mechanism.','SUPPORTED_ADJUNCT'),
('P121-L5',5,'RESEARCH_ADJUNCTS','Research adjuncts','OPTIONAL_RESEARCH','Test candidate modalities without allowing them to create biological mechanism claims.','Use only in governed research when primary safety/direct pathway is preserved.','Predefined node/outcome change versus baseline/control plus durability.','No predefined signal -> reject or retain hypothesis; never upgrade mechanism from outcome alone.','RESEARCH_ONLY')
ON DUPLICATE KEY UPDATE layer_name=VALUES(layer_name),biological_role=VALUES(biological_role),evidence_status=VALUES(evidence_status);

INSERT INTO ilb_psoriasis_treatment_pattern_component
(component_id,layer_id,intervention_code,intervention_name,role_class,target_nodes,required_measurements,evidence_status,mechanism_status,claim_boundary,stop_or_escalate_rule)
VALUES
('P121-C-NBUVB','P121-L1','NB_UVB','Controlled narrow-band UVB phototherapy','REFERENCE_DIRECT_NONDRUG','lesional immune state; epidermal proliferation/differentiation; plaque geometry','UV dose; target lesion; PASI/BSA; standardized photos; adverse skin response','ESTABLISHED','SUPPORTED_DIRECT','Reference non-drug pathway; treatment delivery remains clinician-governed.','If objective disease control is inadequate or toxicity occurs, escalate/reassess rather than extending exposure blindly.'),
('P121-C-BARRIER','P121-L2','BARRIER_CARE','Barrier-directed care','DIRECT_DOWNSTREAM_SUPPORT','stratum corneum/barrier; itch/trauma feedback','TEWL where available; hydration; fissure/scale; itch; target lesion','SUPPORTED','DIRECT_DOWNSTREAM','Does not prove IL-17 suppression.','If barrier improves but plaque does not, retain as support only and reassess upstream disease control.'),
('P121-C-WEIGHT','P121-L3','WEIGHT_METABOLIC','Weight/metabolic correction when indicated','CONDITIONAL_MODIFIER','metabolic/systemic inflammatory amplifier','weight/BMI/waist and relevant metabolic markers; PASI/BSA','SUPPORTED_SELECTED_POPULATION','INDIRECT','Only where overweight/obesity or measured metabolic abnormality exists.','Do not prescribe generic weight loss to normal-weight patients or claim universal mechanism.'),
('P121-C-TRIGGER','P121-L3','TRIGGER_CONTROL','Measured trigger/exposure control','CONDITIONAL_MODIFIER','skin trauma; smoking; alcohol; infection-linked flare; other documented exposure','exposure log; flare timing; lesion trajectory','SUPPORTED_CONDITIONAL','INDIRECT','Only measured/reproducible triggers qualify.','If no temporal association or no response after removal, downgrade causal attribution.'),
('P121-C-STRESS','P121-L4','STRESS_REGULATION','CBT/mindfulness/stress regulation','UPSTREAM_ADJUNCT','stress/threat/autonomic/sleep amplifier','validated stress measure/SUD; sleep; optional HRV; PASI/itch','SUPPORTED_ADJUNCT','INDIRECT','Not a direct cytokine treatment.','Psychological benefit without skin response remains valuable but not mechanistic proof.'),
('P121-C-EMDR','P121-L5','EMDR','EMDR','RESEARCH_UPSTREAM','trauma/threat/autonomic state','SUD; VOC; HRV if used; itch; PASI/BSA; relapse timing','PRELIMINARY','HYPOTHESIS_DOWNSTREAM','No direct IL-17 or keratinocyte normalization claim.','No skin signal -> retain only for indicated psychological outcome.'),
('P121-C-ACU','P121-L5','ACUPUNCTURE','Acupuncture/acupoint stimulation','RESEARCH_ADJUNCT','candidate neuroimmune/itch/lesion nodes','protocol fidelity; PASI; itch; lesion area/thickness; relapse timing','LOW_TO_MODERATE_UNCERTAIN','UNRESOLVED','Clinical outcome evidence is mixed and mechanism not quantitatively closed.','Require predefined response and comparator; otherwise do not promote.'),
('P121-C-HOM','P121-L5','HOMEOPATHY','Homeopathy','VERIFICATION_ONLY','none established biologically','outcome only: PASI/BSA/itch/DLQI/time-to-relapse','UNVALIDATED_MECHANISM','UNKNOWN','May verify outcomes; may not supply psoriasis coefficients/mechanism.','No mechanistic upgrade without independent mediator evidence.'),
('P121-C-BACH','P121-L5','BACH','Bach flower framework','VERIFICATION_ONLY','emotional-state constructs only','emotional-state measure plus independent skin outcomes','UNVALIDATED_MECHANISM','UNKNOWN','No biological psoriasis mechanism established.','Retain as narrative/outcome hypothesis only.'),
('P121-C-LH','P121-L5','LOUISE_HAY','Louise Hay framework','NARRATIVE_HYPOTHESIS','meaning/self-criticism/fear-of-hurt constructs','narrative coding; emotional measure; independent skin outcome','ANECDOTAL','UNKNOWN','Not a verified cause of psoriasis.','Never promote narrative concordance to biological causality.'),
('P121-C-RED','P121-L5','REDIKALL','Redikall framework','NARRATIVE_HYPOTHESIS','emotional/meaning constructs','framework-specific score plus independent skin outcome','ANECDOTAL','UNKNOWN','Not a verified biological psoriasis mechanism.','Never promote outcome correlation to cytokine mechanism.')
ON DUPLICATE KEY UPDATE evidence_status=VALUES(evidence_status),mechanism_status=VALUES(mechanism_status),claim_boundary=VALUES(claim_boundary);

INSERT INTO ilb_psoriasis_treatment_pattern_checkpoint
(checkpoint_id,checkpoint_order,checkpoint_code,checkpoint_name,required_observation,decision_rule,durability_flag)
VALUES
('P121-K0',0,'SAFETY','Safety/phenotype confirmation','phenotype; urgent GPP/erythroderma exclusions; PsA screen; infection/other red flags','Urgent/red-flag state exits research pathway and routes to appropriate medical assessment.',0),
('P121-K1',1,'BASELINE','Baseline state vector','PASI/BSA; target lesion geometry/photos; itch; barrier state; relevant modifiers; current treatments','No treatment-effect inference without a documented baseline.',0),
('P121-K2',2,'EARLY_DIRECTION','Early direction check','same target-lesion and symptom measures using matched method','Continue only if objective trajectory is favorable and safety acceptable; otherwise reassess node choice/intensity/adherence.',0),
('P121-K3',3,'CLEARANCE','Skin normalization check','V_excess proxy/lesion geometry; PASI/BSA; barrier state','Clinical clearance requires lesion regression and barrier normalization; outcome alone does not prove mechanism.',0),
('P121-K4',4,'DURABILITY','Durability/time-to-relapse','time to relapse; recurrence site; trigger context; maintenance exposure','Durable success requires sustained normalization; relapse is modeled separately from initial clearance.',1)
ON DUPLICATE KEY UPDATE required_observation=VALUES(required_observation),decision_rule=VALUES(decision_rule);

CREATE OR REPLACE VIEW v_ilb_psoriasis_candidate_treatment_pattern AS
SELECT
  l.layer_order,l.layer_code,l.layer_name,l.required_class,
  c.intervention_code,c.intervention_name,c.role_class,c.target_nodes,
  c.evidence_status,c.mechanism_status,c.claim_boundary
FROM ilb_psoriasis_treatment_pattern_layer l
JOIN ilb_psoriasis_treatment_pattern_component c ON c.layer_id=l.layer_id
ORDER BY l.layer_order,c.intervention_code;

CREATE OR REPLACE VIEW v_ilb_psoriasis_treatment_pattern_readiness AS
SELECT
  (SELECT COUNT(*) FROM ilb_psoriasis_treatment_pattern_layer) AS layer_count,
  (SELECT COUNT(*) FROM ilb_psoriasis_treatment_pattern_component) AS component_count,
  (SELECT COUNT(*) FROM ilb_psoriasis_treatment_pattern_checkpoint) AS checkpoint_count,
  (SELECT COUNT(*) FROM ilb_psoriasis_treatment_pattern_component WHERE intervention_code='NB_UVB' AND role_class='REFERENCE_DIRECT_NONDRUG') AS direct_reference_count,
  (SELECT COUNT(*) FROM ilb_psoriasis_treatment_pattern_component WHERE intervention_code IN ('HOMEOPATHY','BACH','LOUISE_HAY','REDIKALL') AND mechanism_status<>'UNKNOWN') AS unsafe_mechanism_promotions,
  'CANDIDATE_PATTERN_READY_FOR_PROSPECTIVE_VERIFICATION' AS readiness_status;
