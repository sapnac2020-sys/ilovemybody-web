<?php
// Phase 110 verifier: formula-first IL-17 subsystem.
require_once __DIR__ . '/../config/database.php';
header('Content-Type: application/json');
$out = ['ok'=>false,'stage'=>'start'];
try {
    $pdo = getPDO();
    $out['database'] = $pdo->query('SELECT DATABASE()')->fetchColumn();
    $sql = file_get_contents(__DIR__ . '/../backend/phase_110_psoriasis_il17_first_principles.sql');
    $parts = preg_split('/;\s*(?:\r?\n|$)/', $sql);
    $n = 0;
    foreach ($parts as $stmt) {
        $stmt = trim($stmt);
        if ($stmt === '' || str_starts_with($stmt, '--')) continue;
        $n++;
        try { $pdo->exec($stmt); }
        catch (Throwable $e) {
            $out['stage']='migration_statement'; $out['statement_no']=$n;
            $out['statement_head']=substr(preg_replace('/\s+/', ' ', $stmt),0,180);
            $out['exception']=$e->getMessage();
            echo json_encode($out, JSON_PRETTY_PRINT|JSON_UNESCAPED_SLASHES); exit(1);
        }
    }
    $r = $pdo->query('SELECT * FROM v_ilb_psoriasis_phase110_readiness')->fetch(PDO::FETCH_ASSOC);
    $checks = [
      'equation_count' => ((int)$r['equation_count'] >= 8),
      'primitive_count' => ((int)$r['primitive_count'] >= 13),
      'dependency_count' => ((int)$r['dependency_count'] >= 15),
      'status' => ($r['readiness_status'] === 'DERIVED_STRUCTURE_NOT_NUMERICALLY_CLOSED'),
    ];
    $bad_numeric = (int)$pdo->query("SELECT COUNT(*) FROM ilb_psoriasis_fp_primitive WHERE value_num IS NOT NULL AND source_status IN ('TO_SOURCE','MEASURE_OR_DERIVE','MEASURE_OR_GEOMETRY','DERIVE_FROM_GEOMETRY')")->fetchColumn();
    $checks['no_unsourced_numeric_values'] = ($bad_numeric === 0);
    $bad_antibody = (int)$pdo->query("SELECT COUNT(*) FROM ilb_psoriasis_fp_primitive WHERE primitive_id IN ('FP110-P07','FP110-P08') AND COALESCE(source_note,'') LIKE '%antibody affinity used%'")->fetchColumn();
    $checks['no_antibody_affinity_substitution'] = ($bad_antibody === 0);
    $out['stage']='complete'; $out['migration_statements']=$n; $out['readiness']=$r; $out['checks']=$checks;
    $out['ok'] = !in_array(false,$checks,true);
    echo json_encode($out, JSON_PRETTY_PRINT|JSON_UNESCAPED_SLASHES);
    exit($out['ok'] ? 0 : 1);
} catch (Throwable $e) {
    $out['stage']='fatal'; $out['exception']=$e->getMessage();
    echo json_encode($out, JSON_PRETTY_PRINT|JSON_UNESCAPED_SLASHES); exit(1);
}
