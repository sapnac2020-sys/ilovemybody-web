-- Phase 55: online test-topic and correlation-readiness engine.
-- This catalog does not order tests, diagnose, or use patient rows.
START TRANSACTION;

CREATE TABLE IF NOT EXISTS ilb_test_topic_catalog (
 topic_key varchar(80) NOT NULL,
 display_order smallint unsigned NOT NULL,
 topic_name varchar(180) NOT NULL,
 person_goal_prompt varchar(700) NOT NULL,
 measurable_question varchar(1000) NOT NULL,
 required_value_contract varchar(1400) NOT NULL,
 correlation_boundary varchar(1400) NOT NULL,
 next_step_state enum('collect_context','collect_exact_results','reviewer_review','clinician_discussion') NOT NULL,
 status enum('draft','active','retired') NOT NULL DEFAULT 'active',
 PRIMARY KEY(topic_key),
 UNIQUE KEY uq_ilb_test_topic_order(display_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO ilb_test_topic_catalog
(topic_key,display_order,topic_name,person_goal_prompt,measurable_question,required_value_contract,correlation_boundary,next_step_state,status)
VALUES
('blood_pressure_circulation',10,'Blood Pressure & Circulation','I want to understand blood pressure, dizziness, exertional symptoms or circulation-related records.','What dated, method-defined cardiovascular measurements or reports exist?','Timestamp, device/method, value, unit, posture/context where applicable, source report and exact test/observation identity.','A value may be trended only within the same defined method/context. It does not establish a cardiovascular diagnosis.','collect_exact_results','active'),
('blood_count_iron',20,'Blood Count, Iron & Anaemia Topics','I want to understand fatigue, weakness, pale appearance or blood-count reports.','What exact haematology and iron-related results, units, specimen and report intervals exist?','LOINC identity, specimen, value, unit, reporting-lab interval, date/time and source document.','No anaemia or deficiency conclusion from a single topic selection; every value remains lab-interval and clinician-context dependent.','collect_exact_results','active'),
('glucose_metabolism',30,'Glucose & Metabolic Topics','I want to understand glucose-related records, energy changes or metabolic monitoring.','What exact glucose/metabolic results and dated measurements exist?','Exact test identity, specimen, numeric value, unit, reporting-lab interval, date/time and source document.','Only exact unit/specimen matches can be compared. No diagnosis or medicine change is generated.','collect_exact_results','active'),
('lipids_cardiometabolic',40,'Lipids & Cardiometabolic Topics','I want to organise lipid reports or cardiovascular risk discussions.','What exact lipid values, units and reporting intervals are present over time?','Exact test identity, specimen, value, unit, reporting-lab interval, date/time and source document.','The engine displays sourced results and trends, not a universal risk score or treatment recommendation.','collect_exact_results','active'),
('thyroid_topics',50,'Thyroid Topics','I want to organise thyroid-related reports, symptoms or prescribed monitoring.','What thyroid tests, values, units, specimen and source intervals exist?','Exact test identity, specimen, value, unit, reporting-lab interval, date/time and source document.','No thyroid condition is inferred from symptoms, journal text or non-matching laboratory units.','collect_exact_results','active'),
('kidney_urine',60,'Kidney & Urine Topics','I want to organise renal, urine or fluid-related reports.','What exact renal/blood/urine results and specimen details are available?','Exact identity, specimen, value, unit, interval, date/time and source document.','No disease stage or fluid/medicine instruction is calculated.','collect_exact_results','active'),
('liver_digestive',70,'Liver & Digestive Topics','I want to organise liver, digestion or abdominal reports.','What exact tests, imaging reports and dated food/symptom observations exist?','Exact test identity and/or source imaging report, date/time, unit/specimen for results and source document.','Food or symptoms may be placed beside results in time; they are not asserted to cause them.','collect_exact_results','active'),
('inflammation_infection',80,'Inflammation & Infection Topics','I want to organise fever, infection or inflammation-related reports.','What clinician/laboratory source records and exact result values exist?','Exact test identity, specimen, numeric/categorical result, date/time and source report.','This is record organisation, not diagnosis or antibiotic guidance.','collect_exact_results','active'),
('vitamins_minerals',90,'Vitamins, Minerals & Nutrition Topics','I want to understand nutrient-related reports alongside recorded food intake.','What exact nutrient test values and exact food portions can be connected?','Exact laboratory identity/specimen/unit/interval plus exact food identifier, grams and approved nutrient composition mapping.','Food nutrient mass and lab results are separate dated measurements; no causal correction claim is made.','collect_exact_results','active'),
('medicines_safety',100,'Medicine Identity & Safety','I want to verify what a medicine is and organise its use with reports.','Is the reported medicine supported by prescription/label evidence and an exact identity?','Reported name, strength, form, route, schedule, document evidence and exact identity link where available.','Never recommends initiation, stopping, dose changes or substitutions.','reviewer_review','active'),
('heart_electrical_imaging',110,'ECG, Echo & Cardiac Imaging Topics','I have an ECG, echo, stress-test or cardiac imaging report.','What is the dated source report and clinician/radiologist interpretation?','Study identity, performed date/time, original report, body context and confirmed finding only when present in report.','No raw image or waveform interpretation is performed by the online system.','collect_exact_results','active'),
('brain_neurological_imaging',120,'Brain & Neurological Topics','I have neurological symptoms or a brain/nerve report.','What dated examination, imaging or laboratory report exists?','Original report, study identity, date/time, symptoms as self-report and confirmed findings attributed to source.','New acute neurological symptoms are safety escalation, not correlation work.','reviewer_review','active'),
('eyes_vision',130,'Eyes & Vision Topics','I want to track vision, screen exposure or eye reports.','What objective eye examination/vision results and dated exposure observations exist?','Exam/test identity, method, eye/laterality when applicable, value/unit, date/time and source report.','Screen time may be logged beside results but is not declared causal. Acute vision loss or severe pain is urgent care.','collect_exact_results','active'),
('hearing_ent',140,'Hearing, ENT & Balance Topics','I want to organise hearing, tinnitus, dizziness or ENT reports.','What audiology/ENT observations, method-defined results and source reports exist?','Test identity, method, laterality where applicable, value/unit, date/time and report.','Sudden hearing loss or severe acute symptoms are urgent review; no causal conclusion from self-report.','collect_exact_results','active'),
('skin_hair',150,'Skin & Hair Topics','I want to track hair quality, hair loss, greying, skin changes or dermatology reports.','What dated photographs/exam reports, exact lab values and routine exposures exist?','Consented dated photographs or clinician report, exact lab values where available, and structured routine observation.','No diagnosis from photographs or single symptom; correlations remain observations pending reviewer evidence.','collect_context','active'),
('sleep_mental_wellbeing',160,'Sleep, Mental Health & Wellbeing Topics','I want to organise sleep, mood, stress, attention or functioning observations.','What optional self-reports and validated instrument results are available over time?','Instrument name/version, score and scoring rule; date/time; explicit self-report status; safety response where required.','No diagnosis from free text. Safety answers override normal timeline behaviour.','collect_context','active'),
('women_reproductive',170,'Women’s & Reproductive Health Topics','I want to organise reproductive-health, cycle, pregnancy or hormonal reports.','What private dated observations and source reports are available under consent?','Explicit consent, exact test/imaging identity, result/unit/specimen/date and source report.','Does not replace obstetric/gynaecological care or derive recommendations without clinician review.','reviewer_review','active'),
('preventive_screening',180,'Preventive Screening Topics','I want to see which existing screening records are organised and which questions need a clinician.','Which source screening reports, dates and clinician recommendations have been recorded?','Source report, test identity, date, result/status, documented clinician recommendation and voluntary context.','The system never creates a universal screening schedule; a reviewer/clinician must approve any “consider discussing” prompt.','reviewer_review','active')
ON DUPLICATE KEY UPDATE
 display_order=VALUES(display_order),topic_name=VALUES(topic_name),person_goal_prompt=VALUES(person_goal_prompt),
 measurable_question=VALUES(measurable_question),required_value_contract=VALUES(required_value_contract),
 correlation_boundary=VALUES(correlation_boundary),next_step_state=VALUES(next_step_state),status=VALUES(status);

CREATE TABLE IF NOT EXISTS ilb_test_consideration (
 consideration_id bigint unsigned NOT NULL AUTO_INCREMENT,
 subject_key varchar(120) NOT NULL,
 topic_key varchar(80) NOT NULL,
 basis_type enum('self_selected','reviewer_proposed','clinician_documented') NOT NULL,
 basis_record_ref varchar(255) NULL,
 state enum('collect_context','collect_exact_results','reviewer_review','clinician_discussion','closed') NOT NULL,
 reviewer_note varchar(2000) NULL,
 created_at datetime(6) NOT NULL DEFAULT current_timestamp(6),
 updated_at datetime(6) NOT NULL DEFAULT current_timestamp(6) ON UPDATE current_timestamp(6),
 PRIMARY KEY(consideration_id),
 KEY idx_ilb_test_consideration_subject(subject_key,created_at),
 KEY idx_ilb_test_consideration_topic(topic_key,state),
 CONSTRAINT fk_ilb_test_consideration_topic FOREIGN KEY(topic_key) REFERENCES ilb_test_topic_catalog(topic_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE OR REPLACE VIEW v_ilb_test_topic_catalog AS
SELECT topic_key,display_order,topic_name,person_goal_prompt,measurable_question,required_value_contract,correlation_boundary,next_step_state
FROM ilb_test_topic_catalog WHERE status='active' ORDER BY display_order;

INSERT INTO ilb_backend_object_registry
(object_name,object_type,domain_key,canonical_role,frontend_access,lifecycle_status,replacement_object_name,decision_note,release_key)
VALUES
('ilb_test_topic_catalog','table','diagnostics','Online test topic, data contract and safety boundary catalogue.','read_contract','canonical',NULL,'Topics are not diagnoses or automatic test orders.','ilb_backend_2026_07_24_complete'),
('ilb_test_consideration','table','diagnostics','Patient-specific test consideration workflow.','read_write_contract','canonical',NULL,'Only reviewer-approved or clinician-documented records can reach clinician_discussion.','ilb_backend_2026_07_24_complete'),
('v_ilb_test_topic_catalog','view','diagnostics','Active test topic read model.','read_contract','canonical',NULL,'Exposes test topics with their evidence and safety contract.','ilb_backend_2026_07_24_complete')
ON DUPLICATE KEY UPDATE object_type=VALUES(object_type),domain_key=VALUES(domain_key),canonical_role=VALUES(canonical_role),frontend_access=VALUES(frontend_access),lifecycle_status=VALUES(lifecycle_status),replacement_object_name=VALUES(replacement_object_name),decision_note=VALUES(decision_note),release_key=VALUES(release_key);
COMMIT;