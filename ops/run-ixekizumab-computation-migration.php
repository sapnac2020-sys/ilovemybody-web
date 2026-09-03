<?php
declare(strict_types=1);
const EXPECTED_DATABASE='u756742628_ilovemybody';
if(PHP_SAPI!=='cli')exit(2);
$c=require($argv[1]??'');if(isset($c['database'])&&is_array($c['database']))$c=$c['database'];
$db=$c['db']??($c['name']??null);if($db!==EXPECTED_DATABASE)throw new RuntimeException('Unexpected database');
$p=new PDO("mysql:host=".$c['host'].";port=".($c['port']??3306).";dbname={$db};charset=utf8mb4",$c['user'],$c['pass']??$c['password'],[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION,PDO::MYSQL_ATTR_MULTI_STATEMENTS=>true]);
$s=$p->prepare(file_get_contents($argv[2]??''));$s->execute();do{if($s->columnCount())$s->fetchAll();}while($s->nextRowset());$s->closeCursor();
$r=$p->query("SELECT * FROM v_ilmb_ixekizumab_computation_readiness")->fetch(PDO::FETCH_ASSOC);
$r['patient_rows_read']=0;$r['patient_rows_modified']=0;
$r['ready']=((int)$r['approved_connectors']===4&&(int)$r['blocked_connectors']===2&&(int)$r['registered_equations']===8&&(int)$r['missing_parameters']===7&&(int)$r['pk_pd_patient_execution_enabled']===0&&(int)$r['pasi_execution_enabled']===1&&(int)$r['acupuncture_causal_execution_enabled']===0);
echo json_encode($r,JSON_PRETTY_PRINT|JSON_UNESCAPED_SLASHES),PHP_EOL;if(!$r['ready'])exit(4);
