<?php
declare(strict_types=1);
require __DIR__ . '/../app/lib.php';
header('Content-Type: application/json; charset=utf-8');
header('Cache-Control: public, max-age=300');
$view=(string)($_GET['view']??'summary');
$pdo=db();
try{
 if($view==='summary'){
   echo json_encode(['ok'=>true,'summary'=>[
     'parameters'=>(int)$pdo->query("SELECT COUNT(*) FROM ilmb_parameter_master WHERE status='ACTIVE'")->fetchColumn(),
     'verified_formulas'=>(int)$pdo->query("SELECT COUNT(*) FROM ilmb_formula_master WHERE formula_status IN ('VERIFIED','APPROVED')")->fetchColumn(),
     'formula_inputs'=>(int)$pdo->query("SELECT COUNT(*) FROM ilmb_formula_input")->fetchColumn(),
     'approved_identifiers'=>(int)$pdo->query("SELECT COUNT(*) FROM ilmb_parameter_identifier WHERE verification_status='APPROVED'")->fetchColumn(),
     'method'=>'Measured inputs → canonical parameters → governed identifiers/units → verified formulas → derived need/state.',
     'governance'=>'Draft, unverified, patient-private and blocked calculations are never published.',
   ]],JSON_UNESCAPED_SLASHES|JSON_UNESCAPED_UNICODE);exit;
 }
 if($view==='formulas'){
   $q=$pdo->query("SELECT formula_key,formula_name,formula_domain,expression_text,purpose,evidence_class,source_citation,formula_status,unit_checked FROM ilmb_formula_master WHERE formula_status IN ('VERIFIED','APPROVED') ORDER BY formula_domain,formula_name LIMIT 1000");
   echo json_encode(['ok'=>true,'formulas'=>$q->fetchAll()],JSON_UNESCAPED_SLASHES|JSON_UNESCAPED_UNICODE);exit;
 }
 if($view==='parameters'){
   $q=$pdo->query("SELECT parameter_key,canonical_name,parameter_domain,value_kind,canonical_ucum_unit,specimen_or_context,body_scope FROM ilmb_parameter_master WHERE status='ACTIVE' ORDER BY parameter_domain,canonical_name LIMIT 2000");
   echo json_encode(['ok'=>true,'parameters'=>$q->fetchAll()],JSON_UNESCAPED_SLASHES|JSON_UNESCAPED_UNICODE);exit;
 }
 http_response_code(400);echo json_encode(['ok'=>false,'error'=>'Unknown view.']);
}catch(Throwable $e){http_response_code(503);echo json_encode(['ok'=>false,'error'=>'Public data temporarily unavailable.']);}
