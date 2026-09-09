-- Phase 107: Psoriasis Genetic -> Modifiable Pathway
-- Purpose: separate fixed genetic susceptibility from modifiable biological disease state.
-- Governance: no claim that genetic susceptibility alone determines active psoriasis;
-- no alternative modality may be labelled as a direct cytokine treatment without evidence.

CREATE TABLE IF NOT EXISTS ilb_psoriasis_genetic_factor (
  genetic_factor_id VARCHAR(64) PRIMARY KEY,
  symbol VARCHAR(64) NOT NULL,
  factor_type VARCHAR(32) NOT NULL,
  psoriasis_role VARCHAR(128) NOT NULL,
  mechanism_summary TEXT NOT NULL,
  modifiability_class VARCHAR(32) NOT NULL DEFAULT 'FIXED_GENOTYPE',
  evidence_status VARCHAR(32) NOT NULL,
  source_note TEXT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_psoriasis_modifiable_node (
  node_id VARCHAR(64) PRIMARY KEY,
  node_code VARCHAR(32) NOT NULL UNIQUE,
  node_name VARCHAR(128) NOT NULL,
  layer_name VARCHAR(64) NOT NULL,
  desired_direction VARCHAR(64) NOT NULL,
  normalization_definition TEXT NOT NULL,
  evidence_status VARCHAR(32) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_psoriasis_genetic_node_link (
  link_id VARCHAR(64) PRIMARY KEY,
  genetic_factor_id VARCHAR(64) NOT NULL,
  node_id VARCHAR(64) NOT NULL,
  relation_type VARCHAR(64) NOT NULL,
  direction_of_effect VARCHAR(32) NOT NULL,
  evidence_status VARCHAR(32) NOT NULL,
  mechanism_summary TEXT NOT NULL,
  UNIQUE KEY uq_psogen_node (genetic_factor_id,node_id,relation_type),
  CONSTRAINT fk_psogen_factor FOREIGN KEY (genetic_factor_id) REFERENCES ilb_psoriasis_genetic_factor(genetic_factor_id),
  CONSTRAINT fk_psogen_node FOREIGN KEY (node_id) REFERENCES ilb_psoriasis_modifiable_node(node_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_psoriasis_modality_node_crosswalk (
  crosswalk_id VARCHAR(64) PRIMARY KEY,
  modality_code VARCHAR(64) NOT NULL,
  node_id VARCHAR(64) NOT NULL,
  action_class VARCHAR(64) NOT NULL,
  expected_direction VARCHAR(32) NOT NULL,
  directness VARCHAR(32) NOT NULL,
  psoriasis_evidence_status VARCHAR(32) NOT NULL,
  clinical_use_status VARCHAR(32) NOT NULL,
  claim_boundary TEXT NOT NULL,
  measurement_requirement TEXT NOT NULL,
  UNIQUE KEY uq_pso_modality_node (modality_code,node_id),
  CONSTRAINT fk_psomod_node FOREIGN KEY (node_id) REFERENCES ilb_psoriasis_modifiable_node(node_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_psoriasis_emotional_narrative_note (
  narrative_id VARCHAR(64) PRIMARY KEY,
  framework_name VARCHAR(128) NOT NULL,
  narrative_type VARCHAR(64) NOT NULL,
  theme_code VARCHAR(64) NOT NULL,
  theme_text TEXT NOT NULL,
  biological_claim_status VARCHAR(32) NOT NULL,
  evidence_status VARCHAR(32) NOT NULL,
  use_boundary TEXT NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO ilb_psoriasis_genetic_factor
(genetic_factor_id,symbol,factor_type,psoriasis_role,mechanism_summary,modifiability_class,evidence_status,source_note)
VALUES
('PSOGEN-HLAC0602','HLA-C*06:02','HLA_ALLELE','MAJOR_SUSCEPTIBILITY','Strong psoriasis susceptibility association; relevant to antigen presentation and immune recognition.','FIXED_GENOTYPE','ESTABLISHED','Population association; not sufficient by itself to diagnose active psoriasis.'),
('PSOGEN-IL23R','IL23R','GENE','IMMUNE_SUSCEPTIBILITY','Variant architecture implicates IL-23 signalling and Th17/Tc17 biology.','FIXED_GENOTYPE','ESTABLISHED','Susceptibility locus; active pathway state remains measurable and modifiable.'),
('PSOGEN-IL12B','IL12B','GENE','IMMUNE_SUSCEPTIBILITY','Genetic association implicates cytokine signalling relevant to psoriasis immune activation.','FIXED_GENOTYPE','ESTABLISHED','Susceptibility locus, not a deterministic disease equation.'),
('PSOGEN-IL23A','IL23A','GENE','IMMUNE_SUSCEPTIBILITY','Genetic association implicates IL-23 pathway activity.','FIXED_GENOTYPE','ESTABLISHED','Susceptibility locus, not equivalent to circulating/tissue IL-23 level.'),
('PSOGEN-TRAF3IP2','TRAF3IP2','GENE','IMMUNE_SIGNAL_SUSCEPTIBILITY','Genetic association links to IL-17 related intracellular signalling.','FIXED_GENOTYPE','ESTABLISHED','Susceptibility does not imply immutable active inflammation.'),
('PSOGEN-TYK2','TYK2','GENE','IMMUNE_SIGNAL_SUSCEPTIBILITY','Genetic association implicates cytokine signal transduction.','FIXED_GENOTYPE','ESTABLISHED','Susceptibility locus with downstream pathway state potentially modifiable.'),
('PSOGEN-CARD14','CARD14','GENE','KERATINOCYTE_INNATE_SUSCEPTIBILITY','Variants can affect keratinocyte innate inflammatory signalling in psoriasis phenotypes.','FIXED_GENOTYPE','SUPPORTED','Rare/high-impact and common-variant contexts differ; do not generalize to all psoriasis.'),
('PSOGEN-TNIP1','TNIP1','GENE','INFLAMMATORY_REGULATION_SUSCEPTIBILITY','Genetic association implicates inflammatory signalling regulation.','FIXED_GENOTYPE','ESTABLISHED','Susceptibility locus; phenotype depends on downstream state.')
ON DUPLICATE KEY UPDATE mechanism_summary=VALUES(mechanism_summary), evidence_status=VALUES(evidence_status), source_note=VALUES(source_note);

INSERT INTO ilb_psoriasis_modifiable_node
(node_id,node_code,node_name,layer_name,desired_direction,normalization_definition,evidence_status)
VALUES
('PSONODE-01','ANTIGEN_INNATE','Antigen / innate immune activation','IMMUNE_UPSTREAM','DOWN','Reduced pathologic activation while preserving normal host defence.','ESTABLISHED'),
('PSONODE-02','DC_IL23','Dendritic-cell / IL-23 signalling','IMMUNE_CYTOKINE','DOWN','Reduced pathogenic IL-23 pathway drive compatible with disease quiescence.','ESTABLISHED'),
('PSONODE-03','TH17_TC17','Th17 / Tc17 activation','IMMUNE_CELL','DOWN','Reduced pathogenic type-17 effector activation.','ESTABLISHED'),
('PSONODE-04','IL17_AXIS','IL-17A/F effector signalling','IMMUNE_CYTOKINE','DOWN','Reduced excessive IL-17 effector signalling in lesional skin.','ESTABLISHED'),
('PSONODE-05','TNF_IL22','TNF / IL-22 inflammatory amplification','IMMUNE_CYTOKINE','DOWN','Reduced inflammatory amplification supporting plaque regression.','ESTABLISHED'),
('PSONODE-06','KERATINOCYTE_ACT','Keratinocyte inflammatory activation','SKIN_CELL','DOWN','Return toward non-lesional inflammatory signalling state.','ESTABLISHED'),
('PSONODE-07','KERATINOCYTE_DIFF','Keratinocyte differentiation / maturation','SKIN_CELL','NORMALIZE','Restoration of orderly epidermal differentiation and maturation.','ESTABLISHED'),
('PSONODE-08','BARRIER','Epidermal barrier state','SKIN_BARRIER','UP','Improved barrier integrity and reduced barrier-inflammatory feedback.','ESTABLISHED'),
('PSONODE-09','PLAQUE','Visible plaque burden','CLINICAL_OUTCOME','DOWN','Reduction in erythema, scale, thickness and affected area toward clearance.','ESTABLISHED'),
('PSONODE-10','NEUROIMMUNE','Neuroimmune / autonomic modifier state','UPSTREAM_MODIFIER','NORMALIZE','Reduction of maladaptive stress/autonomic activation where present; downstream skin effect must be measured.','SUPPORTED'),
('PSONODE-11','METABOLIC','Metabolic inflammatory modifier state','SYSTEMIC_MODIFIER','NORMALIZE','Improve relevant metabolic/inflammatory modifiers where abnormal.','SUPPORTED'),
('PSONODE-12','UV_VITD_SKIN','UV / vitamin-D related skin regulatory state','SKIN_REGULATION','NORMALIZE','Use only measured/clinically appropriate UV or vitamin-D pathway data; do not infer universal deficiency.','SUPPORTED')
ON DUPLICATE KEY UPDATE normalization_definition=VALUES(normalization_definition), evidence_status=VALUES(evidence_status);

INSERT INTO ilb_psoriasis_genetic_node_link
(link_id,genetic_factor_id,node_id,relation_type,direction_of_effect,evidence_status,mechanism_summary)
VALUES
('PSOGL-001','PSOGEN-HLAC0602','PSONODE-01','SUSCEPTIBILITY_TO','INCREASED_RISK','ESTABLISHED','HLA-C*06:02 contributes to psoriasis susceptibility through antigen-presentation biology; it is not equivalent to active disease.'),
('PSOGL-002','PSOGEN-IL23R','PSONODE-02','SUSCEPTIBILITY_TO','ALTERED_RISK','ESTABLISHED','IL23R genetic architecture supports involvement of the IL-23 pathway.'),
('PSOGL-003','PSOGEN-IL23A','PSONODE-02','SUSCEPTIBILITY_TO','ALTERED_RISK','ESTABLISHED','IL23A genetic architecture supports involvement of IL-23 signalling.'),
('PSOGL-004','PSOGEN-IL12B','PSONODE-02','SUSCEPTIBILITY_TO','ALTERED_RISK','ESTABLISHED','IL12B susceptibility supports cytokine-pathway contribution to psoriasis.'),
('PSOGL-005','PSOGEN-TRAF3IP2','PSONODE-04','SUSCEPTIBILITY_TO','ALTERED_RISK','ESTABLISHED','TRAF3IP2 connects genetic susceptibility with IL-17-related intracellular signalling.'),
('PSOGL-006','PSOGEN-TYK2','PSONODE-02','SUSCEPTIBILITY_TO','ALTERED_RISK','ESTABLISHED','TYK2 susceptibility implicates cytokine signalling upstream of pathogenic immune activation.'),
('PSOGL-007','PSOGEN-CARD14','PSONODE-06','SUSCEPTIBILITY_TO','ALTERED_RISK','SUPPORTED','CARD14 variants can alter keratinocyte inflammatory signalling in relevant psoriasis contexts.'),
('PSOGL-008','PSOGEN-TNIP1','PSONODE-01','SUSCEPTIBILITY_TO','ALTERED_RISK','ESTABLISHED','TNIP1 susceptibility implicates inflammatory regulation upstream of active disease state.')
ON DUPLICATE KEY UPDATE mechanism_summary=VALUES(mechanism_summary), evidence_status=VALUES(evidence_status);

INSERT INTO ilb_psoriasis_modality_node_crosswalk
(crosswalk_id,modality_code,node_id,action_class,expected_direction,directness,psoriasis_evidence_status,clinical_use_status,claim_boundary,measurement_requirement)
VALUES
('PSOMOD-EMDR','EMDR','PSONODE-10','UPSTREAM_MODIFIER','NORMALIZE','INDIRECT','PRELIMINARY','CONDITIONAL','EMDR may target trauma/distress processing and autonomic state; no direct IL-17 lowering or skin-normalization claim is established.','Track modality-specific distress/autonomic measures and psoriasis outcomes separately.'),
('PSOMOD-ACU','ACUPUNCTURE','PSONODE-10','NEUROIMMUNE_MODIFIER','NORMALIZE','INDIRECT','PRELIMINARY','Do not claim a specific acupuncture point directly suppresses IL-17 or cures psoriasis without validated evidence.','Record point protocol, symptom/skin outcome and objective psoriasis measure.'),
('PSOMOD-NUT','NUTRITION','PSONODE-11','SYSTEMIC_MODIFIER','NORMALIZE','INDIRECT','SUPPORTED','Nutrition is not a universal psoriasis cure; act only on identified nutritional/metabolic abnormalities or evidence-supported risk modifiers.','Measure relevant nutritional/metabolic state plus skin outcome.'),
('PSOMOD-SLEEP','SLEEP','PSONODE-10','PHYSIOLOGIC_MODIFIER','NORMALIZE','INDIRECT','SUPPORTED','Sleep optimization may modify stress/inflammatory physiology; direct plaque clearance is not assumed.','Track sleep state plus objective psoriasis outcome.'),
('PSOMOD-EXERCISE','EXERCISE','PSONODE-11','SYSTEMIC_MODIFIER','NORMALIZE','INDIRECT','SUPPORTED','Exercise may improve systemic/metabolic modifiers; it is not stored as a direct cytokine treatment.','Track activity/metabolic state plus psoriasis outcome.'),
('PSOMOD-UV','PHOTOTHERAPY_UV','PSONODE-06','SKIN_DIRECT','DOWN','DIRECT','ESTABLISHED','UV phototherapy is a conventional non-drug medical treatment, not an alternative-medicine equivalence claim.','Use controlled treatment parameters and objective psoriasis severity measures.'),
('PSOMOD-BARRIER','BARRIER_CARE','PSONODE-08','BARRIER_SUPPORT','UP','DIRECT','ESTABLISHED','Barrier care supports symptoms and barrier function; do not label it as correction of the upstream genetic/IL-23/IL-17 driver.','Track barrier/symptom and psoriasis outcomes.'),
('PSOMOD-LOUISE','LOUISE_HAY','PSONODE-10','MEANING_EMOTIONAL_FRAMEWORK','UNSPECIFIED','HYPOTHESIS','RESEARCH_ONLY','Emotional themes are retained as narrative hypotheses only. They are not verified causes of psoriasis and must not be represented as direct immune mechanisms.','If used, record patient-reported emotional state separately from biological psoriasis measures.'),
('PSOMOD-REDIKALL','REDIKALL','PSONODE-10','MEANING_EMOTIONAL_FRAMEWORK','UNSPECIFIED','HYPOTHESIS','RESEARCH_ONLY','No verified causal route from Redikall concepts to IL-23/IL-17/keratinocyte normalization is established.','Separate subjective outcomes from objective psoriasis measures.')
ON DUPLICATE KEY UPDATE claim_boundary=VALUES(claim_boundary), measurement_requirement=VALUES(measurement_requirement), psoriasis_evidence_status=VALUES(psoriasis_evidence_status);

INSERT INTO ilb_psoriasis_emotional_narrative_note
(narrative_id,framework_name,narrative_type,theme_code,theme_text,biological_claim_status,evidence_status,use_boundary)
VALUES
('PSONARR-LH-001','Louise Hay / Heal Your Body','ANECDOTAL_FRAMEWORK','FEAR_OF_HURT','Fear of being hurt.','NOT_VERIFIED_CAUSE','ANECDOTAL','May be stored for reflective/patient-reported exploration only; never as a verified psoriasis cause.'),
('PSONARR-LH-002','Louise Hay / Heal Your Body','ANECDOTAL_FRAMEWORK','DEADENING_SELF','Deadening the senses of the self.','NOT_VERIFIED_CAUSE','ANECDOTAL','Narrative theme only.'),
('PSONARR-LH-003','Louise Hay / Heal Your Body','ANECDOTAL_FRAMEWORK','FEELINGS_RESPONSIBILITY','Refusing to accept responsibility for our own feelings.','NOT_VERIFIED_CAUSE','ANECDOTAL','Narrative theme only; do not infer blame or biological causality.'),
('PSONARR-CASE-001','Head-to-Heart psoriasis narrative supplied for notes','PERSONAL_ANECDOTE','CRITICISM_PICKING','Author connected scratching/picking and self-criticism with a history of being criticized.','NOT_VERIFIED_CAUSE','ANECDOTAL','Preserve as the author’s interpretation; not proof of psoriasis etiology.'),
('PSONARR-CASE-002','Head-to-Heart psoriasis narrative supplied for notes','PERSONAL_ANECDOTE','PURPOSE_LOSS_STRESS','Author linked psoriasis onset/worsening with self-doubt, job loss, hurt and loss of purpose.','NOT_VERIFIED_CAUSE','ANECDOTAL','May motivate measured research hypotheses; not a causal conclusion.'),
('PSONARR-CASE-003','Head-to-Heart psoriasis narrative supplied for notes','PERSONAL_ANECDOTE','EMOTIONAL_PROCESSING','Author reported psoriasis improving at times and recurring during a long emotional-healing process.','NOT_VERIFIED_CAUSE','ANECDOTAL','Temporal association in one narrative does not establish mechanism or treatment efficacy.')
ON DUPLICATE KEY UPDATE theme_text=VALUES(theme_text), use_boundary=VALUES(use_boundary);

CREATE OR REPLACE VIEW v_ilb_psoriasis_genetic_modifiable_pathway AS
SELECT
  g.genetic_factor_id,
  g.symbol,
  g.factor_type,
  g.psoriasis_role,
  g.modifiability_class,
  l.relation_type,
  l.direction_of_effect,
  n.node_code,
  n.node_name,
  n.layer_name,
  n.desired_direction,
  n.normalization_definition,
  l.evidence_status
FROM ilb_psoriasis_genetic_factor g
JOIN ilb_psoriasis_genetic_node_link l ON l.genetic_factor_id=g.genetic_factor_id
JOIN ilb_psoriasis_modifiable_node n ON n.node_id=l.node_id;

CREATE OR REPLACE VIEW v_ilb_psoriasis_modality_target_crosswalk AS
SELECT
  m.modality_code,
  n.node_code,
  n.node_name,
  n.layer_name,
  m.action_class,
  m.expected_direction,
  m.directness,
  m.psoriasis_evidence_status,
  m.clinical_use_status,
  m.claim_boundary,
  m.measurement_requirement
FROM ilb_psoriasis_modality_node_crosswalk m
JOIN ilb_psoriasis_modifiable_node n ON n.node_id=m.node_id;

CREATE OR REPLACE VIEW v_ilb_psoriasis_genetic_modifiable_readiness AS
SELECT
  (SELECT COUNT(*) FROM ilb_psoriasis_genetic_factor) AS genetic_factors,
  (SELECT COUNT(*) FROM ilb_psoriasis_modifiable_node) AS modifiable_nodes,
  (SELECT COUNT(*) FROM ilb_psoriasis_genetic_node_link) AS genetic_node_links,
  (SELECT COUNT(*) FROM ilb_psoriasis_modality_node_crosswalk) AS modality_node_links,
  (SELECT COUNT(*) FROM ilb_psoriasis_emotional_narrative_note) AS emotional_narrative_notes,
  (SELECT COUNT(*) FROM ilb_psoriasis_modality_node_crosswalk WHERE psoriasis_evidence_status='HYPOTHESIS') AS hypothesis_modality_links,
  (SELECT COUNT(*) FROM ilb_psoriasis_modality_node_crosswalk WHERE claim_boundary LIKE '%direct IL-17%') AS guarded_direct_il17_claims;
