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
    'ilb_pre10_dimension',
    'ilb_pre10_assessment',
    'ilb_pre10_item',
    'ilb_pre10_enrollment',
    'ilb_app_pathway',
    'ilb_app_flow',
    'ilb_app_step',
    'ilb_app_enrollment_state',
    'ilb_backend_release',
    'ilb_backend_object_registry',
    'ilb_backend_freeze_issue',
    'ilb_reference_lifecycle',
    'ilb_product_setting',
    'ilb_hospital_department',
    'ilb_hospital_room',
    'ilb_navigation_item',
    'ilb_content_block',
    'ilb_theme_option',
    'ilb_journey_template',
    'ilb_journey_stage',
    'ilb_connection_component',
    'ilb_connection_edge',
    'ilb_change_stage',
    'ilb_metric_definition',
    'ilb_account',
    'ilb_account_session',
    'ilb_registration_state',
    'ilb_subject_preference',
    'ilb_patient_journey',
    'ilb_journey_stage_event',
    'ilb_journal_entry',
    'ilb_intent_choice_event',
    'ilb_choice_action',
    'ilb_action_consequence',
    'ilb_bot_conversation',
    'ilb_bot_message',
    'ilb_data_contract',
    'v_ilb_public_hospital_bootstrap',
    'v_ilb_journey_contract',
    'v_ilb_connection_contract',
    'v_ilb_patient_dashboard',
    'v_ilb_plug_play_readiness',
    'v_ilb_release_summary',
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

$statusInventory = [];
$statusTablesStmt = $pdo->prepare(
    "SELECT table_name
       FROM information_schema.columns
      WHERE table_schema = ?
        AND column_name = 'status'
      ORDER BY table_name"
);
$statusTablesStmt->execute([$schema]);
foreach ($statusTablesStmt->fetchAll(PDO::FETCH_COLUMN) as $table) {
    $quoted = '`' . str_replace('`', '``', (string)$table) . '`';
    $rows = $pdo->query(
        "SELECT CAST(`status` AS CHAR) AS status_value, COUNT(*) AS row_count
           FROM {$quoted}
          GROUP BY CAST(`status` AS CHAR)
          ORDER BY status_value"
    )->fetchAll();
    $statusInventory[(string)$table] = $rows;
}

$freezeStatus = null;
if (in_array('v_ilb_backend_freeze_status', $tableNames, true)) {
    $freezeStatus = $pdo->query(
        'SELECT * FROM `v_ilb_backend_freeze_status` LIMIT 1'
    )->fetch() ?: null;
}

$releaseSummary = null;
if (in_array('v_ilb_release_summary', $tableNames, true)) {
    $releaseSummary = $pdo->query(
        'SELECT * FROM `v_ilb_release_summary` LIMIT 1'
    )->fetch() ?: null;
}

$plugPlayMissing = [];
if (in_array('v_ilb_plug_play_readiness', $tableNames, true)) {
    $plugPlayMissing = $pdo->query(
        "SELECT object_name, object_type, purpose_text
           FROM `v_ilb_plug_play_readiness`
          WHERE readiness_status <> 'ready'
          ORDER BY object_type, object_name"
    )->fetchAll();
}

$freezeIssues = [];
if (in_array('ilb_backend_freeze_issue', $tableNames, true)) {
    $freezeIssues = $pdo->query(
        "SELECT issue_key, domain_key, issue_title, severity,
                blocks_frontend, status, resolution_rule
           FROM `ilb_backend_freeze_issue`
          WHERE status = 'open'
          ORDER BY blocks_frontend DESC,
                   FIELD(severity,'blocker','review','information'),
                   issue_key"
    )->fetchAll();
}

$legacyFrontendLeakage = [];
if (in_array('ilb_backend_object_registry', $tableNames, true)) {
    $legacyFrontendLeakage = $pdo->query(
        "SELECT object_name, object_type, lifecycle_status, frontend_access
           FROM `ilb_backend_object_registry`
          WHERE lifecycle_status IN ('superseded','retired','blocked')
            AND frontend_access <> 'blocked'
          ORDER BY object_name"
    )->fetchAll();
}

$audit = [
    'audit_version' => '2026-07-24.3',
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
        'open_freeze_issues' => count($freezeIssues),
        'legacy_frontend_leakage' => count($legacyFrontendLeakage),
        'plug_play_missing_objects' => count($plugPlayMissing),
    ],
    'missing_required_tables' => $missingRequired,
    'tables_without_primary_key' => $tablesWithoutPrimaryKey,
    'required_table_exact_counts' => $exactCounts,
    'tables' => $tables,
    'column_counts' => $columnCounts,
    'key_coverage' => $keyCoverage,
    'foreign_keys' => $foreignKeys,
    'status_inventory' => $statusInventory,
    'freeze_status' => $freezeStatus,
    'release_summary' => $releaseSummary,
    'plug_play_missing_objects' => $plugPlayMissing,
    'open_freeze_issues' => $freezeIssues,
    'legacy_frontend_leakage' => $legacyFrontendLeakage,
];

echo json_encode($audit, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES) . PHP_EOL;
