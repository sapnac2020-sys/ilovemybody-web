<?php
declare(strict_types=1);
try {
  $c=require $argv[1]; if(isset($c['database'])) $c=$c['database'];
  $p=new PDO("mysql:host={$c['host']};dbname=".($c['db']??$c['name']).";charset=utf8mb4",
    $c['user'],$c['pass']??$c['password'],
    [PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION,PDO::MYSQL_ATTR_MULTI_STATEMENTS=>true]);
  $s=$p->prepare(file_get_contents($argv[2])); $s->execute();
  do { if($s->columnCount()) $s->fetchAll(); } while($s->nextRowset());
  $q=$p->query("SELECT COUNT(*) total,
    SUM(anatomical_location_status='PENDING') anatomy_pending,
    SUM(pairing_rule_status='PENDING') pairing_pending,
    SUM(claimed_effect_status='PENDING') effect_pending
    FROM ilb_aatmn_point_verification")->fetch();
  echo json_encode(['verification_rows'=>(int)$q['total'],
    'anatomy_pending'=>(int)$q['anatomy_pending'],'pairing_pending'=>(int)$q['pairing_pending'],
    'effect_pending'=>(int)$q['effect_pending'],'automatic_promotions'=>0,'patient_rows_modified'=>0]),PHP_EOL;
  exit((int)$q['total']===271?0:4);
} catch(Throwable $e) { echo 'AATMN_WORKBENCH_ERROR: '.$e->getMessage(),PHP_EOL; exit(1); }