-- ILoveMyBody Phase 105
-- EMDR as a separate governed modality for the psoriasis hospital.
-- Additive, idempotent, evidence-labelled, and does not assert that EMDR treats psoriasis directly.

CREATE TABLE IF NOT EXISTS ilb_modality_definition (
  modality_id CHAR(64) PRIMARY KEY,
  modality_code VARCHAR(80) NOT NULL,
  modality_name VARCHAR(255) NOT NULL,
  modality_class VARCHAR(160) NOT NULL,
  description_text TEXT NOT NULL,
  primary_target_text TEXT NULL,
  established_indication_text TEXT NULL,
  psoriasis_role ENUM('DIRECT_TREATMENT','UPSTREAM_MODIFIER','SUPPORTIVE','RESEARCH_ONLY','NOT_APPLICABLE') NOT NULL DEFAULT 'RESEARCH_ONLY',
  psoriasis_evidence_status ENUM('ESTABLISHED','SUPPORTED','PRELIMINARY','HYPOTHESIS','NO_EVIDENCE') NOT NULL DEFAULT 'HYPOTHESIS',
  medication_flag BOOLEAN NOT NULL DEFAULT FALSE,
  clinician_required BOOLEAN NOT NULL DEFAULT TRUE,
  active_flag BOOLEAN NOT NULL DEFAULT TRUE,
  version_no INT UNSIGNED NOT NULL DEFAULT 1,
  UNIQUE KEY uq_modality_code(modality_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_modality_pathway_link (
  modality_pathway_id CHAR(64) PRIMARY KEY,
  modality_id CHAR(64) NOT NULL,
  disease_code VARCHAR(80) NOT NULL,
  pathway_code VARCHAR(120) NOT NULL,
  target_node_code VARCHAR(120) NULL,
  relation_type ENUM('TARGETS','MODULATES','MEASURES','HYPOTHESIZED_DOWNSTREAM_EFFECT','CONTRAINDICATES') NOT NULL,
  direction_code ENUM('UP','DOWN','NORMALIZE','UNKNOWN') NOT NULL DEFAULT 'UNKNOWN',
  evidence_status ENUM('ESTABLISHED','SUPPORTED','PRELIMINARY','HYPOTHESIS','NO_EVIDENCE') NOT NULL,
  clinical_use_status ENUM('ROUTINE','CONDITIONAL','RESEARCH_ONLY','DO_NOT_USE') NOT NULL DEFAULT 'RESEARCH_ONLY',
  statement_text TEXT NOT NULL,
  CONSTRAINT fk_modality_pathway_modality FOREIGN KEY(modality_id) REFERENCES ilb_modality_definition(modality_id),
  UNIQUE KEY uq_modality_pathway(modality_id,disease_code,pathway_code,target_node_code,relation_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_modality_protocol_step (
  protocol_step_id CHAR(64) PRIMARY KEY,
  modality_id CHAR(64) NOT NULL,
  protocol_code VARCHAR(120) NOT NULL,
  step_no INT UNSIGNED NOT NULL,
  step_name VARCHAR(255) NOT NULL,
  purpose_text TEXT NOT NULL,
  measurement_checkpoint BOOLEAN NOT NULL DEFAULT FALSE,
  safety_checkpoint BOOLEAN NOT NULL DEFAULT FALSE,
  CONSTRAINT fk_protocol_step_modality FOREIGN KEY(modality_id) REFERENCES ilb_modality_definition(modality_id),
  UNIQUE KEY uq_protocol_step(modality_id,protocol_code,step_no)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_modality_measurement_link (
  modality_measurement_id CHAR(64) PRIMARY KEY,
  modality_id CHAR(64) NOT NULL,
  disease_code VARCHAR(80) NOT NULL,
  input_code VARCHAR(160) NOT NULL,
  timing_code ENUM('BASELINE','PRE_SESSION','DURING_SESSION','POST_SESSION','FOLLOW_UP','DISEASE_REASSESSMENT') NOT NULL,
  measurement_role ENUM('TARGET_ENGAGEMENT','AUTONOMIC','DISEASE_ACTIVITY','SYMPTOM','SAFETY','RESEARCH') NOT NULL,
  required_flag BOOLEAN NOT NULL DEFAULT FALSE,
  interpretation_text TEXT NOT NULL,
  CONSTRAINT fk_modality_measurement_modality FOREIGN KEY(modality_id) REFERENCES ilb_modality_definition(modality_id),
  UNIQUE KEY uq_modality_measurement(modality_id,disease_code,input_code,timing_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_modality_evidence (
  evidence_id CHAR(64) PRIMARY KEY,
  modality_id CHAR(64) NOT NULL,
  evidence_scope ENUM('MODALITY_GENERAL','MECHANISM','PSORIASIS_DIRECT','PSORIASIS_INDIRECT','SAFETY') NOT NULL,
  evidence_status ENUM('ESTABLISHED','SUPPORTED','PRELIMINARY','HYPOTHESIS','NO_EVIDENCE') NOT NULL,
  source_type VARCHAR(120) NOT NULL,
  citation_text TEXT NOT NULL,
  conclusion_text TEXT NOT NULL,
  numeric_claim_allowed BOOLEAN NOT NULL DEFAULT FALSE,
  reviewed_flag BOOLEAN NOT NULL DEFAULT FALSE,
  CONSTRAINT fk_modality_evidence_modality FOREIGN KEY(modality_id) REFERENCES ilb_modality_definition(modality_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_modality_session (
  modality_session_id CHAR(64) PRIMARY KEY,
  modality_id CHAR(64) NOT NULL,
  subject_key VARCHAR(255) NOT NULL,
  episode_key VARCHAR(255) NOT NULL,
  session_no INT UNSIGNED NULL,
  started_at DATETIME(6) NULL,
  ended_at DATETIME(6) NULL,
  provider_key VARCHAR(255) NULL,
  target_label VARCHAR(512) NULL,
  completion_status ENUM('PLANNED','STARTED','COMPLETED','STOPPED','CANCELLED') NOT NULL DEFAULT 'PLANNED',
  safety_status ENUM('NOT_ASSESSED','CLEAR','CONCERN','ESCALATED') NOT NULL DEFAULT 'NOT_ASSESSED',
  notes_text TEXT NULL,
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  CONSTRAINT fk_modality_session_modality FOREIGN KEY(modality_id) REFERENCES ilb_modality_definition(modality_id),
  UNIQUE KEY uq_modality_session(modality_id,subject_key,episode_key,session_no)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_modality_session_measurement (
  session_measurement_id CHAR(64) PRIMARY KEY,
  modality_session_id CHAR(64) NOT NULL,
  input_id CHAR(64) NOT NULL,
  observed_at DATETIME(6) NOT NULL,
  timing_code ENUM('PRE','DURING','POST','FOLLOW_UP') NOT NULL,
  value_number DECIMAL(38,12) NULL,
  value_text TEXT NULL,
  unit_code VARCHAR(64) NULL,
  quality_status ENUM('UNVERIFIED','VALID','REJECTED') NOT NULL DEFAULT 'UNVERIFIED',
  source_record_id CHAR(64) NULL,
  CONSTRAINT fk_session_measurement_session FOREIGN KEY(modality_session_id) REFERENCES ilb_modality_session(modality_session_id),
  CONSTRAINT fk_session_measurement_input FOREIGN KEY(input_id) REFERENCES ilb_model_input_definition(input_id),
  CHECK (value_number IS NOT NULL OR value_text IS NOT NULL)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO ilb_modality_definition(
  modality_id,modality_code,modality_name,modality_class,description_text,primary_target_text,
  established_indication_text,psoriasis_role,psoriasis_evidence_status,medication_flag,clinician_required,active_flag,version_no
) VALUES (
  SHA2('ILMB:MODALITY:EMDR',256),'EMDR','Eye Movement Desensitization and Reprocessing',
  'TRAUMA_FOCUSED_PSYCHOTHERAPY',
  'Structured psychotherapy using target-memory activation with dual-attention bilateral stimulation within an eight-phase protocol.',
  'Disturbing memory processing, associated threat meaning, distress and physiological arousal.',
  'Established trauma-focused psychotherapy, especially for PTSD; indication and suitability require qualified clinical assessment.',
  'UPSTREAM_MODIFIER','PRELIMINARY',FALSE,TRUE,TRUE,1
) ON DUPLICATE KEY UPDATE
  modality_name=VALUES(modality_name),modality_class=VALUES(modality_class),description_text=VALUES(description_text),
  primary_target_text=VALUES(primary_target_text),established_indication_text=VALUES(established_indication_text),
  psoriasis_role=VALUES(psoriasis_role),psoriasis_evidence_status=VALUES(psoriasis_evidence_status),active_flag=VALUES(active_flag),version_no=VALUES(version_no);

SET @emdr_id = SHA2('ILMB:MODALITY:EMDR',256);

INSERT INTO ilb_modality_pathway_link(
  modality_pathway_id,modality_id,disease_code,pathway_code,target_node_code,relation_type,direction_code,evidence_status,clinical_use_status,statement_text
) VALUES
(SHA2('EMDR:PSO:P05:N1',256),@emdr_id,'PSO-001','PSO-P05','N1','TARGETS','NORMALIZE','ESTABLISHED','CONDITIONAL','EMDR directly targets distressing memory processing and the associated learned threat response; this is the primary modality target.'),
(SHA2('EMDR:PSO:P05:N2',256),@emdr_id,'PSO-001','PSO-P05','N2','MODULATES','DOWN','SUPPORTED','CONDITIONAL','Reduced trauma-related distress may reduce central threat/arousal responses; autonomic effects should be measured rather than assumed.'),
(SHA2('EMDR:PSO:P04:N5',256),@emdr_id,'PSO-001','PSO-P04','N5','HYPOTHESIZED_DOWNSTREAM_EFFECT','DOWN','HYPOTHESIS','RESEARCH_ONLY','A downstream reduction in peripheral neuroimmune drive is a research hypothesis and is not an established clinical effect of EMDR.'),
(SHA2('EMDR:PSO:P01:I4',256),@emdr_id,'PSO-001','PSO-P01','I4','HYPOTHESIZED_DOWNSTREAM_EFFECT','DOWN','HYPOTHESIS','RESEARCH_ONLY','No direct IL-17-lowering effect of EMDR is established; any downstream immune change must be measured.'),
(SHA2('EMDR:PSO:P02:K1',256),@emdr_id,'PSO-001','PSO-P02','K1','HYPOTHESIZED_DOWNSTREAM_EFFECT','NORMALIZE','HYPOTHESIS','RESEARCH_ONLY','Keratinocyte normalization after EMDR is not established and must never be inferred from improved distress alone.')
ON DUPLICATE KEY UPDATE evidence_status=VALUES(evidence_status),clinical_use_status=VALUES(clinical_use_status),statement_text=VALUES(statement_text);

INSERT INTO ilb_modality_protocol_step(protocol_step_id,modality_id,protocol_code,step_no,step_name,purpose_text,measurement_checkpoint,safety_checkpoint) VALUES
(SHA2('EMDR:STD:1',256),@emdr_id,'EMDR_8_PHASE',1,'History and treatment planning','Assess history, suitability, targets, risks and treatment plan.',TRUE,TRUE),
(SHA2('EMDR:STD:2',256),@emdr_id,'EMDR_8_PHASE',2,'Preparation','Explain procedure, establish stabilization and coping resources before reprocessing.',TRUE,TRUE),
(SHA2('EMDR:STD:3',256),@emdr_id,'EMDR_8_PHASE',3,'Assessment','Identify target image, negative cognition, preferred cognition, emotions, body sensations and baseline ratings.',TRUE,FALSE),
(SHA2('EMDR:STD:4',256),@emdr_id,'EMDR_8_PHASE',4,'Desensitization','Process the target using brief sets of bilateral stimulation while tracking emerging material and distress.',TRUE,TRUE),
(SHA2('EMDR:STD:5',256),@emdr_id,'EMDR_8_PHASE',5,'Installation','Strengthen an adaptive cognition when clinically appropriate.',TRUE,FALSE),
(SHA2('EMDR:STD:6',256),@emdr_id,'EMDR_8_PHASE',6,'Body scan','Check for residual somatic disturbance linked to the target.',TRUE,FALSE),
(SHA2('EMDR:STD:7',256),@emdr_id,'EMDR_8_PHASE',7,'Closure','End the session safely, document incomplete processing and stabilization requirements.',TRUE,TRUE),
(SHA2('EMDR:STD:8',256),@emdr_id,'EMDR_8_PHASE',8,'Reevaluation','Reassess prior target effects, current symptoms and whether further processing is indicated.',TRUE,TRUE)
ON DUPLICATE KEY UPDATE step_name=VALUES(step_name),purpose_text=VALUES(purpose_text),measurement_checkpoint=VALUES(measurement_checkpoint),safety_checkpoint=VALUES(safety_checkpoint);

-- EMDR-specific observations are added to the existing psoriasis model so the current private intake can render them automatically.
INSERT INTO ilb_model_input_definition(input_id,model_code,input_code,category_code,label,value_domain,canonical_unit_code,time_basis,body_site_required,provenance_required,release_required) VALUES
(SHA2('PSO:IN:EMDR_TARGET',256),'PSO_COP_LIFESTYLE_V4','EMDR_TARGET_LABEL','EMDR','EMDR target label','TEXT',NULL,'per session',FALSE,TRUE,FALSE),
(SHA2('PSO:IN:EMDR_SUD',256),'PSO_COP_LIFESTYLE_V4','EMDR_SUD','EMDR','Subjective units of disturbance','NUMBER','1','pre/post session',FALSE,TRUE,FALSE),
(SHA2('PSO:IN:EMDR_VOC',256),'PSO_COP_LIFESTYLE_V4','EMDR_VOC','EMDR','Validity of cognition rating','NUMBER','1','pre/post session',FALSE,TRUE,FALSE),
(SHA2('PSO:IN:EMDR_BODY',256),'PSO_COP_LIFESTYLE_V4','EMDR_BODY_SENSATION','EMDR','Target-linked body sensation','TEXT',NULL,'pre/post session',FALSE,TRUE,FALSE),
(SHA2('PSO:IN:HRV_RMSSD',256),'PSO_COP_LIFESTYLE_V4','HRV_RMSSD','AUTONOMIC','Heart-rate variability RMSSD','NUMBER','ms','standardised resting window',FALSE,TRUE,FALSE),
(SHA2('PSO:IN:EMDR_SESSION',256),'PSO_COP_LIFESTYLE_V4','EMDR_SESSION_STATUS','EMDR','EMDR session status','CATEGORY',NULL,'per session',FALSE,TRUE,FALSE)
ON DUPLICATE KEY UPDATE label=VALUES(label),canonical_unit_code=VALUES(canonical_unit_code),time_basis=VALUES(time_basis),release_required=VALUES(release_required);

INSERT INTO ilb_modality_measurement_link(modality_measurement_id,modality_id,disease_code,input_code,timing_code,measurement_role,required_flag,interpretation_text) VALUES
(SHA2('EMDR:M:SUD:PRE',256),@emdr_id,'PSO-001','EMDR_SUD','PRE_SESSION','TARGET_ENGAGEMENT',TRUE,'Tracks target distress; a change demonstrates target engagement, not psoriasis improvement.'),
(SHA2('EMDR:M:SUD:POST',256),@emdr_id,'PSO-001','EMDR_SUD','POST_SESSION','TARGET_ENGAGEMENT',TRUE,'Post-session target distress must be interpreted independently from skin outcome.'),
(SHA2('EMDR:M:HRV:PRE',256),@emdr_id,'PSO-001','HRV_RMSSD','PRE_SESSION','AUTONOMIC',FALSE,'Optional standardized autonomic measurement; protocol conditions must be recorded.'),
(SHA2('EMDR:M:HRV:POST',256),@emdr_id,'PSO-001','HRV_RMSSD','POST_SESSION','AUTONOMIC',FALSE,'A short-term HRV change is not evidence of immune or skin normalization.'),
(SHA2('EMDR:M:ITCH',256),@emdr_id,'PSO-001','ITCH_NRS','DISEASE_REASSESSMENT','SYMPTOM',FALSE,'Track separately to test whether symptom change follows target engagement.'),
(SHA2('EMDR:M:PASI',256),@emdr_id,'PSO-001','PASI','DISEASE_REASSESSMENT','DISEASE_ACTIVITY',FALSE,'Disease activity must be reassessed independently; EMDR response cannot substitute for PASI/BSA or lesion measurements.'),
(SHA2('EMDR:M:BSA',256),@emdr_id,'PSO-001','BSA_PERCENT','DISEASE_REASSESSMENT','DISEASE_ACTIVITY',FALSE,'Tracks skin involvement independently of psychological response.'),
(SHA2('EMDR:M:PLAQUE',256),@emdr_id,'PSO-001','PLAQUE_TARGET','DISEASE_REASSESSMENT','DISEASE_ACTIVITY',FALSE,'Target plaque measurement tests whether skin state changes after the upstream intervention.')
ON DUPLICATE KEY UPDATE interpretation_text=VALUES(interpretation_text),required_flag=VALUES(required_flag);

INSERT INTO ilb_modality_evidence(evidence_id,modality_id,evidence_scope,evidence_status,source_type,citation_text,conclusion_text,numeric_claim_allowed,reviewed_flag) VALUES
(SHA2('EMDR:E:GENERAL',256),@emdr_id,'MODALITY_GENERAL','ESTABLISHED','GUIDELINE','Trauma-focused clinical guidelines and EMDR standard protocol sources','EMDR is an established trauma-focused psychotherapy. This does not establish psoriasis efficacy.',FALSE,FALSE),
(SHA2('EMDR:E:MECH',256),@emdr_id,'MECHANISM','SUPPORTED','MECHANISTIC_REVIEW','Working-memory, emotional-memory and autonomic EMDR mechanism literature','Reduced vividness/distress and psychophysiological de-arousal are plausible and measurable modality effects; exact mechanism remains debated.',FALSE,FALSE),
(SHA2('EMDR:E:PSO_DIRECT',256),@emdr_id,'PSORIASIS_DIRECT','PRELIMINARY','CASE_SERIES','Small dermatology case literature involving stress-exacerbated dermatoses including psoriasis','Direct psoriasis evidence is insufficient for a treatment or cure claim.',FALSE,FALSE),
(SHA2('EMDR:E:PSO_INDIRECT',256),@emdr_id,'PSORIASIS_INDIRECT','SUPPORTED','MECHANISTIC_REVIEW','Psoriasis stress, HPA/autonomic and neuroimmune literature','Stress and neuroimmune pathways can interact with psoriasis biology, but EMDR-to-IL17-to-clearance is not established.',FALSE,FALSE)
ON DUPLICATE KEY UPDATE evidence_status=VALUES(evidence_status),citation_text=VALUES(citation_text),conclusion_text=VALUES(conclusion_text);

CREATE OR REPLACE VIEW v_ilb_emdr_psoriasis_modality AS
SELECT
  m.modality_code,m.modality_name,m.modality_class,m.psoriasis_role,m.psoriasis_evidence_status,
  COUNT(DISTINCT p.modality_pathway_id) AS pathway_links,
  COUNT(DISTINCT s.protocol_step_id) AS protocol_steps,
  COUNT(DISTINCT ml.modality_measurement_id) AS measurement_links,
  COUNT(DISTINCT e.evidence_id) AS evidence_records,
  SUM(CASE WHEN p.evidence_status='HYPOTHESIS' THEN 1 ELSE 0 END) AS hypothesis_links
FROM ilb_modality_definition m
LEFT JOIN ilb_modality_pathway_link p ON p.modality_id=m.modality_id AND p.disease_code='PSO-001'
LEFT JOIN ilb_modality_protocol_step s ON s.modality_id=m.modality_id AND s.protocol_code='EMDR_8_PHASE'
LEFT JOIN ilb_modality_measurement_link ml ON ml.modality_id=m.modality_id AND ml.disease_code='PSO-001'
LEFT JOIN ilb_modality_evidence e ON e.modality_id=m.modality_id
WHERE m.modality_code='EMDR'
GROUP BY m.modality_id,m.modality_code,m.modality_name,m.modality_class,m.psoriasis_role,m.psoriasis_evidence_status;
