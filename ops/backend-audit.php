<?php
declare(strict_types=1);

/*
 * Read-only production audit for I Love My Body.
 * Credentials are loaded from the server's existing private config and are
 * never included in the output.
 */

$configPath = $argv[1] ?? '';
if ($configPath === '' || !is_file($configPath)) {
    fwrite(STDERR, "Config file not found.\n");
    exit(2);
}

$config = require $configPath;
$db = $config['db'] ?? null;
if (!is_array($db)) {
    fwrite(STDERR, "Database configuration is unavailable.\n");
    exit(3);
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

$requiredTables = [
    'ilb_subject',
    'ilb_subject_profile',
    'ilb_subject_consent_event',
    'ilb_subject_private_identifier',
    'ilb_subject_private_identity',
    'ilb_subject_frontend_alias',
    'ilb_subject_condition_report',
    'ilb_subject_medicine_report',
    'ilb_subject_medication',
    'ilb_subject_document',
    'ilb_subject_lab_episode',
    'ilb_subject_measurement',
    'ilb_subject_goal',
    'ilb_human_state_snapshot',
    'ilb_snapshot_food_event',
    'ilb_snapshot_mind_emotion',
    'ilb_snapshot_behaviour',
    'ilb_snapshot_symptom',
    'ilb_snapshot_medicine_event',
    'ilb_snapshot_safety_flag',
    'ilb_psych_assessment',
    'ilb_psych_item_response',
    'ilb_daily_checkin',
    'ilb_body_signal_type',
    'ilb_body_signal_event',
    'ilb_response_action_event',
    'ilb_food_capture_session',
    'ilb_food_capture_photo',
    'ilb_food_analysis_run',
    'ilb_food_analysis_candidate',
    'ilb_food_event_confirmation',
    'ilb_feedback_rule',
    'ilb_feedback_delivery',
    'ilb_feedback_safety_policy',
    'ilb_case_formula_definition',
    'ilb_case_formula_input',
    'ilb_case_formula_result',
    'ilb_case_variable_definition',
    'ilb_case_variable_value',
    'ilb_energy_insight_definition',
    'ilb_energy_source_map',
    'ilb_energy_result',
    'ilb_energy_result_input',
    'ilb_reference',
    'ilb_claim',
    'ilb_claim_reference',
    'ilb_connection',
    'ilb_connection_reference',
    'ilb_content_source',
    'ilb_content_insight',
    'ilb_content_insight_reference',
    'ilb_content_review_audit',
    'ilb_direction_instrument_registry',
    'ilb_direction_assessment',
    'ilb_direction_score',
    'ilb_activity_profile',
    'ilb_activity_dimension',
    'ilb_flow_history',
    'ilb_loop_source_map',
];

$stmt = $pdo->prepare(
    'SELECT table_name, table_type, engine, table_rows, create_time, update_time
       FROM information_schema.tables
      WHERE table_schema = ?
      ORDER BY table_name'
);
$stmt->execute([$schema]);
$tables = $stmt->fetchAll();
$tableNames = array_column($tables, 'table_name');

$stmt = $pdo->prepare(
    'SELECT table_name, COUNT(*) AS column_count
       FROM information_schema.columns
      WHERE table_schema = ?
      GROUP BY table_name
      ORDER BY table_name'
);
$stmt->execute([$schema]);
$columnCounts = $stmt->fetchAll();

$stmt = $pdo->prepare(
    "SELECT table_name,
            SUM(column_key = 'PRI') AS primary_key_columns,
            SUM(column_key = 'UNI') AS unique_key_columns,
            SUM(column_key = 'MUL') AS indexed_columns
       FROM information_schema.columns
      WHERE table_schema = ?
      GROUP BY table_name
      ORDER BY table_name"
);
$stmt->execute([$schema]);
$keyCoverage = $stmt->fetchAll();

$stmt = $pdo->prepare(
    'SELECT table_name, column_name, constraint_name,
            referenced_table_name, referenced_column_name
       FROM information_schema.key_column_usage
      WHERE table_schema = ?
        AND referenced_table_name IS NOT NULL
      ORDER BY table_name, constraint_name, ordinal_position'
);
$stmt->execute([$schema]);
$foreignKeys = $stmt->fetchAll();

$missingRequired = array_values(array_diff($requiredTables, $tableNames));
$presentRequired = array_values(array_intersect($requiredTables, $tableNames));

$exactCounts = [];
foreach ($presentRequired as $table) {
    $quoted = '`' . str_replace('`', '``', $table) . '`';
    $exactCounts[$table] = (int)$pdo->query("SELECT COUNT(*) FROM {$quoted}")->fetchColumn();
}

$tablesWithoutPrimaryKey = [];
foreach ($keyCoverage as $row) {
    if ((int)$row['primary_key_columns'] === 0) {
        $tablesWithoutPrimaryKey[] = $row['table_name'];
    }
}

$audit = [
    'audit_version' => '2026-07-23.1',
    'generated_at_utc' => gmdate('c'),
    'schema' => $schema,
    'summary' => [
        'all_tables_and_views' => count($tables),
        'base_tables' => count(array_filter($tables, fn(array $t): bool => $t['table_type'] === 'BASE TABLE')),
        'views' => count(array_filter($tables, fn(array $t): bool => $t['table_type'] === 'VIEW')),
        'foreign_key_columns' => count($foreignKeys),
        'required_tables_checked' => count($requiredTables),
        'required_tables_present' => count($presentRequired),
        'required_tables_missing' => count($missingRequired),
        'tables_without_primary_key' => count($tablesWithoutPrimaryKey),
    ],
    'missing_required_tables' => $missingRequired,
    'tables_without_primary_key' => $tablesWithoutPrimaryKey,
    'required_table_exact_counts' => $exactCounts,
    'tables' => $tables,
    'column_counts' => $columnCounts,
    'key_coverage' => $keyCoverage,
    'foreign_keys' => $foreignKeys,
];

echo json_encode($audit, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES) . PHP_EOL;
