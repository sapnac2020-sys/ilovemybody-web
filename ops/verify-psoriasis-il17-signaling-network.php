<?php
require_once __DIR__ . '/../backend/db.php';
$out=['ok'=>false,'stage'=>'start'];
try {
  $sql=file_get_contents(__DIR__.'/../backend/phase_112_psoriasis_il17_signaling_network.sql');
  $parts=preg_split('/;\s*(?:\r?\n|$)/',$sql);
  $n=0;
  foreach($parts as $stmt){$stmt=trim($stmt); if($stmt==='')continue; $n++; try{$pdo->exec($stmt);}catch(Throwable $e){throw new RuntimeException('statement '.$n.' failed: '.substr(preg_replace('/\s+/',' ',$stmt),0,180).' :: '.$e->getMessage(),0,$e);}}
  $r=$pdo->query('SELECT * FROM v_ilb_pso112_readiness')->fetch(PDO::FETCH_ASSOC);
  if((int)$r['reactions']!==10) throw new RuntimeException('expected 10 reactions');
  if((int)$r['states']!==10) throw new RuntimeException('expected 10 states');
  if((int)$r['primitives']!==16) throw new RuntimeException('expected 16 primitives');
  if((int)$r['numeric_primitives']!==0) throw new RuntimeException('unsourced numeric primitives present');
  if((int)$r['unresolved_transfer_steps']<2) throw new RuntimeException('critical unresolved transfer steps not preserved');
  $out=['ok'=>true,'stage'=>'complete','migration_statements'=>$n,'readiness'=>$r,'rule'=>'Reaction structure is derived; no free signaling weights or universal cell-cycle transfer function are permitted.'];
} catch(Throwable $e){$out=['ok'=>false,'stage'=>'failed','error'=>$e->getMessage(),'file'=>$e->getFile(),'line'=>$e->getLine()]; http_response_code(500);}
header('Content-Type: application/json'); echo json_encode($out,JSON_PRETTY_PRINT|JSON_UNESCAPED_SLASHES).PHP_EOL;
