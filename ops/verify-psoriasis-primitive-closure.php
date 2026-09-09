<?php
// Phase 116 verifier: primitive closure must never invent universal patient constants.
require_once __DIR__ . '/../backend/db.php';
$pdo = db();
$sql = file_get_contents(__DIR__ . '/../backend/phase_116_psoriasis_primitive_closure.sql');
$stmts = array_filter(array_map('trim', preg_split('/;\s*(?:\r?\n|$)/', $sql)));
$i=0;
try {
  foreach ($stmts as $stmt) {
    if ($stmt==='' || str_starts_with(ltrim($stmt),'--')) continue;
    $i++;
    $pdo->exec($stmt);
  }
  $row=$pdo->query('SELECT * FROM v_ilb_psoriasis_primitive_closure')->fetch(PDO::FETCH_ASSOC);
  $checks=[];
  $checks['primitive_count'] = ((int)$row['primitive_count'] >= 18);
  $checks['universal_patient_constants_zero'] = ((int)$row['universal_patient_constants'] === 0);
  $checks['unresolved_preserved'] = ((int)$row['unresolved_count'] >= 5);
  $checks['measurement_required_preserved'] = ((int)$row['measure_required_count'] >= 3);
  $checks['verification_only_preserved'] = ((int)$row['verification_only_count'] >= 4);
  $kd=$pdo->query("SELECT numeric_value,unit,context_scope FROM ilb_psoriasis_primitive_value WHERE primitive_id='P116-KD-IL17A-RA'")->fetch(PDO::FETCH_ASSOC);
  $checks['il17ra_kd_contextualized'] = $kd && (float)$kd['numeric_value']===2.8 && $kd['unit']==='nM' && stripos($kd['context_scope'],'SPR')!==false;
  $ok=!in_array(false,$checks,true);
  echo json_encode(['ok'=>$ok,'stage'=>'complete','migration_statements'=>$i,'closure'=>$row,'checks'=>$checks,'rule'=>'DERIVE -> PREDICT -> VERIFY; no sourced context value becomes a universal patient constant.'],JSON_PRETTY_PRINT|JSON_UNESCAPED_SLASHES).PHP_EOL;
  exit($ok?0:1);
} catch (Throwable $e) {
  echo json_encode(['ok'=>false,'stage'=>'migration','statement_number'=>$i,'exception'=>$e->getMessage(),'file'=>$e->getFile(),'line'=>$e->getLine()],JSON_PRETTY_PRINT).PHP_EOL;
  exit(1);
}
