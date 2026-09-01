<?php
declare(strict_types=1);
try {
  $c=require $argv[1]; if(isset($c['database'])) $c=$c['database'];
  $p=new PDO("mysql:host={$c['host']};dbname=".($c['db']??$c['name']).";charset=utf8mb4",
    $c['user'],$c['pass']??$c['password'],[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION]);
  $q=$p->query("SELECT table_name,table_type
    FROM information_schema.tables
    WHERE table_schema=DATABASE()
      AND (LOWER(table_name) LIKE '%uberon%' OR LOWER(table_name) LIKE '%anatom%' OR LOWER(table_name) LIKE '%body_part%')
    ORDER BY table_name");
  $objects=$q->fetchAll(PDO::FETCH_ASSOC);
  echo json_encode(['anatomy_candidate_objects'=>$objects,
    'aatmn_points'=>(int)$p->query("SELECT COUNT(*) FROM ilb_aatmn_parmar_point_source")->fetchColumn()]),PHP_EOL;
} catch(Throwable $e) { echo 'AATMN_ANATOMY_AUDIT_ERROR: '.$e->getMessage(),PHP_EOL; exit(1); }