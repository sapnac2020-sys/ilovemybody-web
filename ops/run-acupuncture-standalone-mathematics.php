<?php
declare(strict_types=1);

error_reporting(E_ALL);
ini_set('display_errors', 'stderr');

set_exception_handler(static function (Throwable $error): void {
    fwrite(STDERR, json_encode([
        'verified' => false,
        'error_type' => get_class($error),
        'error_message' => $error->getMessage(),
        'error_file' => basename($error->getFile()),
        'error_line' => $error->getLine(),
    ], JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES) . PHP_EOL);
    exit(70);
});

if ($argc !== 3) {
    fwrite(STDERR, "Usage: php {$argv[0]} <config.php> <migration.sql>\n");
    exit(64);
}

$config = require $argv[1];
$sql = file_get_contents($argv[2]);
if ($sql === false) {
    throw new RuntimeException('Unable to read migration SQL.');
}

if (!is_array($config)) {
    throw new RuntimeException('Configuration file must return an array.');
}

$hasDsnContract = isset($config['dsn'], $config['username'], $config['password']);
$hasHostContract = isset($config['host'], $config['db'], $config['user'], $config['pass']);
if (!$hasDsnContract && !$hasHostContract) {
    throw new RuntimeException(
        'Unsupported configuration contract; available keys: ' . implode(', ', array_keys($config))
    );
}

if ($hasDsnContract) {
    $dsn = (string) $config['dsn'];
    $username = (string) $config['username'];
    $password = (string) $config['password'];
} else {
    $charset = isset($config['charset']) ? (string) $config['charset'] : 'utf8mb4';
    $port = isset($config['port']) ? (int) $config['port'] : 3306;
    $dsn = sprintf(
        'mysql:host=%s;port=%d;dbname=%s;charset=%s',
        (string) $config['host'],
        $port,
        (string) $config['db'],
        $charset
    );
    $username = (string) $config['user'];
    $password = (string) $config['pass'];
}

$pdoOptions = [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION];
if (!empty($config['init_command']) && defined('PDO::MYSQL_ATTR_INIT_COMMAND')) {
    $pdoOptions[PDO::MYSQL_ATTR_INIT_COMMAND] = (string) $config['init_command'];
}

$pdo = new PDO(
    $dsn,
    $username,
    $password,
    $pdoOptions
);

$required = ['ilb_acupuncture_point', 'ilb_acupuncture_channel'];
$placeholders = implode(',', array_fill(0, count($required), '?'));
$statement = $pdo->prepare(
    "SELECT table_name FROM information_schema.tables
     WHERE table_schema = DATABASE() AND table_name IN ($placeholders)"
);
$statement->execute($required);
$present = array_column($statement->fetchAll(PDO::FETCH_ASSOC), 'table_name');
$missing = array_values(array_diff($required, $present));
if ($missing !== []) {
    throw new RuntimeException(
        'Migration not applied: prerequisite table(s) missing: ' . implode(', ', $missing)
    );
}

$pdo->exec($sql);

$readiness = $pdo->query(
    'SELECT point_count, channel_count, sequential_edge_count,
            evaluable_equation_count, blocked_equation_count,
            released_correlation_count, mathematics_readiness,
            readiness_boundary
       FROM v_ilb_acupuncture_math_readiness'
)->fetch(PDO::FETCH_ASSOC);

$pointStatus = $pdo->query(
    'SELECT status, COUNT(*) AS point_count
       FROM ilb_acupuncture_point
      GROUP BY status
      ORDER BY status'
)->fetchAll(PDO::FETCH_ASSOC);

if ($readiness === false) {
    throw new RuntimeException('Migration applied but readiness view returned no row.');
}

$expected = [
    'point_count' => 361,
    'channel_count' => 14,
    'sequential_edge_count' => 347,
    'released_correlation_count' => 0,
    'mathematics_readiness' => 'IDENTITY_TOPOLOGY_READY',
];

$mismatches = [];
foreach ($expected as $field => $value) {
    if ((string) $readiness[$field] !== (string) $value) {
        $mismatches[$field] = ['expected' => $value, 'actual' => $readiness[$field]];
    }
}

$result = [
    'migration' => 'phase_73_acupuncture_standalone_mathematics',
    'verified' => $mismatches === [],
    'readiness' => $readiness,
    'point_status_inventory' => $pointStatus,
    'mismatches' => $mismatches,
];

echo json_encode($result, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES), PHP_EOL;

if ($mismatches !== []) {
    exit(65);
}
