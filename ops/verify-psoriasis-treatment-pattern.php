<?php
require_once __DIR__ . '/../backend/db.php';
$out=['ok'=>false,'stage'=>'init'];
try {
  $pdo = ilmb_db();
  $row=$pdo->query("SELECT * FROM v_ilb_psoriasis_treatment_pattern_readiness")->fetch(PDO::FETCH_ASSOC);
  $out['stage']='readiness'; $out['readiness']=$row;
  $checks=[
    'layer_count'=>5,
    'component_count'=>11,
    'checkpoint_count'=>5,
    'direct_reference_count'=>1,
    'unsafe_mechanism_promotions'=>0,
  ];
  foreach($checks as $k=>$v){ if((int)$row[$k]!==$v) throw new RuntimeException("$k expected $v got ".$row[$k]); }
  if($row['readiness_status']!=='CANDIDATE_PATTERN_READY_FOR_PROSPECTIVE_VERIFICATION') throw new RuntimeException('bad readiness status');
  $out['ok']=true; $out['stage']='complete';
} catch(Throwable $e) {
  $out['error']=$e->getMessage(); $out['file']=$e->getFile(); $out['line']=$e->getLine();
  http_response_code(500);
}
echo json_encode($out, JSON_PRETTY_PRINT|JSON_UNESCAPED_SLASHES).PHP_EOL;
