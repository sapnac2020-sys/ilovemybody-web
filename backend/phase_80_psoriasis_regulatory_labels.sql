-- Phase 80: source-exact DailyMed SPL registry for verified psoriasis agents.
START TRANSACTION;
CREATE TABLE IF NOT EXISTS ilb_psoriasis_regulatory_label (
 agent_key varchar(80) NOT NULL,
 rxcui varchar(40) NOT NULL,
 set_id char(36) NOT NULL,
 spl_version varchar(40) NOT NULL,
 published_date_text varchar(80) NOT NULL,
 label_title varchar(1000) NOT NULL,
 source_api_url varchar(1000) NOT NULL,
 label_document_url varchar(1000) NOT NULL,
 source_status enum('DAILYMED_RETURNED','REVIEW_REQUIRED','REJECTED') NOT NULL,
 computation_eligible tinyint(1) NOT NULL DEFAULT 0,
 retrieved_at timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
 PRIMARY KEY(agent_key,set_id),
 KEY idx_p80_rxcui(rxcui),
 KEY idx_p80_set_id(set_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE IF NOT EXISTS ilb_psoriasis_label_section_requirement (
 section_code varchar(80) NOT NULL,
 section_name varchar(240) NOT NULL,
 required_for varchar(600) NOT NULL,
 extraction_status enum('SOURCE_REGISTERED','EXTRACTION_REQUIRED','VERIFIED') NOT NULL,
 patient_use_allowed tinyint(1) NOT NULL DEFAULT 0,
 PRIMARY KEY(section_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO ilb_psoriasis_label_section_requirement VALUES
('INDICATIONS','Indications and usage','Scope and population context','EXTRACTION_REQUIRED',0),
('DOSAGE','Dosage and administration','Dose input function only; not a recommendation','EXTRACTION_REQUIRED',0),
('CONTRAINDICATIONS','Contraindications','Safety exclusion registry','EXTRACTION_REQUIRED',0),
('WARNINGS','Warnings and precautions','Safety-event and monitoring registry','EXTRACTION_REQUIRED',0),
('ADVERSE_REACTIONS','Adverse reactions','Observed regulatory safety evidence','EXTRACTION_REQUIRED',0),
('CLINICAL_PHARMACOLOGY','Clinical pharmacology','Mechanism and pharmacodynamic context','EXTRACTION_REQUIRED',0),
('PHARMACOKINETICS','Pharmacokinetics','Sourced PK parameter candidates with population context','EXTRACTION_REQUIRED',0),
('IMMUNOGENICITY','Immunogenicity','Anti-drug antibody context and uncertainty','EXTRACTION_REQUIRED',0)
ON DUPLICATE KEY UPDATE section_name=VALUES(section_name),required_for=VALUES(required_for),extraction_status=VALUES(extraction_status),patient_use_allowed=VALUES(patient_use_allowed);
COMMIT;
