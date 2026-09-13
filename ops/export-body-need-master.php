<?php
declare(strict_types=1);

try {
    if ($argc < 2) throw new RuntimeException('Usage: php export-body-need-master.php CONFIG');
    $config = require $argv[1];
    if (isset($config['database'])) $config = $config['database'];
    $dbName = $config['db'] ?? $config['name'] ?? null;
    if (!$dbName) throw new RuntimeException('Database name missing from config');

    $pdo = new PDO(
        "mysql:host={$config['host']};dbname={$dbName};charset=utf8mb4",
        $config['user'],
        $config['pass'] ?? $config['password'],
        [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]
    );
    $pdo->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);

    $queries = [
        'parameters' => 'SELECT * FROM ilmb_parameter_master ORDER BY parameter_id',
        'identifiers' => 'SELECT * FROM ilmb_parameter_identifier ORDER BY parameter_id,identifier_system,identifier_code',
        'formulas' => 'SELECT * FROM ilmb_formula_master ORDER BY formula_domain,formula_key',
        'formula_inputs' => 'SELECT * FROM ilmb_formula_input ORDER BY formula_id,ordinal,formula_input_id',
        'duplicates' => 'SELECT * FROM ilmb_parameter_duplicate_candidate ORDER BY disposition,confidence DESC,duplicate_candidate_id',
        'formula_duplicates' => 'SELECT * FROM ilmb_formula_duplicate_candidate ORDER BY disposition,confidence DESC,formula_duplicate_candidate_id',
    ];

    $out = ['generated_at_utc' => gmdate('c')];
    foreach ($queries as $key => $sql) $out[$key] = $pdo->query($sql)->fetchAll();
    echo json_encode($out, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES), PHP_EOL;
} catch (Throwable $e) {
    fwrite(STDERR, 'BODY_NEED_EXPORT_ERROR: ' . $e->getMessage() . PHP_EOL);
    exit(1);
}
