<?php
require_once __DIR__ . '/../backend/db.php';
header('Content-Type: application/json');
$out = ['ok' => false, 'stage' => 'init'];
try {
    $files = glob(__DIR__ . '/../backend/phase_*psoriasis*.sql');
    if (!$files) throw new RuntimeException('No psoriasis phase SQL files found');

    $selected = [];
    foreach ($files as $file) {
        $base = basename($file);
        if (!preg_match('/^phase_(\d+)/', $base, $m)) continue;
        $phase = (int)$m[1];
        if ($phase >= 106 && $phase <= 127) $selected[] = $file;
    }
    usort($selected, static function($a, $b) {
        return strnatcasecmp(basename($a), basename($b));
    });
    if (!$selected) throw new RuntimeException('No psoriasis SQL files selected for phases 106-127');

    $pdo->exec("CREATE TABLE IF NOT EXISTS ilb_psoriasis_deployment_ledger (
        deployment_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
        phase_file VARCHAR(255) NOT NULL,
        deployed_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
        statement_count INT UNSIGNED NOT NULL,
        deployment_status VARCHAR(32) NOT NULL,
        UNIQUE KEY uq_psoriasis_phase_file (phase_file)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

    $applied = [];
    $totalStatements = 0;
    foreach ($selected as $file) {
        $sql = file_get_contents($file);
        if ($sql === false) throw new RuntimeException('Cannot read ' . basename($file));
        $parts = array_values(array_filter(array_map('trim', preg_split('/;\s*(?:\r?\n|$)/', $sql))));
        $stmtNo = 0;
        foreach ($parts as $stmt) {
            $stmtNo++;
            try {
                $pdo->exec($stmt);
            } catch (Throwable $e) {
                throw new RuntimeException(
                    basename($file) . ' statement ' . $stmtNo . ' failed: ' . $e->getMessage() .
                    ' | SQL: ' . substr(preg_replace('/\s+/', ' ', $stmt), 0, 300)
                );
            }
        }
        $totalStatements += $stmtNo;
        $q = $pdo->prepare("INSERT INTO ilb_psoriasis_deployment_ledger(phase_file,statement_count,deployment_status)
                           VALUES(?,?, 'APPLIED')
                           ON DUPLICATE KEY UPDATE deployed_at=CURRENT_TIMESTAMP(6), statement_count=VALUES(statement_count), deployment_status='APPLIED'");
        $q->execute([basename($file), $stmtNo]);
        $applied[] = ['file' => basename($file), 'statements' => $stmtNo];
    }

    $criticalTables = [
        'ilb_psoriasis_keratinocyte_compartment',
        'ilb_psoriasis_control_branch',
        'ilb_psoriasis_candidate_stack'
    ];
    $verified = [];
    foreach ($criticalTables as $table) {
        $q = $pdo->prepare("SELECT COUNT(*) FROM information_schema.tables WHERE table_schema=DATABASE() AND table_name=?");
        $q->execute([$table]);
        $present = ((int)$q->fetchColumn() === 1);
        if (!$present) throw new RuntimeException('Critical table missing after migration: ' . $table);
        $verified[$table] = true;
    }

    $ledgerCount = (int)$pdo->query("SELECT COUNT(*) FROM ilb_psoriasis_deployment_ledger WHERE deployment_status='APPLIED'")->fetchColumn();
    $stackCount = (int)$pdo->query("SELECT COUNT(*) FROM ilb_psoriasis_candidate_stack WHERE stack_name='ILMB_INTERSECTION_STACK_V1'")->fetchColumn();
    if ($stackCount < 4) throw new RuntimeException('Phase 127 candidate stack is incomplete in production');

    $out = [
        'ok' => true,
        'stage' => 'complete',
        'database' => $pdo->query('SELECT DATABASE()')->fetchColumn(),
        'phase_range' => '106-127',
        'files_applied' => count($applied),
        'statements_applied' => $totalStatements,
        'deployment_ledger_rows' => $ledgerCount,
        'critical_tables' => $verified,
        'phase127_stack_rows' => $stackCount,
        'applied' => $applied
    ];
    echo json_encode($out, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES);
} catch (Throwable $e) {
    $out = [
        'ok' => false,
        'stage' => 'fatal',
        'exception' => $e->getMessage(),
        'file' => $e->getFile(),
        'line' => $e->getLine()
    ];
    echo json_encode($out, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES);
    exit(1);
}
