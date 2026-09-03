<?php
declare(strict_types=1);
header('Content-Type: application/json; charset=utf-8');
header('Cache-Control: no-store');
function out(int $status,array $payload):never{http_response_code($status);echo json_encode($payload,JSON_UNESCAPED_SLASHES|JSON_UNESCAPED_UNICODE);exit;}
try{
 $c=require dirname(__DIR__,2).'/ilmb-config.php';
 if(isset($c['database'])&&is_array($c['database']))$c=$c['database'];
 $pdo=new PDO("mysql:host=".$c['host'].";port=".($c['port']??3306).";dbname=".($c['db']??$c['name']).";charset=utf8mb4",$c['user'],$c['pass']??$c['password'],[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION,PDO::ATTR_DEFAULT_FETCH_MODE=>PDO::FETCH_ASSOC]);
 $conditions=$pdo->query("SELECT * FROM v_ilmb_psoriasis_pathway ORDER BY condition_key")->fetchAll();
 $assessments=$pdo->query("SELECT assessment_key,assessment_name,assessment_role,captures_text,execution_gate,evidence_key FROM ilb_psoriasis_assessment WHERE status='active' ORDER BY assessment_key")->fetchAll();
 $classes=$pdo->query("SELECT treatment_class_key,treatment_class_name,scope_text,clinician_gate,evidence_key FROM ilb_psoriasis_treatment_class WHERE status='active' ORDER BY treatment_class_key")->fetchAll();
 $medicines=$pdo->query("SELECT * FROM v_ilmb_psoriasis_medicine_proof ORDER BY medicine_key")->fetchAll();
 $gates=$pdo->query("SELECT gate_key,medicine_key,gate_name,gate_stage,required_action,blocks_automated_advice,evidence_key FROM ilb_psoriasis_safety_gate WHERE status='active' ORDER BY gate_stage,gate_key")->fetchAll();
 out(200,[
  'ok'=>true,
  'mode'=>'governed_non_patient_psoriasis_knowledge',
  'patient_data_read'=>false,
  'patient_data_written'=>false,
  'automated_diagnosis'=>false,
  'automated_prescribing'=>false,
  'conditions'=>$conditions,
  'assessments'=>$assessments,
  'treatment_classes'=>$classes,
  'medicines'=>$medicines,
  'safety_gates'=>$gates,
  'boundary'=>'Reference and routing knowledge only. Diagnosis and treatment decisions require qualified clinical care.'
 ]);
}catch(Throwable $e){out(500,['ok'=>false,'error'=>'Psoriasis pathway unavailable']);}
