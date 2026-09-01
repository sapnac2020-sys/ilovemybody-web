<?php
declare(strict_types=1);
require __DIR__.'/_guard.php';
require __DIR__ . '/lib.php';
$pdo=db(); $case=require_case(); $subject=(string)$case['subject_key'];
$action=(string)($_GET['action']??'list');

function result_text(mixed $v,int $max): ?string { $s=trim((string)($v??'')); return $s===''?null:mb_substr($s,0,$max); }
function result_date(mixed $v): ?string { $s=(string)$v; return preg_match('/^\d{4}-\d{2}-\d{2}$/',$s)?$s:null; }

if($action==='list' && $_SERVER['REQUEST_METHOD']==='GET'){
  $q=$pdo->prepare("SELECT result_id,source_document_id,observed_on,reported_test_name,reported_value_text,
    reported_numeric_value,reported_unit,reported_specimen_text,laboratory_name,reported_reference_range_text,
    exact_loinc_num,identity_status,created_at
    FROM v_ilb_subject_test_result_visible WHERE subject_key=? ORDER BY observed_on DESC,result_id DESC");
  $q->execute([$subject]); json_out(['ok'=>true,'results'=>$q->fetchAll()]);
}
if($action==='documents' && $_SERVER['REQUEST_METHOD']==='GET'){
  $q=$pdo->prepare("SELECT document_id,original_filename,document_date FROM ilb_subject_document
    WHERE subject_key=? AND document_type='laboratory_report' ORDER BY document_id DESC");
  $q->execute([$subject]); json_out(['ok'=>true,'documents'=>$q->fetchAll()]);
}
if($action==='save' && $_SERVER['REQUEST_METHOD']==='POST'){
  $d=request_data(); $name=result_text($d['reported_test_name']??null,500);
  $value=result_text($d['reported_value_text']??null,500); $date=result_date($d['observed_on']??null);
  if(!$name || !$value || !$date) json_out(['ok'=>false,'error'=>'Test name, result as written, and report date are required.'],422);
  $documentId=(int)($d['source_document_id']??0);
  if($documentId){
    $q=$pdo->prepare("SELECT 1 FROM ilb_subject_document WHERE document_id=? AND subject_key=? AND document_type='laboratory_report'");
    $q->execute([$documentId,$subject]); if(!$q->fetchColumn()) json_out(['ok'=>false,'error'=>'Choose one of your laboratory reports.'],422);
  }
  $numeric=null; if(is_numeric(str_replace(',','',$value))) $numeric=(float)str_replace(',','',$value);
  $q=$pdo->prepare("INSERT INTO ilb_subject_test_result_ledger
    (subject_key,source_document_id,observed_on,reported_test_name,reported_value_text,reported_numeric_value,
     reported_unit,reported_specimen_text,laboratory_name,reported_reference_range_text,identity_status)
     VALUES (?,?,?,?,?,?,?,?,?,?, 'UNLINKED')");
  $q->execute([$subject,$documentId?:null,$date,$name,$value,$numeric,
    result_text($d['reported_unit']??null,120),result_text($d['reported_specimen_text']??null,255),
    result_text($d['laboratory_name']??null,255),result_text($d['reported_reference_range_text']??null,500)]);
  json_out(['ok'=>true,'result_id'=>(int)$pdo->lastInsertId(),'identity_status'=>'UNLINKED']);
}
json_out(['ok'=>false,'error'=>'Unsupported action.'],405);