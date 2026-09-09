<?php
require_once __DIR__ . '/../backend/db.php';
$out=['ok'=>false,'stage'=>'start'];
try {
  $pdo=db();
  $sql=file_get_contents(__DIR__.'/../backend/phase_111_psoriasis_keratinocyte_geometry.sql');
  $stmts=preg_split('/;\s*(?:\r?\n|$)/',$sql);
  $i=0;
  foreach($stmts as $stmt){
    $stmt=trim($stmt);
    if($stmt==='' || str_starts_with($stmt,'--')) continue;
    $i++;
    try{$pdo->exec($stmt);}catch(Throwable $e){
      throw new RuntimeException('statement '.$i.' failed: '.substr(preg_replace('/\s+/',' ',$stmt),0,180).' :: '.$e->getMessage(),0,$e);
    }
  }
  $r=$pdo->query('SELECT * FROM v_ilb_psoriasis_keratinocyte_geometry_readiness')->fetch(PDO::FETCH_ASSOC);
  if((int)$r['equations']!==9) throw new RuntimeException('expected 9 equations');
  if((int)$r['primitives']!==11) throw new RuntimeException('expected 11 primitives');
  if((int)$r['not_closed_equations']!==1) throw new RuntimeException('expected exactly 1 explicitly not-closed transfer equation');
  if((int)$r['numeric_primitives']!==0) throw new RuntimeException('unsourced numeric primitive detected');
  $out=['ok'=>true,'stage'=>'complete','migration_statements'=>$i,'readiness'=>$r,
        'rule'=>'Population conservation and geometry are derived; IL17-signaling-to-cell-cycle quantitative transfer remains unresolved rather than invented.'];
}catch(Throwable $e){
  $out=['ok'=>false,'stage'=>'failed','exception'=>$e->getMessage(),'file'=>$e->getFile(),'line'=>$e->getLine()];
}
header('Content-Type: application/json');
echo json_encode($out,JSON_PRETTY_PRINT|JSON_UNESCAPED_SLASHES).PHP_EOL;
