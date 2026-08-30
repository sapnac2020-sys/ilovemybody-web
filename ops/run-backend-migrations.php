<?php
declare(strict_types=1);

const EXPECTED_DATABASE = 'u756742628_ilovemybody';

if (PHP_SAPI !== 'cli') {
    fwrite(STDERR, "CLI only.\n");
    exit(2);
}

$configPath = $argv[1] ?? '';
$migrationDir = $argv[2] ?? '';

if ($configPath === '' || $migrationDir === '' || !is_file($configPath) || !is_dir($migrationDir)) {
    fwrite(STDERR, "Usage: php run-backend-migrations.php <config.php> <migration-directory>\n");
    exit(2);
}

$config = require $configPath;
$db = is_array($config['db'] ?? null)
    ? $config['db']
    : [
        'host' => $config['host'] ?? null,
        'port' => $config['port'] ?? 3306,
        'name' => $config['db'] ?? null,
        'user' => $config['user'] ?? null,
        'pass' => $config['pass'] ?? null,
        'charset' => $config['charset'] ?? 'utf8mb4',
    ];

if (($db['name'] ?? '') !== EXPECTED_DATABASE) {
    fwrite(STDERR, "Refusing migration: configured database is not " . EXPECTED_DATABASE . ".\n");
    exit(3);
}

$dsn = sprintf(
    'mysql:host=%s;port=%d;dbname=%s;charset=%s',
    (string)($db['host'] ?? '127.0.0.1'),
    (int)($db['port'] ?? 3306),
    EXPECTED_DATABASE,
    (string)($db['charset'] ?? 'utf8mb4')
);

try {
    $pdo = new PDO(
        $dsn,
        (string)($db['user'] ?? ''),
        (string)($db['pass'] ?? ''),
        [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::MYSQL_ATTR_MULTI_STATEMENTS => true,
        ]
    );

$migrations = [
    'phase_47_hospital_product_contract.sql',
    'phase_48_patient_runtime_contract.sql',
    'phase_49_plug_and_play_freeze.sql',
    'phase_50_gita_verification_system.sql',
    'phase_50a_gita_corpus.sql.gz',
];

    foreach ($migrations as $migration) {
        $path = rtrim($migrationDir, DIRECTORY_SEPARATOR) . DIRECTORY_SEPARATOR . $migration;
        if (!is_file($path)) {
            throw new RuntimeException("Missing migration: {$migration}");
        }

        if (str_ends_with($migration, '.gz')) {
            $compressed = file_get_contents($path);
            $sql = $compressed === false ? false : gzdecode($compressed);
        } else {
            $sql = file_get_contents($path);
        }
        if ($sql === false || trim($sql) === '') {
            throw new RuntimeException("Empty migration: {$migration}");
        }

        echo "Running {$migration}...\n";
        $statement = $pdo->prepare($sql);
        $statement->execute();
        do {
            if ($statement->columnCount() > 0) {
                $statement->fetchAll();
            }
        } while ($statement->nextRowset());
        $statement->closeCursor();
        echo "Completed {$migration}.\n";
    }

    $missing = (int)$pdo->query(
        "SELECT COUNT(*) FROM `v_ilb_plug_play_readiness` WHERE `readiness_status` = 'missing'"
    )->fetchColumn();

    if ($missing !== 0) {
        fwrite(STDERR, "Verification failed: {$missing} required objects are missing.\n");
        exit(4);
    }

    $summary = $pdo->query("SELECT * FROM `v_ilb_release_summary`")->fetch();
    $gita = $pdo->query("SELECT * FROM `v_ilb_gita_readiness`")->fetch();
    $gitaExpected = [
        'verse_rows' => 700,
        'source_rows' => 700,
        'hashed_source_rows' => 700,
        'tokenised_verses' => 700,
        'approved_translations' => 0,
        'passing_formula_tests' => 9,
        'preregistered_predictions' => 0,
        'verified_results' => 0,
        'personally_supported_claims' => 0,
    ];
    foreach ($gitaExpected as $field => $expected) {
        if ((int)($gita[$field] ?? -1) !== $expected) {
            throw new RuntimeException("Gita readiness mismatch for {$field}: expected {$expected}, got " . ($gita[$field] ?? 'missing'));
        }
    }
    echo "Verification passed: missing_objects=0\n";
    echo json_encode($summary, JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE) . "\n";
    echo 'gita=' . json_encode($gita, JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE) . "\n";
} catch (Throwable $error) {
    fwrite(
        STDERR,
        "Migration verifier error [" . get_class($error) . "]: " . $error->getMessage() . "\n"
    );
    exit(5);
}
