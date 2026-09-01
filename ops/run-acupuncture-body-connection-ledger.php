<?php
declare(strict_types=1);

if ($argc !== 3) {
    fwrite(STDERR, "Usage: php {$argv[0]} <config.php> <migration.sql>\n");
    exit(64);
}

$config = require $argv[1];
$sql = file_get_contents($argv[2]);
if ($sql === false) {
    throw new RuntimeException('Unable to read migration SQL.');
}

$pdo = new PDO(
    $config['dsn'],
    $config['username'],
    $config['password'],
    [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]
);

$required = ['ilb_acupuncture_point', 'ilb_bibliography_entry'];
$statement = $pdo->prepare(
    'SELECT table_name FROM information_schema.tables
     WHERE table_schema = DATABASE() AND table_name IN (?, ?)'
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

$result = $pdo->query(
    "SELECT
        (SELECT COUNT(*) FROM ilb_acupuncture_point) AS acupuncture_points,
        (SELECT COUNT(*) FROM ilb_acupuncture_body_connection) AS body_connections,
        (SELECT COUNT(*) FROM information_schema.views
           WHERE table_schema = DATABASE()
             AND table_name = 'v_ilb_acupuncture_body_connection_coverage') AS coverage_view_present"
)->fetch(PDO::FETCH_ASSOC);

echo json_encode($result, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES), PHP_EOL;
