<?php
declare(strict_types=1);
try {
  $c=require $argv[1]; if(isset($c['database'])) $c=$c['database'];
  $p=new PDO("mysql:host={$c['host']};dbname=".($c['db']??$c['name']).";charset=utf8mb4",
    $c['user'],$c['pass']??$c['password'],
    [PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION,PDO::MYSQL_ATTR_MULTI_STATEMENTS=>true]);
  $s=$p->prepare(file_get_contents($argv[2])); $s->execute();
  do { if($s->columnCount()) $s->fetchAll(); } while($s->nextRowset());
  $tables=(int)$p->query("SELECT COUNT(*) FROM information_schema.tables WHERE table_schema=DATABASE() AND table_name='ilb_subject_test_result_ledger'")->fetchColumn();
  echo json_encode(['result_ledger_ready'=>$tables===1,'patient_rows_modified'=>0]),PHP_EOL;
  exit($tables===1?0:4);
} catch(Throwable $e) { echo 'RESULT_LEDGER_ERROR: '.$e->getMessage(),PHP_EOL; exit(1); }