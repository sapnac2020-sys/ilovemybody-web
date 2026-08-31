<?php
declare(strict_types=1);
require __DIR__ . '/_guard.php';
require __DIR__.'/lib.php';
start_private_session();
$c=cfg()['app']; $error='';
if(isset($_GET['logout'])){unset($_SESSION['ilb_reviewer']);header('Location: admin.php');exit;}
if($_SERVER['REQUEST_METHOD']==='POST' && isset($_POST['reviewer_user'])){
 if((int)($_SESSION['ilb_reviewer_locked_until']??0)>time()){$error='Too many attempts. Please wait 15 minutes.';}else{
 $okUser=hash_equals((string)($c['reviewer_user']??''),trim((string)$_POST['reviewer_user']));
 $okPin=hash_equals((string)($c['reviewer_secret_sha256']??''),hash('sha256',(string)($_POST['reviewer_pin']??'')));
 if($okUser&&$okPin){session_regenerate_id(true);$_SESSION['ilb_reviewer']=true;unset($_SESSION['ilb_reviewer_attempts'],$_SESSION['ilb_reviewer_locked_until']);header('Location: admin.php');exit;}
 $attempts=(int)($_SESSION['ilb_reviewer_attempts']??0)+1;$_SESSION['ilb_reviewer_attempts']=$attempts;if($attempts>=5)$_SESSION['ilb_reviewer_locked_until']=time()+900;
 $error='Username or PIN is incorrect.';}
}
$signed=!empty($_SESSION['ilb_reviewer']);
$reviewCases=[];$selectedCase=null;$subject='';
if($signed){
 $reviewCases=db()->query("SELECT f.public_case_key,f.frontend_label,f.allowed_age_display,f.allowed_sex_display
                             FROM ilb_subject_frontend_alias f WHERE f.status='active' ORDER BY f.frontend_label")->fetchAll();
 $requested=preg_replace('/[^a-zA-Z0-9_-]/','',(string)($_GET['case']??$_SESSION['ilb_review_case']??''));
 foreach($reviewCases as $rc){if(hash_equals($rc['public_case_key'],$requested)){$selectedCase=$rc;break;}}
 if(!$selectedCase && $reviewCases)$selectedCase=$reviewCases[0];
 if($selectedCase){
  $_SESSION['ilb_review_case']=$selectedCase['public_case_key'];
  $resolve=db()->prepare("SELECT subject_key FROM ilb_subject_frontend_alias WHERE public_case_key=? AND status='active'");
  $resolve->execute([$selectedCase['public_case_key']]);$subject=(string)$resolve->fetchColumn();
 }
}
if($signed && ($_GET['action']??'')==='document'){
 if($subject===''){http_response_code(404);exit('Case unavailable.');}
 $id=(int)($_GET['id']??0);$s=db()->prepare("SELECT original_filename,mime_type,storage_ref FROM ilb_subject_document WHERE document_id=? AND subject_key=?");$s->execute([$id,$subject]);$d=$s->fetch();
 if(!$d||!str_starts_with($d['storage_ref'],'private-file:')){http_response_code(404);exit('Document unavailable.');}
 $name=substr($d['storage_ref'],13);if(!preg_match('/^[a-f0-9]{48}\.(pdf|jpg|png|webp|heic|heif)$/',$name))exit('Invalid document.');
 $path=safe_upload_dir().DIRECTORY_SEPARATOR.$name;if(!is_file($path)){http_response_code(404);exit('File unavailable.');}
 header('Content-Type: '.$d['mime_type']);header('Content-Length: '.filesize($path));header('Content-Disposition: inline; filename="'.rawurlencode($d['original_filename']?:'document').'"');header('Cache-Control: private,no-store');readfile($path);exit;
}
$snapshots=$medicines=$documents=[];$counts=[];
if($signed){
 $p=db();
 $q=$p->prepare("SELECT s.snapshot_id,DATE(s.captured_at) entry_date,s.status,s.happiness_score,s.energy_score,s.stress_pressure_score,s.physical_discomfort_score,b.sleep_minutes,b.movement_minutes,(SELECT COUNT(*) FROM ilb_snapshot_food_event f WHERE f.snapshot_id=s.snapshot_id) food_count,(SELECT COUNT(*) FROM ilb_snapshot_safety_flag sf WHERE sf.snapshot_id=s.snapshot_id AND sf.reported_answer IN ('yes','uncertain')) safety_count FROM ilb_human_state_snapshot s LEFT JOIN ilb_snapshot_behaviour b ON b.snapshot_id=s.snapshot_id WHERE s.subject_key=? ORDER BY s.captured_at DESC LIMIT 60");$q->execute([$subject]);$snapshots=$q->fetchAll();
 $q=$p->prepare("SELECT reported_name,strength_text,dose_text,frequency_text,usual_time_text,verification_status FROM ilb_subject_medicine_report WHERE subject_key=? AND status='active' ORDER BY medicine_report_id");$q->execute([$subject]);$medicines=$q->fetchAll();
 $q=$p->prepare("SELECT document_id,document_type,document_date,original_filename,human_review_status,storage_ref FROM ilb_subject_document WHERE subject_key=? ORDER BY COALESCE(document_date,DATE(created_at)) DESC");$q->execute([$subject]);$documents=$q->fetchAll();
 $counts=['days'=>count($snapshots),'reports'=>count($documents),'medicines'=>count($medicines),'flags'=>array_sum(array_column($snapshots,'safety_count'))];
}
function h(mixed $v):string{return htmlspecialchars((string)$v,ENT_QUOTES,'UTF-8');}
?><!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><meta name="robots" content="noindex,nofollow,noarchive"><title>Case Review — I Love My Body</title><link rel="preconnect" href="https://fonts.googleapis.com"><link rel="preconnect" href="https://fonts.gstatic.com" crossorigin><link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600;700&display=swap" rel="stylesheet"><link rel="stylesheet" href="assets/review.css?v=1"></head><body>
<?php if(!$signed): ?><main class="review-login"><p class="eyebrow">OWNER REVIEW</p><h1>Case dashboard</h1><p>Protected review and checking area.</p><form method="post"><label>Username<input name="reviewer_user" autocomplete="username" required></label><label>PIN<input name="reviewer_pin" inputmode="numeric" maxlength="6" autocomplete="current-password" required></label><button>Open dashboard</button><p class="error"><?=h($error)?></p></form></main>
<?php else: ?><header><div><b>I LOVE MY BODY</b><span>PRIVATE PARTICIPANT REVIEW</span></div><nav><a href="./">Participant app</a><a href="?logout=1">Sign out</a></nav></header><main class="dashboard">
<form method="get" style="margin:0 0 18px"><label class="eyebrow" for="reviewCase">SELECT AUTHORISED PARTICIPANT</label><select id="reviewCase" name="case" onchange="this.form.submit()" style="display:block;margin-top:7px;padding:10px;border:1px solid #000;min-width:280px"><?php foreach($reviewCases as $rc): ?><option value="<?=h($rc['public_case_key'])?>" <?=$selectedCase&&$rc['public_case_key']===$selectedCase['public_case_key']?'selected':''?>><?=h($rc['frontend_label'])?></option><?php endforeach; ?></select></form>
<section class="title"><div><p class="eyebrow">PRIVATE REVIEWER VIEW</p><h1><?=h($selectedCase['frontend_label']??'No authorised participant')?></h1><p>Daily observations and documents. This dashboard does not diagnose or alter prescriptions.</p></div><div class="status"><?=h($selectedCase['allowed_age_display']??'')?><?php if($selectedCase): ?><br>Case active<?php endif; ?></div></section>
<section class="stats"><article><b><?=h($counts['days'])?></b><span>recorded days</span></article><article><b><?=h($counts['reports'])?></b><span>documents</span></article><article><b><?=h($counts['medicines'])?></b><span>medicines</span></article><article class="<?=($counts['flags']??0)?'alert':''?>"><b><?=h($counts['flags'])?></b><span>safety flags</span></article></section>
<section class="panel"><div class="panel-head"><h2>Daily check-ins</h2><span>Latest 60</span></div><div class="table-wrap"><table><thead><tr><th>Date</th><th>Status</th><th>Food</th><th>Happy</th><th>Energy</th><th>Stress</th><th>Discomfort</th><th>Sleep</th><th>Movement</th><th>Flags</th></tr></thead><tbody><?php foreach($snapshots as $s): ?><tr><td><?=h($s['entry_date'])?></td><td><i><?=h($s['status'])?></i></td><td><?=h($s['food_count'])?></td><td><?=h($s['happiness_score']??'—')?></td><td><?=h($s['energy_score']??'—')?></td><td><?=h($s['stress_pressure_score']??'—')?></td><td><?=h($s['physical_discomfort_score']??'—')?></td><td><?=h($s['sleep_minutes']??'—')?></td><td><?=h($s['movement_minutes']??'—')?></td><td class="flag"><?=h($s['safety_count'])?></td></tr><?php endforeach; ?><?php if(!$snapshots): ?><tr><td colspan="10">No daily check-in has been submitted yet.</td></tr><?php endif; ?></tbody></table></div></section>
<div class="columns"><section class="panel"><div class="panel-head"><h2>Medicines</h2><span>Participant record</span></div><?php foreach($medicines as $m): ?><article class="row"><b><?=h($m['reported_name'])?></b><span><?=h($m['strength_text'])?></span><small><?=h($m['dose_text']?:'Dose not entered')?> · <?=h($m['frequency_text']?:'Frequency not entered')?></small></article><?php endforeach; ?></section>
<section class="panel"><div class="panel-head"><h2>Reports & prescriptions</h2><span><?=count($documents)?> files</span></div><?php foreach($documents as $d): ?><article class="row"><b><?=h($d['original_filename']?:str_replace('_',' ',$d['document_type']))?></b><span><?=h($d['document_date']?:'Date not supplied')?></span><?php if(str_starts_with($d['storage_ref'],'private-file:')): ?><a href="?action=document&id=<?=$d['document_id']?>" target="_blank">Open</a><?php endif; ?></article><?php endforeach; ?><?php if(!$documents): ?><p class="empty">No reports uploaded yet.</p><?php endif; ?></section></div>
</main><?php endif; ?></body></html>
