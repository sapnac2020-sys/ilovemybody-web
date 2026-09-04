-- Phase 86: remove the plaque/trigger symbol collision and register the drug-free reset path.
START TRANSACTION;
CREATE TABLE IF NOT EXISTS ilb_psoriasis_reset_condition (
 condition_order smallint unsigned NOT NULL,
 condition_key varchar(80) NOT NULL,
 mathematical_condition text NOT NULL,
 biological_meaning text NOT NULL,
 evidence_state enum('STRUCTURAL_IDENTITY','OBSERVATIONS_REQUIRED','PARAMETERS_REQUIRED','VALIDATION_REQUIRED') NOT NULL,
 computation_eligible tinyint(1) NOT NULL DEFAULT 0,
 patient_use_allowed tinyint(1) NOT NULL DEFAULT 0,
 PRIMARY KEY(condition_key),
 UNIQUE KEY uq_p86_order(condition_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

UPDATE ilb_psoriasis_formula_registry SET lhs='dR/dt',rhs='f_R(IL23,B_plaque)-mu_R*R' WHERE formula_key='F_MEMORY_TRM';
UPDATE ilb_psoriasis_formula_registry SET lhs='dE/dt',rhs='f_E(IL17,TNF,B_plaque)-mu_E*E' WHERE formula_key='F_MEMORY_KC';
UPDATE ilb_psoriasis_formula_registry SET lhs='dF/dt',rhs='f_F(IL17,IL23,B_plaque)-mu_F*F' WHERE formula_key='F_MEMORY_STROMA';
UPDATE ilb_psoriasis_formula_registry SET lhs='dL/dt',rhs='S_persistent+f_L(E,F)-mu_L*L' WHERE formula_key='F_MEMORY_TRIGGER';
UPDATE ilb_psoriasis_persistence_state SET symbol='R',state_equation='dR/dt=f_R(IL23,B_plaque)-mu_R*R' WHERE state_key='TRM17';
UPDATE ilb_psoriasis_persistence_state SET symbol='E',state_equation='dE/dt=f_E(IL17,TNF,B_plaque)-mu_E*E' WHERE state_key='KC_EPIGENETIC';
UPDATE ilb_psoriasis_persistence_state SET symbol='F',state_equation='dF/dt=f_F(IL17,IL23,B_plaque)-mu_F*F' WHERE state_key='STROMAL';
UPDATE ilb_psoriasis_persistence_state SET symbol='L',state_equation='dL/dt=S_persistent+f_L(E,F)-mu_L*L' WHERE state_key='LOCAL_TRIGGER';

INSERT INTO ilb_psoriasis_formula_registry(formula_key,layer,lhs,rhs,formula_role,provenance,numerical_status,source_key,patient_use_allowed) VALUES
('F_DRUG_FREE_RESET','DECISION','Reset_H','Dose(t)=0 for t>=t_w AND lim(C_c,C_p,X_j)=0 AND lim z(t)=z_H AND max_i Re(lambda_i(J_H))<0','A reset exists only where the healthy state persists after complete pharmacological washout.','DECISION_IDENTITY','OBSERVATIONS_REQUIRED',NULL,0)
ON DUPLICATE KEY UPDATE lhs=VALUES(lhs),rhs=VALUES(rhs),formula_role=VALUES(formula_role),provenance=VALUES(provenance),numerical_status=VALUES(numerical_status),patient_use_allowed=VALUES(patient_use_allowed);

INSERT INTO ilb_psoriasis_reset_condition VALUES
(1,'NO_ONGOING_DOSE','Dose(t)=0 for every t>=t_w','No continuing pharmaceutical input after the declared washout start.','STRUCTURAL_IDENTITY',1,0),
(2,'NO_RESIDUAL_DRUG','lim_{t->infinity} C_c(t)=0 AND lim_{t->infinity} C_p(t)=0','Central and peripheral drug exposure disappear.','PARAMETERS_REQUIRED',0,0),
(3,'NO_RESIDUAL_COMPLEX','lim_{t->infinity} X_j(t)=0','No continuing drug-target complex explains the response.','PARAMETERS_REQUIRED',0,0),
(4,'PLAQUE_RESOLUTION','dB_plaque/dt<0 while B_plaque>B_healthy','Visible pathological formation remains below resolution until the healthy burden is reached.','OBSERVATIONS_REQUIRED',0,0),
(5,'MEMORY_RESOLUTION','dR/dt<0 AND dE/dt<0 AND dF/dt<0 AND dL/dt<0 while each state exceeds its healthy equilibrium','Every registered relapse reservoir resolves rather than silently persisting.','PARAMETERS_REQUIRED',0,0),
(6,'HEALTHY_EQUILIBRIUM','F(z_H,0,theta)=0','The complete drug-free system has a declared healthy equilibrium.','PARAMETERS_REQUIRED',0,0),
(7,'HEALTHY_STABILITY','max_i Re(lambda_i(dF/dz at z_H))<0','After a small perturbation, the drug-free system returns toward the healthy equilibrium.','VALIDATION_REQUIRED',0,0)
ON DUPLICATE KEY UPDATE condition_order=VALUES(condition_order),mathematical_condition=VALUES(mathematical_condition),biological_meaning=VALUES(biological_meaning),evidence_state=VALUES(evidence_state),computation_eligible=VALUES(computation_eligible),patient_use_allowed=VALUES(patient_use_allowed);
COMMIT;
