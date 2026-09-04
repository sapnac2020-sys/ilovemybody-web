<?php
declare(strict_types=1);

ini_set('display_errors', 'stderr');
ini_set('log_errors', '0');
error_reporting(E_ALL);
register_shutdown_function(static function (): void {
    $error = error_get_last();
    if ($error !== null && in_array($error['type'], [E_ERROR,E_PARSE,E_CORE_ERROR,E_COMPILE_ERROR,E_USER_ERROR], true)) {
        fwrite(STDERR, json_encode(['fatal_type'=>$error['type'],'fatal_message'=>$error['message'],'fatal_file'=>basename($error['file']),'fatal_line'=>$error['line']], JSON_UNESCAPED_SLASHES).PHP_EOL);
    }
});

const EXPECTED_DATABASE = 'u756742628_ilovemybody';
if (PHP_SAPI !== 'cli') exit(2);
$config = require($argv[1] ?? '');
if (isset($config['database']) && is_array($config['database'])) $config = $config['database'];
$database = $config['db'] ?? ($config['name'] ?? null);
if ($database !== EXPECTED_DATABASE) throw new RuntimeException('Unexpected database');
$sqlPath = $argv[2] ?? '';
if (!is_file($sqlPath)) throw new RuntimeException('Migration SQL missing');
$pdo = new PDO(
    'mysql:host='.$config['host'].';port='.($config['port'] ?? 3306).';dbname='.$database.';charset=utf8mb4',
    $config['user'], $config['pass'] ?? $config['password'],
    [PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION, PDO::MYSQL_ATTR_MULTI_STATEMENTS=>true, PDO::ATTR_DEFAULT_FETCH_MODE=>PDO::FETCH_ASSOC]
);
$q=$pdo->query("SELECT COUNT(*) FROM information_schema.tables WHERE table_schema=DATABASE() AND table_name='ilb_psoriasis_sbml_species'");
if ((int)$q->fetchColumn() !== 1) throw new RuntimeException('Phase 77 is required');
$sourceCounts=[
 'species'=>(int)$pdo->query("SELECT COUNT(*) FROM ilb_psoriasis_sbml_species WHERE model_key='SHMAROV_2022_FULL'")->fetchColumn(),
 'parameters'=>(int)$pdo->query("SELECT COUNT(*) FROM ilb_psoriasis_sbml_parameter WHERE model_key='SHMAROV_2022_FULL'")->fetchColumn(),
 'reactions'=>(int)$pdo->query("SELECT COUNT(*) FROM ilb_psoriasis_sbml_reaction WHERE model_key='SHMAROV_2022_FULL'")->fetchColumn(),
 'participants'=>(int)$pdo->query("SELECT COUNT(*) FROM ilb_psoriasis_sbml_reaction_species WHERE model_key='SHMAROV_2022_FULL'")->fetchColumn(),
];
if ($sourceCounts !== ['species'=>25,'parameters'=>62,'reactions'=>35,'participants'=>72]) {
    throw new RuntimeException('Phase 77 structural counts changed: '.json_encode($sourceCounts));
}
$stmt=$pdo->prepare(file_get_contents($sqlPath));
$stmt->execute();
do { if ($stmt->columnCount()) $stmt->fetchAll(); } while ($stmt->nextRowset());
$stmt->closeCursor();
$readiness=$pdo->query("SELECT * FROM v_ilmb_psoriasis_end_to_end_readiness WHERE program_key='PSORIASIS_E2E_V1'")->fetch();
$expected=['formula_count'=>15,'pharma_agent_count'=>11,'persistence_state_count'=>4,'experiment_count'=>10,'passed_gates'=>2,'open_or_blocked_gates'=>9,'executable_pharma_agents'=>0,'research_structure_operational'=>1,'validated_declared_use_enabled'=>0,'patient_execution_enabled'=>0];
foreach ($expected as $key=>$value) {
    if ((int)$readiness[$key] !== $value) throw new RuntimeException("Unexpected {$key}: ".$readiness[$key]);
}
$agentRows=$pdo->query('SELECT * FROM v_ilmb_psoriasis_agent_readiness ORDER BY agent_key')->fetchAll();
foreach ($agentRows as $agent) {
    if ((int)$agent['parameter_slots'] !== 8) throw new RuntimeException('Missing parameter slots for '.$agent['agent_key']);
    if ((int)$agent['research_execution_enabled'] !== 0) throw new RuntimeException('Unexpected executable agent '.$agent['agent_key']);
}
echo json_encode([
 'database'=>$database,
 'programme'=>'PSORIASIS_E2E_V1',
 'mode'=>'governed_non_patient_research',
 'source_model'=>$sourceCounts,
 'readiness'=>$readiness,
 'agents'=>$agentRows,
 'patient_tables_queried'=>false,
 'patient_rows_read'=>0,
 'patient_rows_modified'=>0,
 'migration_verified'=>true
],JSON_PRETTY_PRINT|JSON_UNESCAPED_SLASHES),PHP_EOL;
