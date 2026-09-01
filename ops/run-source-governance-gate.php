<?php
declare(strict_types=1);
try {
  $c=require $argv[1]; if(isset($c['database'])) $c=$c['database'];
  $p=new PDO("mysql:host={$c['host']};dbname=".($c['db']??$c['name']).";charset=utf8mb4",
    $c['user'],$c['pass']??$c['password'],
    [PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION,PDO::MYSQL_ATTR_MULTI_STATEMENTS=>true]);
  $s=$p->prepare(file_get_contents($argv[2])); $s->execute();
  do { if($s->columnCount()) $s->fetchAll(); } while($s->nextRowset());
  $gate=$p->query("SELECT source_key,governance_status,connector_eligible,calculation_eligible,output_gate
    FROM v_ilb_source_governance_gate WHERE source_key='aatmn_parmar_sakshi_xlsx'")->fetch(PDO::FETCH_ASSOC);
  if(!$gate || $gate['output_gate']!=='BLOCKED') throw new RuntimeException('legacy source governance gate is not blocked');
  echo json_encode(['source_governance'=>$gate,'aatmn_rows_preserved'=>(int)$p->query("SELECT COUNT(*) FROM ilb_aatmn_parmar_point_source")->fetchColumn(),'patient_rows_modified'=>0]),PHP_EOL;
} catch(Throwable $e) {
  echo 'SOURCE_GOVERNANCE_GATE_ERROR: '.$e->getMessage(),PHP_EOL; exit(1);
}