<?php
declare(strict_types=1);
const EXPECTED_DATABASE='u756742628_ilovemybody';
if(PHP_SAPI!=='cli') exit(2);
$configPath=$argv[1]??'';$sqlPath=$argv[2]??'';
if(!is_file($configPath)||!is_file($sqlPath)) exit(2);
$c=require $configPath;if(isset($c['database'])&&is_array($c['database']))$c=$c['database'];
$host=$c['host']??null;$port=(int)($c['port']??3306);$db=$c['db']??($c['name']??null);$user=$c['user']??null;$pass=$c['pass']??($c['password']??null);
if($db!==EXPECTED_DATABASE) throw new RuntimeException('Unexpected database');
$pdo=new PDO("mysql:host={$host};port={$port};dbname={$db};charset=utf8mb4",$user,$pass,[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION,PDO::MYSQL_ATTR_MULTI_STATEMENTS=>true,PDO::ATTR_DEFAULT_FETCH_MODE=>PDO::FETCH_ASSOC]);
$sql=file_get_contents($sqlPath);$st=$pdo->prepare($sql);$st->execute();do{if($st->columnCount())$st->fetchAll();}while($st->nextRowset());$st->closeCursor();
$row=$pdo->query("SELECT COUNT(*) total,SUM(computation_eligible=1) eligible,SUM(source_endpoint_resolved=0 OR target_endpoint_resolved=0) unresolved FROM ilmb_entity_crosswalk WHERE source_system='LOINC' AND target_system='CHEBI' AND predicate='MEASURES'")->fetch();
$view=(int)$pdo->query("SELECT EXISTS(SELECT 1 FROM v_ilmb_loinc_chebi_compute LIMIT 1)")->fetchColumn();
$rule=(int)$pdo->query("SELECT COUNT(*) FROM ilb_lab_correlation_rule WHERE rule_key='lab_reference_position' AND version_label='1.1' AND status='active'")->fetchColumn();
$contracts=(int)$pdo->query("SELECT COUNT(*) FROM ilb_lab_measurement_contract WHERE active=1")->fetchColumn();
$known=(int)$pdo->query("SELECT COUNT(*) FROM ilb_lab_measurement_contract WHERE loinc_num='2344-0' AND canonical_specimen='Body fld' AND example_ucum_unit='mg/dL' AND active=1")->fetchColumn();
$out=['crosswalk'=>$row,'view_rows'=>$view,'measurement_contracts'=>$contracts,'known_contracts'=>$known,'active_rules'=>$rule,'patient_rows_read'=>0,'patient_rows_modified'=>0,'ready'=>$view>0&&$rule===1&&$contracts>0&&$known===1&&(int)$row['eligible']>0];
echo json_encode($out,JSON_PRETTY_PRINT|JSON_UNESCAPED_SLASHES),PHP_EOL;
if(!$out['ready']) exit(4);
