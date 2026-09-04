<?php
declare(strict_types=1);
const EXPECTED_DATABASE='u756742628_ilovemybody';
if(PHP_SAPI!=='cli') exit(2);
$c=require($argv[1]??'');
if(isset($c['database'])&&is_array($c['database'])) $c=$c['database'];
$db=$c['db']??($c['name']??null);
if($db!==EXPECTED_DATABASE) throw new RuntimeException('Unexpected database');
$pdo=new PDO("mysql:host=".$c['host'].";port=".($c['port']??3306).";dbname={$db};charset=utf8mb4",$c['user'],$c['pass']??$c['password'],[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION,PDO::MYSQL_ATTR_MULTI_STATEMENTS=>true]);
$st=$pdo->prepare(file_get_contents($argv[2]??''));
$st->execute();
do { if($st->columnCount()) $st->fetchAll(); } while($st->nextRowset());
$st->closeCursor();
$r=$pdo->query("SELECT * FROM v_ilmb_psoriasis_feedback_control_readiness")->fetch(PDO::FETCH_ASSOC);
$out=[
 'active_loop_segments'=>(int)$r['active_loop_segments'],
 'ready_observables'=>(int)$r['ready_observables'],
 'measurement_required'=>(int)$r['measurement_required'],
 'executable_equations'=>(int)$r['executable_equations'],
 'parameter_gated_equations'=>(int)$r['parameter_gated_equations'],
 'persistence_loop_structurally_complete'=>(int)$r['persistence_loop_structurally_complete'],
 'feedback_loop_numerically_identified'=>(int)$r['feedback_loop_numerically_identified'],
 'patient_execution_ready'=>(int)$r['feedback_loop_numerically_identified'],
 'patient_rows_read'=>0,
 'patient_rows_modified'=>0
];
$out['structural_ready']=$out['active_loop_segments']===9&&$out['ready_observables']===3&&
 $out['measurement_required']===7&&$out['executable_equations']===1&&
 $out['parameter_gated_equations']===6&&$out['persistence_loop_structurally_complete']===1;
$out['ready']=$out['structural_ready'];
echo json_encode($out,JSON_PRETTY_PRINT|JSON_UNESCAPED_SLASHES),PHP_EOL;
if(!$out['structural_ready']) exit(4);
