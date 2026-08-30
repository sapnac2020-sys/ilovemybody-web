<?php
declare(strict_types=1);
header('Content-Type: application/json; charset=utf-8');
header('Cache-Control: no-store');
header('X-Robots-Tag: noindex, nofollow, noarchive');
function respond(int $status,array $data):never{http_response_code($status);echo json_encode($data,JSON_UNESCAPED_SLASHES|JSON_UNESCAPED_UNICODE);exit;}
try{
 $loinc=trim((string)($_GET['loinc']??''));
 if(!preg_match('/^\d{1,7}-\d$/',$loinc)) respond(422,['ok'=>false,'error'=>'A valid LOINC code is required.']);
 $configPath=dirname(__DIR__,2).'/ilmb-config.php';
 if(!is_file($configPath)) throw new RuntimeException('Private configuration unavailable.');
 $c=require $configPath;if(isset($c['database'])&&is_array($c['database']))$c=$c['database'];
 $host=$c['host']??null;$port=(int)($c['port']??3306);$db=$c['db']??($c['name']??null);$user=$c['user']??null;$pass=$c['pass']??($c['password']??null);
 $pdo=new PDO("mysql:host={$host};port={$port};dbname={$db};charset=utf8mb4",$user,$pass,[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION,PDO::ATTR_DEFAULT_FETCH_MODE=>PDO::FETCH_ASSOC]);
 $q=$pdo->prepare("SELECT * FROM v_ilmb_loinc_chebi_compute WHERE loinc_num=? ORDER BY chebi_id LIMIT 100");$q->execute([$loinc]);$maps=$q->fetchAll();
 $q=$pdo->prepare("SELECT JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$.LONG_COMMON_NAME')) loinc_name,JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$.COMPONENT')) component,JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$.PROPERTY')) property_name,JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$.TIME_ASPCT')) time_aspect,JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$.SYSTEM')) specimen_system,JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$.SCALE_TYP')) scale_type FROM ilmb_canonical_record WHERE system_id='SYS-001' AND sheet_name='LOINC_Master' AND active=1 AND source_key=? LIMIT 1");$q->execute([$loinc]);$identity=$q->fetch();
 if(!$identity) respond(404,['ok'=>false,'error'=>'LOINC code is not present in the promoted canonical release.']);
 $q=$pdo->prepare("SELECT loinc_num,canonical_specimen,property_code,scale_type,example_ucum_unit,unit_semantics,interval_semantics,source_system,source_locator,source_batch_id,verified_at FROM ilb_lab_measurement_contract WHERE loinc_num=? AND active=1 LIMIT 1");$q->execute([$loinc]);$contract=$q->fetch();
 if(!$contract) respond(409,['ok'=>false,'error'=>'The LOINC measurement contract has not been activated.']);
 $rule=$pdo->query("SELECT rule_key,version_label,rule_name,expression_text,input_contract,output_contract,source_boundary FROM ilb_lab_correlation_rule WHERE rule_key='lab_reference_position' AND status='active' ORDER BY version_label DESC LIMIT 1")->fetch();
 $provided=array_key_exists('value',$_GET)||array_key_exists('low',$_GET)||array_key_exists('high',$_GET)||array_key_exists('unit',$_GET)||array_key_exists('reference_unit',$_GET)||array_key_exists('specimen',$_GET);
 $calc=['status'=>'not_requested','classification'=>null,'reason'=>'Supply specimen, value, low, high, unit and reference_unit to run the governed comparison.'];
 $specimenGate=['status'=>'not_checked','reported'=>null,'canonical'=>$contract['canonical_specimen']];
 $unitGate=['status'=>'not_checked','result_unit'=>null,'reference_unit'=>null,'loinc_example_unit'=>$contract['example_ucum_unit']];
 if($provided){
  $raw=['value'=>$_GET['value']??null,'low'=>$_GET['low']??null,'high'=>$_GET['high']??null];
  $specimen=trim((string)($_GET['specimen']??''));
  $unit=(string)($_GET['unit']??'');$referenceUnit=(string)($_GET['reference_unit']??'');
  $specimenGate=['status'=>($specimen!==''&&$specimen===$contract['canonical_specimen'])?'passed':'blocked','reported'=>$specimen,'canonical'=>$contract['canonical_specimen']];
  $unitGate=['status'=>($unit!==''&&$referenceUnit!==''&&$unit===$referenceUnit)?'passed':'blocked','result_unit'=>$unit,'reference_unit'=>$referenceUnit,'loinc_example_unit'=>$contract['example_ucum_unit'],'example_only'=>true];
  if($specimenGate['status']!=='passed') $calc=['status'=>'blocked','classification'=>null,'reason'=>'Reported specimen must exactly match the canonical LOINC specimen code.'];
  elseif(!is_numeric($raw['value'])||!is_numeric($raw['low'])||!is_numeric($raw['high'])) $calc=['status'=>'blocked','classification'=>null,'reason'=>'Value and interval boundaries must all be numeric.'];
  elseif($unitGate['status']!=='passed') $calc=['status'=>'blocked','classification'=>null,'reason'=>'Result and reference units must be present and exactly identical; no implicit conversion was used.'];
  elseif((float)$raw['low']>(float)$raw['high']) $calc=['status'=>'blocked','classification'=>null,'reason'=>'The lower boundary exceeds the upper boundary.'];
  else{$v=(float)$raw['value'];$lo=(float)$raw['low'];$hi=(float)$raw['high'];$class=$v<$lo?'below':($v>$hi?'above':'within');$calc=['status'=>'calculated','classification'=>$class,'reason'=>'Compared only with the explicitly supplied laboratory interval after specimen and unit gates passed.','inputs'=>['specimen'=>$specimen,'value'=>$v,'low'=>$lo,'high'=>$hi,'unit'=>$unit]];}
 }
 $chain=[
  ['layer'=>'measurement_identity','system'=>'LOINC','id'=>$loinc,'label'=>$identity['loinc_name']],
  ['layer'=>'measurement_contract','contract'=>$contract,'specimen_gate'=>$specimenGate,'unit_gate'=>$unitGate],
  ['layer'=>'approved_crosswalk','gate'=>'EXACT + APPROVED + both endpoints resolved','eligible_mappings'=>count($maps)],
  ['layer'=>'chemical_identity','system'=>'ChEBI','entities'=>array_map(fn($m)=>['id'=>$m['chebi_id'],'name'=>$m['chebi_name'],'predicate'=>$m['predicate'],'evidence_source'=>$m['evidence_source'],'evidence_version'=>$m['evidence_version'],'evidence_locator'=>$m['evidence_locator'],'confidence'=>$m['confidence'],'loinc_release'=>$m['loinc_release'],'chebi_release'=>$m['chebi_release']],$maps)],
  ['layer'=>'reference_interval_gate','rule'=>'Interval boundaries must be explicitly supplied from the reporting laboratory or another governed source; no universal range is inferred.'],
  ['layer'=>'calculation','rule'=>$rule,'result'=>$calc]
 ];
 respond(200,['ok'=>true,'mode'=>'non_patient_golden_proof','patient_data_read'=>false,'patient_data_written'=>false,'loinc'=>array_merge(['code'=>$loinc],$identity),'chain'=>$chain,'calculation'=>$calc,'limitations'=>['No diagnosis or treatment recommendation.','LOINC example UCUM units are descriptive metadata, not the only valid units.','A supplied interval is not assumed universal.','Only computation-eligible exact approved mappings are returned.','No patient record is read or stored by this endpoint.']]);
}catch(Throwable $e){respond(500,['ok'=>false,'error'=>'The governed correlation service is temporarily unavailable.']);}
