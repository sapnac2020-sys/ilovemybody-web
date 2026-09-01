<?php
declare(strict_types=1);
const EXPECTED_DATABASE='u756742628_ilovemybody';
try {
  $config=$argv[1]??''; $sql=$argv[2]??'';
  if(PHP_SAPI!=='cli'||!is_file($config)||!is_file($sql)) throw new RuntimeException('Missing CLI config or SQL');
  $c=require $config; if(isset($c['database'])) $c=$c['database'];
  if(($c['db']??$c['name']??'')!==EXPECTED_DATABASE) throw new RuntimeException('Unexpected database');
  $pdo=new PDO("mysql:host={$c['host']};port=".($c['port']??3306).";dbname=".($c['db']??$c['name']).";charset=utf8mb4",$c['user'],$c['pass']??$c['password'],[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION,PDO::MYSQL_ATTR_MULTI_STATEMENTS=>true]);
  $st=$pdo->prepare((string)file_get_contents($sql)); $st->execute();
  do { if($st->columnCount()) $st->fetchAll(); } while($st->nextRowset()); $st->closeCursor();
  $total=(int)$pdo->query("SELECT COUNT(*) FROM ilb_source_data_object_registry")->fetchColumn();
  $unclassified=(int)$pdo->query("SELECT COUNT(*) FROM ilb_source_data_object_registry WHERE provenance_status='UNCLASSIFIED'")->fetchColumn();
  $registered=(int)$pdo->query("SELECT COUNT(*) FROM ilb_source_data_object_registry WHERE domain_key IS NOT NULL")->fetchColumn();
  echo json_encode(['objects_registered'=>$total,'with_domain_role'=>$registered,'unclassified_provenance'=>$unclassified,'patient_rows_read'=>0,'patient_rows_modified'=>0,'ready'=>$total>=1344],JSON_PRETTY_PRINT),PHP_EOL;
  exit($total>=1344?0:4);
} catch(Throwable $e) { fwrite(STDOUT,'SOURCE_MASTER_ERROR: '.$e->getMessage().PHP_EOL); exit(1); }
