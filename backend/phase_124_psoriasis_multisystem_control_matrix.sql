-- Phase 124: Psoriasis multisystem control matrix
-- Purpose: widen discovery beyond single compounds/modalities.
CREATE TABLE IF NOT EXISTS ilb_psoriasis_control_branch (
  branch_id VARCHAR(64) PRIMARY KEY,
  branch_name VARCHAR(128) NOT NULL,
  target_nodes TEXT NOT NULL,
  candidate_controls TEXT NOT NULL,
  evidence_status VARCHAR(32) NOT NULL,
  human_evidence_summary TEXT NOT NULL,
  mechanism_boundary TEXT NOT NULL,
  required_measurements TEXT NOT NULL,
  priority_class VARCHAR(32) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO ilb_psoriasis_control_branch
(branch_id,branch_name,target_nodes,candidate_controls,evidence_status,human_evidence_summary,mechanism_boundary,required_measurements,priority_class)
VALUES
('P124-SKIN-DIFF','Skin formation/differentiation','KSC/ETA/LTA; FLG; LOR; IVL; TGM; K1/K10/K16/K17','Barrier repair; differentiation-restoring candidates; PPAR/LXR research','SUPPORTED','Psoriasis shows abnormal terminal differentiation with loss/alteration of late differentiation markers; PPAR-gamma activation can increase filaggrin/loricrin/involucrin/TGM1 in keratinocyte models.','Do not infer psoriasis efficacy from differentiation-marker effects alone.','Target lesion thickness; FLG/LOR/IVL/TGM/K markers where research-grade sampling exists; TEWL; photos','CORE'),
('P124-BARRIER-LIPID','Barrier lipid/physical state','Ceramides; cholesterol; free fatty acids; SC water flux','Standardized emollient/barrier care; lipid-focused research','SUPPORTED','Barrier dysfunction is part of psoriasis pathology; physical barrier recovery is measurable.','Barrier improvement is not proof of upstream immune normalization.','TEWL; hydration; lesion fissure/scale; site-matched photos','CORE'),
('P124-VITD','Vitamin D/VDR axis','25(OH)D; VDR; differentiation; cytokine modifiers','Correct measured deficiency; vitamin D research adjunct','MIXED_SUPPORTED','Meta-analyses show psoriasis patients often have lower 25(OH)D; oral supplementation trials are inconsistent, though newer network meta-analysis suggests PASI benefit and vitamin D+NB-UVB cytokine effects.','Do not use population deficiency or supplementation as a universal psoriasis treatment rule.','25(OH)D; PASI/BSA; relevant cytokines if measured','CONDITIONAL'),
('P124-OMEGA3','Omega-3/eicosanoid-resolving axis','EPA/DHA; inflammatory lipid mediators','Omega-3 supplementation research','MIXED','Meta-analyses conflict: some show PASI/erythema/scaling benefit, another pooled analysis found no significant PASI reduction.','Keep exploratory unless person-specific response is demonstrated.','EPA/DHA status where available; PASI; erythema; scale; itch','RESEARCH'),
('P124-GUT','Gut-skin/microbiome axis','Microbiome; CRP/TNF/IL6; gut barrier','Defined probiotic/synbiotic interventions','PRELIMINARY_SUPPORTED','Several RCTs and meta-analyses report PASI benefit, but newer pooled analyses remain heterogeneous and sometimes nonsignificant.','No universal strain/formulation or causal gut->IL17 coefficient established.','Defined strain/dose/exposure; PASI; GI state; CRP/TNF/IL6 where relevant','RESEARCH'),
('P124-HPA','HPA/autonomic stress axis','Stress; ACTH; cortisol; autonomic state','Mindfulness/CBT/relaxation; breathing as autonomic control hypothesis','SUPPORTED_UPSTREAM','Psoriasis stress studies show HPA-axis dysregulation associations; several RCTs/systematic reviews show mindfulness/relaxation can improve psoriasis outcomes or clearing rate.','Breathing/pranayama itself is not established as direct psoriasis therapy; require autonomic/clinical change.','Stress scale; sleep; HRV if used; cortisol/ACTH research; PASI/BSA','CONDITIONAL'),
('P124-HORMONE','Endocrine/sex-hormone axis','Insulin; thyroid; prolactin; estrogen/progesterone/testosterone; cortisol','Correct diagnosed endocrine abnormalities; research modifier mapping','ASSOCIATIVE','Systematic/review evidence links psoriasis activity with endocrine transitions and multiple hormones, but treatment-level causal evidence is incomplete.','Do not prescribe hormone manipulation for psoriasis without an independent clinical indication.','Relevant hormone only when clinically indicated; disease trajectory','RESEARCH'),
('P124-SLEEP','Sleep/circadian axis','Sleep quality; circadian timing; neuroimmune state','Sleep correction when disrupted','ASSOCIATIVE_SUPPORTED','Meta-analysis shows markedly higher sleep disturbance in psoriasis; causal treatment effect remains less established.','Treat as modifier unless prospective node/skin response is demonstrated.','PSQI/sleep log; itch; PASI; stress','CONDITIONAL'),
('P124-COMPOUND','Specific molecule-to-node axis','IL17/TAK1/CCL20; EGFR/CDC25B; proliferation/differentiation','Indirubin/indigo naturalis; curcumin; other ChEBI-defined candidates','CANDIDATE','Topical indigo naturalis/indirubin has RCT and mechanistic evidence; curcumin has weaker but relevant adjunctive/mechanistic evidence.','Candidate molecule evidence must not be generalized to a whole modality.','Defined compound/formulation; exposure; PASI; lesion geometry; node markers','HIGH_RESEARCH')
ON DUPLICATE KEY UPDATE evidence_status=VALUES(evidence_status),human_evidence_summary=VALUES(human_evidence_summary),mechanism_boundary=VALUES(mechanism_boundary),required_measurements=VALUES(required_measurements),priority_class=VALUES(priority_class);

CREATE OR REPLACE VIEW v_ilb_psoriasis_multisystem_priorities AS
SELECT priority_class, COUNT(*) AS branch_count
FROM ilb_psoriasis_control_branch
GROUP BY priority_class;