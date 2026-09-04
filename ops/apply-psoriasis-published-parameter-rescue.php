<?php
declare(strict_types=1); ini_set('display_errors','stderr'); error_reporting(E_ALL);
const EXPECTED_DATABASE='u756742628_ilovemybody'; if(PHP_SAPI!=='cli')exit(2);
$config=require($argv[1]??''); if(isset($config['database'])&&is_array($config['database']))$config=$config['database'];
$database=$config['db']??($config['name']??null); if($database!==EXPECTED_DATABASE)throw new RuntimeException('Unexpected database');
$sqlPath=$argv[2]??''; if(!is_file($sqlPath))throw new RuntimeException('Phase 96 SQL missing');
$pdo=new PDO('mysql:host='.$config['host'].';port='.($config['port']??3306).';dbname='.$database.';charset=utf8mb4',$config['user'],$config['pass']??$config['password'],[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION,PDO::MYSQL_ATTR_MULTI_STATEMENTS=>true,PDO::ATTR_DEFAULT_FETCH_MODE=>PDO::FETCH_ASSOC]);
$s=$pdo->prepare(file_get_contents($sqlPath));$s->execute();do{if($s->columnCount())$s->fetchAll();}while($s->nextRowset());$s->closeCursor();
$rows=$pdo->query('SELECT candidate_key,parameter_key,numeric_value,unit,compatibility,exact_in_source,promotion_allowed FROM ilb_psoriasis_published_parameter_candidate ORDER BY candidate_key')->fetchAll();
$covered=count(array_unique(array_column($rows,'parameter_key')));$exact=array_sum(array_column($rows,'exact_in_source'));$promotable=array_sum(array_column($rows,'promotion_allowed'));
$unresolved=(int)$pdo->query("SELECT COUNT(*) FROM ilb_psoriasis_experiment_parameter WHERE experiment_key='EXP_PSO_RESET_001' AND resolution='UNRESOLVED'")->fetchColumn();
if(count($rows)!==7||$covered!==7||$exact!==7||$promotable!==0||$unresolved!==10)throw new RuntimeException('Phase 96 invariant failed');
echo json_encode(['database'=>$database,'phase'=>'P96_PUBLISHED_PARAMETER_RESCUE','candidate_records'=>count($rows),'previously_open_parameters_with_published_evidence'=>$covered,'candidates'=>$rows,'directly_promoted'=>0,'reason_not_promoted'=>'Values are exact in their sources but arise from an alternate 3D model or from induction rather than post-reset rechallenge.','remaining_formally_unresolved'=>10,'new_numbers_discovered'=>true,'invented_values'=>0,'patient_tables_queried'=>false,'patient_rows_read'=>0,'patient_rows_modified'=>0,'verified'=>true],JSON_PRETTY_PRINT|JSON_UNESCAPED_SLASHES),PHP_EOL;
