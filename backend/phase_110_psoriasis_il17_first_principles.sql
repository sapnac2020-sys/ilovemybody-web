-- Phase 110: Psoriasis IL-17 First-Principles Subsystem
-- Rule: derive -> predict -> verify. No fitted psoriasis-specific constants are introduced here.
-- Scope: IL-17 production/clearance, transport, receptor binding, receptor occupancy,
-- downstream keratinocyte signalling interface, and derivation-tree governance.

CREATE TABLE IF NOT EXISTS ilb_psoriasis_fp_equation (
  equation_id VARCHAR(64) PRIMARY KEY,
  equation_code VARCHAR(64) NOT NULL UNIQUE,
  layer_name VARCHAR(64) NOT NULL,
  equation_text TEXT NOT NULL,
  law_class VARCHAR(64) NOT NULL,
  status VARCHAR(32) NOT NULL,
  interpretation_text TEXT NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_psoriasis_fp_primitive (
  primitive_id VARCHAR(64) PRIMARY KEY,
  symbol VARCHAR(64) NOT NULL,
  quantity_name VARCHAR(160) NOT NULL,
  unit_text VARCHAR(64) NOT NULL,
  value_num DECIMAL(30,12) NULL,
  value_text VARCHAR(255) NULL,
  source_status VARCHAR(32) NOT NULL,
  context_requirement TEXT NOT NULL,
  source_note TEXT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_fp_primitive_symbol_context (symbol,quantity_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_psoriasis_fp_dependency (
  dependency_id VARCHAR(64) PRIMARY KEY,
  equation_id VARCHAR(64) NOT NULL,
  primitive_id VARCHAR(64) NOT NULL,
  dependency_role VARCHAR(64) NOT NULL,
  required_for_numeric_prediction TINYINT(1) NOT NULL DEFAULT 1,
  FOREIGN KEY (equation_id) REFERENCES ilb_psoriasis_fp_equation(equation_id),
  FOREIGN KEY (primitive_id) REFERENCES ilb_psoriasis_fp_primitive(primitive_id),
  UNIQUE KEY uq_fp_dep (equation_id,primitive_id,dependency_role)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO ilb_psoriasis_fp_equation
(equation_id,equation_code,layer_name,equation_text,law_class,status,interpretation_text)
VALUES
('FP110-E01','IL17_MASS_BALANCE','CYTOKINE','dN_IL17/dt = sum_s(N_s*r_s) - k_deg*N_IL17 - J_out*A + J_in*A - R_bind','MASS_BALANCE','DERIVED_STRUCTURE','IL-17 amount changes by production minus first-order loss, net transport, and receptor-binding sink/source terms.'),
('FP110-E02','FIRST_ORDER_DECAY','CYTOKINE','k_deg = ln(2)/t_half','FIRST_ORDER_KINETICS','DERIVED','Converts a context-specific IL-17 half-life into a first-order decay constant.'),
('FP110-E03','FICK_FLUX','TRANSPORT','J = -D*dC/dx','FICKS_FIRST_LAW','DERIVED','Diffusive cytokine flux through tissue is determined by diffusion coefficient and concentration gradient.'),
('FP110-E04','MASS_ACTION_BINDING','RECEPTOR','d[LR]/dt = k_on[L][R] - k_off[LR]','MASS_ACTION','DERIVED','IL-17 ligand and receptor complex formation/dissociation follow mass-action kinetics.'),
('FP110-E05','KD_DEFINITION','RECEPTOR','K_D = k_off/k_on','EQUILIBRIUM_BINDING','DERIVED','Dissociation constant follows directly from on/off rates.'),
('FP110-E06','RECEPTOR_OCCUPANCY','RECEPTOR','theta = [L]/(K_D + [L])','LANGMUIR_OCCUPANCY','DERIVED_STRUCTURE','Fractional occupancy for a one-site equilibrium approximation; IL-17 receptor heteromeric stoichiometry must be represented explicitly when numeric prediction is attempted.'),
('FP110-E07','BOUND_RECEPTOR_NUMBER','RECEPTOR','N_LR = theta * N_R_available','COUNT_BALANCE','DERIVED_STRUCTURE','Number of occupied receptor complexes follows fractional occupancy times available signalling-competent receptor complexes.'),
('FP110-E08','SIGNAL_INPUT','KERATINOCYTE','S_IL17 = N_LR/N_cell','NORMALIZED_SIGNAL_INPUT','DERIVED_STRUCTURE','Per-keratinocyte IL-17 receptor engagement is the mechanistic input to downstream ACT1/TRAF/NF-kB/MAPK signalling; downstream transfer function remains to be derived.' )
ON DUPLICATE KEY UPDATE equation_text=VALUES(equation_text),status=VALUES(status),interpretation_text=VALUES(interpretation_text);

INSERT INTO ilb_psoriasis_fp_primitive
(primitive_id,symbol,quantity_name,unit_text,value_num,value_text,source_status,context_requirement,source_note)
VALUES
('FP110-P01','N_s','IL-17 producing cell count by source','cells',NULL,NULL,'TO_SOURCE','Must be source-specific and compartment-specific: Th17, Tc17, gamma-delta T, ILC3, neutrophil, mast-cell or other validated source.','Do not collapse all IL-17 production into Th17 only.'),
('FP110-P02','r_s','IL-17 secretion rate per producing cell','mol cell^-1 s^-1',NULL,NULL,'TO_SOURCE','Requires human cell type, activation state, cytokine species (A/F/AF), and tissue context.','No regression-derived surrogate allowed.'),
('FP110-P03','t_half','IL-17 context-specific half-life','s',NULL,NULL,'TO_SOURCE','Must specify IL-17 species and compartment; serum, interstitial and assay-system values are not interchangeable.','Used only through k_deg=ln(2)/t_half.'),
('FP110-P04','D','IL-17 effective diffusion coefficient in skin compartment','m^2 s^-1',NULL,NULL,'TO_SOURCE','Requires tissue compartment, temperature, matrix and cytokine species.','If direct human-skin value unavailable, derivation must be flagged as proxy and independently verified.'),
('FP110-P05','dCdx','IL-17 concentration gradient','mol m^-4',NULL,NULL,'MEASURE_OR_DERIVE','Requires spatial concentrations and defined diffusion distance.','Primitive for Fick flux.'),
('FP110-P06','A','effective transport area','m^2',NULL,NULL,'MEASURE_OR_GEOMETRY','Derived from lesion/tissue geometry, not population average when patient model is used.','Primitive for total transport rate.'),
('FP110-P07','k_on','IL-17 to receptor association rate','M^-1 s^-1',NULL,NULL,'TO_SOURCE','Must match human IL-17 ligand species and receptor complex/construct used.','Do not substitute antibody affinity.'),
('FP110-P08','k_off','IL-17 to receptor dissociation rate','s^-1',NULL,NULL,'TO_SOURCE','Must match same ligand/receptor experiment as k_on.','K_D is derived, not independently invented.'),
('FP110-P09','L','free IL-17 ligand concentration','M',NULL,NULL,'MEASURE_OR_DERIVE','Lesional/interstitial free ligand, not total serum cytokine by default.','Used in receptor binding.'),
('FP110-P10','R','free signalling-competent receptor complex concentration','M',NULL,NULL,'MEASURE_OR_DERIVE','Must account for IL-17RA/IL-17RC signalling complex availability on keratinocytes.','Keratinocytes express IL-17 receptor complexes.'),
('FP110-P11','LR','ligand-receptor complex concentration','M',NULL,NULL,'DERIVED_STATE','State variable derived through mass action.','Not independently assigned.'),
('FP110-P12','N_R_available','available signalling-competent IL-17 receptor complexes','complexes',NULL,NULL,'MEASURE_OR_DERIVE','Requires receptor density and keratinocyte count/surface area.','No sites-per-cell average may be treated as patient-specific without measurement.'),
('FP110-P13','N_cell','keratinocyte count in modeled compartment','cells',NULL,NULL,'DERIVE_FROM_GEOMETRY','Derive from epidermal volume, layer geometry and cell density/count data.','Required to normalize receptor engagement per cell.')
ON DUPLICATE KEY UPDATE source_status=VALUES(source_status),context_requirement=VALUES(context_requirement),source_note=VALUES(source_note);

INSERT INTO ilb_psoriasis_fp_dependency
(dependency_id,equation_id,primitive_id,dependency_role,required_for_numeric_prediction)
VALUES
('FP110-D01','FP110-E01','FP110-P01','PRODUCTION_CELL_COUNT',1),
('FP110-D02','FP110-E01','FP110-P02','SECRETION_RATE',1),
('FP110-D03','FP110-E02','FP110-P03','HALF_LIFE',1),
('FP110-D04','FP110-E03','FP110-P04','DIFFUSION_COEFFICIENT',1),
('FP110-D05','FP110-E03','FP110-P05','CONCENTRATION_GRADIENT',1),
('FP110-D06','FP110-E01','FP110-P06','TRANSPORT_AREA',1),
('FP110-D07','FP110-E04','FP110-P07','ASSOCIATION_RATE',1),
('FP110-D08','FP110-E04','FP110-P08','DISSOCIATION_RATE',1),
('FP110-D09','FP110-E04','FP110-P09','FREE_LIGAND',1),
('FP110-D10','FP110-E04','FP110-P10','FREE_RECEPTOR',1),
('FP110-D11','FP110-E05','FP110-P07','ASSOCIATION_RATE',1),
('FP110-D12','FP110-E05','FP110-P08','DISSOCIATION_RATE',1),
('FP110-D13','FP110-E06','FP110-P09','FREE_LIGAND',1),
('FP110-D14','FP110-E07','FP110-P12','RECEPTOR_COMPLEX_COUNT',1),
('FP110-D15','FP110-E08','FP110-P13','KERATINOCYTE_COUNT',1)
ON DUPLICATE KEY UPDATE required_for_numeric_prediction=VALUES(required_for_numeric_prediction);

CREATE OR REPLACE VIEW v_ilb_psoriasis_phase110_readiness AS
SELECT
  (SELECT COUNT(*) FROM ilb_psoriasis_fp_equation) AS equation_count,
  (SELECT COUNT(*) FROM ilb_psoriasis_fp_primitive) AS primitive_count,
  (SELECT COUNT(*) FROM ilb_psoriasis_fp_dependency) AS dependency_count,
  (SELECT COUNT(*) FROM ilb_psoriasis_fp_primitive WHERE source_status IN ('TO_SOURCE','MEASURE_OR_DERIVE','MEASURE_OR_GEOMETRY','DERIVE_FROM_GEOMETRY')) AS unresolved_numeric_primitives,
  'DERIVED_STRUCTURE_NOT_NUMERICALLY_CLOSED' AS readiness_status,
  'IL-17 subsystem is structurally derived; numeric closure requires sourced or geometrically/person-derived primitives. No fitted psoriasis coefficients are permitted.' AS governance_rule;
