-- ILoveMyBody Phase 106 split seed
-- Extracted verbatim from canonical Phase 106 migration artifact.

INSERT INTO ilb_psoriasis_source(source_id,organization_or_authors,title_text,source_type,date_or_version,url,used_for) VALUES
('SRC-001','National Psoriasis Foundation','Types of Psoriasis','Patient/clinical education','2025-06-24','https://www.psoriasis.org/locations-and-types/','Core phenotype overview'),
('SRC-002','National Psoriasis Foundation','Guttate Psoriasis','Patient/clinical education','2026-03-31','https://www.psoriasis.org/guttate/','Guttate morphology, triggers, differential'),
('SRC-003','National Psoriasis Foundation','Inverse Psoriasis','Patient/clinical education','2026-03-23','https://www.psoriasis.org/inverse-psoriasis/','Inverse phenotype/site details'),
('SRC-004','National Psoriasis Foundation','Pustular Psoriasis','Patient/clinical education','2026-04-06','https://www.psoriasis.org/pustular/','GPP/PPP/ACH clinical classification'),
('SRC-005','National Psoriasis Foundation','Erythrodermic Psoriasis','Patient/clinical education','2026-03-24','https://www.psoriasis.org/erythrodermic-psoriasis/','Emergency phenotype and systemic risk'),
('SRC-006','National Psoriasis Foundation','Nail Psoriasis','Patient/clinical education','2026-04-15','https://www.psoriasis.org/hands-feet-nails/','Nail signs, NAPSI, PsA association'),
('SRC-007','National Psoriasis Foundation','Scalp Psoriasis','Patient/clinical education','2026-08','https://www.psoriasis.org/scalp/','Scalp phenotype/site and differential'),
('SRC-008','National Psoriasis Foundation','Palmoplantar Psoriasis','Patient/clinical education','2025-05','https://www.psoriasis.org/palmoplantar-psoriasis/','Palm/sole high-impact disease'),
('SRC-009','National Psoriasis Foundation','Genital Psoriasis','Patient/clinical education','2026-04','https://www.psoriasis.org/genitals/','Genital high-impact disease'),
('SRC-010','AAD','Psoriasis clinical guideline','Clinical guideline','current','https://www.aad.org/member/clinical-quality/guidelines/psoriasis','Treatment classes, triggers, comorbidities'),
('SRC-011','AAD','Psoriasis biologics','Clinical education','2026-08','https://www.aad.org/public/diseases/psoriasis/treatment/medications/biologics','Current biologic list'),
('SRC-012','Griffiths et al.','Psoriasis. Lancet 2021','Peer-reviewed review','2021','https://pubmed.ncbi.nlm.nih.gov/33812489/','Pathogenesis, genetics, comorbidities, treatment overview'),
('SRC-013','Balan et al.','Histopathological landscape of psoriasiform dermatoses','Peer-reviewed review','2021','https://pubmed.ncbi.nlm.nih.gov/34754910/','Histopathology and differential'),
('SRC-014','Furue et al.','Generalized pustular psoriasis: immunological mechanisms, genetics, and emerging therapeutics','Peer-reviewed review','2025','https://pubmed.ncbi.nlm.nih.gov/39732527/','GPP IL-36 biology'),
('SRC-015','National Psoriasis Foundation','PsA screening test / PEST','Validated screening education','current','https://www.psoriasis.org/psoriatic-arthritis-screening-test/','PsA screening questions and cadence'),
('SRC-016','DermNet','Psoriasis','Clinical reference','current','https://dermnetnz.org/topics/psoriasis','Triggers, clinical patterns, differential'),
('SRC-017','DermNet','Treatment of psoriasis','Clinical reference','current','https://dermnetnz.org/topics/treatment-of-psoriasis','General treatment and trigger avoidance'),
('SRC-018','FDA','Spevigo orphan approvals','Regulatory source','2024','https://www.accessdata.fda.gov/scripts/opdlisting/oopd/detailedIndex.cfm?cfgridkey=651618','GPP indication and expansion'),
('SRC-019','National Psoriasis Foundation','Current biologics on the market','Clinical education','current','https://www.psoriasis.org/current-biologics-on-the-market/','Biologic class roster including IL-36'),
('SRC-020','AAD','Psoriasis diagnosis and treatment','Clinical education','2026','https://www.aad.org/public/diseases/psoriasis/treatment/treatment','Current oral/topical/systemic options')
ON DUPLICATE KEY UPDATE organization_or_authors=VALUES(organization_or_authors),title_text=VALUES(title_text),source_type=VALUES(source_type),date_or_version=VALUES(date_or_version),url=VALUES(url),used_for=VALUES(used_for);

-- Extend the existing Phase 103 intake contract. These are observations, not diagnoses.
INSERT INTO ilb_model_input_definition
(input_id,model_code,input_code,category_code,label,value_domain,canonical_unit_code,time_basis,body_site_required,provenance_required,release_required) VALUES
(SHA2('PSO:IN:PHENOTYPES',256),'PSO_COP_LIFESTYLE_V4','PSORIASIS_PHENOTYPE_CODES','PHENOTYPE','Current psoriasis phenotype code(s)','TEXT',NULL,'assessment date',FALSE,TRUE,TRUE),
(SHA2('PSO:IN:SITES',256),'PSO_COP_LIFESTYLE_V4','PSORIASIS_SITE_CODES','PHENOTYPE','Active psoriasis site code(s)','TEXT',NULL,'assessment date',FALSE,TRUE,TRUE),
(SHA2('PSO:IN:MORPH',256),'PSO_COP_LIFESTYLE_V4','PSORIASIS_MORPHOLOGY_CODES','PHENOTYPE','Observed psoriasis morphology code(s)','TEXT',NULL,'assessment date',TRUE,TRUE,FALSE),
(SHA2('PSO:IN:PEST',256),'PSO_COP_LIFESTYLE_V4','PSA_PEST_SCORE','COMORBIDITY','Psoriatic Arthritis PEST screening score','INTEGER','1','screening date',FALSE,TRUE,FALSE),
(SHA2('PSO:IN:GPP_SYS',256),'PSO_COP_LIFESTYLE_V4','GPP_SYSTEMIC_SIGNAL','SAFETY','Generalized pustular psoriasis systemic safety signal','BOOLEAN',NULL,'continuous/event',FALSE,TRUE,TRUE),
(SHA2('PSO:IN:ERY_SYS',256),'PSO_COP_LIFESTYLE_V4','ERYTHRODERMA_SIGNAL','SAFETY','Erythrodermic psoriasis safety signal','BOOLEAN',NULL,'continuous/event',FALSE,TRUE,TRUE)
ON DUPLICATE KEY UPDATE
 label=VALUES(label),category_code=VALUES(category_code),time_basis=VALUES(time_basis),body_site_required=VALUES(body_site_required),release_required=VALUES(release_required);

CREATE OR REPLACE VIEW v_ilb_psoriasis_encyclopedia_readiness AS
SELECT
 (SELECT COUNT(*) FROM ilb_psoriasis_phenotype) AS phenotypes,
 (SELECT COUNT(*) FROM ilb_psoriasis_site) AS sites,
 (SELECT COUNT(*) FROM ilb_psoriasis_morphology) AS morphology_terms,
 (SELECT COUNT(*) FROM ilb_psoriasis_histopathology) AS histopathology_features,
 (SELECT COUNT(*) FROM ilb_psoriasis_cell) AS cells,
 (SELECT COUNT(*) FROM ilb_psoriasis_bioentity) AS bioentities,
 (SELECT COUNT(*) FROM ilb_psoriasis_pathway_edge) AS pathway_edges,
 (SELECT COUNT(*) FROM ilb_psoriasis_trigger) AS triggers,
 (SELECT COUNT(*) FROM ilb_psoriasis_comorbidity) AS comorbidities,
 (SELECT COUNT(*) FROM ilb_psoriasis_differential) AS differentials,
 (SELECT COUNT(*) FROM ilb_psoriasis_measurement_tool) AS measurement_tools,
 (SELECT COUNT(*) FROM ilb_psoriasis_treatment_class) AS treatment_classes,
 (SELECT COUNT(*) FROM ilb_psoriasis_medicine_reference) AS medicine_refs,
 (SELECT COUNT(*) FROM ilb_psoriasis_modality_reference) AS modality_refs,
 (SELECT COUNT(*) FROM ilb_psoriasis_red_flag) AS red_flags,
 (SELECT COUNT(*) FROM ilb_psoriasis_research_gap) AS research_gaps,
 (SELECT COUNT(*) FROM ilb_psoriasis_source) AS sources,
 (SELECT COUNT(*) FROM ilb_model_input_definition
    WHERE model_code='PSO_COP_LIFESTYLE_V4'
      AND input_code IN ('PSORIASIS_PHENOTYPE_CODES','PSORIASIS_SITE_CODES','PSORIASIS_MORPHOLOGY_CODES','PSA_PEST_SCORE','GPP_SYSTEMIC_SIGNAL','ERYTHRODERMA_SIGNAL')) AS encyclopedia_inputs,
 CASE
   WHEN (SELECT COUNT(*) FROM ilb_psoriasis_red_flag WHERE red_flag_id IN ('RF-001','RF-002') AND action_text LIKE 'URGENT%') = 2
   THEN 'FOUNDATION_READY'
   ELSE 'SAFETY_BLOCKED'
 END AS readiness_status;
