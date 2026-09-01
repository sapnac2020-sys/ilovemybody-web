<?php
declare(strict_types=1);
try {
  $c=require $argv[1]; if(isset($c['database'])) $c=$c['database'];
  $p=new PDO("mysql:host={$c['host']};dbname=".($c['db']??$c['name']).";charset=utf8mb4",
    $c['user'],$c['pass']??$c['password'],[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION]);
  $q=$p->query("SELECT p.point_code,p.stated_position_text,a.code,a.name,a.item_type
    FROM ilb_aatmn_parmar_point_source p
    JOIN anatomy_items a ON CHAR_LENGTH(a.name)>=3
      AND LOCATE(LOWER(a.name),LOWER(p.stated_position_text))>0
    WHERE a.status='active'
    ORDER BY p.point_code,a.name");
  $rows=$q->fetchAll(PDO::FETCH_ASSOC);
  echo json_encode(['candidate_matches'=>count($rows),'matches'=>$rows]),PHP_EOL;
} catch(Throwable $e) { echo 'AATMN_CANDIDATE_AUDIT_ERROR: '.$e->getMessage(),PHP_EOL; exit(1); }