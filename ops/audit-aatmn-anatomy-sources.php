<?php
declare(strict_types=1);
try {
  $c=require $argv[1]; if(isset($c['database'])) $c=$c['database'];
  $p=new PDO("mysql:host={$c['host']};dbname=".($c['db']??$c['name']).";charset=utf8mb4",
    $c['user'],$c['pass']??$c['password'],[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION]);
  $tables=['ilb_anatomical_landmark_master','ilb_body_part','anatomy_items'];
  $out=[];
  foreach($tables as $t){
    $columns=$p->prepare("SELECT column_name,data_type FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name=? ORDER BY ordinal_position");
    $columns->execute([$t]);
    $out[$t]=['columns'=>$columns->fetchAll(PDO::FETCH_ASSOC)];
    try {$out[$t]['sample']=$p->query("SELECT * FROM \`$t\` LIMIT 3")->fetchAll(PDO::FETCH_ASSOC);}catch(Throwable $e){$out[$t]['sample_error']=$e->getMessage();}
  }
  echo json_encode(['sources'=>$out]),PHP_EOL;
} catch(Throwable $e) { echo 'AATMN_ANATOMY_AUDIT_ERROR: '.$e->getMessage(),PHP_EOL; exit(1); }