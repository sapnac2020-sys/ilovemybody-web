-- ILMB Phase 73: Standalone acupuncture mathematics
-- Scope: identity, discrete order, graph topology, future geometry and correlation gates.
-- Boundary: creates no clinical-effect, mechanism, organ-control or outcome claim.
-- Live application is NOT asserted by this file.

CREATE TABLE IF NOT EXISTS ilb_acupuncture_math_model_master (
  math_model_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  math_model_key VARCHAR(120) NOT NULL,
  model_name VARCHAR(255) NOT NULL,
  model_version VARCHAR(40) NOT NULL,
  canonical_source_file VARCHAR(500) NOT NULL,
  source_point_count SMALLINT UNSIGNED NOT NULL,
  source_channel_count TINYINT UNSIGNED NOT NULL,
  expected_sequential_edge_count SMALLINT UNSIGNED NOT NULL,
  model_scope ENUM('identity_topology','geometry','correlation','other') NOT NULL DEFAULT 'identity_topology',
  clinical_use_allowed TINYINT(1) NOT NULL DEFAULT 0,
  geometry_use_allowed TINYINT(1) NOT NULL DEFAULT 0,
  correlation_release_allowed TINYINT(1) NOT NULL DEFAULT 0,
  model_status ENUM('draft','active','blocked','retired') NOT NULL DEFAULT 'active',
  boundary_text VARCHAR(1500) NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (math_model_id),
  UNIQUE KEY uq_ilb_acu_math_model_key (math_model_key),
  UNIQUE KEY uq_ilb_acu_math_model_file (canonical_source_file)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO ilb_acupuncture_math_model_master
  (math_model_key, model_name, model_version, canonical_source_file,
   source_point_count, source_channel_count, expected_sequential_edge_count,
   model_scope, clinical_use_allowed, geometry_use_allowed,
   correlation_release_allowed, model_status, boundary_text)
VALUES
  ('ilmb_acupuncture_standalone_math_v1',
   'ILMB Standalone Acupuncture Mathematics V1',
   '1.0.0',
   'ILMB_Acupuncture_Standalone_Mathematics_v1.0.0.xlsx',
   361, 14, 347, 'identity_topology', 0, 0, 0, 'active',
   'Canonical source for standardized point identity, channel order and discrete topology. It does not establish a physical meridian, anatomical pathway, physiological mechanism, organ effect, clinical efficacy or health outcome.')
ON DUPLICATE KEY UPDATE
  model_name = VALUES(model_name),
  model_version = VALUES(model_version),
  source_point_count = VALUES(source_point_count),
  source_channel_count = VALUES(source_channel_count),
  expected_sequential_edge_count = VALUES(expected_sequential_edge_count),
  clinical_use_allowed = 0,
  geometry_use_allowed = 0,
  correlation_release_allowed = 0,
  boundary_text = VALUES(boundary_text),
  updated_at = CURRENT_TIMESTAMP;

CREATE TABLE IF NOT EXISTS ilb_acupuncture_math_equation_master (
  equation_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  equation_key VARCHAR(40) NOT NULL,
  math_model_key VARCHAR(120) NOT NULL,
  equation_domain ENUM('order','graph','geometry','uncertainty','incidence','gate','other') NOT NULL,
  equation_name VARCHAR(255) NOT NULL,
  equation_text VARCHAR(1500) NOT NULL,
  input_definition VARCHAR(1500) NOT NULL,
  output_unit VARCHAR(120) NOT NULL,
  current_state ENUM('evaluable','blocked','retired') NOT NULL DEFAULT 'blocked',
  valid_meaning VARCHAR(1500) NOT NULL,
  prohibited_inference VARCHAR(1500) NOT NULL,
  source_basis VARCHAR(1000) NOT NULL,
  equation_status ENUM('active','review','retired') NOT NULL DEFAULT 'active',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (equation_id),
  UNIQUE KEY uq_ilb_acu_equation_key (equation_key),
  KEY ix_ilb_acu_equation_model (math_model_key),
  CONSTRAINT fk_ilb_acu_equation_model
    FOREIGN KEY (math_model_key)
    REFERENCES ilb_acupuncture_math_model_master (math_model_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO ilb_acupuncture_math_equation_master
  (equation_key, math_model_key, equation_domain, equation_name, equation_text,
   input_definition, output_unit, current_state, valid_meaning,
   prohibited_inference, source_basis, equation_status)
VALUES
  ('ACM-01','ilmb_acupuncture_standalone_math_v1','order','Normalized channel order',
   's_i=(n_i-1)/(N-1)','Point ordinal n_i and channel point count N','dimensionless','evaluable',
   'Relative standardized code position from zero to one.','Physical distance, flow, potency or clinical importance.','WHO-standard point numbering; standard normalization.','active'),
  ('ACM-02','ilmb_acupuncture_standalone_math_v1','graph','Sequential adjacency',
   'A_ij=1 when point j immediately follows point i in the same channel; otherwise 0','Channel key and standardized point number','binary','evaluable',
   'Discrete code-order adjacency.','A physical meridian tube, anatomical continuity or physiological transmission.','WHO-standard point numbering; graph adjacency.','active'),
  ('ACM-03','ilmb_acupuncture_standalone_math_v1','graph','Point degree',
   'k_i=sum_j A_ij','Sequential adjacency matrix A','edge_count','evaluable',
   'Number of immediate code neighbours.','Biological importance or strength.','Standard graph theory.','active'),
  ('ACM-04','ilmb_acupuncture_standalone_math_v1','graph','Graph path length',
   'l(i,j)=minimum count of approved edges connecting i and j','Approved graph edges','edge_count','evaluable',
   'Separation in standardized code steps.','Millimetres, transmission time or physiological delay.','Standard graph theory.','active'),
  ('ACM-05','ilmb_acupuncture_standalone_math_v1','geometry','Euclidean distance',
   'd=sqrt((x1-x2)^2+(y1-y2)^2+(z1-z2)^2)','Two sourced coordinates in one verified frame','coordinate_unit','blocked',
   'Straight-line spatial separation.','Effect, mechanism or functional connection.','Euclidean geometry.','active'),
  ('ACM-06','ilmb_acupuncture_standalone_math_v1','geometry','Polyline length',
   'L=sum_i norm(P_(i+1)-P_i)','Ordered sourced coordinates in one verified frame','coordinate_unit','blocked',
   'Length of the registered point polyline.','Traditional channel length or tissue pathway.','Euclidean polyline geometry.','active'),
  ('ACM-07','ilmb_acupuncture_standalone_math_v1','uncertainty','Distance uncertainty',
   'sigma_d^2 approximately equals J Sigma J^T','Coordinate covariance Sigma and distance Jacobian J','coordinate_unit_squared','blocked',
   'First-order propagated spatial uncertainty.','Biological uncertainty.','Standard first-order uncertainty propagation.','active'),
  ('ACM-08','ilmb_acupuncture_standalone_math_v1','geometry','Surface geodesic',
   'g(i,j)=shortest path between registered points on an approved body mesh','Two point-to-mesh registrations and one verified mesh','mesh_unit','blocked',
   'Distance along the registered body surface.','Meridian flow or physiological transmission.','Standard geodesic distance.','active'),
  ('ACM-09','ilmb_acupuncture_standalone_math_v1','incidence','Point-to-entity incidence',
   'B_ia=1 only when point i to entity a is sourced and approved','Point, ontology entity, mapping source and approval','binary','blocked',
   'Verified anatomical relation.','Mechanism or clinical effect.','Binary incidence matrix.','active'),
  ('ACM-10','ilmb_acupuncture_standalone_math_v1','incidence','External relation composition',
   'C=B*R','Approved point-entity incidence B and external relation matrix R','relation_count','blocked',
   'Traceable non-causal graph reachability.','Causation or health outcome.','Matrix composition.','active'),
  ('ACM-11','ilmb_acupuncture_standalone_math_v1','gate','Release product gate',
   'G=S*F*A*M*V*Q','Six binary gates: source, frame, anatomy/entity, measurement, independent validation, governance','binary','evaluable',
   'Release equals one only when every mandatory gate equals one.','Treating partial evidence as proof.','Boolean conjunction represented as a binary product.','active')
ON DUPLICATE KEY UPDATE
  equation_name = VALUES(equation_name),
  equation_text = VALUES(equation_text),
  input_definition = VALUES(input_definition),
  output_unit = VALUES(output_unit),
  current_state = VALUES(current_state),
  valid_meaning = VALUES(valid_meaning),
  prohibited_inference = VALUES(prohibited_inference),
  source_basis = VALUES(source_basis),
  equation_status = VALUES(equation_status),
  updated_at = CURRENT_TIMESTAMP;

CREATE TABLE IF NOT EXISTS ilb_acupuncture_correlation_candidate (
  correlation_candidate_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  math_model_key VARCHAR(120) NOT NULL,
  point_id BIGINT UNSIGNED NOT NULL,
  external_domain VARCHAR(80) NOT NULL,
  external_entity_key VARCHAR(180) NOT NULL,
  external_entity_name VARCHAR(255) NOT NULL,
  relation_type VARCHAR(80) NOT NULL,
  mapping_source_key VARCHAR(180) NOT NULL,
  source_locator VARCHAR(1000) NOT NULL,
  source_gate TINYINT(1) NOT NULL DEFAULT 0,
  frame_gate TINYINT(1) NOT NULL DEFAULT 0,
  entity_gate TINYINT(1) NOT NULL DEFAULT 0,
  measurement_gate TINYINT(1) NOT NULL DEFAULT 0,
  independent_validation_gate TINYINT(1) NOT NULL DEFAULT 0,
  governance_gate TINYINT(1) NOT NULL DEFAULT 0,
  candidate_status ENUM('candidate','review','approved','rejected','retired') NOT NULL DEFAULT 'candidate',
  reviewer_note VARCHAR(1500) DEFAULT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (correlation_candidate_id),
  UNIQUE KEY uq_ilb_acu_corr_candidate
    (math_model_key, point_id, external_domain, external_entity_key, relation_type),
  KEY ix_ilb_acu_corr_point (point_id),
  KEY ix_ilb_acu_corr_external (external_domain, external_entity_key),
  CONSTRAINT fk_ilb_acu_corr_model
    FOREIGN KEY (math_model_key)
    REFERENCES ilb_acupuncture_math_model_master (math_model_key),
  CONSTRAINT fk_ilb_acu_corr_point
    FOREIGN KEY (point_id)
    REFERENCES ilb_acupuncture_point (point_id),
  CONSTRAINT ck_ilb_acu_corr_source_gate CHECK (source_gate IN (0,1)),
  CONSTRAINT ck_ilb_acu_corr_frame_gate CHECK (frame_gate IN (0,1)),
  CONSTRAINT ck_ilb_acu_corr_entity_gate CHECK (entity_gate IN (0,1)),
  CONSTRAINT ck_ilb_acu_corr_measurement_gate CHECK (measurement_gate IN (0,1)),
  CONSTRAINT ck_ilb_acu_corr_validation_gate CHECK (independent_validation_gate IN (0,1)),
  CONSTRAINT ck_ilb_acu_corr_governance_gate CHECK (governance_gate IN (0,1))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE OR REPLACE VIEW v_ilb_acupuncture_point_math AS
SELECT
  p.point_id,
  p.point_code,
  p.standard_name,
  p.channel_key,
  p.point_number,
  c.channel_code,
  c.channel_name,
  COUNT(*) OVER (PARTITION BY p.channel_key) AS channel_point_count,
  CASE
    WHEN COUNT(*) OVER (PARTITION BY p.channel_key) <= 1 THEN 0
    ELSE (p.point_number - 1.0) /
         (COUNT(*) OVER (PARTITION BY p.channel_key) - 1.0)
  END AS normalized_channel_position,
  LAG(p.point_id) OVER
    (PARTITION BY p.channel_key ORDER BY p.point_number) AS previous_point_id,
  LEAD(p.point_id) OVER
    (PARTITION BY p.channel_key ORDER BY p.point_number) AS next_point_id,
  (CASE WHEN LAG(p.point_id) OVER
      (PARTITION BY p.channel_key ORDER BY p.point_number) IS NULL THEN 0 ELSE 1 END
   + CASE WHEN LEAD(p.point_id) OVER
      (PARTITION BY p.channel_key ORDER BY p.point_number) IS NULL THEN 0 ELSE 1 END) AS graph_degree,
  p.location_basis,
  p.status AS point_status,
  'IDENTITY_TOPOLOGY_ONLY' AS mathematics_release
FROM ilb_acupuncture_point p
JOIN ilb_acupuncture_channel c ON c.channel_key = p.channel_key
WHERE p.status IN ('review','active');

CREATE OR REPLACE VIEW v_ilb_acupuncture_sequential_edge AS
SELECT
  p1.channel_key,
  c.channel_code,
  p1.point_id AS from_point_id,
  p1.point_code AS from_point_code,
  p2.point_id AS to_point_id,
  p2.point_code AS to_point_code,
  p1.point_number AS edge_order,
  1 AS adjacency_weight,
  'SEQUENTIAL_CODE_ORDER' AS edge_basis,
  'No physical meridian, anatomical continuity or physiological transmission is asserted.' AS boundary_text
FROM ilb_acupuncture_point p1
JOIN ilb_acupuncture_point p2
  ON p2.channel_key = p1.channel_key
 AND p2.point_number = p1.point_number + 1
JOIN ilb_acupuncture_channel c ON c.channel_key = p1.channel_key
WHERE p1.status IN ('review','active')
  AND p2.status IN ('review','active');

CREATE OR REPLACE VIEW v_ilb_acupuncture_channel_math AS
SELECT
  c.channel_key,
  c.channel_code,
  c.channel_name,
  COUNT(p.point_id) AS point_count,
  GREATEST(COUNT(p.point_id) - 1, 0) AS expected_sequential_edge_count,
  CASE WHEN COUNT(p.point_id) = 0 THEN 0
       ELSE (2.0 * GREATEST(COUNT(p.point_id) - 1, 0)) / COUNT(p.point_id)
  END AS mean_graph_degree,
  CASE WHEN COUNT(p.point_id) = 0 THEN 0
       WHEN COUNT(p.point_id) = 1 THEN 1 ELSE 2 END AS endpoint_count,
  'ORDERED_FINITE_PATH_GRAPH' AS valid_interpretation,
  'No physical or physiological channel is established.' AS boundary_text
FROM ilb_acupuncture_channel c
LEFT JOIN ilb_acupuncture_point p
  ON p.channel_key = c.channel_key
 AND p.status IN ('review','active')
WHERE c.status IN ('review','active')
GROUP BY c.channel_key, c.channel_code, c.channel_name;

CREATE OR REPLACE VIEW v_ilb_acupuncture_correlation_gate AS
SELECT
  x.correlation_candidate_id,
  x.math_model_key,
  x.point_id,
  p.point_code,
  x.external_domain,
  x.external_entity_key,
  x.external_entity_name,
  x.relation_type,
  x.mapping_source_key,
  x.source_locator,
  x.source_gate,
  x.frame_gate,
  x.entity_gate,
  x.measurement_gate,
  x.independent_validation_gate,
  x.governance_gate,
  (x.source_gate * x.frame_gate * x.entity_gate * x.measurement_gate *
   x.independent_validation_gate * x.governance_gate) AS release_product,
  CASE
    WHEN x.candidate_status = 'approved'
     AND (x.source_gate * x.frame_gate * x.entity_gate * x.measurement_gate *
          x.independent_validation_gate * x.governance_gate) = 1
    THEN 'RELEASED_NON_CAUSAL_RELATION'
    ELSE 'BLOCKED'
  END AS correlation_state,
  'Release, if achieved, means a traceable non-causal relation only.' AS allowed_statement,
  'No mechanism, efficacy, organ effect, treatment recommendation or health outcome is implied.' AS prohibited_statement
FROM ilb_acupuncture_correlation_candidate x
JOIN ilb_acupuncture_point p ON p.point_id = x.point_id;

CREATE OR REPLACE VIEW v_ilb_acupuncture_math_readiness AS
SELECT
  (SELECT COUNT(*) FROM ilb_acupuncture_point
    WHERE status IN ('review','active')) AS point_count,
  (SELECT COUNT(*) FROM ilb_acupuncture_channel
    WHERE status IN ('review','active')) AS channel_count,
  (SELECT COUNT(*) FROM v_ilb_acupuncture_sequential_edge) AS sequential_edge_count,
  (SELECT COUNT(*) FROM ilb_acupuncture_math_equation_master
    WHERE current_state = 'evaluable' AND equation_status = 'active') AS evaluable_equation_count,
  (SELECT COUNT(*) FROM ilb_acupuncture_math_equation_master
    WHERE current_state = 'blocked' AND equation_status = 'active') AS blocked_equation_count,
  (SELECT COUNT(*) FROM v_ilb_acupuncture_correlation_gate
    WHERE correlation_state = 'RELEASED_NON_CAUSAL_RELATION') AS released_correlation_count,
  CASE
    WHEN (SELECT COUNT(*) FROM ilb_acupuncture_point
           WHERE status IN ('review','active')) = 361
     AND (SELECT COUNT(*) FROM ilb_acupuncture_channel
           WHERE status IN ('review','active')) = 14
     AND (SELECT COUNT(*) FROM v_ilb_acupuncture_sequential_edge) = 347
    THEN 'IDENTITY_TOPOLOGY_READY'
    ELSE 'FOUNDATION_INCOMPLETE'
  END AS mathematics_readiness,
  'Geometry and external correlations remain independently gated.' AS readiness_boundary;

-- Post-apply verification (read-only):
-- SELECT * FROM v_ilb_acupuncture_math_readiness;
-- Expected only when the canonical point data are present:
-- point_count=361, channel_count=14, sequential_edge_count=347,
-- released_correlation_count=0, mathematics_readiness='IDENTITY_TOPOLOGY_READY'.
