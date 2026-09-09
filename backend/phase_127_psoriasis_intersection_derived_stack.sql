-- Phase 127: Intersection-derived psoriasis candidate stack
-- Purpose: encode a concrete ILMB synthesis from independent evidence branches.
-- This is NOT a proven combination trial and NOT a universal prescription.

CREATE TABLE IF NOT EXISTS ilb_psoriasis_candidate_stack (
  stack_id VARCHAR(64) PRIMARY KEY,
  stack_name VARCHAR(160) NOT NULL,
  component_code VARCHAR(80) NOT NULL,
  component_name VARCHAR(255) NOT NULL,
  control_zone VARCHAR(64) NOT NULL,
  evidence_status VARCHAR(48) NOT NULL,
  human_evidence_summary TEXT NOT NULL,
  mechanistic_role TEXT NOT NULL,
  measurement_requirement TEXT NOT NULL,
  claim_boundary TEXT NOT NULL,
  priority_order INT NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO ilb_psoriasis_candidate_stack
(stack_id,stack_name,component_code,component_name,control_zone,evidence_status,human_evidence_summary,mechanistic_role,measurement_requirement,claim_boundary,priority_order)
VALUES
('P127-A','ILMB_INTERSECTION_STACK_V1','INDIRUBIN','Standardized topical indirubin / indigo naturalis candidate','IMMUNE+EPIDERMAL','HUMAN_RCT_PLUS_MECHANISTIC','Human randomized trials show psoriasis improvement; mechanistic studies support IL17/TAK1/CCL20 attenuation and EGFR/CDC25B/proliferation-differentiation effects.','Candidate dual-domain control of inflammatory feedback and keratinocyte growth/differentiation.','Defined formulation/exposure; PASI/BSA; target lesion geometry; standardized photos; node markers where feasible.','Combination with the other stack components has not itself been proven in an RCT; do not infer universal efficacy or self-compounding instructions.',1),
('P127-B','ILMB_INTERSECTION_STACK_V1','LA_CERAMIDE','Linoleic-acid/ceramide barrier restoration','BARRIER','HUMAN_RCT','Randomized trials report improved TEWL/hydration/PASI and lower relapse when linoleic-acid/ceramide moisturizer is used as adjunct/maintenance.','Direct restoration of stratum-corneum lipid/barrier state; complementary to immune/epidermal control.','TEWL; hydration; scale/fissure; target lesion geometry; relapse interval.','Barrier improvement is not proof of immune-axis normalization.',2),
('P127-C','ILMB_INTERSECTION_STACK_V1','MEDITERRANEAN_DIET','Mediterranean-style dietary intervention','METABOLIC_SYSTEMIC','HUMAN_RCT_ADJUNCT','MEDIPSO randomized trial in mild-moderate psoriasis on stable topical therapy showed significant PASI improvement and PASI75 in 47.4% vs 0% control at 16 weeks.','Systemic/metabolic-inflammatory modifier; may reduce amplifier load rather than directly normalize epidermis.','Diet adherence; weight/waist; HbA1c/metabolic markers where relevant; PASI/BSA.','Evidence is adjunctive; do not infer that diet alone covers immune+epidermal+barrier in all patients.',3),
('P127-D','ILMB_INTERSECTION_STACK_V1','AUTONOMIC','Stress/autonomic regulation when active','NEURO_AUTONOMIC','SUPPORTED_UPSTREAM','Mindfulness/relaxation studies show short-term improvement in psoriasis outcomes in some RCTs; breathing itself lacks direct psoriasis-specific proof.','Optional upstream control when stress/sleep/autonomic abnormality is measured.','Stress/sleep; HRV if used; PASI/BSA; target lesion outcome.','Do not label breathing/EMDR/mindfulness as direct IL17 treatment.',4)
ON DUPLICATE KEY UPDATE evidence_status=VALUES(evidence_status),human_evidence_summary=VALUES(human_evidence_summary),mechanistic_role=VALUES(mechanistic_role),measurement_requirement=VALUES(measurement_requirement),claim_boundary=VALUES(claim_boundary),priority_order=VALUES(priority_order);

CREATE OR REPLACE VIEW v_ilb_psoriasis_intersection_stack AS
SELECT stack_name,
       COUNT(*) AS component_count,
       GROUP_CONCAT(control_zone ORDER BY priority_order SEPARATOR ' + ') AS covered_zones
FROM ilb_psoriasis_candidate_stack
GROUP BY stack_name;
