-- Bounded research follow-up; unresolved gates remain explicit.
CREATE TABLE IF NOT EXISTS ilb_ehr_screen_assessment (
 practice_code VARCHAR(64) NOT NULL, pmid VARCHAR(20) NOT NULL,
 screening_level ENUM('TITLE_METADATA','ABSTRACT','FULL_TEXT') NOT NULL,
 assessed_on DATE NOT NULL, reviewer_text VARCHAR(255) NOT NULL,
 PRIMARY KEY(practice_code,pmid),
 FOREIGN KEY(practice_code,pmid) REFERENCES ilb_ehr_candidate_screen(practice_code,pmid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE TABLE IF NOT EXISTS ilb_ehr_notice_review (
 original_pmid VARCHAR(20) NOT NULL, notice_pmid VARCHAR(20) NOT NULL,
 notice_url TEXT NOT NULL, correction_scope TEXT NOT NULL, remaining_issue TEXT NOT NULL,
 reviewed_on DATE NOT NULL, PRIMARY KEY(original_pmid,notice_pmid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE TABLE IF NOT EXISTS ilb_ehr_database_search (
 practice_code VARCHAR(64) PRIMARY KEY, query_text TEXT NOT NULL,
 platform_text VARCHAR(255) NOT NULL, cutoff_on DATE NOT NULL, searched_on DATE NOT NULL,
 retrieval_status ENUM('OK','ERROR') NOT NULL, result_count INT NULL,
 query_translation TEXT NOT NULL, returned_pmids LONGTEXT NOT NULL, warnings_text TEXT NOT NULL,
 FOREIGN KEY(practice_code) REFERENCES ilb_ehr_practice(practice_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE TABLE IF NOT EXISTS ilb_ehr_research_gate (
 practice_code VARCHAR(64) PRIMARY KEY, checked_on DATE NOT NULL,
 research_complete TINYINT NOT NULL DEFAULT 0,
 summary_text TEXT NOT NULL, next_actions TEXT NOT NULL,
 FOREIGN KEY(practice_code) REFERENCES ilb_ehr_practice(practice_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
START TRANSACTION;
UPDATE ilb_ehr_candidate_screen SET title='Effectiveness of Pranic Healing as complementary therapy on lower urinary tract symptoms and sleep: Single-blind randomized trial.',screening_status='ABSTRACT_APPRAISED',screening_reason='Focused primary appraisal stored with limitations. This is one reviewer, not independent duplicate screening or a complete modality synthesis.' WHERE practice_code='PRANIC_HEALING' AND pmid='39033882';
INSERT INTO ilb_ehr_screen_assessment VALUES ('PRANIC_HEALING','39033882','ABSTRACT','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Amelioration of mild and moderate depression through Pranic Healing as adjuvant therapy: randomised double-blind controlled trial.',screening_status='EXISTING_APPRAISAL',screening_reason='Existing initial depression review; updated full-text and correction review pending.' WHERE practice_code='PRANIC_HEALING' AND pmid='28836826';
INSERT INTO ilb_ehr_screen_assessment VALUES ('PRANIC_HEALING','28836826','ABSTRACT','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Pranic Healing as a Complementary Therapy in Diabetic Foot Ulcer Management: A Randomised, Controlled, Double-Blind Trial.',screening_status='FULL_TEXT_APPRAISED',screening_reason='Focused primary appraisal stored with limitations. This is one reviewer, not independent duplicate screening or a complete modality synthesis.' WHERE practice_code='PRANIC_HEALING' AND pmid='37881236';
INSERT INTO ilb_ehr_screen_assessment VALUES ('PRANIC_HEALING','37881236','FULL_TEXT','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='The effect of pranic healing based on Rogers'' therapeutic touch on cardiorespiratory indices and pain during venipuncture in pediatrics: A randomized clinical trial.',screening_status='IDENTITY_UNCONFIRMED',screening_reason='Named lineage or combined intervention needs primary full-text identification; not attributed to this modality or counted as independent evidence.' WHERE practice_code='PRANIC_HEALING' AND pmid='39667977';
INSERT INTO ilb_ehr_screen_assessment VALUES ('PRANIC_HEALING','39667977','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Time to sense biofield (Prana) experiences between hands: A preliminary single blinded randomized placebo controlled trial.',screening_status='TITLE_ELIGIBLE_EXTRACTION_PENDING',screening_reason='Title/metadata supports retaining this candidate for primary extraction. Full-text eligibility, outcomes, bias and procedure appraisal remain open; no efficacy judgment made.' WHERE practice_code='PRANIC_HEALING' AND pmid='38939830';
INSERT INTO ilb_ehr_screen_assessment VALUES ('PRANIC_HEALING','38939830','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Unveiling the Healing Potential of Energy Therapies in Chronic Obstructive Pulmonary Disease: A Systematic Review and Meta-Analysis With Implications for Nursing Practice.',screening_status='CONTEXT_ONLY',screening_reason='Retained for history, observational context or citation chasing. Not an independent primary efficacy appraisal.' WHERE practice_code='PRANIC_HEALING' AND pmid='41020360';
INSERT INTO ilb_ehr_screen_assessment VALUES ('PRANIC_HEALING','41020360','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Rapid shift of gut microbiome and enrichment of beneficial microbes during arhatic yoga meditation retreat in a single-arm pilot study.',screening_status='TITLE_ELIGIBLE_EXTRACTION_PENDING',screening_reason='Title/metadata supports retaining this candidate for primary extraction. Full-text eligibility, outcomes, bias and procedure appraisal remain open; no efficacy judgment made.' WHERE practice_code='PRANIC_HEALING' AND pmid='39939954';
INSERT INTO ilb_ehr_screen_assessment VALUES ('PRANIC_HEALING','39939954','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Tridosha Influence on Prana Perception and Well-Being: An Exploratory Study of Pranic Healing Techniques Among Ayurveda Students.',screening_status='TITLE_ELIGIBLE_EXTRACTION_PENDING',screening_reason='Title/metadata supports retaining this candidate for primary extraction. Full-text eligibility, outcomes, bias and procedure appraisal remain open; no efficacy judgment made.' WHERE practice_code='PRANIC_HEALING' AND pmid='40837116';
INSERT INTO ilb_ehr_screen_assessment VALUES ('PRANIC_HEALING','40837116','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Corrigendum to "Pranic Healing as a Complementary Therapy in Diabetic Foot Ulcer Management: A Randomised, Controlled, Double-Blind Trial".',screening_status='NOTICE_RECONCILED',screening_reason='Linked notice content reviewed and correction scope recorded; original study limitations remain.' WHERE practice_code='PRANIC_HEALING' AND pmid='39291236';
INSERT INTO ilb_ehr_screen_assessment VALUES ('PRANIC_HEALING','39291236','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='The Need, Feasibility and Willingness to Explore "Meditation on Twin Hearts" as a Self-administered Tool for Mental Health Management among Transgender Women: An Exploratory Survey.',screening_status='TITLE_ELIGIBLE_EXTRACTION_PENDING',screening_reason='Title/metadata supports retaining this candidate for primary extraction. Full-text eligibility, outcomes, bias and procedure appraisal remain open; no efficacy judgment made.' WHERE practice_code='PRANIC_HEALING' AND pmid='34255215';
INSERT INTO ilb_ehr_screen_assessment VALUES ('PRANIC_HEALING','34255215','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Understanding How Pranic Healing Facilitators'' Observed Experiences and Outcomes Arise: A Critical Realist Explanatory Model.',screening_status='TITLE_ELIGIBLE_EXTRACTION_PENDING',screening_reason='Title/metadata supports retaining this candidate for primary extraction. Full-text eligibility, outcomes, bias and procedure appraisal remain open; no efficacy judgment made.' WHERE practice_code='PRANIC_HEALING' AND pmid='42605255';
INSERT INTO ilb_ehr_screen_assessment VALUES ('PRANIC_HEALING','42605255','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Effects of reiki in clinical practice: a systematic review of randomised clinical trials.',screening_status='CONTEXT_ONLY',screening_reason='Retained for history, observational context or citation chasing. Not an independent primary efficacy appraisal.' WHERE practice_code='REIKI' AND pmid='18410352';
INSERT INTO ilb_ehr_screen_assessment VALUES ('REIKI','18410352','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Effect of Reiki on Pain, Anxiety, and Hemodynamic Parameters in Mechanically Ventilated Patients: A Randomized, Single-Blind, and Placebo-Controlled Trial.',screening_status='TITLE_ELIGIBLE_EXTRACTION_PENDING',screening_reason='Title/metadata supports retaining this candidate for primary extraction. Full-text eligibility, outcomes, bias and procedure appraisal remain open; no efficacy judgment made.' WHERE practice_code='REIKI' AND pmid='41051913';
INSERT INTO ilb_ehr_screen_assessment VALUES ('REIKI','41051913','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='A randomised controlled single-blind trial of the efficacy of reiki at benefitting mood and well-being.',screening_status='TITLE_ELIGIBLE_EXTRACTION_PENDING',screening_reason='Title/metadata supports retaining this candidate for primary extraction. Full-text eligibility, outcomes, bias and procedure appraisal remain open; no efficacy judgment made.' WHERE practice_code='REIKI' AND pmid='21584234';
INSERT INTO ilb_ehr_screen_assessment VALUES ('REIKI','21584234','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='The Effect of Reiki on Anxiety, Stress, and Comfort Levels Before Gastrointestinal Endoscopy: A Randomized Sham-Controlled Trial.',screening_status='TITLE_ELIGIBLE_EXTRACTION_PENDING',screening_reason='Title/metadata supports retaining this candidate for primary extraction. Full-text eligibility, outcomes, bias and procedure appraisal remain open; no efficacy judgment made.' WHERE practice_code='REIKI' AND pmid='36272846';
INSERT INTO ilb_ehr_screen_assessment VALUES ('REIKI','36272846','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='The effect of reiki on anxiety, fear, pain, and oxygen saturation in abdominal surgery patients: A randomized controlled trial.',screening_status='TITLE_ELIGIBLE_EXTRACTION_PENDING',screening_reason='Title/metadata supports retaining this candidate for primary extraction. Full-text eligibility, outcomes, bias and procedure appraisal remain open; no efficacy judgment made.' WHERE practice_code='REIKI' AND pmid='36481177';
INSERT INTO ilb_ehr_screen_assessment VALUES ('REIKI','36481177','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='A systematic review of the therapeutic effects of Reiki.',screening_status='CONTEXT_ONLY',screening_reason='Retained for history, observational context or citation chasing. Not an independent primary efficacy appraisal.' WHERE practice_code='REIKI' AND pmid='19922247';
INSERT INTO ilb_ehr_screen_assessment VALUES ('REIKI','19922247','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Effect of Reiki therapy on pain and anxiety in adults: an in-depth literature review of randomized trials with effect size calculations.',screening_status='CONTEXT_ONLY',screening_reason='Retained for history, observational context or citation chasing. Not an independent primary efficacy appraisal.' WHERE practice_code='REIKI' AND pmid='24582620';
INSERT INTO ilb_ehr_screen_assessment VALUES ('REIKI','24582620','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='The effects of reiki on heart rate, blood pressure, body temperature, and stress levels: A pilot randomized, double-blinded, and placebo-controlled study.',screening_status='TITLE_ELIGIBLE_EXTRACTION_PENDING',screening_reason='Title/metadata supports retaining this candidate for primary extraction. Full-text eligibility, outcomes, bias and procedure appraisal remain open; no efficacy judgment made.' WHERE practice_code='REIKI' AND pmid='33639516';
INSERT INTO ilb_ehr_screen_assessment VALUES ('REIKI','33639516','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Massage and Reiki to reduce stress and improve quality of life: a randomized clinical trial.',screening_status='TITLE_ELIGIBLE_EXTRACTION_PENDING',screening_reason='Title/metadata supports retaining this candidate for primary extraction. Full-text eligibility, outcomes, bias and procedure appraisal remain open; no efficacy judgment made.' WHERE practice_code='REIKI' AND pmid='33053005';
INSERT INTO ilb_ehr_screen_assessment VALUES ('REIKI','33053005','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='The Effect of Reiki Applied to Cancer Patients on Pain, Anxiety, and Stress Levels: A Randomized Controlled Study.',screening_status='TITLE_ELIGIBLE_EXTRACTION_PENDING',screening_reason='Title/metadata supports retaining this candidate for primary extraction. Full-text eligibility, outcomes, bias and procedure appraisal remain open; no efficacy judgment made.' WHERE practice_code='REIKI' AND pmid='39828478';
INSERT INTO ilb_ehr_screen_assessment VALUES ('REIKI','39828478','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Is Reiki effective in reducing heart rhythm, cortisol levels, and anxiety and improving biochemical parameters in individuals with cardiac disease? Randomized placebo-controlled trial.',screening_status='TITLE_ELIGIBLE_EXTRACTION_PENDING',screening_reason='Title/metadata supports retaining this candidate for primary extraction. Full-text eligibility, outcomes, bias and procedure appraisal remain open; no efficacy judgment made.' WHERE practice_code='REIKI' AND pmid='38652801';
INSERT INTO ilb_ehr_screen_assessment VALUES ('REIKI','38652801','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Effects of Reiki therapy on quality of life: a meta-analysis of randomized controlled trials.',screening_status='CONTEXT_ONLY',screening_reason='Retained for history, observational context or citation chasing. Not an independent primary efficacy appraisal.' WHERE practice_code='REIKI' AND pmid='40148929';
INSERT INTO ilb_ehr_screen_assessment VALUES ('REIKI','40148929','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Effects of integrating therapeutic touch into a cognitive behavioral pain treatment program. Report of a pilot clinical trial.',screening_status='TITLE_ELIGIBLE_EXTRACTION_PENDING',screening_reason='Title/metadata supports retaining this candidate for primary extraction. Full-text eligibility, outcomes, bias and procedure appraisal remain open; no efficacy judgment made.' WHERE practice_code='THERAPEUTIC_TOUCH' AND pmid='12484105';
INSERT INTO ilb_ehr_screen_assessment VALUES ('THERAPEUTIC_TOUCH','12484105','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Therapeutic touch in the treatment of carpal tunnel syndrome.',screening_status='TITLE_ELIGIBLE_EXTRACTION_PENDING',screening_reason='Title/metadata supports retaining this candidate for primary extraction. Full-text eligibility, outcomes, bias and procedure appraisal remain open; no efficacy judgment made.' WHERE practice_code='THERAPEUTIC_TOUCH' AND pmid='11572538';
INSERT INTO ilb_ehr_screen_assessment VALUES ('THERAPEUTIC_TOUCH','11572538','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='The Effects of Therapeutic Touch on Test Anxiety among Nursing Students: A Randomized Controlled Trial.',screening_status='TITLE_ELIGIBLE_EXTRACTION_PENDING',screening_reason='Title/metadata supports retaining this candidate for primary extraction. Full-text eligibility, outcomes, bias and procedure appraisal remain open; no efficacy judgment made.' WHERE practice_code='THERAPEUTIC_TOUCH' AND pmid='41709616';
INSERT INTO ilb_ehr_screen_assessment VALUES ('THERAPEUTIC_TOUCH','41709616','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Therapeutic Touch in the Management of Responsive Behaviors in Patients with Dementia.',screening_status='TITLE_ELIGIBLE_EXTRACTION_PENDING',screening_reason='Title/metadata supports retaining this candidate for primary extraction. Full-text eligibility, outcomes, bias and procedure appraisal remain open; no efficacy judgment made.' WHERE practice_code='THERAPEUTIC_TOUCH' AND pmid='35340008';
INSERT INTO ilb_ehr_screen_assessment VALUES ('THERAPEUTIC_TOUCH','35340008','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Does therapeutic touch ease the discomfort or distress of patients undergoing stereotactic core breast biopsy? A randomized clinical trial.',screening_status='TITLE_ELIGIBLE_EXTRACTION_PENDING',screening_reason='Title/metadata supports retaining this candidate for primary extraction. Full-text eligibility, outcomes, bias and procedure appraisal remain open; no efficacy judgment made.' WHERE practice_code='THERAPEUTIC_TOUCH' AND pmid='17661855';
INSERT INTO ilb_ehr_screen_assessment VALUES ('THERAPEUTIC_TOUCH','17661855','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Therapeutic touch, nursing practice and contemporary cutaneous wound healing research.',screening_status='CONTEXT_ONLY',screening_reason='Retained for history, observational context or citation chasing. Not an independent primary efficacy appraisal.' WHERE practice_code='THERAPEUTIC_TOUCH' AND pmid='9181407';
INSERT INTO ilb_ehr_screen_assessment VALUES ('THERAPEUTIC_TOUCH','9181407','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='EFFECT OF THERAPEUTIC TOUCH ON PAIN RELATED PARAMETERS IN PATIENTS WITH CANCER: A RANDOMIZED CLINICAL TRIAL.',screening_status='TITLE_ELIGIBLE_EXTRACTION_PENDING',screening_reason='Title/metadata supports retaining this candidate for primary extraction. Full-text eligibility, outcomes, bias and procedure appraisal remain open; no efficacy judgment made.' WHERE practice_code='THERAPEUTIC_TOUCH' AND pmid='27482166';
INSERT INTO ilb_ehr_screen_assessment VALUES ('THERAPEUTIC_TOUCH','27482166','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Therapeutic Touch vs Distraction for Labor Pain: A Randomized Controlled Trial.',screening_status='TITLE_ELIGIBLE_EXTRACTION_PENDING',screening_reason='Title/metadata supports retaining this candidate for primary extraction. Full-text eligibility, outcomes, bias and procedure appraisal remain open; no efficacy judgment made.' WHERE practice_code='THERAPEUTIC_TOUCH' AND pmid='42624695';
INSERT INTO ilb_ehr_screen_assessment VALUES ('THERAPEUTIC_TOUCH','42624695','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Therapeutic touch for healing acute wounds.',screening_status='CONTEXT_ONLY',screening_reason='Retained for history, observational context or citation chasing. Not an independent primary efficacy appraisal.' WHERE practice_code='THERAPEUTIC_TOUCH' AND pmid='14583953';
INSERT INTO ilb_ehr_screen_assessment VALUES ('THERAPEUTIC_TOUCH','14583953','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='The effect of therapeutic touch on pain and anxiety in burn patients.',screening_status='TITLE_ELIGIBLE_EXTRACTION_PENDING',screening_reason='Title/metadata supports retaining this candidate for primary extraction. Full-text eligibility, outcomes, bias and procedure appraisal remain open; no efficacy judgment made.' WHERE practice_code='THERAPEUTIC_TOUCH' AND pmid='9687125';
INSERT INTO ilb_ehr_screen_assessment VALUES ('THERAPEUTIC_TOUCH','9687125','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Effects of Hand Massage and Therapeutic Touch on Comfort and Anxiety Living in a Nursing Home in Turkey: A Randomized Controlled Trial.',screening_status='TITLE_ELIGIBLE_EXTRACTION_PENDING',screening_reason='Title/metadata supports retaining this candidate for primary extraction. Full-text eligibility, outcomes, bias and procedure appraisal remain open; no efficacy judgment made.' WHERE practice_code='THERAPEUTIC_TOUCH' AND pmid='30982141';
INSERT INTO ilb_ehr_screen_assessment VALUES ('THERAPEUTIC_TOUCH','30982141','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Therapeutic Touch in Exercise Videos: A Randomized Experiment of the Impact on the Evaluation of Therapists'' Competence and Viewers'' Self-Reliance.',screening_status='EXCLUDED_WRONG_MODALITY',screening_reason='Primary title/metadata identifies a different intervention or conventional biomedical procedure, not this catalogue method.' WHERE practice_code='THERAPEUTIC_TOUCH' AND pmid='33344958';
INSERT INTO ilb_ehr_screen_assessment VALUES ('THERAPEUTIC_TOUCH','33344958','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Effects of healing touch in clinical practice: a systematic review of randomized clinical trials.',screening_status='CONTEXT_ONLY',screening_reason='Retained for history, observational context or citation chasing. Not an independent primary efficacy appraisal.' WHERE practice_code='HEALING_TOUCH' AND pmid='21228402';
INSERT INTO ilb_ehr_screen_assessment VALUES ('HEALING_TOUCH','21228402','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='[Assessment strategies of the impact of healing touch in nursing care].',screening_status='TITLE_ELIGIBLE_EXTRACTION_PENDING',screening_reason='Title/metadata supports retaining this candidate for primary extraction. Full-text eligibility, outcomes, bias and procedure appraisal remain open; no efficacy judgment made.' WHERE practice_code='HEALING_TOUCH' AND pmid='19642480';
INSERT INTO ilb_ehr_screen_assessment VALUES ('HEALING_TOUCH','19642480','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Healing Touch with Guided Imagery for PTSD in returning active duty military: a randomized controlled trial.',screening_status='TITLE_ELIGIBLE_EXTRACTION_PENDING',screening_reason='Title/metadata supports retaining this candidate for primary extraction. Full-text eligibility, outcomes, bias and procedure appraisal remain open; no efficacy judgment made.' WHERE practice_code='HEALING_TOUCH' AND pmid='23025129';
INSERT INTO ilb_ehr_screen_assessment VALUES ('HEALING_TOUCH','23025129','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Effects of Healing Touch on Postsurgical Adult Outpatients.',screening_status='TITLE_ELIGIBLE_EXTRACTION_PENDING',screening_reason='Title/metadata supports retaining this candidate for primary extraction. Full-text eligibility, outcomes, bias and procedure appraisal remain open; no efficacy judgment made.' WHERE practice_code='HEALING_TOUCH' AND pmid='26453532';
INSERT INTO ilb_ehr_screen_assessment VALUES ('HEALING_TOUCH','26453532','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Evaluation of the effect of Healing Touch on coronary artery bypass grafting recovery: A randomized controlled trial.',screening_status='TITLE_ELIGIBLE_EXTRACTION_PENDING',screening_reason='Title/metadata supports retaining this candidate for primary extraction. Full-text eligibility, outcomes, bias and procedure appraisal remain open; no efficacy judgment made.' WHERE practice_code='HEALING_TOUCH' AND pmid='42475613';
INSERT INTO ilb_ehr_screen_assessment VALUES ('HEALING_TOUCH','42475613','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='A randomized placebo-controlled pilot study of the impact of healing touch on fatigue in breast cancer patients undergoing radiation therapy.',screening_status='TITLE_ELIGIBLE_EXTRACTION_PENDING',screening_reason='Title/metadata supports retaining this candidate for primary extraction. Full-text eligibility, outcomes, bias and procedure appraisal remain open; no efficacy judgment made.' WHERE practice_code='HEALING_TOUCH' AND pmid='24105358';
INSERT INTO ilb_ehr_screen_assessment VALUES ('HEALING_TOUCH','24105358','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Healing Touch as a Method for Supporting Holistic Nursing Practice: A Cluster Randomized Controlled Trial.',screening_status='TITLE_ELIGIBLE_EXTRACTION_PENDING',screening_reason='Title/metadata supports retaining this candidate for primary extraction. Full-text eligibility, outcomes, bias and procedure appraisal remain open; no efficacy judgment made.' WHERE practice_code='HEALING_TOUCH' AND pmid='40495640';
INSERT INTO ilb_ehr_screen_assessment VALUES ('HEALING_TOUCH','40495640','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='The efficacy of healing touch in coronary artery bypass surgery recovery: a randomized clinical trial.',screening_status='TITLE_ELIGIBLE_EXTRACTION_PENDING',screening_reason='Title/metadata supports retaining this candidate for primary extraction. Full-text eligibility, outcomes, bias and procedure appraisal remain open; no efficacy judgment made.' WHERE practice_code='HEALING_TOUCH' AND pmid='18616066';
INSERT INTO ilb_ehr_screen_assessment VALUES ('HEALING_TOUCH','18616066','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Bioenergy for Stress Relief in University Students: A Randomized Controlled Trial.',screening_status='TITLE_ELIGIBLE_EXTRACTION_PENDING',screening_reason='Title/metadata supports retaining this candidate for primary extraction. Full-text eligibility, outcomes, bias and procedure appraisal remain open; no efficacy judgment made.' WHERE practice_code='HEALING_TOUCH' AND pmid='35191790';
INSERT INTO ilb_ehr_screen_assessment VALUES ('HEALING_TOUCH','35191790','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='The effect of healing touch on the pain and mobility of persons with osteoarthritis: a feasibility study.',screening_status='TITLE_ELIGIBLE_EXTRACTION_PENDING',screening_reason='Title/metadata supports retaining this candidate for primary extraction. Full-text eligibility, outcomes, bias and procedure appraisal remain open; no efficacy judgment made.' WHERE practice_code='HEALING_TOUCH' AND pmid='23835011';
INSERT INTO ilb_ehr_screen_assessment VALUES ('HEALING_TOUCH','23835011','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Therapeutic massage and healing touch improve symptoms in cancer.',screening_status='TITLE_ELIGIBLE_EXTRACTION_PENDING',screening_reason='Title/metadata supports retaining this candidate for primary extraction. Full-text eligibility, outcomes, bias and procedure appraisal remain open; no efficacy judgment made.' WHERE practice_code='HEALING_TOUCH' AND pmid='14713325';
INSERT INTO ilb_ehr_screen_assessment VALUES ('HEALING_TOUCH','14713325','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='A pilot study: the effect of healing touch on anxiety, stress, pain, pain medication usage, and physiological measures in hospitalized sickle cell disease adults experiencing a vaso-occlusive pain episode.',screening_status='TITLE_ELIGIBLE_EXTRACTION_PENDING',screening_reason='Title/metadata supports retaining this candidate for primary extraction. Full-text eligibility, outcomes, bias and procedure appraisal remain open; no efficacy judgment made.' WHERE practice_code='HEALING_TOUCH' AND pmid='23817144';
INSERT INTO ilb_ehr_screen_assessment VALUES ('HEALING_TOUCH','23817144','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Quantum touch for reducing transfer anxiety in pediatric emergency admissions: A randomized controlled trial.',screening_status='ABSTRACT_APPRAISED',screening_reason='Focused primary appraisal stored with limitations. This is one reviewer, not independent duplicate screening or a complete modality synthesis.' WHERE practice_code='QUANTUM_TOUCH' AND pmid='40930005';
INSERT INTO ilb_ehr_screen_assessment VALUES ('QUANTUM_TOUCH','40930005','ABSTRACT','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='A systematic review of the quality of research on hands-on and distance healing: clinical and laboratory studies.',screening_status='CONTEXT_ONLY',screening_reason='Retained for history, observational context or citation chasing. Not an independent primary efficacy appraisal.' WHERE practice_code='DISTANCE_HEALING' AND pmid='12776468';
INSERT INTO ilb_ehr_screen_assessment VALUES ('DISTANCE_HEALING','12776468','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Testing the Pagan Prescription: Using a Randomized Controlled Trial to Investigate Pagan Spell-Casting as a Form of Noncontact Healing.',screening_status='TITLE_ELIGIBLE_EXTRACTION_PENDING',screening_reason='Title/metadata supports retaining this candidate for primary extraction. Full-text eligibility, outcomes, bias and procedure appraisal remain open; no efficacy judgment made.' WHERE practice_code='DISTANCE_HEALING' AND pmid='31977236';
INSERT INTO ilb_ehr_screen_assessment VALUES ('DISTANCE_HEALING','31977236','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Two meta-analyses of noncontact healing studies.',screening_status='CONTEXT_ONLY',screening_reason='Retained for history, observational context or citation chasing. Not an independent primary efficacy appraisal.' WHERE practice_code='DISTANCE_HEALING' AND pmid='25457442';
INSERT INTO ilb_ehr_screen_assessment VALUES ('DISTANCE_HEALING','25457442','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Religious and spiritual interventions in mental health care: a systematic review and meta-analysis of randomized controlled clinical trials.',screening_status='CONTEXT_ONLY',screening_reason='Retained for history, observational context or citation chasing. Not an independent primary efficacy appraisal.' WHERE practice_code='DISTANCE_HEALING' AND pmid='26200715';
INSERT INTO ilb_ehr_screen_assessment VALUES ('DISTANCE_HEALING','26200715','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Prayer, randomized controlled trials and distance healing: A response to Dr. Jana.',screening_status='CONTEXT_ONLY',screening_reason='Retained for history, observational context or citation chasing. Not an independent primary efficacy appraisal.' WHERE practice_code='DISTANCE_HEALING' AND pmid='22135451';
INSERT INTO ilb_ehr_screen_assessment VALUES ('DISTANCE_HEALING','22135451','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Sound healing reduces generalized anxiety during the pandemic: A feasibility study.',screening_status='ABSTRACT_APPRAISED',screening_reason='Focused primary appraisal stored with limitations. This is one reviewer, not independent duplicate screening or a complete modality synthesis.' WHERE practice_code='DISTANCE_HEALING' AND pmid='37023932';
INSERT INTO ilb_ehr_screen_assessment VALUES ('DISTANCE_HEALING','37023932','ABSTRACT','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Patient experiences and outcomes in a virtual healing setting: A feasibility study.',screening_status='TITLE_ELIGIBLE_EXTRACTION_PENDING',screening_reason='Title/metadata supports retaining this candidate for primary extraction. Full-text eligibility, outcomes, bias and procedure appraisal remain open; no efficacy judgment made.' WHERE practice_code='DISTANCE_HEALING' AND pmid='37537086';
INSERT INTO ilb_ehr_screen_assessment VALUES ('DISTANCE_HEALING','37537086','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Energy Healers'' Distance Healing Experience.',screening_status='TITLE_ELIGIBLE_EXTRACTION_PENDING',screening_reason='Title/metadata supports retaining this candidate for primary extraction. Full-text eligibility, outcomes, bias and procedure appraisal remain open; no efficacy judgment made.' WHERE practice_code='DISTANCE_HEALING' AND pmid='37165635';
INSERT INTO ilb_ehr_screen_assessment VALUES ('DISTANCE_HEALING','37165635','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Information-processing styles of paranormal healers.',screening_status='CONTEXT_ONLY',screening_reason='Retained for history, observational context or citation chasing. Not an independent primary efficacy appraisal.' WHERE practice_code='DISTANCE_HEALING' AND pmid='8197275';
INSERT INTO ilb_ehr_screen_assessment VALUES ('DISTANCE_HEALING','8197275','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Benefits of Reiki therapy for a severely neutropenic patient with associated influences on a true random number generator.',screening_status='TITLE_ELIGIBLE_EXTRACTION_PENDING',screening_reason='Title/metadata supports retaining this candidate for primary extraction. Full-text eligibility, outcomes, bias and procedure appraisal remain open; no efficacy judgment made.' WHERE practice_code='DISTANCE_HEALING' AND pmid='22132706';
INSERT INTO ilb_ehr_screen_assessment VALUES ('DISTANCE_HEALING','22132706','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='NDRG2 controls COX-2/PGE₂-mediated breast cancer cell migration and invasion.',screening_status='EXCLUDED_WRONG_MODALITY',screening_reason='Primary title/metadata identifies a different intervention or conventional biomedical procedure, not this catalogue method.' WHERE practice_code='DISTANCE_HEALING' AND pmid='25256221';
INSERT INTO ilb_ehr_screen_assessment VALUES ('DISTANCE_HEALING','25256221','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Bioenergy for Stress Relief in University Students: A Randomized Controlled Trial.',screening_status='TITLE_ELIGIBLE_EXTRACTION_PENDING',screening_reason='Title/metadata supports retaining this candidate for primary extraction. Full-text eligibility, outcomes, bias and procedure appraisal remain open; no efficacy judgment made.' WHERE practice_code='CHAKRA_AURA' AND pmid='35191790';
INSERT INTO ilb_ehr_screen_assessment VALUES ('CHAKRA_AURA','35191790','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='A comparative pharmacokinetic evaluation of two aqueous progesterone 25 mg injections in healthy postmenopausal women under fasting conditions: An open-label, balanced, randomized, two-treatment, two-period, two-sequence, single-dose, crossover bioequivalence study.',screening_status='EXCLUDED_WRONG_MODALITY',screening_reason='Primary title/metadata identifies a different intervention or conventional biomedical procedure, not this catalogue method.' WHERE practice_code='CHAKRA_AURA' AND pmid='41641846';
INSERT INTO ilb_ehr_screen_assessment VALUES ('CHAKRA_AURA','41641846','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='A pilot study of an 8-week, group-based, chakra-informed kundalini yoga intervention for adolescents and young adults with diabetes: Feasibility, youth outcomes, and caregiver distress.',screening_status='TITLE_ELIGIBLE_EXTRACTION_PENDING',screening_reason='Title/metadata supports retaining this candidate for primary extraction. Full-text eligibility, outcomes, bias and procedure appraisal remain open; no efficacy judgment made.' WHERE practice_code='CHAKRA_AURA' AND pmid='41833700';
INSERT INTO ilb_ehr_screen_assessment VALUES ('CHAKRA_AURA','41833700','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Phase-I randomized trial of doxorubicin hydrochloride liposome injection versus Caelyx® in multiple myeloma.',screening_status='EXCLUDED_WRONG_MODALITY',screening_reason='Primary title/metadata identifies a different intervention or conventional biomedical procedure, not this catalogue method.' WHERE practice_code='CHAKRA_AURA' AND pmid='28994344';
INSERT INTO ilb_ehr_screen_assessment VALUES ('CHAKRA_AURA','28994344','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='The effect of reiki and acupressure on pain, anxiety and vital signs during femoral sheath removal in patients undergoing percutaneous coronary intervention: A randomized controlled study.',screening_status='TITLE_ELIGIBLE_EXTRACTION_PENDING',screening_reason='Title/metadata supports retaining this candidate for primary extraction. Full-text eligibility, outcomes, bias and procedure appraisal remain open; no efficacy judgment made.' WHERE practice_code='CHAKRA_AURA' AND pmid='39405793';
INSERT INTO ilb_ehr_screen_assessment VALUES ('CHAKRA_AURA','39405793','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Immediate Effect of Nada Yoga Meditation on Energy Levels and Alignment of Seven Chakras as Assessed by Electro-photonic Imaging: A Randomized Controlled Crossover Pilot Study.',screening_status='TITLE_ELIGIBLE_EXTRACTION_PENDING',screening_reason='Title/metadata supports retaining this candidate for primary extraction. Full-text eligibility, outcomes, bias and procedure appraisal remain open; no efficacy judgment made.' WHERE practice_code='CHAKRA_AURA' AND pmid='37119541';
INSERT INTO ilb_ehr_screen_assessment VALUES ('CHAKRA_AURA','37119541','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Effectiveness of Pranic Healing as complementary therapy on lower urinary tract symptoms and sleep: Single-blind randomized trial.',screening_status='TITLE_ELIGIBLE_EXTRACTION_PENDING',screening_reason='Title/metadata supports retaining this candidate for primary extraction. Full-text eligibility, outcomes, bias and procedure appraisal remain open; no efficacy judgment made.' WHERE practice_code='CHAKRA_AURA' AND pmid='39033882';
INSERT INTO ilb_ehr_screen_assessment VALUES ('CHAKRA_AURA','39033882','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Outcomes of Vital Pulp Therapy Using Mineral Trioxide Aggregate or Biodentine: A Prospective Randomized Clinical Trial.',screening_status='EXCLUDED_WRONG_MODALITY',screening_reason='Primary title/metadata identifies a different intervention or conventional biomedical procedure, not this catalogue method.' WHERE practice_code='CHAKRA_AURA' AND pmid='30292451';
INSERT INTO ilb_ehr_screen_assessment VALUES ('CHAKRA_AURA','30292451','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='The Home-Heart-Walk study, a self-administered walk test on perceived physical functioning, and self-care behaviour in people with stable chronic heart failure: A randomized controlled trial.',screening_status='EXCLUDED_WRONG_MODALITY',screening_reason='Primary title/metadata identifies a different intervention or conventional biomedical procedure, not this catalogue method.' WHERE practice_code='CHAKRA_AURA' AND pmid='28857618';
INSERT INTO ilb_ehr_screen_assessment VALUES ('CHAKRA_AURA','28857618','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Reducing Preschool Behavior Problems in an Urban Mental Health Clinic: A Pragmatic, Non-Inferiority Trial.',screening_status='EXCLUDED_WRONG_MODALITY',screening_reason='Primary title/metadata identifies a different intervention or conventional biomedical procedure, not this catalogue method.' WHERE practice_code='CHAKRA_AURA' AND pmid='30768419';
INSERT INTO ilb_ehr_screen_assessment VALUES ('CHAKRA_AURA','30768419','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='A pilot clinical trial of a self-management intervention in patients with a left ventricular assist device.',screening_status='EXCLUDED_WRONG_MODALITY',screening_reason='Primary title/metadata identifies a different intervention or conventional biomedical procedure, not this catalogue method.' WHERE practice_code='CHAKRA_AURA' AND pmid='34342807';
INSERT INTO ilb_ehr_screen_assessment VALUES ('CHAKRA_AURA','34342807','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='An exploratory investigation of human biofield responses to encountering a sacred object.',screening_status='TITLE_ELIGIBLE_EXTRACTION_PENDING',screening_reason='Title/metadata supports retaining this candidate for primary extraction. Full-text eligibility, outcomes, bias and procedure appraisal remain open; no efficacy judgment made.' WHERE practice_code='CHAKRA_AURA' AND pmid='36710104';
INSERT INTO ilb_ehr_screen_assessment VALUES ('CHAKRA_AURA','36710104','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='The fascination of complementary and alternative medicine (CAM).',screening_status='CONTEXT_ONLY',screening_reason='Retained for history, observational context or citation chasing. Not an independent primary efficacy appraisal.' WHERE practice_code='CRYSTAL_ENERGY' AND pmid='17956966';
INSERT INTO ilb_ehr_screen_assessment VALUES ('CRYSTAL_ENERGY','17956966','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='No alternative? The regulation and professionalization of complementary and alternative medicine in the United Kingdom.',screening_status='CONTEXT_ONLY',screening_reason='Retained for history, observational context or citation chasing. Not an independent primary efficacy appraisal.' WHERE practice_code='CRYSTAL_ENERGY' AND pmid='15491893';
INSERT INTO ilb_ehr_screen_assessment VALUES ('CRYSTAL_ENERGY','15491893','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='MOVPE Growth of GaN via Graphene Layers on GaN/Sapphire Templates.',screening_status='EXCLUDED_WRONG_MODALITY',screening_reason='Primary title/metadata identifies a different intervention or conventional biomedical procedure, not this catalogue method.' WHERE practice_code='CRYSTAL_ENERGY' AND pmid='35269273';
INSERT INTO ilb_ehr_screen_assessment VALUES ('CRYSTAL_ENERGY','35269273','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='An Integrative Review of Scientific Evidence for Reconnective Healing.',screening_status='CONTEXT_ONLY',screening_reason='Retained for history, observational context or citation chasing. Not an independent primary efficacy appraisal.' WHERE practice_code='RECONNECTIVE_HEALING' AND pmid='28654301';
INSERT INTO ilb_ehr_screen_assessment VALUES ('RECONNECTIVE_HEALING','28654301','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Comparison of physical therapy with energy healing for improving range of motion in subjects with restricted shoulder mobility.',screening_status='FULL_TEXT_APPRAISED',screening_reason='Focused primary appraisal stored with limitations. This is one reviewer, not independent duplicate screening or a complete modality synthesis.' WHERE practice_code='RECONNECTIVE_HEALING' AND pmid='24327820';
INSERT INTO ilb_ehr_screen_assessment VALUES ('RECONNECTIVE_HEALING','24327820','FULL_TEXT','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Biofield-based therapies: a systematic review of physiological effects on practitioners during healing.',screening_status='CONTEXT_ONLY',screening_reason='Retained for history, observational context or citation chasing. Not an independent primary efficacy appraisal.' WHERE practice_code='RECONNECTIVE_HEALING' AND pmid='24767262';
INSERT INTO ilb_ehr_screen_assessment VALUES ('RECONNECTIVE_HEALING','24767262','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='International Cross-Sectional Study on the Effectiveness of Okada Purifying Therapy, a Biofield Therapy, for the Relief of Various Symptoms.',screening_status='EXCLUDED_WRONG_MODALITY',screening_reason='Primary title/metadata identifies a different intervention or conventional biomedical procedure, not this catalogue method.' WHERE practice_code='RECONNECTIVE_HEALING' AND pmid='32551797';
INSERT INTO ilb_ehr_screen_assessment VALUES ('RECONNECTIVE_HEALING','32551797','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Physiological changes in energy healers during self-practice.',screening_status='IDENTITY_UNCONFIRMED',screening_reason='Named lineage or combined intervention needs primary full-text identification; not attributed to this modality or counted as independent evidence.' WHERE practice_code='RECONNECTIVE_HEALING' AND pmid='22863644';
INSERT INTO ilb_ehr_screen_assessment VALUES ('RECONNECTIVE_HEALING','22863644','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='The Effect of Reconnection to Mechanical Ventilation for 1 Hour After Spontaneous Breathing Trial on Reintubation Among Patients Ventilated for More Than 12 Hours: A Randomized Clinical Trial.',screening_status='EXCLUDED_NAME_COLLISION',screening_reason='Returned title/context concerns conventional biology, surgery, devices or psychology; does not identify this named healing method.' WHERE practice_code='THE_RECONNECTION' AND pmid='33676997';
INSERT INTO ilb_ehr_screen_assessment VALUES ('THE_RECONNECTION','33676997','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Adenosine-Guided Pulmonary Vein Antral Isolation for Paroxysmal Atrial Fibrillation: A Randomized Study.',screening_status='EXCLUDED_NAME_COLLISION',screening_reason='Returned title/context concerns conventional biology, surgery, devices or psychology; does not identify this named healing method.' WHERE practice_code='THE_RECONNECTION' AND pmid='27478152';
INSERT INTO ilb_ehr_screen_assessment VALUES ('THE_RECONNECTION','27478152','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Experimental nerve reconnection: importance of initial repair.',screening_status='EXCLUDED_NAME_COLLISION',screening_reason='Returned title/context concerns conventional biology, surgery, devices or psychology; does not identify this named healing method.' WHERE practice_code='THE_RECONNECTION' AND pmid='2725257';
INSERT INTO ilb_ehr_screen_assessment VALUES ('THE_RECONNECTION','2725257','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='The role of adenosine following pulmonary vein isolation in patients undergoing catheter ablation for atrial fibrillation: a systematic review.',screening_status='EXCLUDED_NAME_COLLISION',screening_reason='Returned title/context concerns conventional biology, surgery, devices or psychology; does not identify this named healing method.' WHERE practice_code='THE_RECONNECTION' AND pmid='23489944';
INSERT INTO ilb_ehr_screen_assessment VALUES ('THE_RECONNECTION','23489944','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='The reconnection of auditory posterior root fibers in the red-eared turtle, Chrysemys scripta elegans.',screening_status='EXCLUDED_NAME_COLLISION',screening_reason='Returned title/context concerns conventional biology, surgery, devices or psychology; does not identify this named healing method.' WHERE practice_code='THE_RECONNECTION' AND pmid='6480526';
INSERT INTO ilb_ehr_screen_assessment VALUES ('THE_RECONNECTION','6480526','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Redo Ablation Following LSI Algorithm-Guided High-Power Short-Duration vs LSI Algorithm-Guided Conventional Radiofrequency for Atrial Fibrillation.',screening_status='EXCLUDED_NAME_COLLISION',screening_reason='Returned title/context concerns conventional biology, surgery, devices or psychology; does not identify this named healing method.' WHERE practice_code='THE_RECONNECTION' AND pmid='42334391';
INSERT INTO ilb_ehr_screen_assessment VALUES ('THE_RECONNECTION','42334391','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Ensuring catheter-tissue contact with intracardiac echocardiography during pulsed-field ablation improves procedure outcome in patients with atrial fibrillation.',screening_status='EXCLUDED_NAME_COLLISION',screening_reason='Returned title/context concerns conventional biology, surgery, devices or psychology; does not identify this named healing method.' WHERE practice_code='THE_RECONNECTION' AND pmid='40414261';
INSERT INTO ilb_ehr_screen_assessment VALUES ('THE_RECONNECTION','40414261','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='The identification of conduction gaps after pulmonary vein isolation using a new electroanatomic mapping system.',screening_status='EXCLUDED_NAME_COLLISION',screening_reason='Returned title/context concerns conventional biology, surgery, devices or psychology; does not identify this named healing method.' WHERE practice_code='THE_RECONNECTION' AND pmid='28823601';
INSERT INTO ilb_ehr_screen_assessment VALUES ('THE_RECONNECTION','28823601','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Persistency of left atrial linear lesions after radiofrequency catheter ablation for atrial fibrillation: Data from an invasive follow-up electrophysiology study.',screening_status='EXCLUDED_NAME_COLLISION',screening_reason='Returned title/context concerns conventional biology, surgery, devices or psychology; does not identify this named healing method.' WHERE practice_code='THE_RECONNECTION' AND pmid='28836709';
INSERT INTO ilb_ehr_screen_assessment VALUES ('THE_RECONNECTION','28836709','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='The role of adenosine challenge in catheter ablation for atrial fibrillation: A systematic review and meta-analysis.',screening_status='EXCLUDED_NAME_COLLISION',screening_reason='Returned title/context concerns conventional biology, surgery, devices or psychology; does not identify this named healing method.' WHERE practice_code='THE_RECONNECTION' AND pmid='28089454';
INSERT INTO ilb_ehr_screen_assessment VALUES ('THE_RECONNECTION','28089454','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Mentalization and Emotional-Cognitive Rigidity as predictors of esketamine''s effects on Treatment-Resistant Depression: Findings from a prospective observational study.',screening_status='EXCLUDED_NAME_COLLISION',screening_reason='Returned title/context concerns conventional biology, surgery, devices or psychology; does not identify this named healing method.' WHERE practice_code='THE_RECONNECTION' AND pmid='40907711';
INSERT INTO ilb_ehr_screen_assessment VALUES ('THE_RECONNECTION','40907711','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Role of the vein of Marshall in atrial fibrillation recurrences after catheter ablation: therapeutic effect of ethanol infusion.',screening_status='EXCLUDED_NAME_COLLISION',screening_reason='Returned title/context concerns conventional biology, surgery, devices or psychology; does not identify this named healing method.' WHERE practice_code='THE_RECONNECTION' AND pmid='22429895';
INSERT INTO ilb_ehr_screen_assessment VALUES ('THE_RECONNECTION','22429895','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Does a Healing Procedure Referring to Theta Rhythms Also Generate Theta Rhythms in the Brain?',screening_status='ABSTRACT_APPRAISED',screening_reason='Focused primary appraisal stored with limitations. This is one reviewer, not independent duplicate screening or a complete modality synthesis.' WHERE practice_code='THETAHEALING' AND pmid='26588598';
INSERT INTO ilb_ehr_screen_assessment VALUES ('THETAHEALING','26588598','ABSTRACT','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Development of a Healthcare Approach Focusing on Subtle Energies: The Case of Eden Energy Medicine.',screening_status='CONTEXT_ONLY',screening_reason='Retained for history, observational context or citation chasing. Not an independent primary efficacy appraisal.' WHERE practice_code='EDEN_ENERGY_MEDICINE' AND pmid='32931459';
INSERT INTO ilb_ehr_screen_assessment VALUES ('EDEN_ENERGY_MEDICINE','32931459','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Managing Mental Health: Eight Extraordinary Vessels.',screening_status='CONTEXT_ONLY',screening_reason='Retained for history, observational context or citation chasing. Not an independent primary efficacy appraisal.' WHERE practice_code='EDEN_ENERGY_MEDICINE' AND pmid='37487162';
INSERT INTO ilb_ehr_screen_assessment VALUES ('EDEN_ENERGY_MEDICINE','37487162','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='The Future of Integrative Health: What Case Managers Need to Know?',screening_status='CONTEXT_ONLY',screening_reason='Retained for history, observational context or citation chasing. Not an independent primary efficacy appraisal.' WHERE practice_code='EDEN_ENERGY_MEDICINE' AND pmid='34846326';
INSERT INTO ilb_ehr_screen_assessment VALUES ('EDEN_ENERGY_MEDICINE','34846326','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Group Coaching Using Energy-Based Practices for Health, Healing, and Personal Growth: Program Design and Training Outcomes.',screening_status='IDENTITY_UNCONFIRMED',screening_reason='Named lineage or combined intervention needs primary full-text identification; not attributed to this modality or counted as independent evidence.' WHERE practice_code='EDEN_ENERGY_MEDICINE' AND pmid='35435869';
INSERT INTO ilb_ehr_screen_assessment VALUES ('EDEN_ENERGY_MEDICINE','35435869','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Effects Induced In Vivo by Exposure to Magnetic Signals Derived From a Healing Technique.',screening_status='FULL_TEXT_APPRAISED',screening_reason='Focused primary appraisal stored with limitations. This is one reviewer, not independent duplicate screening or a complete modality synthesis.' WHERE practice_code='BENGSTON_METHOD' AND pmid='32284695';
INSERT INTO ilb_ehr_screen_assessment VALUES ('BENGSTON_METHOD','32284695','FULL_TEXT','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Transcriptional Changes in Cancer Cells Induced by Exposure to a Healing Method.',screening_status='TITLE_ELIGIBLE_EXTRACTION_PENDING',screening_reason='Title/metadata supports retaining this candidate for primary extraction. Full-text eligibility, outcomes, bias and procedure appraisal remain open; no efficacy judgment made.' WHERE practice_code='BENGSTON_METHOD' AND pmid='30022894';
INSERT INTO ilb_ehr_screen_assessment VALUES ('BENGSTON_METHOD','30022894','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Some implications of the reported effects of Johrei on the viability and proliferation of cultured cancer cells in vitro.',screening_status='EXCLUDED_WRONG_MODALITY',screening_reason='Primary title/metadata identifies a different intervention or conventional biomedical procedure, not this catalogue method.' WHERE practice_code='BENGSTON_METHOD' AND pmid='22385046';
INSERT INTO ilb_ehr_screen_assessment VALUES ('BENGSTON_METHOD','22385046','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Randomized controlled trial of energy healing effects on pain and anxiety in AIS posterior surgery: a pilot study.',screening_status='ABSTRACT_APPRAISED',screening_reason='Focused primary appraisal stored with limitations. This is one reviewer, not independent duplicate screening or a complete modality synthesis.' WHERE practice_code='BRENNAN_HEALING' AND pmid='33683643';
INSERT INTO ilb_ehr_screen_assessment VALUES ('BRENNAN_HEALING','33683643','ABSTRACT','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Pain after hip arthroplasty managed by Brennan Healing Science.',screening_status='TITLE_ELIGIBLE_EXTRACTION_PENDING',screening_reason='Title/metadata supports retaining this candidate for primary extraction. Full-text eligibility, outcomes, bias and procedure appraisal remain open; no efficacy judgment made.' WHERE practice_code='BRENNAN_HEALING' AND pmid='24439097';
INSERT INTO ilb_ehr_screen_assessment VALUES ('BRENNAN_HEALING','24439097','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Polarity Therapy for cancer-related fatigue in patients with breast cancer receiving radiation therapy: a randomized controlled pilot study.',screening_status='FULL_TEXT_APPRAISED',screening_reason='Focused primary appraisal stored with limitations. This is one reviewer, not independent duplicate screening or a complete modality synthesis.' WHERE practice_code='POLARITY_THERAPY' AND pmid='21382958';
INSERT INTO ilb_ehr_screen_assessment VALUES ('POLARITY_THERAPY','21382958','FULL_TEXT','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='[The effect of a polarity intervention on the insomnia and anxiety in middle-aged Quebec women].',screening_status='TITLE_ELIGIBLE_EXTRACTION_PENDING',screening_reason='Title/metadata supports retaining this candidate for primary extraction. Full-text eligibility, outcomes, bias and procedure appraisal remain open; no efficacy judgment made.' WHERE practice_code='POLARITY_THERAPY' AND pmid='31210499';
INSERT INTO ilb_ehr_screen_assessment VALUES ('POLARITY_THERAPY','31210499','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='A randomized trial of a CAM therapy for stress reduction in American Indian and Alaskan Native family caregivers.',screening_status='TITLE_ELIGIBLE_EXTRACTION_PENDING',screening_reason='Title/metadata supports retaining this candidate for primary extraction. Full-text eligibility, outcomes, bias and procedure appraisal remain open; no efficacy judgment made.' WHERE practice_code='POLARITY_THERAPY' AND pmid='19377083';
INSERT INTO ilb_ehr_screen_assessment VALUES ('POLARITY_THERAPY','19377083','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Treatment of radiotherapy-induced fatigue through a nonpharmacological approach.',screening_status='TITLE_ELIGIBLE_EXTRACTION_PENDING',screening_reason='Title/metadata supports retaining this candidate for primary extraction. Full-text eligibility, outcomes, bias and procedure appraisal remain open; no efficacy judgment made.' WHERE practice_code='POLARITY_THERAPY' AND pmid='15695472';
INSERT INTO ilb_ehr_screen_assessment VALUES ('POLARITY_THERAPY','15695472','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Gamma radiation fluctuations during alternative healing therapy.',screening_status='IDENTITY_UNCONFIRMED',screening_reason='Named lineage or combined intervention needs primary full-text identification; not attributed to this modality or counted as independent evidence.' WHERE practice_code='POLARITY_THERAPY' AND pmid='10394674';
INSERT INTO ilb_ehr_screen_assessment VALUES ('POLARITY_THERAPY','10394674','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='A critical review of complementary therapies for cancer-related fatigue.',screening_status='CONTEXT_ONLY',screening_reason='Retained for history, observational context or citation chasing. Not an independent primary efficacy appraisal.' WHERE practice_code='POLARITY_THERAPY' AND pmid='17351022';
INSERT INTO ilb_ehr_screen_assessment VALUES ('POLARITY_THERAPY','17351022','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Respite care for people with dementia and their carers.',screening_status='CONTEXT_ONLY',screening_reason='Retained for history, observational context or citation chasing. Not an independent primary efficacy appraisal.' WHERE practice_code='POLARITY_THERAPY' AND pmid='24435941';
INSERT INTO ilb_ehr_screen_assessment VALUES ('POLARITY_THERAPY','24435941','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Bioenergy therapies as a complementary treatment: a systematic review to evaluate the efficacy of bioenergy therapies in relieving treatment toxicities in patients with cancer.',screening_status='CONTEXT_ONLY',screening_reason='Retained for history, observational context or citation chasing. Not an independent primary efficacy appraisal.' WHERE practice_code='POLARITY_THERAPY' AND pmid='36166091';
INSERT INTO ilb_ehr_screen_assessment VALUES ('POLARITY_THERAPY','36166091','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Fatigue related to radiotherapy for breast and/or gynaecological cancer: a systematic review.',screening_status='CONTEXT_ONLY',screening_reason='Retained for history, observational context or citation chasing. Not an independent primary efficacy appraisal.' WHERE practice_code='POLARITY_THERAPY' AND pmid='23651041';
INSERT INTO ilb_ehr_screen_assessment VALUES ('POLARITY_THERAPY','23651041','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Optimized multichannel 4 mA vs conventional transcranial direct current stimulation for major depressive disorder: A randomized sham-controlled trial.',screening_status='EXCLUDED_WRONG_MODALITY',screening_reason='Primary title/metadata identifies a different intervention or conventional biomedical procedure, not this catalogue method.' WHERE practice_code='POLARITY_THERAPY' AND pmid='41927768';
INSERT INTO ilb_ehr_screen_assessment VALUES ('POLARITY_THERAPY','41927768','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='The use of biofield therapies in cancer care.',screening_status='CONTEXT_ONLY',screening_reason='Retained for history, observational context or citation chasing. Not an independent primary efficacy appraisal.' WHERE practice_code='POLARITY_THERAPY' AND pmid='17573275';
INSERT INTO ilb_ehr_screen_assessment VALUES ('POLARITY_THERAPY','17573275','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Therapeutic potential of galvanic vestibular stimulation for postural and spatial rehabilitation after stroke: A systematic review.',screening_status='EXCLUDED_WRONG_MODALITY',screening_reason='Primary title/metadata identifies a different intervention or conventional biomedical procedure, not this catalogue method.' WHERE practice_code='POLARITY_THERAPY' AND pmid='42766343';
INSERT INTO ilb_ehr_screen_assessment VALUES ('POLARITY_THERAPY','42766343','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Jin Shin Jyutsu® Self-Help Reduces Nurse Stress: A Randomized Controlled Study.',screening_status='ABSTRACT_APPRAISED',screening_reason='Focused primary appraisal stored with limitations. This is one reviewer, not independent duplicate screening or a complete modality synthesis.' WHERE practice_code='JIN_SHIN_JYUTSU' AND pmid='32649851';
INSERT INTO ilb_ehr_screen_assessment VALUES ('JIN_SHIN_JYUTSU','32649851','ABSTRACT','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Correction Statement: Country Affiliations and Conflict of Interest Statements.',screening_status='NOTICE_RECONCILED',screening_reason='Linked notice content reviewed and correction scope recorded; original study limitations remain.' WHERE practice_code='JIN_SHIN_JYUTSU' AND pmid='36398997';
INSERT INTO ilb_ehr_screen_assessment VALUES ('JIN_SHIN_JYUTSU','36398997','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='"Not just a theory": the relationship between Jin Shin Jyutsu® self-care training for nurses and stress, physical health, emotional health, and caring efficacy.',screening_status='TITLE_ELIGIBLE_EXTRACTION_PENDING',screening_reason='Title/metadata supports retaining this candidate for primary extraction. Full-text eligibility, outcomes, bias and procedure appraisal remain open; no efficacy judgment made.' WHERE practice_code='JIN_SHIN_JYUTSU' AND pmid='24771664';
INSERT INTO ilb_ehr_screen_assessment VALUES ('JIN_SHIN_JYUTSU','24771664','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Effect of Jin Shin Jyutsu energy medicine treatments on women diagnosed with breast cancer.',screening_status='TITLE_ELIGIBLE_EXTRACTION_PENDING',screening_reason='Title/metadata supports retaining this candidate for primary extraction. Full-text eligibility, outcomes, bias and procedure appraisal remain open; no efficacy judgment made.' WHERE practice_code='JIN_SHIN_JYUTSU' AND pmid='21825093';
INSERT INTO ilb_ehr_screen_assessment VALUES ('JIN_SHIN_JYUTSU','21825093','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Case Report: Dynamic Interdependencies Between Complementary and Alternative Medicine (CAM) Practice, Urinary Interleukin-6 Levels, and Fatigue in a Breast Cancer Survivor.',screening_status='IDENTITY_UNCONFIRMED',screening_reason='Named lineage or combined intervention needs primary full-text identification; not attributed to this modality or counted as independent evidence.' WHERE practice_code='JIN_SHIN_JYUTSU' AND pmid='34149467';
INSERT INTO ilb_ehr_screen_assessment VALUES ('JIN_SHIN_JYUTSU','34149467','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Advancing the Quadruple Aim Through Workplace-Integrated Holistic Wellness Interventions: A Quality Improvement Evaluation.',screening_status='IDENTITY_UNCONFIRMED',screening_reason='Named lineage or combined intervention needs primary full-text identification; not attributed to this modality or counted as independent evidence.' WHERE practice_code='JIN_SHIN_JYUTSU' AND pmid='42709485';
INSERT INTO ilb_ehr_screen_assessment VALUES ('JIN_SHIN_JYUTSU','42709485','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Jin Shin Jyutsu outcomes in a patient with multiple myeloma.',screening_status='TITLE_ELIGIBLE_EXTRACTION_PENDING',screening_reason='Title/metadata supports retaining this candidate for primary extraction. Full-text eligibility, outcomes, bias and procedure appraisal remain open; no efficacy judgment made.' WHERE practice_code='JIN_SHIN_JYUTSU' AND pmid='12233795';
INSERT INTO ilb_ehr_screen_assessment VALUES ('JIN_SHIN_JYUTSU','12233795','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Dynamic Effects of CAM Techniques on Inflammation and Emotional States: An Integrative Single-Case Study on a Breast Cancer Survivor.',screening_status='IDENTITY_UNCONFIRMED',screening_reason='Named lineage or combined intervention needs primary full-text identification; not attributed to this modality or counted as independent evidence.' WHERE practice_code='JIN_SHIN_JYUTSU' AND pmid='33412954';
INSERT INTO ilb_ehr_screen_assessment VALUES ('JIN_SHIN_JYUTSU','33412954','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Clinical trial: the effect of Johrei on symptoms of patients with functional chest pain.',screening_status='ABSTRACT_APPRAISED',screening_reason='Focused primary appraisal stored with limitations. This is one reviewer, not independent duplicate screening or a complete modality synthesis.' WHERE practice_code='JOHREI' AND pmid='18945261';
INSERT INTO ilb_ehr_screen_assessment VALUES ('JOHREI','18945261','ABSTRACT','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='[The effect of alternative therapies on symptoms of patients with functional chest pain--pilot study with Johrei healing technique].',screening_status='TITLE_ELIGIBLE_EXTRACTION_PENDING',screening_reason='Title/metadata supports retaining this candidate for primary extraction. Full-text eligibility, outcomes, bias and procedure appraisal remain open; no efficacy judgment made.' WHERE practice_code='JOHREI' AND pmid='19606689';
INSERT INTO ilb_ehr_screen_assessment VALUES ('JOHREI','19606689','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='The impact of self-hypnosis and Johrei on lymphocyte subpopulations at exam time: a controlled study.',screening_status='TITLE_ELIGIBLE_EXTRACTION_PENDING',screening_reason='Title/metadata supports retaining this candidate for primary extraction. Full-text eligibility, outcomes, bias and procedure appraisal remain open; no efficacy judgment made.' WHERE practice_code='JOHREI' AND pmid='14698357';
INSERT INTO ilb_ehr_screen_assessment VALUES ('JOHREI','14698357','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Alternative treatment with Johrei: A controlled randomized study evaluating seed physiological potential.',screening_status='TITLE_ELIGIBLE_EXTRACTION_PENDING',screening_reason='Title/metadata supports retaining this candidate for primary extraction. Full-text eligibility, outcomes, bias and procedure appraisal remain open; no efficacy judgment made.' WHERE practice_code='JOHREI' AND pmid='32811741';
INSERT INTO ilb_ehr_screen_assessment VALUES ('JOHREI','32811741','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Johrei family healing: a pilot study.',screening_status='TITLE_ELIGIBLE_EXTRACTION_PENDING',screening_reason='Title/metadata supports retaining this candidate for primary extraction. Full-text eligibility, outcomes, bias and procedure appraisal remain open; no efficacy judgment made.' WHERE practice_code='JOHREI' AND pmid='17173118';
INSERT INTO ilb_ehr_screen_assessment VALUES ('JOHREI','17173118','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='The influence of 10 min of the Johrei healing method on laboratory stress.',screening_status='TITLE_ELIGIBLE_EXTRACTION_PENDING',screening_reason='Title/metadata supports retaining this candidate for primary extraction. Full-text eligibility, outcomes, bias and procedure appraisal remain open; no efficacy judgment made.' WHERE practice_code='JOHREI' AND pmid='16765851';
INSERT INTO ilb_ehr_screen_assessment VALUES ('JOHREI','16765851','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Beneficial Effects of Receiving Johrei on General Health or Hypothermia Tendency.',screening_status='TITLE_ELIGIBLE_EXTRACTION_PENDING',screening_reason='Title/metadata supports retaining this candidate for primary extraction. Full-text eligibility, outcomes, bias and procedure appraisal remain open; no efficacy judgment made.' WHERE practice_code='JOHREI' AND pmid='34969609';
INSERT INTO ilb_ehr_screen_assessment VALUES ('JOHREI','34969609','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='The effect of Johrei healing on substance abuse recovery: a pilot study.',screening_status='TITLE_ELIGIBLE_EXTRACTION_PENDING',screening_reason='Title/metadata supports retaining this candidate for primary extraction. Full-text eligibility, outcomes, bias and procedure appraisal remain open; no efficacy judgment made.' WHERE practice_code='JOHREI' AND pmid='16970532';
INSERT INTO ilb_ehr_screen_assessment VALUES ('JOHREI','16970532','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Effect of a Japanese energy healing method known as Johrei on viability and proliferation of cultured cancer cells in vitro.',screening_status='TITLE_ELIGIBLE_EXTRACTION_PENDING',screening_reason='Title/metadata supports retaining this candidate for primary extraction. Full-text eligibility, outcomes, bias and procedure appraisal remain open; no efficacy judgment made.' WHERE practice_code='JOHREI' AND pmid='22385045';
INSERT INTO ilb_ehr_screen_assessment VALUES ('JOHREI','22385045','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Effect of Johrei therapy on sleep in a murine model.',screening_status='TITLE_ELIGIBLE_EXTRACTION_PENDING',screening_reason='Title/metadata supports retaining this candidate for primary extraction. Full-text eligibility, outcomes, bias and procedure appraisal remain open; no efficacy judgment made.' WHERE practice_code='JOHREI' AND pmid='23452712';
INSERT INTO ilb_ehr_screen_assessment VALUES ('JOHREI','23452712','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Time-lapse analysis of potential cellular responsiveness to Johrei, a Japanese healing technique.',screening_status='TITLE_ELIGIBLE_EXTRACTION_PENDING',screening_reason='Title/metadata supports retaining this candidate for primary extraction. Full-text eligibility, outcomes, bias and procedure appraisal remain open; no efficacy judgment made.' WHERE practice_code='JOHREI' AND pmid='15667653';
INSERT INTO ilb_ehr_screen_assessment VALUES ('JOHREI','15667653','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Radiation response of cultured human cells is unaffected by Johrei.',screening_status='TITLE_ELIGIBLE_EXTRACTION_PENDING',screening_reason='Title/metadata supports retaining this candidate for primary extraction. Full-text eligibility, outcomes, bias and procedure appraisal remain open; no efficacy judgment made.' WHERE practice_code='JOHREI' AND pmid='17549235';
INSERT INTO ilb_ehr_screen_assessment VALUES ('JOHREI','17549235','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Patient experiences and outcomes in a virtual healing setting: A feasibility study.',screening_status='ABSTRACT_APPRAISED',screening_reason='Focused primary appraisal stored with limitations. This is one reviewer, not independent duplicate screening or a complete modality synthesis.' WHERE practice_code='BIOFIELD_TUNING' AND pmid='37537086';
INSERT INTO ilb_ehr_screen_assessment VALUES ('BIOFIELD_TUNING','37537086','ABSTRACT','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Inter-Rater Agreement of Biofield Tuning: Testing a Novel Health Assessment Procedure.',screening_status='ABSTRACT_APPRAISED',screening_reason='Focused primary appraisal stored with limitations. This is one reviewer, not independent duplicate screening or a complete modality synthesis.' WHERE practice_code='BIOFIELD_TUNING' AND pmid='32721212';
INSERT INTO ilb_ehr_screen_assessment VALUES ('BIOFIELD_TUNING','32721212','ABSTRACT','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Sound healing reduces generalized anxiety during the pandemic: A feasibility study.',screening_status='ABSTRACT_APPRAISED',screening_reason='Focused primary appraisal stored with limitations. This is one reviewer, not independent duplicate screening or a complete modality synthesis.' WHERE practice_code='BIOFIELD_TUNING' AND pmid='37023932';
INSERT INTO ilb_ehr_screen_assessment VALUES ('BIOFIELD_TUNING','37023932','ABSTRACT','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Transfer Learning-driven Biofield Image Analysis for Predictive Modeling of Diabetes.',screening_status='EXCLUDED_WRONG_MODALITY',screening_reason='Primary title/metadata identifies a different intervention or conventional biomedical procedure, not this catalogue method.' WHERE practice_code='BIOFIELD_TUNING' AND pmid='42039726';
INSERT INTO ilb_ehr_screen_assessment VALUES ('BIOFIELD_TUNING','42039726','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Biogeometry. The logic in the process of selection, siting, design, construction, and transfer of flaps.',screening_status='EXCLUDED_NAME_COLLISION',screening_reason='Returned title/context concerns conventional biology, surgery, devices or psychology; does not identify this named healing method.' WHERE practice_code='BIOGEOMETRY' AND pmid='4017433';
INSERT INTO ilb_ehr_screen_assessment VALUES ('BIOGEOMETRY','4017433','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Retrospective Cohort Observational Study on the Single Best Perforator-Based Pacman Flap in the Reconstruction of Stage IV Sacral Region Pressure Ulcers.',screening_status='EXCLUDED_NAME_COLLISION',screening_reason='Returned title/context concerns conventional biology, surgery, devices or psychology; does not identify this named healing method.' WHERE practice_code='BIOGEOMETRY' AND pmid='32884193';
INSERT INTO ilb_ehr_screen_assessment VALUES ('BIOGEOMETRY','32884193','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Biogeometry: applications of computational geometry to molecular structure.',screening_status='EXCLUDED_NAME_COLLISION',screening_reason='Returned title/context concerns conventional biology, surgery, devices or psychology; does not identify this named healing method.' WHERE practice_code='BIOGEOMETRY' AND pmid='15759608';
INSERT INTO ilb_ehr_screen_assessment VALUES ('BIOGEOMETRY','15759608','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Primary and secondary perforator-based flap-in-flap reconstructions of postexcisional head and neck soft tissue defects.',screening_status='EXCLUDED_NAME_COLLISION',screening_reason='Returned title/context concerns conventional biology, surgery, devices or psychology; does not identify this named healing method.' WHERE practice_code='BIOGEOMETRY' AND pmid='32637529';
INSERT INTO ilb_ehr_screen_assessment VALUES ('BIOGEOMETRY','32637529','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Pretrainable geometric graph neural network for antibody affinity maturation.',screening_status='EXCLUDED_NAME_COLLISION',screening_reason='Returned title/context concerns conventional biology, surgery, devices or psychology; does not identify this named healing method.' WHERE practice_code='BIOGEOMETRY' AND pmid='39242604';
INSERT INTO ilb_ehr_screen_assessment VALUES ('BIOGEOMETRY','39242604','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Propeller Flaps.',screening_status='EXCLUDED_NAME_COLLISION',screening_reason='Returned title/context concerns conventional biology, surgery, devices or psychology; does not identify this named healing method.' WHERE practice_code='BIOGEOMETRY' AND pmid='36683892';
INSERT INTO ilb_ehr_screen_assessment VALUES ('BIOGEOMETRY','36683892','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Generative AI-driven de novo design of high-affinity, epitope-specific antibodies targeting the CD93-IGFBP7 axis for cancer immunotherapy.',screening_status='EXCLUDED_NAME_COLLISION',screening_reason='Returned title/context concerns conventional biology, surgery, devices or psychology; does not identify this named healing method.' WHERE practice_code='BIOGEOMETRY' AND pmid='42592032';
INSERT INTO ilb_ehr_screen_assessment VALUES ('BIOGEOMETRY','42592032','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Engineered Nonheme Iron Enzymes Enable Asymmetric Hydrogenation of Alkenes.',screening_status='EXCLUDED_NAME_COLLISION',screening_reason='Returned title/context concerns conventional biology, surgery, devices or psychology; does not identify this named healing method.' WHERE practice_code='BIOGEOMETRY' AND pmid='42287220';
INSERT INTO ilb_ehr_screen_assessment VALUES ('BIOGEOMETRY','42287220','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Author Correction: Pretrainable geometric graph neural network for antibody affinity maturation.',screening_status='EXCLUDED_NAME_COLLISION',screening_reason='Returned title/context concerns conventional biology, surgery, devices or psychology; does not identify this named healing method.' WHERE practice_code='BIOGEOMETRY' AND pmid='39375360';
INSERT INTO ilb_ehr_screen_assessment VALUES ('BIOGEOMETRY','39375360','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='The Bilobed Flap - Critical Analysis and New Mathematically Precise Design.',screening_status='EXCLUDED_NAME_COLLISION',screening_reason='Returned title/context concerns conventional biology, surgery, devices or psychology; does not identify this named healing method.' WHERE practice_code='BIOGEOMETRY' AND pmid='39224415';
INSERT INTO ilb_ehr_screen_assessment VALUES ('BIOGEOMETRY','39224415','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Rapid restoration of potent neutralization activity against the latest Omicron variant JN.1 via AI rational design and antibody engineering.',screening_status='EXCLUDED_NAME_COLLISION',screening_reason='Returned title/context concerns conventional biology, surgery, devices or psychology; does not identify this named healing method.' WHERE practice_code='BIOGEOMETRY' AND pmid='39908098';
INSERT INTO ilb_ehr_screen_assessment VALUES ('BIOGEOMETRY','39908098','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='M3Site: multiclass multimodal learning for protein active site identification and classification.',screening_status='EXCLUDED_NAME_COLLISION',screening_reason='Returned title/context concerns conventional biology, surgery, devices or psychology; does not identify this named healing method.' WHERE practice_code='BIOGEOMETRY' AND pmid='41222559';
INSERT INTO ilb_ehr_screen_assessment VALUES ('BIOGEOMETRY','41222559','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Effect of a Web-Based Heartfulness Program on the Mental Well-Being, Biomarkers, and Gene Expression Profile of Health Care Students: Randomized Controlled Trial.',screening_status='TITLE_ELIGIBLE_EXTRACTION_PENDING',screening_reason='Title/metadata supports retaining this candidate for primary extraction. Full-text eligibility, outcomes, bias and procedure appraisal remain open; no efficacy judgment made.' WHERE practice_code='HEARTFULNESS' AND pmid='39680432';
INSERT INTO ilb_ehr_screen_assessment VALUES ('HEARTFULNESS','39680432','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Effect of Heartfulness Meditation on Stress Biomarkers, Burnout and Well-Being: A Randomized Controlled Study.',screening_status='TITLE_ELIGIBLE_EXTRACTION_PENDING',screening_reason='Title/metadata supports retaining this candidate for primary extraction. Full-text eligibility, outcomes, bias and procedure appraisal remain open; no efficacy judgment made.' WHERE practice_code='HEARTFULNESS' AND pmid='40271908';
INSERT INTO ilb_ehr_screen_assessment VALUES ('HEARTFULNESS','40271908','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Heartfulness meditation alters neuroendocrine profiles: A randomized controlled trial on hormones of stress and well-being.',screening_status='TITLE_ELIGIBLE_EXTRACTION_PENDING',screening_reason='Title/metadata supports retaining this candidate for primary extraction. Full-text eligibility, outcomes, bias and procedure appraisal remain open; no efficacy judgment made.' WHERE practice_code='HEARTFULNESS' AND pmid='41305815';
INSERT INTO ilb_ehr_screen_assessment VALUES ('HEARTFULNESS','41305815','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Impact of heartfulness meditation practice compared to the gratitude practices on wellbeing and work engagement among healthcare professionals: Randomized trial.',screening_status='TITLE_ELIGIBLE_EXTRACTION_PENDING',screening_reason='Title/metadata supports retaining this candidate for primary extraction. Full-text eligibility, outcomes, bias and procedure appraisal remain open; no efficacy judgment made.' WHERE practice_code='HEARTFULNESS' AND pmid='38848338';
INSERT INTO ilb_ehr_screen_assessment VALUES ('HEARTFULNESS','38848338','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Efficacy of Heartfulness Meditation as Adjunctive Therapy for Moderate to Severe Psoriasis: A Randomised Controlled Trial.',screening_status='ABSTRACT_APPRAISED',screening_reason='Focused primary appraisal stored with limitations. This is one reviewer, not independent duplicate screening or a complete modality synthesis.' WHERE practice_code='HEARTFULNESS' AND pmid='42555361';
INSERT INTO ilb_ehr_screen_assessment VALUES ('HEARTFULNESS','42555361','ABSTRACT','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Impact of Heartfulness meditation practice on anxiety, perceived stress, well-being, and telomere length.',screening_status='TITLE_ELIGIBLE_EXTRACTION_PENDING',screening_reason='Title/metadata supports retaining this candidate for primary extraction. Full-text eligibility, outcomes, bias and procedure appraisal remain open; no efficacy judgment made.' WHERE practice_code='HEARTFULNESS' AND pmid='37342644';
INSERT INTO ilb_ehr_screen_assessment VALUES ('HEARTFULNESS','37342644','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Heartfulness meditation improves loneliness and sleep in physicians and advance practice providers during COVID-19 pandemic.',screening_status='TITLE_ELIGIBLE_EXTRACTION_PENDING',screening_reason='Title/metadata supports retaining this candidate for primary extraction. Full-text eligibility, outcomes, bias and procedure appraisal remain open; no efficacy judgment made.' WHERE practice_code='HEARTFULNESS' AND pmid='33682592';
INSERT INTO ilb_ehr_screen_assessment VALUES ('HEARTFULNESS','33682592','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Effect of 4-Week Heartfulness Meditation on Stress Scores, Sleep Quality, and Oxidative and Inflammatory Biochemical Parameters in COVID-19 Patients after Completion of Standard Treatment - A Randomized Controlled Trial.',screening_status='TITLE_ELIGIBLE_EXTRACTION_PENDING',screening_reason='Title/metadata supports retaining this candidate for primary extraction. Full-text eligibility, outcomes, bias and procedure appraisal remain open; no efficacy judgment made.' WHERE practice_code='HEARTFULNESS' AND pmid='36949840';
INSERT INTO ilb_ehr_screen_assessment VALUES ('HEARTFULNESS','36949840','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Effects of heartfulness and bell meditation on brain activities and autonomic function in university students: An exploratory study.',screening_status='TITLE_ELIGIBLE_EXTRACTION_PENDING',screening_reason='Title/metadata supports retaining this candidate for primary extraction. Full-text eligibility, outcomes, bias and procedure appraisal remain open; no efficacy judgment made.' WHERE practice_code='HEARTFULNESS' AND pmid='42328361';
INSERT INTO ilb_ehr_screen_assessment VALUES ('HEARTFULNESS','42328361','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Impact of the Heartfulness program on loneliness in high schoolers: Randomized survey study.',screening_status='TITLE_ELIGIBLE_EXTRACTION_PENDING',screening_reason='Title/metadata supports retaining this candidate for primary extraction. Full-text eligibility, outcomes, bias and procedure appraisal remain open; no efficacy judgment made.' WHERE practice_code='HEARTFULNESS' AND pmid='35384302';
INSERT INTO ilb_ehr_screen_assessment VALUES ('HEARTFULNESS','35384302','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Effects of an 8-week intervention of anulom vilom pranayama combined with heartfulness meditation on psychological stress, autonomic function, inflammatory biomarkers, and oxidative stress in healthcare workers during COVID-19 pandemic: a randomized controlled trial.',screening_status='TITLE_ELIGIBLE_EXTRACTION_PENDING',screening_reason='Title/metadata supports retaining this candidate for primary extraction. Full-text eligibility, outcomes, bias and procedure appraisal remain open; no efficacy judgment made.' WHERE practice_code='HEARTFULNESS' AND pmid='39331608';
INSERT INTO ilb_ehr_screen_assessment VALUES ('HEARTFULNESS','39331608','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Training community practitioners in a research intervention: practice examples at the intersection of cancer, Western science, and native Hawaiian healing.',screening_status='CONTEXT_ONLY',screening_reason='Retained for history, observational context or citation chasing. Not an independent primary efficacy appraisal.' WHERE practice_code='HOOPONOPONO' AND pmid='14581899';
INSERT INTO ilb_ehr_screen_assessment VALUES ('HOOPONOPONO','14581899','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Self identity through Ho''oponopono as adjunctive therapy for hypertension management.',screening_status='ABSTRACT_APPRAISED',screening_reason='Focused primary appraisal stored with limitations. This is one reviewer, not independent duplicate screening or a complete modality synthesis.' WHERE practice_code='HOOPONOPONO' AND pmid='18072370';
INSERT INTO ilb_ehr_screen_assessment VALUES ('HOOPONOPONO','18072370','ABSTRACT','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Ho''oponopono, "to make right": Hawaiian conflict resolution and metaphor in the construction of a family therapy.',screening_status='CONTEXT_ONLY',screening_reason='Retained for history, observational context or citation chasing. Not an independent primary efficacy appraisal.' WHERE practice_code='HOOPONOPONO' AND pmid='4017619';
INSERT INTO ilb_ehr_screen_assessment VALUES ('HOOPONOPONO','4017619','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Hawaiian health practitioners in contemporary society.',screening_status='CONTEXT_ONLY',screening_reason='Retained for history, observational context or citation chasing. Not an independent primary efficacy appraisal.' WHERE practice_code='HOOPONOPONO' AND pmid='12180505';
INSERT INTO ilb_ehr_screen_assessment VALUES ('HOOPONOPONO','12180505','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Sociocultural and community factors influencing the use of Native Hawaiian healers and healing practices among adolescents in Hawai''i.',screening_status='CONTEXT_ONLY',screening_reason='Retained for history, observational context or citation chasing. Not an independent primary efficacy appraisal.' WHERE practice_code='HOOPONOPONO' AND pmid='12180504';
INSERT INTO ilb_ehr_screen_assessment VALUES ('HOOPONOPONO','12180504','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Native Hawaiian traditional healing: culturally based interventions for social work practice.',screening_status='CONTEXT_ONLY',screening_reason='Retained for history, observational context or citation chasing. Not an independent primary efficacy appraisal.' WHERE practice_code='HOOPONOPONO' AND pmid='12019805';
INSERT INTO ilb_ehr_screen_assessment VALUES ('HOOPONOPONO','12019805','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Integrating a CAM Therapeutic Strategy for Hypertension.',screening_status='CONTEXT_ONLY',screening_reason='Retained for history, observational context or citation chasing. Not an independent primary efficacy appraisal.' WHERE practice_code='HOOPONOPONO' AND pmid='23853524';
INSERT INTO ilb_ehr_screen_assessment VALUES ('HOOPONOPONO','23853524','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Evaluating the sound magnetic balance intervention in a randomized controlled trial: Effects on psychological distress, somatic pain, and physiological arousal.',screening_status='TITLE_ELIGIBLE_EXTRACTION_PENDING',screening_reason='Title/metadata supports retaining this candidate for primary extraction. Full-text eligibility, outcomes, bias and procedure appraisal remain open; no efficacy judgment made.' WHERE practice_code='SOUND_HEALING' AND pmid='41616681';
INSERT INTO ilb_ehr_screen_assessment VALUES ('SOUND_HEALING','41616681','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Sound healing reduces generalized anxiety during the pandemic: A feasibility study.',screening_status='ABSTRACT_APPRAISED',screening_reason='Focused primary appraisal stored with limitations. This is one reviewer, not independent duplicate screening or a complete modality synthesis.' WHERE practice_code='SOUND_HEALING' AND pmid='37023932';
INSERT INTO ilb_ehr_screen_assessment VALUES ('SOUND_HEALING','37023932','ABSTRACT','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Patient experiences and outcomes in a virtual healing setting: A feasibility study.',screening_status='TITLE_ELIGIBLE_EXTRACTION_PENDING',screening_reason='Title/metadata supports retaining this candidate for primary extraction. Full-text eligibility, outcomes, bias and procedure appraisal remain open; no efficacy judgment made.' WHERE practice_code='SOUND_HEALING' AND pmid='37537086';
INSERT INTO ilb_ehr_screen_assessment VALUES ('SOUND_HEALING','37537086','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Didgeridoo Sound Meditation for Stress Reduction and Mood Enhancement in Undergraduates: A Randomized Controlled Trial.',screening_status='FULL_TEXT_APPRAISED',screening_reason='Focused primary appraisal stored with limitations. This is one reviewer, not independent duplicate screening or a complete modality synthesis.' WHERE practice_code='SOUND_HEALING' AND pmid='31632840';
INSERT INTO ilb_ehr_screen_assessment VALUES ('SOUND_HEALING','31632840','FULL_TEXT','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Medial meniscus root tear refixation: comparison of clinical, radiologic, and arthroscopic findings with medial meniscectomy.',screening_status='EXCLUDED_WRONG_MODALITY',screening_reason='Primary title/metadata identifies a different intervention or conventional biomedical procedure, not this catalogue method.' WHERE practice_code='SOUND_HEALING' AND pmid='21035991';
INSERT INTO ilb_ehr_screen_assessment VALUES ('SOUND_HEALING','21035991','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Comparison of the safety and effectiveness of different surgical timing for acute cholecystitis after percutaneous transhepatic gallbladder drainage: a systematic review and meta-analysis.',screening_status='EXCLUDED_WRONG_MODALITY',screening_reason='Primary title/metadata identifies a different intervention or conventional biomedical procedure, not this catalogue method.' WHERE practice_code='SOUND_HEALING' AND pmid='36943587';
INSERT INTO ilb_ehr_screen_assessment VALUES ('SOUND_HEALING','36943587','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Clinical efficacy and safety of robot assisted surgery for choledochal cysts excisions: a systematic review and meta-analysis.',screening_status='EXCLUDED_WRONG_MODALITY',screening_reason='Primary title/metadata identifies a different intervention or conventional biomedical procedure, not this catalogue method.' WHERE practice_code='SOUND_HEALING' AND pmid='35939040';
INSERT INTO ilb_ehr_screen_assessment VALUES ('SOUND_HEALING','35939040','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Successful treatment of valgus deformity of the knee with an open supracondylar osteotomy using a coral wedge: a brief report of two cases.',screening_status='EXCLUDED_WRONG_MODALITY',screening_reason='Primary title/metadata identifies a different intervention or conventional biomedical procedure, not this catalogue method.' WHERE practice_code='SOUND_HEALING' AND pmid='10788773';
INSERT INTO ilb_ehr_screen_assessment VALUES ('SOUND_HEALING','10788773','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Conservative treatment of femoral shaft fractures in patients with total hip arthroplasty.',screening_status='EXCLUDED_WRONG_MODALITY',screening_reason='Primary title/metadata identifies a different intervention or conventional biomedical procedure, not this catalogue method.' WHERE practice_code='SOUND_HEALING' AND pmid='9526209';
INSERT INTO ilb_ehr_screen_assessment VALUES ('SOUND_HEALING','9526209','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Breast reduction with a superomedial pedicle and a vertical scar (Hall-Findlay''s technique): experience with 210 consecutive patients.',screening_status='EXCLUDED_WRONG_MODALITY',screening_reason='Primary title/metadata identifies a different intervention or conventional biomedical procedure, not this catalogue method.' WHERE practice_code='SOUND_HEALING' AND pmid='20179472';
INSERT INTO ilb_ehr_screen_assessment VALUES ('SOUND_HEALING','20179472','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Liver transplantation with cyclosporine and low-dose corticosteroids.',screening_status='EXCLUDED_WRONG_MODALITY',screening_reason='Primary title/metadata identifies a different intervention or conventional biomedical procedure, not this catalogue method.' WHERE practice_code='SOUND_HEALING' AND pmid='3883865';
INSERT INTO ilb_ehr_screen_assessment VALUES ('SOUND_HEALING','3883865','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='[Resistance of the main bronchial stump to pressure after manual suture].',screening_status='EXCLUDED_WRONG_MODALITY',screening_reason='Primary title/metadata identifies a different intervention or conventional biomedical procedure, not this catalogue method.' WHERE practice_code='SOUND_HEALING' AND pmid='20679749';
INSERT INTO ilb_ehr_screen_assessment VALUES ('SOUND_HEALING','20679749','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Improved anticancer efficacy of plant leaf extracts from homa environment: A preliminary study.',screening_status='TITLE_ELIGIBLE_EXTRACTION_PENDING',screening_reason='Title/metadata supports retaining this candidate for primary extraction. Full-text eligibility, outcomes, bias and procedure appraisal remain open; no efficacy judgment made.' WHERE practice_code='AGNIHOTRA' AND pmid='42140041';
INSERT INTO ilb_ehr_screen_assessment VALUES ('AGNIHOTRA','42140041','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='External qigong for pain conditions: a systematic review of randomized clinical trials.',screening_status='CONTEXT_ONLY',screening_reason='Retained for history, observational context or citation chasing. Not an independent primary efficacy appraisal.' WHERE practice_code='EXTERNAL_QIGONG' AND pmid='17690012';
INSERT INTO ilb_ehr_screen_assessment VALUES ('EXTERNAL_QIGONG','17690012','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Effects of qi therapy (external qigong ) on premenstrual syndrome: a randomized placebo-controlled study.',screening_status='TITLE_ELIGIBLE_EXTRACTION_PENDING',screening_reason='Title/metadata supports retaining this candidate for primary extraction. Full-text eligibility, outcomes, bias and procedure appraisal remain open; no efficacy judgment made.' WHERE practice_code='EXTERNAL_QIGONG' AND pmid='15253849';
INSERT INTO ilb_ehr_screen_assessment VALUES ('EXTERNAL_QIGONG','15253849','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Effects of Qi-therapy (external Qigong) on cardiac autonomic tone: a randomized placebo controlled study.',screening_status='TITLE_ELIGIBLE_EXTRACTION_PENDING',screening_reason='Title/metadata supports retaining this candidate for primary extraction. Full-text eligibility, outcomes, bias and procedure appraisal remain open; no efficacy judgment made.' WHERE practice_code='EXTERNAL_QIGONG' AND pmid='16048810';
INSERT INTO ilb_ehr_screen_assessment VALUES ('EXTERNAL_QIGONG','16048810','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='External qigong for chronic pain.',screening_status='TITLE_ELIGIBLE_EXTRACTION_PENDING',screening_reason='Title/metadata supports retaining this candidate for primary extraction. Full-text eligibility, outcomes, bias and procedure appraisal remain open; no efficacy judgment made.' WHERE practice_code='EXTERNAL_QIGONG' AND pmid='20626055';
INSERT INTO ilb_ehr_screen_assessment VALUES ('EXTERNAL_QIGONG','20626055','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Nonlinear analysis of heart rate variability during Qi therapy (external Qigong).',screening_status='TITLE_ELIGIBLE_EXTRACTION_PENDING',screening_reason='Title/metadata supports retaining this candidate for primary extraction. Full-text eligibility, outcomes, bias and procedure appraisal remain open; no efficacy judgment made.' WHERE practice_code='EXTERNAL_QIGONG' AND pmid='16173532';
INSERT INTO ilb_ehr_screen_assessment VALUES ('EXTERNAL_QIGONG','16173532','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Effects of external qigong therapy on osteoarthritis of the knee. A randomized controlled trial.',screening_status='FULL_TEXT_APPRAISED',screening_reason='Focused primary appraisal stored with limitations. This is one reviewer, not independent duplicate screening or a complete modality synthesis.' WHERE practice_code='EXTERNAL_QIGONG' AND pmid='18654733';
INSERT INTO ilb_ehr_screen_assessment VALUES ('EXTERNAL_QIGONG','18654733','FULL_TEXT','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Is there any difference in the effects of Qi therapy (external Qigong) with and without touching? A pilot study.',screening_status='TITLE_ELIGIBLE_EXTRACTION_PENDING',screening_reason='Title/metadata supports retaining this candidate for primary extraction. Full-text eligibility, outcomes, bias and procedure appraisal remain open; no efficacy judgment made.' WHERE practice_code='EXTERNAL_QIGONG' AND pmid='16861168';
INSERT INTO ilb_ehr_screen_assessment VALUES ('EXTERNAL_QIGONG','16861168','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Efficacy of Qi-therapy (external Qigong) for elderly people with chronic pain.',screening_status='TITLE_ELIGIBLE_EXTRACTION_PENDING',screening_reason='Title/metadata supports retaining this candidate for primary extraction. Full-text eligibility, outcomes, bias and procedure appraisal remain open; no efficacy judgment made.' WHERE practice_code='EXTERNAL_QIGONG' AND pmid='16051542';
INSERT INTO ilb_ehr_screen_assessment VALUES ('EXTERNAL_QIGONG','16051542','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='The Effects of Qigong for Adults with Chronic Pain: Systematic Review and Meta-Analysis.',screening_status='CONTEXT_ONLY',screening_reason='Retained for history, observational context or citation chasing. Not an independent primary efficacy appraisal.' WHERE practice_code='EXTERNAL_QIGONG' AND pmid='26621441';
INSERT INTO ilb_ehr_screen_assessment VALUES ('EXTERNAL_QIGONG','26621441','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Nontouch biofield therapy: a systematic review of human randomized controlled trials reporting use of only nonphysical contact treatment.',screening_status='CONTEXT_ONLY',screening_reason='Retained for history, observational context or citation chasing. Not an independent primary efficacy appraisal.' WHERE practice_code='EXTERNAL_QIGONG' AND pmid='25181286';
INSERT INTO ilb_ehr_screen_assessment VALUES ('EXTERNAL_QIGONG','25181286','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Biofield Therapies: Guidelines for Reporting Clinical Trials.',screening_status='TITLE_ELIGIBLE_EXTRACTION_PENDING',screening_reason='Title/metadata supports retaining this candidate for primary extraction. Full-text eligibility, outcomes, bias and procedure appraisal remain open; no efficacy judgment made.' WHERE practice_code='EXTERNAL_QIGONG' AND pmid='38304734';
INSERT INTO ilb_ehr_screen_assessment VALUES ('EXTERNAL_QIGONG','38304734','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='In vitro test of external Qigong.',screening_status='TITLE_ELIGIBLE_EXTRACTION_PENDING',screening_reason='Title/metadata supports retaining this candidate for primary extraction. Full-text eligibility, outcomes, bias and procedure appraisal remain open; no efficacy judgment made.' WHERE practice_code='EXTERNAL_QIGONG' AND pmid='15102336';
INSERT INTO ilb_ehr_screen_assessment VALUES ('EXTERNAL_QIGONG','15102336','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Psychosocial outcomes of risk-adapted prevention for prostate cancer predisposition: study protocol for a longitudinal observational mixed-methods study.',screening_status='EXCLUDED_NAME_COLLISION',screening_reason='Returned title/context concerns conventional biology, surgery, devices or psychology; does not identify this named healing method.' WHERE practice_code='PSYCH_K' AND pmid='40685233';
INSERT INTO ilb_ehr_screen_assessment VALUES ('PSYCH_K','40685233','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Cognitive Profiles in Adolescents and Young Adults With Co-Occurring Autism and First-Episode Psychosis: A Preliminary Neuropsychological Investigation.',screening_status='EXCLUDED_NAME_COLLISION',screening_reason='Returned title/context concerns conventional biology, surgery, devices or psychology; does not identify this named healing method.' WHERE practice_code='PSYCH_K' AND pmid='41588579';
INSERT INTO ilb_ehr_screen_assessment VALUES ('PSYCH_K','41588579','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Beyond Perceptual Heuristics: A Biosemiotic Reinterpretation of Gestalt Laws in Human Meaning Construction.',screening_status='EXCLUDED_NAME_COLLISION',screening_reason='Returned title/context concerns conventional biology, surgery, devices or psychology; does not identify this named healing method.' WHERE practice_code='PSYCH_K' AND pmid='42521909';
INSERT INTO ilb_ehr_screen_assessment VALUES ('PSYCH_K','42521909','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Interplay Among Reward Processing, Schizotypal Traits, and Psychosocial Stress in a Large Chinese Young Adult Sample: A Cross-Sectional Network Analysis.',screening_status='EXCLUDED_NAME_COLLISION',screening_reason='Returned title/context concerns conventional biology, surgery, devices or psychology; does not identify this named healing method.' WHERE practice_code='PSYCH_K' AND pmid='42159299';
INSERT INTO ilb_ehr_screen_assessment VALUES ('PSYCH_K','42159299','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Corrective Experiencing as a Common Factor in Couple Therapy: Creating New and Positive Emotions in Relationships.',screening_status='EXCLUDED_NAME_COLLISION',screening_reason='Returned title/context concerns conventional biology, surgery, devices or psychology; does not identify this named healing method.' WHERE practice_code='PSYCH_K' AND pmid='41199136';
INSERT INTO ilb_ehr_screen_assessment VALUES ('PSYCH_K','41199136','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Matters arising: Methodological concerns and interpretative limitations of assessing subjective effects of ketamine.',screening_status='EXCLUDED_NAME_COLLISION',screening_reason='Returned title/context concerns conventional biology, surgery, devices or psychology; does not identify this named healing method.' WHERE practice_code='PSYCH_K' AND pmid='42773216';
INSERT INTO ilb_ehr_screen_assessment VALUES ('PSYCH_K','42773216','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Household Income and Sexual Activity Patterns Among Japanese Men: A Latent Class Analysis of a Nationwide Survey.',screening_status='EXCLUDED_NAME_COLLISION',screening_reason='Returned title/context concerns conventional biology, surgery, devices or psychology; does not identify this named healing method.' WHERE practice_code='PSYCH_K' AND pmid='42779489';
INSERT INTO ilb_ehr_screen_assessment VALUES ('PSYCH_K','42779489','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='[Fatigue, PEM and patient care].',screening_status='EXCLUDED_NAME_COLLISION',screening_reason='Returned title/context concerns conventional biology, surgery, devices or psychology; does not identify this named healing method.' WHERE practice_code='PSYCH_K' AND pmid='42786348';
INSERT INTO ilb_ehr_screen_assessment VALUES ('PSYCH_K','42786348','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Cross-Subject Commonality of Emotion Representations in Dorsal Motion-Sensitive Areas.',screening_status='EXCLUDED_NAME_COLLISION',screening_reason='Returned title/context concerns conventional biology, surgery, devices or psychology; does not identify this named healing method.' WHERE practice_code='EMOTION_CODE' AND pmid='33177977';
INSERT INTO ilb_ehr_screen_assessment VALUES ('EMOTION_CODE','33177977','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Mammalian circadian biology: elucidating genome-wide levels of temporal organization.',screening_status='EXCLUDED_NAME_COLLISION',screening_reason='Returned title/context concerns conventional biology, surgery, devices or psychology; does not identify this named healing method.' WHERE practice_code='BODY_CODE' AND pmid='15485355';
INSERT INTO ilb_ehr_screen_assessment VALUES ('BODY_CODE','15485355','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='The A to Z of the wellbeing industry: from Angelic Reiki to patient centred care. Wellbeing is big business, but how much of it works?',screening_status='EXCLUDED_WRONG_DESIGN',screening_reason='Commentary about the wellbeing industry; not an intervention study of Angelic Reiki.' WHERE practice_code='ANGELIC_REIKI' AND pmid='21543407';
INSERT INTO ilb_ehr_screen_assessment VALUES ('ANGELIC_REIKI','21543407','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Sahaja yoga in the management of moderate to severe asthma: a randomised controlled trial.',screening_status='ABSTRACT_APPRAISED',screening_reason='Focused primary appraisal stored with limitations. This is one reviewer, not independent duplicate screening or a complete modality synthesis.' WHERE practice_code='SAHAJA_YOGA' AND pmid='11828038';
INSERT INTO ilb_ehr_screen_assessment VALUES ('SAHAJA_YOGA','11828038','ABSTRACT','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Effect of Sahaja yoga practice on seizure control & EEG changes in patients of epilepsy.',screening_status='TITLE_ELIGIBLE_EXTRACTION_PENDING',screening_reason='Title/metadata supports retaining this candidate for primary extraction. Full-text eligibility, outcomes, bias and procedure appraisal remain open; no efficacy judgment made.' WHERE practice_code='SAHAJA_YOGA' AND pmid='9062044';
INSERT INTO ilb_ehr_screen_assessment VALUES ('SAHAJA_YOGA','9062044','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Effect of Sahaja yoga practice on stress management in patients of epilepsy.',screening_status='TITLE_ELIGIBLE_EXTRACTION_PENDING',screening_reason='Title/metadata supports retaining this candidate for primary extraction. Full-text eligibility, outcomes, bias and procedure appraisal remain open; no efficacy judgment made.' WHERE practice_code='SAHAJA_YOGA' AND pmid='7649596';
INSERT INTO ilb_ehr_screen_assessment VALUES ('SAHAJA_YOGA','7649596','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Effect of Sahaja yoga meditation on auditory evoked potentials (AEP) and visual contrast sensitivity (VCS) in epileptics.',screening_status='TITLE_ELIGIBLE_EXTRACTION_PENDING',screening_reason='Title/metadata supports retaining this candidate for primary extraction. Full-text eligibility, outcomes, bias and procedure appraisal remain open; no efficacy judgment made.' WHERE practice_code='SAHAJA_YOGA' AND pmid='10832506';
INSERT INTO ilb_ehr_screen_assessment VALUES ('SAHAJA_YOGA','10832506','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Effect of Sahaja yoga meditation on quality of life, anxiety, and blood pressure control.',screening_status='TITLE_ELIGIBLE_EXTRACTION_PENDING',screening_reason='Title/metadata supports retaining this candidate for primary extraction. Full-text eligibility, outcomes, bias and procedure appraisal remain open; no efficacy judgment made.' WHERE practice_code='SAHAJA_YOGA' AND pmid='22784346';
INSERT INTO ilb_ehr_screen_assessment VALUES ('SAHAJA_YOGA','22784346','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='The Effectiveness of School-Based Sahaja Yoga Meditation in Dealing with Problematic Internet Use Among Adolescents in India.',screening_status='TITLE_ELIGIBLE_EXTRACTION_PENDING',screening_reason='Title/metadata supports retaining this candidate for primary extraction. Full-text eligibility, outcomes, bias and procedure appraisal remain open; no efficacy judgment made.' WHERE practice_code='SAHAJA_YOGA' AND pmid='41765323';
INSERT INTO ilb_ehr_screen_assessment VALUES ('SAHAJA_YOGA','41765323','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Brief meditation and acute stress in undergraduate nursing students: a pre-post study of an embedded wellness intervention.',screening_status='TITLE_ELIGIBLE_EXTRACTION_PENDING',screening_reason='Title/metadata supports retaining this candidate for primary extraction. Full-text eligibility, outcomes, bias and procedure appraisal remain open; no efficacy judgment made.' WHERE practice_code='SAHAJA_YOGA' AND pmid='42786418';
INSERT INTO ilb_ehr_screen_assessment VALUES ('SAHAJA_YOGA','42786418','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Yoga for epilepsy.',screening_status='CONTEXT_ONLY',screening_reason='Retained for history, observational context or citation chasing. Not an independent primary efficacy appraisal.' WHERE practice_code='SAHAJA_YOGA' AND pmid='10908505';
INSERT INTO ilb_ehr_screen_assessment VALUES ('SAHAJA_YOGA','10908505','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Short-term Sahaja Yoga meditation training modulates brain structure and spontaneous activity in the executive control network.',screening_status='TITLE_ELIGIBLE_EXTRACTION_PENDING',screening_reason='Title/metadata supports retaining this candidate for primary extraction. Full-text eligibility, outcomes, bias and procedure appraisal remain open; no efficacy judgment made.' WHERE practice_code='SAHAJA_YOGA' AND pmid='30485713';
INSERT INTO ilb_ehr_screen_assessment VALUES ('SAHAJA_YOGA','30485713','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Impact of long-term meditation practice on cardiovascular reactivity during perception and reappraisal of affective images.',screening_status='TITLE_ELIGIBLE_EXTRACTION_PENDING',screening_reason='Title/metadata supports retaining this candidate for primary extraction. Full-text eligibility, outcomes, bias and procedure appraisal remain open; no efficacy judgment made.' WHERE practice_code='SAHAJA_YOGA' AND pmid='25583571';
INSERT INTO ilb_ehr_screen_assessment VALUES ('SAHAJA_YOGA','25583571','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='A randomized, controlled trial of meditation for work stress, anxiety and depressed mood in full-time workers.',screening_status='TITLE_ELIGIBLE_EXTRACTION_PENDING',screening_reason='Title/metadata supports retaining this candidate for primary extraction. Full-text eligibility, outcomes, bias and procedure appraisal remain open; no efficacy judgment made.' WHERE practice_code='SAHAJA_YOGA' AND pmid='21716708';
INSERT INTO ilb_ehr_screen_assessment VALUES ('SAHAJA_YOGA','21716708','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Influence of long-term Sahaja Yoga meditation practice on emotional processing in the brain: An ERP study.',screening_status='TITLE_ELIGIBLE_EXTRACTION_PENDING',screening_reason='Title/metadata supports retaining this candidate for primary extraction. Full-text eligibility, outcomes, bias and procedure appraisal remain open; no efficacy judgment made.' WHERE practice_code='SAHAJA_YOGA' AND pmid='25281881';
INSERT INTO ilb_ehr_screen_assessment VALUES ('SAHAJA_YOGA','25281881','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Differential Effects of Ethical Education, Physical Hatha Yoga, and Mantra Meditation on Well-Being and Stress in Healthy Participants-An Experimental Single-Case Study.',screening_status='IDENTITY_UNCONFIRMED',screening_reason='Named lineage or combined intervention needs primary full-text identification; not attributed to this modality or counted as independent evidence.' WHERE practice_code='MANTRA_PRACTICES' AND pmid='34421729';
INSERT INTO ilb_ehr_screen_assessment VALUES ('MANTRA_PRACTICES','34421729','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Effects of Single-Session Group Mantra-meditation on Salivary Immunoglobulin A and Affective State: A Psychoneuroimmunology Viewpoint.',screening_status='TITLE_ELIGIBLE_EXTRACTION_PENDING',screening_reason='Title/metadata supports retaining this candidate for primary extraction. Full-text eligibility, outcomes, bias and procedure appraisal remain open; no efficacy judgment made.' WHERE practice_code='MANTRA_PRACTICES' AND pmid='29650130';
INSERT INTO ilb_ehr_screen_assessment VALUES ('MANTRA_PRACTICES','29650130','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Effects of Mantra Meditation versus Music Listening on Knee Pain, Function, and Related Outcomes in Older Adults with Knee Osteoarthritis: An Exploratory Randomized Clinical Trial (RCT).',screening_status='TITLE_ELIGIBLE_EXTRACTION_PENDING',screening_reason='Title/metadata supports retaining this candidate for primary extraction. Full-text eligibility, outcomes, bias and procedure appraisal remain open; no efficacy judgment made.' WHERE practice_code='MANTRA_PRACTICES' AND pmid='30245732';
INSERT INTO ilb_ehr_screen_assessment VALUES ('MANTRA_PRACTICES','30245732','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Sustained effects of mantra meditation compared to music listening on neurocognitive outcomes of breast cancer survivors: A brief report of a randomized control trial.',screening_status='TITLE_ELIGIBLE_EXTRACTION_PENDING',screening_reason='Title/metadata supports retaining this candidate for primary extraction. Full-text eligibility, outcomes, bias and procedure appraisal remain open; no efficacy judgment made.' WHERE practice_code='MANTRA_PRACTICES' AND pmid='34600308';
INSERT INTO ilb_ehr_screen_assessment VALUES ('MANTRA_PRACTICES','34600308','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Embodied Cognition in Meditation, Yoga, and Ethics-An Experimental Single-Case Study on the Differential Effects of Four Mind-Body Treatments.',screening_status='IDENTITY_UNCONFIRMED',screening_reason='Named lineage or combined intervention needs primary full-text identification; not attributed to this modality or counted as independent evidence.' WHERE practice_code='MANTRA_PRACTICES' AND pmid='36142006';
INSERT INTO ilb_ehr_screen_assessment VALUES ('MANTRA_PRACTICES','36142006','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Efficacy of Meditation-Based Interventions on Post-Traumatic Stress Disorder (PTSD) Among Veterans: A Narrative Review.',screening_status='CONTEXT_ONLY',screening_reason='Retained for history, observational context or citation chasing. Not an independent primary efficacy appraisal.' WHERE practice_code='MANTRA_PRACTICES' AND pmid='33513582';
INSERT INTO ilb_ehr_screen_assessment VALUES ('MANTRA_PRACTICES','33513582','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Pilot clinical trial of a clinical meditation and imagery intervention for chronic pain after spinal cord injury.',screening_status='IDENTITY_UNCONFIRMED',screening_reason='Named lineage or combined intervention needs primary full-text identification; not attributed to this modality or counted as independent evidence.' WHERE practice_code='MANTRA_PRACTICES' AND pmid='34612802';
INSERT INTO ilb_ehr_screen_assessment VALUES ('MANTRA_PRACTICES','34612802','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Effects of meditation compared to music listening on biomarkers in breast cancer survivors with cognitive complaints: secondary outcomes of a pilot randomized control trial.',screening_status='TITLE_ELIGIBLE_EXTRACTION_PENDING',screening_reason='Title/metadata supports retaining this candidate for primary extraction. Full-text eligibility, outcomes, bias and procedure appraisal remain open; no efficacy judgment made.' WHERE practice_code='MANTRA_PRACTICES' AND pmid='34802955';
INSERT INTO ilb_ehr_screen_assessment VALUES ('MANTRA_PRACTICES','34802955','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Clinical trials of meditation practices in health care: characteristics and quality.',screening_status='CONTEXT_ONLY',screening_reason='Retained for history, observational context or citation chasing. Not an independent primary efficacy appraisal.' WHERE practice_code='MANTRA_PRACTICES' AND pmid='19123875';
INSERT INTO ilb_ehr_screen_assessment VALUES ('MANTRA_PRACTICES','19123875','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Efficacy of Transcendental Meditation to Reduce Stress Among Health Care Workers: A Randomized Clinical Trial.',screening_status='TITLE_ELIGIBLE_EXTRACTION_PENDING',screening_reason='Title/metadata supports retaining this candidate for primary extraction. Full-text eligibility, outcomes, bias and procedure appraisal remain open; no efficacy judgment made.' WHERE practice_code='MANTRA_PRACTICES' AND pmid='36121655';
INSERT INTO ilb_ehr_screen_assessment VALUES ('MANTRA_PRACTICES','36121655','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Scientific Evidence of Health Benefits by Practicing Mantra Meditation: Narrative Review.',screening_status='CONTEXT_ONLY',screening_reason='Retained for history, observational context or citation chasing. Not an independent primary efficacy appraisal.' WHERE practice_code='MANTRA_PRACTICES' AND pmid='36329765';
INSERT INTO ilb_ehr_screen_assessment VALUES ('MANTRA_PRACTICES','36329765','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Who Benefits Most? Interactions between Personality Traits and Outcomes of Four Incremental Meditation and Yoga Treatments.',screening_status='IDENTITY_UNCONFIRMED',screening_reason='Named lineage or combined intervention needs primary full-text identification; not attributed to this modality or counted as independent evidence.' WHERE practice_code='MANTRA_PRACTICES' AND pmid='35956171';
INSERT INTO ilb_ehr_screen_assessment VALUES ('MANTRA_PRACTICES','35956171','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Journey into healing: the transformative experience of shamanic healing on women with temporomandibular joint disorders.',screening_status='IDENTITY_UNCONFIRMED',screening_reason='Broad spiritual or shamanic search; named lineage correspondence must be established before evidence transfer.' WHERE practice_code='CORE_SHAMANISM' AND pmid='21040886';
INSERT INTO ilb_ehr_screen_assessment VALUES ('CORE_SHAMANISM','21040886','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Feasibility and short-term outcomes of a shamanic treatment for temporomandibular joint disorders.',screening_status='IDENTITY_UNCONFIRMED',screening_reason='Broad spiritual or shamanic search; named lineage correspondence must be established before evidence transfer.' WHERE practice_code='CORE_SHAMANISM' AND pmid='17985808';
INSERT INTO ilb_ehr_screen_assessment VALUES ('CORE_SHAMANISM','17985808','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Shamanism as a Clinical Intervention: A Scoping Review.',screening_status='IDENTITY_UNCONFIRMED',screening_reason='Broad spiritual or shamanic search; named lineage correspondence must be established before evidence transfer.' WHERE practice_code='CORE_SHAMANISM' AND pmid='41281382';
INSERT INTO ilb_ehr_screen_assessment VALUES ('CORE_SHAMANISM','41281382','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Shamanic Healing for Veterans with PTSD: A Case Series.',screening_status='IDENTITY_UNCONFIRMED',screening_reason='Broad spiritual or shamanic search; named lineage correspondence must be established before evidence transfer.' WHERE practice_code='CORE_SHAMANISM' AND pmid='28336055';
INSERT INTO ilb_ehr_screen_assessment VALUES ('CORE_SHAMANISM','28336055','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Antinociceptive Efficacy of Shamanic Healing for the Management of Temporomandibular Disorders: An Evidence-Based Review.',screening_status='IDENTITY_UNCONFIRMED',screening_reason='Broad spiritual or shamanic search; named lineage correspondence must be established before evidence transfer.' WHERE practice_code='CORE_SHAMANISM' AND pmid='37269379';
INSERT INTO ilb_ehr_screen_assessment VALUES ('CORE_SHAMANISM','37269379','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Long-term outcomes of shamanic treatment for temporomandibular joint disorders.',screening_status='IDENTITY_UNCONFIRMED',screening_reason='Broad spiritual or shamanic search; named lineage correspondence must be established before evidence transfer.' WHERE practice_code='CORE_SHAMANISM' AND pmid='22745613';
INSERT INTO ilb_ehr_screen_assessment VALUES ('CORE_SHAMANISM','22745613','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Power animal journeying in Western psychotherapy: Applications, therapeutic safety, and future promises.',screening_status='IDENTITY_UNCONFIRMED',screening_reason='Broad spiritual or shamanic search; named lineage correspondence must be established before evidence transfer.' WHERE practice_code='CORE_SHAMANISM' AND pmid='42030677';
INSERT INTO ilb_ehr_screen_assessment VALUES ('CORE_SHAMANISM','42030677','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='The experiential foundations of shamanic healing.',screening_status='IDENTITY_UNCONFIRMED',screening_reason='Broad spiritual or shamanic search; named lineage correspondence must be established before evidence transfer.' WHERE practice_code='CORE_SHAMANISM' AND pmid='8315358';
INSERT INTO ilb_ehr_screen_assessment VALUES ('CORE_SHAMANISM','8315358','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Shamanism as a healing paradigm for complementary therapy.',screening_status='IDENTITY_UNCONFIRMED',screening_reason='Broad spiritual or shamanic search; named lineage correspondence must be established before evidence transfer.' WHERE practice_code='CORE_SHAMANISM' AND pmid='11855507';
INSERT INTO ilb_ehr_screen_assessment VALUES ('CORE_SHAMANISM','11855507','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='A Farmer Becoming a Quasi-doctor: The Daegok Diary and Rural Healthcare from the 1960s to the 1980s.',screening_status='IDENTITY_UNCONFIRMED',screening_reason='Broad spiritual or shamanic search; named lineage correspondence must be established before evidence transfer.' WHERE practice_code='CORE_SHAMANISM' AND pmid='30679411';
INSERT INTO ilb_ehr_screen_assessment VALUES ('CORE_SHAMANISM','30679411','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='What we can learn from shamanic healing: brief psychotherapy with Latino immigrant clients.',screening_status='IDENTITY_UNCONFIRMED',screening_reason='Broad spiritual or shamanic search; named lineage correspondence must be established before evidence transfer.' WHERE practice_code='CORE_SHAMANISM' AND pmid='12356595';
INSERT INTO ilb_ehr_screen_assessment VALUES ('CORE_SHAMANISM','12356595','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='The vidente phenomenon in third world traditional healing: an Amazonian example.',screening_status='IDENTITY_UNCONFIRMED',screening_reason='Broad spiritual or shamanic search; named lineage correspondence must be established before evidence transfer.' WHERE practice_code='CORE_SHAMANISM' AND pmid='6536848';
INSERT INTO ilb_ehr_screen_assessment VALUES ('CORE_SHAMANISM','6536848','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Spiritual healing as a therapy for chronic pain: a randomized, clinical trial.',screening_status='IDENTITY_UNCONFIRMED',screening_reason='Broad spiritual or shamanic search; named lineage correspondence must be established before evidence transfer.' WHERE practice_code='SPIRITUALIST_HEALING' AND pmid='11240080';
INSERT INTO ilb_ehr_screen_assessment VALUES ('SPIRITUALIST_HEALING','11240080','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Assessing the feasibility of a spiritual healing intervention for adults with moderate depression: A pilot randomized controlled trial.',screening_status='IDENTITY_UNCONFIRMED',screening_reason='Broad spiritual or shamanic search; named lineage correspondence must be established before evidence transfer.' WHERE practice_code='SPIRITUALIST_HEALING' AND pmid='39864754';
INSERT INTO ilb_ehr_screen_assessment VALUES ('SPIRITUALIST_HEALING','39864754','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Impact of spiritual healing on moderate depression in adults: a study protocol of a pilot randomised controlled trial (RCT).',screening_status='IDENTITY_UNCONFIRMED',screening_reason='Broad spiritual or shamanic search; named lineage correspondence must be established before evidence transfer.' WHERE practice_code='SPIRITUALIST_HEALING' AND pmid='36109024';
INSERT INTO ilb_ehr_screen_assessment VALUES ('SPIRITUALIST_HEALING','36109024','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='A pragmatic, three-arm randomised controlled trial of spiritual healing for asthma in primary care.',screening_status='IDENTITY_UNCONFIRMED',screening_reason='Broad spiritual or shamanic search; named lineage correspondence must be established before evidence transfer.' WHERE practice_code='SPIRITUALIST_HEALING' AND pmid='16762126';
INSERT INTO ilb_ehr_screen_assessment VALUES ('SPIRITUALIST_HEALING','16762126','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='A randomized controlled trial of spiritual healing in restricted neck movement.',screening_status='IDENTITY_UNCONFIRMED',screening_reason='Broad spiritual or shamanic search; named lineage correspondence must be established before evidence transfer.' WHERE practice_code='SPIRITUALIST_HEALING' AND pmid='14499022';
INSERT INTO ilb_ehr_screen_assessment VALUES ('SPIRITUALIST_HEALING','14499022','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Spiritual healing in the treatment of rheumatoid arthritis: an exploratory single centre, parallel-group, double-blind, three-arm, randomised, sham-controlled trial.',screening_status='IDENTITY_UNCONFIRMED',screening_reason='Broad spiritual or shamanic search; named lineage correspondence must be established before evidence transfer.' WHERE practice_code='SPIRITUALIST_HEALING' AND pmid='25614748';
INSERT INTO ilb_ehr_screen_assessment VALUES ('SPIRITUALIST_HEALING','25614748','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='A systematic review of the quality of research on hands-on and distance healing: clinical and laboratory studies.',screening_status='IDENTITY_UNCONFIRMED',screening_reason='Broad spiritual or shamanic search; named lineage correspondence must be established before evidence transfer.' WHERE practice_code='SPIRITUALIST_HEALING' AND pmid='12776468';
INSERT INTO ilb_ehr_screen_assessment VALUES ('SPIRITUALIST_HEALING','12776468','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='The efficacy of "distant healing": a systematic review of randomized trials.',screening_status='IDENTITY_UNCONFIRMED',screening_reason='Broad spiritual or shamanic search; named lineage correspondence must be established before evidence transfer.' WHERE practice_code='SPIRITUALIST_HEALING' AND pmid='10836918';
INSERT INTO ilb_ehr_screen_assessment VALUES ('SPIRITUALIST_HEALING','10836918','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Effectiveness of Spiritist "passe" (Spiritual healing) for anxiety levels, depression, pain, muscle tension, well-being, and physiological parameters in cardiovascular inpatients: A randomized controlled trial.',screening_status='IDENTITY_UNCONFIRMED',screening_reason='Broad spiritual or shamanic search; named lineage correspondence must be established before evidence transfer.' WHERE practice_code='SPIRITUALIST_HEALING' AND pmid='28137530';
INSERT INTO ilb_ehr_screen_assessment VALUES ('SPIRITUALIST_HEALING','28137530','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Effect of spiritual healing on chronic idiopathic pain: a medical and psychological study.',screening_status='IDENTITY_UNCONFIRMED',screening_reason='Broad spiritual or shamanic search; named lineage correspondence must be established before evidence transfer.' WHERE practice_code='SPIRITUALIST_HEALING' AND pmid='7858359';
INSERT INTO ilb_ehr_screen_assessment VALUES ('SPIRITUALIST_HEALING','7858359','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Effectiveness of distant healing for patients with chronic fatigue syndrome: a randomised controlled partially blinded trial (EUHEALS).',screening_status='IDENTITY_UNCONFIRMED',screening_reason='Broad spiritual or shamanic search; named lineage correspondence must be established before evidence transfer.' WHERE practice_code='SPIRITUALIST_HEALING' AND pmid='18277062';
INSERT INTO ilb_ehr_screen_assessment VALUES ('SPIRITUALIST_HEALING','18277062','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Chronically ill patients treated by spiritual healing improve in quality of life: results of a randomized waiting-list controlled study.',screening_status='IDENTITY_UNCONFIRMED',screening_reason='Broad spiritual or shamanic search; named lineage correspondence must be established before evidence transfer.' WHERE practice_code='SPIRITUALIST_HEALING' AND pmid='11246935';
INSERT INTO ilb_ehr_screen_assessment VALUES ('SPIRITUALIST_HEALING','11246935','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Malpractice against Christian Science practitioners.',screening_status='CONTEXT_ONLY',screening_reason='Retained for history, observational context or citation chasing. Not an independent primary efficacy appraisal.' WHERE practice_code='CHRISTIAN_SCIENCE_HEALING' AND pmid='542103';
INSERT INTO ilb_ehr_screen_assessment VALUES ('CHRISTIAN_SCIENCE_HEALING','542103','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Lundman v. McKown.',screening_status='CONTEXT_ONLY',screening_reason='Retained for history, observational context or citation chasing. Not an independent primary efficacy appraisal.' WHERE practice_code='CHRISTIAN_SCIENCE_HEALING' AND pmid='12041170';
INSERT INTO ilb_ehr_screen_assessment VALUES ('CHRISTIAN_SCIENCE_HEALING','12041170','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Human research: questions raised.',screening_status='EXCLUDED_WRONG_MODALITY',screening_reason='Primary title/metadata identifies a different intervention or conventional biomedical procedure, not this catalogue method.' WHERE practice_code='CHRISTIAN_SCIENCE_HEALING' AND pmid='11648721';
INSERT INTO ilb_ehr_screen_assessment VALUES ('CHRISTIAN_SCIENCE_HEALING','11648721','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Self-reported health, and illness and the use of conventional and unconventional medicine and mind/body healing by Christian Scientists and others.',screening_status='CONTEXT_ONLY',screening_reason='Retained for history, observational context or citation chasing. Not an independent primary efficacy appraisal.' WHERE practice_code='CHRISTIAN_SCIENCE_HEALING' AND pmid='10496509';
INSERT INTO ilb_ehr_screen_assessment VALUES ('CHRISTIAN_SCIENCE_HEALING','10496509','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Comparative longevity in a college cohort of Christian Scientists.',screening_status='CONTEXT_ONLY',screening_reason='Retained for history, observational context or citation chasing. Not an independent primary efficacy appraisal.' WHERE practice_code='CHRISTIAN_SCIENCE_HEALING' AND pmid='2769921';
INSERT INTO ilb_ehr_screen_assessment VALUES ('CHRISTIAN_SCIENCE_HEALING','2769921','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='In re Eric B.',screening_status='CONTEXT_ONLY',screening_reason='Retained for history, observational context or citation chasing. Not an independent primary efficacy appraisal.' WHERE practice_code='CHRISTIAN_SCIENCE_HEALING' AND pmid='11648245';
INSERT INTO ilb_ehr_screen_assessment VALUES ('CHRISTIAN_SCIENCE_HEALING','11648245','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Commonwealth v. Twitchell.',screening_status='CONTEXT_ONLY',screening_reason='Retained for history, observational context or citation chasing. Not an independent primary efficacy appraisal.' WHERE practice_code='CHRISTIAN_SCIENCE_HEALING' AND pmid='12041213';
INSERT INTO ilb_ehr_screen_assessment VALUES ('CHRISTIAN_SCIENCE_HEALING','12041213','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Boundary objects in complementary and alternative medicine: acupuncture vs. Christian Science.',screening_status='CONTEXT_ONLY',screening_reason='Retained for history, observational context or citation chasing. Not an independent primary efficacy appraisal.' WHERE practice_code='CHRISTIAN_SCIENCE_HEALING' AND pmid='25576962';
INSERT INTO ilb_ehr_screen_assessment VALUES ('CHRISTIAN_SCIENCE_HEALING','25576962','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Who should control genetic research?',screening_status='EXCLUDED_WRONG_MODALITY',screening_reason='Primary title/metadata identifies a different intervention or conventional biomedical procedure, not this catalogue method.' WHERE practice_code='CHRISTIAN_SCIENCE_HEALING' AND pmid='11648709';
INSERT INTO ilb_ehr_screen_assessment VALUES ('CHRISTIAN_SCIENCE_HEALING','11648709','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Challenging medical authority. The refusal of treatment by Christian Scientists.',screening_status='CONTEXT_ONLY',screening_reason='Retained for history, observational context or citation chasing. Not an independent primary efficacy appraisal.' WHERE practice_code='CHRISTIAN_SCIENCE_HEALING' AND pmid='7730043';
INSERT INTO ilb_ehr_screen_assessment VALUES ('CHRISTIAN_SCIENCE_HEALING','7730043','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='DNA research: opposition fades.',screening_status='EXCLUDED_WRONG_MODALITY',screening_reason='Primary title/metadata identifies a different intervention or conventional biomedical procedure, not this catalogue method.' WHERE practice_code='CHRISTIAN_SCIENCE_HEALING' AND pmid='11648931';
INSERT INTO ilb_ehr_screen_assessment VALUES ('CHRISTIAN_SCIENCE_HEALING','11648931','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='CHRISTIAN Scientist goes to the doctor.',screening_status='CONTEXT_ONLY',screening_reason='Retained for history, observational context or citation chasing. Not an independent primary efficacy appraisal.' WHERE practice_code='CHRISTIAN_SCIENCE_HEALING' AND pmid='18899179';
INSERT INTO ilb_ehr_screen_assessment VALUES ('CHRISTIAN_SCIENCE_HEALING','18899179','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Pulsed radiofrequency in peripheral posttraumatic neuropathic pain: A double blind sham controlled randomized clinical trial.',screening_status='EXCLUDED_NAME_COLLISION',screening_reason='Returned title/context concerns conventional biology, surgery, devices or psychology; does not identify this named healing method.' WHERE practice_code='RADIONICS' AND pmid='29913831';
INSERT INTO ilb_ehr_screen_assessment VALUES ('RADIONICS','29913831','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Stereotactic brain biopsies in AIDS patients--early local experience.',screening_status='EXCLUDED_NAME_COLLISION',screening_reason='Returned title/context concerns conventional biology, surgery, devices or psychology; does not identify this named healing method.' WHERE practice_code='RADIONICS' AND pmid='11063180';
INSERT INTO ilb_ehr_screen_assessment VALUES ('RADIONICS','11063180','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Phase II trial of radio frequency ablation of renal cancer: evaluation of the kill zone.',screening_status='EXCLUDED_NAME_COLLISION',screening_reason='Returned title/context concerns conventional biology, surgery, devices or psychology; does not identify this named healing method.' WHERE practice_code='RADIONICS' AND pmid='12441926';
INSERT INTO ilb_ehr_screen_assessment VALUES ('RADIONICS','12441926','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Radiofrequency ablation with a new perfused-cooled electrode using a single pump: an experimental study in ex vivo bovine liver.',screening_status='EXCLUDED_NAME_COLLISION',screening_reason='Returned title/context concerns conventional biology, surgery, devices or psychology; does not identify this named healing method.' WHERE practice_code='RADIONICS' AND pmid='16187149';
INSERT INTO ilb_ehr_screen_assessment VALUES ('RADIONICS','16187149','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Multiple fractionated stereotactic radiotherapy of residual pituitary macroadenomas: initial experience.',screening_status='EXCLUDED_NAME_COLLISION',screening_reason='Returned title/context concerns conventional biology, surgery, devices or psychology; does not identify this named healing method.' WHERE practice_code='RADIONICS' AND pmid='9711753';
INSERT INTO ilb_ehr_screen_assessment VALUES ('RADIONICS','9711753','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Endocrine and visual function after fractionated stereotactic radiotherapy of perioptic tumors.',screening_status='EXCLUDED_NAME_COLLISION',screening_reason='Returned title/context concerns conventional biology, surgery, devices or psychology; does not identify this named healing method.' WHERE practice_code='RADIONICS' AND pmid='23283589';
INSERT INTO ilb_ehr_screen_assessment VALUES ('RADIONICS','23283589','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Treatment of symptomatic intracranial arachnoid cysts by stereotactic cyst-ventricular shunting.',screening_status='EXCLUDED_NAME_COLLISION',screening_reason='Returned title/context concerns conventional biology, surgery, devices or psychology; does not identify this named healing method.' WHERE practice_code='RADIONICS' AND pmid='10640921';
INSERT INTO ilb_ehr_screen_assessment VALUES ('RADIONICS','10640921','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Dual-probe radiofrequency ablation: an in vitro experimental study in bovine liver.',screening_status='EXCLUDED_NAME_COLLISION',screening_reason='Returned title/context concerns conventional biology, surgery, devices or psychology; does not identify this named healing method.' WHERE practice_code='RADIONICS' AND pmid='14734923';
INSERT INTO ilb_ehr_screen_assessment VALUES ('RADIONICS','14734923','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Radio frequency ablation of small renal tumors:: intermediate results.',screening_status='EXCLUDED_NAME_COLLISION',screening_reason='Returned title/context concerns conventional biology, surgery, devices or psychology; does not identify this named healing method.' WHERE practice_code='RADIONICS' AND pmid='15076283';
INSERT INTO ilb_ehr_screen_assessment VALUES ('RADIONICS','15076283','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='[Efficacy of pulsed mode radiofrequency lesioning of the suprascapular nerve in chronic shoulder pain secondary to rotator cuff rupture].',screening_status='EXCLUDED_NAME_COLLISION',screening_reason='Returned title/context concerns conventional biology, surgery, devices or psychology; does not identify this named healing method.' WHERE practice_code='RADIONICS' AND pmid='16158343';
INSERT INTO ilb_ehr_screen_assessment VALUES ('RADIONICS','16158343','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Accuracy, efficacy, and clinical applications of the Radionics Operating Arm System.',screening_status='EXCLUDED_NAME_COLLISION',screening_reason='Returned title/context concerns conventional biology, surgery, devices or psychology; does not identify this named healing method.' WHERE practice_code='RADIONICS' AND pmid='9484590';
INSERT INTO ilb_ehr_screen_assessment VALUES ('RADIONICS','9484590','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Clinical short-term results of radiofrequency ablation in primary and secondary liver tumors.',screening_status='EXCLUDED_NAME_COLLISION',screening_reason='Returned title/context concerns conventional biology, surgery, devices or psychology; does not identify this named healing method.' WHERE practice_code='RADIONICS' AND pmid='10326848';
INSERT INTO ilb_ehr_screen_assessment VALUES ('RADIONICS','10326848','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Can homeopaths detect homeopathic medicines by dowsing? A randomized, double-blind, placebo-controlled trial.',screening_status='ABSTRACT_APPRAISED',screening_reason='Focused primary appraisal stored with limitations. This is one reviewer, not independent duplicate screening or a complete modality synthesis.' WHERE practice_code='HEALING_DOWSING' AND pmid='11934908';
INSERT INTO ilb_ehr_screen_assessment VALUES ('HEALING_DOWSING','11934908','ABSTRACT','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Anatomical localization of human detection of weak electromagnetic radiation: experiments with dowsers.',screening_status='TITLE_ELIGIBLE_EXTRACTION_PENDING',screening_reason='Title/metadata supports retaining this candidate for primary extraction. Full-text eligibility, outcomes, bias and procedure appraisal remain open; no efficacy judgment made.' WHERE practice_code='HEALING_DOWSING' AND pmid='754193';
INSERT INTO ilb_ehr_screen_assessment VALUES ('HEALING_DOWSING','754193','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Dowsing can be interfered with by radio frequency radiation.',screening_status='TITLE_ELIGIBLE_EXTRACTION_PENDING',screening_reason='Title/metadata supports retaining this candidate for primary extraction. Full-text eligibility, outcomes, bias and procedure appraisal remain open; no efficacy judgment made.' WHERE practice_code='HEALING_DOWSING' AND pmid='22365422';
INSERT INTO ilb_ehr_screen_assessment VALUES ('HEALING_DOWSING','22365422','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='HER-SAFE study design: an open-label, randomised controlled trial to investigate the safety of withdrawal of pharmacological treatment for recovered HER2-targeted therapy-related cardiac dysfunction.',screening_status='EXCLUDED_WRONG_MODALITY',screening_reason='Primary title/metadata identifies a different intervention or conventional biomedical procedure, not this catalogue method.' WHERE practice_code='HEALING_DOWSING' AND pmid='39909533';
INSERT INTO ilb_ehr_screen_assessment VALUES ('HEALING_DOWSING','39909533','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='The Northwick Park tragedy--protecting healthy volunteers in future first-in-man trials.',screening_status='EXCLUDED_WRONG_MODALITY',screening_reason='Primary title/metadata identifies a different intervention or conventional biomedical procedure, not this catalogue method.' WHERE practice_code='HEALING_DOWSING' AND pmid='17489872';
INSERT INTO ilb_ehr_screen_assessment VALUES ('HEALING_DOWSING','17489872','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='["Earth rays"--an underground phenomenon?].',screening_status='CONTEXT_ONLY',screening_reason='Retained for history, observational context or citation chasing. Not an independent primary efficacy appraisal.' WHERE practice_code='HEALING_DOWSING' AND pmid='9265308';
INSERT INTO ilb_ehr_screen_assessment VALUES ('HEALING_DOWSING','9265308','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='The impact of a regular erythrocytapheresis programme on the acute and chronic complications of sickle cell disease in adults.',screening_status='EXCLUDED_WRONG_MODALITY',screening_reason='Primary title/metadata identifies a different intervention or conventional biomedical procedure, not this catalogue method.' WHERE practice_code='HEALING_DOWSING' AND pmid='20346014';
INSERT INTO ilb_ehr_screen_assessment VALUES ('HEALING_DOWSING','20346014','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Inhaled methoxyflurane for fracture reduction in prehospital extremity trauma: an observational review of HEMS clinical practice.',screening_status='EXCLUDED_WRONG_MODALITY',screening_reason='Primary title/metadata identifies a different intervention or conventional biomedical procedure, not this catalogue method.' WHERE practice_code='HEALING_DOWSING' AND pmid='41845450';
INSERT INTO ilb_ehr_screen_assessment VALUES ('HEALING_DOWSING','41845450','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Safety of withdrawal of pharmacological treatment after recovery from HER2 therapy-related cardiac dysfunction: the HER-SAFE trial.',screening_status='EXCLUDED_WRONG_MODALITY',screening_reason='Primary title/metadata identifies a different intervention or conventional biomedical procedure, not this catalogue method.' WHERE practice_code='HEALING_DOWSING' AND pmid='42669033';
INSERT INTO ilb_ehr_screen_assessment VALUES ('HEALING_DOWSING','42669033','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Predictors of the use and approval of CAM: results from the German General Social Survey (ALLBUS).',screening_status='CONTEXT_ONLY',screening_reason='Retained for history, observational context or citation chasing. Not an independent primary efficacy appraisal.' WHERE practice_code='HEALING_DOWSING' AND pmid='32527256';
INSERT INTO ilb_ehr_screen_assessment VALUES ('HEALING_DOWSING','32527256','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Quantitative Myocardial Perfusion Predicts Outcomes in Patients With Prior Surgical Revascularization.',screening_status='EXCLUDED_WRONG_MODALITY',screening_reason='Primary title/metadata identifies a different intervention or conventional biomedical procedure, not this catalogue method.' WHERE practice_code='HEALING_DOWSING' AND pmid='35331408';
INSERT INTO ilb_ehr_screen_assessment VALUES ('HEALING_DOWSING','35331408','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Timing of administration of dexamethasone or the nitric oxide synthase inhibitor, nitro-L-arginine methyl ester, is critical for effective treatment of ischaemia-reperfusion injury to rat skeletal muscle.',screening_status='EXCLUDED_WRONG_MODALITY',screening_reason='Primary title/metadata identifies a different intervention or conventional biomedical procedure, not this catalogue method.' WHERE practice_code='HEALING_DOWSING' AND pmid='9301432';
INSERT INTO ilb_ehr_screen_assessment VALUES ('HEALING_DOWSING','9301432','TITLE_METADATA','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Reiki for the treatment of fibromyalgia: a randomized controlled trial.',screening_status='ABSTRACT_APPRAISED',screening_reason='Focused primary appraisal stored with limitations. This is one reviewer, not independent duplicate screening or a complete modality synthesis.' WHERE practice_code='REIKI' AND pmid='18991519';
INSERT INTO ilb_ehr_screen_assessment VALUES ('REIKI','18991519','ABSTRACT','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='A close look at therapeutic touch.',screening_status='ABSTRACT_APPRAISED',screening_reason='Focused primary appraisal stored with limitations. This is one reviewer, not independent duplicate screening or a complete modality synthesis.' WHERE practice_code='THERAPEUTIC_TOUCH' AND pmid='9533499';
INSERT INTO ilb_ehr_screen_assessment VALUES ('THERAPEUTIC_TOUCH','9533499','ABSTRACT','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
UPDATE ilb_ehr_candidate_screen SET title='Preservation of immune function in cervical cancer patients during chemoradiation using a novel integrative approach.',screening_status='FULL_TEXT_APPRAISED',screening_reason='Focused primary appraisal stored with limitations. This is one reviewer, not independent duplicate screening or a complete modality synthesis.' WHERE practice_code='HEALING_TOUCH' AND pmid='20600809';
INSERT INTO ilb_ehr_screen_assessment VALUES ('HEALING_TOUCH','20600809','FULL_TEXT','2026-09-30','ILMB single-reviewer screening') ON DUPLICATE KEY UPDATE screening_level=VALUES(screening_level),assessed_on=VALUES(assessed_on);
INSERT INTO ilb_ehr_source(source_key,title,source_type,source_url,citation_text,correction_check,checked_at,publication_status) VALUES ('PMID_37881236','Pranic Healing as a Complementary Therapy in Diabetic Foot Ulcer Management: A Randomised, Controlled, Double-Blind Trial.','TRIAL','https://pubmed.ncbi.nlm.nih.gov/37881236/','10.1177/27536130231183429','PubMed linked notices checked; independent publisher/Crossmark audit remains open','2026-09-30','PUBLISHED') ON DUPLICATE KEY UPDATE checked_at=VALUES(checked_at);
INSERT INTO ilb_ehr_claim(claim_key,practice_code,claim_text,claim_kind,population_text,outcome_text,evidence_status,conclusion_text,reviewed_by,reviewed_at,publication_status) VALUES ('ABSTRACT_37881236','PRANIC_HEALING','Focused study findings: Corrected wound-area comparison favored the intervention, but this small trial does not establish a general treatment effect.','OUTCOME','Adults with diabetic foot ulcers receiving standard care','Wound area, ulcer grade, glycemic measures and symptoms','PRELIMINARY','Corrected wound-area comparison favored the intervention, but this small trial does not establish a general treatment effect.','ILMB primary source appraisal','2026-09-30','PUBLISHED') ON DUPLICATE KEY UPDATE conclusion_text=VALUES(conclusion_text);
INSERT INTO ilb_ehr_evidence_review(claim_id,source_id,source_locator,study_design,sample_size,comparator_text,masking_text,funding_text,findings_text,effect_estimate,uncertainty_text,limitations_text,reviewed_by,reviewed_at) SELECT c.claim_id,s.source_id,'Process & Intervention; corrected Results/Table 2, PMID 39291236','Randomized adjunctive trial; corrected report','30','Standard wound and diabetes care in both arms','Clinician, patients, nursing staff and assessors described as blinded','Pranic Healing Research Institute paid IRB fees; named Pranic healers funded publication charges per correction.','Corrected wound-area comparison favored the intervention, but this small trial does not establish a general treatment effect.','Corrected intergroup t-test p=0.034, 95% interval -9.33 to -0.40; analyzed groups 13 and 9. Corrected prose and tables give inconsistent intervention change values.','Confidence and bias limitations are study-specific; no pooled estimate computed.','Eight of 30 randomized participants absent from final groups; differential attrition, multiple outcomes and unresolved corrected-table inconsistencies limit confidence. Notice revises results and funding; raw-data reconciliation remains open.','ILMB primary source appraisal','2026-09-30' FROM ilb_ehr_claim c JOIN ilb_ehr_source s ON s.source_key='PMID_37881236' WHERE c.claim_key='ABSTRACT_37881236' ON DUPLICATE KEY UPDATE findings_text=VALUES(findings_text),limitations_text=VALUES(limitations_text);
INSERT INTO ilb_ehr_study_scope VALUES ('ABSTRACT_37881236','FULL_TEXT','Remote sessions 50-60 minutes daily for five weeks by ten rotating certified healers. Standard wound care continued. Scanning, cleansing and energising are described, but complete referenced specialist sequences are not reproduced.','CHECKED','HUMAN','Full modality synthesis, independent bias appraisal and registry matching remain open. Available study procedure is not a validated self-treatment prescription.') ON DUPLICATE KEY UPDATE material_reviewed=VALUES(material_reviewed),procedure_text=VALUES(procedure_text);
INSERT INTO ilb_ehr_source(source_key,title,source_type,source_url,citation_text,correction_check,checked_at,publication_status) VALUES ('PMID_33683643','Randomized controlled trial of energy healing effects on pain and anxiety in AIS posterior surgery: a pilot study.','TRIAL','https://pubmed.ncbi.nlm.nih.gov/33683643/','10.1007/s43390-021-00317-3','PubMed linked notices checked; independent publisher/Crossmark audit remains open','2026-09-30','PUBLISHED') ON DUPLICATE KEY UPDATE checked_at=VALUES(checked_at);
INSERT INTO ilb_ehr_claim(claim_key,practice_code,claim_text,claim_kind,population_text,outcome_text,evidence_status,conclusion_text,reviewed_by,reviewed_at,publication_status) VALUES ('ABSTRACT_33683643','BRENNAN_HEALING','Focused study findings: Immediate within-session pain/anxiety decreases were reported. Hospital stay and conversion to oral analgesia did not differ significantly.','OUTCOME','Adolescents undergoing idiopathic scoliosis surgery','Pain, anxiety, oral analgesia transition and hospital stay','PRELIMINARY','Immediate within-session pain/anxiety decreases were reported. Hospital stay and conversion to oral analgesia did not differ significantly.','ILMB primary source appraisal','2026-09-30','PUBLISHED') ON DUPLICATE KEY UPDATE conclusion_text=VALUES(conclusion_text);
INSERT INTO ilb_ehr_evidence_review(claim_id,source_id,source_locator,study_design,sample_size,comparator_text,masking_text,funding_text,findings_text,effect_estimate,uncertainty_text,limitations_text,reviewed_by,reviewed_at) SELECT c.claim_id,s.source_id,'PubMed abstract; indexing keywords','Randomized pilot adjunctive trial','50','Standard operative care','Masking not established from abstract','Not extracted from abstract.','Immediate within-session pain/anxiety decreases were reported. Hospital stay and conversion to oral analgesia did not differ significantly.','28 controls and 22 intervention participants; stay p=0.07, oral analgesia p=0.11. Within-session changes do not supply a between-group clinical effect.','Confidence and bias limitations are study-specific; no pooled estimate computed.','Small pilot, baseline difference in fused levels, no sham described, subjective immediate outcomes. Brennan identity identified in primary indexing; full text required for technique fidelity.','ILMB primary source appraisal','2026-09-30' FROM ilb_ehr_claim c JOIN ilb_ehr_source s ON s.source_key='PMID_33683643' WHERE c.claim_key='ABSTRACT_33683643' ON DUPLICATE KEY UPDATE findings_text=VALUES(findings_text),limitations_text=VALUES(limitations_text);
INSERT INTO ilb_ehr_study_scope VALUES ('ABSTRACT_33683643','ABSTRACT','Three healing sessions alongside scoliosis surgery care; duration and precise sequence not extracted.','PENDING','HUMAN','Full modality synthesis, independent bias appraisal and registry matching remain open. Available study procedure is not a validated self-treatment prescription.') ON DUPLICATE KEY UPDATE material_reviewed=VALUES(material_reviewed),procedure_text=VALUES(procedure_text);
INSERT INTO ilb_ehr_source(source_key,title,source_type,source_url,citation_text,correction_check,checked_at,publication_status) VALUES ('PMID_42555361','Efficacy of Heartfulness Meditation as Adjunctive Therapy for Moderate to Severe Psoriasis: A Randomised Controlled Trial.','TRIAL','https://pubmed.ncbi.nlm.nih.gov/42555361/','10.4103/ijd.ijd_858_24','PubMed linked notices checked; independent publisher/Crossmark audit remains open','2026-09-30','PUBLISHED') ON DUPLICATE KEY UPDATE checked_at=VALUES(checked_at);
INSERT INTO ilb_ehr_claim(claim_key,practice_code,claim_text,claim_kind,population_text,outcome_text,evidence_status,conclusion_text,reviewed_by,reviewed_at,publication_status) VALUES ('ABSTRACT_42555361','HEARTFULNESS','Focused study findings: The primary psoriasis response difference and reported secondary improvements were not statistically significant.','OUTCOME','Adults with moderate-to-severe psoriasis on methotrexate','PASI 75, skin involvement, quality of life, stress and sleep','INSUFFICIENT','The primary psoriasis response difference and reported secondary improvements were not statistically significant.','ILMB primary source appraisal','2026-09-30','PUBLISHED') ON DUPLICATE KEY UPDATE conclusion_text=VALUES(conclusion_text);
INSERT INTO ilb_ehr_evidence_review(claim_id,source_id,source_locator,study_design,sample_size,comparator_text,masking_text,funding_text,findings_text,effect_estimate,uncertainty_text,limitations_text,reviewed_by,reviewed_at) SELECT c.claim_id,s.source_id,'PubMed abstract Methods/Results','Randomized adjunctive trial','50','Methotrexate alone versus plus meditation','Outcome assessors and analysts described as blinded','Not extracted from abstract.','The primary psoriasis response difference and reported secondary improvements were not statistically significant.','PASI 75: 61.1% versus 52.38%, p=0.548; 44 included in final analysis. No interval extracted.','Confidence and bias limitations are study-specific; no pooled estimate computed.','Small study; six randomized participants not in final analysis and reported response denominators need reconciliation. Not evidence of psoriasis cure or replacement of medication.','ILMB primary source appraisal','2026-09-30' FROM ilb_ehr_claim c JOIN ilb_ehr_source s ON s.source_key='PMID_42555361' WHERE c.claim_key='ABSTRACT_42555361' ON DUPLICATE KEY UPDATE findings_text=VALUES(findings_text),limitations_text=VALUES(limitations_text);
INSERT INTO ilb_ehr_study_scope VALUES ('ABSTRACT_42555361','ABSTRACT','Four-month adjunctive meditation evaluation; complete meditation dose and sequence not extracted.','PENDING','HUMAN','Full modality synthesis, independent bias appraisal and registry matching remain open. Available study procedure is not a validated self-treatment prescription.') ON DUPLICATE KEY UPDATE material_reviewed=VALUES(material_reviewed),procedure_text=VALUES(procedure_text);
INSERT INTO ilb_ehr_source(source_key,title,source_type,source_url,citation_text,correction_check,checked_at,publication_status) VALUES ('PMID_18072370','Self identity through Ho''oponopono as adjunctive therapy for hypertension management.','OTHER','https://pubmed.ncbi.nlm.nih.gov/18072370/','PMID 18072370','PubMed linked notices checked; independent publisher/Crossmark audit remains open','2026-09-30','PUBLISHED') ON DUPLICATE KEY UPDATE checked_at=VALUES(checked_at);
INSERT INTO ilb_ehr_claim(claim_key,practice_code,claim_text,claim_kind,population_text,outcome_text,evidence_status,conclusion_text,reviewed_by,reviewed_at,publication_status) VALUES ('ABSTRACT_18072370','HOOPONOPONO','Focused study findings: Blood pressure decreased after the class; causal attribution cannot be made from this design.','OUTCOME','Community participants with hypertension in Hawaii','Repeated systolic and diastolic blood pressure','INSUFFICIENT','Blood pressure decreased after the class; causal attribution cannot be made from this design.','ILMB primary source appraisal','2026-09-30','PUBLISHED') ON DUPLICATE KEY UPDATE conclusion_text=VALUES(conclusion_text);
INSERT INTO ilb_ehr_evidence_review(claim_id,source_id,source_locator,study_design,sample_size,comparator_text,masking_text,funding_text,findings_text,effect_estimate,uncertainty_text,limitations_text,reviewed_by,reviewed_at) SELECT c.claim_id,s.source_id,'PubMed abstract Design/Intervention/Results','Uncontrolled longitudinal before/after study','23','No concurrent comparison group','No masked controlled comparison','NIH support indexed; detailed disclosures not extracted.','Blood pressure decreased after the class; causal attribution cannot be made from this design.','Reported mean decreases 11.86 mmHg systolic and 5.44 mmHg diastolic; no controlled difference or confidence interval extracted.','Confidence and bias limitations are study-specific; no pooled estimate computed.','Small uncontrolled study, regression to mean, medication and attention confounding; no basis for changing hypertension treatment.','ILMB primary source appraisal','2026-09-30' FROM ilb_ehr_claim c JOIN ilb_ehr_source s ON s.source_key='PMID_18072370' WHERE c.claim_key='ABSTRACT_18072370' ON DUPLICATE KEY UPDATE findings_text=VALUES(findings_text),limitations_text=VALUES(limitations_text);
INSERT INTO ilb_ehr_study_scope VALUES ('ABSTRACT_18072370','ABSTRACT','Half-day Self Identity class alongside standard medical therapy, teaching repentance, forgiveness and daily application. Complete sequence not extracted.','NOTICE_FOUND','HUMAN','Full modality synthesis, independent bias appraisal and registry matching remain open. Available study procedure is not a validated self-treatment prescription.') ON DUPLICATE KEY UPDATE material_reviewed=VALUES(material_reviewed),procedure_text=VALUES(procedure_text);
INSERT INTO ilb_ehr_source(source_key,title,source_type,source_url,citation_text,correction_check,checked_at,publication_status) VALUES ('PMID_24327820','Comparison of physical therapy with energy healing for improving range of motion in subjects with restricted shoulder mobility.','OTHER','https://pubmed.ncbi.nlm.nih.gov/24327820/','10.1155/2013/329731','PubMed linked notices checked; independent publisher/Crossmark audit remains open','2026-09-30','PUBLISHED') ON DUPLICATE KEY UPDATE checked_at=VALUES(checked_at);
INSERT INTO ilb_ehr_claim(claim_key,practice_code,claim_text,claim_kind,population_text,outcome_text,evidence_status,conclusion_text,reviewed_by,reviewed_at,publication_status) VALUES ('ABSTRACT_24327820','RECONNECTIVE_HEALING','Focused study findings: Immediate range of motion favored active groups; pain relief was similar with sham. No energy mechanism established.','OUTCOME','Adults with restricted shoulder mobility','Immediate arm range of motion, pain and heart-rate variability','INSUFFICIENT','Immediate range of motion favored active groups; pain relief was similar with sham. No energy mechanism established.','ILMB primary source appraisal','2026-09-30','PUBLISHED') ON DUPLICATE KEY UPDATE conclusion_text=VALUES(conclusion_text);
INSERT INTO ilb_ehr_evidence_review(claim_id,source_id,source_locator,study_design,sample_size,comparator_text,masking_text,funding_text,findings_text,effect_estimate,uncertainty_text,limitations_text,reviewed_by,reviewed_at) SELECT c.claim_id,s.source_id,'Methods 2.2, 2.6-2.8; Results','Nonrandomized controlled study; rotating recruitment-order assignment','78','Physical therapy, Reiki, sham and no-treatment groups','Participants and coded-data analysts masked; no-treatment assignment visible','Detailed independent funding appraisal pending.','Immediate range of motion favored active groups; pain relief was similar with sham. No energy mechanism established.','Mean ROM gains: RH 26 degrees, Reiki 20, physical therapy 12, sham 0.6, no treatment 3. RH/sham comparison p<0.001; no interval extracted.','Confidence and bias limitations are study-specific; no pooled estimate computed.','Allocation rotated with recruitment and occurred in separate phases; not an RCT. Short-term outcomes, heterogeneous diagnoses and incomplete hand sequence. Cannot attribute Reiki findings to every branch.','ILMB primary source appraisal','2026-09-30' FROM ilb_ehr_claim c JOIN ilb_ehr_source s ON s.source_key='PMID_24327820' WHERE c.claim_key='ABSTRACT_24327820' ON DUPLICATE KEY UPDATE findings_text=VALUES(findings_text),limitations_text=VALUES(limitations_text);
INSERT INTO ilb_ehr_study_scope VALUES ('ABSTRACT_24327820','FULL_TEXT','Baseline video ROM, pain and HRV; ten-minute supine session; repeat measures. RH mainly hands off, Reiki mainly touch, sham hand movements 6-12 inches away.','PENDING','HUMAN','Full modality synthesis, independent bias appraisal and registry matching remain open. Available study procedure is not a validated self-treatment prescription.') ON DUPLICATE KEY UPDATE material_reviewed=VALUES(material_reviewed),procedure_text=VALUES(procedure_text);
INSERT INTO ilb_ehr_source(source_key,title,source_type,source_url,citation_text,correction_check,checked_at,publication_status) VALUES ('PMID_11828038','Sahaja yoga in the management of moderate to severe asthma: a randomised controlled trial.','TRIAL','https://pubmed.ncbi.nlm.nih.gov/11828038/','10.1136/thorax.57.2.110','PubMed linked notices checked; independent publisher/Crossmark audit remains open','2026-09-30','PUBLISHED') ON DUPLICATE KEY UPDATE checked_at=VALUES(checked_at);
INSERT INTO ilb_ehr_claim(claim_key,practice_code,claim_text,claim_kind,population_text,outcome_text,evidence_status,conclusion_text,reviewed_by,reviewed_at,publication_status) VALUES ('ABSTRACT_11828038','SAHAJA_YOGA','Focused study findings: Some end-treatment airway and mood measures improved, but overall quality-of-life and asthma scores did not; no significant differences remained at follow-up.','OUTCOME','Adults with symptomatic asthma receiving inhaled steroids','Airway responsiveness, asthma scores, quality of life and mood','PRELIMINARY','Some end-treatment airway and mood measures improved, but overall quality-of-life and asthma scores did not; no significant differences remained at follow-up.','ILMB primary source appraisal','2026-09-30','PUBLISHED') ON DUPLICATE KEY UPDATE conclusion_text=VALUES(conclusion_text);
INSERT INTO ilb_ehr_evidence_review(claim_id,source_id,source_locator,study_design,sample_size,comparator_text,masking_text,funding_text,findings_text,effect_estimate,uncertainty_text,limitations_text,reviewed_by,reviewed_at) SELECT c.claim_id,s.source_id,'PubMed abstract Methods/Results','Randomized adjunctive trial','59','Time-matched control intervention','Authors describe double blind; roles require full text','Not extracted from abstract.','Some end-treatment airway and mood measures improved, but overall quality-of-life and asthma scores did not; no significant differences remained at follow-up.','AHR difference 1.5 doubling doses, 95% interval 0.0-2.9, p=0.047; AQLQ 0.41 (-0.04,0.86); CAS 0.9 (-0.9,2.7).','Confidence and bias limitations are study-specific; no pooled estimate computed.','21/30 yoga and 26/29 control assessed after treatment; differential attrition, several endpoints and borderline estimates. Narrow adjunctive claim only.','ILMB primary source appraisal','2026-09-30' FROM ilb_ehr_claim c JOIN ilb_ehr_source s ON s.source_key='PMID_11828038' WHERE c.claim_key='ABSTRACT_11828038' ON DUPLICATE KEY UPDATE findings_text=VALUES(findings_text),limitations_text=VALUES(limitations_text);
INSERT INTO ilb_ehr_study_scope VALUES ('ABSTRACT_11828038','ABSTRACT','Two-hour weekly sessions for four months, ongoing inhaled steroid treatment; follow-up two months later. Complete meditation sequence not extracted.','NOTICE_FOUND','HUMAN','Full modality synthesis, independent bias appraisal and registry matching remain open. Available study procedure is not a validated self-treatment prescription.') ON DUPLICATE KEY UPDATE material_reviewed=VALUES(material_reviewed),procedure_text=VALUES(procedure_text);
INSERT INTO ilb_ehr_source(source_key,title,source_type,source_url,citation_text,correction_check,checked_at,publication_status) VALUES ('PMID_18654733','Effects of external qigong therapy on osteoarthritis of the knee. A randomized controlled trial.','TRIAL','https://pubmed.ncbi.nlm.nih.gov/18654733/','10.1007/s10067-008-0955-4','PubMed linked notices checked; independent publisher/Crossmark audit remains open','2026-09-30','PUBLISHED') ON DUPLICATE KEY UPDATE checked_at=VALUES(checked_at);
INSERT INTO ilb_ehr_claim(claim_key,practice_code,claim_text,claim_kind,population_text,outcome_text,evidence_status,conclusion_text,reviewed_by,reviewed_at,publication_status) VALUES ('ABSTRACT_18654733','EXTERNAL_QIGONG','Focused study findings: One healer showed larger pain/function improvements; the other did not outperform sham.','OUTCOME','Adults with knee osteoarthritis','WOMAC pain/function and follow-up symptoms','PRELIMINARY','One healer showed larger pain/function improvements; the other did not outperform sham.','ILMB primary source appraisal','2026-09-30','PUBLISHED') ON DUPLICATE KEY UPDATE conclusion_text=VALUES(conclusion_text);
INSERT INTO ilb_ehr_evidence_review(claim_id,source_id,source_locator,study_design,sample_size,comparator_text,masking_text,funding_text,findings_text,effect_estimate,uncertainty_text,limitations_text,reviewed_by,reviewed_at) SELECT c.claim_id,s.source_id,'Methods randomization/control; Table 1; masking and Results','Randomized sham-controlled trial','112','Trained sham healer','Patients and examining physician masked; coordinator knew allocation order','NIH support indexed; complete disclosure appraisal pending.','One healer showed larger pain/function improvements; the other did not outperform sham.','106 completed; healer-2 pain change -25.7 versus sham -13.1, p<0.01. Healer-1 results similar to control; intervals not extracted.','Confidence and bias limitations are study-specific; no pooled estimate computed.','Fixed block size two and coordinator aware of order threaten concealment. Healer subgroup analysis and 91% healer-2 recognition raise bias concerns. No general proof of qi transfer.','ILMB primary source appraisal','2026-09-30' FROM ilb_ehr_claim c JOIN ilb_ehr_source s ON s.source_key='PMID_18654733' WHERE c.claim_key='ABSTRACT_18654733' ON DUPLICATE KEY UPDATE findings_text=VALUES(findings_text),limitations_text=VALUES(limitations_text);
INSERT INTO ilb_ehr_study_scope VALUES ('ABSTRACT_18654733','FULL_TEXT','Five to six sessions over three weeks; black eye covers and curtain; same interpreter with sham. Movements and duration individualized; no single standard technique.','PENDING','HUMAN','Full modality synthesis, independent bias appraisal and registry matching remain open. Available study procedure is not a validated self-treatment prescription.') ON DUPLICATE KEY UPDATE material_reviewed=VALUES(material_reviewed),procedure_text=VALUES(procedure_text);
INSERT INTO ilb_ehr_source(source_key,title,source_type,source_url,citation_text,correction_check,checked_at,publication_status) VALUES ('PMID_31632840','Didgeridoo Sound Meditation for Stress Reduction and Mood Enhancement in Undergraduates: A Randomized Controlled Trial.','OTHER','https://pubmed.ncbi.nlm.nih.gov/31632840/','10.1177/2164956119879367','PubMed linked notices checked; independent publisher/Crossmark audit remains open','2026-09-30','PUBLISHED') ON DUPLICATE KEY UPDATE checked_at=VALUES(checked_at);
INSERT INTO ilb_ehr_claim(claim_key,practice_code,claim_text,claim_kind,population_text,outcome_text,evidence_status,conclusion_text,reviewed_by,reviewed_at,publication_status) VALUES ('ABSTRACT_31632840','SOUND_HEALING','Focused study findings: Sound meditation produced larger immediate relaxation and acute-stress improvements, with no difference on several other mood measures.','OUTCOME','Undergraduates without a regular meditation practice','Immediate self-reported relaxation, stress and mood','PRELIMINARY','Sound meditation produced larger immediate relaxation and acute-stress improvements, with no difference on several other mood measures.','ILMB primary source appraisal','2026-09-30','PUBLISHED') ON DUPLICATE KEY UPDATE conclusion_text=VALUES(conclusion_text);
INSERT INTO ilb_ehr_evidence_review(claim_id,source_id,source_locator,study_design,sample_size,comparator_text,masking_text,funding_text,findings_text,effect_estimate,uncertainty_text,limitations_text,reviewed_by,reviewed_at) SELECT c.claim_id,s.source_id,'Methods Study design/Interventions; Results; Limitations','Randomized active-comparator single-session study','74','Silent breath-focused meditation','Participants learned assignment before intervention; analysts masked','Independent disclosure appraisal pending.','Sound meditation produced larger immediate relaxation and acute-stress improvements, with no difference on several other mood measures.','Relaxation interaction d=0.55, p=0.01; acute stress d=0.53, p=0.03, assessed in only 54 participants.','Confidence and bias limitations are study-specific; no pooled estimate computed.','133 eligible agreed; 59 did not attend. Single session, self-report, unvalidated one-item stress scale, incomplete stress sampling and multiple comparisons. Does not establish energy-field effects.','ILMB primary source appraisal','2026-09-30' FROM ilb_ehr_claim c JOIN ilb_ehr_source s ON s.source_key='PMID_31632840' WHERE c.claim_key='ABSTRACT_31632840' ON DUPLICATE KEY UPDATE findings_text=VALUES(findings_text),limitations_text=VALUES(limitations_text);
INSERT INTO ilb_ehr_study_scope VALUES ('ABSTRACT_31632840','FULL_TEXT','Sit upright, close eyes, focus on live didgeridoo for 30 minutes; attention reminders at minutes 5,10,20. Control followed same timing with breath focus.','PENDING','HUMAN','Full modality synthesis, independent bias appraisal and registry matching remain open. Available study procedure is not a validated self-treatment prescription.') ON DUPLICATE KEY UPDATE material_reviewed=VALUES(material_reviewed),procedure_text=VALUES(procedure_text);
INSERT INTO ilb_ehr_source(source_key,title,source_type,source_url,citation_text,correction_check,checked_at,publication_status) VALUES ('PMID_32721212','Inter-Rater Agreement of Biofield Tuning: Testing a Novel Health Assessment Procedure.','OTHER','https://pubmed.ncbi.nlm.nih.gov/32721212/','10.1089/acm.2020.0159','PubMed linked notices checked; independent publisher/Crossmark audit remains open','2026-09-30','PUBLISHED') ON DUPLICATE KEY UPDATE checked_at=VALUES(checked_at);
INSERT INTO ilb_ehr_claim(claim_key,practice_code,claim_text,claim_kind,population_text,outcome_text,evidence_status,conclusion_text,reviewed_by,reviewed_at,publication_status) VALUES ('ABSTRACT_32721212','BIOFIELD_TUNING','Focused study findings: Agreement on claimed perturbation locations was poor; this does not validate a diagnostic assessment.','MECHANISM','Adult volunteers without serious current illness','Agreement between practitioners on perturbation locations','INSUFFICIENT','Agreement on claimed perturbation locations was poor; this does not validate a diagnostic assessment.','ILMB primary source appraisal','2026-09-30','PUBLISHED') ON DUPLICATE KEY UPDATE conclusion_text=VALUES(conclusion_text);
INSERT INTO ilb_ehr_evidence_review(claim_id,source_id,source_locator,study_design,sample_size,comparator_text,masking_text,funding_text,findings_text,effect_estimate,uncertainty_text,limitations_text,reviewed_by,reviewed_at) SELECT c.claim_id,s.source_id,'PubMed abstract Design/Results','Inter-rater agreement assessment','10','Three practitioners assess the same volunteers','Rater order randomized; masking details limited','Not extracted from abstract.','Agreement on claimed perturbation locations was poor; this does not validate a diagnostic assessment.','Agreement 33% with a two-inch tolerance; Monte Carlo analysis supported low agreement.','Confidence and bias limitations are study-specific; no pooled estimate computed.','Ten volunteers and no health-diagnosis ground truth. Reliability is distinct from efficacy and physical biofield existence.','ILMB primary source appraisal','2026-09-30' FROM ilb_ehr_claim c JOIN ilb_ehr_source s ON s.source_key='PMID_32721212' WHERE c.claim_key='ABSTRACT_32721212' ON DUPLICATE KEY UPDATE findings_text=VALUES(findings_text),limitations_text=VALUES(limitations_text);
INSERT INTO ilb_ehr_study_scope VALUES ('ABSTRACT_32721212','ABSTRACT','Activated 174 Hz unweighted tuning fork used along four sites at spine base and heart on both sides; location distances recorded.','PENDING','HUMAN','Full modality synthesis, independent bias appraisal and registry matching remain open. Available study procedure is not a validated self-treatment prescription.') ON DUPLICATE KEY UPDATE material_reviewed=VALUES(material_reviewed),procedure_text=VALUES(procedure_text);
INSERT INTO ilb_ehr_source(source_key,title,source_type,source_url,citation_text,correction_check,checked_at,publication_status) VALUES ('PMID_37023932','Sound healing reduces generalized anxiety during the pandemic: A feasibility study.','OTHER','https://pubmed.ncbi.nlm.nih.gov/37023932/','10.1016/j.ctim.2023.102947','PubMed linked notices checked; independent publisher/Crossmark audit remains open','2026-09-30','PUBLISHED') ON DUPLICATE KEY UPDATE checked_at=VALUES(checked_at);
INSERT INTO ilb_ehr_claim(claim_key,practice_code,claim_text,claim_kind,population_text,outcome_text,evidence_status,conclusion_text,reviewed_by,reviewed_at,publication_status) VALUES ('ABSTRACT_37023932','BIOFIELD_TUNING','Focused study findings: Anxiety and stress declined during remote sessions; feasibility and experiences cannot establish causal effectiveness.','OUTCOME','Participants meeting study anxiety criteria during the pandemic','Self-reported anxiety, stress, affect and feasibility','INSUFFICIENT','Anxiety and stress declined during remote sessions; feasibility and experiences cannot establish causal effectiveness.','ILMB primary source appraisal','2026-09-30','PUBLISHED') ON DUPLICATE KEY UPDATE conclusion_text=VALUES(conclusion_text);
INSERT INTO ilb_ehr_evidence_review(claim_id,source_id,source_locator,study_design,sample_size,comparator_text,masking_text,funding_text,findings_text,effect_estimate,uncertainty_text,limitations_text,reviewed_by,reviewed_at) SELECT c.claim_id,s.source_id,'PubMed abstract Design/Intervention/Results','Uncontrolled feasibility study','15','No comparison group','No blinded controlled outcomes','Not extracted from abstract.','Anxiety and stress declined during remote sessions; feasibility and experiences cannot establish causal effectiveness.','Two participants withdrew; within-group anxiety/affect/stress p<0.001, not a between-group treatment effect.','Confidence and bias limitations are study-specific; no pooled estimate computed.','Same feasibility cohort as qualitative report PMID 37537086: not two independent efficacy replications. Attention, regression, expectation and follow-up unresolved.','ILMB primary source appraisal','2026-09-30' FROM ilb_ehr_claim c JOIN ilb_ehr_source s ON s.source_key='PMID_37023932' WHERE c.claim_key='ABSTRACT_37023932' ON DUPLICATE KEY UPDATE findings_text=VALUES(findings_text),limitations_text=VALUES(limitations_text);
INSERT INTO ilb_ehr_study_scope VALUES ('ABSTRACT_37023932','ABSTRACT','Three weekly one-hour sessions delivered remotely by five certified practitioners. Full technique sequence not extracted.','PENDING','HUMAN','Full modality synthesis, independent bias appraisal and registry matching remain open. Available study procedure is not a validated self-treatment prescription.') ON DUPLICATE KEY UPDATE material_reviewed=VALUES(material_reviewed),procedure_text=VALUES(procedure_text);
INSERT INTO ilb_ehr_source(source_key,title,source_type,source_url,citation_text,correction_check,checked_at,publication_status) VALUES ('ACCESS_SOURCE_2017','The Effects of Access Bars on Anxiety and Depression: A Pilot Study','OTHER','https://energypsychologyjournal.org/effects-access-bars-anxiety-depression-pilot-study/','10.9769/EPJ.2017.9.2.TH','Notice and disclosure audit pending; full article purchase required on publisher page','2026-09-30','PUBLISHED') ON DUPLICATE KEY UPDATE checked_at=VALUES(checked_at);
INSERT INTO ilb_ehr_claim(claim_key,practice_code,claim_text,claim_kind,population_text,outcome_text,evidence_status,conclusion_text,reviewed_by,reviewed_at,publication_status) VALUES ('ACCESS_REPORT_2017','ACCESS_BARS','Large immediate score decreases reported in seven participants; uncontrolled results and EEG changes do not establish a treatment effect.','OUTCOME','Small uncontrolled participant series','Reported anxiety/depression/stress scores','INSUFFICIENT','Large immediate score decreases reported in seven participants; uncontrolled results and EEG changes do not establish a treatment effect.','ILMB publisher abstract appraisal','2026-09-30','PUBLISHED') ON DUPLICATE KEY UPDATE conclusion_text=VALUES(conclusion_text);
INSERT INTO ilb_ehr_evidence_review(claim_id,source_id,source_locator,study_design,sample_size,comparator_text,masking_text,funding_text,findings_text,effect_estimate,uncertainty_text,limitations_text,reviewed_by,reviewed_at) SELECT c.claim_id,s.source_id,'Publisher abstract Methods/Results','Uncontrolled before/after pilot or case series','7','None','No masked controlled comparison','Full disclosure appraisal pending','Large immediate score decreases reported in seven participants; uncontrolled results and EEG changes do not establish a treatment effect.','Within-person scores only; no controlled effect estimate','Very small sample; no reliable controlled uncertainty','No control; repeated measures, expectation, regression to mean and concurrent care not isolated. Full article unavailable through the accessed publisher page.','ILMB publisher abstract appraisal','2026-09-30' FROM ilb_ehr_claim c JOIN ilb_ehr_source s ON s.source_key='ACCESS_SOURCE_2017' WHERE c.claim_key='ACCESS_REPORT_2017' ON DUPLICATE KEY UPDATE limitations_text=VALUES(limitations_text);
INSERT INTO ilb_ehr_study_scope VALUES ('ACCESS_REPORT_2017','ABSTRACT','One 90-minute session; complete sequence not available in publisher abstract.','PENDING','HUMAN','Full paper, conflicts, notices and independent controlled replication required.') ON DUPLICATE KEY UPDATE procedure_text=VALUES(procedure_text);
INSERT INTO ilb_ehr_source(source_key,title,source_type,source_url,citation_text,correction_check,checked_at,publication_status) VALUES ('ACCESS_SOURCE_2023','The Effects of Access Bars on Depression, Anxiety, and Stress in Police Officers','OTHER','https://energypsychologyjournal.org/effects-access-bars-on-depression-anxiety-stress-in-police-officers/','10.9769/EPJ.2023.15.2.TH','Notice and disclosure audit pending; full article purchase required on publisher page','2026-09-30','PUBLISHED') ON DUPLICATE KEY UPDATE checked_at=VALUES(checked_at);
INSERT INTO ilb_ehr_claim(claim_key,practice_code,claim_text,claim_kind,population_text,outcome_text,evidence_status,conclusion_text,reviewed_by,reviewed_at,publication_status) VALUES ('ACCESS_REPORT_2023','ACCESS_BARS','Four-person uncontrolled case series reports lower scores after treatment; no comparator, no controlled effect or general PTSD efficacy demonstrated.','OUTCOME','Small uncontrolled participant series','Reported anxiety/depression/stress scores','INSUFFICIENT','Four-person uncontrolled case series reports lower scores after treatment; no comparator, no controlled effect or general PTSD efficacy demonstrated.','ILMB publisher abstract appraisal','2026-09-30','PUBLISHED') ON DUPLICATE KEY UPDATE conclusion_text=VALUES(conclusion_text);
INSERT INTO ilb_ehr_evidence_review(claim_id,source_id,source_locator,study_design,sample_size,comparator_text,masking_text,funding_text,findings_text,effect_estimate,uncertainty_text,limitations_text,reviewed_by,reviewed_at) SELECT c.claim_id,s.source_id,'Publisher abstract Methods/Results','Uncontrolled before/after pilot or case series','4','None','No masked controlled comparison','Full disclosure appraisal pending','Four-person uncontrolled case series reports lower scores after treatment; no comparator, no controlled effect or general PTSD efficacy demonstrated.','Within-person scores only; no controlled effect estimate','Very small sample; no reliable controlled uncertainty','No control; repeated measures, expectation, regression to mean and concurrent care not isolated. Full article unavailable through the accessed publisher page.','ILMB publisher abstract appraisal','2026-09-30' FROM ilb_ehr_claim c JOIN ilb_ehr_source s ON s.source_key='ACCESS_SOURCE_2023' WHERE c.claim_key='ACCESS_REPORT_2023' ON DUPLICATE KEY UPDATE limitations_text=VALUES(limitations_text);
INSERT INTO ilb_ehr_study_scope VALUES ('ACCESS_REPORT_2023','ABSTRACT','Seven weekly 60-minute sessions; complete sequence not available in publisher abstract.','PENDING','HUMAN','Full paper, conflicts, notices and independent controlled replication required.') ON DUPLICATE KEY UPDATE procedure_text=VALUES(procedure_text);
UPDATE ilb_ehr_study_scope SET material_reviewed='FULL_TEXT',procedure_text='Twenty-to-thirty-minute sessions four days weekly for six weeks after radiation. Techniques: centering, pain drain, chakra connection, magnetic unruffling, mind clearing; some touch and individualized additional techniques. Not a complete fixed hand-position sequence.',next_steps='Independent replication, registry/notices and complete modality synthesis remain open.' WHERE claim_key='ABSTRACT_20600809';
UPDATE ilb_ehr_evidence_review e JOIN ilb_ehr_claim c ON c.claim_id=e.claim_id SET e.source_locator='Methods 2.1-2.3; Results 3.3-3.5',e.limitations_text='Permuted blocks in sealed envelopes; laboratory staff and physicians masked. 60 randomized, 51 completed. Participants could distinguish interventions; several outcomes and no clinical survival endpoint.',e.effect_estimate='NKCC interaction coefficient 1.01, p=0.018; toxicity p=0.93 and treatment-delay p=0.94 showed no difference.' WHERE c.claim_key='ABSTRACT_20600809';
UPDATE ilb_ehr_study_scope SET material_reviewed='FULL_TEXT',procedure_text='Three weekly approximately 75-minute clothed supine/prone sessions; gentle connector contacts such as ears or soles, individualized duration. Modified massage controlled time, touch and attention. No fixed universal sequence extracted.',next_steps='Independent replication, registry/notices and complete modality synthesis remain open.' WHERE claim_key='ABSTRACT_21382958';
UPDATE ilb_ehr_evidence_review e JOIN ilb_ehr_claim c ON c.claim_id=e.claim_id SET e.source_locator='Methods treatments; Results fatigue/HRQL; Limitations',e.limitations_text='45 randomized, 43 analyzed; baseline fatigue imbalance, lack of participant masking, ancillary symptom treatments and exploratory multiplicity limit confidence.',e.effect_estimate='Primary BFI repeated-measures p=0.72; adjusted average p=0.64. Diary effects are secondary; do not present as a positive primary endpoint.' WHERE c.claim_key='ABSTRACT_21382958';
UPDATE ilb_ehr_study_scope SET material_reviewed='FULL_TEXT',procedure_text='Recorded signals played four hours per exposure day on daily or weekly schedule. Control housed in a different room. This recording exposure is distinct from live practitioner treatment and human self-practice.',next_steps='Independent replication, registry/notices and complete modality synthesis remain open.' WHERE claim_key='ABSTRACT_32284695';
UPDATE ilb_ehr_evidence_review e JOIN ilb_ehr_claim c ON c.claim_id=e.claim_id SET e.source_locator='Methods Animals/Recording/Treatment; Results; Disclosures',e.limitations_text='25 tumor-bearing mice (5/10/10) and 15 healthy mice; different housing rooms and early euthanasia create confounding and attrition. Numerous biomarker analyses. Inventor coauthor declares interest; no human cancer efficacy.',e.effect_estimate='Tumor endpoints and selected markers are preclinical; day-28 survivor restriction and room differences limit attribution.' WHERE c.claim_key='ABSTRACT_32284695';
INSERT INTO ilb_ehr_notice_review VALUES ('32649851','36398997','https://pubmed.ncbi.nlm.nih.gov/36398997/','Missing country affiliations supplied (United States); authors declare no potential conflicts. This notice does not replace results.','Original full-text methods and effect appraisal still open.','2026-09-30') ON DUPLICATE KEY UPDATE correction_scope=VALUES(correction_scope),remaining_issue=VALUES(remaining_issue);
UPDATE ilb_ehr_study_scope SET notice_status='CHECKED' WHERE claim_key='ABSTRACT_32649851';
UPDATE ilb_ehr_source SET correction_check='Missing country affiliations supplied (United States); authors declare no potential conflicts. This notice does not replace results. Original full-text methods and effect appraisal still open.' WHERE source_key='PMID_32649851';
INSERT INTO ilb_ehr_notice_review VALUES ('37881236','39291236','https://pubmed.ncbi.nlm.nih.gov/39291236/','Affiliation, flowchart text, Results/tables, acknowledgments and funding revised; original online version updated.','Revised prose and tables retain inconsistent wound-change and sample counts; reconcile raw data before a stronger conclusion.','2026-09-30') ON DUPLICATE KEY UPDATE correction_scope=VALUES(correction_scope),remaining_issue=VALUES(remaining_issue);
UPDATE ilb_ehr_study_scope SET notice_status='CHECKED' WHERE claim_key='ABSTRACT_37881236';
UPDATE ilb_ehr_source SET correction_check='Affiliation, flowchart text, Results/tables, acknowledgments and funding revised; original online version updated. Revised prose and tables retain inconsistent wound-change and sample counts; reconcile raw data before a stronger conclusion.' WHERE source_key='PMID_37881236';
UPDATE ilb_ehr_evidence_review e JOIN ilb_ehr_claim c ON c.claim_id=e.claim_id SET e.limitations_text='Small self-report study; expectation, attrition and crossover analysis require full text. Notice PMID 36398997 supplies country affiliations and a no-conflict declaration; it does not revise outcomes.',e.funding_text='Corrected notice declares no potential conflicts; original funding details require full text.' WHERE c.claim_key='ABSTRACT_32649851';
INSERT INTO ilb_ehr_database_search VALUES ('PRANIC_HEALING','("Pranic Healing"[Title/Abstract]) AND ("1800/01/01"[Date - Publication] : "2026/09/30"[Date - Publication])','NCBI PubMed ESearch API','2026-09-30','2026-09-30','OK','19','"Pranic Healing"[Title/Abstract] AND 1800/01/01:2026/09/30[Date - Publication]','42605255
42039726
40837116
39667977
39291236
39033882
38939830
37881236
37711602
37119543
34255215
31668156
31341443
28836826
26665042
19175256
15040779
12889412
12056313','{"phrasesignored": [], "quotedphrasesnotfound": [], "outputmessages": ["Restrictions achieved. start and count adjusted to 0, 9999"]} ') ON DUPLICATE KEY UPDATE retrieval_status=VALUES(retrieval_status),result_count=VALUES(result_count),returned_pmids=VALUES(returned_pmids),warnings_text=VALUES(warnings_text);
INSERT INTO ilb_ehr_research_gate VALUES ('PRANIC_HEALING','2026-09-30','0','PubMed database query status OK; 19 returned records, including possible name collisions. 10 returned identifiers are outside the earlier cohort and require metadata screening. Earlier cohort: 6 retained/identity candidates still need extraction or resolution. No exhaustive or clinical-validation conclusion is asserted.','Screen expanded query identifiers and resolve aliases/lineages; search registries and regional/non-English databases; appraise remaining full texts and bias; compare independent outcome-specific studies; extract complete procedures where reported. Never infer branch efficacy from parent studies or diagnose using unvalidated energy measurements.') ON DUPLICATE KEY UPDATE summary_text=VALUES(summary_text),next_actions=VALUES(next_actions),research_complete=VALUES(research_complete);
INSERT INTO ilb_ehr_database_search VALUES ('MAGNIFIED_HEALING','("Magnified Healing"[Title/Abstract]) AND ("1800/01/01"[Date - Publication] : "2026/09/30"[Date - Publication])','NCBI PubMed ESearch API','2026-09-30','2026-09-30','OK','0','("Magnified Healing"[Title/Abstract]) AND ("1800/01/01"[Date - Publication] : "2026/09/30"[Date - Publication])','','{"phrasesignored": [], "quotedphrasesnotfound": ["\"Magnified Healing\"[Title/Abstract]"], "outputmessages": ["Restrictions achieved. start and count adjusted to 0, 9999", "No items found."]} ') ON DUPLICATE KEY UPDATE retrieval_status=VALUES(retrieval_status),result_count=VALUES(result_count),returned_pmids=VALUES(returned_pmids),warnings_text=VALUES(warnings_text);
INSERT INTO ilb_ehr_research_gate VALUES ('MAGNIFIED_HEALING','2026-09-30','0','PubMed database query status OK; 0 returned records, including possible name collisions. 0 returned identifiers are outside the earlier cohort and require metadata screening. Earlier cohort: 0 retained/identity candidates still need extraction or resolution. No exhaustive or clinical-validation conclusion is asserted.','No records returned by this exact PubMed query. This does not establish no research: verify aliases and publisher reports outside PubMed. Screen expanded query identifiers and resolve aliases/lineages; search registries and regional/non-English databases; appraise remaining full texts and bias; compare independent outcome-specific studies; extract complete procedures where reported. Never infer branch efficacy from parent studies or diagnose using unvalidated energy measurements.') ON DUPLICATE KEY UPDATE summary_text=VALUES(summary_text),next_actions=VALUES(next_actions),research_complete=VALUES(research_complete);
INSERT INTO ilb_ehr_database_search VALUES ('REIKI','("Reiki"[Title/Abstract]) AND ("1800/01/01"[Date - Publication] : "2026/09/30"[Date - Publication])','NCBI PubMed ESearch API','2026-09-30','2026-09-30','OK','429','"Reiki"[Title/Abstract] AND 1800/01/01:2026/09/30[Date - Publication]','42813884
42805879
42766936
42721754
42626333
42551571
42508010
42491574
42469949
42427118
42392933
42385109
42315636
42263755
42108752
42039726
41984024
41954493
41951553
41884352
41852013
41793784
41789910
41778078
41761986
41662322
41635184
41555896
41433417
41430763
41377076
41370530
41341454
41264460
41221955
41183719
41171585
41164641
41135140
41051913
41015064
41004389
40978605
40978603
40967425
40900563
40856898
40856793
40856748
40845346
40802410
40689652
40673750
40425035
40396344
40364466
40332998
40300254
40237049
40160720
40151965
40148929
40034577
39991409
39908578
39899546
39854162
39828478
39827748
39715572
39671363
39613272
39565707
39557196
39499888
39405793
39400912
39319886
39304481
39270308
39255457
39225031
39121752
39120250
39097970
39042722
39042182
39042101
38971115
38963809
38872168
38746536
38729141
38652801
38563780
38546686
38490826
30860755
38307816
38307809
38304734
38300148
38131135
38030555
37966988
37851350
37851347
37738314
37711602
37614464
37595119
37270354
37070840
36646612
36481177
36476354
36331090
36308730
36278509
36272846
36173262
36166091
35981119
35976274
35951066
35911042
35851503
35752581
35722865
35613402
35481320
35435859
35074604
34990899
34723183
34647912
34577790
34387236
34312086
34293753
34262006
34199174
34115737
34083124
34037196
34029232
33994324
33836405
33787777
33675935
33639516
33544513
33252426
33246388
33223611
33132081
33131629
33131628
33128534
33111740
33053005
32871687
32871021
32798173
32778391
32728837
32618216
32408085
32362016
32361655
32236440
32224256
32147038
32107160
32100622
32002940
31928064
31780011
31642490
31638407
31331581
31233312
31046557
31003689
30948444
30870027
30305254
30170509
30076965
30057036
29883196
29620922
29551623
29536776
29498537
29460558
29315084
29228783
28968143
28874060
28845677
28794663
28668857
28654301
28572102
28497700
28443949
28181973
28112554
27901219
30179378
27846661
27790858
27763932
27548991
27502811
27297510
27206308
27184735
27119403
27078812
27078809
27058159
26867264
26858170
26803374
26775426
26760383
26665043
26665042
26571281
26436931
26343105
26167739
26163604
26025798
25835541
25828811
25694849
25457442
25381189
25314111
25303853
25299140
25258446
25253110
25181286
25138568
25037669
24967637
24899738
24817897
24767262
24582620
24439640
24327820
24310710
24280471
24259404
24105356
24096385
24093734
24083770
24020920
23977801
23799960
23686463
23617447
25031994
23550268
23337565
23337563
23294820
23221065
23211384
23210468
23182602
23155905
23086004
23018166
22863644
22760464
22658441
22500842
22281310
22132706
22058669
22030577
22021729
22015342
21998438
21921709
21832928
21832927
21832926
21821642
21701183
21697661
21670620
21584234
21543407
21531671
21497321
21484835
21482920
21220082
21140870
20923076
20920808
20828654
20813333
20803609
20733345
20706088
20699431
20640288
20635803
20630360
20355265
20189724
20186018
20145447
20092137
20009019
19922247
19856109
19819311
19623833
19567731
19531072
19515284
19487318
19422284
19411991
19024236
18991519
18843720
18780590
18515247
18435597
18410352
18193585
18029964
17957554
20664124
17848766
17714796
17627194
17619753
17573275
17544681
17508495
17351024
17309379
17144199
17109583
17109581
17099413
17022926
16925002
16825921
16822357
16781577
16669984
16518156
16494564
16494563
16463715
16373889
16297024
20973269
16094133
16056170
15992246
15992229
15944500
15674004
15624343
15561517
15458751
15356954
15186894
15154152
14639779
14639776
14585550
14571006
12889549
12868256
12652892
12652885
12652881
12652880
12630139
12629941
12620133
12614528
12594975
12592974
12503455
12269776
12188157
12119625
11926432
11894284
11890385
11855528
11816777
11586477
11482809
11324176
11251731
10979163
28080439
10373831
10330795
10328637
9823252
9541710
9464018
9395702
9225408
9765732
9069762
8685612
9395679
11362356
7849997
7843869','{"phrasesignored": [], "quotedphrasesnotfound": [], "outputmessages": ["Restrictions achieved. start and count adjusted to 0, 9999"]} ') ON DUPLICATE KEY UPDATE retrieval_status=VALUES(retrieval_status),result_count=VALUES(result_count),returned_pmids=VALUES(returned_pmids),warnings_text=VALUES(warnings_text);
INSERT INTO ilb_ehr_research_gate VALUES ('REIKI','2026-09-30','0','PubMed database query status OK; 429 returned records, including possible name collisions. 416 returned identifiers are outside the earlier cohort and require metadata screening. Earlier cohort: 8 retained/identity candidates still need extraction or resolution. No exhaustive or clinical-validation conclusion is asserted.','Screen expanded query identifiers and resolve aliases/lineages; search registries and regional/non-English databases; appraise remaining full texts and bias; compare independent outcome-specific studies; extract complete procedures where reported. Never infer branch efficacy from parent studies or diagnose using unvalidated energy measurements.') ON DUPLICATE KEY UPDATE summary_text=VALUES(summary_text),next_actions=VALUES(next_actions),research_complete=VALUES(research_complete);
INSERT INTO ilb_ehr_database_search VALUES ('THERAPEUTIC_TOUCH','("Therapeutic Touch"[Title/Abstract]) AND ("1800/01/01"[Date - Publication] : "2026/09/30"[Date - Publication])','NCBI PubMed ESearch API','2026-09-30','2026-09-30','OK','575','"Therapeutic Touch"[Title/Abstract] AND 1800/01/01:2026/09/30[Date - Publication]','42723022
42677350
42626333
42624695
42622803
42509575
42108752
42069826
42068796
42039726
41982211
41954493
41951553
41864692
41851982
41845859
41802174
41738840
41709616
41699875
41688284
41574421
41555896
41506515
41244962
41225691
41111187
41026955
41020673
40941433
40937093
40900563
40856898
40709785
40689652
40668936
40574457
40396344
40326007
40300254
40160720
40148795
40051757
39918364
39854162
39680900
39667977
39639605
39602095
39513174
39270308
39143930
39097970
39043113
38998887
38905700
38837237
38382911
38307816
38307809
38304734
38300148
38286705
38268021
38218673
37926497
37874963
37640590
37404216
37270354
40115365
36923275
36810482
36693813
38662012
36529594
36517809
36189075
36189047
36166091
35846789
35738774
35613519
35340008
35250723
34723183
34577790
34536666
34199174
34066393
37184330
33861467
33789431
33762231
33742792
33548747
33338148
33218495
32852138
32508602
32415423
32364462
32147030
32002940
31780011
31632842
33344958
31469240
31450520
31062207
30997970
30982141
30709784
30425012
30367804
30297988
30066319
29861224
29526233
29498537
29479909
29357856
29299785
29220625
29205082
29041781
28950108
28845677
28821217
28786890
28801081
28654301
28572102
28254638
28235686
28137530
27925607
27615696
27581995
27552401
27515871
27502814
27482166
27390459
27206308
27194823
27186202
27140910
26955265
26850808
26822561
26803374
26665043
26665042
26571281
26430688
26333111
26275655
26113869
26016134
25895186
25722103
25682383
25457442
25284739
25253110
25181286
25144965
25069726
24947468
26997809
24767262
24700218
24488378
24280471
24259404
24055114
24020920
23817594
25031994
23559181
23546330
23211388
23040157
22995597
22828950
22820486
22792482
22765216
22696330
22562939
22509710
22281310
23556330
21805785
21701183
21697661
21481259
21360035
21337796
21220082
21194672
20942309
20920808
28076045
20630360
20618097
20585102
20585101
20189724
20186018
21589748
19856109
19657203
19299529
19233016
19222055
19176854
19142390
27820539
19060577
18955319
18843720
18755877
18602618
18524012
18442414
18370579
18332356
18332355
18272750
18258581
28792815
18029960
18021160
17985064
17786889
17661855
17636838
17609996
17609994
17573275
17544681
17370014
17369995
17309379
17260598
17034678
17022926
17019255
16932660
16825921
16781590
16566349
16502914
16449746
16449745
16437862
16260314
16145330
16128173
15992229
15969772
15871589
15835036
15782712
15759082
15712768
15686081
15487871
15486152
15446337
15298087
15279858
15266458
15222602
15146228
15139345
19175275
15010569
15010568
14639779
14583953
14498972
12956145
12943139
12889546
12849607
12830105
12629941
12564352
12564350
12564349
12564348
12492014
12484105
12462824
12462823
12454906
12435217
12420534
12408216
12271550
12269776
27719211
12201884
12119624
12119623
12060945
12025798
12007267
11984413
11984412
11898687
11898291
11898191
11873336
11858599
11858598
11858597
11858596
11858595
11858594
11858593
11855800
11855266
11847652
11837015
11808403
11759612
11759611
11697072
11694756
11676732
11586477
11572538
11525790
11517850
11370483
11253583
11253582
11185834
10754826
11153391
11107435
10979163
10979162
10897714
10836918
10786501
10768547
10711214
10690071
10630352
10594605
10550906
10542580
10531869
10520096
10512334
10471017
10418492
10411192
10380448
10377631
10377630
10362943
10347540
10335554
10036457
10023483
9934373
9923328
9923206
9851473
9851472
9851471
9851470
9851469
9851468
9851467
9851466
9851465
9851464
9851463
9851462
9849260
9830942
9823264
9807429
9807324
9793014
9789512
9782829
9773370
9766290
9765761
9737031
9687138
9687125
9682584
9680913
9677929
9661330
9658362
9653377
9594094
9552026
9533499
9515630
9511646
10179936
9464090
9464015
9455277
9386255
9439024
9384072
9380585
27937119
9287618
9439261
9395700
9181407
9165806
9165805
9295408
9061991
9095715
9355334
9349060
9325725
9006250
9004697
9001078
9439288
8883065
8949197
8871984
9362806
8795925
8690446
10158092
8820319
8820318
8807962
8801510
8698982
8552806
9395679
9272070
8920552
8920548
8545679
8535577
8695945
7624536
7624535
7624534
7624532
7624727
7615916
7604857
9456714
7792512
7754099
7754098
7553200
7755027
7706066
7599715
9395605
8582812
7613708
7722274
7995899
7984876
7960846
27527045
8195575
8080307
8012249
7937013
7937002
27669880
8173282
8123527
8263083
8116030
8054647
7997293
7843870
7843869
8228136
8278089
8220197
27922356
8233874
8512301
8240768
8322556
8437138
8502438
8425174
8326484
8070986
1447328
1419661
1620780
1607495
1301421
1738778
1834141
1909161
2061359
1678161
2027687
2401510
2216575
2144043
2164178
2116293
2404259
2359629
2325782
2227986
2100138
2745578
2928592
2466115
2738848
2717098
3172626
3367664
3047227
3312255
3307626
3302959
3650571
3648470
3668791
3642530
3642486
3642485
3642497
3638899
3633503
3634823
10275132
6568834
6397842
6096274
6095989
6566132
6748195
6566551
6366749
6366748
6366641
6322674
6559289
6553423
6949071
6949070
6906014
6992355
6898066
255540
373441
255051
458550
259269
177956
1056435
1039264','{"phrasesignored": [], "quotedphrasesnotfound": [], "outputmessages": ["Restrictions achieved. start and count adjusted to 0, 9999"]} ') ON DUPLICATE KEY UPDATE retrieval_status=VALUES(retrieval_status),result_count=VALUES(result_count),returned_pmids=VALUES(returned_pmids),warnings_text=VALUES(warnings_text);
INSERT INTO ilb_ehr_research_gate VALUES ('THERAPEUTIC_TOUCH','2026-09-30','0','PubMed database query status OK; 575 returned records, including possible name collisions. 562 returned identifiers are outside the earlier cohort and require metadata screening. Earlier cohort: 9 retained/identity candidates still need extraction or resolution. No exhaustive or clinical-validation conclusion is asserted.','Screen expanded query identifiers and resolve aliases/lineages; search registries and regional/non-English databases; appraise remaining full texts and bias; compare independent outcome-specific studies; extract complete procedures where reported. Never infer branch efficacy from parent studies or diagnose using unvalidated energy measurements.') ON DUPLICATE KEY UPDATE summary_text=VALUES(summary_text),next_actions=VALUES(next_actions),research_complete=VALUES(research_complete);
INSERT INTO ilb_ehr_database_search VALUES ('HEALING_TOUCH','("Healing Touch"[Title/Abstract]) AND ("1800/01/01"[Date - Publication] : "2026/09/30"[Date - Publication])','NCBI PubMed ESearch API','2026-09-30','2026-09-30','OK','243','"Healing Touch"[Title/Abstract] AND 1800/01/01:2026/09/30[Date - Publication]','42475613
42060857
42002866
41229089
41136125
40908656
40856898
40495640
40073717
39918364
39899546
39854162
39702917
39442826
39171772
39115285
38905700
38562055
38307816
38307809
38304734
38300148
38159779
37859402
37792581
37342727
37270354
37193512
37165635
36714962
36445978
36166091
35513998
35191790
34577790
34199174
33654502
33545940
33346680
32798173
32404727
32312087
31803691
31780011
31493135
31132779
31076901
30870027
30792957
30670251
30247960
30197027
29535002
29361838
29140485
29113407
28968143
28786890
28760817
28678920
28502231
28497700
28273819
28063869
29668435
26374619
27479023
27749089
27688787
27641608
27578080
27194823
27149995
27004552
26984883
26822561
26665043
26665042
26629667
26571281
26516298
26453532
26331102
26167739
26130464
26098401
25976090
25797686
27981117
25314110
25253110
25181286
24879619
24767262
24722611
24701556
24259404
24175871
24105358
23972540
23835011
23817144
25031994
23431919
23141792
23025129
22713606
22710258
22694864
22662519
22562939
22281310
22278643
22005807
21951738
21864886
21701183
21697661
21624872
21292347
21228402
20920808
20624103
20621272
20600809
20404620
20186018
20009019
19856109
19678772
19642480
19476730
19090556
19087765
18955312
18843720
18616066
18466849
18317289
18051981
17679222
17627198
17573275
17544681
17351022
17179840
17135649
17098874
16781590
16781519
16672812
16599085
16582768
16483898
16294665
16145330
16121148
15992246
15719539
15636404
15630798
15453606
15353017
15298087
15227762
15154151
15101231
14713325
14689396
14639775
12943140
12709165
12510515
12503455
12484718
12046440
12042801
11979292
11898589
11898291
11898191
11890432
11866025
11855527
11847715
11586477
11478564
11436379
11366862
11342408
11243556
10754832
11040557
10833691
10802955
10690027
10687617
10568918
10474340
10401297
10380449
10373832
10234323
10076440
9773370
9313008
9330672
8945180
8715987
8704369
8695974
8700295
7579981
7630817
7630758
7647512
18750996
7626921
7772932
7772929
7719051
7865968
7854695
7949783
7919747
8081083
7795336
8155911
8219622
8409352
8364296
1345418
1515308
1551006
2027687
2494408
3635465
27449580
364668
248276
242525
12992054
14852248','{"phrasesignored": [], "quotedphrasesnotfound": [], "outputmessages": ["Restrictions achieved. start and count adjusted to 0, 9999"]} ') ON DUPLICATE KEY UPDATE retrieval_status=VALUES(retrieval_status),result_count=VALUES(result_count),returned_pmids=VALUES(returned_pmids),warnings_text=VALUES(warnings_text);
INSERT INTO ilb_ehr_research_gate VALUES ('HEALING_TOUCH','2026-09-30','0','PubMed database query status OK; 243 returned records, including possible name collisions. 230 returned identifiers are outside the earlier cohort and require metadata screening. Earlier cohort: 11 retained/identity candidates still need extraction or resolution. No exhaustive or clinical-validation conclusion is asserted.','Screen expanded query identifiers and resolve aliases/lineages; search registries and regional/non-English databases; appraise remaining full texts and bias; compare independent outcome-specific studies; extract complete procedures where reported. Never infer branch efficacy from parent studies or diagnose using unvalidated energy measurements.') ON DUPLICATE KEY UPDATE summary_text=VALUES(summary_text),next_actions=VALUES(next_actions),research_complete=VALUES(research_complete);
INSERT INTO ilb_ehr_database_search VALUES ('QUANTUM_TOUCH','("Quantum Touch"[Title/Abstract] OR "Quantum-Touch"[Title/Abstract]) AND ("1800/01/01"[Date - Publication] : "2026/09/30"[Date - Publication])','NCBI PubMed ESearch API','2026-09-30','2026-09-30','OK','1','("quantum touch"[Title/Abstract] OR "quantum touch"[Title/Abstract]) AND 1800/01/01:2026/09/30[Date - Publication]','40930005','{"phrasesignored": [], "quotedphrasesnotfound": [], "outputmessages": ["Restrictions achieved. start and count adjusted to 0, 9999"]} ') ON DUPLICATE KEY UPDATE retrieval_status=VALUES(retrieval_status),result_count=VALUES(result_count),returned_pmids=VALUES(returned_pmids),warnings_text=VALUES(warnings_text);
INSERT INTO ilb_ehr_research_gate VALUES ('QUANTUM_TOUCH','2026-09-30','0','PubMed database query status OK; 1 returned records, including possible name collisions. 0 returned identifiers are outside the earlier cohort and require metadata screening. Earlier cohort: 0 retained/identity candidates still need extraction or resolution. No exhaustive or clinical-validation conclusion is asserted.','Screen expanded query identifiers and resolve aliases/lineages; search registries and regional/non-English databases; appraise remaining full texts and bias; compare independent outcome-specific studies; extract complete procedures where reported. Never infer branch efficacy from parent studies or diagnose using unvalidated energy measurements.') ON DUPLICATE KEY UPDATE summary_text=VALUES(summary_text),next_actions=VALUES(next_actions),research_complete=VALUES(research_complete);
INSERT INTO ilb_ehr_database_search VALUES ('ACCESS_BARS','("Access Bars"[Title/Abstract]) AND ("1800/01/01"[Date - Publication] : "2026/09/30"[Date - Publication])','NCBI PubMed ESearch API','2026-09-30','2026-09-30','OK','0','("Access Bars"[Title/Abstract]) AND ("1800/01/01"[Date - Publication] : "2026/09/30"[Date - Publication])','','{"phrasesignored": [], "quotedphrasesnotfound": ["\"Access Bars\"[Title/Abstract]"], "outputmessages": ["Restrictions achieved. start and count adjusted to 0, 9999", "No items found."]} ') ON DUPLICATE KEY UPDATE retrieval_status=VALUES(retrieval_status),result_count=VALUES(result_count),returned_pmids=VALUES(returned_pmids),warnings_text=VALUES(warnings_text);
INSERT INTO ilb_ehr_research_gate VALUES ('ACCESS_BARS','2026-09-30','0','PubMed database query status OK; 0 returned records, including possible name collisions. 0 returned identifiers are outside the earlier cohort and require metadata screening. Earlier cohort: 0 retained/identity candidates still need extraction or resolution. No exhaustive or clinical-validation conclusion is asserted.','No records returned by this exact PubMed query. This does not establish no research: verify aliases and publisher reports outside PubMed. Screen expanded query identifiers and resolve aliases/lineages; search registries and regional/non-English databases; appraise remaining full texts and bias; compare independent outcome-specific studies; extract complete procedures where reported. Never infer branch efficacy from parent studies or diagnose using unvalidated energy measurements.') ON DUPLICATE KEY UPDATE summary_text=VALUES(summary_text),next_actions=VALUES(next_actions),research_complete=VALUES(research_complete);
INSERT INTO ilb_ehr_database_search VALUES ('DISTANCE_HEALING','("distant healing"[Title/Abstract] OR "distance healing"[Title/Abstract] OR "remote healing"[Title/Abstract] OR "noncontact healing"[Title/Abstract]) AND ("1800/01/01"[Date - Publication] : "2026/09/30"[Date - Publication])','NCBI PubMed ESearch API','2026-09-30','2026-09-30','OK','65','("distant healing"[Title/Abstract] OR "distance healing"[Title/Abstract] OR "remote healing"[Title/Abstract] OR "noncontact healing"[Title/Abstract]) AND 1800/01/01:2026/09/30[Date - Publication]','42456633
39854162
38563780
37537086
37165635
37023932
35871986
34649428
34199174
32811741
31977236
31492551
30709783
29306936
26743876
26665044
26657031
26200715
25457442
22784339
22742672
22385565
22135451
21985801
21982120
21917562
21767688
19472862
19297799
19245175
18564948
18277062
18251321
17131980
16398588
16296928
14531177
12778776
12776468
12776463
12699715
12119513
22112748
11993014
11898908
11893844
11795611
11795608
11694756
11270063
11255536
11255535
11246935
11240080
11195444
10836918
10784273
10781788
10781776
10726950
9866433
9375432
9375431
8197275
7843870','{"phrasesignored": [], "quotedphrasesnotfound": [], "outputmessages": ["Restrictions achieved. start and count adjusted to 0, 9999"]} ') ON DUPLICATE KEY UPDATE retrieval_status=VALUES(retrieval_status),result_count=VALUES(result_count),returned_pmids=VALUES(returned_pmids),warnings_text=VALUES(warnings_text);
INSERT INTO ilb_ehr_research_gate VALUES ('DISTANCE_HEALING','2026-09-30','0','PubMed database query status OK; 65 returned records, including possible name collisions. 56 returned identifiers are outside the earlier cohort and require metadata screening. Earlier cohort: 4 retained/identity candidates still need extraction or resolution. No exhaustive or clinical-validation conclusion is asserted.','Screen expanded query identifiers and resolve aliases/lineages; search registries and regional/non-English databases; appraise remaining full texts and bias; compare independent outcome-specific studies; extract complete procedures where reported. Never infer branch efficacy from parent studies or diagnose using unvalidated energy measurements.') ON DUPLICATE KEY UPDATE summary_text=VALUES(summary_text),next_actions=VALUES(next_actions),research_complete=VALUES(research_complete);
INSERT INTO ilb_ehr_database_search VALUES ('CHAKRA_AURA','("chakra"[Title/Abstract] OR "aura healing"[Title/Abstract] OR "aura balancing"[Title/Abstract]) AND ("1800/01/01"[Date - Publication] : "2026/09/30"[Date - Publication])','NCBI PubMed ESearch API','2026-09-30','2026-09-30','OK','47','"chakra"[Title/Abstract] AND 1800/01/01:2026/09/30[Date - Publication]','42281140
42228731
41833700
41015812
40708797
39959512
39702917
39639605
39405793
39033882
37416675
37119541
36710104
35800975
35191790
34901438
34816263
34123883
33056083
31523257
30867236
30834177
30671155
32952783
30147818
29916575
28629809
28483188
29861585
27768332
27186202
27164469
24989743
24489583
23323597
18324479
18096986
15915291
15871593
11246939
9142560
9449057
22556648
22556608
22556605
256325
254477','{"phrasesignored": [], "quotedphrasesnotfound": ["\"aura healing\"[Title/Abstract]", "\"aura balancing\"[Title/Abstract]"], "outputmessages": ["Restrictions achieved. start and count adjusted to 0, 9999"]} ') ON DUPLICATE KEY UPDATE retrieval_status=VALUES(retrieval_status),result_count=VALUES(result_count),returned_pmids=VALUES(returned_pmids),warnings_text=VALUES(warnings_text);
INSERT INTO ilb_ehr_research_gate VALUES ('CHAKRA_AURA','2026-09-30','0','PubMed database query status OK; 47 returned records, including possible name collisions. 41 returned identifiers are outside the earlier cohort and require metadata screening. Earlier cohort: 6 retained/identity candidates still need extraction or resolution. No exhaustive or clinical-validation conclusion is asserted.','Screen expanded query identifiers and resolve aliases/lineages; search registries and regional/non-English databases; appraise remaining full texts and bias; compare independent outcome-specific studies; extract complete procedures where reported. Never infer branch efficacy from parent studies or diagnose using unvalidated energy measurements.') ON DUPLICATE KEY UPDATE summary_text=VALUES(summary_text),next_actions=VALUES(next_actions),research_complete=VALUES(research_complete);
INSERT INTO ilb_ehr_database_search VALUES ('CRYSTAL_ENERGY','("crystal healing"[Title/Abstract] OR "pranic crystal healing"[Title/Abstract]) AND ("1800/01/01"[Date - Publication] : "2026/09/30"[Date - Publication])','NCBI PubMed ESearch API','2026-09-30','2026-09-30','OK','2','"crystal healing"[Title/Abstract] AND 1800/01/01:2026/09/30[Date - Publication]','17956966
15491893','{"phrasesignored": [], "quotedphrasesnotfound": ["\"pranic crystal healing\"[Title/Abstract]"], "outputmessages": ["Restrictions achieved. start and count adjusted to 0, 9999"]} ') ON DUPLICATE KEY UPDATE retrieval_status=VALUES(retrieval_status),result_count=VALUES(result_count),returned_pmids=VALUES(returned_pmids),warnings_text=VALUES(warnings_text);
INSERT INTO ilb_ehr_research_gate VALUES ('CRYSTAL_ENERGY','2026-09-30','0','PubMed database query status OK; 2 returned records, including possible name collisions. 0 returned identifiers are outside the earlier cohort and require metadata screening. Earlier cohort: 0 retained/identity candidates still need extraction or resolution. No exhaustive or clinical-validation conclusion is asserted.','Screen expanded query identifiers and resolve aliases/lineages; search registries and regional/non-English databases; appraise remaining full texts and bias; compare independent outcome-specific studies; extract complete procedures where reported. Never infer branch efficacy from parent studies or diagnose using unvalidated energy measurements.') ON DUPLICATE KEY UPDATE summary_text=VALUES(summary_text),next_actions=VALUES(next_actions),research_complete=VALUES(research_complete);
INSERT INTO ilb_ehr_database_search VALUES ('RECONNECTIVE_HEALING','("Reconnective Healing"[Title/Abstract]) AND ("1800/01/01"[Date - Publication] : "2026/09/30"[Date - Publication])','NCBI PubMed ESearch API','2026-09-30','2026-09-30','OK','3','"Reconnective Healing"[Title/Abstract] AND 1800/01/01:2026/09/30[Date - Publication]','28654301
24767262
24327820','{"phrasesignored": [], "quotedphrasesnotfound": [], "outputmessages": ["Restrictions achieved. start and count adjusted to 0, 9999"]} ') ON DUPLICATE KEY UPDATE retrieval_status=VALUES(retrieval_status),result_count=VALUES(result_count),returned_pmids=VALUES(returned_pmids),warnings_text=VALUES(warnings_text);
INSERT INTO ilb_ehr_research_gate VALUES ('RECONNECTIVE_HEALING','2026-09-30','0','PubMed database query status OK; 3 returned records, including possible name collisions. 0 returned identifiers are outside the earlier cohort and require metadata screening. Earlier cohort: 1 retained/identity candidates still need extraction or resolution. No exhaustive or clinical-validation conclusion is asserted.','Screen expanded query identifiers and resolve aliases/lineages; search registries and regional/non-English databases; appraise remaining full texts and bias; compare independent outcome-specific studies; extract complete procedures where reported. Never infer branch efficacy from parent studies or diagnose using unvalidated energy measurements.') ON DUPLICATE KEY UPDATE summary_text=VALUES(summary_text),next_actions=VALUES(next_actions),research_complete=VALUES(research_complete);
INSERT INTO ilb_ehr_database_search VALUES ('THE_RECONNECTION','("the reconnection"[Title/Abstract]) AND ("1800/01/01"[Date - Publication] : "2026/09/30"[Date - Publication])','NCBI PubMed ESearch API','2026-09-30','2026-09-30','OK','0','("the reconnection"[Title/Abstract]) AND ("1800/01/01"[Date - Publication] : "2026/09/30"[Date - Publication])','','{"phrasesignored": [], "quotedphrasesnotfound": ["\"the reconnection\"[Title/Abstract]"], "outputmessages": ["Restrictions achieved. start and count adjusted to 0, 9999", "No items found."]} ') ON DUPLICATE KEY UPDATE retrieval_status=VALUES(retrieval_status),result_count=VALUES(result_count),returned_pmids=VALUES(returned_pmids),warnings_text=VALUES(warnings_text);
INSERT INTO ilb_ehr_research_gate VALUES ('THE_RECONNECTION','2026-09-30','0','PubMed database query status OK; 0 returned records, including possible name collisions. 0 returned identifiers are outside the earlier cohort and require metadata screening. Earlier cohort: 0 retained/identity candidates still need extraction or resolution. No exhaustive or clinical-validation conclusion is asserted.','No records returned by this exact PubMed query. This does not establish no research: verify aliases and publisher reports outside PubMed. Screen expanded query identifiers and resolve aliases/lineages; search registries and regional/non-English databases; appraise remaining full texts and bias; compare independent outcome-specific studies; extract complete procedures where reported. Never infer branch efficacy from parent studies or diagnose using unvalidated energy measurements.') ON DUPLICATE KEY UPDATE summary_text=VALUES(summary_text),next_actions=VALUES(next_actions),research_complete=VALUES(research_complete);
INSERT INTO ilb_ehr_database_search VALUES ('THETAHEALING','("ThetaHealing"[Title/Abstract]) AND ("1800/01/01"[Date - Publication] : "2026/09/30"[Date - Publication])','NCBI PubMed ESearch API','2026-09-30','2026-09-30','OK','1','"ThetaHealing"[Title/Abstract] AND 1800/01/01:2026/09/30[Date - Publication]','26588598','{"phrasesignored": [], "quotedphrasesnotfound": [], "outputmessages": ["Restrictions achieved. start and count adjusted to 0, 9999"]} ') ON DUPLICATE KEY UPDATE retrieval_status=VALUES(retrieval_status),result_count=VALUES(result_count),returned_pmids=VALUES(returned_pmids),warnings_text=VALUES(warnings_text);
INSERT INTO ilb_ehr_research_gate VALUES ('THETAHEALING','2026-09-30','0','PubMed database query status OK; 1 returned records, including possible name collisions. 0 returned identifiers are outside the earlier cohort and require metadata screening. Earlier cohort: 0 retained/identity candidates still need extraction or resolution. No exhaustive or clinical-validation conclusion is asserted.','Screen expanded query identifiers and resolve aliases/lineages; search registries and regional/non-English databases; appraise remaining full texts and bias; compare independent outcome-specific studies; extract complete procedures where reported. Never infer branch efficacy from parent studies or diagnose using unvalidated energy measurements.') ON DUPLICATE KEY UPDATE summary_text=VALUES(summary_text),next_actions=VALUES(next_actions),research_complete=VALUES(research_complete);
INSERT INTO ilb_ehr_database_search VALUES ('EDEN_ENERGY_MEDICINE','("Eden Energy Medicine"[Title/Abstract]) AND ("1800/01/01"[Date - Publication] : "2026/09/30"[Date - Publication])','NCBI PubMed ESearch API','2026-09-30','2026-09-30','OK','1','"Eden Energy Medicine"[Title/Abstract] AND 1800/01/01:2026/09/30[Date - Publication]','32931459','{"phrasesignored": [], "quotedphrasesnotfound": [], "outputmessages": ["Restrictions achieved. start and count adjusted to 0, 9999"]} ') ON DUPLICATE KEY UPDATE retrieval_status=VALUES(retrieval_status),result_count=VALUES(result_count),returned_pmids=VALUES(returned_pmids),warnings_text=VALUES(warnings_text);
INSERT INTO ilb_ehr_research_gate VALUES ('EDEN_ENERGY_MEDICINE','2026-09-30','0','PubMed database query status OK; 1 returned records, including possible name collisions. 0 returned identifiers are outside the earlier cohort and require metadata screening. Earlier cohort: 1 retained/identity candidates still need extraction or resolution. No exhaustive or clinical-validation conclusion is asserted.','Screen expanded query identifiers and resolve aliases/lineages; search registries and regional/non-English databases; appraise remaining full texts and bias; compare independent outcome-specific studies; extract complete procedures where reported. Never infer branch efficacy from parent studies or diagnose using unvalidated energy measurements.') ON DUPLICATE KEY UPDATE summary_text=VALUES(summary_text),next_actions=VALUES(next_actions),research_complete=VALUES(research_complete);
INSERT INTO ilb_ehr_database_search VALUES ('BENGSTON_METHOD','("Bengston"[Title/Abstract]) AND ("1800/01/01"[Date - Publication] : "2026/09/30"[Date - Publication])','NCBI PubMed ESearch API','2026-09-30','2026-09-30','OK','9','"Bengston"[Title/Abstract] AND 1800/01/01:2026/09/30[Date - Publication]','37325440
35784417
32284695
30022894
29083972
28650246
26344558
24944959
4879041','{"phrasesignored": [], "quotedphrasesnotfound": [], "outputmessages": ["Restrictions achieved. start and count adjusted to 0, 9999"]} ') ON DUPLICATE KEY UPDATE retrieval_status=VALUES(retrieval_status),result_count=VALUES(result_count),returned_pmids=VALUES(returned_pmids),warnings_text=VALUES(warnings_text);
INSERT INTO ilb_ehr_research_gate VALUES ('BENGSTON_METHOD','2026-09-30','0','PubMed database query status OK; 9 returned records, including possible name collisions. 7 returned identifiers are outside the earlier cohort and require metadata screening. Earlier cohort: 1 retained/identity candidates still need extraction or resolution. No exhaustive or clinical-validation conclusion is asserted.','Screen expanded query identifiers and resolve aliases/lineages; search registries and regional/non-English databases; appraise remaining full texts and bias; compare independent outcome-specific studies; extract complete procedures where reported. Never infer branch efficacy from parent studies or diagnose using unvalidated energy measurements.') ON DUPLICATE KEY UPDATE summary_text=VALUES(summary_text),next_actions=VALUES(next_actions),research_complete=VALUES(research_complete);
INSERT INTO ilb_ehr_database_search VALUES ('BRENNAN_HEALING','("Brennan Healing"[Title/Abstract] OR "Brennan Healing Science"[Title/Abstract]) AND ("1800/01/01"[Date - Publication] : "2026/09/30"[Date - Publication])','NCBI PubMed ESearch API','2026-09-30','2026-09-30','OK','2','("Brennan Healing"[Title/Abstract] OR "Brennan Healing Science"[Title/Abstract]) AND 1800/01/01:2026/09/30[Date - Publication]','33683643
24439097','{"phrasesignored": [], "quotedphrasesnotfound": [], "outputmessages": ["Restrictions achieved. start and count adjusted to 0, 9999"]} ') ON DUPLICATE KEY UPDATE retrieval_status=VALUES(retrieval_status),result_count=VALUES(result_count),returned_pmids=VALUES(returned_pmids),warnings_text=VALUES(warnings_text);
INSERT INTO ilb_ehr_research_gate VALUES ('BRENNAN_HEALING','2026-09-30','0','PubMed database query status OK; 2 returned records, including possible name collisions. 0 returned identifiers are outside the earlier cohort and require metadata screening. Earlier cohort: 1 retained/identity candidates still need extraction or resolution. No exhaustive or clinical-validation conclusion is asserted.','Screen expanded query identifiers and resolve aliases/lineages; search registries and regional/non-English databases; appraise remaining full texts and bias; compare independent outcome-specific studies; extract complete procedures where reported. Never infer branch efficacy from parent studies or diagnose using unvalidated energy measurements.') ON DUPLICATE KEY UPDATE summary_text=VALUES(summary_text),next_actions=VALUES(next_actions),research_complete=VALUES(research_complete);
INSERT INTO ilb_ehr_database_search VALUES ('POLARITY_THERAPY','("Polarity Therapy"[Title/Abstract]) AND ("1800/01/01"[Date - Publication] : "2026/09/30"[Date - Publication])','NCBI PubMed ESearch API','2026-09-30','2026-09-30','OK','12','"Polarity Therapy"[Title/Abstract] AND 1800/01/01:2026/09/30[Date - Publication]','36166091
31210499
26665042
24435941
23651041
21382958
19377083
17573275
17351022
15695472
15127775
10394674','{"phrasesignored": [], "quotedphrasesnotfound": [], "outputmessages": ["Restrictions achieved. start and count adjusted to 0, 9999"]} ') ON DUPLICATE KEY UPDATE retrieval_status=VALUES(retrieval_status),result_count=VALUES(result_count),returned_pmids=VALUES(returned_pmids),warnings_text=VALUES(warnings_text);
INSERT INTO ilb_ehr_research_gate VALUES ('POLARITY_THERAPY','2026-09-30','0','PubMed database query status OK; 12 returned records, including possible name collisions. 2 returned identifiers are outside the earlier cohort and require metadata screening. Earlier cohort: 4 retained/identity candidates still need extraction or resolution. No exhaustive or clinical-validation conclusion is asserted.','Screen expanded query identifiers and resolve aliases/lineages; search registries and regional/non-English databases; appraise remaining full texts and bias; compare independent outcome-specific studies; extract complete procedures where reported. Never infer branch efficacy from parent studies or diagnose using unvalidated energy measurements.') ON DUPLICATE KEY UPDATE summary_text=VALUES(summary_text),next_actions=VALUES(next_actions),research_complete=VALUES(research_complete);
INSERT INTO ilb_ehr_database_search VALUES ('JIN_SHIN_JYUTSU','("Jin Shin Jyutsu"[Title/Abstract]) AND ("1800/01/01"[Date - Publication] : "2026/09/30"[Date - Publication])','NCBI PubMed ESearch API','2026-09-30','2026-09-30','OK','7','"Jin Shin Jyutsu"[Title/Abstract] AND 1800/01/01:2026/09/30[Date - Publication]','42709485
34149467
33412954
32649851
24771664
21825093
12233795','{"phrasesignored": [], "quotedphrasesnotfound": [], "outputmessages": ["Restrictions achieved. start and count adjusted to 0, 9999"]} ') ON DUPLICATE KEY UPDATE retrieval_status=VALUES(retrieval_status),result_count=VALUES(result_count),returned_pmids=VALUES(returned_pmids),warnings_text=VALUES(warnings_text);
INSERT INTO ilb_ehr_research_gate VALUES ('JIN_SHIN_JYUTSU','2026-09-30','0','PubMed database query status OK; 7 returned records, including possible name collisions. 0 returned identifiers are outside the earlier cohort and require metadata screening. Earlier cohort: 6 retained/identity candidates still need extraction or resolution. No exhaustive or clinical-validation conclusion is asserted.','Screen expanded query identifiers and resolve aliases/lineages; search registries and regional/non-English databases; appraise remaining full texts and bias; compare independent outcome-specific studies; extract complete procedures where reported. Never infer branch efficacy from parent studies or diagnose using unvalidated energy measurements.') ON DUPLICATE KEY UPDATE summary_text=VALUES(summary_text),next_actions=VALUES(next_actions),research_complete=VALUES(research_complete);
INSERT INTO ilb_ehr_database_search VALUES ('JOHREI','("Johrei"[Title/Abstract]) AND ("1800/01/01"[Date - Publication] : "2026/09/30"[Date - Publication])','NCBI PubMed ESearch API','2026-09-30','2026-09-30','OK','22','"Johrei"[Title/Abstract] AND 1800/01/01:2026/09/30[Date - Publication]','34969609
32811741
28654301
26665042
26520228
25457442
25181286
24280471
23452712
22924412
22385046
22385045
20832764
19606689
18945261
17549235
17173118
16970532
16765851
15992229
15667653
14698357','{"phrasesignored": [], "quotedphrasesnotfound": [], "outputmessages": ["Restrictions achieved. start and count adjusted to 0, 9999"]} ') ON DUPLICATE KEY UPDATE retrieval_status=VALUES(retrieval_status),result_count=VALUES(result_count),returned_pmids=VALUES(returned_pmids),warnings_text=VALUES(warnings_text);
INSERT INTO ilb_ehr_research_gate VALUES ('JOHREI','2026-09-30','0','PubMed database query status OK; 22 returned records, including possible name collisions. 10 returned identifiers are outside the earlier cohort and require metadata screening. Earlier cohort: 11 retained/identity candidates still need extraction or resolution. No exhaustive or clinical-validation conclusion is asserted.','Screen expanded query identifiers and resolve aliases/lineages; search registries and regional/non-English databases; appraise remaining full texts and bias; compare independent outcome-specific studies; extract complete procedures where reported. Never infer branch efficacy from parent studies or diagnose using unvalidated energy measurements.') ON DUPLICATE KEY UPDATE summary_text=VALUES(summary_text),next_actions=VALUES(next_actions),research_complete=VALUES(research_complete);
INSERT INTO ilb_ehr_database_search VALUES ('MAHIKARI','("Mahikari"[Title/Abstract]) AND ("1800/01/01"[Date - Publication] : "2026/09/30"[Date - Publication])','NCBI PubMed ESearch API','2026-09-30','2026-09-30','OK','0','("Mahikari"[Title/Abstract]) AND ("1800/01/01"[Date - Publication] : "2026/09/30"[Date - Publication])','','{"phrasesignored": [], "quotedphrasesnotfound": ["\"Mahikari\"[Title/Abstract]"], "outputmessages": ["Restrictions achieved. start and count adjusted to 0, 9999", "No items found."]} ') ON DUPLICATE KEY UPDATE retrieval_status=VALUES(retrieval_status),result_count=VALUES(result_count),returned_pmids=VALUES(returned_pmids),warnings_text=VALUES(warnings_text);
INSERT INTO ilb_ehr_research_gate VALUES ('MAHIKARI','2026-09-30','0','PubMed database query status OK; 0 returned records, including possible name collisions. 0 returned identifiers are outside the earlier cohort and require metadata screening. Earlier cohort: 0 retained/identity candidates still need extraction or resolution. No exhaustive or clinical-validation conclusion is asserted.','No records returned by this exact PubMed query. This does not establish no research: verify aliases and publisher reports outside PubMed. Screen expanded query identifiers and resolve aliases/lineages; search registries and regional/non-English databases; appraise remaining full texts and bias; compare independent outcome-specific studies; extract complete procedures where reported. Never infer branch efficacy from parent studies or diagnose using unvalidated energy measurements.') ON DUPLICATE KEY UPDATE summary_text=VALUES(summary_text),next_actions=VALUES(next_actions),research_complete=VALUES(research_complete);
INSERT INTO ilb_ehr_database_search VALUES ('VORTEX_HEALING','("VortexHealing"[Title/Abstract] OR "Vortex Healing"[Title/Abstract]) AND ("1800/01/01"[Date - Publication] : "2026/09/30"[Date - Publication])','NCBI PubMed ESearch API','2026-09-30','2026-09-30','OK','0','("VortexHealing"[Title/Abstract] OR "Vortex Healing"[Title/Abstract]) AND ("1800/01/01"[Date - Publication] : "2026/09/30"[Date - Publication])','','{"phrasesignored": [], "quotedphrasesnotfound": ["\"VortexHealing\"[Title/Abstract]", "\"Vortex Healing\"[Title/Abstract]"], "outputmessages": ["Restrictions achieved. start and count adjusted to 0, 9999", "No items found."]} ') ON DUPLICATE KEY UPDATE retrieval_status=VALUES(retrieval_status),result_count=VALUES(result_count),returned_pmids=VALUES(returned_pmids),warnings_text=VALUES(warnings_text);
INSERT INTO ilb_ehr_research_gate VALUES ('VORTEX_HEALING','2026-09-30','0','PubMed database query status OK; 0 returned records, including possible name collisions. 0 returned identifiers are outside the earlier cohort and require metadata screening. Earlier cohort: 0 retained/identity candidates still need extraction or resolution. No exhaustive or clinical-validation conclusion is asserted.','No records returned by this exact PubMed query. This does not establish no research: verify aliases and publisher reports outside PubMed. Screen expanded query identifiers and resolve aliases/lineages; search registries and regional/non-English databases; appraise remaining full texts and bias; compare independent outcome-specific studies; extract complete procedures where reported. Never infer branch efficacy from parent studies or diagnose using unvalidated energy measurements.') ON DUPLICATE KEY UPDATE summary_text=VALUES(summary_text),next_actions=VALUES(next_actions),research_complete=VALUES(research_complete);
INSERT INTO ilb_ehr_database_search VALUES ('INTEGRATED_ENERGY_THERAPY','("Integrated Energy Therapy"[Title/Abstract]) AND ("1800/01/01"[Date - Publication] : "2026/09/30"[Date - Publication])','NCBI PubMed ESearch API','2026-09-30','2026-09-30','OK','0','("Integrated Energy Therapy"[Title/Abstract]) AND ("1800/01/01"[Date - Publication] : "2026/09/30"[Date - Publication])','','{"phrasesignored": [], "quotedphrasesnotfound": ["\"Integrated Energy Therapy\"[Title/Abstract]"], "outputmessages": ["Restrictions achieved. start and count adjusted to 0, 9999", "No items found."]} ') ON DUPLICATE KEY UPDATE retrieval_status=VALUES(retrieval_status),result_count=VALUES(result_count),returned_pmids=VALUES(returned_pmids),warnings_text=VALUES(warnings_text);
INSERT INTO ilb_ehr_research_gate VALUES ('INTEGRATED_ENERGY_THERAPY','2026-09-30','0','PubMed database query status OK; 0 returned records, including possible name collisions. 0 returned identifiers are outside the earlier cohort and require metadata screening. Earlier cohort: 0 retained/identity candidates still need extraction or resolution. No exhaustive or clinical-validation conclusion is asserted.','No records returned by this exact PubMed query. This does not establish no research: verify aliases and publisher reports outside PubMed. Screen expanded query identifiers and resolve aliases/lineages; search registries and regional/non-English databases; appraise remaining full texts and bias; compare independent outcome-specific studies; extract complete procedures where reported. Never infer branch efficacy from parent studies or diagnose using unvalidated energy measurements.') ON DUPLICATE KEY UPDATE summary_text=VALUES(summary_text),next_actions=VALUES(next_actions),research_complete=VALUES(research_complete);
INSERT INTO ilb_ehr_database_search VALUES ('RAHANNI','("Rahanni Celestial Healing"[Title/Abstract]) AND ("1800/01/01"[Date - Publication] : "2026/09/30"[Date - Publication])','NCBI PubMed ESearch API','2026-09-30','2026-09-30','OK','0','("Rahanni Celestial Healing"[Title/Abstract]) AND ("1800/01/01"[Date - Publication] : "2026/09/30"[Date - Publication])','','{"phrasesignored": [], "quotedphrasesnotfound": ["\"Rahanni Celestial Healing\"[Title/Abstract]"], "outputmessages": ["Restrictions achieved. start and count adjusted to 0, 9999", "No items found."]} ') ON DUPLICATE KEY UPDATE retrieval_status=VALUES(retrieval_status),result_count=VALUES(result_count),returned_pmids=VALUES(returned_pmids),warnings_text=VALUES(warnings_text);
INSERT INTO ilb_ehr_research_gate VALUES ('RAHANNI','2026-09-30','0','PubMed database query status OK; 0 returned records, including possible name collisions. 0 returned identifiers are outside the earlier cohort and require metadata screening. Earlier cohort: 0 retained/identity candidates still need extraction or resolution. No exhaustive or clinical-validation conclusion is asserted.','No records returned by this exact PubMed query. This does not establish no research: verify aliases and publisher reports outside PubMed. Screen expanded query identifiers and resolve aliases/lineages; search registries and regional/non-English databases; appraise remaining full texts and bias; compare independent outcome-specific studies; extract complete procedures where reported. Never infer branch efficacy from parent studies or diagnose using unvalidated energy measurements.') ON DUPLICATE KEY UPDATE summary_text=VALUES(summary_text),next_actions=VALUES(next_actions),research_complete=VALUES(research_complete);
INSERT INTO ilb_ehr_database_search VALUES ('BIOFIELD_TUNING','("Biofield Tuning"[Title/Abstract]) AND ("1800/01/01"[Date - Publication] : "2026/09/30"[Date - Publication])','NCBI PubMed ESearch API','2026-09-30','2026-09-30','OK','3','"Biofield Tuning"[Title/Abstract] AND 1800/01/01:2026/09/30[Date - Publication]','37537086
37023932
32721212','{"phrasesignored": [], "quotedphrasesnotfound": [], "outputmessages": ["Restrictions achieved. start and count adjusted to 0, 9999"]} ') ON DUPLICATE KEY UPDATE retrieval_status=VALUES(retrieval_status),result_count=VALUES(result_count),returned_pmids=VALUES(returned_pmids),warnings_text=VALUES(warnings_text);
INSERT INTO ilb_ehr_research_gate VALUES ('BIOFIELD_TUNING','2026-09-30','0','PubMed database query status OK; 3 returned records, including possible name collisions. 0 returned identifiers are outside the earlier cohort and require metadata screening. Earlier cohort: 0 retained/identity candidates still need extraction or resolution. No exhaustive or clinical-validation conclusion is asserted.','Screen expanded query identifiers and resolve aliases/lineages; search registries and regional/non-English databases; appraise remaining full texts and bias; compare independent outcome-specific studies; extract complete procedures where reported. Never infer branch efficacy from parent studies or diagnose using unvalidated energy measurements.') ON DUPLICATE KEY UPDATE summary_text=VALUES(summary_text),next_actions=VALUES(next_actions),research_complete=VALUES(research_complete);
INSERT INTO ilb_ehr_database_search VALUES ('BIOGEOMETRY','("BioGeometry"[Title/Abstract]) AND ("1800/01/01"[Date - Publication] : "2026/09/30"[Date - Publication])','NCBI PubMed ESearch API','2026-09-30','2026-09-30','OK','10','"BioGeometry"[Title/Abstract] AND 1800/01/01:2026/09/30[Date - Publication]','39678747
39224415
36683892
36514421
32884193
32637529
28713718
22714237
15759608
4017433','{"phrasesignored": [], "quotedphrasesnotfound": [], "outputmessages": ["Restrictions achieved. start and count adjusted to 0, 9999"]} ') ON DUPLICATE KEY UPDATE retrieval_status=VALUES(retrieval_status),result_count=VALUES(result_count),returned_pmids=VALUES(returned_pmids),warnings_text=VALUES(warnings_text);
INSERT INTO ilb_ehr_research_gate VALUES ('BIOGEOMETRY','2026-09-30','0','PubMed database query status OK; 10 returned records, including possible name collisions. 4 returned identifiers are outside the earlier cohort and require metadata screening. Earlier cohort: 0 retained/identity candidates still need extraction or resolution. No exhaustive or clinical-validation conclusion is asserted.','Screen expanded query identifiers and resolve aliases/lineages; search registries and regional/non-English databases; appraise remaining full texts and bias; compare independent outcome-specific studies; extract complete procedures where reported. Never infer branch efficacy from parent studies or diagnose using unvalidated energy measurements.') ON DUPLICATE KEY UPDATE summary_text=VALUES(summary_text),next_actions=VALUES(next_actions),research_complete=VALUES(research_complete);
INSERT INTO ilb_ehr_database_search VALUES ('HEARTFULNESS','("Heartfulness"[Title/Abstract]) AND ("1800/01/01"[Date - Publication] : "2026/09/30"[Date - Publication])','NCBI PubMed ESearch API','2026-09-30','2026-09-30','OK','55','"Heartfulness"[Title/Abstract] AND 1800/01/01:2026/09/30[Date - Publication]','42724159
42555361
42328361
42131538
41907996
41574102
41305815
41180129
41018239
40949718
40271908
40152697
39960276
39877285
39742029
39680432
39331608
39047180
39044890
38974327
38948578
38848338
38713142
38577121
38204769
38025468
37797350
37342644
36981851
36949840
36949832
36938168
36891912
38466050
36505903
36458088
36317026
36065401
35619781
35470800
35384302
34769634
34733054
34721219
34097862
33774892
33682592
33455902
33096504
32128052
31239023
31139634
30733893
30595318
28634520','{"phrasesignored": [], "quotedphrasesnotfound": [], "outputmessages": ["Restrictions achieved. start and count adjusted to 0, 9999"]} ') ON DUPLICATE KEY UPDATE retrieval_status=VALUES(retrieval_status),result_count=VALUES(result_count),returned_pmids=VALUES(returned_pmids),warnings_text=VALUES(warnings_text);
INSERT INTO ilb_ehr_research_gate VALUES ('HEARTFULNESS','2026-09-30','0','PubMed database query status OK; 55 returned records, including possible name collisions. 44 returned identifiers are outside the earlier cohort and require metadata screening. Earlier cohort: 10 retained/identity candidates still need extraction or resolution. No exhaustive or clinical-validation conclusion is asserted.','Screen expanded query identifiers and resolve aliases/lineages; search registries and regional/non-English databases; appraise remaining full texts and bias; compare independent outcome-specific studies; extract complete procedures where reported. Never infer branch efficacy from parent studies or diagnose using unvalidated energy measurements.') ON DUPLICATE KEY UPDATE summary_text=VALUES(summary_text),next_actions=VALUES(next_actions),research_complete=VALUES(research_complete);
INSERT INTO ilb_ehr_database_search VALUES ('SAT_NAM_RASAYAN','("Sat Nam Rasayan"[Title/Abstract]) AND ("1800/01/01"[Date - Publication] : "2026/09/30"[Date - Publication])','NCBI PubMed ESearch API','2026-09-30','2026-09-30','OK','0','("Sat Nam Rasayan"[Title/Abstract]) AND ("1800/01/01"[Date - Publication] : "2026/09/30"[Date - Publication])','','{"phrasesignored": [], "quotedphrasesnotfound": ["\"Sat Nam Rasayan\"[Title/Abstract]"], "outputmessages": ["Restrictions achieved. start and count adjusted to 0, 9999", "No items found."]} ') ON DUPLICATE KEY UPDATE retrieval_status=VALUES(retrieval_status),result_count=VALUES(result_count),returned_pmids=VALUES(returned_pmids),warnings_text=VALUES(warnings_text);
INSERT INTO ilb_ehr_research_gate VALUES ('SAT_NAM_RASAYAN','2026-09-30','0','PubMed database query status OK; 0 returned records, including possible name collisions. 0 returned identifiers are outside the earlier cohort and require metadata screening. Earlier cohort: 0 retained/identity candidates still need extraction or resolution. No exhaustive or clinical-validation conclusion is asserted.','No records returned by this exact PubMed query. This does not establish no research: verify aliases and publisher reports outside PubMed. Screen expanded query identifiers and resolve aliases/lineages; search registries and regional/non-English databases; appraise remaining full texts and bias; compare independent outcome-specific studies; extract complete procedures where reported. Never infer branch efficacy from parent studies or diagnose using unvalidated energy measurements.') ON DUPLICATE KEY UPDATE summary_text=VALUES(summary_text),next_actions=VALUES(next_actions),research_complete=VALUES(research_complete);
INSERT INTO ilb_ehr_database_search VALUES ('HOOPONOPONO','("hooponopono"[Title/Abstract] OR "ho''oponopono"[Title/Abstract]) AND ("1800/01/01"[Date - Publication] : "2026/09/30"[Date - Publication])','NCBI PubMed ESearch API','2026-09-30','2026-09-30','OK','0','("hooponopono"[Title/Abstract] OR "ho''oponopono"[Title/Abstract]) AND ("1800/01/01"[Date - Publication] : "2026/09/30"[Date - Publication])','','{} ') ON DUPLICATE KEY UPDATE retrieval_status=VALUES(retrieval_status),result_count=VALUES(result_count),returned_pmids=VALUES(returned_pmids),warnings_text=VALUES(warnings_text);
INSERT INTO ilb_ehr_research_gate VALUES ('HOOPONOPONO','2026-09-30','0','PubMed database query status OK; 0 returned records, including possible name collisions. 0 returned identifiers are outside the earlier cohort and require metadata screening. Earlier cohort: 0 retained/identity candidates still need extraction or resolution. No exhaustive or clinical-validation conclusion is asserted.','No records returned by this exact PubMed query. This does not establish no research: verify aliases and publisher reports outside PubMed. Screen expanded query identifiers and resolve aliases/lineages; search registries and regional/non-English databases; appraise remaining full texts and bias; compare independent outcome-specific studies; extract complete procedures where reported. Never infer branch efficacy from parent studies or diagnose using unvalidated energy measurements.') ON DUPLICATE KEY UPDATE summary_text=VALUES(summary_text),next_actions=VALUES(next_actions),research_complete=VALUES(research_complete);
INSERT INTO ilb_ehr_database_search VALUES ('SOUND_HEALING','("Sound healing"[Title/Abstract]) AND ("1800/01/01"[Date - Publication] : "2026/09/30"[Date - Publication])','NCBI PubMed ESearch API','2026-09-30','2026-09-30','OK','38','"Sound healing"[Title/Abstract] AND 1800/01/01:2026/09/30[Date - Publication]','41616681
39905265
39144513
39046336
38498783
37537086
37023932
36943587
35939040
33488307
32050311
31632840
30705557
30066557
27299120
25580302
23960304
23519714
21857444
21035991
20733345
20679749
20179472
19464974
18509480
16056053
15762835
12141244
10788773
28790589
9526209
8245084
1718202
3219526
3764624
3100895
3883865
6861063','{} ') ON DUPLICATE KEY UPDATE retrieval_status=VALUES(retrieval_status),result_count=VALUES(result_count),returned_pmids=VALUES(returned_pmids),warnings_text=VALUES(warnings_text);
INSERT INTO ilb_ehr_research_gate VALUES ('SOUND_HEALING','2026-09-30','0','PubMed database query status OK; 38 returned records, including possible name collisions. 26 returned identifiers are outside the earlier cohort and require metadata screening. Earlier cohort: 2 retained/identity candidates still need extraction or resolution. No exhaustive or clinical-validation conclusion is asserted.','Screen expanded query identifiers and resolve aliases/lineages; search registries and regional/non-English databases; appraise remaining full texts and bias; compare independent outcome-specific studies; extract complete procedures where reported. Never infer branch efficacy from parent studies or diagnose using unvalidated energy measurements.') ON DUPLICATE KEY UPDATE summary_text=VALUES(summary_text),next_actions=VALUES(next_actions),research_complete=VALUES(research_complete);
INSERT INTO ilb_ehr_database_search VALUES ('AGNIHOTRA','("Agnihotra"[Title/Abstract] OR "Homa therapy"[Title/Abstract]) AND ("1800/01/01"[Date - Publication] : "2026/09/30"[Date - Publication])','NCBI PubMed ESearch API','2026-09-30','2026-09-30','OK','4','("Agnihotra"[Title/Abstract] OR "Homa therapy"[Title/Abstract]) AND 1800/01/01:2026/09/30[Date - Publication]','42140041
28483188
21897457
21927247','{"phrasesignored": [], "quotedphrasesnotfound": [], "outputmessages": ["Restrictions achieved. start and count adjusted to 0, 9999"]} ') ON DUPLICATE KEY UPDATE retrieval_status=VALUES(retrieval_status),result_count=VALUES(result_count),returned_pmids=VALUES(returned_pmids),warnings_text=VALUES(warnings_text);
INSERT INTO ilb_ehr_research_gate VALUES ('AGNIHOTRA','2026-09-30','0','PubMed database query status OK; 4 returned records, including possible name collisions. 3 returned identifiers are outside the earlier cohort and require metadata screening. Earlier cohort: 1 retained/identity candidates still need extraction or resolution. No exhaustive or clinical-validation conclusion is asserted.','Screen expanded query identifiers and resolve aliases/lineages; search registries and regional/non-English databases; appraise remaining full texts and bias; compare independent outcome-specific studies; extract complete procedures where reported. Never infer branch efficacy from parent studies or diagnose using unvalidated energy measurements.') ON DUPLICATE KEY UPDATE summary_text=VALUES(summary_text),next_actions=VALUES(next_actions),research_complete=VALUES(research_complete);
INSERT INTO ilb_ehr_database_search VALUES ('KARUNA_REIKI','("Karuna Reiki"[Title/Abstract]) AND ("1800/01/01"[Date - Publication] : "2026/09/30"[Date - Publication])','NCBI PubMed ESearch API','2026-09-30','2026-09-30','OK','0','("Karuna Reiki"[Title/Abstract]) AND ("1800/01/01"[Date - Publication] : "2026/09/30"[Date - Publication])','','{"phrasesignored": [], "quotedphrasesnotfound": ["\"Karuna Reiki\"[Title/Abstract]"], "outputmessages": ["Restrictions achieved. start and count adjusted to 0, 9999", "No items found."]} ') ON DUPLICATE KEY UPDATE retrieval_status=VALUES(retrieval_status),result_count=VALUES(result_count),returned_pmids=VALUES(returned_pmids),warnings_text=VALUES(warnings_text);
INSERT INTO ilb_ehr_research_gate VALUES ('KARUNA_REIKI','2026-09-30','0','PubMed database query status OK; 0 returned records, including possible name collisions. 0 returned identifiers are outside the earlier cohort and require metadata screening. Earlier cohort: 0 retained/identity candidates still need extraction or resolution. No exhaustive or clinical-validation conclusion is asserted.','No records returned by this exact PubMed query. This does not establish no research: verify aliases and publisher reports outside PubMed. Screen expanded query identifiers and resolve aliases/lineages; search registries and regional/non-English databases; appraise remaining full texts and bias; compare independent outcome-specific studies; extract complete procedures where reported. Never infer branch efficacy from parent studies or diagnose using unvalidated energy measurements.') ON DUPLICATE KEY UPDATE summary_text=VALUES(summary_text),next_actions=VALUES(next_actions),research_complete=VALUES(research_complete);
INSERT INTO ilb_ehr_database_search VALUES ('HOLY_FIRE_REIKI','("Holy Fire Reiki"[Title/Abstract]) AND ("1800/01/01"[Date - Publication] : "2026/09/30"[Date - Publication])','NCBI PubMed ESearch API','2026-09-30','2026-09-30','OK','0','("Holy Fire Reiki"[Title/Abstract]) AND ("1800/01/01"[Date - Publication] : "2026/09/30"[Date - Publication])','','{"phrasesignored": [], "quotedphrasesnotfound": ["\"Holy Fire Reiki\"[Title/Abstract]"], "outputmessages": ["Restrictions achieved. start and count adjusted to 0, 9999", "No items found."]} ') ON DUPLICATE KEY UPDATE retrieval_status=VALUES(retrieval_status),result_count=VALUES(result_count),returned_pmids=VALUES(returned_pmids),warnings_text=VALUES(warnings_text);
INSERT INTO ilb_ehr_research_gate VALUES ('HOLY_FIRE_REIKI','2026-09-30','0','PubMed database query status OK; 0 returned records, including possible name collisions. 0 returned identifiers are outside the earlier cohort and require metadata screening. Earlier cohort: 0 retained/identity candidates still need extraction or resolution. No exhaustive or clinical-validation conclusion is asserted.','No records returned by this exact PubMed query. This does not establish no research: verify aliases and publisher reports outside PubMed. Screen expanded query identifiers and resolve aliases/lineages; search registries and regional/non-English databases; appraise remaining full texts and bias; compare independent outcome-specific studies; extract complete procedures where reported. Never infer branch efficacy from parent studies or diagnose using unvalidated energy measurements.') ON DUPLICATE KEY UPDATE summary_text=VALUES(summary_text),next_actions=VALUES(next_actions),research_complete=VALUES(research_complete);
INSERT INTO ilb_ehr_database_search VALUES ('SEICHIM','("Seichim"[Title/Abstract] OR "Seichem"[Title/Abstract]) AND ("1800/01/01"[Date - Publication] : "2026/09/30"[Date - Publication])','NCBI PubMed ESearch API','2026-09-30','2026-09-30','OK','0','("Seichim"[Title/Abstract] OR "Seichem"[Title/Abstract]) AND ("1800/01/01"[Date - Publication] : "2026/09/30"[Date - Publication])','','{"phrasesignored": [], "quotedphrasesnotfound": ["\"Seichim\"[Title/Abstract]", "\"Seichem\"[Title/Abstract]"], "outputmessages": ["Restrictions achieved. start and count adjusted to 0, 9999", "No items found."]} ') ON DUPLICATE KEY UPDATE retrieval_status=VALUES(retrieval_status),result_count=VALUES(result_count),returned_pmids=VALUES(returned_pmids),warnings_text=VALUES(warnings_text);
INSERT INTO ilb_ehr_research_gate VALUES ('SEICHIM','2026-09-30','0','PubMed database query status OK; 0 returned records, including possible name collisions. 0 returned identifiers are outside the earlier cohort and require metadata screening. Earlier cohort: 0 retained/identity candidates still need extraction or resolution. No exhaustive or clinical-validation conclusion is asserted.','No records returned by this exact PubMed query. This does not establish no research: verify aliases and publisher reports outside PubMed. Screen expanded query identifiers and resolve aliases/lineages; search registries and regional/non-English databases; appraise remaining full texts and bias; compare independent outcome-specific studies; extract complete procedures where reported. Never infer branch efficacy from parent studies or diagnose using unvalidated energy measurements.') ON DUPLICATE KEY UPDATE summary_text=VALUES(summary_text),next_actions=VALUES(next_actions),research_complete=VALUES(research_complete);
INSERT INTO ilb_ehr_database_search VALUES ('SEKHEM_BELOT','("Sekhem Helen Belot"[Title/Abstract] OR "Sekhem healing"[Title/Abstract]) AND ("1800/01/01"[Date - Publication] : "2026/09/30"[Date - Publication])','NCBI PubMed ESearch API','2026-09-30','2026-09-30','OK','0','("Sekhem Helen Belot"[Title/Abstract] OR "Sekhem healing"[Title/Abstract]) AND ("1800/01/01"[Date - Publication] : "2026/09/30"[Date - Publication])','','{"phrasesignored": [], "quotedphrasesnotfound": ["\"Sekhem Helen Belot\"[Title/Abstract]", "\"Sekhem healing\"[Title/Abstract]"], "outputmessages": ["Restrictions achieved. start and count adjusted to 0, 9999", "No items found."]} ') ON DUPLICATE KEY UPDATE retrieval_status=VALUES(retrieval_status),result_count=VALUES(result_count),returned_pmids=VALUES(returned_pmids),warnings_text=VALUES(warnings_text);
INSERT INTO ilb_ehr_research_gate VALUES ('SEKHEM_BELOT','2026-09-30','0','PubMed database query status OK; 0 returned records, including possible name collisions. 0 returned identifiers are outside the earlier cohort and require metadata screening. Earlier cohort: 0 retained/identity candidates still need extraction or resolution. No exhaustive or clinical-validation conclusion is asserted.','No records returned by this exact PubMed query. This does not establish no research: verify aliases and publisher reports outside PubMed. Screen expanded query identifiers and resolve aliases/lineages; search registries and regional/non-English databases; appraise remaining full texts and bias; compare independent outcome-specific studies; extract complete procedures where reported. Never infer branch efficacy from parent studies or diagnose using unvalidated energy measurements.') ON DUPLICATE KEY UPDATE summary_text=VALUES(summary_text),next_actions=VALUES(next_actions),research_complete=VALUES(research_complete);
INSERT INTO ilb_ehr_database_search VALUES ('EXTERNAL_QIGONG','("external qigong"[Title/Abstract] OR "external qi"[Title/Abstract] OR "qi therapy"[Title/Abstract]) AND ("1800/01/01"[Date - Publication] : "2026/09/30"[Date - Publication])','NCBI PubMed ESearch API','2026-09-30','2026-09-30','OK','88','("external qigong"[Title/Abstract] OR "external qi"[Title/Abstract] OR "qi therapy"[Title/Abstract]) AND 1800/01/01:2026/09/30[Date - Publication]','42736683
39854162
39327376
38307816
38307809
38304734
38300148
37577894
37492023
35248473
34199174
33895982
33630509
31544386
30702038
30184531
28817428
26773318
26665042
26621441
26291589
25181286
23363659
23165942
23057219
22757968
22160803
22136027
21106615
20712393
20626055
20110687
19606506
19425820
19176423
18654733
18522664
18162859
18080802
18049345
17690012
17109575
17041488
16893670
16861168
16274468
16173532
16051542
16048810
16005839
16005520
15844841
15636358
15550798
15527198
15344429
15285273
15253849
15208467
15102336
15066896
15051523
15025889
14736354
14659379
14587884
12856872
12801074
12470443
12470431
11931339
11576031
11560537
11527067
11448378
11321475
11119183
10471013
9702325
9592592
9188913
8914686
7863841
1353653
1819037
1767800
1978504
2568074','{"phrasesignored": [], "quotedphrasesnotfound": [], "outputmessages": ["Restrictions achieved. start and count adjusted to 0, 9999"]} ') ON DUPLICATE KEY UPDATE retrieval_status=VALUES(retrieval_status),result_count=VALUES(result_count),returned_pmids=VALUES(returned_pmids),warnings_text=VALUES(warnings_text);
INSERT INTO ilb_ehr_research_gate VALUES ('EXTERNAL_QIGONG','2026-09-30','0','PubMed database query status OK; 88 returned records, including possible name collisions. 76 returned identifiers are outside the earlier cohort and require metadata screening. Earlier cohort: 8 retained/identity candidates still need extraction or resolution. No exhaustive or clinical-validation conclusion is asserted.','Screen expanded query identifiers and resolve aliases/lineages; search registries and regional/non-English databases; appraise remaining full texts and bias; compare independent outcome-specific studies; extract complete procedures where reported. Never infer branch efficacy from parent studies or diagnose using unvalidated energy measurements.') ON DUPLICATE KEY UPDATE summary_text=VALUES(summary_text),next_actions=VALUES(next_actions),research_complete=VALUES(research_complete);
INSERT INTO ilb_ehr_database_search VALUES ('PSYCH_K','("PSYCH-K"[Title/Abstract] OR "Psych K"[Title/Abstract]) AND ("1800/01/01"[Date - Publication] : "2026/09/30"[Date - Publication])','NCBI PubMed ESearch API','2026-09-30','2026-09-30','OK','0','("PSYCH-K"[Title/Abstract] OR "Psych K"[Title/Abstract]) AND ("1800/01/01"[Date - Publication] : "2026/09/30"[Date - Publication])','','{"phrasesignored": [], "quotedphrasesnotfound": ["\"PSYCH-K\"[Title/Abstract]", "\"Psych K\"[Title/Abstract]"], "outputmessages": ["Restrictions achieved. start and count adjusted to 0, 9999", "No items found."]} ') ON DUPLICATE KEY UPDATE retrieval_status=VALUES(retrieval_status),result_count=VALUES(result_count),returned_pmids=VALUES(returned_pmids),warnings_text=VALUES(warnings_text);
INSERT INTO ilb_ehr_research_gate VALUES ('PSYCH_K','2026-09-30','0','PubMed database query status OK; 0 returned records, including possible name collisions. 0 returned identifiers are outside the earlier cohort and require metadata screening. Earlier cohort: 0 retained/identity candidates still need extraction or resolution. No exhaustive or clinical-validation conclusion is asserted.','No records returned by this exact PubMed query. This does not establish no research: verify aliases and publisher reports outside PubMed. Screen expanded query identifiers and resolve aliases/lineages; search registries and regional/non-English databases; appraise remaining full texts and bias; compare independent outcome-specific studies; extract complete procedures where reported. Never infer branch efficacy from parent studies or diagnose using unvalidated energy measurements.') ON DUPLICATE KEY UPDATE summary_text=VALUES(summary_text),next_actions=VALUES(next_actions),research_complete=VALUES(research_complete);
INSERT INTO ilb_ehr_database_search VALUES ('EMOTION_CODE','("Emotion Code"[Title/Abstract]) AND ("1800/01/01"[Date - Publication] : "2026/09/30"[Date - Publication])','NCBI PubMed ESearch API','2026-09-30','2026-09-30','OK','0','("Emotion Code"[Title/Abstract]) AND ("1800/01/01"[Date - Publication] : "2026/09/30"[Date - Publication])','','{"phrasesignored": [], "quotedphrasesnotfound": ["\"Emotion Code\"[Title/Abstract]"], "outputmessages": ["Restrictions achieved. start and count adjusted to 0, 9999", "No items found."]} ') ON DUPLICATE KEY UPDATE retrieval_status=VALUES(retrieval_status),result_count=VALUES(result_count),returned_pmids=VALUES(returned_pmids),warnings_text=VALUES(warnings_text);
INSERT INTO ilb_ehr_research_gate VALUES ('EMOTION_CODE','2026-09-30','0','PubMed database query status OK; 0 returned records, including possible name collisions. 0 returned identifiers are outside the earlier cohort and require metadata screening. Earlier cohort: 0 retained/identity candidates still need extraction or resolution. No exhaustive or clinical-validation conclusion is asserted.','No records returned by this exact PubMed query. This does not establish no research: verify aliases and publisher reports outside PubMed. Screen expanded query identifiers and resolve aliases/lineages; search registries and regional/non-English databases; appraise remaining full texts and bias; compare independent outcome-specific studies; extract complete procedures where reported. Never infer branch efficacy from parent studies or diagnose using unvalidated energy measurements.') ON DUPLICATE KEY UPDATE summary_text=VALUES(summary_text),next_actions=VALUES(next_actions),research_complete=VALUES(research_complete);
INSERT INTO ilb_ehr_database_search VALUES ('BODY_CODE','("Body Code"[Title/Abstract]) AND ("1800/01/01"[Date - Publication] : "2026/09/30"[Date - Publication])','NCBI PubMed ESearch API','2026-09-30','2026-09-30','OK','0','("Body Code"[Title/Abstract]) AND ("1800/01/01"[Date - Publication] : "2026/09/30"[Date - Publication])','','{"phrasesignored": [], "quotedphrasesnotfound": ["\"Body Code\"[Title/Abstract]"], "outputmessages": ["Restrictions achieved. start and count adjusted to 0, 9999", "No items found."]} ') ON DUPLICATE KEY UPDATE retrieval_status=VALUES(retrieval_status),result_count=VALUES(result_count),returned_pmids=VALUES(returned_pmids),warnings_text=VALUES(warnings_text);
INSERT INTO ilb_ehr_research_gate VALUES ('BODY_CODE','2026-09-30','0','PubMed database query status OK; 0 returned records, including possible name collisions. 0 returned identifiers are outside the earlier cohort and require metadata screening. Earlier cohort: 0 retained/identity candidates still need extraction or resolution. No exhaustive or clinical-validation conclusion is asserted.','No records returned by this exact PubMed query. This does not establish no research: verify aliases and publisher reports outside PubMed. Screen expanded query identifiers and resolve aliases/lineages; search registries and regional/non-English databases; appraise remaining full texts and bias; compare independent outcome-specific studies; extract complete procedures where reported. Never infer branch efficacy from parent studies or diagnose using unvalidated energy measurements.') ON DUPLICATE KEY UPDATE summary_text=VALUES(summary_text),next_actions=VALUES(next_actions),research_complete=VALUES(research_complete);
INSERT INTO ilb_ehr_database_search VALUES ('JIKIDEN_REIKI','("Jikiden Reiki"[Title/Abstract]) AND ("1800/01/01"[Date - Publication] : "2026/09/30"[Date - Publication])','NCBI PubMed ESearch API','2026-09-30','2026-09-30','OK','0','("Jikiden Reiki"[Title/Abstract]) AND ("1800/01/01"[Date - Publication] : "2026/09/30"[Date - Publication])','','{"phrasesignored": [], "quotedphrasesnotfound": ["\"Jikiden Reiki\"[Title/Abstract]"], "outputmessages": ["Restrictions achieved. start and count adjusted to 0, 9999", "No items found."]} ') ON DUPLICATE KEY UPDATE retrieval_status=VALUES(retrieval_status),result_count=VALUES(result_count),returned_pmids=VALUES(returned_pmids),warnings_text=VALUES(warnings_text);
INSERT INTO ilb_ehr_research_gate VALUES ('JIKIDEN_REIKI','2026-09-30','0','PubMed database query status OK; 0 returned records, including possible name collisions. 0 returned identifiers are outside the earlier cohort and require metadata screening. Earlier cohort: 0 retained/identity candidates still need extraction or resolution. No exhaustive or clinical-validation conclusion is asserted.','No records returned by this exact PubMed query. This does not establish no research: verify aliases and publisher reports outside PubMed. Screen expanded query identifiers and resolve aliases/lineages; search registries and regional/non-English databases; appraise remaining full texts and bias; compare independent outcome-specific studies; extract complete procedures where reported. Never infer branch efficacy from parent studies or diagnose using unvalidated energy measurements.') ON DUPLICATE KEY UPDATE summary_text=VALUES(summary_text),next_actions=VALUES(next_actions),research_complete=VALUES(research_complete);
INSERT INTO ilb_ehr_database_search VALUES ('GENDAI_REIKI','("Gendai Reiki"[Title/Abstract]) AND ("1800/01/01"[Date - Publication] : "2026/09/30"[Date - Publication])','NCBI PubMed ESearch API','2026-09-30','2026-09-30','OK','0','("Gendai Reiki"[Title/Abstract]) AND ("1800/01/01"[Date - Publication] : "2026/09/30"[Date - Publication])','','{"phrasesignored": [], "quotedphrasesnotfound": ["\"Gendai Reiki\"[Title/Abstract]"], "outputmessages": ["Restrictions achieved. start and count adjusted to 0, 9999", "No items found."]} ') ON DUPLICATE KEY UPDATE retrieval_status=VALUES(retrieval_status),result_count=VALUES(result_count),returned_pmids=VALUES(returned_pmids),warnings_text=VALUES(warnings_text);
INSERT INTO ilb_ehr_research_gate VALUES ('GENDAI_REIKI','2026-09-30','0','PubMed database query status OK; 0 returned records, including possible name collisions. 0 returned identifiers are outside the earlier cohort and require metadata screening. Earlier cohort: 0 retained/identity candidates still need extraction or resolution. No exhaustive or clinical-validation conclusion is asserted.','No records returned by this exact PubMed query. This does not establish no research: verify aliases and publisher reports outside PubMed. Screen expanded query identifiers and resolve aliases/lineages; search registries and regional/non-English databases; appraise remaining full texts and bias; compare independent outcome-specific studies; extract complete procedures where reported. Never infer branch efficacy from parent studies or diagnose using unvalidated energy measurements.') ON DUPLICATE KEY UPDATE summary_text=VALUES(summary_text),next_actions=VALUES(next_actions),research_complete=VALUES(research_complete);
INSERT INTO ilb_ehr_database_search VALUES ('TERA_MAI','("Tera-Mai Reiki"[Title/Abstract]) AND ("1800/01/01"[Date - Publication] : "2026/09/30"[Date - Publication])','NCBI PubMed ESearch API','2026-09-30','2026-09-30','OK','0','("Tera-Mai Reiki"[Title/Abstract]) AND ("1800/01/01"[Date - Publication] : "2026/09/30"[Date - Publication])','','{"phrasesignored": [], "quotedphrasesnotfound": ["\"Tera-Mai Reiki\"[Title/Abstract]"], "outputmessages": ["Restrictions achieved. start and count adjusted to 0, 9999", "No items found."]} ') ON DUPLICATE KEY UPDATE retrieval_status=VALUES(retrieval_status),result_count=VALUES(result_count),returned_pmids=VALUES(returned_pmids),warnings_text=VALUES(warnings_text);
INSERT INTO ilb_ehr_research_gate VALUES ('TERA_MAI','2026-09-30','0','PubMed database query status OK; 0 returned records, including possible name collisions. 0 returned identifiers are outside the earlier cohort and require metadata screening. Earlier cohort: 0 retained/identity candidates still need extraction or resolution. No exhaustive or clinical-validation conclusion is asserted.','No records returned by this exact PubMed query. This does not establish no research: verify aliases and publisher reports outside PubMed. Screen expanded query identifiers and resolve aliases/lineages; search registries and regional/non-English databases; appraise remaining full texts and bias; compare independent outcome-specific studies; extract complete procedures where reported. Never infer branch efficacy from parent studies or diagnose using unvalidated energy measurements.') ON DUPLICATE KEY UPDATE summary_text=VALUES(summary_text),next_actions=VALUES(next_actions),research_complete=VALUES(research_complete);
INSERT INTO ilb_ehr_database_search VALUES ('ANGELIC_REIKI','("Angelic Reiki"[Title/Abstract]) AND ("1800/01/01"[Date - Publication] : "2026/09/30"[Date - Publication])','NCBI PubMed ESearch API','2026-09-30','2026-09-30','OK','0','("Angelic Reiki"[Title/Abstract]) AND ("1800/01/01"[Date - Publication] : "2026/09/30"[Date - Publication])','','{"phrasesignored": [], "quotedphrasesnotfound": ["\"Angelic Reiki\"[Title/Abstract]"], "outputmessages": ["Restrictions achieved. start and count adjusted to 0, 9999", "No items found."]} ') ON DUPLICATE KEY UPDATE retrieval_status=VALUES(retrieval_status),result_count=VALUES(result_count),returned_pmids=VALUES(returned_pmids),warnings_text=VALUES(warnings_text);
INSERT INTO ilb_ehr_research_gate VALUES ('ANGELIC_REIKI','2026-09-30','0','PubMed database query status OK; 0 returned records, including possible name collisions. 0 returned identifiers are outside the earlier cohort and require metadata screening. Earlier cohort: 0 retained/identity candidates still need extraction or resolution. No exhaustive or clinical-validation conclusion is asserted.','No records returned by this exact PubMed query. This does not establish no research: verify aliases and publisher reports outside PubMed. Screen expanded query identifiers and resolve aliases/lineages; search registries and regional/non-English databases; appraise remaining full texts and bias; compare independent outcome-specific studies; extract complete procedures where reported. Never infer branch efficacy from parent studies or diagnose using unvalidated energy measurements.') ON DUPLICATE KEY UPDATE summary_text=VALUES(summary_text),next_actions=VALUES(next_actions),research_complete=VALUES(research_complete);
INSERT INTO ilb_ehr_database_search VALUES ('DOMANCIC_METHOD','("Domancic"[Title/Abstract]) AND ("1800/01/01"[Date - Publication] : "2026/09/30"[Date - Publication])','NCBI PubMed ESearch API','2026-09-30','2026-09-30','OK','0','("Domancic"[Title/Abstract]) AND ("1800/01/01"[Date - Publication] : "2026/09/30"[Date - Publication])','','{"phrasesignored": [], "quotedphrasesnotfound": ["\"Domancic\"[Title/Abstract]"], "outputmessages": ["Restrictions achieved. start and count adjusted to 0, 9999", "No items found."]} ') ON DUPLICATE KEY UPDATE retrieval_status=VALUES(retrieval_status),result_count=VALUES(result_count),returned_pmids=VALUES(returned_pmids),warnings_text=VALUES(warnings_text);
INSERT INTO ilb_ehr_research_gate VALUES ('DOMANCIC_METHOD','2026-09-30','0','PubMed database query status OK; 0 returned records, including possible name collisions. 0 returned identifiers are outside the earlier cohort and require metadata screening. Earlier cohort: 0 retained/identity candidates still need extraction or resolution. No exhaustive or clinical-validation conclusion is asserted.','No records returned by this exact PubMed query. This does not establish no research: verify aliases and publisher reports outside PubMed. Screen expanded query identifiers and resolve aliases/lineages; search registries and regional/non-English databases; appraise remaining full texts and bias; compare independent outcome-specific studies; extract complete procedures where reported. Never infer branch efficacy from parent studies or diagnose using unvalidated energy measurements.') ON DUPLICATE KEY UPDATE summary_text=VALUES(summary_text),next_actions=VALUES(next_actions),research_complete=VALUES(research_complete);
INSERT INTO ilb_ehr_database_search VALUES ('SAHAJA_YOGA','("Sahaja Yoga"[Title/Abstract]) AND ("1800/01/01"[Date - Publication] : "2026/09/30"[Date - Publication])','NCBI PubMed ESearch API','2026-09-30','2026-09-30','OK','31','"Sahaja Yoga"[Title/Abstract] AND 1800/01/01:2026/09/30[Date - Publication]','42786418
41765323
40281041
40168409
38547155
37957605
33796013
33370272
30485713
29847314
29275207
27060268
26938433
25671603
25583571
25281881
22784346
22611427
22266174
21807424
21716708
16019582
12947151
12231432
11828038
10908505
10832506
10796803
9062044
7649596
1814885','{"phrasesignored": [], "quotedphrasesnotfound": [], "outputmessages": ["Restrictions achieved. start and count adjusted to 0, 9999"]} ') ON DUPLICATE KEY UPDATE retrieval_status=VALUES(retrieval_status),result_count=VALUES(result_count),returned_pmids=VALUES(returned_pmids),warnings_text=VALUES(warnings_text);
INSERT INTO ilb_ehr_research_gate VALUES ('SAHAJA_YOGA','2026-09-30','0','PubMed database query status OK; 31 returned records, including possible name collisions. 19 returned identifiers are outside the earlier cohort and require metadata screening. Earlier cohort: 10 retained/identity candidates still need extraction or resolution. No exhaustive or clinical-validation conclusion is asserted.','Screen expanded query identifiers and resolve aliases/lineages; search registries and regional/non-English databases; appraise remaining full texts and bias; compare independent outcome-specific studies; extract complete procedures where reported. Never infer branch efficacy from parent studies or diagnose using unvalidated energy measurements.') ON DUPLICATE KEY UPDATE summary_text=VALUES(summary_text),next_actions=VALUES(next_actions),research_complete=VALUES(research_complete);
INSERT INTO ilb_ehr_database_search VALUES ('MANTRA_PRACTICES','("mantra meditation"[Title/Abstract] OR "mantra chanting"[Title/Abstract] OR "mantram"[Title/Abstract]) AND ("1800/01/01"[Date - Publication] : "2026/09/30"[Date - Publication])','NCBI PubMed ESearch API','2026-09-30','2026-09-30','OK','98','("mantra meditation"[Title/Abstract] OR "mantra chanting"[Title/Abstract] OR "mantram"[Title/Abstract]) AND 1800/01/01:2026/09/30[Date - Publication]','42730089
42553883
42534037
42453487
41743302
41428258
41328386
41116809
40775839
40547334
40319664
39978672
39789222
39480321
39427264
39415754
39156622
39083412
39069224
38204770
38166894
38152342
37966989
37788602
37103669
36777474
36444780
36427257
36329765
36142006
36121655
35997686
35956171
35749707
35713599
35386478
35151306
35101554
34855539
34802955
34612802
34600308
34421729
34109412
33573826
33513582
33224309
31681085
31632617
31621414
31138977
31043916
30935542
30249626
30245732
29921143
29752573
29650130
28840941
28619092
28467753
27763931
27537781
27525960
27482335
26850810
26806403
26091550
25397817
25222539
25035626
24959124
24933784
24902448
24203540
24065045
26549967
22742674
22268972
21874605
21138386
20974063
20556767
19752637
19154859
19127438
19123875
18356284
17764203
17518033
17004395
16847590
16499671
16251489
8715891
7862775
2033561
6164542','{"phrasesignored": [], "quotedphrasesnotfound": [], "outputmessages": ["Restrictions achieved. start and count adjusted to 0, 9999"]} ') ON DUPLICATE KEY UPDATE retrieval_status=VALUES(retrieval_status),result_count=VALUES(result_count),returned_pmids=VALUES(returned_pmids),warnings_text=VALUES(warnings_text);
INSERT INTO ilb_ehr_research_gate VALUES ('MANTRA_PRACTICES','2026-09-30','0','PubMed database query status OK; 98 returned records, including possible name collisions. 86 returned identifiers are outside the earlier cohort and require metadata screening. Earlier cohort: 9 retained/identity candidates still need extraction or resolution. No exhaustive or clinical-validation conclusion is asserted.','Screen expanded query identifiers and resolve aliases/lineages; search registries and regional/non-English databases; appraise remaining full texts and bias; compare independent outcome-specific studies; extract complete procedures where reported. Never infer branch efficacy from parent studies or diagnose using unvalidated energy measurements.') ON DUPLICATE KEY UPDATE summary_text=VALUES(summary_text),next_actions=VALUES(next_actions),research_complete=VALUES(research_complete);
INSERT INTO ilb_ehr_database_search VALUES ('CORE_SHAMANISM','("core shamanism"[Title/Abstract] OR "Michael Harner"[Title/Abstract]) AND ("1800/01/01"[Date - Publication] : "2026/09/30"[Date - Publication])','NCBI PubMed ESearch API','2026-09-30','2026-09-30','OK','1','"core shamanism"[Title/Abstract] AND 1800/01/01:2026/09/30[Date - Publication]','41281382','{"phrasesignored": [], "quotedphrasesnotfound": ["\"Michael Harner\"[Title/Abstract]"], "outputmessages": ["Restrictions achieved. start and count adjusted to 0, 9999"]} ') ON DUPLICATE KEY UPDATE retrieval_status=VALUES(retrieval_status),result_count=VALUES(result_count),returned_pmids=VALUES(returned_pmids),warnings_text=VALUES(warnings_text);
INSERT INTO ilb_ehr_research_gate VALUES ('CORE_SHAMANISM','2026-09-30','0','PubMed database query status OK; 1 returned records, including possible name collisions. 0 returned identifiers are outside the earlier cohort and require metadata screening. Earlier cohort: 12 retained/identity candidates still need extraction or resolution. No exhaustive or clinical-validation conclusion is asserted.','Screen expanded query identifiers and resolve aliases/lineages; search registries and regional/non-English databases; appraise remaining full texts and bias; compare independent outcome-specific studies; extract complete procedures where reported. Never infer branch efficacy from parent studies or diagnose using unvalidated energy measurements.') ON DUPLICATE KEY UPDATE summary_text=VALUES(summary_text),next_actions=VALUES(next_actions),research_complete=VALUES(research_complete);
INSERT INTO ilb_ehr_database_search VALUES ('SPIRITUALIST_HEALING','("Spiritualist healing"[Title/Abstract]) AND ("1800/01/01"[Date - Publication] : "2026/09/30"[Date - Publication])','NCBI PubMed ESearch API','2026-09-30','2026-09-30','OK','3','"Spiritualist healing"[Title/Abstract] AND 1800/01/01:2026/09/30[Date - Publication]','3781717
24310951
7408525','{"phrasesignored": [], "quotedphrasesnotfound": [], "outputmessages": ["Restrictions achieved. start and count adjusted to 0, 9999"]} ') ON DUPLICATE KEY UPDATE retrieval_status=VALUES(retrieval_status),result_count=VALUES(result_count),returned_pmids=VALUES(returned_pmids),warnings_text=VALUES(warnings_text);
INSERT INTO ilb_ehr_research_gate VALUES ('SPIRITUALIST_HEALING','2026-09-30','0','PubMed database query status OK; 3 returned records, including possible name collisions. 3 returned identifiers are outside the earlier cohort and require metadata screening. Earlier cohort: 12 retained/identity candidates still need extraction or resolution. No exhaustive or clinical-validation conclusion is asserted.','Screen expanded query identifiers and resolve aliases/lineages; search registries and regional/non-English databases; appraise remaining full texts and bias; compare independent outcome-specific studies; extract complete procedures where reported. Never infer branch efficacy from parent studies or diagnose using unvalidated energy measurements.') ON DUPLICATE KEY UPDATE summary_text=VALUES(summary_text),next_actions=VALUES(next_actions),research_complete=VALUES(research_complete);
INSERT INTO ilb_ehr_database_search VALUES ('CHRISTIAN_SCIENCE_HEALING','("Christian Science"[Title/Abstract] OR "Christian Scientists"[Title/Abstract]) AND ("1800/01/01"[Date - Publication] : "2026/09/30"[Date - Publication])','NCBI PubMed ESearch API','2026-09-30','2026-09-30','OK','114','("Christian Science"[Title/Abstract] OR "Christian Scientists"[Title/Abstract]) AND 1800/01/01:2026/09/30[Date - Publication]','33661680
31778102
30998026
30747304
29266612
27480014
25576962
24388858
21957657
21732134
21681598
20495256
15353105
15255273
12806095
11010664
10496509
10213721
9934563
9032146
11647090
8709454
7591725
7591724
7591720
7591719
12041170
7881376
7730043
8208236
7829307
8411508
11647946
12041213
8493960
11651642
1741319
12041164
11648250
2067935
2391730
11646777
11646775
2367857
2308198
2769921
10312520
3124197
3326292
11648245
3429095
3704701
11611908
3861861
6709033
11644130
6399347
6646189
6646188
6358892
6359451
7454889
6985755
542103
585080
11630626
11609843
1074007
4810119
5028852
4939991
13962786
14494875
13909419
18899179
20317109
18739311
33944424
18738248
18737447
18736970
36886317
29827011
28909837
36020914
29821837
29814807
29819132
29006447
36019904
18340837
36955252
36019289
20760141
36019018
36018960
33701117
36884775
36884770
35829610
36954376
36954359
36887248
36954329
36887218
35829593
20758147
29835847
17816433
36953269
36493236
36493280
36492243
36492029','{"phrasesignored": [], "quotedphrasesnotfound": [], "outputmessages": ["Restrictions achieved. start and count adjusted to 0, 9999"]} ') ON DUPLICATE KEY UPDATE retrieval_status=VALUES(retrieval_status),result_count=VALUES(result_count),returned_pmids=VALUES(returned_pmids),warnings_text=VALUES(warnings_text);
INSERT INTO ilb_ehr_research_gate VALUES ('CHRISTIAN_SCIENCE_HEALING','2026-09-30','0','PubMed database query status OK; 114 returned records, including possible name collisions. 105 returned identifiers are outside the earlier cohort and require metadata screening. Earlier cohort: 0 retained/identity candidates still need extraction or resolution. No exhaustive or clinical-validation conclusion is asserted.','Screen expanded query identifiers and resolve aliases/lineages; search registries and regional/non-English databases; appraise remaining full texts and bias; compare independent outcome-specific studies; extract complete procedures where reported. Never infer branch efficacy from parent studies or diagnose using unvalidated energy measurements.') ON DUPLICATE KEY UPDATE summary_text=VALUES(summary_text),next_actions=VALUES(next_actions),research_complete=VALUES(research_complete);
INSERT INTO ilb_ehr_database_search VALUES ('RADIONICS','("Radionics"[Title/Abstract]) AND ("1800/01/01"[Date - Publication] : "2026/09/30"[Date - Publication])','NCBI PubMed ESearch API','2026-09-30','2026-09-30','OK','156','"Radionics"[Title/Abstract] AND 1800/01/01:2026/09/30[Date - Publication]','42128173
41291294
40773129
39990966
39917985
39528858
39489657
39035734
39010072
37968599
37931880
37780621
37601988
36925913
36185309
34766380
34408877
30497199
29925157
29913831
29227251
28894408
27601154
27025026
25059972
24509185
23507292
23283589
23267914
22658764
28517206
22432193
22299555
22225313
20583411
20037425
20037342
20020296
19735313
19496197
19235371
18987475
18596429
18644286
18644283
18574414
18417896
18060768
18027050
17629076
17622486
17535025
17533322
17352009
25484968
21217914
17057576
16886029
16871294
16782862
16703974
16549690
16518314
16489676
16315902
16244795
16187149
16158343
15909727
15899344
15798426
15742722
15738911
15726439
15674748
15655616
15655593
15625453
15537189
15491893
15467380
15335419
15248081
15235237
15159755
15156617
15076283
15049060
14981955
14734923
14719103
14619473
14604415
14551273
14506571
14501488
12942277
12894984
12892233
12847653
12738337
12721686
12516804
22388095
12484025
12441926
12418375
12383365
12375821
12168323
12111485
12065105
12007278
12007268
11932818
11707988
11707986
11707799
11704463
11474938
11465982
11424357
11317722
11155059
11063180
10853063
10667823
10640921
10598710
10567098
10549932
10533938
10494139
10477028
10379981
10326848
9894978
9693334
9577392
9477398
9402598
9711753
9484590
9233418
9204113
8692390
9311078
8850427
1342476
1295046
2670796
7036890
177954
13856756
13856721
17773810','{"phrasesignored": [], "quotedphrasesnotfound": [], "outputmessages": ["Restrictions achieved. start and count adjusted to 0, 9999"]} ') ON DUPLICATE KEY UPDATE retrieval_status=VALUES(retrieval_status),result_count=VALUES(result_count),returned_pmids=VALUES(returned_pmids),warnings_text=VALUES(warnings_text);
INSERT INTO ilb_ehr_research_gate VALUES ('RADIONICS','2026-09-30','0','PubMed database query status OK; 156 returned records, including possible name collisions. 144 returned identifiers are outside the earlier cohort and require metadata screening. Earlier cohort: 0 retained/identity candidates still need extraction or resolution. No exhaustive or clinical-validation conclusion is asserted.','Screen expanded query identifiers and resolve aliases/lineages; search registries and regional/non-English databases; appraise remaining full texts and bias; compare independent outcome-specific studies; extract complete procedures where reported. Never infer branch efficacy from parent studies or diagnose using unvalidated energy measurements.') ON DUPLICATE KEY UPDATE summary_text=VALUES(summary_text),next_actions=VALUES(next_actions),research_complete=VALUES(research_complete);
INSERT INTO ilb_ehr_database_search VALUES ('HEALING_DOWSING','("dowsing"[Title/Abstract]) AND ("1800/01/01"[Date - Publication] : "2026/09/30"[Date - Publication])','NCBI PubMed ESearch API','2026-09-30','2026-09-30','OK','22','"dowsing"[Title/Abstract] AND 1800/01/01:2026/09/30[Date - Publication]','32527256
30578320
27841517
22365422
19244711
17456101
16781550
16120258
15981388
15895616
12113364
11934908
9265308
2887953
6618961
754193
16063456
16063455
16059362
16059134
18914466
29838345','{"phrasesignored": [], "quotedphrasesnotfound": [], "outputmessages": ["Restrictions achieved. start and count adjusted to 0, 9999"]} ') ON DUPLICATE KEY UPDATE retrieval_status=VALUES(retrieval_status),result_count=VALUES(result_count),returned_pmids=VALUES(returned_pmids),warnings_text=VALUES(warnings_text);
INSERT INTO ilb_ehr_research_gate VALUES ('HEALING_DOWSING','2026-09-30','0','PubMed database query status OK; 22 returned records, including possible name collisions. 17 returned identifiers are outside the earlier cohort and require metadata screening. Earlier cohort: 2 retained/identity candidates still need extraction or resolution. No exhaustive or clinical-validation conclusion is asserted.','Screen expanded query identifiers and resolve aliases/lineages; search registries and regional/non-English databases; appraise remaining full texts and bias; compare independent outcome-specific studies; extract complete procedures where reported. Never infer branch efficacy from parent studies or diagnose using unvalidated energy measurements.') ON DUPLICATE KEY UPDATE summary_text=VALUES(summary_text),next_actions=VALUES(next_actions),research_complete=VALUES(research_complete);
COMMIT;
