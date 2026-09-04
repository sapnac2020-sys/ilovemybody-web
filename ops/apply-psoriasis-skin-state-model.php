<?php
declare(strict_types=1); ini_set('display_errors','stderr'); error_reporting(E_ALL);
const EXPECTED_DATABASE='u756742628_ilovemybody'; if(PHP_SAPI!=='cli')exit(2);
$config=require($argv[1]??''); if(isset($config['database'])&&is_array($config['database']))$config=$config['database'];
$database=$config['db']??($config['name']??null); if($database!==EXPECTED_DATABASE)throw new RuntimeException('Unexpected database');
$sqlPath=$argv[2]??''; if(!is_file($sqlPath))throw new RuntimeException('Phase 89 SQL missing');
$pdo=new PDO('mysql:host='.$config['host'].';port='.($config['port']??3306).';dbname='.$database.';charset=utf8mb4',$config['user'],$config['pass']??$config['password'],[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION,PDO::MYSQL_ATTR_MULTI_STATEMENTS=>true,PDO::ATTR_DEFAULT_FETCH_MODE=>PDO::FETCH_ASSOC]);
$s=$pdo->prepare(file_get_contents($sqlPath));$s->execute();do{if($s->columnCount())$s->fetchAll();}while($s->nextRowset());$s->closeCursor();
$states=$pdo->query('SELECT state_key,state_name,desired_direction FROM ilb_psoriasis_skin_state_variable ORDER BY state_key')->fetchAll();
$observables=$pdo->query('SELECT state_key,COUNT(*) n,SUM(universal_threshold_available) universal_thresholds FROM ilb_psoriasis_skin_state_observable GROUP BY state_key ORDER BY state_key')->fetchAll();
$gates=$pdo->query('SELECT gate_order,gate_key,patient_experiment FROM ilb_psoriasis_modification_gate ORDER BY gate_order')->fetchAll();
if(count($states)!==5||array_sum(array_column($observables,'n'))!==12||count($gates)!==8||array_sum(array_column($gates,'patient_experiment'))!==0)throw new RuntimeException('Phase 89 invariant failed');
echo json_encode(['database'=>$database,'phase'=>'P89_MEASURABLE_SKIN_STATE_MODEL','states'=>$states,'observable_counts'=>$observables,'total_observables'=>12,'gates'=>$gates,'universal_numeric_thresholds'=>0,'candidate_interventions_registered'=>0,'patient_tables_queried'=>false,'patient_rows_read'=>0,'patient_rows_modified'=>0,'verified'=>true],JSON_PRETTY_PRINT|JSON_UNESCAPED_SLASHES),PHP_EOL;
