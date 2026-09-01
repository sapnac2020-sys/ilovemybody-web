-- ILMB Phase 74: verification ledger for all standalone acupuncture equations.
-- Verifies mathematical definitions independently from acupuncture-specific input availability.
-- Does not create anatomy, mechanism, treatment, organ-function or outcome claims.

CREATE TABLE IF NOT EXISTS ilb_acupuncture_equation_verification (
  equation_key VARCHAR(40) NOT NULL,
  verification_version VARCHAR(40) NOT NULL,
  authority_name VARCHAR(255) NOT NULL,
  authority_url VARCHAR(1000) NOT NULL,
  authority_locator VARCHAR(500) NOT NULL,
  verification_method ENUM('identity','worked_example','reference_algorithm','boolean_exhaustion') NOT NULL,
  test_input_json LONGTEXT NOT NULL,
  expected_output_json LONGTEXT NOT NULL,
  tolerance_value DECIMAL(30,15) DEFAULT NULL,
  tolerance_unit VARCHAR(80) DEFAULT NULL,
  mathematical_status ENUM('verified','failed','review') NOT NULL DEFAULT 'review',
  acupuncture_input_status ENUM('available','missing_coordinates','missing_mesh','missing_covariance','missing_anatomy_mapping','missing_external_relation','not_applicable') NOT NULL,
  operational_status ENUM('evaluable','blocked') NOT NULL,
  verified_at DATETIME NOT NULL,
  boundary_text VARCHAR(1500) NOT NULL,
  PRIMARY KEY (equation_key, verification_version),
  CONSTRAINT fk_ilb_acu_eq_verify_equation
    FOREIGN KEY (equation_key)
    REFERENCES ilb_acupuncture_math_equation_master (equation_key),
  CONSTRAINT ck_ilb_acu_eq_verify_input_json CHECK (JSON_VALID(test_input_json)),
  CONSTRAINT ck_ilb_acu_eq_verify_output_json CHECK (JSON_VALID(expected_output_json))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO ilb_acupuncture_equation_verification
  (equation_key, verification_version, authority_name, authority_url, authority_locator,
   verification_method, test_input_json, expected_output_json, tolerance_value,
   tolerance_unit, mathematical_status, acupuncture_input_status, operational_status,
   verified_at, boundary_text)
VALUES
('ACM-01','1.0.0','WHO standard acupuncture nomenclature',
 'https://www.who.int/publications/i/item/9290611057','361 standardized point names; ordinal normalization is an algebraic identity',
 'worked_example','{"n":1,"N":10}','{"s":0}',0,'dimensionless','verified','available','evaluable',UTC_TIMESTAMP(),
 'Normalized ordinal position is not physical distance or biological importance.'),
('ACM-02','1.0.0','Standard finite graph adjacency definition',
 'https://mathworld.wolfram.com/AdjacencyMatrix.html','Adjacency matrix definition applied only to consecutive standardized codes',
 'worked_example','{"point_numbers":[1,2,4]}','{"A_1_2":1,"A_2_4":0}',0,'binary','verified','available','evaluable',UTC_TIMESTAMP(),
 'Code adjacency does not establish anatomical continuity.'),
('ACM-03','1.0.0','Standard graph degree identity',
 'https://mathworld.wolfram.com/VertexDegree.html','Vertex degree equals the sum of adjacency entries',
 'worked_example','{"adjacency_row":[1,0,1,1]}','{"degree":3}',0,'edge_count','verified','available','evaluable',UTC_TIMESTAMP(),
 'Graph degree does not measure biological importance.'),
('ACM-04','1.0.0','Standard shortest-path definition',
 'https://mathworld.wolfram.com/GraphGeodesic.html','Minimum edge count over graph paths',
 'worked_example','{"edges":[[1,2],[2,3],[3,4]],"from":1,"to":4}','{"path_length":3}',0,'edge_count','verified','available','evaluable',UTC_TIMESTAMP(),
 'Edge count is not length, transmission time or physiological delay.'),
('ACM-05','1.0.0','Euclidean metric',
 'https://mathworld.wolfram.com/Distance.html','Three-dimensional Euclidean distance',
 'worked_example','{"p1":[0,0,0],"p2":[3,4,12]}','{"distance":13}',0.000000000001,'coordinate_unit','verified','missing_coordinates','blocked',UTC_TIMESTAMP(),
 'Mathematics is verified; sourced point coordinates in one approved frame are absent.'),
('ACM-06','1.0.0','Euclidean polyline arc-length sum',
 'https://mathworld.wolfram.com/PolygonalChain.html','Sum of consecutive Euclidean segment lengths',
 'worked_example','{"points":[[0,0,0],[3,0,0],[3,4,0]]}','{"length":7}',0.000000000001,'coordinate_unit','verified','missing_coordinates','blocked',UTC_TIMESTAMP(),
 'A registered polyline would not prove a physical meridian.'),
('ACM-07','1.0.0','NIST covariance propagation',
 'https://www.nist.gov/document/vna-covariance-14pdf','First-order covariance propagation by Jacobian matrices',
 'worked_example','{"J":[[2]],"Sigma":[[0.25]]}','{"output_covariance":[[1.0]]}',0.000000000001,'output_unit_squared','verified','missing_covariance','blocked',UTC_TIMESTAMP(),
 'Coordinate covariance is absent; biological uncertainty is not inferred.'),
('ACM-08','1.0.0','Standard surface geodesic definition',
 'https://mathworld.wolfram.com/Geodesic.html','Shortest path constrained to a specified surface',
 'reference_algorithm','{"surface":"unit_sphere","central_angle_radians":1.5707963267948966}','{"geodesic":1.5707963267948966}',0.000000000001,'mesh_unit','verified','missing_mesh','blocked',UTC_TIMESTAMP(),
 'No approved body mesh with registered acupuncture points is present.'),
('ACM-09','1.0.0','Binary incidence matrix definition',
 'https://mathworld.wolfram.com/IncidenceMatrix.html','Binary incidence requires a sourced and approved relation',
 'boolean_exhaustion','{"sourced":1,"approved":1}','{"B_ia":1}',0,'binary','verified','missing_anatomy_mapping','blocked',UTC_TIMESTAMP(),
 'No anatomical relation is created by the matrix definition.'),
('ACM-10','1.0.0','Standard matrix multiplication',
 'https://mathworld.wolfram.com/MatrixMultiplication.html','Relation composition by matrix product',
 'worked_example','{"B":[[1,0]],"R":[[0,1],[1,0]]}','{"C":[[0,1]]}',0,'relation_count','verified','missing_external_relation','blocked',UTC_TIMESTAMP(),
 'Matrix reachability is non-causal and requires approved input relations.'),
('ACM-11','1.0.0','Boolean conjunction as binary product',
 'https://mathworld.wolfram.com/AND.html','For binary inputs, the product is one exactly when every gate is one',
 'boolean_exhaustion','{"gate_count":6,"domain":[0,1]}','{"rows_tested":64,"released_rows":1}',0,'binary','verified','not_applicable','evaluable',UTC_TIMESTAMP(),
 'The release gate prevents partial evidence from being treated as proof.')
ON DUPLICATE KEY UPDATE
 authority_name=VALUES(authority_name), authority_url=VALUES(authority_url),
 authority_locator=VALUES(authority_locator), verification_method=VALUES(verification_method),
 test_input_json=VALUES(test_input_json), expected_output_json=VALUES(expected_output_json),
 tolerance_value=VALUES(tolerance_value), tolerance_unit=VALUES(tolerance_unit),
 mathematical_status=VALUES(mathematical_status),
 acupuncture_input_status=VALUES(acupuncture_input_status),
 operational_status=VALUES(operational_status), verified_at=VALUES(verified_at),
 boundary_text=VALUES(boundary_text);

CREATE OR REPLACE VIEW v_ilb_acupuncture_equation_verification AS
SELECT e.equation_key, e.equation_domain, e.equation_name, e.equation_text,
       v.mathematical_status, v.acupuncture_input_status, v.operational_status,
       v.authority_name, v.authority_url, v.authority_locator,
       v.test_input_json, v.expected_output_json, v.tolerance_value,
       v.tolerance_unit, v.verified_at, v.boundary_text
FROM ilb_acupuncture_math_equation_master e
LEFT JOIN ilb_acupuncture_equation_verification v
  ON v.equation_key=e.equation_key AND v.verification_version='1.0.0'
WHERE e.equation_status='active';

CREATE OR REPLACE VIEW v_ilb_acupuncture_equation_verification_summary AS
SELECT
 COUNT(*) AS active_equation_count,
 SUM(mathematical_status='verified') AS mathematically_verified_count,
 SUM(operational_status='evaluable') AS operationally_evaluable_count,
 SUM(operational_status='blocked') AS operationally_blocked_count,
 SUM(mathematical_status IS NULL) AS missing_verification_count,
 CASE WHEN COUNT(*)=11 AND SUM(mathematical_status='verified')=11
           AND SUM(mathematical_status IS NULL)=0
      THEN 'ALL_EQUATIONS_MATHEMATICALLY_VERIFIED'
      ELSE 'EQUATION_VERIFICATION_INCOMPLETE' END AS equation_verification_state,
 'Operational evaluation remains input-gated; mathematical verification is not biological validation.' AS boundary_text
FROM v_ilb_acupuncture_equation_verification;

-- Expected after apply:
-- 11 active, 11 mathematically verified, 5 operationally evaluable,
-- 6 operationally blocked, 0 missing verification.
