-- Phase 60: governed psoriasis clinical knowledge pathway.
-- Non-patient reference data only. No diagnosis, prescription, dose selection or patient calculation.
START TRANSACTION;

CREATE TABLE IF NOT EXISTS ilb_psoriasis_condition (
 condition_key varchar(80) NOT NULL,
 condition_name varchar(180) NOT NULL,
 condition_group varchar(80) NOT NULL,
 definition_text varchar(1200) NOT NULL,
 urgent_review_gate varchar(1500) NOT NULL,
 evidence_key varchar(80) NOT NULL,
 status enum('draft','review','active','retired') NOT NULL DEFAULT 'review',
 PRIMARY KEY(condition_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ilb_psoriasis_assessment (
 assessment_key varchar(80) NOT NULL,
 assessment_name varchar(180) NOT NULL,
 assessment_role enum('clinician_measure','patient_report','screening','observation') NOT NULL,
 captures_text varchar(1200) NOT NULL,
 execution_gate varchar(1500) NOT NULL,
 evidence_key varchar(80) NOT NULL,
 status enum('draft','review','active','retired') NOT NULL DEFAULT 'review',
 PRIMARY KEY(assessment_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ilb_psoriasis_treatment_class (
 treatment_class_key varchar(80) NOT NULL,
 treatment_class_name varchar(180) NOT NULL,
 scope_text varchar(1200) NOT NULL,
 clinician_gate varchar(1500) NOT NULL,
 evidence_key varchar(80) NOT NULL,
 status enum('draft','review','active','retired') NOT NULL DEFAULT 'review',
 PRIMARY KEY(treatment_class_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ilb_psoriasis_medicine (
 medicine_key varchar(80) NOT NULL,
 generic_name varchar(180) NOT NULL,
 brand_name varchar(180) DEFAULT NULL,
 strength_text varchar(120) DEFAULT NULL,
 dose_form varchar(120) NOT NULL,
 route varchar(80) NOT NULL,
 medicine_class varchar(180) NOT NULL,
 mechanism_text varchar(1200) NOT NULL,
 rxnorm_ingredient_id varchar(40) DEFAULT NULL,
 rxnorm_status enum('exact_approved','blocked_missing_authoritative_identifier') NOT NULL,
 india_brand_status enum('verified','reported_requires_label_confirmation','not_applicable') NOT NULL,
 prescribing_gate varchar(1800) NOT NULL,
 evidence_key varchar(80) NOT NULL,
 status enum('draft','review','active','retired') NOT NULL DEFAULT 'review',
 PRIMARY KEY(medicine_key),
 UNIQUE KEY uq_p60_generic(generic_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ilb_psoriasis_safety_gate (
 gate_key varchar(80) NOT NULL,
 medicine_key varchar(80) DEFAULT NULL,
 gate_name varchar(180) NOT NULL,
 gate_stage enum('urgent_triage','before_treatment','during_treatment','always') NOT NULL,
 required_action varchar(1800) NOT NULL,
 blocks_automated_advice tinyint(1) NOT NULL DEFAULT 1,
 evidence_key varchar(80) NOT NULL,
 status enum('draft','review','active','retired') NOT NULL DEFAULT 'active',
 PRIMARY KEY(gate_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ilb_psoriasis_evidence (
 evidence_key varchar(80) NOT NULL,
 source_authority varchar(180) NOT NULL,
 source_title varchar(500) NOT NULL,
 source_url varchar(1000) NOT NULL,
 source_role enum('guideline','regulatory_label','terminology','manufacturer_safety') NOT NULL,
 jurisdiction varchar(80) NOT NULL,
 verified_on date NOT NULL,
 status enum('active','superseded','withdrawn') NOT NULL DEFAULT 'active',
 PRIMARY KEY(evidence_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO ilb_psoriasis_evidence VALUES
('NICE_CG153','NICE','Psoriasis: assessment and management (CG153)','https://www.nice.org.uk/guidance/cg153/chapter/1-recommendations','guideline','United Kingdom','2026-09-03','active'),
('AAD_NPF_GUIDELINES','American Academy of Dermatology','Psoriasis clinical guideline','https://www.aad.org/member/clinical-quality/guidelines/psoriasis','guideline','United States','2026-09-03','active'),
('FDA_TALTZ_LABEL','US Food and Drug Administration','TALTZ (ixekizumab) prescribing information','https://www.accessdata.fda.gov/drugsatfda_docs/label/2016/125521s000lbl.pdf','regulatory_label','United States','2026-09-03','active'),
('EMA_TALTZ_EPAR','European Medicines Agency','Taltz EPAR','https://www.ema.europa.eu/en/medicines/human/EPAR/taltz','regulatory_label','European Union','2026-09-03','active'),
('RXNORM_IXEKIZUMAB','US National Library of Medicine','RxNorm ingredient: ixekizumab, RxCUI 1745099','https://mor.nlm.nih.gov/RxNav/search?searchBy=RXCUI&searchTerm=1745099','terminology','United States','2026-09-03','active'),
('LILLY_INDIA_SAFETY','Eli Lilly and Company India','Patient safety and adverse-event reporting','https://www.lilly.com/in/safety/patient-safety','manufacturer_safety','India','2026-09-03','active')
ON DUPLICATE KEY UPDATE source_authority=VALUES(source_authority),source_title=VALUES(source_title),source_url=VALUES(source_url),source_role=VALUES(source_role),jurisdiction=VALUES(jurisdiction),verified_on=VALUES(verified_on),status=VALUES(status);

INSERT INTO ilb_psoriasis_condition VALUES
('psoriasis','Psoriasis','immune_mediated_inflammatory_skin_disease','Chronic immune-mediated inflammatory disease with skin manifestations; it is not contagious.','Urgent qualified assessment for widespread acute redness, pustules, systemic illness, fever, rapidly worsening disease, eye symptoms, or severe distress.','NICE_CG153','active'),
('plaque_psoriasis','Plaque psoriasis','psoriasis_variant','Plaque-pattern psoriasis recorded as a distinct clinical variant.','Diagnosis and severity classification require qualified clinical assessment; do not infer from photographs or self-description alone.','NICE_CG153','active'),
('guttate_psoriasis','Guttate psoriasis','psoriasis_variant','Guttate-pattern psoriasis recorded as a distinct clinical variant.','Confirm diagnosis and assess possible infection context through qualified care; no automatic antibiotic or treatment advice.','NICE_CG153','active'),
('pustular_psoriasis','Pustular psoriasis','psoriasis_variant','Pustular psoriasis recorded as a distinct potentially serious clinical variant.','Generalised pustular disease or systemic illness requires urgent medical assessment.','NICE_CG153','active'),
('erythrodermic_psoriasis','Erythrodermic psoriasis','psoriasis_variant','Erythrodermic psoriasis recorded as a distinct potentially life-threatening clinical variant.','Widespread redness or systemic illness requires emergency medical assessment.','NICE_CG153','active'),
('psoriatic_arthritis','Psoriatic arthritis','psoriasis_comorbidity','Inflammatory arthritis associated with psoriasis, maintained as a separate confirmed diagnosis.','New persistent joint swelling, morning stiffness, heel pain or dactylitis requires qualified assessment; screening is not diagnosis.','NICE_CG153','active')
ON DUPLICATE KEY UPDATE condition_name=VALUES(condition_name),condition_group=VALUES(condition_group),definition_text=VALUES(definition_text),urgent_review_gate=VALUES(urgent_review_gate),evidence_key=VALUES(evidence_key),status=VALUES(status);

INSERT INTO ilb_psoriasis_assessment VALUES
('BSA','Body Surface Area involvement','clinician_measure','Estimated proportion of body surface affected.','Store method, assessor, date and value; never infer from an uncalibrated image.','NICE_CG153','active'),
('PASI','Psoriasis Area and Severity Index','clinician_measure','Clinician-rated extent and severity measure.','Use the validated method with trained assessment; store components and version, not an invented shortcut.','NICE_CG153','active'),
('DLQI','Dermatology Life Quality Index','patient_report','Validated patient-reported dermatology quality-of-life measure.','Use only an authorised exact instrument version; do not reproduce protected questionnaire items or invent missing answers.','NICE_CG153','active'),
('PEST','Psoriasis Epidemiology Screening Tool','screening','Screening route for possible psoriatic arthritis.','A screen is not a diagnosis; positive or concerning joint symptoms route to qualified assessment.','NICE_CG153','active'),
('SYMPTOM_LOCATION','Symptoms and affected locations','observation','Dated itch, pain, scaling, skin locations, nails, scalp and patient concerns.','Record observations without diagnosing psoriasis or calculating severity automatically.','AAD_NPF_GUIDELINES','active')
ON DUPLICATE KEY UPDATE assessment_name=VALUES(assessment_name),assessment_role=VALUES(assessment_role),captures_text=VALUES(captures_text),execution_gate=VALUES(execution_gate),evidence_key=VALUES(evidence_key),status=VALUES(status);

INSERT INTO ilb_psoriasis_treatment_class VALUES
('topical','Topical therapies','topical agents used within a clinician-selected plan','No automated selection, potency, quantity, duration or body-site advice.','AAD_NPF_GUIDELINES','active'),
('phototherapy','Phototherapy','clinically supervised ultraviolet treatment modalities','Requires dermatologist selection and controlled dosing; ordinary sun exposure is not a substitute.','AAD_NPF_GUIDELINES','active'),
('systemic_non_biologic','Systemic non-biologic therapies','oral or injected systemic non-biologic medicines','Requires prescriber review, medicine-specific contraindication checks and monitoring.','AAD_NPF_GUIDELINES','active'),
('biologic','Biologic therapies','targeted biologic medicines for eligible patients','Requires specialist diagnosis, indication, infection screening, vaccination review, contraindication review and monitoring.','AAD_NPF_GUIDELINES','active'),
('supportive_self_care','Supportive self-care','non-prescribing support for comfort, adherence and observation','Must not replace assessment or promise disease control; treatment changes remain with the clinician.','NICE_CG153','active')
ON DUPLICATE KEY UPDATE treatment_class_name=VALUES(treatment_class_name),scope_text=VALUES(scope_text),clinician_gate=VALUES(clinician_gate),evidence_key=VALUES(evidence_key),status=VALUES(status);

INSERT INTO ilb_psoriasis_medicine VALUES
('ixekizumab','Ixekizumab','Copellor','80 mg/mL','solution for injection','subcutaneous','IL-17A antagonist monoclonal antibody','Selectively binds interleukin-17A and inhibits its interaction with the IL-17 receptor; descriptive mechanism only, not a patient calculation.','1745099','exact_approved','reported_requires_label_confirmation','Prescription biologic. Specialist must confirm indication and product label, assess active infection and tuberculosis risk, review immunisation status, inflammatory bowel disease and hypersensitivity risk, and monitor during treatment. The hospital must never recommend initiation, dose, interval, interruption or discontinuation.','FDA_TALTZ_LABEL','active')
ON DUPLICATE KEY UPDATE generic_name=VALUES(generic_name),brand_name=VALUES(brand_name),strength_text=VALUES(strength_text),dose_form=VALUES(dose_form),route=VALUES(route),medicine_class=VALUES(medicine_class),mechanism_text=VALUES(mechanism_text),rxnorm_ingredient_id=VALUES(rxnorm_ingredient_id),rxnorm_status=VALUES(rxnorm_status),india_brand_status=VALUES(india_brand_status),prescribing_gate=VALUES(prescribing_gate),evidence_key=VALUES(evidence_key),status=VALUES(status);

INSERT INTO ilb_psoriasis_safety_gate VALUES
('PSO_EMERGENCY',NULL,'Potential severe psoriasis emergency','urgent_triage','Route widespread acute redness, generalised pustules, fever or systemic illness to urgent medical care; do not continue an ordinary self-care flow.',1,'NICE_CG153','active'),
('IXE_HYPERSENSITIVITY','ixekizumab','Serious hypersensitivity','always','Do not provide routine continuation advice after suspected serious allergic reaction; route to emergency or immediate qualified care.',1,'FDA_TALTZ_LABEL','active'),
('IXE_INFECTION','ixekizumab','Active or serious infection','before_treatment','Qualified prescriber assesses infection before treatment and if clinically important infection develops; no automated start/continue decision.',1,'FDA_TALTZ_LABEL','active'),
('IXE_TB','ixekizumab','Tuberculosis evaluation','before_treatment','Qualified prescriber evaluates tuberculosis risk/testing before biologic treatment and manages according to applicable clinical protocol.',1,'FDA_TALTZ_LABEL','active'),
('IXE_VACCINE','ixekizumab','Live-vaccine precaution','before_treatment','Vaccination status and live-vaccine timing require clinician review; the hospital gives no automatic vaccine schedule.',1,'FDA_TALTZ_LABEL','active'),
('IXE_IBD','ixekizumab','Inflammatory bowel disease','during_treatment','New or worsening bowel symptoms require prompt qualified review because inflammatory bowel disease onset or exacerbation is a labelled warning.',1,'FDA_TALTZ_LABEL','active')
ON DUPLICATE KEY UPDATE medicine_key=VALUES(medicine_key),gate_name=VALUES(gate_name),gate_stage=VALUES(gate_stage),required_action=VALUES(required_action),blocks_automated_advice=VALUES(blocks_automated_advice),evidence_key=VALUES(evidence_key),status=VALUES(status);

CREATE OR REPLACE VIEW v_ilmb_psoriasis_pathway AS
SELECT c.condition_key,c.condition_name,c.condition_group,c.definition_text,c.urgent_review_gate,
 e.source_authority,e.source_title,e.source_url
FROM ilb_psoriasis_condition c JOIN ilb_psoriasis_evidence e ON e.evidence_key=c.evidence_key
WHERE c.status='active' AND e.status='active';

CREATE OR REPLACE VIEW v_ilmb_psoriasis_medicine_proof AS
SELECT m.medicine_key,m.generic_name,m.brand_name,m.strength_text,m.dose_form,m.route,m.medicine_class,
 m.mechanism_text,m.rxnorm_ingredient_id,m.rxnorm_status,m.india_brand_status,m.prescribing_gate,
 e.source_authority,e.source_title,e.source_url
FROM ilb_psoriasis_medicine m JOIN ilb_psoriasis_evidence e ON e.evidence_key=m.evidence_key
WHERE m.status='active' AND e.status='active';

COMMIT;