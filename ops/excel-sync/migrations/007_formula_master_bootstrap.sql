-- Bootstrap the new Formula Master from ILMB's existing governed equation registry.
-- This is an index/snapshot with provenance; it does not replace the legacy registry.

ALTER TABLE ilmb_formula_master
  ADD COLUMN IF NOT EXISTS source_system VARCHAR(64) NULL AFTER evidence_class,
  ADD COLUMN IF NOT EXISTS source_record_key VARCHAR(191) NULL AFTER source_system,
  ADD UNIQUE KEY IF NOT EXISTS uq_ilmb_formula_source (source_system, source_record_key);

INSERT INTO ilmb_formula_master (
  formula_key, formula_name, formula_domain, output_parameter_id,
  expression_text, expression_language, purpose, evidence_class,
  source_system, source_record_key, source_citation,
  formula_status, unit_checked, dimensional_analysis_text
)
SELECT
  CONCAT('equation_registry:', e.equation_key),
  e.equation_name,
  COALESCE(NULLIF(e.equation_class,''),'OTHER'),
  NULL,
  e.equation_expression,
  'EQUATION_TEXT',
  CASE
    WHEN UPPER(e.equation_class) LIKE '%PHYSIC%' THEN 'PHYSICS'
    WHEN UPPER(e.equation_class) LIKE '%CHEM%' THEN 'CHEMISTRY'
    WHEN UPPER(e.equation_class) LIKE '%PHYSIOL%' THEN 'PHYSIOLOGY'
    ELSE 'OTHER'
  END,
  'PUBLISHED_MODEL',
  'ilb_equation_registry',
  e.equation_key,
  e.evidence_locator,
  CASE WHEN e.validation_status='VERIFIED' THEN 'VERIFIED' ELSE 'DRAFT' END,
  CASE WHEN EXISTS (
    SELECT 1 FROM ilb_equation_verification_case vc
     WHERE vc.equation_id=e.equation_id
       AND vc.verification_method='DIMENSIONAL_ANALYSIS'
       AND vc.verification_status='PASS'
  ) THEN 1 ELSE 0 END,
  CONCAT('input_unit_contract=',COALESCE(e.input_unit_contract,''),'; output_unit_contract=',COALESCE(e.output_unit_contract,''))
FROM ilb_equation_registry e
ON DUPLICATE KEY UPDATE
  formula_name=VALUES(formula_name),
  formula_domain=VALUES(formula_domain),
  expression_text=VALUES(expression_text),
  source_citation=VALUES(source_citation),
  formula_status=VALUES(formula_status),
  unit_checked=VALUES(unit_checked),
  dimensional_analysis_text=VALUES(dimensional_analysis_text),
  updated_at=CURRENT_TIMESTAMP;
