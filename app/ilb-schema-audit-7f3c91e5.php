<?php
declare(strict_types=1);

header('Content-Type: application/json; charset=utf-8');
header('Cache-Control: no-store, max-age=0');
header('X-Robots-Tag: noindex, nofollow, noarchive');

$expectedToken = 'ilb-audit-20260827-7f3c91e5a4b82d60c7e194f3';
$providedToken = (string)($_GET['token'] ?? '');
if (!hash_equals($expectedToken, $providedToken)) {
    http_response_code(404);
    echo json_encode(['error' => 'Not found']);
    exit;
}

$candidates = [
    __DIR__ . '/config.php',
    __DIR__ . '/secrets.php',
    dirname(__DIR__) . '/config.php',
    dirname(__DIR__) . '/secrets.php',
    dirname(dirname(__DIR__)) . '/config.php',
    dirname(dirname(__DIR__)) . '/private/config.php',
    dirname(dirname(__DIR__)) . '/private/secrets.php',
];
$configPath = '';
foreach ($candidates as $candidate) {
    if (is_file($candidate)) { $configPath = $candidate; break; }
}
if ($configPath === '') {
    http_response_code(503);
    echo json_encode([
        'error' => 'Configuration unavailable',
        'checked' => array_map(static fn(string $p): string => basename(dirname($p)) . '/' . basename($p), $candidates),
        'environment_keys_present' => array_values(array_filter(['DB_HOST','DB_NAME','DB_USER','DB_PASS'], static fn(string $k): bool => getenv($k) !== false)),
    ]);
    exit;
}
$config = require $configPath;
$db = $config['db'] ?? null;
if (!is_array($db)) {
    http_response_code(503);
    echo json_encode(['error' => 'Database configuration unavailable']);
    exit;
}

$dsn = sprintf(
    'mysql:host=%s;port=%d;dbname=%s;charset=%s',
    $db['host'] ?? '127.0.0.1',
    (int)($db['port'] ?? 3306),
    $db['name'] ?? '',
    $db['charset'] ?? 'utf8mb4'
);
$pdo = new PDO($dsn, $db['user'] ?? '', $db['pass'] ?? '', [
    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    PDO::ATTR_EMULATE_PREPARES => false,
]);
$schema = (string)($db['name'] ?? '');
$mode = (string)($_GET['mode'] ?? 'summary');

function output(array $data): never {
    echo json_encode($data, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES);
    exit;
}

if ($mode === 'summary') {
    $q = $pdo->prepare(
        "SELECT
            COUNT(*) AS all_objects,
            SUM(table_type='BASE TABLE') AS base_tables,
            SUM(table_type='VIEW') AS views,
            ROUND(SUM(COALESCE(data_length,0)+COALESCE(index_length,0))/1024/1024,2) AS total_mb,
            SUM(COALESCE(table_rows,0)) AS estimated_rows
         FROM information_schema.tables WHERE table_schema=?"
    );
    $q->execute([$schema]);
    $summary = $q->fetch();

    $q = $pdo->prepare("SELECT COUNT(*) FROM information_schema.columns WHERE table_schema=?");
    $q->execute([$schema]);
    $summary['columns'] = (int)$q->fetchColumn();

    $q = $pdo->prepare("SELECT COUNT(*) FROM information_schema.key_column_usage WHERE table_schema=? AND referenced_table_name IS NOT NULL");
    $q->execute([$schema]);
    $summary['foreign_key_columns'] = (int)$q->fetchColumn();

    $q = $pdo->prepare("SELECT COUNT(*) FROM information_schema.triggers WHERE trigger_schema=?");
    $q->execute([$schema]);
    $summary['triggers'] = (int)$q->fetchColumn();

    $q = $pdo->prepare("SELECT COUNT(*) FROM information_schema.routines WHERE routine_schema=?");
    $q->execute([$schema]);
    $summary['routines'] = (int)$q->fetchColumn();

    output([
        'generated_at_utc' => gmdate('c'),
        'audit_scope' => 'schema metadata and aggregate estimates only; no patient rows',
        'summary' => $summary,
    ]);
}

if ($mode === 'inventory') {
    $q = $pdo->prepare(
        "SELECT table_name, table_type, engine, table_rows,
                ROUND((COALESCE(data_length,0)+COALESCE(index_length,0))/1024/1024,3) AS size_mb,
                create_time, update_time
         FROM information_schema.tables
         WHERE table_schema=?
         ORDER BY table_name"
    );
    $q->execute([$schema]);
    output(['generated_at_utc'=>gmdate('c'), 'objects'=>$q->fetchAll()]);
}

if ($mode === 'search') {
    $term = trim((string)($_GET['q'] ?? ''));
    if ($term === '' || strlen($term) > 80) {
        http_response_code(400);
        output(['error'=>'A search term of 1-80 characters is required']);
    }
    $like = '%' . $term . '%';
    $q = $pdo->prepare(
        "SELECT DISTINCT t.table_name, t.table_type, t.table_rows
         FROM information_schema.tables t
         LEFT JOIN information_schema.columns c
           ON c.table_schema=t.table_schema AND c.table_name=t.table_name
         WHERE t.table_schema=? AND (t.table_name LIKE ? OR c.column_name LIKE ?)
         ORDER BY t.table_name LIMIT 500"
    );
    $q->execute([$schema,$like,$like]);
    output(['query'=>$term, 'objects'=>$q->fetchAll()]);
}

if ($mode === 'table') {
    $table = (string)($_GET['table'] ?? '');
    $q = $pdo->prepare("SELECT COUNT(*) FROM information_schema.tables WHERE table_schema=? AND table_name=?");
    $q->execute([$schema,$table]);
    if ((int)$q->fetchColumn() !== 1) {
        http_response_code(404);
        output(['error'=>'Unknown table or view']);
    }

    $q = $pdo->prepare(
        "SELECT ordinal_position, column_name, column_type, is_nullable,
                column_default, column_key, extra, column_comment
         FROM information_schema.columns
         WHERE table_schema=? AND table_name=?
         ORDER BY ordinal_position"
    );
    $q->execute([$schema,$table]);
    $columns = $q->fetchAll();

    $q = $pdo->prepare(
        "SELECT constraint_name, column_name, referenced_table_name, referenced_column_name
         FROM information_schema.key_column_usage
         WHERE table_schema=? AND table_name=? AND referenced_table_name IS NOT NULL
         ORDER BY constraint_name, ordinal_position"
    );
    $q->execute([$schema,$table]);
    $foreignKeys = $q->fetchAll();

    $q = $pdo->prepare(
        "SELECT index_name, non_unique, seq_in_index, column_name
         FROM information_schema.statistics
         WHERE table_schema=? AND table_name=?
         ORDER BY index_name, seq_in_index"
    );
    $q->execute([$schema,$table]);
    $indexes = $q->fetchAll();

    output(['table'=>$table,'columns'=>$columns,'foreign_keys'=>$foreignKeys,'indexes'=>$indexes]);
}

http_response_code(400);
output(['error'=>'Unsupported audit mode']);
