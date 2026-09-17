<?php
declare(strict_types=1);
require __DIR__ . '/_guard.php';
require __DIR__ . '/lib.php';
header('Cache-Control: no-store, no-cache, must-revalidate, max-age=0');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    header('Location: /app/access.php', true, 302);
    exit;
}

$patientId=trim((string)($_POST['user_id']??''));
$password=(string)($_POST['password']??'');
if(!preg_match('/^[A-Za-z0-9][A-Za-z0-9_-]{1,63}$/',$patientId) || $password===''){
    header('Location: /app/access.php?error=credentials',true,302); exit;
}

$pdo=db();
$q=$pdo->prepare("SELECT login_id,public_case_key,pin_hash,status,failed_attempts,locked_until FROM ilb_participant_login WHERE LOWER(public_case_key)=LOWER(?) LIMIT 1");
$q->execute([$patientId]);
$row=$q->fetch();
$locked=$row && !empty($row['locked_until']) && strtotime((string)$row['locked_until'])>time();
$ok=$row && $row['status']==='active' && !$locked && password_verify($password,(string)$row['pin_hash']);

if(!$ok){
    if($row){
        $attempt=(int)($row['failed_attempts']??0)+1;
        $pdo->prepare("UPDATE ilb_participant_login SET failed_attempts=?,locked_until=IF(?>=5,DATE_ADD(NOW(),INTERVAL 15 MINUTE),locked_until) WHERE login_id=?")
            ->execute([$attempt,$attempt,$row['login_id']]);
    }
    header('Location: /app/access.php?error=credentials',true,302); exit;
}

start_private_session();
session_regenerate_id(true);
$_SESSION['ilb_login_id']=(string)$row['login_id'];
$pdo->prepare("UPDATE ilb_participant_login SET failed_attempts=0,locked_until=NULL,last_login_at=NOW() WHERE login_id=?")
    ->execute([$row['login_id']]);
header('Location: /app/#today',true,302);
exit;
