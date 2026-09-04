-- Phase 77: governed registry for the published Shmarov et al. psoriasis SBML model.
-- The source artifact is imported separately and remains research-only.
START TRANSACTION;

CREATE TABLE IF NOT EXISTS ilb_psoriasis_model_source (
 model_key varchar(100) NOT NULL,
 title varchar(500) NOT NULL,
 publication_doi varchar(160) NOT NULL,
 publication_url varchar(1000) NOT NULL,
 artifact_path varchar(500) NOT NULL,
 upstream_url varchar(1000) NOT NULL,
 upstream_git_blob_sha1 char(40) NOT NULL,
 artifact_sha256 char(64) NOT NULL,
 license_spdx varchar(40) NOT NULL,
 model_scope varchar(1800) NOT NULL,
 provenance_status enum('PEER_REVIEWED_MODEL','SOURCE_CODE_EXACT','ASSUMPTION_BASED_REDUCED_MODEL') NOT NULL,
 patient_execution_status enum('BLOCKED','RESEARCH_ONLY','VALIDATED_FOR_DECLARED_USE') NOT NULL DEFAULT 'BLOCKED',
 imported_at timestamp NULL,
 PRIMARY KEY(model_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ilb_psoriasis_sbml_species (
 model_key varchar(100) NOT NULL,
 sbml_id varchar(160) NOT NULL,
 symbol varchar(160) NOT NULL,
 compartment_id varchar(160) NOT NULL,
 initial_value decimal(30,12) DEFAULT NULL,
 initial_value_kind enum('AMOUNT','CONCENTRATION','UNSPECIFIED') NOT NULL,
 boundary_condition tinyint(1) NOT NULL,
 constant_flag tinyint(1) NOT NULL,
 state_role enum('BIOLOGICAL_STATE','CLINICAL_OUTPUT','DERIVED_OUTPUT','THERAPY_INPUT','OTHER') NOT NULL,
 measurement_gate enum('DIRECT_MEASUREMENT_REQUIRED','OBSERVATION_MODEL_REQUIRED','INPUT_REQUIRED','DERIVED','NOT_APPLICABLE') NOT NULL,
 PRIMARY KEY(model_key,sbml_id),
 KEY idx_p77_species_symbol(symbol)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ilb_psoriasis_sbml_parameter (
 model_key varchar(100) NOT NULL,
 parameter_scope varchar(220) NOT NULL,
 sbml_id varchar(160) NOT NULL,
 symbol varchar(160) NOT NULL,
 parameter_value decimal(30,12) DEFAULT NULL,
 declared_units varchar(160) DEFAULT NULL,
 constant_flag tinyint(1) NOT NULL,
 provenance_class enum('PUBLISHED_MODEL_VALUE','PATIENT_FITTED','ASSUMED','DERIVED','UNCLASSIFIED') NOT NULL DEFAULT 'UNCLASSIFIED',
 execution_gate enum('ALLOWED_FOR_REPRODUCTION','SOURCE_REVIEW_REQUIRED','PATIENT_VALUE_REQUIRED') NOT NULL DEFAULT 'SOURCE_REVIEW_REQUIRED',
 PRIMARY KEY(model_key,parameter_scope,sbml_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ilb_psoriasis_sbml_reaction (
 model_key varchar(100) NOT NULL,
 sbml_id varchar(160) NOT NULL,
 reaction_name varchar(300) NOT NULL,
 reversible_flag tinyint(1) NOT NULL,
 kinetic_mathml mediumtext NOT NULL,
 computation_status enum('SOURCE_EXACT_REACTION','BLOCKED_PARAMETER_PROVENANCE','EXECUTABLE') NOT NULL,
 PRIMARY KEY(model_key,sbml_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ilb_psoriasis_sbml_reaction_species (
 model_key varchar(100) NOT NULL,
 reaction_id varchar(160) NOT NULL,
 species_id varchar(160) NOT NULL,
 participation enum('REACTANT','PRODUCT','MODIFIER') NOT NULL,
 stoichiometry decimal(24,12) DEFAULT NULL,
 PRIMARY KEY(model_key,reaction_id,species_id,participation)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ilb_psoriasis_model_gate (
 model_key varchar(100) NOT NULL,
 gate_code varchar(100) NOT NULL,
 gate_order smallint unsigned NOT NULL,
 gate_name varchar(300) NOT NULL,
 requirement_text varchar(2400) NOT NULL,
 status enum('PASSED','RESEARCH_GATE','MEASUREMENT_REQUIRED','BLOCKED') NOT NULL,
 evidence_note varchar(2400) NOT NULL,
 PRIMARY KEY(model_key,gate_code),
 UNIQUE KEY uq_p77_gate_order(model_key,gate_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO ilb_psoriasis_model_source
(model_key,title,publication_doi,publication_url,artifact_path,upstream_url,upstream_git_blob_sha1,artifact_sha256,license_spdx,model_scope,provenance_status,patient_execution_status)
VALUES
('SHMAROV_2022_FULL','Individualised computational modelling of immune mediated disease onset, flare and clearance in psoriasis','10.1371/journal.pcbi.1010267','https://journals.plos.org/ploscompbiol/article?id=10.1371/journal.pcbi.1010267','sources/psoriasis/Shmarov_2022_psor_v8_4.xml','https://github.com/pzuliani/psoriasis/blob/main/models/psor_v8_4.xml','3ca80555247c47b321367e385e9f65ff846486e4','99db820fca593cde4d4e8c0519ef63f946be24d1a4d5329c48c78cf3203ef1c9','Apache-2.0','Published multi-species ODE/SBML research model of epidermal and immune dynamics, UVB phototherapy, PASI observation and selected biologic simulations. Not a universal physiological law or autonomous prescribing model.','PEER_REVIEWED_MODEL','RESEARCH_ONLY'),
('SHMAROV_SIMPLE_2D','Exploratory two-state keratinocyte/immune-cell parameter construction','10.1371/journal.pcbi.1010267','https://github.com/pzuliani/psoriasis/blob/main/matlab/simple_model.m','scripts/psoriasis_skin_state.php','https://github.com/pzuliani/psoriasis/blob/main/matlab/simple_model.m','7250518325474b98697c68709d5b7d4af206ef07','ee8f8c875b86141d6ba91c8d7f944ad0872e17cdedbae41183e5dc5a1642804b','Apache-2.0','Exact software port of an exploratory helper whose healthy, psoriatic and transition states are constructed from declared assumptions. It is retained for reproduction and phase-plane research only.','ASSUMPTION_BASED_REDUCED_MODEL','BLOCKED')
ON DUPLICATE KEY UPDATE title=VALUES(title),publication_doi=VALUES(publication_doi),publication_url=VALUES(publication_url),artifact_path=VALUES(artifact_path),upstream_url=VALUES(upstream_url),upstream_git_blob_sha1=VALUES(upstream_git_blob_sha1),artifact_sha256=VALUES(artifact_sha256),license_spdx=VALUES(license_spdx),model_scope=VALUES(model_scope),provenance_status=VALUES(provenance_status),patient_execution_status=VALUES(patient_execution_status);

INSERT INTO ilb_psoriasis_model_gate VALUES
('SHMAROV_2022_FULL','G1_ARTIFACT_IDENTITY',1,'Source artifact identity','Bundled SBML SHA-256 must equal the preregistered digest from the upstream file.','PASSED','Importer refuses any mismatched artifact.'),
('SHMAROV_2022_FULL','G2_STRUCTURAL_IMPORT',2,'Exact SBML structural import','Import all compartments, species, global/local parameters, reactions and reaction participants without translating names or inventing equations.','RESEARCH_GATE','Set to passed only by the production importer after exact count verification.'),
('SHMAROV_2022_FULL','G3_PARAMETER_PROVENANCE',3,'Parameter provenance','Every parameter must be classified as published, assumed, derived or patient-fitted from the paper/S1 text.','RESEARCH_GATE','Unclassified parameters block numerical patient use.'),
('SHMAROV_2022_FULL','G4_OBSERVATION_MODEL',4,'Patient observation model','Map measured PASI and declared biomarkers to model states with units, compartment, method and time.','MEASUREMENT_REQUIRED','PASI alone cannot identify all internal states.'),
('SHMAROV_2022_FULL','G5_PATIENT_IDENTIFIABILITY',5,'Patient parameter identifiability','Demonstrate which patient-specific parameters can be estimated from available observations and report uncertainty.','BLOCKED','No patient execution until identifiability is established.'),
('SHMAROV_2022_FULL','G6_EXTERNAL_VALIDATION',6,'External clinical validation','Validate predictions on an independent cohort for the exact declared use.','BLOCKED','Original fitting is not sufficient for autonomous clinical use.'),
('SHMAROV_2022_FULL','G7_SAFETY_RELEASE',7,'Clinical safety release','Human clinical review, contraindication handling and non-autonomous decision policy must pass.','BLOCKED','No diagnosis or prescribing is enabled.'),
('SHMAROV_SIMPLE_2D','R1_PROVENANCE',1,'Reduced-model provenance','Expose assumptions and distinguish reproduction from physiological validation.','PASSED','Transition is constructed as 10 percent of assumed thickness difference; immune infiltration k4=100 is explicitly assumed in source.'),
('SHMAROV_SIMPLE_2D','R2_PATIENT_USE',2,'Reduced-model patient-use gate','Do not interpret K/T thresholds as patient targets without a validated observation and parameter model.','BLOCKED','No validated PASI-to-K/T or non-drug-input mapping exists.')
ON DUPLICATE KEY UPDATE gate_order=VALUES(gate_order),gate_name=VALUES(gate_name),requirement_text=VALUES(requirement_text),status=VALUES(status),evidence_note=VALUES(evidence_note);

CREATE OR REPLACE VIEW v_ilmb_psoriasis_published_model_readiness AS
SELECT
 s.model_key,
 s.provenance_status,
 s.patient_execution_status,
 (SELECT COUNT(*) FROM ilb_psoriasis_sbml_species x WHERE x.model_key=s.model_key) species_count,
 (SELECT COUNT(*) FROM ilb_psoriasis_sbml_parameter x WHERE x.model_key=s.model_key) parameter_count,
 (SELECT COUNT(*) FROM ilb_psoriasis_sbml_reaction x WHERE x.model_key=s.model_key) reaction_count,
 (SELECT COUNT(*) FROM ilb_psoriasis_model_gate g WHERE g.model_key=s.model_key AND g.status='PASSED') passed_gates,
 (SELECT COUNT(*) FROM ilb_psoriasis_model_gate g WHERE g.model_key=s.model_key AND g.status IN ('RESEARCH_GATE','MEASUREMENT_REQUIRED','BLOCKED')) open_gates,
 CASE WHEN s.patient_execution_status='VALIDATED_FOR_DECLARED_USE'
   AND NOT EXISTS (SELECT 1 FROM ilb_psoriasis_model_gate g WHERE g.model_key=s.model_key AND g.status<>'PASSED')
 THEN 1 ELSE 0 END patient_execution_enabled
FROM ilb_psoriasis_model_source s;

COMMIT;
