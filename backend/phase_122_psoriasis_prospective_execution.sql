-- Phase 122: Psoriasis prospective execution protocol
-- Purpose: turn the candidate treatment pattern into a measurable prospective test.
-- Rule: DERIVE -> PREDICT -> VERIFY. This is a research execution framework, not a universal prescription.

CREATE TABLE IF NOT EXISTS ilb_psoriasis_prospective_protocol (
  protocol_id VARCHAR(64) PRIMARY KEY,
  protocol_code VARCHAR(64) NOT NULL UNIQUE,
  protocol_name VARCHAR(160) NOT NULL,
  objective_text TEXT NOT NULL,
  primary_endpoint VARCHAR(128) NOT NULL,
  durability_endpoint VARCHAR(128) NOT NULL,
  evidence_status VARCHAR(32) NOT NULL,
  clinical_use_status VARCHAR(32) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_psoriasis_protocol_checkpoint (
  checkpoint_id VARCHAR(64) PRIMARY KEY,
  protocol_id VARCHAR(64) NOT NULL,
  checkpoint_order INT NOT NULL,
  checkpoint_code VARCHAR(64) NOT NULL,
  checkpoint_name VARCHAR(160) NOT NULL,
  timing_rule VARCHAR(160) NOT NULL,
  required_measurements TEXT NOT NULL,
  decision_rule TEXT NOT NULL,
  stop_escalate_rule TEXT NOT NULL,
  UNIQUE KEY uq_pso_checkpoint (protocol_id,checkpoint_code),
  CONSTRAINT fk_pso_checkpoint_protocol FOREIGN KEY (protocol_id) REFERENCES ilb_psoriasis_prospective_protocol(protocol_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_psoriasis_protocol_component (
  component_id VARCHAR(64) PRIMARY KEY,
  protocol_id VARCHAR(64) NOT NULL,
  layer_code VARCHAR(64) NOT NULL,
  intervention_code VARCHAR(96) NOT NULL,
  role_class VARCHAR(64) NOT NULL,
  inclusion_rule TEXT NOT NULL,
  target_nodes TEXT NOT NULL,
  required_exposure_measurement TEXT NOT NULL,
  expected_node_direction TEXT NOT NULL,
  evidence_status VARCHAR(32) NOT NULL,
  mechanism_boundary TEXT NOT NULL,
  UNIQUE KEY uq_pso_protocol_component (protocol_id,intervention_code),
  CONSTRAINT fk_pso_component_protocol FOREIGN KEY (protocol_id) REFERENCES ilb_psoriasis_prospective_protocol(protocol_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_psoriasis_episode_measurement_plan (
  plan_measurement_id VARCHAR(64) PRIMARY KEY,
  protocol_id VARCHAR(64) NOT NULL,
  variable_code VARCHAR(96) NOT NULL,
  measurement_role VARCHAR(64) NOT NULL,
  body_site_required TINYINT(1) NOT NULL DEFAULT 0,
  frequency_rule VARCHAR(160) NOT NULL,
  canonical_unit VARCHAR(64) NULL,
  release_required TINYINT(1) NOT NULL DEFAULT 1,
  UNIQUE KEY uq_pso_measurement_plan (protocol_id,variable_code,measurement_role),
  CONSTRAINT fk_pso_measurement_protocol FOREIGN KEY (protocol_id) REFERENCES ilb_psoriasis_prospective_protocol(protocol_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_psoriasis_protocol_outcome_rule (
  outcome_rule_id VARCHAR(64) PRIMARY KEY,
  protocol_id VARCHAR(64) NOT NULL,
  rule_code VARCHAR(64) NOT NULL,
  rule_type VARCHAR(64) NOT NULL,
  expression_text TEXT NOT NULL,
  interpretation_text TEXT NOT NULL,
  UNIQUE KEY uq_pso_outcome_rule (protocol_id,rule_code),
  CONSTRAINT fk_pso_outcome_protocol FOREIGN KEY (protocol_id) REFERENCES ilb_psoriasis_prospective_protocol(protocol_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO ilb_psoriasis_prospective_protocol
(protocol_id,protocol_code,protocol_name,objective_text,primary_endpoint,durability_endpoint,evidence_status,clinical_use_status)
VALUES
('P122-PROTOCOL-001','PSO-NONDRUG-PROSPECTIVE-V1','Psoriasis Candidate Non-Drug Prospective Test v1',
'Test whether the governed four-layer candidate pathway produces objective lesion regression and durable normalization while preserving node-specific evidence boundaries.',
'VEXCESS_TRAJECTORY','TIME_TO_RELAPSE','PROSPECTIVE_TEST','RESEARCH_PROTOCOL')
ON DUPLICATE KEY UPDATE objective_text=VALUES(objective_text),primary_endpoint=VALUES(primary_endpoint),durability_endpoint=VALUES(durability_endpoint);

INSERT INTO ilb_psoriasis_protocol_component
(component_id,protocol_id,layer_code,intervention_code,role_class,inclusion_rule,target_nodes,required_exposure_measurement,expected_node_direction,evidence_status,mechanism_boundary)
VALUES
('P122-C01','P122-PROTOCOL-001','DIRECT_CONTROL','NB_UVB','REFERENCE_DIRECT_NONDRUG','Include when phototherapy is clinically appropriate and no contraindication/safety block exists.','skin immune activity; epidermal hyperplasia; lesion activity','session date; wavelength class; delivered dose; body site','lesion activity down; excess epidermal volume down','ESTABLISHED','Established non-drug psoriasis treatment; does not prove every upstream primitive is normalized.'),
('P122-C02','P122-PROTOCOL-001','BARRIER_REPAIR','BARRIER_CARE','DIRECT_DOWNSTREAM_SUPPORT','Include for active dryness/scale/fissure/barrier impairment unless product intolerance exists.','barrier flux; corneocyte retention; trauma feedback','product; grams/site/day; site; adherence','TEWL/barrier defect down; scale/fissure burden down','SUPPORTED','Barrier improvement is not direct proof of IL-17 reduction.'),
('P122-C03','P122-PROTOCOL-001','AMPLIFIER_REMOVAL','METABOLIC_CORRECTION','CONDITIONAL_MODIFIER','Include only when overweight/obesity or a measured metabolic abnormality relevant to psoriasis is present.','metabolic inflammatory drive','weight; waist; relevant labs; intervention exposure','measured metabolic abnormality toward target; psoriasis amplifier down','SUPPORTED_CONDITIONAL','No universal psoriasis diet or universal metabolic cause is asserted.'),
('P122-C04','P122-PROTOCOL-001','AMPLIFIER_REMOVAL','TRIGGER_REDUCTION','CONDITIONAL_MODIFIER','Include only for verified recurrent trigger exposure such as smoking, alcohol excess, repeated mechanical trauma or other documented trigger.','trigger input; Koebner/trauma feedback','exposure log with units and dates','documented trigger exposure down','SUPPORTED_CONDITIONAL','Trigger control may reduce flares but is not equivalent to disease-mechanism closure.'),
('P122-C05','P122-PROTOCOL-001','UPSTREAM_REGULATION','STRESS_AUTONOMIC','SUPPORTED_UPSTREAM_ADJUNCT','Include when stress/threat/sleep/autonomic burden is reproducibly elevated or temporally coupled to disease activity.','threat/stress/autonomic state','validated stress measure and/or SUD; sleep; HRV when available; session/exposure log','upstream burden down','SUPPORTED_ADJUNCT','Not a direct IL-17 treatment; downstream biological impact must be observed, not assumed.'),
('P122-C06','P122-PROTOCOL-001','RESEARCH_ADJUNCT','EMDR','RESEARCH_UPSTREAM','Include only when clinically indicated for trauma/distress and tracked separately from direct psoriasis treatment.','threat memory; autonomic/arousal state','session phase; SUD; VoC; HRV when available','upstream distress/arousal down','PRELIMINARY','No established direct IL-17 or keratinocyte-normalization claim.'),
('P122-C07','P122-PROTOCOL-001','RESEARCH_ADJUNCT','ACUPUNCTURE','RESEARCH_ADJUNCT','Optional research adjunct with exact point/session documentation.','candidate neuroimmune/itch/stress nodes','points; laterality; stimulation; duration; session dates','candidate symptom/upstream node improvement','LOW_CERTAINTY','Mechanistic psoriasis-node bridge remains unclosed.'),
('P122-C08','P122-PROTOCOL-001','VERIFICATION_ONLY','HOMEOPATHY','VERIFICATION_ONLY','May be recorded only as a separately tracked exposure/outcome verification layer.','none accepted as biological mechanism','remedy; potency; schedule; adherence','clinical outcome only','UNVALIDATED_MECHANISM','May not supply psoriasis biological coefficients or direct mediator claims.'),
('P122-C09','P122-PROTOCOL-001','VERIFICATION_ONLY','BACH','VERIFICATION_ONLY','May be recorded only as emotional-state/outcome verification.','emotional-state constructs only','product; schedule; emotional-state measure','emotional state and clinical outcome only','UNVALIDATED_MECHANISM','No biological psoriasis mechanism accepted.'),
('P122-C10','P122-PROTOCOL-001','VERIFICATION_ONLY','LOUISE_HAY','NARRATIVE_ONLY','Narrative/emotional themes may be recorded prospectively if the subject wishes.','self-reported emotional themes','time-stamped narrative/state rating','narrative/state change only','ANECDOTAL','No causal biological psoriasis claim.'),
('P122-C11','P122-PROTOCOL-001','VERIFICATION_ONLY','REDIKALL','NARRATIVE_ONLY','Narrative/hypothesis layer only.','self-reported emotional themes','time-stamped narrative/state rating','narrative/state change only','ANECDOTAL','No causal biological psoriasis claim.')
ON DUPLICATE KEY UPDATE inclusion_rule=VALUES(inclusion_rule),target_nodes=VALUES(target_nodes),evidence_status=VALUES(evidence_status),mechanism_boundary=VALUES(mechanism_boundary);

INSERT INTO ilb_psoriasis_protocol_checkpoint
(checkpoint_id,protocol_id,checkpoint_order,checkpoint_code,checkpoint_name,timing_rule,required_measurements,decision_rule,stop_escalate_rule)
VALUES
('P122-K01','P122-PROTOCOL-001',1,'SAFETY_BASELINE','Safety and baseline','Before intervention start','phenotype; urgent red flags; PsA screen; PASI/BSA or target lesion; standardized photo; itch; current treatments; relevant modifiers','Proceed only if phenotype/safety status is documented and no urgent exclusion requires alternate care.','Urgent red flag, suspected erythrodermic/generalized pustular disease, serious infection or other safety block -> stop protocol and route for urgent medical assessment.'),
('P122-K02','P122-PROTOCOL-001',2,'EARLY_DIRECTION','Early objective direction','First planned reassessment after sufficient exposure for the selected component','same target lesion/photo method; PASI/BSA when applicable; itch; exposure adherence; barrier/TEWL when available','Require objective direction compatible with lesion regression and no meaningful worsening attributable to the protocol.','No objective improvement with adequate exposure, significant worsening, adverse effect or new safety signal -> reassess diagnosis/adherence/exposure and escalate care rather than intensify unsupported adjuncts.'),
('P122-K03','P122-PROTOCOL-001',3,'MIDCOURSE','Mid-course node check','At protocol-defined mid-course','lesion area/thickness proxy; scale/erythema/induration; barrier metric; modifier-specific node measurement','Continue components only where exposure is documented and the intended node or lesion output is moving in the expected direction.','If only subjective benefit occurs without objective lesion movement, classify as symptom/QoL benefit rather than disease-modifying proof.'),
('P122-K04','P122-PROTOCOL-001',4,'CLEARANCE_STATE','Clearance/normalization assessment','At maximal observed response or protocol endpoint','PASI/BSA/target lesion; standardized photo; h_epi or physical thickness if available; barrier state; residual plaque volume proxy','Classify skin normalization only when objective lesion burden approaches matched normal state; PASI response alone is not mechanism proof.','Persistent active plaque after adequate direct-treatment exposure -> classify incomplete response and consider evidence-based escalation outside the experimental non-drug pattern.'),
('P122-K05','P122-PROTOCOL-001',5,'DURABILITY','Durability clock','After clearance or best achieved response','time to relapse; same lesion site; trigger/exposure changes; maintenance exposures','Record T_R independently of clearance magnitude. Durable normalization requires reproducible extension of T_R with stable end-state measurements.','Relapse resets the active-disease episode and triggers re-analysis of node state; do not relabel transient clearance as cure.')
ON DUPLICATE KEY UPDATE timing_rule=VALUES(timing_rule),required_measurements=VALUES(required_measurements),decision_rule=VALUES(decision_rule),stop_escalate_rule=VALUES(stop_escalate_rule);

INSERT INTO ilb_psoriasis_episode_measurement_plan
(plan_measurement_id,protocol_id,variable_code,measurement_role,body_site_required,frequency_rule,canonical_unit,release_required)
VALUES
('P122-M01','P122-PROTOCOL-001','PASI','DISEASE_ACTIVITY',0,'baseline and major checkpoints','1',1),
('P122-M02','P122-PROTOCOL-001','BSA_PERCENT','DISEASE_ACTIVITY',0,'baseline and major checkpoints','%',1),
('P122-M03','P122-PROTOCOL-001','TARGET_LESION_AREA','PHYSICAL_ENDPOINT',1,'baseline and every objective reassessment','cm2',1),
('P122-M04','P122-PROTOCOL-001','TARGET_LESION_THICKNESS','PHYSICAL_ENDPOINT',1,'baseline and every objective reassessment','mm',1),
('P122-M05','P122-PROTOCOL-001','V_EXCESS_PROXY','MODEL_ENDPOINT',1,'derived at every objective reassessment','cm3',1),
('P122-M06','P122-PROTOCOL-001','ITCH_NRS','SYMPTOM',0,'daily or checkpoint summary','1',0),
('P122-M07','P122-PROTOCOL-001','TEWL','BARRIER_NODE',1,'baseline and selected checkpoints when available','g m-2 h-1',0),
('P122-M08','P122-PROTOCOL-001','STANDARD_PHOTO','IMAGING',1,'baseline and every objective reassessment',NULL,1),
('P122-M09','P122-PROTOCOL-001','UV_DOSE','EXPOSURE',1,'each phototherapy exposure','J/m2',0),
('P122-M10','P122-PROTOCOL-001','STRESS_STATE','UPSTREAM_NODE',0,'baseline and selected checkpoints','1',0),
('P122-M11','P122-PROTOCOL-001','SLEEP_STATE','UPSTREAM_NODE',0,'daily/weekly summary','h/night',0),
('P122-M12','P122-PROTOCOL-001','TIME_TO_RELAPSE','DURABILITY',1,'from best response/clearance until relapse','d',1)
ON DUPLICATE KEY UPDATE frequency_rule=VALUES(frequency_rule),canonical_unit=VALUES(canonical_unit),release_required=VALUES(release_required);

INSERT INTO ilb_psoriasis_protocol_outcome_rule
(outcome_rule_id,protocol_id,rule_code,rule_type,expression_text,interpretation_text)
VALUES
('P122-R01','P122-PROTOCOL-001','LESION_REGRESSION','PRIMARY','dV_excess/dt < 0','Objective physical lesion burden is decreasing.'),
('P122-R02','P122-PROTOCOL-001','NORMALIZATION','PRIMARY','V_excess -> 0 AND h_epi -> h_normal AND barrier_index -> 1','Candidate skin normalization state; not equivalent to permanent cure.'),
('P122-R03','P122-PROTOCOL-001','PREDICTION_RESIDUAL','MODEL_VERIFY','epsilon(t)=Y_observed(t)-Y_predicted(t)','Residuals quantify model verification; repeated systematic error requires model revision.'),
('P122-R04','P122-PROTOCOL-001','DURABILITY','DURABILITY','T_R = t_relapse - t_best_response','Time to relapse is independent from PASI response magnitude and is mandatory for durability claims.'),
('P122-R05','P122-PROTOCOL-001','MECHANISM_UPGRADE','EVIDENCE','intervention -> measured node change -> compartment change -> lesion regression -> replication','Clinical improvement alone does not establish mechanism; mediator/node evidence plus temporal order and replication are required.')
ON DUPLICATE KEY UPDATE expression_text=VALUES(expression_text),interpretation_text=VALUES(interpretation_text);

CREATE OR REPLACE VIEW v_ilb_psoriasis_prospective_readiness AS
SELECT
  p.protocol_code,
  COUNT(DISTINCT c.component_id) AS component_count,
  COUNT(DISTINCT k.checkpoint_id) AS checkpoint_count,
  COUNT(DISTINCT m.plan_measurement_id) AS measurement_count,
  COUNT(DISTINCT r.outcome_rule_id) AS outcome_rule_count,
  SUM(c.role_class='REFERENCE_DIRECT_NONDRUG') AS direct_reference_count,
  SUM(c.role_class IN ('VERIFICATION_ONLY','NARRATIVE_ONLY')) AS verification_only_count,
  CASE
    WHEN COUNT(DISTINCT c.component_id)>=11
      AND COUNT(DISTINCT k.checkpoint_id)=5
      AND COUNT(DISTINCT m.plan_measurement_id)>=12
      AND COUNT(DISTINCT r.outcome_rule_id)=5
      AND SUM(c.role_class='REFERENCE_DIRECT_NONDRUG')>=1
    THEN 'PROSPECTIVE_PROTOCOL_READY'
    ELSE 'BLOCKED'
  END AS readiness_status
FROM ilb_psoriasis_prospective_protocol p
LEFT JOIN ilb_psoriasis_protocol_component c ON c.protocol_id=p.protocol_id
LEFT JOIN ilb_psoriasis_protocol_checkpoint k ON k.protocol_id=p.protocol_id
LEFT JOIN ilb_psoriasis_episode_measurement_plan m ON m.protocol_id=p.protocol_id
LEFT JOIN ilb_psoriasis_protocol_outcome_rule r ON r.protocol_id=p.protocol_id
WHERE p.protocol_id='P122-PROTOCOL-001'
GROUP BY p.protocol_code;
