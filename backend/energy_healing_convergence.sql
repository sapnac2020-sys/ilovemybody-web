-- Source-backed teaching comparison, not efficacy or sequence validation.
CREATE TABLE IF NOT EXISTS ilb_ehr_convergence_feature (
 feature_code VARCHAR(64) PRIMARY KEY, feature_name VARCHAR(255) NOT NULL,
 interpretation_limit TEXT NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE IF NOT EXISTS ilb_ehr_convergence_observation (
 feature_code VARCHAR(64) NOT NULL, practice_code VARCHAR(64) NOT NULL,
 action_text TEXT NOT NULL, source_url TEXT NOT NULL, source_locator VARCHAR(255) NOT NULL,
 delivery_scope ENUM('SELF','OTHER','SELF_AND_OTHER','UNSPECIFIED') NOT NULL,
 component_status ENUM('REQUIRED','OPTIONAL','UNSPECIFIED') NOT NULL,
 limitation_text TEXT NOT NULL, source_checked_on DATE NOT NULL,
 finding_status ENUM('TEACHING_SIMILARITY','CLINICALLY_VALIDATED') NOT NULL DEFAULT 'TEACHING_SIMILARITY',
 PRIMARY KEY(feature_code,practice_code),
 FOREIGN KEY(feature_code) REFERENCES ilb_ehr_convergence_feature(feature_code),
 FOREIGN KEY(practice_code) REFERENCES ilb_ehr_practice(practice_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO ilb_ehr_convergence_feature VALUES
('BREATH','Breathing','Compare breathing instructions, duration and optionality. No shared physiological effect has been established.'),
('ATTENTION','Focused attention','Compare attention tasks and recipient experience. Similar wording does not establish an identical mental or biological process.'),
('HANDS','Hand positioning and movement','Compare contact, distance and movement. Hand positions do not measure a proposed subtle-energy field.'),
('CLEARING','Clearing and balancing','Compare the tradition-specific actions behind these terms. The terms are not equivalent to measured toxin removal or a clinical endpoint.')
ON DUPLICATE KEY UPDATE feature_name=VALUES(feature_name),interpretation_limit=VALUES(interpretation_limit);
INSERT INTO ilb_ehr_convergence_observation VALUES
('BREATH','PRANIC_HEALING','Breathing exercises are included in a personal-health teaching outline.','https://pranichealing.com/content/six-quick-steps-greater-energy-and-better-health','Step 2','SELF','UNSPECIFIED','Public overview; exact safe sequence and outcome-specific dose not extracted.','2026-09-30','TEACHING_SIMILARITY'),
('BREATH','MAGNIFIED_HEALING','Phase 1 names breathing as a teaching component.','https://magnifiedhealing.com/phase-1/','Phase 1 overview','SELF_AND_OTHER','UNSPECIFIED','Workshop outline; exact breathing procedure is not supplied here.','2026-09-30','TEACHING_SIMILARITY'),
('BREATH','QUANTUM_TOUCH','The method describes breathwork alongside body awareness.','https://quantumtouch.com/en/','Method overview','UNSPECIFIED','UNSPECIFIED','No outcome-specific procedure or dose established by this overview.','2026-09-30','TEACHING_SIMILARITY'),
('BREATH','THERAPEUTIC_TOUCH','Centering may use breath, imagery, meditation or visualization.','https://therapeutictouch.org/about-us/how-did-therapeutic-touch-begin/the-process-of-therapeutic-touch/','Centering phase','OTHER','OPTIONAL','Alternatives are offered; breathing is not a universal required step.','2026-09-30','TEACHING_SIMILARITY'),
('ATTENTION','QUANTUM_TOUCH','Focused intention is a named component.','https://quantumtouch.com/en/','Method overview','UNSPECIFIED','UNSPECIFIED','Teaching description; no validated energy measurement.','2026-09-30','TEACHING_SIMILARITY'),
('ATTENTION','THERAPEUTIC_TOUCH','Centering involves a quiet, focused state.','https://therapeutictouch.org/about-us/how-did-therapeutic-touch-begin/the-process-of-therapeutic-touch/','Centering phase','OTHER','UNSPECIFIED','Practitioner process; self-practice adaptation not established.','2026-09-30','TEACHING_SIMILARITY'),
('HANDS','PRANIC_HEALING','The overview describes hand scanning, sweeping and energizing.','https://pranichealing.com/content/six-quick-steps-greater-energy-and-better-health','Step 3','SELF','UNSPECIFIED','Traditional sensing is not an instrument measurement of an energy field.','2026-09-30','TEACHING_SIMILARITY'),
('HANDS','THERAPEUTIC_TOUCH','Assessment and clearing use rhythmic hand movements around the recipient.','https://therapeutictouch.org/about-us/how-did-therapeutic-touch-begin/the-process-of-therapeutic-touch/','Assessment and clearing phases','OTHER','UNSPECIFIED','Practitioner process; no inferred self-healing sequence.','2026-09-30','TEACHING_SIMILARITY'),
('HANDS','HEALING_TOUCH','The description includes gentle hand movements and light touch.','https://www.healingtouchprogram.com/what-is-healing-touch','What is Healing Touch','OTHER','UNSPECIFIED','Overview does not specify an outcome-specific sequence.','2026-09-30','TEACHING_SIMILARITY'),
('HANDS','REIKI','Hands are placed lightly on or above the recipient.','https://www.nccih.nih.gov/health/reiki','What is Reiki','OTHER','UNSPECIFIED','NCCIH reports no scientific evidence for the proposed energy field and no clear effectiveness for health purposes.','2026-09-30','TEACHING_SIMILARITY'),
('CLEARING','PRANIC_HEALING','Sweeping is described as cleansing in the teaching framework.','https://pranichealing.com/content/six-quick-steps-greater-energy-and-better-health','Step 3','SELF','UNSPECIFIED','Tradition-specific language; no measured toxin-removal finding.','2026-09-30','TEACHING_SIMILARITY'),
('CLEARING','THERAPEUTIC_TOUCH','Clearing or unruffling precedes balancing within the described process.','https://therapeutictouch.org/about-us/how-did-therapeutic-touch-begin/the-process-of-therapeutic-touch/','Clearing and balancing phases','OTHER','UNSPECIFIED','Traditional process description; not a demonstrated common physical mechanism.','2026-09-30','TEACHING_SIMILARITY'),
('CLEARING','HEALING_TOUCH','The description uses clearing and energizing language.','https://www.healingtouchprogram.com/what-is-healing-touch','What is Healing Touch','OTHER','UNSPECIFIED','Teaching claim; neither field clearance nor clinical efficacy is verified by the description.','2026-09-30','TEACHING_SIMILARITY')
ON DUPLICATE KEY UPDATE action_text=VALUES(action_text),source_url=VALUES(source_url),source_locator=VALUES(source_locator),delivery_scope=VALUES(delivery_scope),component_status=VALUES(component_status),limitation_text=VALUES(limitation_text),source_checked_on=VALUES(source_checked_on),finding_status=VALUES(finding_status);
