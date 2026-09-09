-- Phase 125: Psoriasis Minimal Control Set
-- Objective: identify the smallest defensible intervention set that covers all required disease-control domains.
-- Governance: no arbitrary efficacy weights; no universal prescription; conditional branches require measured abnormality.

CREATE TABLE IF NOT EXISTS ilb_psoriasis_control_domain (
  domain_code VARCHAR(64) PRIMARY KEY,
  domain_name VARCHAR(160) NOT NULL,
  domain_class VARCHAR(32) NOT NULL,
  required_for_normalization TINYINT(1) NOT NULL DEFAULT 0,
  normalization_target TEXT NOT NULL,
  measurement_requirement TEXT NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_psoriasis_control_candidate (
  candidate_code VARCHAR(96) PRIMARY KEY,
  candidate_name VARCHAR(160) NOT NULL,
  candidate_class VARCHAR(64) NOT NULL,
  evidence_status VARCHAR(32) NOT NULL,
  clinical_role VARCHAR(64) NOT NULL,
  directness VARCHAR(32) NOT NULL,
  safety_boundary TEXT NOT NULL,
  mechanism_boundary TEXT NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_psoriasis_candidate_domain_cover (
  candidate_code VARCHAR(96) NOT NULL,
  domain_code VARCHAR(64) NOT NULL,
  coverage_status VARCHAR(32) NOT NULL,
  evidence_status VARCHAR(32) NOT NULL,
  required_measurement TEXT NOT NULL,
  claim_boundary TEXT NOT NULL,
  PRIMARY KEY(candidate_code, domain_code),
  CONSTRAINT fk_p125_candidate FOREIGN KEY(candidate_code) REFERENCES ilb_psoriasis_control_candidate(candidate_code),
  CONSTRAINT fk_p125_domain FOREIGN KEY(domain_code) REFERENCES ilb_psoriasis_control_domain(domain_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_psoriasis_conditional_gate (
  gate_code VARCHAR(96) PRIMARY KEY,
  domain_code VARCHAR(64) NOT NULL,
  activation_condition TEXT NOT NULL,
  deactivate_condition TEXT NOT NULL,
  measurement_required TEXT NOT NULL,
  CONSTRAINT fk_p125_gate_domain FOREIGN KEY(domain_code) REFERENCES ilb_psoriasis_control_domain(domain_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO ilb_psoriasis_control_domain
(domain_code,domain_name,domain_class,required_for_normalization,normalization_target,measurement_requirement)
VALUES
('IMMUNE','Immune inflammatory drive','CORE',1,'Reduce pathological IL-23/Th17/IL-17/TNF-associated drive sufficiently to permit epidermal normalization.','Clinical severity plus mediator measurement where available; direct-control exposure must be recorded.'),
('EPIDERMAL','Epidermal compartment flow and differentiation','CORE',1,'Restore KSC/ETA/LTA/differentiation/cornification flux toward matched physiological homeostasis.','Target-lesion geometry plus differentiation/proliferation markers where available.'),
('BARRIER','Barrier lipid/physical state','CORE',1,'Restore matched barrier resistance, hydration and physical integrity.','TEWL or validated barrier proxy, hydration, fissure/scale assessment.'),
('METABOLIC','Metabolic/weight amplifier','CONDITIONAL',0,'Correct only measured metabolic or adiposity-related amplifier.','BMI/waist and relevant metabolic measurements.'),
('VITD','Vitamin D/VDR state','CONDITIONAL',0,'Correct measured deficiency/abnormality where clinically indicated; do not infer psoriasis causality from association alone.','25(OH)D and relevant clinical context.'),
('MICROBIOME','Gut-microbiome modifier','RESEARCH',0,'Test whether a reproducible microbiome-directed intervention changes inflammatory and skin outcomes.','Defined intervention, PASI/BSA, CRP or mediator outcome, durability.'),
('AUTONOMIC','HPA/autonomic stress modifier','CONDITIONAL',0,'Reduce measured stress/autonomic dysregulation where present.','Stress/sleep metrics, HRV where used, skin outcome.'),
('SLEEP','Sleep/circadian modifier','CONDITIONAL',0,'Correct measured sleep/circadian disturbance where present.','Sleep duration/regularity and skin outcome.'),
('HORMONAL','Endocrine/hormonal modifier','RESEARCH',0,'Investigate only clinically indicated endocrine abnormalities; no hormone treatment claim for psoriasis.','Condition-specific endocrine labs and skin outcome.'),
('MOLECULE','Specific molecule-to-node intervention','RESEARCH',0,'Test chemically defined molecules against explicit psoriasis nodes.','Defined formulation/exposure, node measurement, lesion outcome, safety.')
ON DUPLICATE KEY UPDATE domain_name=VALUES(domain_name), domain_class=VALUES(domain_class), required_for_normalization=VALUES(required_for_normalization), normalization_target=VALUES(normalization_target), measurement_requirement=VALUES(measurement_requirement);

INSERT INTO ilb_psoriasis_control_candidate
(candidate_code,candidate_name,candidate_class,evidence_status,clinical_role,directness,safety_boundary,mechanism_boundary)
VALUES
('NB_UVB','Controlled narrow-band UVB phototherapy','NON_DRUG_MEDICAL','ESTABLISHED','REFERENCE_DIRECT_CONTROL','DIRECT','Must be delivered under appropriate clinical phototherapy protocols and safety screening.','Direct skin/immune disease-modifying evidence exists; exact patient-specific molecular coefficients remain unresolved.'),
('BARRIER_STD','Standardized barrier-directed care','SKIN_SUPPORT','SUPPORTED','DIRECT_DOWNSTREAM_SUPPORT','DIRECT','Use formulation appropriate for site and skin state; monitor irritation/contact effects.','Improves barrier-related outputs; does not by itself prove upstream immune normalization.'),
('WEIGHT_METABOLIC','Weight/metabolic correction when abnormal','LIFESTYLE_METABOLIC','SUPPORTED_CONDITIONAL','AMPLIFIER_REMOVAL','INDIRECT','Activate only when overweight/obesity or relevant metabolic abnormality is present.','Evidence supports selected subgroups; not a universal psoriasis diet.'),
('STRESS_AUTONOMIC','Stress/autonomic regulation','BEHAVIORAL','SUPPORTED_CONDITIONAL','UPSTREAM_MODIFIER','INDIRECT','Use only when a reproducible stress/autonomic burden is present; do not delay evidence-based care.','Psychological/autonomic effect may improve severity; direct IL-17 lowering is not assumed.'),
('SLEEP_CORR','Sleep/circadian correction','BEHAVIORAL','ASSOCIATIVE_CONDITIONAL','UPSTREAM_MODIFIER','INDIRECT','Activate only with measured sleep disturbance.','Sleep disturbance is common; direct causal psoriasis treatment effect remains to be verified.'),
('VITD_CORR','Vitamin D correction when deficient','NUTRIENT','MIXED_CONDITIONAL','NUTRIENT_MODIFIER','INDIRECT','Correct deficiency according to standard clinical practice; avoid megadose psoriasis claims.','Population deficiency association and mixed RCT evidence; not a universal psoriasis control.'),
('PROBIOTIC_DEFINED','Defined probiotic intervention','MICROBIOME','PRELIMINARY_SUPPORTED','RESEARCH_MODIFIER','INDIRECT','Use only defined strains/products in a governed research context and record adverse effects.','Meta-analyses suggest PASI/CRP improvement but strain/dose/mechanism are not closed.'),
('INDIRUBIN','Topical indirubin / indigo naturalis candidate','SPECIFIC_MOLECULE','SUPPORTED_RESEARCH','CORE_NODE_CANDIDATE','DIRECT_AND_INDIRECT','Do not compound or dose outside dermatologist/pharmacy-controlled formulation; monitor local effects.','Human efficacy plus IL-17-signature and keratinocyte pathway evidence; not yet proven to cover barrier or durable remission alone.'),
('CURCUMIN','Curcumin candidate','SPECIFIC_MOLECULE','PRELIMINARY','RESEARCH_CANDIDATE','INDIRECT','Formulation/bioavailability/context matter; no universal dose.','Human and mechanistic evidence weaker/less coherent than indirubin.'),
('OMEGA3','Omega-3 intervention','NUTRIENT','MIXED','RESEARCH_MODIFIER','INDIRECT','Do not assume benefit; record formulation and dose.','Evidence across meta-analyses is inconsistent.'),
('EMDR','EMDR','PSYCHOTHERAPY','PRELIMINARY','RESEARCH_UPSTREAM_MODIFIER','INDIRECT','Appropriate trauma-focused clinical context only.','No established psoriasis-specific IL-17 or epidermal mechanism.'),
('ACUPUNCTURE','Acupuncture','PROCEDURAL_COMPLEMENTARY','LOW_CERTAINTY','RESEARCH_ADJUNCT','INDIRECT','Govern safety and practitioner competence.','Clinical evidence mixed; quantitative node bridge unresolved.')
ON DUPLICATE KEY UPDATE candidate_name=VALUES(candidate_name), evidence_status=VALUES(evidence_status), clinical_role=VALUES(clinical_role), directness=VALUES(directness), safety_boundary=VALUES(safety_boundary), mechanism_boundary=VALUES(mechanism_boundary);

INSERT INTO ilb_psoriasis_candidate_domain_cover
(candidate_code,domain_code,coverage_status,evidence_status,required_measurement,claim_boundary)
VALUES
('NB_UVB','IMMUNE','COVERS','ESTABLISHED','Delivered phototherapy exposure + PASI/BSA/target lesion.','Reference direct non-drug control; does not imply cure.'),
('NB_UVB','EPIDERMAL','COVERS','SUPPORTED','Target lesion geometry and skin response.','Supports normalization of hyperproliferative epidermis; person-specific kinetics unresolved.'),
('BARRIER_STD','BARRIER','COVERS','SUPPORTED','TEWL/barrier proxy + lesion scale/fissure response.','Barrier support only.'),
('INDIRUBIN','IMMUNE','CANDIDATE_COVER','SUPPORTED_RESEARCH','Defined topical exposure + inflammatory signature/clinical response.','IL-17-related pathway normalization observed in human study; not equivalent to biologic blockade.'),
('INDIRUBIN','EPIDERMAL','CANDIDATE_COVER','SUPPORTED_RESEARCH','PCNA/Ki67/differentiation markers where feasible + lesion geometry.','Mechanistic studies support proliferation/differentiation effects; durability not established.'),
('WEIGHT_METABOLIC','METABOLIC','COVERS_IF_GATE_ACTIVE','SUPPORTED_CONDITIONAL','Weight/waist/metabolic markers + PASI.','Only relevant when metabolic gate is active.'),
('STRESS_AUTONOMIC','AUTONOMIC','COVERS_IF_GATE_ACTIVE','SUPPORTED_CONDITIONAL','Stress/sleep/HRV where used + skin outcome.','Upstream modifier, not direct cytokine treatment.'),
('SLEEP_CORR','SLEEP','COVERS_IF_GATE_ACTIVE','ASSOCIATIVE_CONDITIONAL','Sleep metrics + skin outcome.','Requires prospective confirmation.'),
('VITD_CORR','VITD','COVERS_IF_GATE_ACTIVE','MIXED_CONDITIONAL','25(OH)D + PASI/other outcome.','Deficiency correction, not universal psoriasis therapy.'),
('PROBIOTIC_DEFINED','MICROBIOME','RESEARCH_COVER','PRELIMINARY_SUPPORTED','Defined strain/dose + PASI/CRP/other mediator.','No universal strain or mechanism.'),
('OMEGA3','METABOLIC','RESEARCH_COVER','MIXED','Defined EPA/DHA exposure + skin outcome.','Evidence inconsistent.'),
('EMDR','AUTONOMIC','RESEARCH_COVER','PRELIMINARY','SUD/HRV/stress plus skin outcome.','No direct psoriasis mechanism established.'),
('ACUPUNCTURE','AUTONOMIC','RESEARCH_COVER','LOW_CERTAINTY','Protocol exposure + node/skin outcome.','Mechanism unresolved.')
ON DUPLICATE KEY UPDATE coverage_status=VALUES(coverage_status), evidence_status=VALUES(evidence_status), required_measurement=VALUES(required_measurement), claim_boundary=VALUES(claim_boundary);

INSERT INTO ilb_psoriasis_conditional_gate
(gate_code,domain_code,activation_condition,deactivate_condition,measurement_required)
VALUES
('GATE_METABOLIC','METABOLIC','Activate only when overweight/obesity or a relevant metabolic abnormality is measured.','Deactivate when no relevant abnormality is present or once the modeled amplifier is corrected.','BMI/waist plus relevant metabolic markers.'),
('GATE_VITD','VITD','Activate only when vitamin D deficiency/insufficiency is measured and clinical correction is indicated.','Deactivate when status is corrected and no further indication exists.','25(OH)D.'),
('GATE_AUTONOMIC','AUTONOMIC','Activate when reproducible stress/autonomic burden is present and temporally relevant.','Deactivate when burden normalizes and no skin-response relationship remains.','Validated stress/sleep metrics; HRV optional.'),
('GATE_SLEEP','SLEEP','Activate when persistent sleep/circadian disturbance is measured.','Deactivate when sleep state normalizes.','Sleep duration, regularity, awakenings.'),
('GATE_HORMONAL','HORMONAL','Activate only for clinically indicated endocrine abnormality.','Deactivate when no endocrine indication exists.','Condition-specific endocrine testing.')
ON DUPLICATE KEY UPDATE activation_condition=VALUES(activation_condition), deactivate_condition=VALUES(deactivate_condition), measurement_required=VALUES(measurement_required);

CREATE OR REPLACE VIEW v_ilb_psoriasis_minimal_control_set AS
SELECT
  'MINIMAL_SET_RULE' AS rule_code,
  'Select the smallest intervention set that covers IMMUNE + EPIDERMAL + BARRIER; then add only conditional domains whose measurement gates are active. Prefer Pareto-nondominated sets with lower intervention burden when coverage/evidence are otherwise equivalent.' AS rule_text,
  3 AS required_core_domains,
  'NO_ARBITRARY_WEIGHTS' AS optimization_governance;
