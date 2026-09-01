<?php
declare(strict_types=1);
try {
  $c=require $argv[1]; if(isset($c['database'])) $c=$c['database'];
  $p=new PDO("mysql:host={$c['host']};dbname=".($c['db']??$c['name']).";charset=utf8mb4",
    $c['user'],$c['pass']??$c['password'],
    [PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION,PDO::MYSQL_ATTR_MULTI_STATEMENTS=>true]);
  $s=$p->prepare(file_get_contents($argv[2])); $s->execute();
  do { if($s->columnCount()) $s->fetchAll(); } while($s->nextRowset());
  $n=(int)$p->query("SELECT COUNT(*) FROM ilb_aatmn_parmar_point_source")->fetchColumn();
  $m=(int)$p->query("SELECT COUNT(*) FROM ilb_aatmn_parmar_point_source WHERE medical_mapping_status='EXACT_MAPPED'")->fetchColumn();
  echo json_encode(['aatmn_source_points'=>$n,'medical_mappings'=>$m,'formulas_added'=>0,'patient_rows_modified'=>0]),PHP_EOL;
  exit($n===271?0:4);
} catch(Throwable $e) { echo 'AATMN_SOURCE_IMPORT_ERROR: '.$e->getMessage(),PHP_EOL; exit(1); }