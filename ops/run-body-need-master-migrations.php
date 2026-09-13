<?php
declare(strict_types=1);

try {
    if ($argc < 3) {
        throw new RuntimeException('Usage: php run-body-need-master-migrations.php CONFIG MIGRATION_DIR');
    }
    $config = require $argv[1];
    if (isset($config['database'])) $config = $config['database'];
    $dbName = $config['db'] ?? $config['name'] ?? null;
    if (!$dbName) throw new RuntimeException('Database name missing from config');

    $pdo = new PDO(
        "mysql:host={$config['host']};dbname={$dbName};charset=utf8mb4",
        $config['user'],
        $config['pass'] ?? $config['password'],
        [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION, PDO::MYSQL_ATTR_MULTI_STATEMENTS => true]
    );

    $dir = rtrim($argv[2], '/');
    $files = [
        '005_body_need_master.sql',
        '006_formula_duplicate_and_identifier_patch.sql',
        '007_formula_master_bootstrap.sql',
        '008_loinc_parameter_bootstrap.sql',
        '009_body_need_execution_status_patch.sql',
    ];

    $applied = [];
    foreach ($files as $file) {
        $path = $dir . '/' . $file;
        if (!is_file($path) || filesize($path) === 0) {
            throw new RuntimeException("Missing migration: {$file}");
        }
        $stmt = $pdo->prepare(file_get_contents($path));
        $stmt->execute();
        do {
            if ($stmt->columnCount()) $stmt->fetchAll();
        } while ($stmt->nextRowset());
        $applied[] = $file;
    }

    $requiredTables = [
        'ilmb_parameter_master',
        'ilmb_parameter_identifier',
        'ilmb_formula_master',
        'ilmb_formula_input',
        'ilmb_parameter_duplicate_candidate',
        'ilmb_formula_duplicate_candidate',
        'ilmb_body_need_run',
    ];
    $requiredViews = [
        'vw_ilmb_common_parameter_master',
        'vw_ilmb_subject_parameter_observation',
    ];

    $check = $pdo->prepare("SELECT COUNT(*) FROM information_schema.tables WHERE table_schema=DATABASE() AND table_name=? AND table_type=?");
    $missing = [];
    foreach ($requiredTables as $name) {
        $check->execute([$name, 'BASE TABLE']);
        if ((int)$check->fetchColumn() !== 1) $missing[] = $name;
    }
    foreach ($requiredViews as $name) {
        $check->execute([$name, 'VIEW']);
        if ((int)$check->fetchColumn() !== 1) $missing[] = $name;
    }

    $counts = [];
    foreach ([
        'parameters' => 'SELECT COUNT(*) FROM ilmb_parameter_master',
        'identifiers' => 'SELECT COUNT(*) FROM ilmb_parameter_identifier',
        'formulas' => 'SELECT COUNT(*) FROM ilmb_formula_master',
        'formula_inputs' => 'SELECT COUNT(*) FROM ilmb_formula_input',
        'resolved_subject_observations' => 'SELECT COUNT(*) FROM vw_ilmb_subject_parameter_observation',
    ] as $key => $sql) {
        $counts[$key] = (int)$pdo->query($sql)->fetchColumn();
    }

    $result = [
        'body_need_master_ready' => count($missing) === 0,
        'missing_objects' => $missing,
        'applied_migrations' => $applied,
        'counts' => $counts,
        'patient_rows_modified' => 0,
    ];
    echo json_encode($result, JSON_UNESCAPED_SLASHES), PHP_EOL;
    exit(count($missing) === 0 ? 0 : 4);
} catch (Throwable $e) {
    echo 'BODY_NEED_MIGRATION_ERROR: ' . $e->getMessage(), PHP_EOL;
    exit(1);
}
