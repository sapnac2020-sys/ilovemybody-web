<?php
declare(strict_types=1);header('Content-Type: application/json; charset=utf-8');header('Cache-Control: no-store');
function out(int $s,array $x):never{http_response_code($s);echo json_encode($x,JSON_UNESCAPED_SLASHES|JSON_UNESCAPED_UNICODE);exit;}
try{
 $key=strtolower(trim((string)($_GET['drug']??'metformin')));
 $c=require dirname(__DIR__,2).'/ilmb-config.php';if(isset($c['database'])&&is_array($c['database']))$c=$c['database'];
 $p=new PDO("mysql:host=".$c['host'].";port=".($c['port']??3306).";dbname=".($c['db']??$c['name']).";charset=utf8mb4",$c['user'],$c['pass']??$c['password'],[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION,PDO::ATTR_DEFAULT_FETCH_MODE=>PDO::FETCH_ASSOC]);
 $q=$p->prepare("SELECT * FROM v_ilmb_medicine_identity_proof WHERE drug_key=? LIMIT 1");$q->execute([$key]);$r=$q->fetch();
 if($r)out(200,['ok'=>true,'mode'=>'non_patient_medicine_identity_proof','patient_data_read'=>false,'patient_data_written'=>false,'drug'=>['system'=>'ILMB','id'=>$r['drug_key'],'name'=>$r['generic_name'],'class'=>$r['drug_class']],'rxnorm'=>['status'=>$r['rxnorm_status'],'id'=>$r['rxnorm_id'],'label'=>$r['rxnorm_label'],'url'=>$r['rxnorm_url'],'gate'=>'EXACT + APPROVED existing identifier only'],'mechanism'=>['status'=>$r['mechanism_description']===null?'not_available':'descriptive_record_available','description'=>$r['mechanism_description'],'warrant'=>$r['mechanism_warrant'],'computation_eligible'=>false],'nlem_link'=>['status'=>'blocked_missing_authoritative_crosswalk'],'chebi_link'=>['status'=>'blocked_missing_authoritative_crosswalk'],'limitations'=>['No NLEM, RxNorm or ChEBI mapping was inferred from a similar name.','Mechanism text is descriptive and does not execute a patient calculation.','Draft illness, interaction and adverse-event examples are excluded.']]);
 $q=$p->prepare("SELECT * FROM v_ilmb_psoriasis_medicine_proof WHERE medicine_key=? OR LOWER(generic_name)=? OR LOWER(brand_name)=? LIMIT 1");$q->execute([$key,$key,$key]);$r=$q->fetch();
 if(!$r)out(404,['ok'=>false,'error'=>'Unknown active ILMB drug key.']);
 out(200,[
  'ok'=>true,'mode'=>'governed_psoriasis_medicine_identity_proof','patient_data_read'=>false,'patient_data_written'=>false,
  'drug'=>['system'=>'ILMB','id'=>$r['medicine_key'],'name'=>$r['generic_name'],'brand'=>$r['brand_name'],'strength'=>$r['strength_text'],'form'=>$r['dose_form'],'route'=>$r['route'],'class'=>$r['medicine_class']],
  'rxnorm'=>['status'=>$r['rxnorm_status'],'id'=>$r['rxnorm_ingredient_id'],'url'=>'https://mor.nlm.nih.gov/RxNav/search?searchBy=RXCUI&searchTerm='.$r['rxnorm_ingredient_id'],'gate'=>'Exact ingredient identifier only'],
  'india_brand_status'=>$r['india_brand_status'],
  'mechanism'=>['status'=>'descriptive_record_available','description'=>$r['mechanism_text'],'computation_eligible'=>false],
  'prescribing_gate'=>$r['prescribing_gate'],
  'source'=>['authority'=>$r['source_authority'],'title'=>$r['source_title'],'url'=>$r['source_url']],
  'limitations'=>['The Indian brand-to-product label remains flagged for confirmation against the current approved Indian package insert.','This record cannot diagnose psoriasis or recommend a dose, schedule, start, interruption or discontinuation.']
 ]);
}catch(Throwable $e){out(500,['ok'=>false,'error'=>'Medicine identity service unavailable.']);}
