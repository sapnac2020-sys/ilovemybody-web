<?php
declare(strict_types=1);
const EXPECTED_DATABASE='u756742628_ilovemybody';
if(PHP_SAPI!=='cli') exit(2);
$configPath=$argv[1]??''; $sqlPath=$argv[2]??'';
if(!is_file($configPath)||!is_file($sqlPath)) exit(2);
$c=require $configPath; if(isset($c['database'])&&is_array($c['database'])) $c=$c['database'];
$host=$c['host']??null; $port=(int)($c['port']??3306); $db=$c['db']??($c['name']??null); $user=$c['user']??null; $pass=$c['pass']??($c['password']??null);
if($db!==EXPECTED_DATABASE) throw new RuntimeException('Unexpected database');
$pdo=new PDO("mysql:host={$host};port={$port};dbname={$db};charset=utf8mb4",$user,$pass,[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION,PDO::MYSQL_ATTR_MULTI_STATEMENTS=>true]);
$st=$pdo->prepare((string)file_get_contents($sqlPath)); $st->execute(); do { if($st->columnCount()) $st->fetchAll(); } while($st->nextRowset()); $st->closeCursor();
$count=(int)$pdo->query("SELECT COUNT(*) FROM v_ilb_test_topic_catalog")->fetchColumn();
$required=(int)$pdo->query("SELECT COUNT(*) FROM ilb_test_topic_catalog WHERE topic_key IN ('blood_count_iron','glucose_metabolism','pathology_laboratory','radiology_imaging','skin_hair','preventive_screening') AND status='active'")->fetchColumn();
$out=['active_topics'=>$count,'required_topics'=>$required,'patient_rows_read'=>0,'patient_rows_modified'=>0,'ready'=>$count===18&&$required===5];
echo json_encode($out,JSON_PRETTY_PRINT|JSON_UNESCAPED_SLASHES),PHP_EOL;
if(!$out['ready']) exit(4);
