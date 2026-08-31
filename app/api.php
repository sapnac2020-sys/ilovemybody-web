<?php
declare(strict_types=1);
require __DIR__ . '/_guard.php';
require __DIR__ . '/lib.php';
$pdo=db(); $action=$_GET['action']??'bootstrap';

if ($action==='login' && $_SERVER['REQUEST_METHOD']==='POST') {
    $d=request_data(); $phone=preg_replace('/\D+/','',(string)($d['mobile']??''));
    if(strlen($phone)===10)$phone='91'.$phone;
    $pin=(string)($d['pin']??''); $loginId=hash('sha256',$phone);
    $stmt=$pdo->prepare("SELECT * FROM ilb_participant_login WHERE login_id=? LIMIT 1"); $stmt->execute([$loginId]); $login=$stmt->fetch();
    if(!$login || $login['status']!=='active' || ($login['locked_until'] && strtotime($login['locked_until'])>time()) || !password_verify($pin,$login['pin_hash'])) {
        if($login){$attempt=(int)$login['failed_attempts']+1;$pdo->prepare("UPDATE ilb_participant_login SET failed_attempts=?,locked_until=IF(?>=5,DATE_ADD(NOW(),INTERVAL 15 MINUTE),locked_until) WHERE login_id=?")->execute([$attempt,$attempt,$loginId]);}
        json_out(['ok'=>false,'error'=>'Mobile number or PIN is incorrect.'],401);
    }
    start_private_session(); session_regenerate_id(true); $_SESSION['ilb_login_id']=$loginId;
    $pdo->prepare("UPDATE ilb_participant_login SET failed_attempts=0,locked_until=NULL,last_login_at=NOW() WHERE login_id=?")->execute([$loginId]);
    json_out(['ok'=>true,'must_change_pin'=>(bool)$login['must_change_pin']]);
}
if($action==='logout'){start_private_session();$_SESSION=[];session_destroy();json_out(['ok'=>true]);}

$case=require_case();

if ($action === 'theme' && $_SERVER['REQUEST_METHOD'] === 'POST') {
    $d=request_data(); $theme=(string)($d['theme_key']??'pink');
    $check=$pdo->prepare("SELECT 1 FROM webcustapp_theme_palette WHERE theme_key=? AND status='active'");
    $check->execute([$theme]);
    if(!$check->fetchColumn()) json_out(['ok'=>false,'error'=>'That colour is not available.'],422);
    $pdo->prepare("INSERT INTO ilb_subject_ui_preference(subject_key,theme_key) VALUES (?,?)
                   ON DUPLICATE KEY UPDATE theme_key=VALUES(theme_key)")->execute([$case['subject_key'],$theme]);
    json_out(['ok'=>true,'theme_key'=>$theme]);
}

if ($action === 'sources' && $_SERVER['REQUEST_METHOD'] === 'GET') {
    $key=preg_replace('/[^a-z0-9_:-]/','',(string)($_GET['key']??''));
    if($key==='') json_out(['ok'=>false,'error'=>'Choose an insight first.'],422);
    $stmt=$pdo->prepare("SELECT energy_insight_key,insight_name,energy_layer,evidence_class,
                               participant_explanation,boundary_text,reference_id,source_label,support_role,
                               popup_note,exact_source_title,authors_or_group,publisher_or_journal,
                               publication_year,doi,pmid,canonical_url,quality_status
                          FROM v_ilb_energy_source_popup WHERE energy_insight_key=?
                          ORDER BY is_primary DESC,reference_id");
    $stmt->execute([$key]); $rows=$stmt->fetchAll();
    if(!$rows) json_out(['ok'=>false,'error'=>'No source record is available for this insight.'],404);
    json_out(['ok'=>true,'insight'=>[
      'key'=>$rows[0]['energy_insight_key'],'name'=>$rows[0]['insight_name'],'layer'=>$rows[0]['energy_layer'],
      'evidence_class'=>$rows[0]['evidence_class'],'explanation'=>$rows[0]['participant_explanation'],
      'boundary'=>$rows[0]['boundary_text']
    ],'references'=>array_map(fn($x)=>[
      'reference_id'=>$x['reference_id'],'label'=>$x['source_label'],'role'=>$x['support_role'],
      'note'=>$x['popup_note'],'title'=>$x['exact_source_title'],'group'=>$x['authors_or_group'],
      'publisher'=>$x['publisher_or_journal'],'year'=>$x['publication_year'],'doi'=>$x['doi'],
      'pmid'=>$x['pmid'],'url'=>$x['canonical_url'],'quality'=>$x['quality_status']
    ],array_filter($rows,fn($x)=>$x['reference_id']!==null))]);
}

if ($action === 'bootstrap') {
    $med = $pdo->prepare("SELECT medicine_report_id,reported_name,strength_text,dose_text,frequency_text,usual_time_text,reason_text
                          FROM ilb_subject_medicine_report WHERE subject_key=? AND status='active' ORDER BY medicine_report_id");
    $med->execute([$case['subject_key']]);
    $docs = $pdo->prepare("SELECT d.document_id,d.document_type,d.document_date,d.original_filename,d.mime_type,
                                  d.human_review_status,CASE WHEN d.storage_ref LIKE 'private-file:%' THEN 1 ELSE 0 END AS downloadable
                             FROM ilb_subject_document d WHERE d.subject_key=? ORDER BY COALESCE(d.document_date,DATE(d.created_at)) DESC,d.document_id DESC");
    $docs->execute([$case['subject_key']]);
    $pages=$pdo->query("SELECT page_key,route_path,nav_label,nav_icon,page_title,eyebrow,intro_text,sort_order
                          FROM webcustapp_page WHERE access_scope='participant' AND status='active' ORDER BY sort_order")->fetchAll();
    $themes=$pdo->query("SELECT theme_key,theme_name,accent_hex,accent_rgb,accent_on_text_hex,is_default
                           FROM webcustapp_theme_palette WHERE status='active' ORDER BY sort_order")->fetchAll();
    $pref=$pdo->prepare("SELECT p.theme_key,t.accent_hex,t.accent_rgb,t.accent_on_text_hex,p.density,p.reduced_motion,p.language_code
                           FROM ilb_subject_ui_preference p JOIN webcustapp_theme_palette t ON t.theme_key=p.theme_key
                          WHERE p.subject_key=?");
    $pref->execute([$case['subject_key']]); $preference=$pref->fetch();
    if(!$preference){
      $default=$pdo->query("SELECT theme_key,accent_hex,accent_rgb,accent_on_text_hex FROM webcustapp_theme_palette WHERE is_default=1 AND status='active' LIMIT 1")->fetch();
      if(!$default) $default=['theme_key'=>'pink','accent_hex'=>'#E6157F','accent_rgb'=>'230,21,127','accent_on_text_hex'=>'#FFFFFF'];
      $preference=$default+['density'=>'comfortable','reduced_motion'=>0,'language_code'=>'en'];
    }
    $plan=$pdo->query("SELECT plan_day,day_name,primary_purpose,owning_tables,clinical_boundary
                        FROM ilb_direction_week_plan WHERE status='active' ORDER BY plan_day")->fetchAll();
    json_out(['ok'=>true,'case'=>[
        'label'=>$case['frontend_label'],'age'=>$case['allowed_age_display'],'sex'=>$case['allowed_sex_display']
    ],'pages'=>$pages,'themes'=>$themes,'preference'=>$preference,'direction_plan'=>$plan,
       'medicines'=>$med->fetchAll(),'documents'=>$docs->fetchAll(),'today'=>date('Y-m-d')]);
}

if ($action === 'medicine' && $_SERVER['REQUEST_METHOD'] === 'POST') {
    $d = request_data();
    $id = (int)($d['medicine_report_id']??0);
    $name = text_or_null($d['reported_name']??null,255);
    if (!$name) json_out(['ok'=>false,'error'=>'Medicine name is required.'],422);
    $fields = [text_or_null($d['strength_text']??null,120),text_or_null($d['dose_text']??null,160),
      text_or_null($d['frequency_text']??null,160),text_or_null($d['usual_time_text']??null,160),
      text_or_null($d['reason_text']??null,500)];
    if ($id) {
        $stmt=$pdo->prepare("UPDATE ilb_subject_medicine_report SET reported_name=?,strength_text=?,dose_text=?,frequency_text=?,usual_time_text=?,reason_text=?,verification_status='self_reported'
                             WHERE medicine_report_id=? AND subject_key=?");
        $stmt->execute([$name,...$fields,$id,$case['subject_key']]);
        if (!$stmt->rowCount()) json_out(['ok'=>false,'error'=>'Medicine record was not found.'],404);
    } else {
        $stmt=$pdo->prepare("INSERT INTO ilb_subject_medicine_report
          (subject_key,item_type,reported_name,strength_text,dose_text,frequency_text,usual_time_text,route_text,reason_text,prescriber_status,verification_status,status)
          VALUES (?,'prescription_medicine',?,?,?,?,?,'oral',?,'unknown','self_reported','active')");
        $stmt->execute([$case['subject_key'],$name,...$fields]);
        $id=(int)$pdo->lastInsertId();
    }
    json_out(['ok'=>true,'medicine_report_id'=>$id]);
}

if ($action === 'upload' && $_SERVER['REQUEST_METHOD'] === 'POST') {
    if (!isset($_FILES['file']) || $_FILES['file']['error'] !== UPLOAD_ERR_OK) json_out(['ok'=>false,'error'=>'Choose a report, prescription or photograph.'],422);
    $f=$_FILES['file'];
    if ($f['size']>15*1024*1024) json_out(['ok'=>false,'error'=>'Maximum file size is 15 MB.'],422);
    $fi=new finfo(FILEINFO_MIME_TYPE); $mime=$fi->file($f['tmp_name']);
    $allowed=['application/pdf'=>'pdf','image/jpeg'=>'jpg','image/png'=>'png','image/webp'=>'webp','image/heic'=>'heic','image/heif'=>'heif'];
    if (!isset($allowed[$mime])) json_out(['ok'=>false,'error'=>'Use PDF, JPG, PNG, WebP or HEIC.'],422);
    $kind=$_POST['document_type']??'other';
    if (!in_array($kind,['laboratory_report','prescription','discharge_summary','imaging_report','food_log','other'],true)) $kind='other';
    $medId=(int)($_POST['medicine_report_id']??0);
    $role=$_POST['document_role']??'other';
    if (!in_array($role,['label_front','label_back','prescription','other'],true)) $role='other';
    $stored=bin2hex(random_bytes(24)).'.'.$allowed[$mime];
    $path=safe_upload_dir().DIRECTORY_SEPARATOR.$stored;
    if (!move_uploaded_file($f['tmp_name'],$path)) json_out(['ok'=>false,'error'=>'Upload could not be secured.'],500);
    chmod($path,0600);
    try {
        $pdo->beginTransaction();
        $stmt=$pdo->prepare("INSERT INTO ilb_subject_document
          (subject_key,document_type,document_date,original_filename,mime_type,storage_ref,checksum_sha256,extraction_status,human_review_status)
          VALUES (?,?,CURRENT_DATE,?,?,?,?,'pending','not_reviewed')");
        $stmt->execute([$case['subject_key'],$kind,mb_substr(basename($f['name']),0,255),$mime,'private-file:'.$stored,hash_file('sha256',$path)]);
        $docId=(int)$pdo->lastInsertId();
        if ($medId) {
            $check=$pdo->prepare("SELECT 1 FROM ilb_subject_medicine_report WHERE medicine_report_id=? AND subject_key=?");
            $check->execute([$medId,$case['subject_key']]);
            if (!$check->fetchColumn()) throw new RuntimeException('Medicine not found.');
            $pdo->prepare("INSERT INTO ilb_medicine_report_document(medicine_report_id,document_id,document_role) VALUES (?,?,?)")
                ->execute([$medId,$docId,$role]);
        }
        $pdo->commit();
        json_out(['ok'=>true,'document_id'=>$docId]);
    } catch(Throwable $e) {
        if($pdo->inTransaction())$pdo->rollBack(); @unlink($path); error_log($e->getMessage());
        json_out(['ok'=>false,'error'=>'The file could not be linked to the case.'],500);
    }
}

if ($action === 'document' && $_SERVER['REQUEST_METHOD'] === 'GET') {
    $id=(int)($_GET['id']??0);
    $stmt=$pdo->prepare("SELECT original_filename,mime_type,storage_ref FROM ilb_subject_document WHERE document_id=? AND subject_key=?");
    $stmt->execute([$id,$case['subject_key']]); $doc=$stmt->fetch();
    if(!$doc || !str_starts_with($doc['storage_ref'],'private-file:')) json_out(['ok'=>false,'error'=>'This document is not available in the app.'],404);
    $stored=substr($doc['storage_ref'],13);
    if(!preg_match('/^[a-f0-9]{48}\.(pdf|jpg|png|webp|heic|heif)$/',$stored)) json_out(['ok'=>false,'error'=>'Invalid document reference.'],400);
    $path=safe_upload_dir().DIRECTORY_SEPARATOR.$stored;
    if(!is_file($path)) json_out(['ok'=>false,'error'=>'Document file is unavailable.'],404);
    header('Content-Type: '.$doc['mime_type']); header('Content-Length: '.filesize($path));
    header('Content-Disposition: inline; filename="'.rawurlencode($doc['original_filename']?:'document').'"'); header('Cache-Control: private,no-store');
    readfile($path); exit;
}

if ($action !== 'save' || $_SERVER['REQUEST_METHOD'] !== 'POST') json_out(['ok'=>false,'error'=>'Unsupported action.'],405);
$d = request_data();
$localDate = preg_match('/^\d{4}-\d{2}-\d{2}$/', (string)($d['local_date'] ?? '')) ? $d['local_date'] : date('Y-m-d');
$submit = !empty($d['submit']);
$pdo->beginTransaction();
try {
    $find = $pdo->prepare('SELECT snapshot_id FROM ilb_daily_checkin WHERE subject_key=? AND local_date=? FOR UPDATE');
    $find->execute([$case['subject_key'],$localDate]);
    $snapshotId = $find->fetchColumn();
    if (!$snapshotId) {
        $captured = $localDate . ' ' . date('H:i:s');
        $pdo->prepare("INSERT INTO ilb_human_state_snapshot
          (subject_key,captured_at,timezone_name,capture_channel,completeness_status,status)
          VALUES (?,?,'Asia/Kolkata','self_mobile','minimal','draft')")->execute([$case['subject_key'],$captured]);
        $snapshotId = (int)$pdo->lastInsertId();
        $pdo->prepare('INSERT INTO ilb_daily_checkin(subject_key,local_date,snapshot_id) VALUES (?,?,?)')
            ->execute([$case['subject_key'],$localDate,$snapshotId]);
    }

    $s = $d['state'] ?? [];
    $status = $submit ? 'submitted' : 'draft';
    $completeness = $submit ? 'complete' : 'partial';
    $pdo->prepare("UPDATE ilb_human_state_snapshot SET
       happiness_score=?,energy_score=?,calm_stability_score=?,sleep_quality_score=?,social_connection_score=?,
       food_satisfaction_score=?,physical_discomfort_score=?,stress_pressure_score=?,primary_concern=?,
       what_is_affecting_me=?,what_would_make_today_better=?,safety_screen_completed=1,
       completeness_status=?,status=? WHERE snapshot_id=? AND subject_key=?")
      ->execute([
       bounded_score($s['happiness']??null),bounded_score($s['energy']??null),bounded_score($s['calm']??null),
       bounded_score($s['sleep_quality']??null),bounded_score($s['connection']??null),bounded_score($s['food_satisfaction']??null),
       bounded_score($s['discomfort']??null),bounded_score($s['stress']??null),text_or_null($s['primary_concern']??null),
       text_or_null($s['affecting']??null,5000),text_or_null($s['better']??null,5000),$completeness,$status,$snapshotId,$case['subject_key']
      ]);

    $b = $d['behaviour'] ?? [];
    $pdo->prepare("INSERT INTO ilb_snapshot_behaviour
      (snapshot_id,sleep_minutes,movement_minutes,sitting_minutes,outdoor_minutes,screen_minutes,water_amount,water_unit,
       alcohol_text,tobacco_text,workload_score,social_contact_score,unusual_event_text)
      VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?) ON DUPLICATE KEY UPDATE
       sleep_minutes=VALUES(sleep_minutes),movement_minutes=VALUES(movement_minutes),sitting_minutes=VALUES(sitting_minutes),
       outdoor_minutes=VALUES(outdoor_minutes),screen_minutes=VALUES(screen_minutes),water_amount=VALUES(water_amount),
       water_unit=VALUES(water_unit),alcohol_text=VALUES(alcohol_text),tobacco_text=VALUES(tobacco_text),
       workload_score=VALUES(workload_score),social_contact_score=VALUES(social_contact_score),unusual_event_text=VALUES(unusual_event_text)")
      ->execute([$snapshotId,nullable_number($b['sleep_minutes']??null),nullable_number($b['movement_minutes']??null),
       nullable_number($b['sitting_minutes']??null),nullable_number($b['outdoor_minutes']??null),nullable_number($b['screen_minutes']??null),
       nullable_number($b['water']??null),'litre',text_or_null($b['alcohol']??null,500),text_or_null($b['tobacco']??null,500),
       bounded_score($b['workload']??null),bounded_score($b['social']??null),text_or_null($b['unusual']??null)]);

    $m = $d['mind'] ?? [];
    $selfHarm = in_array(($m['self_harm']??'not_asked'),['not_asked','no','yes','prefer_not_to_say'],true) ? $m['self_harm'] : 'not_asked';
    $pdo->prepare("INSERT INTO ilb_snapshot_mind_emotion
      (snapshot_id,primary_emotion,recurring_thought,current_worry_or_fear,anger_score,loneliness_score,sense_of_control_score,
       belief_influencing_behaviour,preceding_event_text,self_harm_answer)
      VALUES (?,?,?,?,?,?,?,?,?,?) ON DUPLICATE KEY UPDATE primary_emotion=VALUES(primary_emotion),
       recurring_thought=VALUES(recurring_thought),current_worry_or_fear=VALUES(current_worry_or_fear),anger_score=VALUES(anger_score),
       loneliness_score=VALUES(loneliness_score),sense_of_control_score=VALUES(sense_of_control_score),
       belief_influencing_behaviour=VALUES(belief_influencing_behaviour),preceding_event_text=VALUES(preceding_event_text),
       self_harm_answer=VALUES(self_harm_answer)")
      ->execute([$snapshotId,text_or_null($m['emotion']??null,160),text_or_null($m['thought']??null,5000),
       text_or_null($m['worry']??null,5000),bounded_score($m['anger']??null),bounded_score($m['loneliness']??null),
       bounded_score($m['control']??null),text_or_null($m['belief']??null,5000),text_or_null($m['event']??null,5000),$selfHarm]);

    $pdo->prepare('DELETE FROM ilb_snapshot_symptom WHERE snapshot_id=?')->execute([$snapshotId]);
    $symStmt = $pdo->prepare("INSERT INTO ilb_snapshot_symptom(snapshot_id,symptom_text,body_location_text,pattern,severity_score,trigger_text,relief_text,verification_status)
                              VALUES (?,?,?,?,?,?,?,'self_reported')");
    foreach (($d['symptoms']??[]) as $x) {
        if (!text_or_null($x['text']??null,500)) continue;
        $pattern = in_array(($x['pattern']??'unknown'),['constant','intermittent','single_episode','unknown'],true)?$x['pattern']:'unknown';
        $symStmt->execute([$snapshotId,text_or_null($x['text'],500),text_or_null($x['location']??null,255),$pattern,
          bounded_score($x['severity']??null),text_or_null($x['trigger']??null,500),text_or_null($x['relief']??null,500)]);
    }

    $pdo->prepare('DELETE c FROM ilb_food_event_context c JOIN ilb_snapshot_food_event f ON f.food_event_id=c.food_event_id WHERE f.snapshot_id=?')->execute([$snapshotId]);
    $pdo->prepare('DELETE FROM ilb_snapshot_food_event WHERE snapshot_id=?')->execute([$snapshotId]);
    $foodStmt = $pdo->prepare("INSERT INTO ilb_snapshot_food_event
      (snapshot_id,consumed_at,meal_type,location_text,reported_food_text,quantity_value,quantity_unit_text,preparation_text,hunger_before_score,fullness_after_score,reason_for_eating,digestive_response,alcohol_flag)
      VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)");
    foreach (($d['foods']??[]) as $x) {
        if (!text_or_null($x['text']??null,500)) continue;
        $type = in_array(($x['type']??'unknown'),['breakfast','lunch','dinner','snack','drink','other','unknown'],true)?$x['type']:'unknown';
        $time = preg_match('/^\d{2}:\d{2}$/',(string)($x['time']??'')) ? $localDate.' '.$x['time'].':00' : null;
        $foodStmt->execute([$snapshotId,$time,$type,text_or_null($x['where']??null,255),text_or_null($x['text'],500),nullable_number($x['quantity']??null),
          text_or_null($x['unit']??null,80),text_or_null($x['preparation']??null,500),bounded_score($x['hunger']??null),
          bounded_score($x['fullness']??null),text_or_null($x['reason']??null,500),text_or_null($x['response']??null,1000),!empty($x['alcohol'])?1:0]);
        $foodEventId=(int)$pdo->lastInsertId();
        $pdo->prepare("INSERT INTO ilb_food_event_context
          (food_event_id,before_snapshot_id,why_code,where_code,how_prepared_code,with_whom_code,with_whom_text,source_system,source_database,source_table,source_entity_key,context_note)
          VALUES (?,?,?,?,?,?,?,'ilovemybody_app','u756742628_ilovemybody','ilb_snapshot_food_event',?,?)")
          ->execute([$foodEventId,$snapshotId,text_or_null($x['reason']??null,80),text_or_null($x['where']??null,80),
            text_or_null($x['preparation']??null,80),text_or_null($x['with_whom']??null,80),text_or_null($x['with_whom_text']??null,255),
            (string)$foodEventId,text_or_null($x['context_note']??null,1000)]);
    }

    $pdo->prepare("DELETE FROM ilb_subject_measurement WHERE snapshot_id=? AND verification_status='self_entered'")->execute([$snapshotId]);
    $measureStmt = $pdo->prepare("INSERT INTO ilb_subject_measurement
      (subject_key,snapshot_id,reported_measurement_name,value_numeric,unit_text,measured_at,fasting_status,method_or_device,laboratory_or_source,verification_status)
      VALUES (?,?,?,?,?,?,?,?,?,'self_entered')");
    $measureMap = [
      'fasting_glucose'=>['Fasting glucose','mg/dL','yes'], 'other_glucose'=>['Other glucose','mg/dL','unknown'],
      'systolic_bp'=>['Systolic blood pressure','mmHg','not_applicable'], 'diastolic_bp'=>['Diastolic blood pressure','mmHg','not_applicable'],
      'pulse'=>['Pulse','beats/min','not_applicable'], 'weight'=>['Body weight','kg','not_applicable']
    ];
    foreach ($measureMap as $key=>$meta) {
        $value = nullable_number(($d['measurements']??[])[$key]??null);
        if ($value===null) continue;
        $measureStmt->execute([$case['subject_key'],$snapshotId,$meta[0],$value,$meta[1],$localDate.' '.date('H:i:s'),$meta[2],'Participant-entered home reading','Daily app']);
    }

    $pdo->prepare('DELETE FROM ilb_snapshot_medicine_event WHERE snapshot_id=?')->execute([$snapshotId]);
    $medStmt = $pdo->prepare("INSERT INTO ilb_snapshot_medicine_event(snapshot_id,medicine_report_id,adherence_status,taken_at,participant_note)
                              SELECT ?,medicine_report_id,?,?,? FROM ilb_subject_medicine_report
                              WHERE medicine_report_id=? AND subject_key=? AND status='active'");
    foreach (($d['medicines']??[]) as $x) {
        $st = in_array(($x['status']??'uncertain'),['taken','missed','delayed','not_due','uncertain'],true)?$x['status']:'uncertain';
        $taken = preg_match('/^\d{2}:\d{2}$/',(string)($x['time']??'')) ? $localDate.' '.$x['time'].':00' : null;
        $medStmt->execute([$snapshotId,$st,$taken,text_or_null($x['note']??null,500),(int)($x['id']??0),$case['subject_key']]);
    }

    $pdo->prepare('DELETE FROM ilb_snapshot_safety_flag WHERE snapshot_id=?')->execute([$snapshotId]);
    $flagStmt = $pdo->prepare("INSERT INTO ilb_snapshot_safety_flag
      (snapshot_id,flag_type,reported_answer,reported_detail,urgency,prompt_shown_at,acknowledged_at,resolution_status)
      VALUES (?,?,?,?,?,NOW(),NOW(),'acknowledged')");
    $urgent = false;
    foreach (($d['safety']??[]) as $type=>$answer) {
        if (!in_array($type,['chest_pain','breathing_difficulty','fainting','sudden_weakness','confusion','severe_allergic_reaction','self_harm_concern','other'],true)) continue;
        $answer = in_array($answer,['yes','no','uncertain','prefer_not_to_say'],true)?$answer:'uncertain';
        $urgency = $answer==='yes' ? 'emergency_prompt' : ($answer==='uncertain'?'urgent_prompt':'information');
        if ($answer==='yes' || $answer==='uncertain') $urgent=true;
        $flagStmt->execute([$snapshotId,$type,$answer,null,$urgency]);
    }
    if ($selfHarm==='yes') {
        $urgent=true;
        $flagStmt->execute([$snapshotId,'self_harm_concern','yes',null,'emergency_prompt']);
    }

    if ($submit) $pdo->prepare('UPDATE ilb_daily_checkin SET submitted_at=NOW() WHERE snapshot_id=?')->execute([$snapshotId]);
    $pdo->commit();
    json_out(['ok'=>true,'snapshot_id'=>$snapshotId,'status'=>$status,'urgent'=>$urgent]);
} catch (Throwable $e) {
    if ($pdo->inTransaction()) $pdo->rollBack();
    error_log($e->getMessage());
    json_out(['ok'=>false,'error'=>'The check-in could not be saved. Please try again.'],500);
}
