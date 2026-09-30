<?php
declare(strict_types=1);
require __DIR__ . '/_guard.php';
require __DIR__ . '/lib.php';
start_private_session();
if(empty($_SESSION['ilb_login_id'])){header('Location: /app/access.php');exit;}
$case=require_case();$subject=(string)$case['subject_key'];
header('Cache-Control: no-store');
function ehr_h(mixed $s): string {return htmlspecialchars((string)$s,ENT_QUOTES|ENT_SUBSTITUTE,'UTF-8');}
$_SESSION['ehr_csrf']??=bin2hex(random_bytes(32));
$message='';$error='';
try {
 if($_SERVER['REQUEST_METHOD']==='POST'){
  if(!hash_equals($_SESSION['ehr_csrf'],(string)($_POST['csrf']??''))){http_response_code(403);exit('Request expired. Reload the page.');}
  $practice=(string)($_POST['practice']??'');
  $st=db()->prepare("SELECT practice_code FROM ilb_ehr_practice WHERE practice_code=? AND publication_status='PUBLISHED'");$st->execute([$practice]);
  if(!$st->fetch())throw new InvalidArgumentException('Choose a published practice.');
  $mode=(string)($_POST['mode']??'');
  if(!in_array($mode,['PROXIMITY','TOUCH','DISTANCE','SELF_PRACTICE'],true))throw new InvalidArgumentException('Choose a delivery mode.');
  $date=(string)($_POST['started_at']??'');
  $start=DateTimeImmutable::createFromFormat('!Y-m-d\\TH:i',$date);
  if(!$start||$start->format('Y-m-d\\TH:i')!==$date||$start>new DateTimeImmutable())throw new InvalidArgumentException('Enter the actual session start time, not a future date.');
  $duration=filter_var($_POST['duration']??'',FILTER_VALIDATE_INT);
  if($duration===false||$duration<1||$duration>1440)throw new InvalidArgumentException('Duration must be 1 to 1440 minutes.');
  $end=$start->modify('+'.$duration.' minutes');
  if($end>new DateTimeImmutable())throw new InvalidArgumentException('A completed session cannot end in the future.');
  $result=trim((string)($_POST['result_id']??''));
  $timing=(string)($_POST['timing']??'');
  if($result!==''&&(!ctype_digit($result)||!in_array($timing,['BASELINE','PRE_SESSION','POST_SESSION','FOLLOW_UP'],true)))throw new InvalidArgumentException('Choose a result and timing.');
  $provider=text_or_null($_POST['provider']??'',128);
  db()->beginTransaction();
  if($result!==''){
   $st=db()->prepare("SELECT result_id FROM v_ilb_subject_test_result_visible WHERE result_id=? AND CONVERT(subject_key USING utf8mb4) COLLATE utf8mb4_bin=CONVERT(? USING utf8mb4) COLLATE utf8mb4_bin");$st->execute([$result,$subject]);
   if(!$st->fetch())throw new InvalidArgumentException('That result is not available in your records.');
  }
  $st=db()->prepare("INSERT INTO ilb_ehr_session(session_key,practice_code,subject_key,started_at,ended_at,delivery_mode,provider_key,status) VALUES(?,?,?,?,?,?,?,'COMPLETED')");
  $st->execute([bin2hex(random_bytes(16)),$practice,$subject,$start->format('Y-m-d H:i:s'),$end->format('Y-m-d H:i:s'),$mode,$provider]);
  $id=db()->lastInsertId();
  if($result!==''){
   $st=db()->prepare("INSERT INTO ilb_ehr_session_result_link(session_id,result_id,timing_role,linkage_reason,linked_by) VALUES(?,?,?,?,?)");
   $st->execute([$id,$result,$timing,'Participant selected this report for session follow-up',(string)$case['login_id']]);
  }
  db()->commit();header('Location: /app/energy-healing-record.php?saved=1',true,303);exit;
 }
 $practices=db()->query("SELECT practice_code,practice_name FROM ilb_ehr_practice WHERE publication_status='PUBLISHED' ORDER BY practice_name")->fetchAll();
 $st=db()->prepare("SELECT result_id,observed_on,reported_test_name,identity_status FROM v_ilb_subject_test_result_visible WHERE CONVERT(subject_key USING utf8mb4) COLLATE utf8mb4_bin=CONVERT(? USING utf8mb4) COLLATE utf8mb4_bin ORDER BY observed_on DESC LIMIT 100");$st->execute([$subject]);$results=$st->fetchAll();
 $st=db()->prepare("SELECT s.started_at,s.ended_at,s.delivery_mode,p.practice_name FROM ilb_ehr_session s JOIN ilb_ehr_practice p ON p.practice_code=s.practice_code WHERE CONVERT(s.subject_key USING utf8mb4) COLLATE utf8mb4_bin=CONVERT(? USING utf8mb4) COLLATE utf8mb4_bin ORDER BY s.started_at DESC LIMIT 50");$st->execute([$subject]);$sessions=$st->fetchAll();
} catch(InvalidArgumentException $e){if(db()->inTransaction())db()->rollBack();$error=$e->getMessage();$practices=[];$results=[];$sessions=[];}
catch(Throwable $e){if(db()->inTransaction())db()->rollBack();http_response_code(503);exit('Session logging is temporarily unavailable.');}
?>
<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>My energy-healing sessions</title><style>body{font:16px/1.5 system-ui;background:#102321;color:#edf5ef;margin:0}main{max-width:680px;margin:auto;padding:24px}a{color:#b8e6c4}label{display:block;margin-top:16px}input,select,button{box-sizing:border-box;font:inherit;padding:12px;width:100%;border-radius:8px}button{margin-top:20px;background:#b8e6c4}li{margin:12px 0}.error{color:#ffd1c6}</style></head><body><main>
<a href="/app/energy-healing.php">Research department</a><h1>My energy-healing sessions</h1>
<p>Record what happened and optionally link one of your existing reports. A linked report keeps its original values. Timing is your recorded description; a date-only report cannot establish within-day order.</p>
<?php if(isset($_GET['saved'])):?><p role="status">Session saved.</p><?php endif;?>
<?php if($error):?><p class="error" role="alert"><?=ehr_h($error)?></p><a href="/app/energy-healing-record.php">Reload the form</a><?php else:?>
<form method="post"><input type="hidden" name="csrf" value="<?=ehr_h($_SESSION['ehr_csrf'])?>">
<label>Practice<select name="practice" required><?php foreach($practices as $p):?><option value="<?=ehr_h($p['practice_code'])?>"><?=ehr_h($p['practice_name'])?></option><?php endforeach;?></select></label>
<label>Started at (<?=ehr_h(date_default_timezone_get())?>)<input type="datetime-local" name="started_at" required></label>
<label>Duration in minutes<input type="number" name="duration" min="1" max="1440" required></label>
<label>Delivery mode<select name="mode"><option value="PROXIMITY">Nearby, no touch</option><option value="TOUCH">Touch</option><option value="DISTANCE">Distance</option><option value="SELF_PRACTICE">Self practice</option></select></label>
<label>Practitioner reference (optional)<input name="provider" maxlength="128"></label>
<label>Report to link (optional)<select name="result_id"><option value="">No report</option><?php foreach($results as $r):?><option value="<?=ehr_h($r['result_id'])?>"><?=ehr_h($r['observed_on'].' · '.$r['reported_test_name'].' · '.$r['identity_status'])?></option><?php endforeach;?></select></label>
<label>Report timing<select name="timing"><option value="BASELINE">Baseline</option><option value="PRE_SESSION">Before session</option><option value="POST_SESSION">After session</option><option value="FOLLOW_UP">Follow-up</option></select></label>
<button>Save completed session</button></form><?php endif;?>
<h2>Recent sessions</h2><ul><?php foreach($sessions as $s):?><li><?=ehr_h($s['started_at'].' · '.$s['practice_name'].' · '.$s['delivery_mode'])?></li><?php endforeach;?></ul><p><a href="/app/test-results.php">My original test results</a></p></main></body></html>
