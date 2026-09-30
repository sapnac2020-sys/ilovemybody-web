-- ILMB Energy Healing Research Department: additive implementation draft.
-- No patient records, efficacy claims, or changes to existing treatment models.
CREATE TABLE IF NOT EXISTS ilb_ehr_department (
 department_code VARCHAR(64) PRIMARY KEY,
 department_name VARCHAR(255) NOT NULL,
 mission TEXT NOT NULL,
 publication_status ENUM('DRAFT','PUBLISHED','ARCHIVED') NOT NULL DEFAULT 'DRAFT'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_ehr_practice (
 practice_code VARCHAR(64) PRIMARY KEY,
 department_code VARCHAR(64) NOT NULL,
 practice_name VARCHAR(255) NOT NULL,
 description_text TEXT NULL,
 review_status ENUM('NOT_REVIEWED','IN_REVIEW','REVIEWED') NOT NULL DEFAULT 'NOT_REVIEWED',
 publication_status ENUM('DRAFT','PUBLISHED','ARCHIVED') NOT NULL DEFAULT 'DRAFT',
 FOREIGN KEY (department_code) REFERENCES ilb_ehr_department(department_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_ehr_source (
 source_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 source_key VARCHAR(120) NOT NULL UNIQUE,
 title TEXT NOT NULL,
 source_type ENUM('TEACHING','BOOK','TRIAL','REVIEW','MEASUREMENT_STUDY','REGISTRY','OTHER') NOT NULL,
 source_url TEXT NULL,
 citation_text TEXT NOT NULL,
 full_text_rights ENUM('LINK_ONLY','PERMISSION','OPEN_LICENCE','PUBLIC_DOMAIN') NOT NULL DEFAULT 'LINK_ONLY',
 rights_record TEXT NULL,
 correction_check TEXT NULL,
 checked_at DATETIME NULL,
 publication_status ENUM('DRAFT','PUBLISHED','ARCHIVED') NOT NULL DEFAULT 'DRAFT'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_ehr_claim (
 claim_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 claim_key VARCHAR(120) NOT NULL UNIQUE,
 practice_code VARCHAR(64) NOT NULL,
 claim_text TEXT NOT NULL,
 claim_kind ENUM('TEACHING','OUTCOME','MECHANISM','CONNECTION') NOT NULL,
 population_text TEXT NULL,
 outcome_text TEXT NULL,
 evidence_status ENUM('NOT_REVIEWED','INSUFFICIENT','MIXED','PRELIMINARY','SUPPORTED','REFUTED') NOT NULL DEFAULT 'NOT_REVIEWED',
 conclusion_text TEXT NULL,
 reviewed_by VARCHAR(255) NULL,
 reviewed_at DATETIME NULL,
 publication_status ENUM('DRAFT','PUBLISHED','ARCHIVED') NOT NULL DEFAULT 'DRAFT',
 FOREIGN KEY (practice_code) REFERENCES ilb_ehr_practice(practice_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_ehr_evidence_review (
 review_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 claim_id BIGINT UNSIGNED NOT NULL,
 source_id BIGINT UNSIGNED NOT NULL,
 source_locator TEXT NOT NULL,
 study_design TEXT NULL,
 sample_size INT UNSIGNED NULL,
 comparator_text TEXT NULL,
 masking_text TEXT NULL,
 funding_text TEXT NULL,
 findings_text TEXT NOT NULL,
 effect_estimate TEXT NULL,
 uncertainty_text TEXT NULL,
 limitations_text TEXT NOT NULL,
 reviewed_by VARCHAR(255) NOT NULL,
 reviewed_at DATETIME NOT NULL,
 UNIQUE KEY uq_ehr_review (claim_id,source_id),
 FOREIGN KEY (claim_id) REFERENCES ilb_ehr_claim(claim_id),
 FOREIGN KEY (source_id) REFERENCES ilb_ehr_source(source_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_ehr_protocol (
 protocol_code VARCHAR(120) PRIMARY KEY,
 practice_code VARCHAR(64) NOT NULL,
 question_text TEXT NOT NULL,
 primary_endpoint TEXT NOT NULL,
 design_text TEXT NOT NULL,
 analysis_plan TEXT NOT NULL,
 registration_url TEXT NULL,
 ethics_record TEXT NULL,
 research_status ENUM('DRAFT','REGISTERED','RUNNING','COMPLETED') NOT NULL DEFAULT 'DRAFT',
 results_text TEXT NULL,
 publication_status ENUM('DRAFT','PUBLISHED','ARCHIVED') NOT NULL DEFAULT 'DRAFT',
 FOREIGN KEY (practice_code) REFERENCES ilb_ehr_practice(practice_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO ilb_ehr_department(department_code,department_name,mission)
VALUES ('ENERGY_HEALING','Energy Healing Research Department','Understand practices, document experiences, and verify outcomes and proposed mechanisms through reproducible research.')
ON DUPLICATE KEY UPDATE department_name=VALUES(department_name),mission=VALUES(mission);

INSERT INTO ilb_ehr_practice(practice_code,department_code,practice_name) VALUES
('PRANIC_HEALING','ENERGY_HEALING','Pranic Healing'),
('MAGNIFIED_HEALING','ENERGY_HEALING','Magnified Healing'),
('REIKI','ENERGY_HEALING','Reiki'),
('THERAPEUTIC_TOUCH','ENERGY_HEALING','Therapeutic Touch'),
('HEALING_TOUCH','ENERGY_HEALING','Healing Touch'),
('QUANTUM_TOUCH','ENERGY_HEALING','Quantum-Touch'),
('ACCESS_BARS','ENERGY_HEALING','Access Bars'),
('DISTANCE_HEALING','ENERGY_HEALING','Distance healing'),
('CHAKRA_AURA','ENERGY_HEALING','Chakra and aura practices'),
('CRYSTAL_ENERGY','ENERGY_HEALING','Crystal-based energy healing')
ON DUPLICATE KEY UPDATE practice_name=VALUES(practice_name);

-- Verify 1 department and 10 initial scope records; repeat in staging.
SELECT department_code,department_name,publication_status FROM ilb_ehr_department WHERE department_code='ENERGY_HEALING';
SELECT practice_code,practice_name,review_status,publication_status FROM ilb_ehr_practice WHERE department_code='ENERGY_HEALING' ORDER BY practice_code;
