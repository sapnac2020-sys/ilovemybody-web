<?php
$pdo = require __DIR__ . '/../backend/db.php';
$sql = file_get_contents(__DIR__ . '/../backend/phase_113_psoriasis_cell_cycle_g1s.sql');
$statements = array_filter(array_map('trim', preg_split('/;\s*(?:\r?\n|$)/', $sql)));
$stage='migration'; $i=0;
try {
  foreach ($statements as $stmt) {
    if ($stmt === '' || str_starts_with($stmt,'--')) continue;
    $i++;
    $pdo->exec($stmt);
  }
  $stage='checks';
  $row=$pdo->query('SELECT * FROM v_ilb_psoriasis_cellcycle_readiness')->fetch(PDO::FETCH_ASSOC);
  $ok=((int)$row['reaction_count']===10 && (int)$row['primitive_count']===17 && (int)$row['populated_primitives']===0 && $row['readiness_status']==='DERIVED_STRUCTURE_NOT_NUMERICALLY_CLOSED');
  echo json_encode(['ok'=>$ok,'stage'=>'complete','migration_statements'=>$i,'cellcycle'=>$row,'rule'=>'No free fitted signaling-to-cycle weights; all numeric primitives remain unsourced until independently derived.'], JSON_PRETTY_PRINT), PHP_EOL;
  exit($ok?0:1);
} catch (Throwable $e) {
  echo json_encode(['ok'=>false,'stage'=>$stage,'statement_number'=>$i,'exception'=>$e->getMessage(),'file'=>$e->getFile(),'line'=>$e->getLine()], JSON_PRETTY_PRINT), PHP_EOL;
  exit(1);
}
