-- Phase 97: final published evidence for IL-23 potency, drug detection and precision.
START TRANSACTION;

INSERT INTO ilb_psoriasis_published_parameter_candidate VALUES
('P97_IL23_RZB_IC80','IL23_BLOCK_CONCENTRATION','Risankizumab human whole-blood IL-23 pSTAT3 IC80',12,'pM','80% inhibition concentration with IL-23 stimulation at 1 ng/mL','PMCID:PMC8409790','https://pmc.ncbi.nlm.nih.gov/articles/PMC8409790/','Human whole-blood CD45+ CD161-high pSTAT3 assay','NOT_COMPATIBLE',1,0,'Exact human-cell potency benchmark, but not a concentration validated in the selected T-cell-enriched 3D skin model.'),
('P97_IL23_GUS_IC80','IL23_BLOCK_CONCENTRATION','Guselkumab human whole-blood IL-23 pSTAT3 IC80',20,'pM','80% inhibition concentration with IL-23 stimulation at 1 ng/mL','PMCID:PMC8409790','https://pmc.ncbi.nlm.nih.gov/articles/PMC8409790/','Human whole-blood CD45+ CD161-high pSTAT3 assay','NOT_COMPATIBLE',1,0,'Exact human-cell potency benchmark, but not a concentration validated in the selected T-cell-enriched 3D skin model.'),
('P97_WASHOUT_RZB_ELISA','WASHOUT_DETECTION_ASSAY','Validated free-risankizumab ELISA','5','ng/mL','Polyclonal anti-risankizumab capture and biotinylated anti-risankizumab idiotype detection; nominal range 5-100 ng/mL','PMCID:PMC6852105','https://pmc.ncbi.nlm.nih.gov/articles/PMC6852105/','Validated plasma ELISA','NOT_COMPATIBLE',1,0,'The analytical principle and range are published, but matrix validation is required before use with 3D-skin culture medium.'),
('P97_WASHOUT_RZB_LLOQ','WASHOUT_DETECTION_LIMIT','Risankizumab ELISA lower limit of quantification',5,'ng/mL','Inter-run precision no greater than 5% across studies','PMCID:PMC6852105','https://pmc.ncbi.nlm.nih.gov/articles/PMC6852105/','Validated plasma ELISA','NOT_COMPATIBLE',1,0,'Exact published LLOQ for plasma; it cannot be declared as the culture-matrix LLOQ without a matrix bridge.'),
('P97_WASHOUT_GUS_ELISA_RANGE','WASHOUT_DETECTION_ASSAY','Guselkumab-specific ELISA calibration range lower bound',0.08,'ng/mL','Published dose-response calibration range 0.08-5 ng/mL','DOI:10.1016/j.jpba.2020.113719','https://doi.org/10.1016/j.jpba.2020.113719','Validated guselkumab immunoassay','NOT_COMPATIBLE',1,0,'Published drug-specific analytical method; the source matrix and selected culture matrix require compatibility verification.'),
('P97_PASS_TOLERANCE_FACT','PASS_TOLERANCE','Equivalence margin is assay- and state-specific',NULL,NULL,'No universal psoriasis equivalence margin was reported; p-value non-significance is not an equivalence margin','ICH:Q2(R2)','https://database.ich.org/sites/default/files/ICH_Q2%28R2%29_Guideline_2023_1130.pdf','Analytical-procedure validation framework','NOT_COMPATIBLE',1,0,'This parameter is not a discoverable biological constant. It must be locked from the chosen assay performance and control repeatability before outcome analysis.')
ON DUPLICATE KEY UPDATE parameter_key=VALUES(parameter_key),candidate_name=VALUES(candidate_name),numeric_value=VALUES(numeric_value),unit=VALUES(unit),text_value=VALUES(text_value),source_id=VALUES(source_id),source_url=VALUES(source_url),source_model=VALUES(source_model),compatibility=VALUES(compatibility),exact_in_source=VALUES(exact_in_source),promotion_allowed=VALUES(promotion_allowed),reason=VALUES(reason);

CREATE TABLE IF NOT EXISTS ilb_psoriasis_parameter_completion_gate (
 parameter_key varchar(100) NOT NULL,
 published_candidate_count int unsigned NOT NULL,
 exact_numeric_candidate_count int unsigned NOT NULL,
 same_model_candidate_count int unsigned NOT NULL,
 gate_state enum('PROMOTABLE','BRIDGE_REQUIRED','DATA_REQUIRED') NOT NULL,
 gate_reason text NOT NULL,
 PRIMARY KEY(parameter_key),
 CONSTRAINT fk_p97_gate_parameter FOREIGN KEY(parameter_key)
  REFERENCES ilb_psoriasis_experiment_parameter(parameter_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO ilb_psoriasis_parameter_completion_gate
SELECT p.parameter_key,
       COUNT(c.candidate_key),
       SUM(c.numeric_value IS NOT NULL),
       SUM(c.compatibility='SAME_MODEL'),
       CASE
        WHEN SUM(c.compatibility='SAME_MODEL' AND c.promotion_allowed=1)>0 THEN 'PROMOTABLE'
        WHEN p.parameter_key='PASS_TOLERANCE' THEN 'DATA_REQUIRED'
        WHEN COUNT(c.candidate_key)>0 THEN 'BRIDGE_REQUIRED'
        ELSE 'DATA_REQUIRED'
       END,
       CASE
        WHEN SUM(c.compatibility='SAME_MODEL' AND c.promotion_allowed=1)>0 THEN 'At least one same-model approved value exists.'
        WHEN p.parameter_key='PASS_TOLERANCE' THEN 'Published guidance establishes that the equivalence margin must come from the selected assay and control data; no universal numeric value exists.'
        WHEN COUNT(c.candidate_key)>0 THEN 'Published evidence exists, but model, matrix or experimental-stage compatibility prevents automatic promotion.'
        ELSE 'No published candidate registered.'
       END
FROM ilb_psoriasis_experiment_parameter p
LEFT JOIN ilb_psoriasis_published_parameter_candidate c ON c.parameter_key=p.parameter_key
WHERE p.experiment_key='EXP_PSO_RESET_001' AND p.resolution='UNRESOLVED'
GROUP BY p.parameter_key
ON DUPLICATE KEY UPDATE published_candidate_count=VALUES(published_candidate_count),exact_numeric_candidate_count=VALUES(exact_numeric_candidate_count),same_model_candidate_count=VALUES(same_model_candidate_count),gate_state=VALUES(gate_state),gate_reason=VALUES(gate_reason);

COMMIT;
