-- Consolidate existing governed case-formula source inputs into the canonical parameter/formula graph.
-- These are SOURCE FIELD parameters, not clinical ontology assertions. No LOINC/ChEBI identity is inferred.
-- Exact provenance is retained as source_table/source_column/input_key and formulas remain governed separately.

INSERT INTO ilmb_parameter_master (
  parameter_key,
  canonical_name,
  parameter_domain,
  value_kind,
  canonical_ucum_unit,
  specimen_or_context,
  body_scope,
  definition_text,
  source_system,
  source_record_key,
  status
)
SELECT DISTINCT
  CONCAT('case_input:',i.input_key),
  i.input_key,
  'case_input',
  'numeric',
  NULLIF(i.expected_unit,''),
  NULL,
  NULL,
  CONCAT_WS('; ',
    NULLIF(i.note,''),
    NULLIF(CONCAT('source=',COALESCE(i.source_table,''),'.',COALESCE(i.source_column,'')), 'source=.'),
    NULLIF(CONCAT('lag_rule=',COALESCE(i.lag_rule,'')), 'lag_rule=')
  ),
  'ilb_case_formula_input',
  i.input_key,
  'ACTIVE'
FROM ilb_case_formula_input i
WHERE i.input_key IS NOT NULL
  AND i.input_key<>''
ON DUPLICATE KEY UPDATE
  canonical_ucum_unit=COALESCE(VALUES(canonical_ucum_unit),ilmb_parameter_master.canonical_ucum_unit),
  definition_text=COALESCE(VALUES(definition_text),ilmb_parameter_master.definition_text),
  status='ACTIVE',
  updated_at=CURRENT_TIMESTAMP;

INSERT INTO ilmb_formula_input (
  formula_id,
  symbol_name,
  parameter_id,
  role,
  required_flag,
  expected_ucum_unit,
  ordinal,
  notes
)
SELECT
  f.formula_id,
  LEFT(i.input_key,64),
  p.parameter_id,
  CASE
    WHEN UPPER(i.input_role) LIKE '%MEASURED%' THEN 'MEASURED'
    WHEN UPPER(i.input_role) LIKE '%TARGET%' THEN 'TARGET'
    WHEN UPPER(i.input_role) LIKE '%CONSTANT%' THEN 'CONSTANT'
    WHEN UPPER(i.input_role) LIKE '%COEFFICIENT%' THEN 'COEFFICIENT'
    WHEN UPPER(i.input_role) LIKE '%DERIVED%' THEN 'DERIVED'
    ELSE 'CONTEXT'
  END,
  COALESCE(i.required_flag,1),
  NULLIF(i.expected_unit,''),
  ROW_NUMBER() OVER (PARTITION BY i.case_formula_key ORDER BY i.input_key),
  CONCAT_WS('; ',
    NULLIF(CONCAT('source=',COALESCE(i.source_table,''),'.',COALESCE(i.source_column,'')), 'source=.'),
    NULLIF(CONCAT('lag_rule=',COALESCE(i.lag_rule,'')), 'lag_rule='),
    NULLIF(i.note,'')
  )
FROM ilb_case_formula_input i
JOIN ilmb_formula_master f
  ON CONVERT(f.formula_key USING utf8mb4) COLLATE utf8mb4_bin
   = CONVERT(CONCAT('case_formula:',i.case_formula_key) USING utf8mb4) COLLATE utf8mb4_bin
JOIN ilmb_parameter_master p
  ON CONVERT(p.parameter_key USING utf8mb4) COLLATE utf8mb4_bin
   = CONVERT(CONCAT('case_input:',i.input_key) USING utf8mb4) COLLATE utf8mb4_bin
WHERE i.input_key IS NOT NULL
  AND i.input_key<>''
ON DUPLICATE KEY UPDATE
  parameter_id=VALUES(parameter_id),
  role=VALUES(role),
  required_flag=VALUES(required_flag),
  expected_ucum_unit=VALUES(expected_ucum_unit),
  ordinal=VALUES(ordinal),
  notes=VALUES(notes);
