<?php
declare(strict_types=1);
try {
  $c=require $argv[1]; if(isset($c['database'])) $c=$c['database'];
  $p=new PDO("mysql:host={$c['host']};dbname=".($c['db']??$c['name']).";charset=utf8mb4",
    $c['user'],$c['pass']??$c['password'],
    [PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION,PDO::MYSQL_ATTR_MULTI_STATEMENTS=>true]);
  $s=$p->prepare(file_get_contents($argv[2])); $s->execute();
  do { if($s->columnCount()) $s->fetchAll(); } while($s->nextRowset());
  $readiness=$p->query("SELECT next_required_step,COUNT(*) AS count
    FROM ilb_aatmn_location_verification_readiness GROUP BY next_required_step ORDER BY next_required_step")
    ->fetchAll(PDO::FETCH_ASSOC);
  $spatial=$p->query("SELECT spatial_reference_grade,COUNT(*) AS count
    FROM ilb_aatmn_location_verification_readiness GROUP BY spatial_reference_grade ORDER BY spatial_reference_grade")
    ->fetchAll(PDO::FETCH_ASSOC);
  echo json_encode([
    'points_audited'=>(int)$p->query("SELECT COUNT(*) FROM ilb_aatmn_location_verification_readiness")->fetchColumn(),
    'readiness'=>$readiness,
    'spatial_reference'=>$spatial,
    'controlled_landmarks_loaded'=>(int)$p->query("SELECT COUNT(*) FROM ilb_anatomical_landmark_master")->fetchColumn(),
    'automatic_anatomy_verifications'=>0,
    'patient_rows_modified'=>0
  ]),PHP_EOL;
} catch(Throwable $e) {
  echo 'AATMN_LOCATION_READINESS_ERROR: '.$e->getMessage(),PHP_EOL; exit(1);
}