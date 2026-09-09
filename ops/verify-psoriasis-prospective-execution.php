<?php
// Phase 122 verifier: prospective psoriasis execution protocol.
// Executes migration statement-by-statement, then verifies governed counts and claim boundaries.

declare(strict_types=1);

function fail(string $stage, Throwable|string $e, array $extra = []): never {
    $msg = $e instanceof Throwable ? $e->getMessage() : $e;
    $out = array_merge(['ok'=>false,'stage'=>$stage,'error'=>$msg], $extra);
    if ($e instanceof Throwable) {
        $out['exception'] = get_class($e);
        $out['file'] = $e->getFile();
        $out['line'] = $e->getLine();
    }
    echo json_encode($out, JSON_PRETTY_PRINT|JSON_UNESCAPED_SLASHES), PHP_EOL;
    exit(1);
}

try {
    $root = dirname(__DIR__);
    $sqlFile = $root . '/backend/phase_122_psoriasis_prospective_execution.sql';
    if (!is_file($sqlFile)) fail('file_check', 'missing phase_122 SQL');

    $dsn = getenv('DB_DSN') ?: '';
    $user = getenv('DB_USER') ?: '';
    $pass = getenv('DB_PASSWORD') ?: '';
    if ($dsn === '') {
        $host = getenv('DB_HOST') ?: 'localhost';
        $db = getenv('DB_NAME') ?: '';
        $port = getenv('DB_PORT') ?: '3306';
        if ($db === '') fail('env', 'DB_NAME/DB_DSN missing');
        $dsn = "mysql:host={$host};port={$port};dbname={$db};charset=utf8mb4";
    }
    $pdo = new PDO($dsn, $user, $pass, [PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION]);

    $sql = file_get_contents($sqlFile);
    if ($sql === false) fail('read_sql', 'could not read SQL');
    $parts = preg_split('/;\s*(?:\r?\n|$)/', $sql) ?: [];
    $statementNo = 0;
    foreach ($parts as $part) {
        $stmt = trim($part);
        if ($stmt === '' || str_starts_with($stmt, '--')) continue;
        $statementNo++;
        try { $pdo->exec($stmt); }
        catch (Throwable $e) {
            fail('migration_statement', $e, ['statement_no'=>$statementNo,'statement_head'=>substr(preg_replace('/\s+/', ' ', $stmt) ?? $stmt,0,220)]);
        }
    }

    $row = $pdo->query("SELECT * FROM v_ilb_psoriasis_prospective_readiness WHERE protocol_code='PSO-NONDRUG-PROSPECTIVE-V1'")->fetch(PDO::FETCH_ASSOC);
    if (!$row) fail('readiness', 'readiness row missing');
    if (($row['readiness_status'] ?? '') !== 'PROSPECTIVE_PROTOCOL_READY') fail('readiness', 'protocol not ready', ['readiness'=>$row]);
    if ((int)$row['component_count'] < 11) fail('counts', 'component count too low', ['readiness'=>$row]);
    if ((int)$row['checkpoint_count'] !== 5) fail('counts', 'checkpoint count mismatch', ['readiness'=>$row]);
    if ((int)$row['measurement_count'] < 12) fail('counts', 'measurement count too low', ['readiness'=>$row]);
    if ((int)$row['outcome_rule_count'] !== 5) fail('counts', 'outcome rule count mismatch', ['readiness'=>$row]);

    $unsafe = (int)$pdo->query("SELECT COUNT(*) FROM ilb_psoriasis_protocol_component WHERE protocol_id='P122-PROTOCOL-001' AND intervention_code IN ('HOMEOPATHY','BACH','LOUISE_HAY','REDIKALL') AND role_class NOT IN ('VERIFICATION_ONLY','NARRATIVE_ONLY')")->fetchColumn();
    if ($unsafe !== 0) fail('governance', 'verification/narrative modality promoted beyond boundary');

    $emdrUnsafe = (int)$pdo->query("SELECT COUNT(*) FROM ilb_psoriasis_protocol_component WHERE protocol_id='P122-PROTOCOL-001' AND intervention_code='EMDR' AND mechanism_boundary NOT LIKE '%No established direct IL-17%'")->fetchColumn();
    if ($emdrUnsafe !== 0) fail('governance', 'EMDR boundary missing');

    $urgent = (int)$pdo->query("SELECT COUNT(*) FROM ilb_psoriasis_protocol_checkpoint WHERE protocol_id='P122-PROTOCOL-001' AND checkpoint_code='SAFETY_BASELINE' AND stop_escalate_rule LIKE '%urgent medical assessment%'")->fetchColumn();
    if ($urgent !== 1) fail('safety', 'urgent safety routing missing');

    echo json_encode([
        'ok'=>true,
        'stage'=>'complete',
        'migration_statements'=>$statementNo,
        'protocol'=>'PSO-NONDRUG-PROSPECTIVE-V1',
        'readiness'=>$row,
        'rule'=>'DERIVE -> PREDICT -> VERIFY; durability tracked independently from clearance.'
    ], JSON_PRETTY_PRINT|JSON_UNESCAPED_SLASHES), PHP_EOL;
} catch (Throwable $e) {
    fail('fatal', $e);
}
