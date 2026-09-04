-- Phase 98: governed two-model, non-patient psoriasis disease-modification protocol.
-- This phase specifies what must be measured; it creates no biological result.
START TRANSACTION;

CREATE TABLE IF NOT EXISTS ilb_psoriasis_protocol_model (
 model_key varchar(80) NOT NULL,
 experiment_key varchar(80) NOT NULL,
 model_name varchar(255) NOT NULL,
 biological_scope text NOT NULL,
 valid_question text NOT NULL,
 invalid_inference text NOT NULL,
 source_id varchar(120) NULL,
 source_url varchar(1000) NULL,
 patient_experiment tinyint(1) NOT NULL DEFAULT 0,
 PRIMARY KEY(model_key),
 CONSTRAINT fk_p98_model_experiment FOREIGN KEY(experiment_key)
  REFERENCES ilb_psoriasis_experiment(experiment_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO ilb_psoriasis_protocol_model VALUES
('MODEL_A_TCELL_FTSE','EXP_PSO_RESET_001','T-cell-enriched full-thickness 3D psoriatic skin equivalent','Immune-containing skin system selected for IL-23-axis, T-cell persistence and rechallenge measurements.','Whether upstream pathway interruption changes the ability of the immune-containing tissue to recreate the psoriatic state after verified washout.','A response in this model alone cannot establish complete epidermal barrier restoration across a separately constructed bilayered model.',NULL,NULL,0),
('MODEL_B_CYTOKINE_HSE','EXP_PSO_RESET_001','Cytokine-primed bilayered 3D human skin equivalent','Bilayered epidermal/dermal system exposed to a published psoriasis-associated cytokine cocktail.','Whether downstream IL-17 interruption restores proliferation, differentiation and barrier observables through treatment-free renewal.','This cytokine-primed system bypasses dendritic-cell IL-23 biology and therefore cannot validate IL-23 inhibition.','DOI:10.1038/s42003-024-07226-x','https://www.nature.com/articles/s42003-024-07226-x',0)
ON DUPLICATE KEY UPDATE model_name=VALUES(model_name),biological_scope=VALUES(biological_scope),valid_question=VALUES(valid_question),invalid_inference=VALUES(invalid_inference),source_id=VALUES(source_id),source_url=VALUES(source_url),patient_experiment=VALUES(patient_experiment);

CREATE TABLE IF NOT EXISTS ilb_psoriasis_protocol_endpoint (
 endpoint_key varchar(80) NOT NULL,
 endpoint_name varchar(160) NOT NULL,
 state_key varchar(20) NOT NULL,
 model_a_required tinyint(1) NOT NULL,
 model_b_required tinyint(1) NOT NULL,
 measurement_role text NOT NULL,
 universal_numeric_threshold decimal(20,8) NULL,
 PRIMARY KEY(endpoint_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO ilb_psoriasis_protocol_endpoint VALUES
('KI67','Ki-67','P',1,1,'Keratinocyte proliferation',NULL),
('KRT10','Keratin 10','D',1,1,'Epidermal differentiation',NULL),
('FLG','Filaggrin','D',1,1,'Terminal differentiation and barrier formation',NULL),
('CLDN1','Claudin-1','B',1,1,'Tight-junction barrier',NULL),
('DSG1','Desmoglein-1','B',1,1,'Epidermal adhesion and barrier',NULL),
('TJP1','Tight-junction protein 1','B',1,1,'Tight-junction organization',NULL),
('S100A7','S100A7/psoriasin','R',1,1,'Persistence of psoriatic phenotype',NULL),
('IL17A','Interleukin-17A','I',1,1,'Downstream inflammatory signalling',NULL),
('IL23','Interleukin-23','I',1,0,'Upstream IL-23-axis signalling',NULL),
('IL22','Interleukin-22','I',1,1,'Inflammatory differentiation signal',NULL),
('TNF','Tumour necrosis factor','I',1,1,'Inflammatory signalling',NULL),
('IL6','Interleukin-6','I',1,1,'Inflammatory signalling',NULL),
('BARRIER_FUNCTION','Functional barrier measurement','B',1,1,'Functional confirmation; molecular markers alone are insufficient',NULL),
('TISSUE_VIABILITY','Tissue viability','Q',1,1,'Run-quality and toxicity control',NULL),
('RESIDUAL_INTERVENTION','Residual intervention concentration','W',1,1,'Analytical proof of complete washout',NULL)
ON DUPLICATE KEY UPDATE endpoint_name=VALUES(endpoint_name),state_key=VALUES(state_key),model_a_required=VALUES(model_a_required),model_b_required=VALUES(model_b_required),measurement_role=VALUES(measurement_role),universal_numeric_threshold=VALUES(universal_numeric_threshold);

CREATE TABLE IF NOT EXISTS ilb_psoriasis_protocol_gate (
 gate_key varchar(80) NOT NULL,
 gate_order tinyint unsigned NOT NULL,
 gate_name varchar(180) NOT NULL,
 required_condition text NOT NULL,
 current_state enum('SPECIFIED','DATA_REQUIRED','PASS','FAIL') NOT NULL,
 patient_use_authorized tinyint(1) NOT NULL DEFAULT 0,
 PRIMARY KEY(gate_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO ilb_psoriasis_protocol_gate VALUES
('G01_MODEL_QC',1,'Both model quality gates','Simultaneous healthy and psoriatic controls separate reproducibly while tissue quality passes.','DATA_REQUIRED',0),
('G02_TARGET_ENGAGEMENT',2,'Pathway target engagement','The locked intervention changes its intended pathway in the model assigned to that question.','DATA_REQUIRED',0),
('G03_SKIN_EQUIVALENCE',3,'Post-renewal skin equivalence','Proliferation, differentiation and barrier endpoint confidence intervals lie inside their preregistered margins relative to healthy controls.','DATA_REQUIRED',0),
('G04_IMMUNE_EQUIVALENCE',4,'Post-renewal immune equivalence','Inflammatory endpoint confidence intervals lie inside their preregistered margins relative to healthy controls.','DATA_REQUIRED',0),
('G05_WASHOUT',5,'Verified intervention removal','Residual intervention is below the detection limit validated in the exact culture/tissue matrix.','DATA_REQUIRED',0),
('G06_RECHALLENGE',6,'Resistance to matched rechallenge','Post-rechallenge changes remain inside preregistered endpoint-specific equivalence margins.','DATA_REQUIRED',0),
('G07_CROSS_MODEL',7,'Cross-model agreement','No required endpoint or directional conclusion conflicts between the two valid model scopes.','DATA_REQUIRED',0),
('G08_COMPLETE_CASE',8,'Complete-case disease-modification decision','G01 through G07 all pass; no missing required endpoint is converted to zero or imputed as success.','DATA_REQUIRED',0)
ON DUPLICATE KEY UPDATE gate_order=VALUES(gate_order),gate_name=VALUES(gate_name),required_condition=VALUES(required_condition),current_state=VALUES(current_state),patient_use_authorized=VALUES(patient_use_authorized);

CREATE TABLE IF NOT EXISTS ilb_psoriasis_protocol_formula (
 formula_key varchar(80) NOT NULL,
 formula_latex text NOT NULL,
 definition text NOT NULL,
 invented_coefficient_count int unsigned NOT NULL DEFAULT 0,
 computation_state enum('READY_FOR_DATA','BLOCKED_BY_DATA','COMPUTED') NOT NULL,
 PRIMARY KEY(formula_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO ilb_psoriasis_protocol_formula VALUES
('F_P98_NORMALISE','N_{a,j,t}=(X_{a,j,t}-H_{j,t})/(P_{j,t}-H_{j,t})','Within-run normalization; undefined when P-H equals zero.',0,'READY_FOR_DATA'),
('F_P98_RENEWAL','R_{a,j}=N_{a,j,postrenewal}','Residual disease-state displacement after verified washout and treatment-free renewal.',0,'READY_FOR_DATA'),
('F_P98_RECHALLENGE','C_{a,j}=N_{a,j,postrechallenge}-N_{a,j,prerechallenge}','State displacement caused by matched rechallenge.',0,'READY_FOR_DATA'),
('F_P98_EQUIVALENCE','CI(R_{a,j})\\subseteq[-\\delta_j,+\\delta_j]\\;\\land\\;CI(C_{a,j})\\subseteq[-\\delta_j,+\\delta_j]','Endpoint passes only when both confidence intervals lie entirely inside the preregistered assay-specific equivalence margin.',0,'BLOCKED_BY_DATA'),
('F_P98_DECISION','D_a=G_{01}\\land G_{02}\\land G_{03}\\land G_{04}\\land G_{05}\\land G_{06}\\land G_{07}\\land G_{08}','Disease-modification candidate status requires every gate; missing data cannot pass.',0,'BLOCKED_BY_DATA')
ON DUPLICATE KEY UPDATE formula_latex=VALUES(formula_latex),definition=VALUES(definition),invented_coefficient_count=VALUES(invented_coefficient_count),computation_state=VALUES(computation_state);

COMMIT;
