-- Phase 90: source-bound psoriasis disease-modification candidate matrix.
START TRANSACTION;
CREATE TABLE IF NOT EXISTS ilb_psoriasis_candidate (
 candidate_key varchar(80) NOT NULL,
 candidate_name varchar(160) NOT NULL,
 domain enum('PHARMACEUTICAL','LIGHT','NUTRITIONAL_MOLECULE','MICROBIOME','NEUROBEHAVIOURAL') NOT NULL,
 evidence_model enum('HUMAN','3D_SKIN','HUMAN_AND_3D') NOT NULL,
 combination_context varchar(255) NULL,
 source_id varchar(80) NOT NULL,
 source_url varchar(1000) NOT NULL,
 PRIMARY KEY(candidate_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE IF NOT EXISTS ilb_psoriasis_candidate_state_evidence (
 candidate_key varchar(80) NOT NULL,
 state_key char(1) NOT NULL,
 evidence_status enum('SUPPORTED_DIRECTION','CONFLICTING','NOT_MEASURED','NOT_ESTABLISHED') NOT NULL,
 observed_result text NULL,
 direct_state_measurement tinyint(1) NOT NULL DEFAULT 0,
 withdrawal_tested tinyint(1) NOT NULL DEFAULT 0,
 rechallenge_tested tinyint(1) NOT NULL DEFAULT 0,
 PRIMARY KEY(candidate_key,state_key),
 CONSTRAINT fk_p90_candidate FOREIGN KEY(candidate_key) REFERENCES ilb_psoriasis_candidate(candidate_key),
 CONSTRAINT fk_p90_state FOREIGN KEY(state_key) REFERENCES ilb_psoriasis_skin_state_variable(state_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO ilb_psoriasis_candidate VALUES
('GUSELKUMAB_IL23','guselkumab / IL-23p19 blockade','PHARMACEUTICAL','HUMAN',NULL,'PMCID:PMC8438891','https://pmc.ncbi.nlm.nih.gov/articles/PMC8438891/'),
('NB_UVB','narrowband ultraviolet-B phototherapy','LIGHT','HUMAN',NULL,'PMID:9773769','https://pubmed.ncbi.nlm.nih.gov/9773769/'),
('EPA','eicosapentaenoic acid','NUTRITIONAL_MOLECULE','3D_SKIN',NULL,'PMCID:PMC10509711','https://pmc.ncbi.nlm.nih.gov/articles/PMC10509711/'),
('ALA','alpha-linolenic acid','NUTRITIONAL_MOLECULE','3D_SKIN',NULL,'PMCID:PMC9104007','https://pmc.ncbi.nlm.nih.gov/articles/PMC9104007/'),
('MINDFULNESS_UV','mindfulness audio during UVB or PUVA','NEUROBEHAVIOURAL','HUMAN','Adjunct to UVB or PUVA; not tested alone.','PMID:9773769','https://pubmed.ncbi.nlm.nih.gov/9773769/'),
('LRHAMNOSUS_ADJUVANT','Lactobacillus rhamnosus formula','MICROBIOME','HUMAN','Added to standard care.','PMID:36757438','https://pubmed.ncbi.nlm.nih.gov/36757438/'),
('MULTISTRAIN_PROBIOTIC','multi-strain probiotic supplementation','MICROBIOME','HUMAN',NULL,'PMID:35674759','https://pubmed.ncbi.nlm.nih.gov/35674759/')
ON DUPLICATE KEY UPDATE candidate_name=VALUES(candidate_name),domain=VALUES(domain),evidence_model=VALUES(evidence_model),combination_context=VALUES(combination_context),source_id=VALUES(source_id),source_url=VALUES(source_url);

INSERT INTO ilb_psoriasis_candidate_state_evidence
(candidate_key,state_key,evidence_status,observed_result,direct_state_measurement,withdrawal_tested,rechallenge_tested) VALUES
('GUSELKUMAB_IL23','P','SUPPORTED_DIRECTION','Human lesional molecular and histologic improvement reported.',1,0,0),
('GUSELKUMAB_IL23','D','SUPPORTED_DIRECTION','Epidermal molecular profile moved toward nonlesional skin.',1,0,0),
('GUSELKUMAB_IL23','B','NOT_ESTABLISHED','No source-exact universal barrier-restoration threshold registered.',0,0,0),
('GUSELKUMAB_IL23','I','SUPPORTED_DIRECTION','IL-23 pathway blockade reduced psoriasis inflammatory programme.',1,0,0),
('GUSELKUMAB_IL23','R','NOT_ESTABLISHED','Potential disease modification discussed; elimination of relapse-capable resident memory not proven.',0,0,0),
('NB_UVB','P','NOT_ESTABLISHED','Clinical clearing was measured; proliferation state was not registered from this source.',0,0,0),
('NB_UVB','D','NOT_MEASURED',NULL,0,0,0),('NB_UVB','B','NOT_MEASURED',NULL,0,0,0),('NB_UVB','I','NOT_MEASURED',NULL,0,0,0),('NB_UVB','R','NOT_MEASURED',NULL,0,0,0),
('EPA','P','SUPPORTED_DIRECTION','Proliferation of psoriatic keratinocytes normalised in the 3D model.',1,0,0),
('EPA','D','NOT_ESTABLISHED','Complete differentiation restoration not established.',0,0,0),
('EPA','B','NOT_ESTABLISHED','Functional barrier restoration not established.',0,0,0),
('EPA','I','SUPPORTED_DIRECTION','Proportion of IL-17A-producing T cells diminished in the 3D model.',1,0,0),
('EPA','R','NOT_MEASURED',NULL,0,0,0),
('ALA','P','NOT_ESTABLISHED','Psoriatic phenotype effects reported without a registered universal proliferation threshold.',0,0,0),
('ALA','D','NOT_ESTABLISHED','Complete differentiation restoration not established.',0,0,0),
('ALA','B','NOT_ESTABLISHED','No withdrawal-stable functional barrier result registered.',0,0,0),
('ALA','I','SUPPORTED_DIRECTION','T-cell incorporation and inflammatory crosstalk were modulated in 3D psoriatic skin.',1,0,0),
('ALA','R','NOT_MEASURED',NULL,0,0,0),
('MINDFULNESS_UV','P','NOT_MEASURED',NULL,0,0,0),('MINDFULNESS_UV','D','NOT_MEASURED',NULL,0,0,0),('MINDFULNESS_UV','B','NOT_MEASURED',NULL,0,0,0),('MINDFULNESS_UV','I','NOT_MEASURED',NULL,0,0,0),('MINDFULNESS_UV','R','NOT_MEASURED',NULL,0,0,0),
('LRHAMNOSUS_ADJUVANT','P','NOT_MEASURED',NULL,0,0,0),('LRHAMNOSUS_ADJUVANT','D','NOT_MEASURED',NULL,0,0,0),('LRHAMNOSUS_ADJUVANT','B','NOT_MEASURED',NULL,0,0,0),('LRHAMNOSUS_ADJUVANT','I','NOT_ESTABLISHED','Between-group PASI benefit was not supported; mechanistic state not measured.',0,0,0),('LRHAMNOSUS_ADJUVANT','R','NOT_MEASURED',NULL,0,0,0),
('MULTISTRAIN_PROBIOTIC','P','NOT_MEASURED',NULL,0,0,0),('MULTISTRAIN_PROBIOTIC','D','NOT_MEASURED',NULL,0,0,0),('MULTISTRAIN_PROBIOTIC','B','NOT_MEASURED',NULL,0,0,0),('MULTISTRAIN_PROBIOTIC','I','SUPPORTED_DIRECTION','Serum LPS, hs-CRP and IL-1beta decreased in one small randomized trial; this is systemic, not a direct skin-state measurement.',0,0,0),('MULTISTRAIN_PROBIOTIC','R','NOT_MEASURED',NULL,0,0,0)
ON DUPLICATE KEY UPDATE evidence_status=VALUES(evidence_status),observed_result=VALUES(observed_result),direct_state_measurement=VALUES(direct_state_measurement),withdrawal_tested=VALUES(withdrawal_tested),rechallenge_tested=VALUES(rechallenge_tested);
COMMIT;

-- Deployment trigger: Phase 90 live verification.
