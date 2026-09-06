-- ILoveMyBody psoriasis inverse-solver projection (workbook v4).
-- Structural model only: nullable coefficients stay unknown; no clinical equivalence is asserted.

CREATE TABLE IF NOT EXISTS ilb_intervention_variable (
  variable_id CHAR(64) PRIMARY KEY,
  model_code VARCHAR(160) NOT NULL,
  domain_code VARCHAR(64) NOT NULL,
  measurement_method TEXT NULL,
  baseline_value DECIMAL(38,12) NULL,
  decision_value DECIMAL(38,12) NULL,
  lower_bound DECIMAL(38,12) NULL,
  upper_bound DECIMAL(38,12) NULL,
  burden_weight DECIMAL(38,12) NULL,
  release_status ENUM('INPUT_REQUIRED','READY','REJECTED') NOT NULL DEFAULT 'INPUT_REQUIRED',
  CONSTRAINT fk_intervention_variable_definition FOREIGN KEY (variable_id) REFERENCES ilb_variable_definition(variable_id),
  CHECK (lower_bound IS NULL OR upper_bound IS NULL OR lower_bound <= upper_bound)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_transfer_coefficient (
  transfer_id CHAR(64) PRIMARY KEY,
  model_code VARCHAR(160) NOT NULL,
  source_variable_id CHAR(64) NOT NULL,
  target_variable_id CHAR(64) NOT NULL,
  coefficient_value DECIMAL(38,12) NULL,
  coefficient_unit VARCHAR(128) NULL,
  direction ENUM('POSITIVE','NEGATIVE','ZERO','UNKNOWN') NOT NULL DEFAULT 'UNKNOWN',
  source_status ENUM('MISSING','HYPOTHESIS','MEASURED','VALIDATED','REJECTED') NOT NULL DEFAULT 'MISSING',
  version_no INT UNSIGNED NOT NULL DEFAULT 1,
  UNIQUE KEY uq_transfer_version (model_code,source_variable_id,target_variable_id,version_no),
  CONSTRAINT fk_transfer_source FOREIGN KEY (source_variable_id) REFERENCES ilb_variable_definition(variable_id),
  CONSTRAINT fk_transfer_target FOREIGN KEY (target_variable_id) REFERENCES ilb_variable_definition(variable_id),
  CHECK ((source_status='MISSING' AND coefficient_value IS NULL) OR source_status<>'MISSING')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

SET @batch='PSO-V4-20260906-STRUCTURE-000000001';
SET @run='4e724190-9e85-4a78-bb9e-bdbd4a8db54e';
SET @report='e5a8bfc0-7da0-438c-9aad-ec82d925754f';

INSERT INTO ilb_semantic_entity(entity_id,type_code,canonical_code,preferred_label,definition,lifecycle_status,source_batch_id)
VALUES (SHA2('PSO:DISEASE',256),'DISEASE','ILMB:PSORIASIS','Psoriasis','Disease model context for the workbook v4 coupled mathematics engine.','STAGED',@batch)
ON DUPLICATE KEY UPDATE definition=VALUES(definition),lifecycle_status='STAGED',source_batch_id=VALUES(source_batch_id);

INSERT INTO ilb_field_mapping(system_id,sheet_name_pattern,source_field,semantic_role,target_type_code,required_flag,transform_rule,mapping_version,approval_status) VALUES
('PSO','V4_Lifestyle_Variables','Variable ID','VARIABLE','INTERVENTION',TRUE,JSON_OBJECT('blank','reject'),4,'APPROVED'),
('PSO','V4_Lifestyle_Variables','Decision value','VALUE','INTERVENTION',FALSE,JSON_OBJECT('blank','retain_null','never_zero_fill',TRUE),4,'APPROVED'),
('PSO','V4_Lifestyle_Variables','Unit','UNIT','INTERVENTION',TRUE,JSON_OBJECT('vocabulary','UCUM'),4,'APPROVED'),
('PSO','V4_Transfer_Matrix','Coefficient','VALUE','PATHWAY',FALSE,JSON_OBJECT('blank','unknown','zero_requires_evidence',TRUE),4,'APPROVED'),
('PSO','Math3_Equations','Differential equation','EQUATION','PATHWAY',TRUE,JSON_OBJECT('dimensional_gate','required'),4,'APPROVED'),
('PSO','Math3_State_Vector','State','VARIABLE','PATHWAY',TRUE,JSON_OBJECT('identity','symbol+model_version'),4,'APPROVED'),
('PSO','V4_Objective','Declared NRMSE tolerance','VALUE','OUTCOME',FALSE,JSON_OBJECT('blank','blocked'),4,'APPROVED')
ON DUPLICATE KEY UPDATE semantic_role=VALUES(semantic_role),transform_rule=VALUES(transform_rule),approval_status='APPROVED';

INSERT INTO ilb_variable_definition(variable_id,variable_code,label,quantity_kind,canonical_unit_code,value_domain) VALUES
(SHA2('PSO:STATE:D',256),'PSO_D','Upstream immune balance','model state','1','NUMBER'),
(SHA2('PSO:STATE:I23',256),'PSO_I23','IL-23 balance','model state','1','NUMBER'),
(SHA2('PSO:STATE:T17',256),'PSO_T17','Th17 activation','model state','1','NUMBER'),
(SHA2('PSO:STATE:ASC',256),'PSO_ASC','Subcutaneous drug depot','mass','mg','NUMBER'),
(SHA2('PSO:STATE:CIX',256),'PSO_CIX','Free ixekizumab concentration','substance concentration','pmol/L','NUMBER'),
(SHA2('PSO:STATE:X',256),'PSO_X','Drug-cytokine complex','substance concentration','pmol/L','NUMBER'),
(SHA2('PSO:STATE:L17',256),'PSO_L17','Free IL-17A','substance concentration','pmol/L','NUMBER'),
(SHA2('PSO:STATE:KP',256),'PSO_KP','Proliferating keratinocytes','cell density','cells/mm2','NUMBER'),
(SHA2('PSO:STATE:KD',256),'PSO_KD','Differentiating keratinocytes','cell density','cells/mm2','NUMBER'),
(SHA2('PSO:STATE:B',256),'PSO_B','Barrier injury','model state','1','NUMBER'),
(SHA2('PSO:STATE:P',256),'PSO_P','Plaque burden','plaque state','1','NUMBER'),
(SHA2('PSO:STATE:N',256),'PSO_N','Neurostress feedback','model state','1','NUMBER'),
(SHA2('PSO:STATE:M',256),'PSO_M','Metabolic drive','model state','1','NUMBER'),
(SHA2('PSO:INPUT:DOSE',256),'PSO_DOSE_IMPULSE','Dose impulse','dose event','mg','NUMBER'),
(SHA2('PSO:OUTCOME:EQ',256),'PSO_OUTCOME_EQUIVALENCE','Lifestyle-to-drug outcome equivalence','decision rule','1','BOOLEAN'),
(SHA2('PSO:QOL',256),'PSO_QOL_UNIVERSAL','Psoriasis quality-of-life projection','quality of life','1','NUMBER'),
(SHA2('PSO:NODE:STRESS',256),'PSO_uStress','Stress recovery control','control input','1','NUMBER'),
(SHA2('PSO:NODE:METABOLIC',256),'PSO_uMetabolic','Metabolic recovery control','control input','1','NUMBER'),
(SHA2('PSO:NODE:REPAIR',256),'PSO_uRepair','Barrier repair control','control input','1','NUMBER'),
(SHA2('PSO:NODE:D_SOURCE',256),'PSO_uD_source','Immune-source control','control input','1','NUMBER'),
(SHA2('PSO:NODE:IL23_SOURCE',256),'PSO_uIL23_source','IL-23 source control','control input','1','NUMBER'),
(SHA2('PSO:NODE:TH17',256),'PSO_uTh17_activation','Th17 activation control','control input','1','NUMBER'),
(SHA2('PSO:NODE:IL17_SOURCE',256),'PSO_uIL17_source','IL-17 source control','control input','1','NUMBER')
ON DUPLICATE KEY UPDATE label=VALUES(label),quantity_kind=VALUES(quantity_kind),canonical_unit_code=VALUES(canonical_unit_code),active=TRUE;

INSERT INTO ilb_variable_definition(variable_id,variable_code,label,quantity_kind,canonical_unit_code,value_domain) VALUES
(SHA2('PSO:Z001',256),'PSO_Z001','Energy intake','lifestyle decision','kcal/d','NUMBER'),
(SHA2('PSO:Z002',256),'PSO_Z002','Protein intake','lifestyle decision','g/d','NUMBER'),
(SHA2('PSO:Z003',256),'PSO_Z003','Digestible carbohydrate','lifestyle decision','g/d','NUMBER'),
(SHA2('PSO:Z004',256),'PSO_Z004','Total fat','lifestyle decision','g/d','NUMBER'),
(SHA2('PSO:Z005',256),'PSO_Z005','Dietary fibre','lifestyle decision','g/d','NUMBER'),
(SHA2('PSO:Z006',256),'PSO_Z006','EPA plus DHA','lifestyle decision','mg/d','NUMBER'),
(SHA2('PSO:Z007',256),'PSO_Z007','Vitamin D intake','lifestyle decision','ug/d','NUMBER'),
(SHA2('PSO:Z008',256),'PSO_Z008','Alcohol','lifestyle decision','g/d','NUMBER'),
(SHA2('PSO:Z009',256),'PSO_Z009','Meal timing regularity','lifestyle decision','1','NUMBER'),
(SHA2('PSO:Z010',256),'PSO_Z010','Sleep duration','lifestyle decision','h/night','NUMBER'),
(SHA2('PSO:Z011',256),'PSO_Z011','Sleep midpoint regularity','lifestyle decision','1','NUMBER'),
(SHA2('PSO:Z012',256),'PSO_Z012','Moderate activity','lifestyle decision','min/d','NUMBER'),
(SHA2('PSO:Z013',256),'PSO_Z013','Resistance activity','lifestyle decision','min/wk','NUMBER'),
(SHA2('PSO:Z014',256),'PSO_Z014','Sedentary time','lifestyle decision','h/d','NUMBER'),
(SHA2('PSO:Z015',256),'PSO_Z015','Skin-site UV effective dose','lifestyle decision','J/m2/d','NUMBER'),
(SHA2('PSO:Z016',256),'PSO_Z016','Emollient application','lifestyle decision','g/site/d','NUMBER'),
(SHA2('PSO:Z017',256),'PSO_Z017','Mechanical skin trauma','lifestyle decision','events/wk','NUMBER'),
(SHA2('PSO:Z018',256),'PSO_Z018','Perceived threat load','lifestyle decision','unit.h/d','NUMBER'),
(SHA2('PSO:Z019',256),'PSO_Z019','Recovery practice','lifestyle decision','min/d','NUMBER'),
(SHA2('PSO:Z020',256),'PSO_Z020','Conflict exposure','lifestyle decision','unit.h/wk','NUMBER'),
(SHA2('PSO:Z021',256),'PSO_Z021','Supportive connection','lifestyle decision','h/wk','NUMBER'),
(SHA2('PSO:Z022',256),'PSO_Z022','Pleasurable absorption','lifestyle decision','min/d','NUMBER'),
(SHA2('PSO:Z023',256),'PSO_Z023','Meaningful activity','lifestyle decision','min/d','NUMBER'),
(SHA2('PSO:Z024',256),'PSO_Z024','Workload strain','lifestyle decision','unit.h/wk','NUMBER'),
(SHA2('PSO:Z025',256),'PSO_Z025','Social isolation','lifestyle decision','h/d','NUMBER'),
(SHA2('PSO:Z026',256),'PSO_Z026','Smoking exposure','lifestyle decision','cigarettes/d','NUMBER')
ON DUPLICATE KEY UPDATE label=VALUES(label),canonical_unit_code=VALUES(canonical_unit_code),active=TRUE;

INSERT INTO ilb_intervention_variable(variable_id,model_code,domain_code,release_status)
SELECT variable_id,'PSO_COP_LIFESTYLE_V4',
CASE WHEN variable_code BETWEEN 'PSO_Z001' AND 'PSO_Z009' THEN 'NUTRITION'
     WHEN variable_code BETWEEN 'PSO_Z010' AND 'PSO_Z011' THEN 'SLEEP'
     WHEN variable_code BETWEEN 'PSO_Z012' AND 'PSO_Z014' THEN 'ACTIVITY'
     WHEN variable_code BETWEEN 'PSO_Z015' AND 'PSO_Z017' THEN 'SKIN_ENVIRONMENT'
     WHEN variable_code BETWEEN 'PSO_Z018' AND 'PSO_Z025' THEN 'PSYCHOSOCIAL'
     ELSE 'TOBACCO' END,'INPUT_REQUIRED'
FROM ilb_variable_definition WHERE variable_code BETWEEN 'PSO_Z001' AND 'PSO_Z026'
ON DUPLICATE KEY UPDATE release_status='INPUT_REQUIRED';

INSERT INTO ilb_transfer_coefficient(transfer_id,model_code,source_variable_id,target_variable_id,coefficient_value,direction,source_status,version_no)
SELECT SHA2(CONCAT('PSO:A:',s.variable_code,':',t.variable_code),256),'PSO_COP_LIFESTYLE_V4',s.variable_id,t.variable_id,NULL,'UNKNOWN','MISSING',1
FROM ilb_variable_definition s CROSS JOIN ilb_variable_definition t
WHERE s.variable_code BETWEEN 'PSO_Z001' AND 'PSO_Z026'
AND t.variable_code IN ('PSO_uStress','PSO_uMetabolic','PSO_uRepair','PSO_uD_source','PSO_uIL23_source','PSO_uTh17_activation','PSO_uIL17_source')
ON DUPLICATE KEY UPDATE coefficient_value=NULL,direction='UNKNOWN',source_status='MISSING';

INSERT INTO ilb_equation_definition(equation_id,equation_code,version_no,label,expression_language,expression_text,output_variable_id,evaluation_mode,time_basis_unit_code,source_status,approval_status) VALUES
(SHA2('PSO:M3-01',256),'PSO_M3_01',4,'Upstream immune balance','TEXT_ONLY','dD/dt = sD*(1-uD_source)+aBD*B+aND*N*(1-uStress)+aMD*M*(1-uMetabolic)-kD*D',SHA2('PSO:STATE:D',256),'ODE','d','HYPOTHESIS','DRAFT'),
(SHA2('PSO:M3-02',256),'PSO_M3_02',4,'IL-23 balance','TEXT_ONLY','dI23/dt = s23*(1-uIL23_source)+aD23*D-k23*I23',SHA2('PSO:STATE:I23',256),'ODE','d','HYPOTHESIS','DRAFT'),
(SHA2('PSO:M3-03',256),'PSO_M3_03',4,'Th17 activation','TEXT_ONLY','dT17/dt = sT+a23T*I23/(K23+I23)*(1-uTh17_activation)-kT*T17',SHA2('PSO:STATE:T17',256),'ODE','d','HYPOTHESIS','DRAFT'),
(SHA2('PSO:M3-04',256),'PSO_M3_04',4,'Subcutaneous depot','TEXT_ONLY','dAsc/dt = Dose_impulse(t)-ka*Asc',SHA2('PSO:STATE:ASC',256),'ODE','d','STRUCTURAL','DRAFT'),
(SHA2('PSO:M3-05',256),'PSO_M3_05',4,'Free ixekizumab','TEXT_ONLY','dCix/dt = ka*Fsc*Asc*10^9/(MWix*Vix)-kel*Cix-kon*Cix*L17+koff*X',SHA2('PSO:STATE:CIX',256),'ODE','d','HYPOTHESIS','DRAFT'),
(SHA2('PSO:M3-06',256),'PSO_M3_06',4,'Drug-cytokine complex','TEXT_ONLY','dX/dt = kon*Cix*L17-(koff+kint)*X',SHA2('PSO:STATE:X',256),'ODE','d','HYPOTHESIS','DRAFT'),
(SHA2('PSO:M3-07',256),'PSO_M3_07',4,'Free IL-17A','TEXT_ONLY','dL17/dt = s17*(1-uIL17_source)+aT17*T17-k17*L17-kon*Cix*L17+koff*X',SHA2('PSO:STATE:L17',256),'ODE','d','HYPOTHESIS','DRAFT'),
(SHA2('PSO:M3-08',256),'PSO_M3_08',4,'Proliferating keratinocytes','TEXT_ONLY','dKp/dt = sK+r17*L17/(K17+L17)*Kp-(kdiff+kdeath)*Kp',SHA2('PSO:STATE:KP',256),'ODE','d','HYPOTHESIS','DRAFT'),
(SHA2('PSO:M3-09',256),'PSO_M3_09',4,'Keratinocyte differentiation','TEXT_ONLY','dKd/dt = kdiff*Kp-kmat*Kd',SHA2('PSO:STATE:KD',256),'ODE','d','HYPOTHESIS','DRAFT'),
(SHA2('PSO:M3-10',256),'PSO_M3_10',4,'Barrier injury and repair','TEXT_ONLY','dB/dt = aKB*Kp+aLB*L17-krepair*(1+uRepair)*B',SHA2('PSO:STATE:B',256),'ODE','d','HYPOTHESIS','DRAFT'),
(SHA2('PSO:M3-11',256),'PSO_M3_11',4,'Plaque burden','TEXT_ONLY','dP/dt = aKP*Kp+aBP*B-kclear*P',SHA2('PSO:STATE:P',256),'ODE','d','HYPOTHESIS','DRAFT'),
(SHA2('PSO:M3-12',256),'PSO_M3_12',4,'Neurostress feedback','TEXT_ONLY','dN/dt = aPN*P-kN*(1+uStress)*N',SHA2('PSO:STATE:N',256),'ODE','d','HYPOTHESIS','DRAFT'),
(SHA2('PSO:M3-13',256),'PSO_M3_13',4,'Metabolic drive','TEXT_ONLY','dM/dt = -kM*(1+uMetabolic)*M',SHA2('PSO:STATE:M',256),'ODE','d','HYPOTHESIS','DRAFT'),
(SHA2('PSO:M3-14',256),'PSO_M3_14',4,'Plaque regression condition','TEXT_ONLY','dP/dt<0 iff kclear*P>aKP*Kp+aBP*B',SHA2('PSO:STATE:P',256),'RULE',NULL,'STRUCTURAL','DRAFT'),
(SHA2('PSO:M3-15',256),'PSO_M3_15',4,'Outcome equivalence rule','TEXT_ONLY','P_L(T)<=P_D(T) AND AUC_P_L<=AUC_P_D AND Safety_L=PASS',SHA2('PSO:OUTCOME:EQ',256),'RULE',NULL,'STRUCTURAL','DRAFT')
ON DUPLICATE KEY UPDATE expression_text=VALUES(expression_text),source_status=VALUES(source_status),approval_status='DRAFT';

INSERT INTO ilb_equation_dependency(equation_id,input_variable_id,dependency_order,required_flag)
SELECT SHA2('PSO:M3-01',256),variable_id,ROW_NUMBER() OVER (ORDER BY variable_code),TRUE FROM ilb_variable_definition WHERE variable_code IN ('PSO_B','PSO_N','PSO_M','PSO_uStress','PSO_uMetabolic','PSO_uD_source')
ON DUPLICATE KEY UPDATE required_flag=TRUE;
INSERT INTO ilb_equation_dependency VALUES
(SHA2('PSO:M3-02',256),SHA2('PSO:STATE:D',256),1,TRUE,0),(SHA2('PSO:M3-02',256),SHA2('PSO:NODE:IL23_SOURCE',256),2,TRUE,0),
(SHA2('PSO:M3-03',256),SHA2('PSO:STATE:I23',256),1,TRUE,0),(SHA2('PSO:M3-03',256),SHA2('PSO:NODE:TH17',256),2,TRUE,0),
(SHA2('PSO:M3-04',256),SHA2('PSO:INPUT:DOSE',256),1,TRUE,0),
(SHA2('PSO:M3-05',256),SHA2('PSO:STATE:ASC',256),1,TRUE,0),(SHA2('PSO:M3-05',256),SHA2('PSO:STATE:L17',256),2,TRUE,0),(SHA2('PSO:M3-05',256),SHA2('PSO:STATE:X',256),3,TRUE,0),
(SHA2('PSO:M3-06',256),SHA2('PSO:STATE:CIX',256),1,TRUE,0),(SHA2('PSO:M3-06',256),SHA2('PSO:STATE:L17',256),2,TRUE,0),
(SHA2('PSO:M3-07',256),SHA2('PSO:STATE:T17',256),1,TRUE,0),(SHA2('PSO:M3-07',256),SHA2('PSO:STATE:CIX',256),2,TRUE,0),(SHA2('PSO:M3-07',256),SHA2('PSO:NODE:IL17_SOURCE',256),3,TRUE,0),
(SHA2('PSO:M3-08',256),SHA2('PSO:STATE:L17',256),1,TRUE,0),(SHA2('PSO:M3-09',256),SHA2('PSO:STATE:KP',256),1,TRUE,0),
(SHA2('PSO:M3-10',256),SHA2('PSO:STATE:KP',256),1,TRUE,0),(SHA2('PSO:M3-10',256),SHA2('PSO:STATE:L17',256),2,TRUE,0),(SHA2('PSO:M3-10',256),SHA2('PSO:NODE:REPAIR',256),3,TRUE,0),
(SHA2('PSO:M3-11',256),SHA2('PSO:STATE:KP',256),1,TRUE,0),(SHA2('PSO:M3-11',256),SHA2('PSO:STATE:B',256),2,TRUE,0),
(SHA2('PSO:M3-12',256),SHA2('PSO:STATE:P',256),1,TRUE,0),(SHA2('PSO:M3-12',256),SHA2('PSO:NODE:STRESS',256),2,TRUE,0),
(SHA2('PSO:M3-13',256),SHA2('PSO:NODE:METABOLIC',256),1,TRUE,0),
(SHA2('PSO:M3-14',256),SHA2('PSO:STATE:P',256),1,TRUE,0),(SHA2('PSO:M3-15',256),SHA2('PSO:STATE:P',256),1,TRUE,0)
ON DUPLICATE KEY UPDATE required_flag=VALUES(required_flag),lag_seconds=0;

INSERT INTO ilb_equation_gate(gate_id,equation_id,gate_code,gate_status,reason_text,checked_at)
SELECT SHA2(CONCAT(e.equation_code,':PARAMETERS'),256),e.equation_id,'PARAMETERS_PRESENT','BLOCKED','Workbook v4 retains unknown patient/model parameters as NULL.',CURRENT_TIMESTAMP(6)
FROM ilb_equation_definition e WHERE e.equation_code LIKE 'PSO_M3_%'
ON DUPLICATE KEY UPDATE gate_status='BLOCKED',reason_text=VALUES(reason_text),checked_at=VALUES(checked_at);

-- Entity rows required by the relation graph; kept staged and unverified.
INSERT INTO ilb_semantic_entity(entity_id,type_code,canonical_code,preferred_label,lifecycle_status,source_batch_id)
SELECT SHA2(CONCAT('PSO:ENTITY:',variable_code),256),
CASE variable_code WHEN 'PSO_I23' THEN 'MOLECULE' WHEN 'PSO_L17' THEN 'MOLECULE' WHEN 'PSO_T17' THEN 'CELL' WHEN 'PSO_KP' THEN 'CELL' ELSE 'PATHWAY' END,
CONCAT('ILMB:',variable_code),label,'STAGED',@batch
FROM ilb_variable_definition WHERE variable_code IN ('PSO_D','PSO_I23','PSO_T17','PSO_L17','PSO_KP','PSO_B','PSO_P')
ON DUPLICATE KEY UPDATE preferred_label=VALUES(preferred_label),lifecycle_status='STAGED';

-- Re-run relation insert after entity upsert for clean installations.
INSERT INTO ilb_entity_relation(relation_id,source_entity_id,relation_code,target_entity_id,assertion_status,verification_status,source_batch_id)
SELECT SHA2(CONCAT('PSO:REL:',variable_code),256),SHA2(CONCAT('PSO:ENTITY:',variable_code),256),'PARTICIPATES_IN',SHA2('PSO:DISEASE',256),'HYPOTHESIS','PENDING',@batch
FROM ilb_variable_definition WHERE variable_code IN ('PSO_D','PSO_I23','PSO_T17','PSO_L17','PSO_KP','PSO_B','PSO_P')
ON DUPLICATE KEY UPDATE assertion_status='HYPOTHESIS',verification_status='PENDING';

INSERT INTO ilb_projection_run(projection_run_id,source_batch_id,mapping_version,status,staged_rows,projected_entities,projected_relations,error_count,completed_at)
VALUES (@run,@batch,4,'BLOCKED',247,8,7,182,CURRENT_TIMESTAMP(6))
ON DUPLICATE KEY UPDATE status='BLOCKED',staged_rows=247,projected_entities=8,projected_relations=7,error_count=182,completed_at=CURRENT_TIMESTAMP(6);

INSERT INTO ilb_calculation_run(calculation_run_id,subject_key,model_code,model_version,status,input_hash,engine_version,completed_at)
VALUES ('79bcd4f4-69e3-40bb-95e5-63795e90545e',NULL,'PSO_COP_LIFESTYLE_V4',4,'BLOCKED',SHA2('MISSING_PATIENT_INPUTS_AND_182_COEFFICIENTS',256),'ILMB_EXPR_V1',CURRENT_TIMESTAMP(6))
ON DUPLICATE KEY UPDATE status='BLOCKED',completed_at=CURRENT_TIMESTAMP(6);

INSERT INTO ilb_hospital_report(report_id,subject_key,report_version,report_status,quality_of_life_variable_id,quality_of_life_value,generated_by)
VALUES (@report,'MODEL:PSO_COP_LIFESTYLE_V4',4,'BLOCKED',SHA2('PSO:QOL',256),NULL,'ILMB phase 102 structural projection')
ON DUPLICATE KEY UPDATE report_status='BLOCKED',quality_of_life_value=NULL,generated_by=VALUES(generated_by);
INSERT INTO ilb_hospital_report_section(report_id,section_code,display_order,section_status,payload_json,calculation_run_id) VALUES
(@report,'MODEL_SCOPE',1,'READY',JSON_OBJECT('claim','Architecture imported; no treatment equivalence asserted','states',13,'equations',15),'79bcd4f4-69e3-40bb-95e5-63795e90545e'),
(@report,'PATIENT_INPUTS',2,'BLOCKED',JSON_OBJECT('missing','baseline, bounds, decision values, observations and prescribed dose confirmation'),'79bcd4f4-69e3-40bb-95e5-63795e90545e'),
(@report,'TRANSFER_MATRIX',3,'BLOCKED',JSON_OBJECT('required',182,'available',0,'blank_rule','unknown, never zero'),'79bcd4f4-69e3-40bb-95e5-63795e90545e'),
(@report,'TREATMENT_COMPARISON',4,'BLOCKED',JSON_OBJECT('rule','NRMSE tolerance plus plaque final/AUC plus separate safety pass'),'79bcd4f4-69e3-40bb-95e5-63795e90545e'),
(@report,'QUALITY_OF_LIFE',5,'BLOCKED',JSON_OBJECT('value',NULL,'reason','patient-reported and clinical outcome inputs absent'),'79bcd4f4-69e3-40bb-95e5-63795e90545e')
ON DUPLICATE KEY UPDATE section_status=VALUES(section_status),payload_json=VALUES(payload_json),calculation_run_id=VALUES(calculation_run_id);
INSERT INTO ilb_hospital_report_gate(report_id,gate_code,gate_status,reason_text) VALUES
(@report,'CLINICIAN_REVIEW','BLOCKED','No patient-specific output may be released before clinician review.'),
(@report,'PATIENT_INPUTS','BLOCKED','No person observations or prescribed dose schedule are present.'),
(@report,'TRANSFER_COMPLETE','BLOCKED','All 182 transfer coefficients are missing.'),
(@report,'SAFETY_COMPLETE','BLOCKED','Lifestyle and medicine harms require separate populated models.'),
(@report,'EQUIVALENCE_SOLVED','BLOCKED','Equivalence is a result to calculate, not an assumption.')
ON DUPLICATE KEY UPDATE gate_status=VALUES(gate_status),reason_text=VALUES(reason_text),checked_at=CURRENT_TIMESTAMP(6);

CREATE OR REPLACE VIEW v_ilb_psoriasis_solver_readiness AS
SELECT
 (SELECT COUNT(*) FROM ilb_intervention_variable WHERE model_code='PSO_COP_LIFESTYLE_V4') lifestyle_variables,
 (SELECT COUNT(*) FROM ilb_transfer_coefficient WHERE model_code='PSO_COP_LIFESTYLE_V4') transfer_slots,
 (SELECT SUM(coefficient_value IS NULL) FROM ilb_transfer_coefficient WHERE model_code='PSO_COP_LIFESTYLE_V4') missing_coefficients,
 (SELECT COUNT(*) FROM ilb_equation_definition WHERE equation_code LIKE 'PSO_M3_%') equations,
 (SELECT SUM(gate_status<>'PASS') FROM ilb_equation_gate g JOIN ilb_equation_definition e ON e.equation_id=g.equation_id WHERE e.equation_code LIKE 'PSO_M3_%') blocking_equation_gates,
 CASE WHEN
   (SELECT COUNT(*) FROM ilb_transfer_coefficient WHERE model_code='PSO_COP_LIFESTYLE_V4' AND coefficient_value IS NULL)=0
   AND (SELECT COUNT(*) FROM ilb_intervention_variable WHERE model_code='PSO_COP_LIFESTYLE_V4' AND (baseline_value IS NULL OR decision_value IS NULL))=0
 THEN 'READY_TO_VALIDATE' ELSE 'BLOCKED_INPUTS_AND_COEFFICIENTS' END readiness_status;
