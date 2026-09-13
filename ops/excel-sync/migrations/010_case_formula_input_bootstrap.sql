-- Consolidate existing governed case-formula inputs into the canonical Formula Master.
-- input_key is the source contract used by ilb_case_formula_input; it is linked only when
-- an exact case_variable:<input_key> parameter already exists. Unresolved inputs are not fabricated.

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
  1,
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
   = CONVERT(CONCAT('case_variable:',i.input_key) USING utf8mb4) COLLATE utf8mb4_bin
WHERE i.input_key IS NOT NULL
  AND i.input_key<>''
ON DUPLICATE KEY UPDATE
  parameter_id=VALUES(parameter_id),
  role=VALUES(role),
  required_flag=VALUES(required_flag),
  expected_ucum_unit=VALUES(expected_ucum_unit),
  notes=VALUES(notes);
