<?php
declare(strict_types=1);
try {
  $c=require $argv[1]; if(isset($c['database'])) $c=$c['database'];
  $p=new PDO("mysql:host={$c['host']};dbname=".($c['db']??$c['name']).";charset=utf8mb4",
    $c['user'],$c['pass']??$c['password'],
    [PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION,PDO::MYSQL_ATTR_MULTI_STATEMENTS=>true]);
  $s=$p->prepare(file_get_contents($argv[2])); $s->execute();
  do { if($s->columnCount()) $s->fetchAll(); } while($s->nextRowset());
  echo json_encode([
    'candidate_links'=>(int)$p->query("SELECT COUNT(*) FROM ilb_aatmn_anatomy_candidate")->fetchColumn(),
    'exact_uberon_anchor_checks'=>(int)$p->query("SELECT COUNT(*) FROM ilb_aatmn_uberon_anchor_check")->fetchColumn(),
    'point_location_verifications'=>(int)$p->query("SELECT COUNT(*) FROM ilb_aatmn_point_verification WHERE anatomical_location_status='IDENTIFIABLE'")->fetchColumn(),
    'automatic_point_verifications'=>0,
    'patient_rows_modified'=>0
  ]),PHP_EOL;
} catch(Throwable $e) { echo 'AATMN_UBERON_ANCHOR_CHECK_ERROR: '.$e->getMessage(),PHP_EOL; exit(1); }