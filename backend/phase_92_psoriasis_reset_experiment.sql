-- Phase 92: non-patient psoriasis reset experiment specification.
START TRANSACTION;
CREATE TABLE IF NOT EXISTS ilb_psoriasis_experiment (
 experiment_key varchar(80) NOT NULL,
 title varchar(255) NOT NULL,
 biological_system varchar(255) NOT NULL,
 objective text NOT NULL,
 status enum('DESIGN_READY_WETLAB_PENDING','RUNNING','COMPLETE') NOT NULL,
 patient_experiment tinyint(1) NOT NULL DEFAULT 0,
 PRIMARY KEY(experiment_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE IF NOT EXISTS ilb_psoriasis_experiment_arm (
 experiment_key varchar(80) NOT NULL,
 arm_key varchar(80) NOT NULL,
 arm_order tinyint unsigned NOT NULL,
 arm_name varchar(160) NOT NULL,
 intervention_class varchar(160) NULL,
 purpose text NOT NULL,
 source_bound_dose_required tinyint(1) NOT NULL DEFAULT 1,
 PRIMARY KEY(experiment_key,arm_key),
 CONSTRAINT fk_p92_arm_experiment FOREIGN KEY(experiment_key) REFERENCES ilb_psoriasis_experiment(experiment_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE IF NOT EXISTS ilb_psoriasis_experiment_stage (
 experiment_key varchar(80) NOT NULL,
 stage_key varchar(80) NOT NULL,
 stage_order tinyint unsigned NOT NULL,
 stage_name varchar(120) NOT NULL,
 entry_condition text NOT NULL,
 exit_condition text NOT NULL,
 duration_source_required tinyint(1) NOT NULL DEFAULT 1,
 PRIMARY KEY(experiment_key,stage_key),
 CONSTRAINT fk_p92_stage_experiment FOREIGN KEY(experiment_key) REFERENCES ilb_psoriasis_experiment(experiment_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE IF NOT EXISTS ilb_psoriasis_experiment_formula (
 formula_key varchar(80) NOT NULL,
 experiment_key varchar(80) NOT NULL,
 formula_latex text NOT NULL,
 definition text NOT NULL,
 invented_coefficient_count int unsigned NOT NULL DEFAULT 0,
 computation_ready tinyint(1) NOT NULL DEFAULT 1,
 PRIMARY KEY(formula_key),
 CONSTRAINT fk_p92_formula_experiment FOREIGN KEY(experiment_key) REFERENCES ilb_psoriasis_experiment(experiment_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO ilb_psoriasis_experiment VALUES
('EXP_PSO_RESET_001','Psoriasis state correction, withdrawal and rechallenge','T-cell-enriched full-thickness 3D psoriatic skin equivalent','Determine whether pathway interruption merely suppresses the phenotype or changes the model ability to recreate psoriasis after complete washout and matched rechallenge.','DESIGN_READY_WETLAB_PENDING',0)
ON DUPLICATE KEY UPDATE title=VALUES(title),biological_system=VALUES(biological_system),objective=VALUES(objective),status=VALUES(status),patient_experiment=VALUES(patient_experiment);
INSERT INTO ilb_psoriasis_experiment_arm VALUES
('EXP_PSO_RESET_001','A_HEALTHY',1,'Healthy matched control',NULL,'Defines H_j(t), the simultaneous healthy-control state.',0),
('EXP_PSO_RESET_001','B_PSORIATIC',2,'Untreated psoriatic control',NULL,'Defines P_j(t), the simultaneous psoriatic-control state.',0),
('EXP_PSO_RESET_001','C_IL17',3,'IL-17 pathway interruption','IL-17','Downstream pathway comparator.',1),
('EXP_PSO_RESET_001','D_IL23',4,'IL-23 pathway interruption','IL-23','Upstream pathway candidate with five-state directional human evidence.',1),
('EXP_PSO_RESET_001','E_BARRIER',5,'Barrier-directed candidate','BARRIER','Tests functional barrier correction without assuming immune-memory correction.',1),
('EXP_PSO_RESET_001','F_COMBINATION',6,'IL-23 plus barrier-directed candidate','IL-23+BARRIER','Tests combined five-state correction and durability.',1)
ON DUPLICATE KEY UPDATE arm_order=VALUES(arm_order),arm_name=VALUES(arm_name),intervention_class=VALUES(intervention_class),purpose=VALUES(purpose),source_bound_dose_required=VALUES(source_bound_dose_required);
INSERT INTO ilb_psoriasis_experiment_stage VALUES
('EXP_PSO_RESET_001','S1_INDUCTION',1,'Phenotype induction','Matched 3D tissues pass quality control.','P,D,B,I phenotype differs reproducibly from healthy control using preregistered assays.',1),
('EXP_PSO_RESET_001','S2_INTERVENTION',2,'State correction','Psoriatic phenotype established.','All scheduled on-treatment measurements completed.',1),
('EXP_PSO_RESET_001','S3_WASHOUT',3,'Complete intervention washout','Intervention stage complete.','Analytical assay confirms intervention below its validated detection limit.',1),
('EXP_PSO_RESET_001','S4_RENEWAL',4,'Intervention-free epidermal renewal','Washout confirmed.','Prespecified renewal observation window complete.',1),
('EXP_PSO_RESET_001','S5_RECHALLENGE',5,'Matched inflammatory rechallenge','Intervention-free renewal complete.','All post-rechallenge measurements completed.',1)
ON DUPLICATE KEY UPDATE stage_order=VALUES(stage_order),stage_name=VALUES(stage_name),entry_condition=VALUES(entry_condition),exit_condition=VALUES(exit_condition),duration_source_required=VALUES(duration_source_required);
INSERT INTO ilb_psoriasis_experiment_formula VALUES
('F_NORMALISE','EXP_PSO_RESET_001','N_{a,j,t}=(X_{a,j,t}-H_{j,t})/(P_{j,t}-H_{j,t})','Dimensionless within-run normalization of arm a and state j against simultaneous healthy H and psoriatic P controls.',0,1),
('F_WITHDRAWAL_CHANGE','EXP_PSO_RESET_001','W_{a,j}=N_{a,j,postwashout}-N_{a,j,endtreatment}','State change after removal of the intervention.',0,1),
('F_RECHALLENGE_CHANGE','EXP_PSO_RESET_001','C_{a,j}=N_{a,j,postrechallenge}-N_{a,j,prerechallenge}','State change caused by matched rechallenge.',0,1),
('F_DENOMINATOR_GATE','EXP_PSO_RESET_001','P_{j,t}-H_{j,t}\\neq0','The normalization is invalid when the experimental disease control does not differ from the healthy control for state j.',0,1)
ON DUPLICATE KEY UPDATE experiment_key=VALUES(experiment_key),formula_latex=VALUES(formula_latex),definition=VALUES(definition),invented_coefficient_count=VALUES(invented_coefficient_count),computation_ready=VALUES(computation_ready);
COMMIT;
