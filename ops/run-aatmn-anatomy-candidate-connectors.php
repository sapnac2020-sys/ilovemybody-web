<?php
declare(strict_types=1);
try {
  $c=require $argv[1]; if(isset($c['database'])) $c=$c['database'];
  $p=new PDO("mysql:host={$c['host']};dbname=".($c['db']??$c['name']).";charset=utf8mb4",
    $c['user'],$c['pass']??$c['password'],
    [PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION,PDO::MYSQL_ATTR_MULTI_STATEMENTS=>true]);
  $s=$p->prepare(file_get_contents($argv[2])); $s->execute();
  do { if($s->columnCount()) $s->fetchAll(); } while($s->nextRowset());
  $q=$p->query("SELECT candidate_status,COUNT(*) AS count
    FROM ilb_aatmn_anatomy_candidate GROUP BY candidate_status ORDER BY candidate_status")
    ->fetchAll(PDO::FETCH_ASSOC);
  echo json_encode([
    'source_points'=>(int)$p->query("SELECT COUNT(*) FROM ilb_aatmn_parmar_point_source")->fetchColumn(),
    'anatomy_candidates'=>(int)$p->query("SELECT COUNT(*) FROM ilb_aatmn_anatomy_candidate")->fetchColumn(),
    'candidate_statuses'=>$q,
    'automatic_verifications'=>0,
    'patient_rows_modified'=>0
  ]),PHP_EOL;
} catch(Throwable $e) {
  echo 'AATMN_ANATOMY_CANDIDATE_CONNECTOR_ERROR: '.$e->getMessage(),PHP_EOL; exit(1);
}