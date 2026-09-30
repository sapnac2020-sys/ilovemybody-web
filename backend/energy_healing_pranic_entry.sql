-- Pranic Healing first entry: focused initial review, no personal case data.
CREATE TABLE IF NOT EXISTS ilb_ehr_section (
 practice_code VARCHAR(64) NOT NULL,
 section_key VARCHAR(64) NOT NULL,
 position_no INT UNSIGNED NOT NULL,
 title VARCHAR(255) NOT NULL,
 body_text TEXT NOT NULL,
 source_key VARCHAR(120) NULL,
 publication_status ENUM('DRAFT','PUBLISHED','ARCHIVED') NOT NULL DEFAULT 'DRAFT',
 PRIMARY KEY(practice_code,section_key),
 FOREIGN KEY(practice_code) REFERENCES ilb_ehr_practice(practice_code),
 FOREIGN KEY(source_key) REFERENCES ilb_ehr_source(source_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
START TRANSACTION;
INSERT INTO ilb_ehr_source(source_key,title,source_type,source_url,citation_text,correction_check,checked_at,publication_status) VALUES
('WPH_ABOUT','Pranic Healing: organisation description','TEACHING','https://www.worldpranichealing.com/about/pranichealing','World Pranic Healing Foundation, About Pranic Healing.','Not applicable: teaching webpage','2026-09-30','PUBLISHED'),
('WPH_FOUNDER','Founder: organisation account','TEACHING','https://worldpranichealing.com/about/ourfounder','World Pranic Healing Foundation, Our Founder.','Not applicable: teaching webpage','2026-09-30','PUBLISHED'),
('PH_METHOD','Practitioner description of scanning, sweeping and energising','TEACHING','https://pranichealing.com/content/six-quick-steps-greater-energy-and-better-health','PranicHealing.com, Six Quick Steps to Greater Energy and Better Health.','Not applicable: teaching webpage','2026-09-30','PUBLISHED'),
('PH_DEPRESSION','Adjunctive Pranic Healing depression trial','TRIAL','https://pubmed.ncbi.nlm.nih.gov/28836826/','Amelioration of mild and moderate depression through Pranic Healing as adjuvant therapy: randomised double-blind controlled trial. PMID 28836826; PMCID PMC5802541.','Formal correction/retraction search pending','2026-09-30','PUBLISHED')
ON DUPLICATE KEY UPDATE title=VALUES(title),citation_text=VALUES(citation_text),source_url=VALUES(source_url),checked_at=VALUES(checked_at);
INSERT INTO ilb_ehr_section(practice_code,section_key,position_no,title,body_text,source_key,publication_status) VALUES
('PRANIC_HEALING','overview',1,'What is it?','Pranic Healing is a no-touch practice developed by Choa Kok Sui. Its teaching organisation describes prana as life force and attributes healing effects to changes in an energy body. These are the tradition’s explanations, not a measured mechanism.','WPH_ABOUT','PUBLISHED'),
('PRANIC_HEALING','origins',2,'How was it developed?','The foundation describes a synthesis of several Asian traditions. Its founder account describes experiments with clairvoyant collaborators. This records the organisation’s history; independent replication needs its own evidence.','WPH_FOUNDER','PUBLISHED'),
('PRANIC_HEALING','practice',3,'What happens in a session?','Practitioners describe scanning for imbalances, sweeping or cleansing, then energising. These actions can be documented without assuming that what is perceived is a physical energy field.','PH_METHOD','PUBLISHED'),
('PRANIC_HEALING','findings',4,'What has research found?','One small trial analysed 52 adults with mild-to-moderate depression. Both groups received medication; one also received Pranic Healing and the other mock sessions. Median HAM-D score reductions were 11 versus 6.5. This preliminary result concerns adjunctive depression care; it does not establish a cancer effect or demonstrate energy transfer.','PH_DEPRESSION','PUBLISHED'),
('PRANIC_HEALING','measurements',5,'How will we connect measurements?','Session records link to existing results through approved LOINC identities. Original dates, values, specimens and units remain intact. Only compatible measurements should be compared. Practitioner perceptions retain local research labels. Human and veterinary outcomes require separate interpretations.',NULL,'PUBLISHED'),
('PRANIC_HEALING','verification',6,'What can we test next?','Start with a preregistered blinded scanning task and a separate sham-controlled outcome study. Specify the endpoint, comparator, masking, sample-size justification and analysis before collecting data. No experiments have been conducted by this department yet.',NULL,'PUBLISHED'),
('PRANIC_HEALING','boundaries',7,'How should findings be read?','The current entry is a focused initial review, not a systematic review. Reported improvement, practitioner sensation and a verified physical mechanism are different research questions. An experience can guide investigation without being converted into a general cure claim.',NULL,'PUBLISHED'),
('PRANIC_HEALING','library',8,'Books and learning materials','Catalogue books with author, edition and page references. Full-text hosting requires documented permission, an applicable licence or public-domain status. The uploaded chakra book is not published here.',NULL,'PUBLISHED')
ON DUPLICATE KEY UPDATE title=VALUES(title),body_text=VALUES(body_text),source_key=VALUES(source_key),position_no=VALUES(position_no);
INSERT INTO ilb_ehr_claim(claim_key,practice_code,claim_text,claim_kind,population_text,outcome_text,evidence_status,conclusion_text,reviewed_by,reviewed_at,publication_status) VALUES
('PH_NO_TOUCH','PRANIC_HEALING','The tradition describes its practice as no-touch.','TEACHING',NULL,NULL,'SUPPORTED','Supported as a description of the teaching; not an efficacy finding.','ILMB initial source review','2026-09-30','PUBLISHED'),
('PH_ENERGY','PRANIC_HEALING','Changes in prana are proposed to influence the physical body.','MECHANISM',NULL,NULL,'INSUFFICIENT','The selected sources do not independently establish measurable transfer or this causal mechanism.','ILMB initial source review','2026-09-30','PUBLISHED'),
('PH_DEPRESSION_ADJUNCT','PRANIC_HEALING','Adjunctive Pranic Healing may improve depression scores relative to mock sessions.','OUTCOME','Adults with mild-to-moderate depression receiving medication','HAM-D score change','PRELIMINARY','One small trial supports further study; generalisation and mechanism remain unresolved.','ILMB initial source review','2026-09-30','PUBLISHED')
ON DUPLICATE KEY UPDATE claim_text=VALUES(claim_text),conclusion_text=VALUES(conclusion_text);
INSERT INTO ilb_ehr_evidence_review(claim_id,source_id,source_locator,study_design,sample_size,comparator_text,masking_text,funding_text,findings_text,effect_estimate,uncertainty_text,limitations_text,reviewed_by,reviewed_at)
SELECT c.claim_id,s.source_id,'Abstract Methods and Results; full text funding disclosure','Randomised trial',52,'Medication plus mock sessions','Described by authors as double-blind; practitioner blinding cannot be assumed','World Pranic Healing Foundation support reported','Greater HAM-D reduction in the adjunctive group.','Median reduction 11 versus 6.5','Small initial study; no pooled effect estimate','Short follow-up; concurrent medication; foundation involvement; no direct energy measurement.','ILMB initial source review','2026-09-30'
FROM ilb_ehr_claim c JOIN ilb_ehr_source s ON s.source_key='PH_DEPRESSION' WHERE c.claim_key='PH_DEPRESSION_ADJUNCT'
ON DUPLICATE KEY UPDATE findings_text=VALUES(findings_text),limitations_text=VALUES(limitations_text);
UPDATE ilb_ehr_practice SET description_text='No-touch energy-healing tradition; focused initial evidence review.',review_status='IN_REVIEW',publication_status='PUBLISHED' WHERE practice_code='PRANIC_HEALING';
UPDATE ilb_ehr_department SET publication_status='PUBLISHED' WHERE department_code='ENERGY_HEALING';
COMMIT;
