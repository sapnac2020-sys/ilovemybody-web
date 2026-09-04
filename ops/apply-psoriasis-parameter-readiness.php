<?php
declare(strict_types=1);
ini_set('display_errors', 'stderr');
error_reporting(E_ALL);
const EXPECTED_DATABASE = 'u756742628_ilovemybody';
if (PHP_SAPI !== 'cli') exit(2);

$config = require($argv[1] ?? '');
if (isset($config['database']) && is_array($config['database'])) $config = $config['database'];
$database = $config['db'] ?? ($config['name'] ?? null);
if ($database !== EXPECTED_DATABASE) throw new RuntimeException('Unexpected database');
$sqlPath = $argv[2] ?? '';
if (!is_file($sqlPath)) throw new RuntimeException('Phase 94 SQL missing');

$pdo = new PDO(
 'mysql:host='.$config['host'].';port='.($config['port'] ?? 3306).';dbname='.$database.';charset=utf8mb4',
 $config['user'],
 $config['pass'] ?? $config['password'],
 [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION, PDO::MYSQL_ATTR_MULTI_STATEMENTS => true, PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC]
);
$s = $pdo->prepare(file_get_contents($sqlPath));
$s->execute();
do { if ($s->columnCount()) $s->fetchAll(); } while ($s->nextRowset());
$s->closeCursor();

$plans = $pdo->query("SELECT parameter_key,resolution_class,status,clinical_to_invitro_conversion_allowed,patient_experiment_required FROM ilb_psoriasis_parameter_resolution_plan ORDER BY parameter_key")->fetchAll();
$rules = $pdo->query("SELECT rule_key,outcome_class,claim_ceiling,invented_coefficient_count FROM ilb_psoriasis_experiment_decision_rule WHERE experiment_key='EXP_PSO_RESET_001' ORDER BY rule_key")->fetchAll();
$open = array_values(array_filter($plans, static fn(array $r): bool => $r['status'] === 'OPEN'));
$unresolved = (int)$pdo->query("SELECT COUNT(*) FROM ilb_psoriasis_experiment_parameter WHERE experiment_key='EXP_PSO_RESET_001' AND required_for_execution=1 AND resolution='UNRESOLVED'")->fetchColumn();

if (count($plans) !== 10 || count($rules) !== 5 || count($open) !== 10 || $unresolved !== 10) throw new RuntimeException('Phase 94 invariant failed');
if (array_sum(array_column($plans, 'clinical_to_invitro_conversion_allowed')) !== 0 || array_sum(array_column($plans, 'patient_experiment_required')) !== 0) throw new RuntimeException('Phase 94 safety invariant failed');
if (array_sum(array_column($rules, 'invented_coefficient_count')) !== 0) throw new RuntimeException('Phase 94 coefficient invariant failed');

echo json_encode([
 'database' => $database,
 'phase' => 'P94_PARAMETER_IDENTIFIABILITY_AND_DECISION_GATE',
 'resolution_plan_count' => count($plans),
 'resolution_plans' => $plans,
 'decision_rule_count' => count($rules),
 'decision_rules' => $rules,
 'open_execution_parameters' => count($open),
 'experiment_executable' => count($open) === 0 && $unresolved === 0,
 'clinical_dose_conversions' => 0,
 'invented_coefficients' => 0,
 'patient_experiment_required' => false,
 'patient_tables_queried' => false,
 'patient_rows_read' => 0,
 'patient_rows_modified' => 0,
 'verified' => true
], JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES), PHP_EOL;
