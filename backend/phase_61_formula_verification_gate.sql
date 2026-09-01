-- Phase 61: source-first formula verification gate.
-- This adds no formulas. It records the evidence and reproducible test case
-- required before a formula may be marked VERIFIED.
START TRANSACTION;
CREATE TABLE IF NOT EXISTS ilb_equation_verification_case (
  verification_case_id bigint unsigned NOT NULL AUTO_INCREMENT,
  equation_id bigint unsigned NOT NULL,
  case_key varchar(160) NOT NULL,
  verification_method enum('SOURCE_WORKED_EXAMPLE','DIMENSIONAL_ANALYSIS','INVARIANT_CHECK','INDEPENDENT_RECALCULATION','OTHER') NOT NULL,
  input_payload_json longtext NOT NULL,
  expected_output_text text NOT NULL,
  expected_output_unit varchar(255) NULL,
  computed_output_text text NULL,
  evidence_locator varchar(1200) NOT NULL,
  verification_status enum('PENDING','PASS','FAIL','BLOCKED') NOT NULL DEFAULT 'PENDING',
  reviewer_note text NULL,
  reviewed_at datetime(6) NULL,
  created_at datetime(6) NOT NULL DEFAULT current_timestamp(6),
  PRIMARY KEY(verification_case_id),
  UNIQUE KEY uq_ilb_equation_verification_case(equation_id,case_key),
  KEY idx_ilb_equation_verification_status(verification_status),
  CONSTRAINT fk_ilb_equation_verification_equation
    FOREIGN KEY(equation_id) REFERENCES ilb_equation_registry(equation_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE OR REPLACE VIEW v_ilb_equation_verification_queue AS
SELECT e.equation_id,e.equation_key,e.equation_name,e.equation_class,
       e.expression_text,e.input_unit_contract,e.output_unit_contract,
       e.evidence_locator,e.validation_status,
       COUNT(c.verification_case_id) AS verification_case_count,
       COALESCE(SUM(c.verification_status='PASS'),0) AS passed_case_count,
       COALESCE(SUM(c.verification_status='FAIL'),0) AS failed_case_count,
       CASE
         WHEN e.evidence_locator='' THEN 'BLOCKED_NO_SOURCE'
         WHEN COUNT(c.verification_case_id)=0 THEN 'PENDING_NO_CASE'
         WHEN SUM(c.verification_status='FAIL')>0 THEN 'FAILED'
         WHEN SUM(c.verification_status='PASS')=COUNT(c.verification_case_id)
           AND e.validation_status='VERIFIED' THEN 'VERIFIED'
         WHEN SUM(c.verification_status='PASS')=COUNT(c.verification_case_id)
           THEN 'READY_FOR_REVIEW'
         ELSE 'PENDING'
       END AS verification_gate
  FROM ilb_equation_registry e
  LEFT JOIN ilb_equation_verification_case c ON c.equation_id=e.equation_id
 GROUP BY e.equation_id,e.equation_key,e.equation_name,e.equation_class,
          e.expression_text,e.input_unit_contract,e.output_unit_contract,
          e.evidence_locator,e.validation_status;
COMMIT;