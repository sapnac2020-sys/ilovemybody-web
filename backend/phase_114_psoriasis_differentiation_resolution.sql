-- Phase 114: Psoriasis differentiation -> cornification -> desquamation -> barrier -> plaque resolution
-- Formula-first derivation. No unsourced numeric constants.

CREATE TABLE IF NOT EXISTS ilb_psoriasis_resolution_equation (
  equation_id VARCHAR(64) PRIMARY KEY,
  equation_name VARCHAR(128) NOT NULL,
  equation_text TEXT NOT NULL,
  law_class VARCHAR(64) NOT NULL,
  derivation_status VARCHAR(32) NOT NULL,
  source_boundary TEXT NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_psoriasis_resolution_primitive (
  primitive_code VARCHAR(64) PRIMARY KEY,
  primitive_name VARCHAR(128) NOT NULL,
  unit_text VARCHAR(64) NOT NULL,
  numeric_value DECIMAL(30,12) NULL,
  value_status VARCHAR(32) NOT NULL DEFAULT 'UNKNOWN',
  derivation_or_source TEXT NOT NULL,
  context_requirement TEXT NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO ilb_psoriasis_resolution_equation
(equation_id,equation_name,equation_text,law_class,derivation_status,source_boundary)
VALUES
('PSO114-E01','Differentiation commitment balance','dN_d/dt = r_commit*N_p - r_corn*N_d - r_apop_d*N_d','POPULATION_BALANCE','DERIVED_STRUCTURE','Population conservation; rate primitives must be sourced/derived'),
('PSO114-E02','Cornification balance','dN_c/dt = r_corn*N_d - r_shed*N_c','POPULATION_BALANCE','DERIVED_STRUCTURE','Population conservation'),
('PSO114-E03','Cornified envelope assembly','dCE/dt = v_TGM - k_CEdeg*CE','MASS_BALANCE','DERIVED_STRUCTURE','CE formation depends on transglutaminase-mediated crosslinking of envelope proteins'),
('PSO114-E04','Transglutaminase envelope rate','v_TGM = Vmax_TGM*S_CE/(Km_TGM + S_CE)','MICHAELIS_MENTEN','DERIVED_STRUCTURE','Use only if enzyme-kinetic assumptions and matched substrate/context are satisfied'),
('PSO114-E05','Corneodesmosome abundance','dCDS/dt = v_form - v_cleave','MASS_BALANCE','DERIVED_STRUCTURE','Corneodesmosomes are formed during differentiation and cleaved during desquamation'),
('PSO114-E06','Proteolytic cleavage','v_cleave = k_KLK*E_KLK*CDS','MASS_ACTION_APPROX','DERIVED_STRUCTURE','KLK/cathepsin cleavage of CDSN/DSG1/DSC1; inhibitor and pH dependence must be explicit when available'),
('PSO114-E07','Effective desquamation rate','r_shed = v_cleave/(CDS*N_c)','DERIVED_RATIO','DERIVED_STRUCTURE','Maps structural cleavage to corneocyte shedding under stated geometry/stoichiometry assumptions'),
('PSO114-E08','Barrier resistance','R_barrier = L_SC/(D_water*K_part)','FICK_RESISTANCE','DERIVED_STRUCTURE','Planar steady-state approximation'),
('PSO114-E09','Water flux / TEWL core','J_water = DeltaC_water/R_barrier','FICK_FLUX','DERIVED_STRUCTURE','Steady-state diffusion approximation; measured TEWL remains verification endpoint'),
('PSO114-E10','Barrier state index','B = J_water/J_water_normal','NORMALIZED_PHYSICAL_RATIO','DERIVED_STRUCTURE','Dimensionless barrier-defect index; requires matched normal-site comparator'),
('PSO114-E11','Epidermal thickness','h_epi = (N_p*v_p + N_d*v_d + N_c*v_c)/A_lesion','GEOMETRY','DERIVED_STRUCTURE','Cell-count/volume geometry'),
('PSO114-E12','Excess plaque volume','V_excess = A_lesion*max(h_epi-h_normal,0)','GEOMETRY','DERIVED_STRUCTURE','Physical excess epidermal volume'),
('PSO114-E13','Plaque resolution condition','dV_excess/dt < 0','INEQUALITY','DERIVED_STRUCTURE','Resolution requires net epidermal volume loss toward matched normal thickness'),
('PSO114-E14','Corneocyte pool resolution','r_shed*N_c > r_corn*N_d','INEQUALITY','DERIVED_STRUCTURE','Necessary local condition for shrinking corneocyte excess'),
('PSO114-E15','Viable differentiated pool resolution','r_corn*N_d + r_apop_d*N_d > r_commit*N_p','INEQUALITY','DERIVED_STRUCTURE','Necessary local condition for shrinking differentiated-cell excess'),
('PSO114-E16','Proliferative pool resolution','r_commit + r_apop_p > r_self','INEQUALITY','DERIVED_STRUCTURE','Necessary local condition for shrinking proliferative-cell excess')
ON DUPLICATE KEY UPDATE equation_text=VALUES(equation_text),law_class=VALUES(law_class),derivation_status=VALUES(derivation_status),source_boundary=VALUES(source_boundary);

INSERT INTO ilb_psoriasis_resolution_primitive
(primitive_code,primitive_name,unit_text,numeric_value,value_status,derivation_or_source,context_requirement)
VALUES
('R_COMMIT','Basal-to-differentiation commitment rate','1/time',NULL,'UNKNOWN','Must be derived from matched keratinocyte transition kinetics','Human epidermis, lesional/nonlesional context'),
('R_CORN','Differentiated-to-corneocyte transition rate','1/time',NULL,'UNKNOWN','Must be derived from cornification transit kinetics','Human epidermis'),
('R_APOP_D','Differentiated-cell loss rate','1/time',NULL,'UNKNOWN','Half-life or direct loss kinetics','Matched compartment'),
('Vmax_TGM','Maximum cornified-envelope transglutaminase rate','amount/time',NULL,'UNKNOWN','Matched TGM1/TGM3 enzyme kinetics','Temperature, pH, substrate identity'),
('Km_TGM','Cornified-envelope substrate Michaelis constant','concentration',NULL,'UNKNOWN','Matched enzyme/substrate kinetics','Exact substrate/context'),
('S_CE','Cornified-envelope precursor concentration','concentration',NULL,'UNKNOWN','Measured/derived from IVL/LOR/FLG-related pool','Lesional epidermis'),
('K_CEDEG','Cornified-envelope degradation/loss constant','1/time',NULL,'UNKNOWN','Half-life-derived if available','Matched tissue compartment'),
('K_KLK','Effective corneodesmosome cleavage constant','1/(amount*time)',NULL,'UNKNOWN','Matched KLK/cathepsin kinetics','pH, inhibitor state, substrate identity'),
('E_KLK','Active epidermal protease abundance','amount',NULL,'UNKNOWN','Measured/derived active enzyme pool','Stratum corneum'),
('CDS','Corneodesmosome substrate abundance','amount',NULL,'UNKNOWN','CDSN/DSG1/DSC1 abundance or structural proxy','Stratum corneum'),
('L_SC','Stratum-corneum diffusion path length','length',NULL,'UNKNOWN','Measured geometry','Site and lesion specific'),
('D_WATER','Water diffusion coefficient in stratum corneum','area/time',NULL,'UNKNOWN','Physical transport measurement/source','Hydration, temperature, site'),
('K_PART','Water partition coefficient','dimensionless',NULL,'UNKNOWN','Physical partition measurement/source','Matched SC composition'),
('DELTAC_WATER','Water concentration gradient','amount/volume',NULL,'UNKNOWN','Derived from boundary concentrations','Ambient humidity and tissue water state'),
('J_WATER_NORMAL','Matched normal water flux','mass/(area*time)',NULL,'UNKNOWN','Person/site matched measurement or defensible source','Same site/environment'),
('V_P','Mean proliferating keratinocyte volume','volume/cell',NULL,'UNKNOWN','Morphometric geometry','Matched compartment'),
('V_D','Mean differentiated keratinocyte volume','volume/cell',NULL,'UNKNOWN','Morphometric geometry','Matched compartment'),
('V_C','Mean corneocyte volume','volume/cell',NULL,'UNKNOWN','Morphometric geometry','Matched compartment'),
('A_LESION','Lesion area','area',NULL,'PERSON_GEOMETRY','Measured directly','Patient lesion'),
('H_NORMAL','Matched normal epidermal thickness','length',NULL,'PERSON_OR_SITE_REFERENCE','Matched unaffected site preferred','Same anatomical site')
ON DUPLICATE KEY UPDATE primitive_name=VALUES(primitive_name),unit_text=VALUES(unit_text),derivation_or_source=VALUES(derivation_or_source),context_requirement=VALUES(context_requirement);

CREATE OR REPLACE VIEW v_ilb_psoriasis_resolution_readiness AS
SELECT
  (SELECT COUNT(*) FROM ilb_psoriasis_resolution_equation) AS equations,
  (SELECT COUNT(*) FROM ilb_psoriasis_resolution_primitive) AS primitives,
  (SELECT SUM(numeric_value IS NOT NULL) FROM ilb_psoriasis_resolution_primitive) AS numeric_primitives,
  'DERIVED_STRUCTURE_NOT_NUMERICALLY_CLOSED' AS readiness_status,
  'Resolution is defined by population-balance inequalities plus physical barrier/geometry equations; all unsourced kinetic primitives remain NULL.' AS governance_rule;
