-- ILoveMyBody Phase 106
-- Canonical Psoriasis Encyclopedia foundation.
-- Additive/idempotent. Clinical facts, mechanisms, associations, hypotheses and safety routing remain explicitly separated.
-- This migration does not create a psoriasis cure claim and does not replace clinician diagnosis.

CREATE TABLE IF NOT EXISTS ilb_psoriasis_phenotype (
 phenotype_id VARCHAR(32) PRIMARY KEY,
 name VARCHAR(255) NOT NULL,
 record_type VARCHAR(80) NOT NULL,
 synonyms VARCHAR(255) NULL,
 core_appearance TEXT NOT NULL,
 typical_distribution TEXT NULL,
 course_text TEXT NULL,
 dominant_biology_note TEXT NULL,
 safety_class VARCHAR(80) NOT NULL,
 notes_text TEXT NULL,
 source_url TEXT NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_psoriasis_site (
 site_id VARCHAR(32) PRIMARY KEY,
 site_name VARCHAR(160) NOT NULL,
 site_class VARCHAR(120) NOT NULL,
 common_features TEXT NOT NULL,
 preferred_measurements TEXT NULL,
 key_differentials TEXT NULL,
 clinical_note TEXT NULL,
 source_url TEXT NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_psoriasis_morphology (
 morphology_id VARCHAR(32) PRIMARY KEY,
 term VARCHAR(160) NOT NULL,
 definition_text TEXT NOT NULL,
 commonly_seen_in TEXT NULL,
 notes_text TEXT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_psoriasis_histopathology (
 feature_id VARCHAR(32) PRIMARY KEY,
 feature_name VARCHAR(255) NOT NULL,
 description_text TEXT NOT NULL,
 frequency_or_role VARCHAR(160) NULL,
 diagnostic_note TEXT NULL,
 source_url TEXT NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_psoriasis_cell (
 cell_id VARCHAR(32) PRIMARY KEY,
 cell_type VARCHAR(255) NOT NULL,
 location_text VARCHAR(255) NULL,
 role_class VARCHAR(160) NULL,
 psoriasis_role TEXT NOT NULL,
 key_receptors_markers TEXT NULL,
 key_outputs TEXT NULL,
 ilmb_note TEXT NULL,
 source_url TEXT NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_psoriasis_bioentity (
 entity_id VARCHAR(32) PRIMARY KEY,
 entity_name VARCHAR(255) NOT NULL,
 entity_type VARCHAR(120) NOT NULL,
 symbol_text VARCHAR(120) NULL,
 main_source_cell VARCHAR(255) NULL,
 target_or_receptor TEXT NULL,
 role_text TEXT NOT NULL,
 expected_state VARCHAR(255) NULL,
 evidence_class VARCHAR(120) NOT NULL,
 source_url TEXT NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_psoriasis_pathway_edge (
 edge_id VARCHAR(32) PRIMARY KEY,
 from_node VARCHAR(255) NOT NULL,
 to_node VARCHAR(255) NOT NULL,
 relation_text VARCHAR(160) NOT NULL,
 mechanistic_note TEXT NOT NULL,
 evidence_class VARCHAR(120) NOT NULL,
 source_url TEXT NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_psoriasis_trigger (
 trigger_id VARCHAR(32) PRIMARY KEY,
 trigger_name VARCHAR(255) NOT NULL,
 category_name VARCHAR(120) NOT NULL,
 phenotype_site_relevance TEXT NULL,
 evidence_note TEXT NOT NULL,
 ilmb_measurement TEXT NULL,
 source_url TEXT NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_psoriasis_comorbidity (
 comorbidity_id VARCHAR(32) PRIMARY KEY,
 condition_name VARCHAR(255) NOT NULL,
 system_name VARCHAR(120) NOT NULL,
 association_note TEXT NOT NULL,
 screening_clues TEXT NULL,
 measurement_or_action TEXT NULL,
 ilmb_note TEXT NULL,
 source_url TEXT NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_psoriasis_differential (
 diff_id VARCHAR(32) PRIMARY KEY,
 psoriasis_context VARCHAR(255) NOT NULL,
 differential_name VARCHAR(255) NOT NULL,
 distinguishing_features TEXT NOT NULL,
 confirmatory_approach TEXT NULL,
 source_url TEXT NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_psoriasis_measurement_tool (
 measure_id VARCHAR(32) PRIMARY KEY,
 abbrev VARCHAR(64) NOT NULL,
 name VARCHAR(255) NOT NULL,
 domain_name VARCHAR(160) NOT NULL,
 what_it_measures TEXT NOT NULL,
 range_text VARCHAR(160) NULL,
 reported_by VARCHAR(120) NULL,
 ilmb_rule TEXT NOT NULL,
 source_url TEXT NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_psoriasis_treatment_class (
 class_id VARCHAR(32) PRIMARY KEY,
 class_name VARCHAR(255) NOT NULL,
 route_or_type VARCHAR(160) NULL,
 mechanism_summary TEXT NOT NULL,
 typical_role TEXT NULL,
 major_safety_theme TEXT NULL,
 governance_text TEXT NOT NULL,
 source_url TEXT NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_psoriasis_medicine_reference (
 drug_id VARCHAR(32) PRIMARY KEY,
 generic_name VARCHAR(255) NOT NULL,
 class_name VARCHAR(255) NOT NULL,
 route_text VARCHAR(120) NULL,
 mechanism_text TEXT NOT NULL,
 psoriasis_role TEXT NULL,
 major_safety_theme TEXT NULL,
 source_url TEXT NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_psoriasis_modality_reference (
 modality_id VARCHAR(32) PRIMARY KEY,
 modality_name VARCHAR(255) NOT NULL,
 domain_name VARCHAR(160) NOT NULL,
 role_type VARCHAR(160) NOT NULL,
 mechanistic_rationale TEXT NULL,
 evidence_position TEXT NOT NULL,
 governance_rule TEXT NOT NULL,
 eligibility_note TEXT NULL,
 source_url TEXT NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_psoriasis_red_flag (
 red_flag_id VARCHAR(32) PRIMARY KEY,
 signal_text VARCHAR(255) NOT NULL,
 concern_text VARCHAR(255) NOT NULL,
 example_features TEXT NOT NULL,
 action_text VARCHAR(255) NOT NULL,
 ilmb_rule TEXT NOT NULL,
 source_url TEXT NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_psoriasis_research_gap (
 gap_id VARCHAR(32) PRIMARY KEY,
 question_title VARCHAR(255) NOT NULL,
 research_question TEXT NOT NULL,
 candidate_variables TEXT NULL,
 required_study_design TEXT NULL,
 priority_text VARCHAR(80) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_psoriasis_source (
 source_id VARCHAR(32) PRIMARY KEY,
 organization_or_authors VARCHAR(255) NOT NULL,
 title_text VARCHAR(512) NOT NULL,
 source_type VARCHAR(160) NOT NULL,
 date_or_version VARCHAR(80) NULL,
 url TEXT NOT NULL,
 used_for TEXT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_subject_psoriasis_phenotype (
 subject_phenotype_id CHAR(64) PRIMARY KEY,
 subject_key VARCHAR(255) NOT NULL,
 episode_key VARCHAR(255) NOT NULL,
 phenotype_id VARCHAR(32) NOT NULL,
 body_site_text VARCHAR(255) NULL,
 status_code ENUM('SUSPECTED','CONFIRMED','ABSENT','RESOLVED','UNKNOWN') NOT NULL DEFAULT 'UNKNOWN',
 assessed_at DATETIME(6) NOT NULL,
 assessed_by VARCHAR(255) NULL,
 source_record_id CHAR(64) NULL,
 CONSTRAINT fk_subject_pso_phenotype FOREIGN KEY(phenotype_id) REFERENCES ilb_psoriasis_phenotype(phenotype_id),
 UNIQUE KEY uq_subject_pso_phenotype(subject_key,episode_key,phenotype_id,body_site_text)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_subject_psoriasis_site (
 subject_site_id CHAR(64) PRIMARY KEY,
 subject_key VARCHAR(255) NOT NULL,
 episode_key VARCHAR(255) NOT NULL,
 site_id VARCHAR(32) NOT NULL,
 active_flag BOOLEAN NOT NULL DEFAULT TRUE,
 severity_measure_code VARCHAR(64) NULL,
 severity_value DECIMAL(18,6) NULL,
 assessed_at DATETIME(6) NOT NULL,
 assessed_by VARCHAR(255) NULL,
 source_record_id CHAR(64) NULL,
 CONSTRAINT fk_subject_pso_site FOREIGN KEY(site_id) REFERENCES ilb_psoriasis_site(site_id),
 UNIQUE KEY uq_subject_pso_site(subject_key,episode_key,site_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_subject_psoriasis_morphology (
 subject_morphology_id CHAR(64) PRIMARY KEY,
 subject_key VARCHAR(255) NOT NULL,
 episode_key VARCHAR(255) NOT NULL,
 morphology_id VARCHAR(32) NOT NULL,
 body_site_text VARCHAR(255) NULL,
 present_flag BOOLEAN NOT NULL DEFAULT TRUE,
 assessed_at DATETIME(6) NOT NULL,
 assessed_by VARCHAR(255) NULL,
 source_record_id CHAR(64) NULL,
 CONSTRAINT fk_subject_pso_morphology FOREIGN KEY(morphology_id) REFERENCES ilb_psoriasis_morphology(morphology_id),
 UNIQUE KEY uq_subject_pso_morphology(subject_key,episode_key,morphology_id,body_site_text)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
