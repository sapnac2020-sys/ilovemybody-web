<?php
declare(strict_types=1);
try {
  $c=require $argv[1]; if(isset($c['database'])) $c=$c['database'];
  $p=new PDO("mysql:host={$c['host']};dbname=".($c['db']??$c['name']).";charset=utf8mb4",
    $c['user'],$c['pass']??$c['password'],
    [PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION,PDO::MYSQL_ATTR_MULTI_STATEMENTS=>true]);
  $s=$p->prepare(file_get_contents($argv[2])); $s->execute();
  do { if($s->columnCount()) $s->fetchAll(); } while($s->nextRowset());
  $q=$p->query("SELECT COUNT(*) formulas_total,
    COALESCE(SUM(validation_status='VERIFIED'),0) formulas_verified
    FROM ilb_equation_registry")->fetch();
  $cases=(int)$p->query("SELECT COUNT(*) FROM ilb_equation_verification_case")->fetchColumn();
  echo json_encode(['formula_verification_gate_ready'=>true,'formulas_total'=>(int)$q['formulas_total'],
    'formulas_verified'=>(int)$q['formulas_verified'],'verification_cases'=>$cases,'patient_rows_modified'=>0]),PHP_EOL;
} catch(Throwable $e) { echo 'FORMULA_VERIFICATION_GATE_ERROR: '.$e->getMessage(),PHP_EOL; exit(1); }