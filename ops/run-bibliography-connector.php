<?php
declare(strict_types=1);
try {
  $c=require $argv[1]; if(isset($c['database'])) $c=$c['database'];
  $p=new PDO("mysql:host={$c['host']};dbname=".($c['db']??$c['name']).";charset=utf8mb4",
    $c['user'],$c['pass']??$c['password'],
    [PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION,PDO::MYSQL_ATTR_MULTI_STATEMENTS=>true]);
  $s=$p->prepare(file_get_contents($argv[2]));$s->execute();
  do {if($s->columnCount())$s->fetchAll();}while($s->nextRowset());
  $q=$p->query("SELECT object_type,objects_total,objects_with_active_source FROM v_ilb_bibliography_coverage")->fetchAll(PDO::FETCH_ASSOC);
  echo json_encode(['bibliography_entries'=>(int)$p->query("SELECT COUNT(*) FROM ilb_bibliography_entry")->fetchColumn(),
    'bibliography_links'=>(int)$p->query("SELECT COUNT(*) FROM ilb_bibliography_link")->fetchColumn(),
    'coverage'=>$q,'patient_rows_modified'=>0]),PHP_EOL;
  exit(0);
}catch(Throwable $e){echo 'BIBLIOGRAPHY_CONNECTOR_ERROR: '.$e->getMessage(),PHP_EOL;exit(1);}