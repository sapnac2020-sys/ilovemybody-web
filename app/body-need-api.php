<?php
declare(strict_types=1);
require __DIR__ . '/_guard.php';
require __DIR__ . '/lib.php';
start_private_session();
if (empty($_SESSION['ilb_reviewer'])) json_out(['ok'=>false,'error'=>'Reviewer sign-in required.'],401);

$view=(string)($_GET['view']??'summary');
$pdo=db();
function allq(PDO $pdo,string $sql):array{return $pdo->query($sql)->fetchAll();}
function oneq(PDO $pdo,string $sql):int{return (int)$pdo->query($sql)->fetchColumn();}

try {
 if($view==='summary'){
   $root=dirname(__DIR__,2).'/ilmb-data-exchange';
   $manifest=$root.'/manifest.json';
   $mirror=is_file($manifest)?json_decode((string)file_get_contents($manifest),true):null;
   json_out(['ok'=>true,'summary'=>[
     'parameters'=>oneq($pdo,'SELECT COUNT(*) FROM ilmb_parameter_master'),
     'identifiers'=>oneq($pdo,'SELECT COUNT(*) FROM ilmb_parameter_identifier'),
     'formulas'=>oneq($pdo,'SELECT COUNT(*) FROM ilmb_formula_master'),
     'formula_inputs'=>oneq($pdo,'SELECT COUNT(*) FROM ilmb_formula_input'),
     'parameter_duplicates'=>oneq($pdo,"SELECT COUNT(*) FROM ilmb_parameter_duplicate_candidate WHERE disposition='OPEN'"),
     'formula_duplicates'=>oneq($pdo,"SELECT COUNT(*) FROM ilmb_formula_duplicate_candidate WHERE disposition='OPEN'"),
     'computed_runs'=>oneq($pdo,"SELECT COUNT(*) FROM ilmb_body_need_run WHERE execution_status='COMPUTED'"),
     'blocked_runs'=>oneq($pdo,"SELECT COUNT(*) FROM ilmb_body_need_run WHERE execution_status LIKE 'BLOCKED_%'"),
     'mirror'=>$mirror,
   ]]);
 }
 if($view==='parameters') json_out(['ok'=>true,'parameters'=>allq($pdo,"SELECT * FROM vw_ilmb_common_parameter_master ORDER BY parameter_domain,canonical_name LIMIT 5000")]);
 if($view==='formulas') json_out(['ok'=>true,'formulas'=>allq($pdo,"SELECT f.*,p.canonical_name output_parameter_name FROM ilmb_formula_master f LEFT JOIN ilmb_parameter_master p ON p.parameter_id=f.output_parameter_id ORDER BY f.formula_domain,f.formula_name LIMIT 5000")]);
 if($view==='inputs') json_out(['ok'=>true,'inputs'=>allq($pdo,"SELECT i.*,f.formula_key,p.parameter_key,p.canonical_name FROM ilmb_formula_input i JOIN ilmb_formula_master f ON f.formula_id=i.formula_id JOIN ilmb_parameter_master p ON p.parameter_id=i.parameter_id ORDER BY f.formula_key,i.ordinal,i.symbol_name LIMIT 10000")]);
 if($view==='duplicates') json_out(['ok'=>true,
   'parameter_duplicates'=>allq($pdo,"SELECT d.*,l.parameter_key left_key,r.parameter_key right_key FROM ilmb_parameter_duplicate_candidate d JOIN ilmb_parameter_master l ON l.parameter_id=d.left_parameter_id JOIN ilmb_parameter_master r ON r.parameter_id=d.right_parameter_id ORDER BY d.created_at DESC LIMIT 1000"),
   'formula_duplicates'=>allq($pdo,"SELECT d.*,l.formula_key left_key,r.formula_key right_key FROM ilmb_formula_duplicate_candidate d JOIN ilmb_formula_master l ON l.formula_id=d.left_formula_id JOIN ilmb_formula_master r ON r.formula_id=d.right_formula_id ORDER BY d.created_at DESC LIMIT 1000")
 ]);
 if($view==='identifier-gaps') json_out(['ok'=>true,'gaps'=>allq($pdo,"SELECT p.parameter_id,p.parameter_key,p.canonical_name,p.parameter_domain,p.canonical_ucum_unit, SUM(i.identifier_system='LOINC' AND i.verification_status='APPROVED') approved_loinc, SUM(i.identifier_system='CHEBI' AND i.verification_status='APPROVED') approved_chebi FROM ilmb_parameter_master p LEFT JOIN ilmb_parameter_identifier i ON i.parameter_id=p.parameter_id WHERE p.status<>'DEPRECATED' GROUP BY p.parameter_id ORDER BY p.parameter_domain,p.canonical_name")]);
 json_out(['ok'=>false,'error'=>'Unknown view.'],400);
} catch(Throwable $e){ json_out(['ok'=>false,'error'=>'Console data unavailable.'],500); }
