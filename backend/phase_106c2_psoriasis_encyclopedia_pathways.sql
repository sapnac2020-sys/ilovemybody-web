-- ILoveMyBody Phase 106 split seed
-- Extracted verbatim from canonical Phase 106 migration artifact.

INSERT INTO ilb_psoriasis_pathway_edge(edge_id,from_node,to_node,relation_text,mechanistic_note,evidence_class,source_url) VALUES
('EDGE-001','Dendritic cell','IL-23','produces','Supports pathogenic type-17 cells','Established','https://pubmed.ncbi.nlm.nih.gov/33812489/'),
('EDGE-002','IL-23','Th17/Tc17/TRM','maintains/activates','Maintains IL-17-producing cell state','Established','https://pubmed.ncbi.nlm.nih.gov/33812489/'),
('EDGE-003','Th17/Tc17/TRM','IL-17A/F','produces','Type-17 cytokine output','Established','https://pubmed.ncbi.nlm.nih.gov/33812489/'),
('EDGE-004','IL-17A/F','Keratinocyte','activates','Induces inflammatory gene expression','Established','https://pubmed.ncbi.nlm.nih.gov/33812489/'),
('EDGE-005','TNF-alpha','Keratinocyte + immune cells','amplifies','Synergy with IL-17 and inflammatory signaling','Established','https://pubmed.ncbi.nlm.nih.gov/33812489/'),
('EDGE-006','IL-22','Keratinocyte','modulates','Promotes hyperplasia and altered differentiation','Established','https://pubmed.ncbi.nlm.nih.gov/33812489/'),
('EDGE-007','Keratinocyte','CCL20','produces','Recruits CCR6+ type-17 cells','Established','https://pubmed.ncbi.nlm.nih.gov/33812489/'),
('EDGE-008','CCL20','Type-17 cells','recruits','Positive feedback into lesion','Established','https://pubmed.ncbi.nlm.nih.gov/33812489/'),
('EDGE-009','Keratinocyte','CXCL1/CXCL8','produces','Recruits neutrophils','Established','https://pubmed.ncbi.nlm.nih.gov/33812489/'),
('EDGE-010','CXCL1/CXCL8','Neutrophil','recruits','Pustules/microabscess formation','Established','https://pubmed.ncbi.nlm.nih.gov/33812489/'),
('EDGE-011','IL-36','Keratinocyte','autocrine activation','Amplifies IL-36 and neutrophilic chemokine programs','Established','https://pubmed.ncbi.nlm.nih.gov/33812489/'),
('EDGE-012','IL36RN loss-of-function','IL-36 signaling','disinhibits','Strong GPP mechanism in genetic subset','Established','https://pubmed.ncbi.nlm.nih.gov/33812489/'),
('EDGE-013','Neutrophil proteases','IL-36 precursors','activate','Mature IL-36 proteins are more bioactive','Established','https://pubmed.ncbi.nlm.nih.gov/33812489/'),
('EDGE-014','Sensory neuron','CGRP/Substance P','releases','Neuroimmune communication','Supported','https://pubmed.ncbi.nlm.nih.gov/33812489/'),
('EDGE-015','CGRP','IL-23-producing skin cells','promotes in models','Experimental bridge to IL-23/IL-17 loop','Experimental','https://pubmed.ncbi.nlm.nih.gov/33812489/'),
('EDGE-016','Psoriatic inflammation','Sensory neuron','sensitizes','Bidirectional neuroimmune feedback','Supported','https://pubmed.ncbi.nlm.nih.gov/33812489/'),
('EDGE-017','Skin injury','Local innate immunity','activates','Koebner phenomenon can initiate lesions in predisposed skin','Established','https://pubmed.ncbi.nlm.nih.gov/33812489/'),
('EDGE-018','Streptococcal infection','Guttate psoriasis','triggers association','Strong clinical association','Established association','https://pubmed.ncbi.nlm.nih.gov/33812489/'),
('EDGE-019','Resident memory T cells','Relapse at same site','supports','Residual immune memory can reactivate disease','Supported','https://pubmed.ncbi.nlm.nih.gov/33812489/'),
('EDGE-020','Keratinocyte inflammatory memory','Relapse propensity','may support','Persistent tissue-state changes after resolution','Research-supported','https://pubmed.ncbi.nlm.nih.gov/33812489/')
ON DUPLICATE KEY UPDATE from_node=VALUES(from_node),to_node=VALUES(to_node),relation_text=VALUES(relation_text),mechanistic_note=VALUES(mechanistic_note),evidence_class=VALUES(evidence_class),source_url=VALUES(source_url);

INSERT INTO ilb_psoriasis_trigger(trigger_id,trigger_name,category_name,phenotype_site_relevance,evidence_note,ilmb_measurement,source_url) VALUES
('TRG-001','Streptococcal infection','Infection','Especially guttate; can exacerbate plaque','Strong clinical association','Assess sore throat/tonsillitis timing; test only when clinically indicated','https://www.psoriasis.org/guttate/'),
('TRG-002','Other infections','Infection','Can exacerbate psoriasis','Supported','Clinical infection assessment','https://dermnetnz.org/topics/psoriasis'),
('TRG-003','Skin trauma / Koebner phenomenon','Mechanical','Any phenotype','Established','Record scratches, cuts, tattoos, surgery, burns, friction','https://dermnetnz.org/topics/psoriasis'),
('TRG-004','Psychological stress','Neuroendocrine','Exacerbation in subset','Supported association','Record timing and physiological/behavioral responses; do not assume causality','https://www.aad.org/member/clinical-quality/guidelines/psoriasis'),
('TRG-005','Smoking','Exposure/metabolic','Associated with psoriasis; strong association with palmoplantar pustulosis','Observational','Quantify exposure','https://dermnetnz.org/topics/psoriasis'),
('TRG-006','Alcohol excess','Exposure','Can exacerbate and complicate treatment','Observational','Quantify intake','https://www.aad.org/member/clinical-quality/guidelines/psoriasis'),
('TRG-007','Obesity/adiposity','Metabolic','Associated with severity and treatment response','Strong observational/interventional weight-loss evidence','BMI/waist/body composition where appropriate','https://pubmed.ncbi.nlm.nih.gov/33812489/'),
('TRG-008','Lithium','Medication','Can trigger/exacerbate psoriasis','Recognized','Medication reconciliation','https://dermnetnz.org/topics/treatment-of-psoriasis'),
('TRG-009','Beta blockers','Medication','Can trigger/exacerbate psoriasis in some patients','Recognized','Medication reconciliation','https://dermnetnz.org/topics/treatment-of-psoriasis'),
('TRG-010','Antimalarials','Medication','Can trigger/exacerbate psoriasis','Recognized','Medication reconciliation','https://dermnetnz.org/topics/treatment-of-psoriasis'),
('TRG-011','Systemic corticosteroid withdrawal','Medication change','Can precipitate severe rebound/pustular/erythrodermic disease','Recognized safety issue','Record recent systemic steroid use/withdrawal','https://www.aad.org/member/clinical-quality/guidelines/psoriasis'),
('TRG-012','Weather / low humidity','Environment','Dry/cold conditions can worsen symptoms','Common patient-reported','Seasonality log','https://dermnetnz.org/topics/psoriasis'),
('TRG-013','Sunburn','Mechanical/UV injury','Can Koebnerize lesions','Recognized','UV exposure + burn history','https://dermnetnz.org/topics/treatment-of-psoriasis'),
('TRG-014','Pregnancy/hormonal transition','Physiologic','Relevant especially to pustular psoriasis in susceptible patients','Recognized','Pregnancy status and obstetric context','https://pubmed.ncbi.nlm.nih.gov/39732527/'),
('TRG-015','Friction/sweat/occlusion','Mechanical/environment','Inverse/genital/folds','Recognized','Site-level exposure log','https://www.psoriasis.org/inverse-psoriasis/')
ON DUPLICATE KEY UPDATE trigger_name=VALUES(trigger_name),evidence_note=VALUES(evidence_note),ilmb_measurement=VALUES(ilmb_measurement),source_url=VALUES(source_url);

INSERT INTO ilb_psoriasis_comorbidity(comorbidity_id,condition_name,system_name,association_note,screening_clues,measurement_or_action,ilmb_note,source_url) VALUES
('COM-001','Psoriatic arthritis','Musculoskeletal','~1 in 3 is commonly cited by NPF','Joint pain/swelling, morning stiffness, dactylitis, heel pain, nail disease','PEST; rheumatology referral if positive/clinical concern','Joint damage can become irreversible; screen regularly.','https://www.psoriasis.org/psoriatic-arthritis-screening-test/'),
('COM-002','Obesity','Metabolic','Common association','BMI/waist/adiposity','Anthropometry','Can influence disease burden and treatment response.','https://pubmed.ncbi.nlm.nih.gov/33812489/'),
('COM-003','Metabolic syndrome','Metabolic','Increased association','Waist, BP, glucose/HbA1c, lipids','Standard cardiometabolic assessment','Whole-body risk management matters.','https://www.aad.org/member/clinical-quality/guidelines/psoriasis'),
('COM-004','Type 2 diabetes','Metabolic','Increased association','HbA1c/glucose','Standard medical screening','Manage independently according to guidelines.','https://www.aad.org/member/clinical-quality/guidelines/psoriasis'),
('COM-005','Cardiovascular disease','Cardiovascular','Increased risk particularly with more severe disease','BP, lipids, smoking, diabetes, family history','Standard cardiovascular risk assessment','Psoriasis is a systemic inflammatory risk context, not a standalone CVD diagnosis.','https://www.aad.org/member/clinical-quality/guidelines/psoriasis'),
('COM-006','Depression/anxiety','Mental health','Common burden association','Mood, function, suicidality when indicated','Validated mental-health tools','Quality-of-life and safety matter.','https://pubmed.ncbi.nlm.nih.gov/33812489/'),
('COM-007','Inflammatory bowel disease','Gastrointestinal','Association with Crohn disease/ulcerative colitis','GI symptoms/history','Medical evaluation if symptomatic','Can influence biologic choice.','https://www.aad.org/member/clinical-quality/guidelines/psoriasis'),
('COM-008','Uveitis','Ophthalmic','Associated especially with PsA context','Eye pain/redness/photophobia/vision change','Urgent ophthalmic assessment if suspected','Eye symptoms require prompt evaluation.','https://www.aad.org/member/clinical-quality/guidelines/psoriasis'),
('COM-009','Sleep disturbance / sleep apnea','Sleep','Association with psoriasis and obesity','Sleep quality, snoring, daytime sleepiness','Validated sleep tools / sleep evaluation','Sleep disruption can worsen quality of life.','https://dermnetnz.org/topics/treatment-of-psoriasis'),
('COM-010','Fatty liver / MASLD','Hepatic/metabolic','Association via metabolic risk and some therapies','Liver history, enzymes, metabolic profile','Standard medical assessment','Important when considering systemic therapy.','https://www.aad.org/member/clinical-quality/guidelines/psoriasis')
ON DUPLICATE KEY UPDATE condition_name=VALUES(condition_name),association_note=VALUES(association_note),measurement_or_action=VALUES(measurement_or_action),ilmb_note=VALUES(ilmb_note),source_url=VALUES(source_url);
