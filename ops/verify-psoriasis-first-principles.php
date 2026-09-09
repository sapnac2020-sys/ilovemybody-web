<?php
require_once __DIR__ . '/../backend/db.php';
header('Content-Type: application/json');
$out=['ok'=>false,'stage'=>'start'];
try {
  $sql=file_get_contents(__DIR__.'/../backend/phase_109_psoriasis_first_principles_verification.sql');
  $parts=preg_split('/;\s*(?:\r?\n|$)/',$sql);
  $n=0;
  foreach($parts as $stmt){$stmt=trim($stmt); if($stmt===''||str_starts_with($stmt,'--')) continue; $n++; try{$pdo->exec($stmt);}catch(Throwable $e){throw new RuntimeException('statement '.$n.' failed: '.substr(preg_replace('/\s+/',' ',$stmt),0,180).' :: '.$e->getMessage(),0,$e);} }
  $r=$pdo->query('SELECT * FROM v_ilb_pso_phase109_readiness')->fetch(PDO::FETCH_ASSOC);
  $dataset=$pdo->query("SELECT role_class,may_supply_coefficients,may_supply_mechanism FROM ilb_pso_verification_dataset WHERE dataset_id='VERIFY-HOMEO-001'")->fetch(PDO::FETCH_ASSOC);
  if(!$r || $r['readiness_status']!=='FORMULA_FIRST_READY') throw new RuntimeException('readiness gate failed');
  if(!$dataset || $dataset['role_class']!=='VERIFICATION_ONLY' || (int)$dataset['may_supply_coefficients']!==0 || (int)$dataset['may_supply_mechanism']!==0) throw new RuntimeException('verification isolation failed');
  $out=['ok'=>true,'stage'=>'complete','migration_statements'=>$n,'readiness'=>$r,'homeopathy_boundary'=>$dataset,'rule'=>'Derive -> predict -> verify. Verification data cannot supply biological coefficients or mechanisms.'];
}catch(Throwable $e){$out['stage']='failed';$out['error']=$e->getMessage();$out['file']=$e->getFile();$out['line']=$e->getLine();}
echo json_encode($out,JSON_PRETTY_PRINT|JSON_UNESCAPED_SLASHES),"\n";
