-- Process-level comparison foundation. Research records, not treatment instructions.
CREATE TABLE IF NOT EXISTS ilb_ehr_process_map (
 map_code VARCHAR(120) PRIMARY KEY,
 practice_code VARCHAR(64) NOT NULL,
 outcome_label VARCHAR(255) NOT NULL,
 sequence_status ENUM('SOURCE_GAP','PARTIAL','EXTRACTED') NOT NULL DEFAULT 'SOURCE_GAP',
 self_practice_status ENUM('UNKNOWN','DESCRIBED','NOT_DESCRIBED') NOT NULL DEFAULT 'UNKNOWN',
 source_url TEXT NULL,
 source_locator TEXT NOT NULL,
 notes_text TEXT NOT NULL,
 FOREIGN KEY(practice_code) REFERENCES ilb_ehr_practice(practice_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE TABLE IF NOT EXISTS ilb_ehr_process_connection (
 connection_code VARCHAR(120) PRIMARY KEY,
 map_code VARCHAR(120) NOT NULL,
 action_text TEXT NULL,
 tradition_target TEXT NULL,
 biological_target TEXT NULL,
 proposed_effect TEXT NOT NULL,
 relationship_status ENUM('TEACHING','HYPOTHESIS','OBSERVATION','BIOLOGICAL_CONTEXT') NOT NULL,
 modality_causal_status ENUM('NOT_TESTED','INSUFFICIENT','PRELIMINARY','SUPPORTED') NOT NULL DEFAULT 'NOT_TESTED',
 sequence_position INT UNSIGNED NULL,
 source_url TEXT NULL,
 source_locator TEXT NOT NULL,
 evidence_notes TEXT NOT NULL,
 FOREIGN KEY(map_code) REFERENCES ilb_ehr_process_map(map_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
START TRANSACTION;
INSERT INTO ilb_ehr_process_map VALUES
('PH_WEIGHT','PRANIC_HEALING','Weight management','PARTIAL','UNKNOWN','https://register.worldpranichealing.com/courses/batch/47506/uadnch','Pranic Facelift and Pranic Body Sculpting description','Public overview names targets but does not supply ordered weight-specific techniques.'),
('MH_WEIGHT','MAGNIFIED_HEALING','Weight management','SOURCE_GAP','UNKNOWN','https://magnifiedhealing.com/phase-1/','General first-phase outline','No outcome-specific sequence identified. An official-site weight-loss testimonial was located, but it does not supply a reproducible weight-specific sequence; do not substitute the general practice.')
ON DUPLICATE KEY UPDATE source_locator=VALUES(source_locator),notes_text=VALUES(notes_text);
INSERT INTO ilb_ehr_process_connection VALUES
('PH_APPETITE','PH_WEIGHT',NULL,'Colour pranas and unspecified techniques','Appetite and eating behaviour','Regulate appetite and cravings','TEACHING','NOT_TESTED',NULL,'https://register.worldpranichealing.com/courses/batch/47506/uadnch','Workshop learning outcomes','Target described; action sequence and controlled mediator measurements unavailable.'),
('PH_EMOTIONS','PH_WEIGHT',NULL,'Colour pranas and unspecified techniques','Emotion-related eating','Address emotions said to contribute to weight gain','TEACHING','NOT_TESTED',NULL,'https://register.worldpranichealing.com/courses/batch/47506/uadnch','Workshop learning outcomes','Research on emotional eating supports investigation of the target, not efficacy of the unspecified technique.'),
('PH_SELFCONTROL','PH_WEIGHT',NULL,'Colour pranas and unspecified techniques','Behavioural self-regulation','Improve resistance to excessive food intake','TEACHING','NOT_TESTED',NULL,'https://register.worldpranichealing.com/courses/batch/47506/uadnch','Workshop learning outcomes','Do not interpret as a moral judgement or assume a measured behavioural change.'),
('PH_THYROID','PH_WEIGHT',NULL,'Throat chakra','Thyroid gland','Tradition attributes thyroid control to the throat chakra','TEACHING','NOT_TESTED',NULL,NULL,'User-provided The Chakras and their Functions, PDF pages 104–105','General teaching, not an extracted weight-loss step; edition metadata pending.'),
('PH_WAIST','PH_WEIGHT','One distant session lasting 60 minutes','Energy body',NULL,'Immediate waist-circumference reduction','OBSERVATION','INSUFFICIENT',NULL,'https://doi.org/10.18231/j.jpmhh.2023.018','Abstract; publisher-indexed limitations','Full-text methods reviewed on the author-linked ResearchGate record: self-reported waist measurements before and immediately after the session; no control group. Exact healing actions and standardised measurement details are not supplied. No sustained fat-loss inference.'),
('BIO_INTAKE','PH_WEIGHT',NULL,NULL,'Food intake and body weight','Food environment can change intake and weight','BIOLOGICAL_CONTEXT','NOT_TESTED',NULL,'https://pubmed.ncbi.nlm.nih.gov/31105044/','Hall et al., 2019, abstract','Randomised dietary study. Biological context only; does not test Pranic Healing. Linked correction records require review before quantitative reuse.'),
('BIO_EMOTIONS','PH_WEIGHT',NULL,NULL,'Stress and eating behaviour','Stress-eating response varies with emotional eating characteristics','BIOLOGICAL_CONTEXT','NOT_TESTED',NULL,'https://pubmed.ncbi.nlm.nih.gov/22999262/','Cortisol reactivity and distress-induced emotional eating, abstract','Specific study context; not a universal stress-causes-overeating rule and not evidence for an energy intervention.')
ON DUPLICATE KEY UPDATE evidence_notes=VALUES(evidence_notes);
INSERT INTO ilb_ehr_process_connection VALUES
('MH_WEIGHT_ACCOUNT','MH_WEIGHT',NULL,NULL,NULL,'An individual reports weight loss after a healing encounter','OBSERVATION','INSUFFICIENT',NULL,'https://magnifiedhealing.com/testimonials/','Testimonial mentioning weight loss after a video-call healing encounter','Official-site personal account; no quantified weight endpoint, comparator, reproducible weight-specific sequence or independent measurements supplied. The account includes earlier medical care and later learning; it does not establish self-practice causation.')
ON DUPLICATE KEY UPDATE evidence_notes=VALUES(evidence_notes);
COMMIT;
