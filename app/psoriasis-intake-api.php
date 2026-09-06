<?php
declare(strict_types=1);
require __DIR__.'/_guard.php';
require __DIR__.'/lib.php';
$pdo=db(); $case=require_case(); $subject=(string)$case['subject_key'];
$model='PSO_COP_LIFESTYLE_V4'; $action=(string)($_GET['action']??'bootstrap');

function episode_key(mixed $v): string { $s=trim((string)$v); if(!preg_match('/^PSO-[A-Za-z0-9_-]{1,80}$/',$s)) json_out(['ok'=>false,'error'=>'Invalid episode.'],422); return $s; }
function date_time(mixed $v): string { $s=trim((string)$v); $t=strtotime($s); if($s===''||$t===false) json_out(['ok'=>false,'error'=>'A valid observation time is required.'],422); return date('Y-m-d H:i:s',$t); }

if($action==='bootstrap' && $_SERVER['REQUEST_METHOD']==='GET'){
  $defs=$pdo->prepare("SELECT input_id,input_code,category_code,label,value_domain,canonical_unit_code,time_basis,body_site_required,release_required FROM ilb_model_input_definition WHERE model_code=? ORDER BY category_code,input_code");
  $defs->execute([$model]);
  $gates=$pdo->prepare("SELECT gate_code,gate_order,gate_status,reason_text FROM ilb_model_release_gate WHERE model_code=? ORDER BY gate_order"); $gates->execute([$model]);
  json_out(['ok'=>true,'case'=>['label'=>$case['frontend_label'],'public_case_key'=>$case['public_case_key']],'definitions'=>$defs->fetchAll(),'gates'=>$gates->fetchAll()]);
}

if($action==='episode' && $_SERVER['REQUEST_METHOD']==='GET'){
  $episode=episode_key($_GET['episode_key']??'');
  $q=$pdo->prepare("SELECT o.observation_id,d.input_code,d.label,o.observed_at,o.value_number,o.value_text,o.unit_code,o.body_site,o.method_code,o.quality_status FROM ilb_subject_observation o JOIN ilb_model_input_definition d ON d.input_id=o.input_id WHERE o.subject_key=? AND o.episode_key=? ORDER BY d.category_code,d.input_code,o.observed_at DESC");
  $q->execute([$subject,$episode]); json_out(['ok'=>true,'observations'=>$q->fetchAll()]);
}

if($action==='save' && $_SERVER['REQUEST_METHOD']==='POST'){
  $d=request_data(); $episode=episode_key($d['episode_key']??''); $observed=date_time($d['observed_at']??''); $rows=$d['observations']??null;
  if(!is_array($rows)||count($rows)>80) json_out(['ok'=>false,'error'=>'Observations must be an array of at most 80 fields.'],422);
  $get=$pdo->prepare("SELECT input_id,value_domain,canonical_unit_code,body_site_required FROM ilb_model_input_definition WHERE model_code=? AND input_code=?");
  $put=$pdo->prepare("INSERT INTO ilb_subject_observation(observation_id,subject_key,episode_key,input_id,observed_at,value_number,value_text,unit_code,body_site,method_code,quality_status,entered_by) VALUES(?,?,?,?,?,?,?,?,?,?, 'UNVERIFIED',?) ON DUPLICATE KEY UPDATE value_number=VALUES(value_number),value_text=VALUES(value_text),unit_code=VALUES(unit_code),body_site=VALUES(body_site),method_code=VALUES(method_code),quality_status='UNVERIFIED',entered_by=VALUES(entered_by)");
  $saved=0; $pdo->beginTransaction();
  try { foreach($rows as $row){ if(!is_array($row))continue; $code=trim((string)($row['input_code']??'')); $raw=$row['value']??null; if($code===''||$raw===''||$raw===null)continue;
      $get->execute([$model,$code]); $def=$get->fetch(); if(!$def)throw new RuntimeException('Unknown input: '.$code);
      $site=text_or_null($row['body_site']??null,255); if((int)$def['body_site_required']===1 && !$site)throw new RuntimeException($code.' requires a body site.');
      $number=null;$text=null; if(in_array($def['value_domain'],['NUMBER','INTEGER'],true)){if(!is_numeric($raw))throw new RuntimeException($code.' must be numeric.');$number=(float)$raw;}else{$text=text_or_null($raw,4000);}
      $id=hash('sha256',implode('|',[$subject,$episode,$code,$observed]));
      $put->execute([$id,$subject,$episode,$def['input_id'],$observed,$number,$text,$def['canonical_unit_code'],$site,text_or_null($row['method_code']??null,160),(string)$case['login_id']]); $saved++;
    } $pdo->commit();
  } catch(Throwable $e){$pdo->rollBack();json_out(['ok'=>false,'error'=>$e->getMessage()],422);}
  json_out(['ok'=>true,'saved'=>$saved,'episode_key'=>$episode,'quality_status'=>'UNVERIFIED']);
}

if($action==='save_medicine' && $_SERVER['REQUEST_METHOD']==='POST'){
  $d=request_data();$episode=episode_key($d['episode_key']??'');$name=text_or_null($d['medicine_name']??null,512);if(!$name)json_out(['ok'=>false,'error'=>'Medicine name is required.'],422);
  $id=hash('sha256',implode('|',[$subject,$episode,$name,(string)($d['start_at']??'')]));
  $q=$pdo->prepare("INSERT INTO ilb_medicine_exposure(exposure_id,subject_key,episode_key,medicine_name_as_recorded,dose_value,dose_unit,route_code,start_at,end_at,schedule_text,prescribed_flag,verification_status) VALUES(?,?,?,?,?,?,?,?,?,?,?,'PENDING') ON DUPLICATE KEY UPDATE dose_value=VALUES(dose_value),dose_unit=VALUES(dose_unit),route_code=VALUES(route_code),end_at=VALUES(end_at),schedule_text=VALUES(schedule_text),prescribed_flag=VALUES(prescribed_flag),verification_status='PENDING'");
  $q->execute([$id,$subject,$episode,$name,nullable_number($d['dose_value']??null),text_or_null($d['dose_unit']??null,64),text_or_null($d['route_code']??null,64),text_or_null($d['start_at']??null,30),text_or_null($d['end_at']??null,30),text_or_null($d['schedule_text']??null,512),!empty($d['prescribed_flag'])?1:0]);
  json_out(['ok'=>true,'exposure_id'=>$id,'verification_status'=>'PENDING']);
}

if($action==='save_adverse_event' && $_SERVER['REQUEST_METHOD']==='POST'){
  $d=request_data();$episode=episode_key($d['episode_key']??'');$label=text_or_null($d['event_label']??null,512);if(!$label)json_out(['ok'=>false,'error'=>'Side-effect or event description is required.'],422);
  $severity=in_array(($d['severity']??''),['MILD','MODERATE','SEVERE','LIFE_THREATENING','UNKNOWN'],true)?$d['severity']:'UNKNOWN';
  $id=hash('sha256',implode('|',[$subject,$episode,$label,(string)($d['onset_at']??'')]));
  $q=$pdo->prepare("INSERT INTO ilb_adverse_event_observation(adverse_event_id,subject_key,episode_key,exposure_id,event_label,onset_at,severity,seriousness_flag,action_taken,outcome_text,attribution,clinician_review_status) VALUES(?,?,?,?,?,?,?,?,?,?,'UNASSESSED','PENDING') ON DUPLICATE KEY UPDATE severity=VALUES(severity),seriousness_flag=VALUES(seriousness_flag),action_taken=VALUES(action_taken),outcome_text=VALUES(outcome_text),clinician_review_status='PENDING'");
  $q->execute([$id,$subject,$episode,text_or_null($d['exposure_id']??null,64),$label,text_or_null($d['onset_at']??null,30),$severity,!empty($d['seriousness_flag'])?1:0,text_or_null($d['action_taken']??null,2000),text_or_null($d['outcome_text']??null,2000)]);
  json_out(['ok'=>true,'adverse_event_id'=>$id,'clinician_review_status'=>'PENDING']);
}
json_out(['ok'=>false,'error'=>'Unsupported action.'],405);
