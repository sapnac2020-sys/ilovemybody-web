<?php
// Phase 115 verifier: structural formula completion only; numeric closure remains primitive-gated.
require_once __DIR__ . '/../config/database.php';

$out = ['ok'=>false,'stage'=>'start'];
try {
    $pdo = getPDO();
    $sql = file_get_contents(__DIR__ . '/../backend/phase_115_psoriasis_master_formula_closure.sql');
    if ($sql === false) { throw new RuntimeException('Cannot read Phase 115 SQL'); }

    $statements = array_values(array_filter(array_map('trim', preg_split('/;\s*(?:\r?\n|$)/', $sql)), fn($s) => $s !== '' && !str_starts_with($s, '--')));
    $n = 0;
    foreach ($statements as $stmt) {
        $n++;
        try { $pdo->exec($stmt); }
        catch (Throwable $e) {
            $out = ['ok'=>false,'stage'=>'migration','statement'=>$n,'statement_head'=>substr(preg_replace('/\s+/',' ',$stmt),0,180),'exception'=>$e->getMessage()];
            echo json_encode($out, JSON_PRETTY_PRINT|JSON_UNESCAPED_SLASHES), PHP_EOL; exit(1);
        }
    }

    $r = $pdo->query('SELECT * FROM v_ilb_psoriasis_master_formula_readiness')->fetch(PDO::FETCH_ASSOC);
    $badExternal = (int)$pdo->query("SELECT COUNT(*) FROM ilb_psoriasis_master_formula_stage WHERE governance_note LIKE '%verification dataset% supplies%' ")->fetchColumn();
    $ok = $r
      && (int)$r['formula_stages'] >= 16
      && (int)$r['resolution_conditions'] >= 5
      && $r['readiness_status'] === 'STRUCTURAL_FORMULA_COMPLETE_NUMERIC_CLOSURE_PENDING'
      && $badExternal === 0;

    $out = [
      'ok'=>$ok,
      'stage'=>'complete',
      'migration_statements'=>$n,
      'formula_stages'=>(int)($r['formula_stages'] ?? 0),
      'structurally_closed_stages'=>(int)($r['structurally_closed_stages'] ?? 0),
      'stages_awaiting_primitives'=>(int)($r['stages_awaiting_primitives'] ?? 0),
      'resolution_conditions'=>(int)($r['resolution_conditions'] ?? 0),
      'readiness_status'=>$r['readiness_status'] ?? null,
      'governance'=>'DERIVE -> PREDICT -> VERIFY; numeric closure requires sourced or person/geometrically derived primitives.'
    ];
    echo json_encode($out, JSON_PRETTY_PRINT|JSON_UNESCAPED_SLASHES), PHP_EOL;
    exit($ok ? 0 : 2);
} catch (Throwable $e) {
    $out = ['ok'=>false,'stage'=>'exception','exception'=>$e->getMessage(),'file'=>$e->getFile(),'line'=>$e->getLine()];
    echo json_encode($out, JSON_PRETTY_PRINT|JSON_UNESCAPED_SLASHES), PHP_EOL; exit(1);
}
