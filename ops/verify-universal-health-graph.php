<?php
declare(strict_types=1);

const EXPECTED_DATABASE = 'u756742628_ilovemybody';

if (PHP_SAPI !== 'cli') {
    fwrite(STDERR, "CLI only.\n");
    exit(2);
}

$configPath = $argv[1] ?? '';
$migrationPath = $argv[2] ?? '';
if (!is_file($configPath) || !is_file($migrationPath)) {
    fwrite(STDERR, "Usage: php verify-universal-health-graph.php <config.php> <migration.sql>\n");
    exit(2);
}

$config = require $configPath;
$db = is_array($config['db'] ?? null) ? $config['db'] : [
    'host' => $config['host'] ?? null,
    'port' => $config['port'] ?? 3306,
    'name' => $config['db'] ?? null,
    'user' => $config['user'] ?? null,
    'pass' => $config['pass'] ?? null,
    'charset' => $config['charset'] ?? 'utf8mb4',
];
if (($db['name'] ?? $config['db'] ?? '') !== EXPECTED_DATABASE) {
    throw new RuntimeException('Refusing non-ILMB database.');
}

$pdo = new PDO(
    sprintf('mysql:host=%s;port=%d;dbname=%s;charset=%s', $db['host'], $db['port'] ?? 3306, EXPECTED_DATABASE, $db['charset'] ?? 'utf8mb4'),
    (string)$db['user'], (string)$db['pass'],
    [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION, PDO::MYSQL_ATTR_MULTI_STATEMENTS => true]
);
$sql = file_get_contents($migrationPath);
if ($sql === false || trim($sql) === '') {
    throw new RuntimeException('Migration is empty.');
}
$stmt = $pdo->prepare($sql);
$stmt->execute();
do { if ($stmt->columnCount() > 0) { $stmt->fetchAll(); } } while ($stmt->nextRowset());
$stmt->closeCursor();

$required = [
    'ilb_semantic_type','ilb_semantic_entity','ilb_entity_identifier','ilb_relation_type','ilb_entity_relation',
    'ilb_field_mapping','ilb_projection_run','ilb_projection_error','ilb_variable_definition',
    'ilb_equation_definition','ilb_equation_dependency','ilb_equation_gate','ilb_calculation_run',
    'ilb_calculation_value','ilb_hospital_report','ilb_hospital_report_section','ilb_hospital_report_gate'
];
$placeholders = implode(',', array_fill(0, count($required), '?'));
$check = $pdo->prepare("SELECT table_name FROM information_schema.tables WHERE table_schema=? AND table_name IN ($placeholders)");
$check->execute(array_merge([EXPECTED_DATABASE], $required));
$present = $check->fetchAll(PDO::FETCH_COLUMN);
$missing = array_values(array_diff($required, $present));
if ($missing) {
    throw new RuntimeException('Missing objects: '.implode(', ', $missing));
}
$rows = $pdo->query('SELECT * FROM v_ilb_universal_platform_readiness')->fetchAll(PDO::FETCH_ASSOC);
echo json_encode(['schema_objects'=>count($present),'readiness'=>$rows], JSON_PRETTY_PRINT|JSON_UNESCAPED_SLASHES)."\n";
