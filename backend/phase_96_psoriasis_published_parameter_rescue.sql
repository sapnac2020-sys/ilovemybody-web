-- Phase 96: rescue source-exact published parameter candidates previously classified as open.
-- Candidate provenance is preserved; alternate-model values are not silently promoted.
START TRANSACTION;

CREATE TABLE IF NOT EXISTS ilb_psoriasis_published_parameter_candidate (
 candidate_key varchar(120) NOT NULL,
 parameter_key varchar(100) NOT NULL,
 candidate_name varchar(255) NOT NULL,
 numeric_value decimal(20,8) NULL,
 unit varchar(80) NULL,
 text_value varchar(1000) NULL,
 source_id varchar(100) NOT NULL,
 source_url varchar(1000) NOT NULL,
 source_model varchar(500) NOT NULL,
 compatibility enum('SAME_MODEL','ALTERNATE_3D_MODEL','PROTOCOL_COMPONENT','NOT_COMPATIBLE') NOT NULL,
 exact_in_source tinyint(1) NOT NULL,
 promotion_allowed tinyint(1) NOT NULL DEFAULT 0,
 reason text NOT NULL,
 PRIMARY KEY(candidate_key),
 KEY idx_p96_parameter(parameter_key),
 CONSTRAINT fk_p96_parameter FOREIGN KEY(parameter_key)
  REFERENCES ilb_psoriasis_experiment_parameter(parameter_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO ilb_psoriasis_published_parameter_candidate VALUES
('P96_IL17_BMM_80','IL17_BLOCK_CONCENTRATION','Bimekizumab concentration in 3D PSO-HSE',80,'microgram/mL','Bimekizumab; applied to the medium reservoir beneath inserts','DOI:10.1038/s42003-024-07226-x','https://www.nature.com/articles/s42003-024-07226-x','Cytokine-primed bilayered human skin equivalent with fibroblasts and keratinocytes','ALTERNATE_3D_MODEL',1,0,'Source-exact 3D-skin value. It is not the T-cell-enriched self-assembly model specified by EXP_PSO_RESET_001, so direct promotion is prohibited.'),
('P96_INTERVENTION_6D','INTERVENTION_DURATION','Biologic intervention observation period',6,'days','Applications at airlift days 6, 8 and 10; sampling at day 12','DOI:10.1038/s42003-024-07226-x','https://www.nature.com/articles/s42003-024-07226-x','Cytokine-primed bilayered human skin equivalent with fibroblasts and keratinocytes','ALTERNATE_3D_MODEL',1,0,'Exact treatment window in a published 3D psoriasis model; model transfer requires an explicit bridge.'),
('P96_RENEWAL_6D','RENEWAL_DURATION','Stimulus-free regeneration period',6,'days','Cytokine stimulus removed at airlift day 6; samples taken at day 12','DOI:10.1038/s42003-024-07226-x','https://www.nature.com/articles/s42003-024-07226-x','Cytokine-primed bilayered human skin equivalent with fibroblasts and keratinocytes','ALTERNATE_3D_MODEL',1,0,'Exact regeneration duration. CK10 and FLG recovered, while high S100A7 and Ki67 persisted, so six days does not establish complete five-state reset.'),
('P96_RECHALLENGE_MIX','RECHALLENGE_STIMULUS','Published multifactorial psoriasis cytokine mixture',NULL,NULL,'IL-17A 10 ng/mL; IL-6 10 ng/mL; IL-22 25 ng/mL; IL-1alpha 10 ng/mL; TNF-alpha 10 ng/mL; added every 2-3 days','DOI:10.1038/s42003-024-07226-x','https://www.nature.com/articles/s42003-024-07226-x','Cytokine-primed bilayered human skin equivalent with fibroblasts and keratinocytes','PROTOCOL_COMPONENT',1,0,'The mixture is source-exact for disease induction, not a published post-reset rechallenge. It is therefore a candidate rechallenge, not a promoted parameter.'),
('P96_RECHALLENGE_6D','RECHALLENGE_DURATION','Published psoriasis-priming response window',6,'days','Initial cytokine priming for six days before withdrawal in the regeneration experiment','DOI:10.1038/s42003-024-07226-x','https://www.nature.com/articles/s42003-024-07226-x','Cytokine-primed bilayered human skin equivalent with fibroblasts and keratinocytes','PROTOCOL_COMPONENT',1,0,'Six days is source-exact for induction; the paper did not perform post-reset rechallenge.'),
('P96_BARRIER_BMM','BARRIER_CANDIDATE_ID','Bimekizumab as barrier-state reference candidate',NULL,NULL,'Bimekizumab (Bimzelx); IL-17A/F blockade restored CLDN1 transcript and increased DSG1 and TJP1 expression','DOI:10.1038/s42003-024-07226-x','https://www.nature.com/articles/s42003-024-07226-x','Cytokine-primed bilayered human skin equivalent with fibroblasts and keratinocytes','ALTERNATE_3D_MODEL',1,0,'Published barrier-associated transcriptional response exists, but this duplicates the IL-17 comparator mechanism and is not an independent barrier intervention.'),
('P96_IL23_MODEL_WARNING','IL23_BLOCK_CONCENTRATION','Risankizumab proof-of-principle model warning',NULL,NULL,'The authors state that IL-23 inhibitors cannot be reflected properly because the induction procedure bypasses dendritic-cell IL-23 biology','DOI:10.1038/s42003-024-07226-x','https://www.nature.com/articles/s42003-024-07226-x','Cytokine-primed bilayered human skin equivalent with fibroblasts and keratinocytes','NOT_COMPATIBLE',1,0,'This source cannot justify an IL-23 reset concentration; its explicit limitation prevents false promotion.')
ON DUPLICATE KEY UPDATE parameter_key=VALUES(parameter_key),candidate_name=VALUES(candidate_name),numeric_value=VALUES(numeric_value),unit=VALUES(unit),text_value=VALUES(text_value),source_id=VALUES(source_id),source_url=VALUES(source_url),source_model=VALUES(source_model),compatibility=VALUES(compatibility),exact_in_source=VALUES(exact_in_source),promotion_allowed=VALUES(promotion_allowed),reason=VALUES(reason);

COMMIT;
