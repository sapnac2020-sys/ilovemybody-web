<?php
declare(strict_types=1);

const EXPECTED_DATABASE = 'u756742628_ilovemybody';
if (PHP_SAPI !== 'cli') exit(2);

$config = require($argv[1] ?? '');
if (isset($config['database']) && is_array($config['database'])) $config = $config['database'];
$db = $config['db'] ?? ($config['name'] ?? null);
if ($db !== EXPECTED_DATABASE) throw new RuntimeException('Unexpected database');

$pdo = new PDO(
    "mysql:host=".$config['host'].";port=".($config['port'] ?? 3306).";dbname={$db};charset=utf8mb4",
    $config['user'],
    $config['pass'] ?? $config['password'],
    [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]
);

$objects = ['ilb_science_chain', 'ilb_science_gate', 'ilb_science_chain_summary'];
$out = [
    'database' => $db,
    'captured_at_utc' => gmdate('c'),
    'read_only' => true,
    'objects' => [],
    'patient_rows_read' => 0,
    'patient_rows_modified' => 0,
];

foreach ($objects as $name) {
    $q = $pdo->prepare("SELECT TABLE_TYPE FROM information_schema.TABLES WHERE TABLE_SCHEMA=? AND TABLE_NAME=?");
    $q->execute([$db, $name]);
    $type = $q->fetchColumn();
    if ($type === false) {
        $out['objects'][$name] = ['exists' => false];
        continue;
    }
    $quoted = "`".str_replace("`", "``", $name)."`";
    $ddlRow = $pdo->query("SHOW CREATE ".($type === 'VIEW' ? 'VIEW ' : 'TABLE ').$quoted)->fetch(PDO::FETCH_NUM);
    $entry = ['exists' => true, 'type' => $type, 'ddl' => $ddlRow[1] ?? null];
    if ($type === 'BASE TABLE') {
        $entry['row_count'] = (int)$pdo->query("SELECT COUNT(*) FROM ".$quoted)->fetchColumn();
    }
    $out['objects'][$name] = $entry;
}

$candidates = [
    dirname(__DIR__).'/scripts/vitamin_d_direct_beam.php',
    dirname(__DIR__).'/public_html/scripts/vitamin_d_direct_beam.php',
];
$out['vitamin_d_direct_beam'] = ['exists' => false];
foreach ($candidates as $path) {
    if (is_file($path)) {
        $out['vitamin_d_direct_beam'] = [
            'exists' => true,
            'path' => $path,
            'sha256' => hash_file('sha256', $path),
            'bytes' => filesize($path),
        ];
        break;
    }
}

echo json_encode($out, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES), PHP_EOL;
