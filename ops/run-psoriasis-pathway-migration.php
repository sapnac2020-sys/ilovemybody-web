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
$counts=[
 'conditions'=>(int)$pdo->query("SELECT COUNT(*) FROM ilb_psoriasis_condition WHERE status='active'")->fetchColumn(),
 'assessments'=>(int)$pdo->query("SELECT COUNT(*) FROM ilb_psoriasis_assessment WHERE status='active'")->fetchColumn(),
 'treatment_classes'=>(int)$pdo->query("SELECT COUNT(*) FROM ilb_psoriasis_treatment_class WHERE status='active'")->fetchColumn(),
 'medicines'=>(int)$pdo->query("SELECT COUNT(*) FROM ilb_psoriasis_medicine WHERE status='active'")->fetchColumn(),
 'safety_gates'=>(int)$pdo->query("SELECT COUNT(*) FROM ilb_psoriasis_safety_gate WHERE status='active'")->fetchColumn(),
 'evidence_sources'=>(int)$pdo->query("SELECT COUNT(*) FROM ilb_psoriasis_evidence WHERE status='active'")->fetchColumn(),
 'ixekizumab'=>(int)$pdo->query("SELECT COUNT(*) FROM v_ilmb_psoriasis_medicine_proof WHERE medicine_key='ixekizumab' AND rxnorm_ingredient_id='1745099' AND rxnorm_status='exact_approved'")->fetchColumn()
];
$out=$counts+[
 'patient_rows_read'=>0,
 'patient_rows_modified'=>0,
 'automated_prescribing_enabled'=>false,
 'ready'=>$counts['conditions']===6&&$counts['assessments']===5&&$counts['treatment_classes']===5&&$counts['medicines']===1&&$counts['safety_gates']===6&&$counts['evidence_sources']===6&&$counts['ixekizumab']===1
];
echo json_encode($out,JSON_PRETTY_PRINT|JSON_UNESCAPED_SLASHES),PHP_EOL;
if(!$out['ready']) exit(4);
