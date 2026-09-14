-- ILoveMyBody Phase 108: Food Biology -> Chemistry -> Physics -> Biochemistry -> Body plumbing
-- Additive only. MySQL 8 / MariaDB 10.5 compatible.
-- Requires Phase 101 universal graph and Phase 107 findings master.

INSERT IGNORE INTO ilb_semantic_type(type_code,label) VALUES
('ORGANISM','Organism'),('FOOD_PART','Food biological part'),('FOOD_PROCESS','Food process'),
('PHYSICAL_PROPERTY','Physical property'),('BIOCHEMICAL_REACTION','Biochemical reaction'),
('COMPARTMENT','Body / process compartment'),('TRANSPORTER','Transporter'),('ENZYME','Enzyme');

INSERT IGNORE INTO ilb_relation_type(relation_code,label,is_directional) VALUES
('DERIVED_FROM','derived from',TRUE),('HAS_PART','has part',TRUE),('HAS_COMPONENT','has component',TRUE),
('HAS_PROPERTY','has property',TRUE),('PROCESSED_BY','processed by',TRUE),('DIGESTED_BY','digested by',TRUE),
('CATALYZED_BY','catalyzed by',TRUE),('PRODUCES','produces',TRUE),('ENTERS','enters',TRUE),
('LEAVES','leaves',TRUE),('CARRIED_BY','carried by',TRUE),('DELIVERED_TO','delivered to',TRUE),
('MEASURED_AS','measured as',TRUE),('TARGETS','targets',TRUE),('AFFECTS','affects',TRUE);

CREATE TABLE IF NOT EXISTS ilb_food_biology_profile (
  food_entity_id CHAR(64) PRIMARY KEY,
  organism_entity_id CHAR(64) NULL,
  food_part_entity_id CHAR(64) NULL,
  biological_origin ENUM('PLANT','ANIMAL','FUNGUS','ALGA','MICROBIAL','MINERAL','MIXED','SYNTHETIC','OTHER') NOT NULL DEFAULT 'OTHER',
  maturity_stage VARCHAR(160) NULL,
  edible_state VARCHAR(160) NULL,
  edible_fraction_variable_id CHAR(64) NULL,
  notes TEXT NULL,
  lifecycle_status ENUM('DRAFT','STAGED','APPROVED','RETIRED') NOT NULL DEFAULT 'DRAFT',
  source_batch_id CHAR(36) NULL,
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  CONSTRAINT fk_food_bio_food FOREIGN KEY (food_entity_id) REFERENCES ilb_semantic_entity(entity_id),
  CONSTRAINT fk_food_bio_organism FOREIGN KEY (organism_entity_id) REFERENCES ilb_semantic_entity(entity_id),
  CONSTRAINT fk_food_bio_part FOREIGN KEY (food_part_entity_id) REFERENCES ilb_semantic_entity(entity_id),
  CONSTRAINT fk_food_bio_edible_var FOREIGN KEY (edible_fraction_variable_id) REFERENCES ilb_variable_definition(variable_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_food_composition_measurement (
  composition_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  food_entity_id CHAR(64) NOT NULL,
  component_entity_id CHAR(64) NOT NULL,
  amount_value DECIMAL(38,12) NULL,
  unit_code VARCHAR(64) NOT NULL,
  basis_amount DECIMAL(24,8) NOT NULL DEFAULT 100,
  basis_unit_code VARCHAR(64) NOT NULL DEFAULT 'g',
  preparation_state VARCHAR(160) NULL,
  analytical_method VARCHAR(255) NULL,
  evidence_id CHAR(64) NULL,
  value_status ENUM('MEASURED','CALCULATED','ESTIMATED','MISSING') NOT NULL DEFAULT 'MEASURED',
  lifecycle_status ENUM('DRAFT','STAGED','APPROVED','RETIRED') NOT NULL DEFAULT 'DRAFT',
  source_batch_id CHAR(36) NULL,
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  UNIQUE KEY uq_food_component_basis (food_entity_id,component_entity_id,preparation_state,basis_amount,basis_unit_code,evidence_id),
  KEY ix_food_component_component (component_entity_id,food_entity_id),
  CONSTRAINT fk_food_comp_food FOREIGN KEY (food_entity_id) REFERENCES ilb_semantic_entity(entity_id),
  CONSTRAINT fk_food_comp_component FOREIGN KEY (component_entity_id) REFERENCES ilb_semantic_entity(entity_id),
  CONSTRAINT fk_food_comp_evidence FOREIGN KEY (evidence_id) REFERENCES ilb_evidence_reference(evidence_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_food_physical_property_value (
  physical_value_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  food_entity_id CHAR(64) NOT NULL,
  property_entity_id CHAR(64) NOT NULL,
  process_state VARCHAR(160) NULL,
  variable_id CHAR(64) NULL,
  value_number DECIMAL(38,12) NULL,
  unit_code VARCHAR(64) NULL,
  temperature_c DECIMAL(12,6) NULL,
  pressure_kpa DECIMAL(18,6) NULL,
  evidence_id CHAR(64) NULL,
  value_origin ENUM('MEASURED','CALCULATED','EXTERNAL_RANGE','MISSING') NOT NULL DEFAULT 'MEASURED',
  notes TEXT NULL,
  lifecycle_status ENUM('DRAFT','STAGED','APPROVED','RETIRED') NOT NULL DEFAULT 'DRAFT',
  source_batch_id CHAR(36) NULL,
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  CONSTRAINT fk_food_phys_food FOREIGN KEY (food_entity_id) REFERENCES ilb_semantic_entity(entity_id),
  CONSTRAINT fk_food_phys_property FOREIGN KEY (property_entity_id) REFERENCES ilb_semantic_entity(entity_id),
  CONSTRAINT fk_food_phys_variable FOREIGN KEY (variable_id) REFERENCES ilb_variable_definition(variable_id),
  CONSTRAINT fk_food_phys_evidence FOREIGN KEY (evidence_id) REFERENCES ilb_evidence_reference(evidence_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_food_process_effect (
  process_effect_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  food_entity_id CHAR(64) NOT NULL,
  process_entity_id CHAR(64) NOT NULL,
  component_entity_id CHAR(64) NULL,
  property_entity_id CHAR(64) NULL,
  input_variable_id CHAR(64) NULL,
  output_variable_id CHAR(64) NULL,
  equation_id CHAR(64) NULL,
  effect_direction ENUM('INCREASE','DECREASE','TRANSFORM','NO_CHANGE','UNKNOWN') NOT NULL DEFAULT 'UNKNOWN',
  evidence_id CHAR(64) NULL,
  notes TEXT NULL,
  lifecycle_status ENUM('DRAFT','STAGED','APPROVED','RETIRED') NOT NULL DEFAULT 'DRAFT',
  source_batch_id CHAR(36) NULL,
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  CONSTRAINT fk_food_proc_food FOREIGN KEY (food_entity_id) REFERENCES ilb_semantic_entity(entity_id),
  CONSTRAINT fk_food_proc_process FOREIGN KEY (process_entity_id) REFERENCES ilb_semantic_entity(entity_id),
  CONSTRAINT fk_food_proc_component FOREIGN KEY (component_entity_id) REFERENCES ilb_semantic_entity(entity_id),
  CONSTRAINT fk_food_proc_property FOREIGN KEY (property_entity_id) REFERENCES ilb_semantic_entity(entity_id),
  CONSTRAINT fk_food_proc_input FOREIGN KEY (input_variable_id) REFERENCES ilb_variable_definition(variable_id),
  CONSTRAINT fk_food_proc_output FOREIGN KEY (output_variable_id) REFERENCES ilb_variable_definition(variable_id),
  CONSTRAINT fk_food_proc_equation FOREIGN KEY (equation_id) REFERENCES ilb_equation_definition(equation_id),
  CONSTRAINT fk_food_proc_evidence FOREIGN KEY (evidence_id) REFERENCES ilb_evidence_reference(evidence_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_feed_pathway (
  feed_pathway_id CHAR(64) PRIMARY KEY,
  pathway_code VARCHAR(160) NOT NULL UNIQUE,
  label VARCHAR(512) NOT NULL,
  input_food_entity_id CHAR(64) NULL,
  input_component_entity_id CHAR(64) NULL,
  output_entity_id CHAR(64) NULL,
  disease_entity_id CHAR(64) NULL,
  intervention_entity_id CHAR(64) NULL,
  purpose ENUM('DELIVERY','METABOLISM','DISEASE_MECHANISM','TREATMENT_COMPARISON','SAFETY') NOT NULL DEFAULT 'DELIVERY',
  lifecycle_status ENUM('DRAFT','STAGED','APPROVED','RETIRED') NOT NULL DEFAULT 'DRAFT',
  source_batch_id CHAR(36) NULL,
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  CONSTRAINT fk_feed_path_food FOREIGN KEY (input_food_entity_id) REFERENCES ilb_semantic_entity(entity_id),
  CONSTRAINT fk_feed_path_component FOREIGN KEY (input_component_entity_id) REFERENCES ilb_semantic_entity(entity_id),
  CONSTRAINT fk_feed_path_output FOREIGN KEY (output_entity_id) REFERENCES ilb_semantic_entity(entity_id),
  CONSTRAINT fk_feed_path_disease FOREIGN KEY (disease_entity_id) REFERENCES ilb_semantic_entity(entity_id),
  CONSTRAINT fk_feed_path_intervention FOREIGN KEY (intervention_entity_id) REFERENCES ilb_semantic_entity(entity_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_feed_pathway_step (
  feed_pathway_id CHAR(64) NOT NULL,
  step_no INT UNSIGNED NOT NULL,
  stage_code ENUM('INGESTION','PROCESSING','DIGESTION','BIOACCESSIBILITY','ABSORPTION','TRANSPORT','DISTRIBUTION','METABOLISM','STORAGE','TISSUE_DELIVERY','TARGET_EFFECT','EXCRETION','OUTCOME') NOT NULL,
  source_entity_id CHAR(64) NULL,
  relation_code VARCHAR(64) NULL,
  target_entity_id CHAR(64) NULL,
  compartment_entity_id CHAR(64) NULL,
  input_variable_id CHAR(64) NULL,
  output_variable_id CHAR(64) NULL,
  equation_id CHAR(64) NULL,
  evidence_id CHAR(64) NULL,
  quantification_status ENUM('NOT_QUANTIFIED','PARTIAL','QUANTIFIED') NOT NULL DEFAULT 'NOT_QUANTIFIED',
  assumption_status ENUM('NONE','EXPLICIT','BLOCKED') NOT NULL DEFAULT 'NONE',
  notes TEXT NULL,
  PRIMARY KEY (feed_pathway_id,step_no),
  KEY ix_feed_step_target (target_entity_id,stage_code),
  CONSTRAINT fk_feed_step_path FOREIGN KEY (feed_pathway_id) REFERENCES ilb_feed_pathway(feed_pathway_id),
  CONSTRAINT fk_feed_step_source FOREIGN KEY (source_entity_id) REFERENCES ilb_semantic_entity(entity_id),
  CONSTRAINT fk_feed_step_relation FOREIGN KEY (relation_code) REFERENCES ilb_relation_type(relation_code),
  CONSTRAINT fk_feed_step_target FOREIGN KEY (target_entity_id) REFERENCES ilb_semantic_entity(entity_id),
  CONSTRAINT fk_feed_step_compartment FOREIGN KEY (compartment_entity_id) REFERENCES ilb_semantic_entity(entity_id),
  CONSTRAINT fk_feed_step_input FOREIGN KEY (input_variable_id) REFERENCES ilb_variable_definition(variable_id),
  CONSTRAINT fk_feed_step_output FOREIGN KEY (output_variable_id) REFERENCES ilb_variable_definition(variable_id),
  CONSTRAINT fk_feed_step_equation FOREIGN KEY (equation_id) REFERENCES ilb_equation_definition(equation_id),
  CONSTRAINT fk_feed_step_evidence FOREIGN KEY (evidence_id) REFERENCES ilb_evidence_reference(evidence_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_food_delivery_factor (
  delivery_factor_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  food_entity_id CHAR(64) NOT NULL,
  component_entity_id CHAR(64) NOT NULL,
  factor_code ENUM('EDIBLE_FRACTION','RETENTION','BIOACCESSIBILITY','ABSORPTION','FIRST_PASS_SURVIVAL','METABOLIC_AVAILABILITY','TISSUE_DELIVERY') NOT NULL,
  process_state VARCHAR(160) NULL,
  compartment_entity_id CHAR(64) NULL,
  factor_value DECIMAL(18,12) NULL,
  factor_variable_id CHAR(64) NULL,
  equation_id CHAR(64) NULL,
  evidence_id CHAR(64) NULL,
  person_specific BOOLEAN NOT NULL DEFAULT FALSE,
  status ENUM('MEASURED','DERIVED','EXTERNAL_RANGE','UNKNOWN') NOT NULL DEFAULT 'UNKNOWN',
  notes TEXT NULL,
  lifecycle_status ENUM('DRAFT','STAGED','APPROVED','RETIRED') NOT NULL DEFAULT 'DRAFT',
  source_batch_id CHAR(36) NULL,
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  CHECK (factor_value IS NULL OR (factor_value >= 0 AND factor_value <= 1)),
  CONSTRAINT fk_food_factor_food FOREIGN KEY (food_entity_id) REFERENCES ilb_semantic_entity(entity_id),
  CONSTRAINT fk_food_factor_component FOREIGN KEY (component_entity_id) REFERENCES ilb_semantic_entity(entity_id),
  CONSTRAINT fk_food_factor_compartment FOREIGN KEY (compartment_entity_id) REFERENCES ilb_semantic_entity(entity_id),
  CONSTRAINT fk_food_factor_variable FOREIGN KEY (factor_variable_id) REFERENCES ilb_variable_definition(variable_id),
  CONSTRAINT fk_food_factor_equation FOREIGN KEY (equation_id) REFERENCES ilb_equation_definition(equation_id),
  CONSTRAINT fk_food_factor_evidence FOREIGN KEY (evidence_id) REFERENCES ilb_evidence_reference(evidence_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_food_delivered_amount_model (
  model_id CHAR(64) PRIMARY KEY,
  model_code VARCHAR(160) NOT NULL UNIQUE,
  food_entity_id CHAR(64) NOT NULL,
  component_entity_id CHAR(64) NOT NULL,
  intake_mass_variable_id CHAR(64) NOT NULL,
  composition_variable_id CHAR(64) NOT NULL,
  output_variable_id CHAR(64) NOT NULL,
  equation_id CHAR(64) NULL,
  target_compartment_entity_id CHAR(64) NULL,
  lifecycle_status ENUM('DRAFT','STAGED','APPROVED','RETIRED') NOT NULL DEFAULT 'DRAFT',
  notes TEXT NULL,
  CONSTRAINT fk_food_delivery_food FOREIGN KEY (food_entity_id) REFERENCES ilb_semantic_entity(entity_id),
  CONSTRAINT fk_food_delivery_component FOREIGN KEY (component_entity_id) REFERENCES ilb_semantic_entity(entity_id),
  CONSTRAINT fk_food_delivery_intake FOREIGN KEY (intake_mass_variable_id) REFERENCES ilb_variable_definition(variable_id),
  CONSTRAINT fk_food_delivery_composition FOREIGN KEY (composition_variable_id) REFERENCES ilb_variable_definition(variable_id),
  CONSTRAINT fk_food_delivery_output FOREIGN KEY (output_variable_id) REFERENCES ilb_variable_definition(variable_id),
  CONSTRAINT fk_food_delivery_equation FOREIGN KEY (equation_id) REFERENCES ilb_equation_definition(equation_id),
  CONSTRAINT fk_food_delivery_target_compartment FOREIGN KEY (target_compartment_entity_id) REFERENCES ilb_semantic_entity(entity_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_observation_mapping (
  observation_mapping_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  variable_id CHAR(64) NOT NULL,
  loinc_code VARCHAR(32) NULL,
  specimen_entity_id CHAR(64) NULL,
  method_text VARCHAR(255) NULL,
  canonical_unit_code VARCHAR(64) NULL,
  relation_to_model ENUM('INPUT','OUTPUT','VALIDATION','SAFETY','OUTCOME') NOT NULL,
  lifecycle_status ENUM('DRAFT','STAGED','APPROVED','RETIRED') NOT NULL DEFAULT 'DRAFT',
  UNIQUE KEY uq_observation_mapping (variable_id,loinc_code,specimen_entity_id,method_text),
  CONSTRAINT fk_observation_variable FOREIGN KEY (variable_id) REFERENCES ilb_variable_definition(variable_id),
  CONSTRAINT fk_observation_specimen FOREIGN KEY (specimen_entity_id) REFERENCES ilb_semantic_entity(entity_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ilb_intervention_node_effect (
  intervention_entity_id CHAR(64) NOT NULL,
  target_entity_id CHAR(64) NOT NULL,
  relation_code VARCHAR(64) NOT NULL,
  variable_id CHAR(64) NULL,
  equation_id CHAR(64) NULL,
  evidence_id CHAR(64) NULL,
  effect_sign ENUM('POSITIVE','NEGATIVE','MIXED','UNKNOWN') NOT NULL DEFAULT 'UNKNOWN',
  effect_class ENUM('DIRECT_BINDING','ENZYME','TRANSPORT','PHOTOPHYSICAL','NUTRITIONAL','METABOLIC','BEHAVIOURAL','OTHER') NOT NULL DEFAULT 'OTHER',
  quantification_status ENUM('NOT_QUANTIFIED','PARTIAL','QUANTIFIED') NOT NULL DEFAULT 'NOT_QUANTIFIED',
  lifecycle_status ENUM('DRAFT','STAGED','APPROVED','RETIRED') NOT NULL DEFAULT 'DRAFT',
  notes TEXT NULL,
  PRIMARY KEY (intervention_entity_id,target_entity_id,relation_code,effect_class),
  CONSTRAINT fk_int_node_intervention FOREIGN KEY (intervention_entity_id) REFERENCES ilb_semantic_entity(entity_id),
  CONSTRAINT fk_int_node_target FOREIGN KEY (target_entity_id) REFERENCES ilb_semantic_entity(entity_id),
  CONSTRAINT fk_int_node_relation FOREIGN KEY (relation_code) REFERENCES ilb_relation_type(relation_code),
  CONSTRAINT fk_int_node_variable FOREIGN KEY (variable_id) REFERENCES ilb_variable_definition(variable_id),
  CONSTRAINT fk_int_node_equation FOREIGN KEY (equation_id) REFERENCES ilb_equation_definition(equation_id),
  CONSTRAINT fk_int_node_evidence FOREIGN KEY (evidence_id) REFERENCES ilb_evidence_reference(evidence_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE OR REPLACE VIEW v_ilb_food_delivery_readiness AS
SELECT
  fp.feed_pathway_id,fp.pathway_code,fp.label,fp.lifecycle_status,
  COUNT(fs.step_no) AS step_count,
  SUM(CASE WHEN fs.quantification_status='QUANTIFIED' THEN 1 ELSE 0 END) AS quantified_steps,
  SUM(CASE WHEN fs.evidence_id IS NOT NULL THEN 1 ELSE 0 END) AS evidenced_steps,
  SUM(CASE WHEN fs.assumption_status='BLOCKED' THEN 1 ELSE 0 END) AS blocked_steps,
  CASE
    WHEN fp.lifecycle_status <> 'APPROVED' THEN 'BLOCKED'
    WHEN COUNT(fs.step_no)=0 THEN 'BLOCKED'
    WHEN SUM(CASE WHEN fs.assumption_status='BLOCKED' THEN 1 ELSE 0 END)>0 THEN 'BLOCKED'
    ELSE 'READY'
  END AS readiness_status
FROM ilb_feed_pathway fp
LEFT JOIN ilb_feed_pathway_step fs ON fs.feed_pathway_id=fp.feed_pathway_id
GROUP BY fp.feed_pathway_id,fp.pathway_code,fp.label,fp.lifecycle_status;

CREATE OR REPLACE VIEW v_ilb_food_pharma_common_node AS
SELECT
  a.target_entity_id,
  a.intervention_entity_id AS intervention_a_id,
  a.effect_class AS intervention_a_class,
  a.effect_sign AS intervention_a_sign,
  a.quantification_status AS intervention_a_quantification,
  b.intervention_entity_id AS intervention_b_id,
  b.effect_class AS intervention_b_class,
  b.effect_sign AS intervention_b_sign,
  b.quantification_status AS intervention_b_quantification
FROM ilb_intervention_node_effect a
JOIN ilb_intervention_node_effect b
  ON b.target_entity_id=a.target_entity_id
 AND b.intervention_entity_id>a.intervention_entity_id
WHERE a.lifecycle_status='APPROVED' AND b.lifecycle_status='APPROVED';

-- Delivered amount governance equation:
-- intake_mass * composition * edible_fraction * retention * bioaccessibility * absorption
-- * first_pass_survival * metabolic_availability * tissue_delivery.
-- Missing factors MUST remain NULL/UNKNOWN; they MUST NOT default to 1 unless an explicit
-- approved assumption record/equation justifies that choice.

CREATE OR REPLACE VIEW v_ilb_food_component_factor_completeness AS
SELECT
  c.food_entity_id,c.component_entity_id,
  COUNT(DISTINCT f.factor_code) AS available_factor_types,
  SUM(CASE WHEN f.status='UNKNOWN' OR (f.factor_value IS NULL AND f.factor_variable_id IS NULL AND f.equation_id IS NULL) THEN 1 ELSE 0 END) AS unknown_factor_rows,
  GROUP_CONCAT(DISTINCT CASE WHEN f.status<>'UNKNOWN' THEN f.factor_code END ORDER BY f.factor_code SEPARATOR ',') AS known_factors
FROM ilb_food_composition_measurement c
LEFT JOIN ilb_food_delivery_factor f
  ON f.food_entity_id=c.food_entity_id AND f.component_entity_id=c.component_entity_id
GROUP BY c.food_entity_id,c.component_entity_id;

-- External identifiers remain in ilb_entity_identifier.
-- Recommended namespaces: USDA_FDC, NCBI_TAXONOMY, ChEBI, UniProt, HGNC, Reactome, GO,
-- LOINC, RxNorm and ATC. This keeps food and pharmacy on the same semantic graph.
