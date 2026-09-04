-- Phase 88: human post-clearance psoriasis tissue evidence.
-- Evidence registry only. No patient data and no executable treatment rule.
START TRANSACTION;

CREATE TABLE IF NOT EXISTS ilb_psoriasis_postclearance_evidence (
 evidence_key varchar(100) NOT NULL,
 publication_year smallint unsigned NOT NULL,
 source_type enum('HUMAN_CLEARED_SKIN','HUMAN_RESOLVED_SKIN') NOT NULL,
 intervention_context varchar(255) NULL,
 measured_compartment varchar(255) NOT NULL,
 observable text NOT NULL,
 persistence_state enum('R','E','F','L','MULTI_STATE') NOT NULL,
 evidence_class enum('DIRECT_CELLULAR','FUNCTIONAL_TISSUE','MIXED_TISSUE_MOLECULAR') NOT NULL,
 state_decision enum('SUPPORTED','CANDIDATE_UNRESOLVED','UNRESOLVED') NOT NULL,
 exact_result text NOT NULL,
 source_id varchar(80) NOT NULL,
 source_url varchar(1000) NOT NULL,
 computation_eligible tinyint(1) NOT NULL DEFAULT 0,
 patient_use_allowed tinyint(1) NOT NULL DEFAULT 0,
 PRIMARY KEY(evidence_key),
 UNIQUE KEY uq_p88_source(source_id,evidence_key),
 KEY idx_p88_state(persistence_state,state_decision)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO ilb_psoriasis_postclearance_evidence
(evidence_key,publication_year,source_type,intervention_context,measured_compartment,observable,persistence_state,evidence_class,state_decision,exact_result,source_id,source_url,computation_eligible,patient_use_allowed)
VALUES
('CHEUK_2014_EPIDERMAL_TRM',2014,'HUMAN_CLEARED_SKIN',NULL,'clinically healed psoriatic epidermis','IL-17/IL-22-capable epidermal resident T-cell populations','R','DIRECT_CELLULAR','SUPPORTED','Epidermal Th22 and Tc17 cells persisted as localized disease memory in clinically healed psoriasis.','PMCID:PMC3962894','https://pmc.ncbi.nlm.nih.gov/articles/PMC3962894/',0,0),
('SEREZAL_2018_RESOLVED_TRM',2018,'HUMAN_RESOLVED_SKIN',NULL,'resolved psoriatic skin','resident T-cell-driven ex vivo tissue responses and association with clinical outcome','R','FUNCTIONAL_TISSUE','SUPPORTED','Resident T cells in resolved psoriasis steered tissue responses that stratified clinical outcome.','PMID:29510191','https://pubmed.ncbi.nlm.nih.gov/29510191/',0,0),
('SUAREZ_2011_RESIDUAL_PROFILE',2011,'HUMAN_RESOLVED_SKIN','three months of etanercept in clinical responders','whole resolved-lesion skin','residual disease genomic profile','MULTI_STATE','MIXED_TISSUE_MOLECULAR','CANDIDATE_UNRESOLVED','A residual disease genomic profile of 248 probe sets remained; mixed whole-skin data cannot uniquely assign the signal to R, E, or F.','PMID:20861854','https://pubmed.ncbi.nlm.nih.gov/20861854/',0,0)
ON DUPLICATE KEY UPDATE
 publication_year=VALUES(publication_year),source_type=VALUES(source_type),intervention_context=VALUES(intervention_context),measured_compartment=VALUES(measured_compartment),observable=VALUES(observable),persistence_state=VALUES(persistence_state),evidence_class=VALUES(evidence_class),state_decision=VALUES(state_decision),exact_result=VALUES(exact_result),source_id=VALUES(source_id),source_url=VALUES(source_url),computation_eligible=VALUES(computation_eligible),patient_use_allowed=VALUES(patient_use_allowed);

COMMIT;
