<?php
declare(strict_types=1);
const EXPECTED_DATABASE='u756742628_ilovemybody';
if(PHP_SAPI!=='cli') exit(2);
$c=require($argv[1]??'');
if(isset($c['database'])&&is_array($c['database'])) $c=$c['database'];
$db=$c['db']??($c['name']??null);
if($db!==EXPECTED_DATABASE) throw new RuntimeException('Unexpected database');
$pdo=new PDO("mysql:host=".$c['host'].";port=".($c['port']??3306).";dbname={$db};charset=utf8mb4",$c['user'],$c['pass']??$c['password'],[
 PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION,
 PDO::MYSQL_ATTR_MULTI_STATEMENTS=>true
]);
$st=$pdo->prepare(file_get_contents($argv[2]??''));
$st->execute();
do { if($st->columnCount()) $st->fetchAll(); } while($st->nextRowset());
$st->closeCursor();
$readiness=$pdo->query("SELECT * FROM v_ilmb_psoriasis_mechanism_readiness")->fetch(PDO::FETCH_ASSOC);
$out=[
 'nodes'=>(int)$readiness['active_nodes'],
 'edges'=>(int)$readiness['active_edges'],
 'computable_edges'=>(int)$readiness['computable_edges'],
 'hypothesis_edges'=>(int)$readiness['hypothesis_edges'],
 'identity_equations'=>(int)$readiness['identity_equations'],
 'model_structure_equations'=>(int)$readiness['model_structure_equations'],
 'end_to_end_structure_ready'=>(int)$readiness['end_to_end_structure_ready'],
 'numerical_patient_execution_ready'=>(int)$readiness['numerical_patient_execution_ready'],
 'patient_rows_read'=>0,
 'patient_rows_modified'=>0
];
$out['ready']=$out['nodes']===16&&$out['edges']===16&&$out['computable_edges']===11&&
 $out['hypothesis_edges']===2&&$out['identity_equations']===2&&
 $out['model_structure_equations']===6&&$out['end_to_end_structure_ready']===1;
echo json_encode($out,JSON_PRETTY_PRINT|JSON_UNESCAPED_SLASHES),PHP_EOL;
if(!$out['ready']) exit(4);
