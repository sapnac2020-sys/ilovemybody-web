<?php
declare(strict_types=1);
require __DIR__ . '/_guard.php';

/**
 * One-time setup of a staging participant login.
 *
 * Sets the mobile and PIN for a chosen case, creating the login row if that
 * case has none. Both are needed because login_id is a sha256 of the number
 * and is therefore not recoverable either.
 *
 * The PIN is hashed on submit. It is never logged, echoed, or stored in plain
 * form, so whoever installed this page does not learn it.
 *
 * The case picker is radio cards, not a <select>. A select renders its option
 * list in native OS styling that no stylesheet can reach, which looked like
 * raw debug output next to the rest of the app.
 *
 * Only case key and subject key are shown. No dates of birth, no sex, no
 * clinical context — a page that sets a password has no business showing
 * anyone's medical details.
 *
 * Gated three ways: the staging guard, a single-use token held outside the web
 * root, and deletion of that token the moment a save succeeds.
 */

require __DIR__ . '/lib.php';

$tokenFile = '/home/u756742628/domains/ilovemybody.in/private/reset_token.txt';
$token     = is_readable($tokenFile) ? trim((string)file_get_contents($tokenFile)) : '';

if ($token === '') {
    http_response_code(410);
    exit('<!doctype html><meta charset="utf-8"><title>Used</title>'
       . '<p style="font:16px system-ui;padding:2rem">This link has already been used.</p>');
}

$supplied = (string)($_GET['t'] ?? $_POST['t'] ?? '');
if (!hash_equals($token, $supplied)) {
    http_response_code(404);
    exit('<!doctype html><title>404</title><h1>404</h1>');
}

$pdo = db();
$cases = $pdo->query(
    "SELECT f.public_case_key, f.frontend_label, f.subject_key,
            (SELECT COUNT(*) FROM ilb_participant_login l
              WHERE l.public_case_key = f.public_case_key) AS has_login
       FROM ilb_subject_frontend_alias f
      WHERE f.status = 'active'
      ORDER BY f.public_case_key"
)->fetchAll();

$error  = '';
$done   = false;
$chosen = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $chosen = (string)($_POST['case'] ?? '');
    $phone  = preg_replace('/\D+/', '', (string)($_POST['mobile'] ?? ''));
    if (strlen($phone) === 10) { $phone = '91' . $phone; }
    $pin  = (string)($_POST['pin'] ?? '');
    $pin2 = (string)($_POST['pin2'] ?? '');

    $case = null;
    foreach ($cases as $c) { if (hash_equals($c['public_case_key'], $chosen)) { $case = $c; break; } }

    if (!$case) {
        $error = 'Choose which case this login is for.';
    } elseif (strlen($phone) < 11 || strlen($phone) > 15) {
        $error = 'Enter the 10-digit mobile number.';
    } elseif (!preg_match('/^\d{6}$/', $pin)) {
        $error = 'The PIN must be exactly 6 digits.';
    } elseif (!hash_equals($pin, $pin2)) {
        $error = 'The two PINs do not match.';
    } else {
        $loginId = hash('sha256', $phone);

        $clash = $pdo->prepare(
            "SELECT public_case_key FROM ilb_participant_login
              WHERE login_id = ? AND public_case_key <> ? LIMIT 1"
        );
        $clash->execute([$loginId, $case['public_case_key']]);
        $other = $clash->fetchColumn();

        if ($other !== false) {
            $error = 'That mobile number is already the login for '
                   . htmlspecialchars((string)$other, ENT_QUOTES) . '. Use a different number.';
        } else {
            $existing = $pdo->prepare("SELECT login_id FROM ilb_participant_login WHERE public_case_key = ? LIMIT 1");
            $existing->execute([$case['public_case_key']]);
            $old = $existing->fetchColumn();

            $hash = password_hash($pin, PASSWORD_DEFAULT);

            if ($old !== false) {
                $pdo->prepare(
                    "UPDATE ilb_participant_login
                        SET login_id = ?, subject_key = ?, pin_hash = ?, failed_attempts = 0,
                            locked_until = NULL, must_change_pin = 0, status = 'active'
                      WHERE login_id = ?"
                )->execute([$loginId, $case['subject_key'], $hash, $old]);
            } else {
                $pdo->prepare(
                    "INSERT INTO ilb_participant_login
                        (login_id, subject_key, public_case_key, pin_hash,
                         failed_attempts, must_change_pin, status)
                     VALUES (?,?,?,?,0,0,'active')"
                )->execute([$loginId, $case['subject_key'], $case['public_case_key'], $hash]);
            }

            @unlink($tokenFile);          // single use
            $done = true;
        }
    }
    unset($pin, $pin2, $hash);
}
function e(mixed $v): string { return htmlspecialchars((string)$v, ENT_QUOTES, 'UTF-8'); }
?><!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<meta name="robots" content="noindex,nofollow,noarchive">
<title>Set a login &middot; I Love My Body</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Cormorant+Garamond:wght@500;600&family=DM+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="assets/app.css">
<link rel="stylesheet" href="assets/responsive.css">
<style>
  .boot-card { width: min(460px, calc(100% - 32px)); margin: 8vh auto; text-align: left; }
  .boot-card h1 { margin: 0 0 6px; font-family: var(--display); font-size: 1.75rem;
                  font-weight: 600; letter-spacing: -.01em; }
  .note { margin: 0 0 18px; font-size: .84rem; }
  .picker { display: grid; gap: 8px; margin: 6px 0 18px; }
  .pick { position: relative; display: block; padding: 13px 14px 13px 42px;
          border: 1px solid var(--line); border-radius: 11px; background: #fff;
          cursor: pointer; font-weight: 400; }
  .pick input { position: absolute; left: 14px; top: 50%; transform: translateY(-50%);
                width: 16px; height: 16px; accent-color: var(--neon); margin: 0; }
  .pick .who { display: block; font-weight: 700; font-size: .95rem; }
  .pick .sub { display: block; margin-top: 2px; color: var(--muted); font-size: .74rem; }
  .pick:hover { border-color: var(--neon); }
  .pick:has(input:checked) { border-color: var(--neon);
                             box-shadow: 0 0 0 3px rgba(var(--neon-rgb), .10); }
  .pick input:focus-visible { outline: 2px solid var(--neon); outline-offset: 2px; }
  .legend { display: block; margin: 0 0 6px; font-size: .74rem; font-weight: 700; }
  .boot-card .primary { width: 100%; margin-top: 8px; }
  .done { border-left: 3px solid var(--neon); padding-left: 15px; }
  code { padding: 1px 5px; border-radius: 5px; background: var(--paper); font-size: .9em; }
</style>
</head>
<body>
<main class="boot-card">
<?php if ($done): ?>
  <div class="done">
    <p class="eyebrow">STAGING</p>
    <h1>Done</h1>
    <p class="muted note">The mobile and PIN are set for <code><?= e($chosen) ?></code>.
    This link is dead now &mdash; it worked once, and the token has been deleted.</p>
    <p class="muted note">Sign in at <code>index.php</code> with the number and PIN you just entered.</p>
  </div>
<?php else: ?>
  <p class="eyebrow">STAGING</p>
  <h1>Set a login</h1>
  <p class="muted note">The PIN is hashed the moment you submit. It is not logged,
  not shown again, and cannot be read back by anyone.</p>

  <?php if ($error): ?><p class="error"><?= $error ?></p><?php endif; ?>

  <form method="post" autocomplete="off">
    <input type="hidden" name="t" value="<?= e($supplied) ?>">

    <fieldset style="border:0;padding:0;margin:0 0 4px">
      <legend class="legend">Which case</legend>
      <div class="picker">
        <?php foreach ($cases as $c): ?>
          <label class="pick">
            <input type="radio" name="case" value="<?= e($c['public_case_key']) ?>"
                   <?= $chosen === $c['public_case_key'] ? 'checked' : '' ?> required>
            <span class="who"><?= e($c['frontend_label']) ?></span>
            <span class="sub"><?= e($c['subject_key']) ?><?= (int)$c['has_login'] ? ' &middot; already has a login' : ' &middot; no login yet' ?></span>
          </label>
        <?php endforeach; ?>
      </div>
    </fieldset>

    <label class="field">Mobile number
      <input name="mobile" inputmode="numeric" autocomplete="off" placeholder="10 digits" required>
    </label>

    <label class="field">6-digit PIN
      <input name="pin" type="password" inputmode="numeric" minlength="6" maxlength="6"
             autocomplete="new-password" required>
    </label>

    <label class="field">Repeat the 6-digit PIN
      <input name="pin2" type="password" inputmode="numeric" minlength="6" maxlength="6"
             autocomplete="new-password" required>
    </label>

    <button class="primary">Set it</button>
  </form>
<?php endif; ?>
</main>
</body>
</html>
