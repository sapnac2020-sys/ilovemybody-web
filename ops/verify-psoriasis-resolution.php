<?php
// Phase 114 verifier: psoriasis differentiation / cornification / barrier / plaque resolution
header('Content-Type: application/json');
require_once __DIR__ . '/../config.php';

$out=['ok'=>false,'stage'=>'init'];
try {
  $pdo = new PDO($dsn,$db_user,$db_pass,[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION]);
  $out['database']=$db_name ?? null;
  $sql=file_get_contents(__DIR__.'/../backend/phase_114_psoriasis_differentiation_resolution.sql');
  if($sql===false) throw new RuntimeException('Cannot read Phase 114 SQL');
  $stmts=array_values(array_filter(array_map('trim',preg_split('/;\s*(?:\r?\n|$)/',$sql)),fn($s)=>$s!=='' && !str_starts_with($s,'--')));
  $out['stage']='migration';
  $i=0;
  foreach($stmts as $stmt){$i++; try{$pdo->exec($stmt);}catch(Throwable $e){$out['failed_statement']=$i;$out['statement_head']=substr(preg_replace('/\s+/',' ',$stmt),0,220);throw $e;}}
  $out['migration_statements']=$i;
  $out['stage']='verify';
  $r=$pdo->query('SELECT * FROM v_ilb_psoriasis_resolution_readiness')->fetch(PDO::FETCH_ASSOC);
  if(!$r) throw new RuntimeException('Readiness view missing');
  if((int)$r['equations']<16) throw new RuntimeException('Expected >=16 resolution equations');
  if((int)$r['primitives']<20) throw new RuntimeException('Expected >=20 primitives');
  if((int)$r['numeric_primitives']!==0) throw new RuntimeException('Unsourced numeric primitives detected');
  $q=$pdo->query("SELECT COUNT(*) FROM ilb_psoriasis_resolution_equation WHERE equation_name IN ('Plaque resolution condition','Corneocyte pool resolution','Viable differentiated pool resolution','Proliferative pool resolution')")->fetchColumn();
  if((int)$q!==4) throw new RuntimeException('Resolution inequalities incomplete');
  $out['readiness']=$r;
  $out['stage']='complete';$out['ok']=true;
}catch(Throwable $e){$out['exception']=get_class($e);$out['error']=$e->getMessage();$out['file']=$e->getFile();$out['line']=$e->getLine();}
echo json_encode($out,JSON_PRETTY_PRINT|JSON_UNESCAPED_SLASHES),PHP_EOL;
