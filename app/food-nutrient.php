<?php
declare(strict_types=1);
header('Content-Type: application/json; charset=utf-8');
header('Cache-Control: no-store');
function respond(int $status,array $data):never{http_response_code($status);echo json_encode($data,JSON_UNESCAPED_SLASHES|JSON_UNESCAPED_UNICODE);exit;}
try{
 $food=trim((string)($_GET['food']??''));$nutrient=trim((string)($_GET['nutrient']??''));$portionRaw=$_GET['portion_g']??null;
 if($food===''||$nutrient==='') respond(422,['ok'=>false,'error'=>'Food and nutrient identifiers are required.']);
 $configPath=dirname(__DIR__,2).'/ilmb-config.php';$c=require $configPath;if(isset($c['database'])&&is_array($c['database']))$c=$c['database'];
 $pdo=new PDO("mysql:host=".$c['host'].";port=".($c['port']??3306).";dbname=".($c['db']??$c['name']).";charset=utf8mb4",$c['user'],$c['pass']??$c['password'],[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION,PDO::ATTR_DEFAULT_FETCH_MODE=>PDO::FETCH_ASSOC]);
 $q=$pdo->prepare("SELECT * FROM v_ilmb_food_nutrient_compute WHERE food_id=? AND nutrient_id=? LIMIT 1");$q->execute([$food,$nutrient]);$row=$q->fetch();
 if(!$row) respond(404,['ok'=>false,'error'=>'No exact approved positive IFCT composition relation exists for these identifiers.']);
 $calc=['status'=>'not_requested','amount'=>null,'unit'=>$row['amount_unit']];
 if($portionRaw!==null){
  if(!is_numeric($portionRaw)||(float)$portionRaw<0) $calc=['status'=>'blocked','amount'=>null,'unit'=>$row['amount_unit'],'reason'=>'Portion must be a non-negative number of grams.'];
  elseif($row['basis_unit']!=='g') $calc=['status'=>'blocked','amount'=>null,'unit'=>$row['amount_unit'],'reason'=>'The source basis is not grams; no implicit conversion was used.'];
  else{$portion=(float)$portionRaw;$amount=(float)$row['amount']*$portion/(float)$row['basis_quantity'];$calc=['status'=>'calculated','formula'=>'source_amount × portion_g ÷ source_basis_quantity','amount'=>$amount,'unit'=>$row['amount_unit'],'inputs'=>['source_amount'=>(float)$row['amount'],'source_basis_quantity'=>(float)$row['basis_quantity'],'source_basis_unit'=>$row['basis_unit'],'portion_g'=>$portion]];}
 }
 $q=$pdo->prepare("SELECT COUNT(*) FROM ilmb_entity_crosswalk WHERE ((source_system='CHEBI' AND target_system='IFCT' AND target_id=?) OR (source_system='IFCT' AND source_id=? AND target_system='CHEBI')) AND match_type='EXACT' AND status='APPROVED' AND computation_eligible=1");$q->execute([$nutrient,$nutrient]);$chebi=(int)$q->fetchColumn();
 respond(200,['ok'=>true,'mode'=>'non_patient_food_nutrient_proof','patient_data_read'=>false,'patient_data_written'=>false,'identity'=>['food'=>['system'=>'IFCT','id'=>$row['food_id'],'name'=>$row['food_name']],'nutrient'=>['system'=>'IFCT','id'=>$row['nutrient_id'],'name'=>$row['nutrient_name']]],'composition'=>['amount'=>(float)$row['amount'],'unit'=>$row['amount_unit'],'basis_quantity'=>(float)$row['basis_quantity'],'basis_unit'=>$row['basis_unit'],'source_record_key'=>$row['source_record_key'],'source_batch_id'=>$row['source_batch_id'],'row_hash'=>$row['row_hash'],'mapping_id'=>$row['mapping_id'],'gate'=>'EXACT + APPROVED + resolved endpoints'],'calculation'=>$calc,'chebi_link'=>['status'=>$chebi>0?'available':'blocked_missing_authoritative_mapping','eligible_links'=>$chebi],'limitations'=>['No name-based ChEBI mapping was inferred.','Zero-value composition rows remain stored but do not produce CONTAINS relations.','This is food composition arithmetic, not a diagnosis or treatment recommendation.']]);
}catch(Throwable $e){respond(500,['ok'=>false,'error'=>'The governed food composition service is temporarily unavailable.']);}
