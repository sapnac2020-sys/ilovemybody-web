<?php
// Phase 108 production verifier: psoriasis equations and coefficient governance.
header('Content-Type: application/json');

$result = [
  'ok' => false,
  'stage' => 'init',
  'database' => null,
  'checks' => [],
  'safety_rule' => 'No numeric ODE coefficient may be invented. Literature kinetic observations are context-only unless explicitly validated as the same model parameter.'
];

try {
  $configCandidates = [
    __DIR__ . '/../config.php',
    __DIR__ . '/../backend/config.php',
    __DIR__ . '/../api/config.php'
  ];
  $config = null;
  foreach ($configCandidates as $candidate) {
    if (file_exists($candidate)) { $config = $candidate; break; }
  }
  if (!$config) throw new RuntimeException('Database config file not found');
  require $config;

  if (isset($pdo) && $pdo instanceof PDO) {
    $db = $pdo;
  } elseif (function_exists('getDb')) {
    $db = getDb();
  } elseif (function_exists('db')) {
    $db = db();
  } else {
    throw new RuntimeException('No PDO connection found after loading config');
  }

  $result['database'] = $db->query('SELECT DATABASE()')->fetchColumn();
  $result['stage'] = 'migration';

  $sqlPath = __DIR__ . '/../backend/phase_108_psoriasis_equation_coefficients.sql';
  if (!file_exists($sqlPath)) throw new RuntimeException('Phase 108 SQL missing');
  $sql = file_get_contents($sqlPath);

  // Execute one statement at a time to surface the exact failure point.
  $statements = preg_split('/;\s*(?:\r?\n|$)/', $sql);
  $executed = 0;
  foreach ($statements as $i => $statement) {
    $statement = trim($statement);
    if ($statement === '' || preg_match('/^--/', $statement) && !preg_match('/\n[^-]/', $statement)) continue;
    // Strip leading SQL comment lines while preserving statement body.
    $statement = preg_replace('/^(?:\s*--[^\n]*\n)+/', '', $statement);
    $statement = trim($statement);
    if ($statement === '') continue;
    try {
      $db->exec($statement);
      $executed++;
    } catch (Throwable $e) {
      throw new RuntimeException('Statement '.($i+1).' failed: '.$e->getMessage().' | SQL: '.substr(preg_replace('/\s+/', ' ', $statement),0,400), 0, $e);
    }
  }
  $result['migration_statements'] = $executed;

  $result['stage'] = 'verify';
  $row = $db->query('SELECT * FROM v_ilb_psoriasis_math_readiness')->fetch(PDO::FETCH_ASSOC);
  if (!$row) throw new RuntimeException('Readiness view returned no row');

  $checks = [
    'equations_9' => ((int)$row['equation_count'] === 9),
    'parameters_at_least_23' => ((int)$row['parameter_count'] >= 23),
    'all_model_parameters_unfit' => ((int)$row['numeric_parameter_count'] === 0),
    'unknown_parameters_at_least_23' => ((int)$row['unknown_parameter_count'] >= 23),
    'kinetic_observations_at_least_5' => ((int)$row['kinetic_observation_count'] >= 5),
    'measurement_mappings_at_least_15' => ((int)$row['measurement_mapping_count'] >= 15),
    'sources_at_least_7' => ((int)$row['source_count'] >= 7),
    'readiness_correct' => ($row['readiness_status'] === 'STRUCTURE_READY_COEFFICIENTS_UNFIT')
  ];

  $badNumeric = (int)$db->query("SELECT COUNT(*) FROM ilb_psoriasis_parameter WHERE value_numeric IS NOT NULL")->fetchColumn();
  $historicalMisuse = (int)$db->query("SELECT COUNT(*) FROM ilb_psoriasis_kinetic_observation WHERE model_use_status <> 'CONTEXT_ONLY'")->fetchColumn();
  $clearance = $db->query('SELECT * FROM v_ilb_psoriasis_clearance_condition')->fetch(PDO::FETCH_ASSOC);
  $checks['zero_invented_numeric_coefficients'] = ($badNumeric === 0);
  $checks['historical_kinetics_context_only'] = ($historicalMisuse === 0);
  $checks['symbolic_clearance_condition_present'] = ($clearance && $clearance['governance_status'] === 'NO_CURE_CLAIM');

  $result['checks'] = $checks;
  $result['readiness'] = $row;
  $result['clearance_condition'] = $clearance;
  $result['ok'] = !in_array(false, $checks, true);
  $result['stage'] = $result['ok'] ? 'complete' : 'failed_checks';

} catch (Throwable $e) {
  $result['ok'] = false;
  $result['stage'] = $result['stage'] ?: 'exception';
  $result['exception'] = get_class($e);
  $result['error'] = $e->getMessage();
  $result['file'] = $e->getFile();
  $result['line'] = $e->getLine();
}

echo json_encode($result, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES), PHP_EOL;
exit($result['ok'] ? 0 : 1);
