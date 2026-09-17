<?php
declare(strict_types=1);
header('X-Robots-Tag: noindex,nofollow,noarchive');
header('Cache-Control: no-store, no-cache, must-revalidate, max-age=0');
$error = '';
$enteredId = '';
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $enteredId = strtolower(trim((string)($_POST['user_id'] ?? '')));
    $password = (string)($_POST['password'] ?? '');
    if (!preg_match('/^[a-z0-9][a-z0-9_-]{1,63}$/', $enteredId)) {
        $error = 'Enter the Patient ID exactly as the hospital gave it to you.';
    } elseif ($password === '') {
        $error = 'Enter your password.';
    } else {
        $target = __DIR__ . DIRECTORY_SEPARATOR . $enteredId . '.php';
        if (!is_file($target) || in_array($enteredId, ['index','access','new','api','lib','config','_guard'], true)) {
            $error = 'That Patient ID is not activated. Please check the ID or contact the hospital team that issued it.';
        } else {
            require $target;
            exit;
        }
    }
}
?>
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1,viewport-fit=cover">
<meta name="theme-color" content="#09070b">
<meta name="robots" content="noindex,nofollow,noarchive">
<title>Patient Access · I Love My Body</title>
<style>
:root{--bg:#09070b;--panel:#170d17;--line:rgba(255,255,255,.12);--ink:#fff;--muted:#c6b9c2;--peach:#f3c2a7;--pink:#f09abb}
*{box-sizing:border-box}body{margin:0;background:radial-gradient(circle at 80% 20%,rgba(240,154,187,.08),transparent 28%),var(--bg);color:var(--ink);font-family:system-ui;min-height:100vh}.wrap{width:min(1040px,calc(100% - 28px));margin:0 auto;padding:28px 0 60px}.top{display:flex;justify-content:space-between;align-items:center;gap:12px}.brand{font-weight:800}.brand small{display:block;color:var(--muted);font-size:10px;letter-spacing:.12em}.back{color:var(--muted);text-decoration:none;font-size:13px}.hero{padding:56px 0 28px;max-width:780px}.ey{color:var(--peach);font-size:11px;font-weight:800;letter-spacing:.12em}.hero h1{font:500 clamp(38px,6vw,64px)/1.02 Georgia,serif;margin:10px 0}.hero p{color:var(--muted);line-height:1.7;max-width:700px}.grid{display:grid;grid-template-columns:1.2fr .8fr;gap:14px;margin-top:18px}.c{padding:26px;border:1px solid var(--line);border-radius:20px;background:rgba(23,13,23,.94)}.c h2{font:500 28px Georgia,serif;margin:8px 0}.c p{color:var(--muted);line-height:1.6}.field{display:block;margin:14px 0 6px;font-size:12px;color:var(--muted)}input{width:100%;padding:12px;border-radius:10px;border:1px solid var(--line);background:#0c080d;color:#fff;font:inherit}.primary{width:100%;margin-top:16px;padding:12px;border:0;border-radius:10px;background:var(--peach);color:#2a1120;font-weight:800;cursor:pointer}.alt{display:block;margin-top:16px;color:var(--peach);text-decoration:none}.note{margin-top:18px;padding:14px;border-left:3px solid var(--pink);background:rgba(240,154,187,.06);color:var(--muted);font-size:12px;line-height:1.55}.error{color:#ffb4b4;font-size:12px;min-height:18px;margin-top:8px}.first{display:inline-flex;margin-top:12px;padding:10px 14px;border:1px solid var(--line);border-radius:999px;color:#fff;text-decoration:none;font-size:12px}@media(max-width:760px){.grid{grid-template-columns:1fr}.hero{padding-top:35px}.top{align-items:flex-start;flex-direction:column-reverse}}
</style>
</head>
<body>
<main class="wrap">
<div class="top"><a class="back" href="/hospital.html">← Back to hospital</a><div class="brand">I Love My Body<small>PRIVATE PATIENT ACCESS</small></div></div>
<section class="hero"><div class="ey">RETURNING PATIENT</div><h1>Open your private health journey.</h1><p>If the hospital has already given you a Patient ID and password, use them here. First-time visitors can explore the hospital without signing in.</p><a class="first" href="/app/new.php">I am new — show me how it works →</a></section>
<div class="grid">
<section class="c"><div class="ey">PATIENT ID + PASSWORD</div><h2>Your private dashboard</h2><p>Enter the Patient ID exactly as the hospital gave it to you.</p>
<form method="post" autocomplete="on"><label class="field" for="patientId">Patient ID</label><input id="patientId" name="user_id" autocomplete="username" autocapitalize="none" spellcheck="false" value="<?=htmlspecialchars($enteredId,ENT_QUOTES,'UTF-8')?>" required><label class="field" for="patientPassword">Password</label><input id="patientPassword" name="password" type="password" autocomplete="current-password" required><button class="primary" type="submit">Open my dashboard →</button><?php if($error):?><div class="error" role="alert"><?=htmlspecialchars($error,ENT_QUOTES,'UTF-8')?></div><?php endif;?></form>
<div class="note">If your Patient ID is not yet activated, this page will tell you clearly instead of sending you to a broken page.</div></section>
<section class="c"><div class="ey">OLDER ACCESS</div><h2>Mobile + 6-digit PIN</h2><p>Use this only if you already created a mobile/PIN login in My Happy Space.</p><a class="alt" href="/app/">Open mobile + PIN sign-in →</a><div class="note">New visitors should explore first. A mobile number and PIN are optional repeat-access tools, not a first-visit requirement.</div></section>
</div>
</main>
</body>
</html>
