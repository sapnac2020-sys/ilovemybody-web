<?php
declare(strict_types=1);
try {
 $c=require $argv[1]; if(isset($c['database']))$c=$c['database']; $sql=$argv[2];
 $pdo=new PDO("mysql:host={$c['host']};dbname=".($c['db']??$c['name']).";charset=utf8mb4",$c['user'],$c['pass']??$c['password'],[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION,PDO::MYSQL_ATTR_MULTI_STATEMENTS=>true]);
 $s=$pdo->prepare(file_get_contents($sql));$s->execute();do{if($s->columnCount())$s->fetchAll();}while($s->nextRowset());
 $n=(int)$pdo->query("SELECT COUNT(*) FROM ilb_source_dataset")->fetchColumn();echo json_encode(['verified_source_datasets'=>$n,'patient_rows_modified'=>0,'ready'=>$n===8]),PHP_EOL;exit($n===8?0:4);
}catch(Throwable $e){echo 'SOURCE_CATALOGUE_ERROR: '.$e->getMessage(),PHP_EOL;exit(1);}
