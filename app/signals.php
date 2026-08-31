<?php
declare(strict_types=1);

require __DIR__ . '/_guard.php';
/**
 * Signal review dashboard.
 *
 * Reads ilb_body_signal_event and ilb_safety_event, and lets a reviewer close
 * a safety flag. The closing half is not optional: a flag nobody can clear is
 * worse than no flag, because it looks like someone is watching.
 *
 * Authentication, lockout and case selection follow admin.php exactly, so a
 * reviewer signs in once for both. Subjects are addressed only by their
 * public_case_key; raw subject keys never reach the page.
 *
 * ilb_feedback_safety_policy governs what may be said here:
 *   block_diagnosis            nothing on this page names a condition
 *   association_wording        co-occurrence is written "was followed by"
 *   urgent_overrides_feedback  an open urgent flag hides the pattern panel
 */

require __DIR__ . '/lib.php';
start_private_session();

$c = cfg()['app'];
$error = '';

if (isset($_GET['logout'])) {
    unset($_SESSION['ilb_reviewer']);
    header('Location: signals.php');
    exit;
}

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['reviewer_user'])) {
    if ((int)($_SESSION['ilb_reviewer_locked_until'] ?? 0) > time()) {
        $error = 'Too many attempts. Please wait 15 minutes.';
    } else {
        $okUser = hash_equals((string)($c['reviewer_user'] ?? ''), trim((string)$_POST['reviewer_user']));
        $okPin  = hash_equals((string)($c['reviewer_secret_sha256'] ?? ''), hash('sha256', (string)($_POST['reviewer_pin'] ?? '')));
        if ($okUser && $okPin) {
            session_regenerate_id(true);
            $_SESSION['ilb_reviewer'] = true;
            unset($_SESSION['ilb_reviewer_attempts'], $_SESSION['ilb_reviewer_locked_until']);
            header('Location: signals.php');
            exit;
        }
        $attempts = (int)($_SESSION['ilb_reviewer_attempts'] ?? 0) + 1;
        $_SESSION['ilb_reviewer_attempts'] = $attempts;
        if ($attempts >= 5) $_SESSION['ilb_reviewer_locked_until'] = time() + 900;
        $error = 'Username or PIN is incorrect.';
    }
}

$signed = !empty($_SESSION['ilb_reviewer']);
function h(mixed $v): string { return htmlspecialchars((string)$v, ENT_QUOTES, 'UTF-8'); }

/* Closing a safety flag changes state, so it carries a token. admin.php has no
   equivalent because it only reads. */
if ($signed && empty($_SESSION['ilb_csrf'])) {
    $_SESSION['ilb_csrf'] = bin2hex(random_bytes(16));
}
$csrf = (string)($_SESSION['ilb_csrf'] ?? '');

$notice = '';

/* ------------------------------------------------------------------ */
/* Resolve a safety flag                                              */
/* ------------------------------------------------------------------ */

if ($signed && $_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['safety_event_id'])) {
    if (!hash_equals($csrf, (string)($_POST['csrf'] ?? ''))) {
        $notice = 'That form had expired. Nothing was changed.';
    } else {
        $id     = (int)$_POST['safety_event_id'];
        $status = (string)($_POST['resolution_status'] ?? '');
        $note   = trim((string)($_POST['resolution_note'] ?? ''));
        $allowed = ['acknowledged', 'referred', 'resolved', 'false_positive'];

        if (!in_array($status, $allowed, true)) {
            $notice = 'Choose what was done.';
        } elseif ($note === '') {
            $notice = 'A note is required. What was done, and by whom.';
        } else {
            $closing = in_array($status, ['resolved', 'false_positive'], true);
            $stmt = db()->prepare(
                "UPDATE ilb_safety_event
                    SET resolution_status = ?,
                        resolution_note   = ?,
                        acknowledged_at   = COALESCE(acknowledged_at, NOW()),
                        closed_by         = IF(? = 1, ?, closed_by),
                        closed_at         = IF(? = 1, NOW(), closed_at)
                  WHERE safety_event_id = ?"
            );
            $stmt->execute([
                $status, mb_substr($note, 0, 1500),
                $closing ? 1 : 0, (string)($c['reviewer_user'] ?? 'reviewer'),
                $closing ? 1 : 0, $id,
            ]);
            $notice = 'Recorded.';
        }
    }
}

$cases = [];
$selected = null;
$subject = '';
$openFlags = [];
$events = [];
$patterns = [];
$counts = ['events' => 0, 'open' => 0, 'urgent' => 0, 'types' => 0];
$suppressed = false;

if ($signed) {
    $p = db();

    $cases = $p->query(
        "SELECT public_case_key, frontend_label, allowed_age_display
           FROM ilb_subject_frontend_alias
          WHERE status='active' ORDER BY frontend_label"
    )->fetchAll();

    $requested = preg_replace('/[^a-zA-Z0-9_-]/', '', (string)($_GET['case'] ?? $_SESSION['ilb_review_case'] ?? ''));
    foreach ($cases as $rc) {
        if (hash_equals($rc['public_case_key'], $requested)) { $selected = $rc; break; }
    }
    if (!$selected && $cases) $selected = $cases[0];

    if ($selected) {
        $_SESSION['ilb_review_case'] = $selected['public_case_key'];
        $r = $p->prepare("SELECT subject_key FROM ilb_subject_frontend_alias WHERE public_case_key=? AND status='active'");
        $r->execute([$selected['public_case_key']]);
        $subject = (string)$r->fetchColumn();
    }

    /* Open flags across every case, not only the selected one. An urgent flag
       on someone else's case does not become less urgent because a different
       case is on screen. */
    $openFlags = $p->query(
        "SELECT s.safety_event_id, s.subject_key, s.trigger_key, s.source_ref,
                s.occurred_at, s.urgency, s.raised_by, s.resolution_status,
                s.acknowledged_at,
                t.trigger_name, t.match_rule_text,
                f.frontend_label, f.public_case_key,
                e.signal_text, e.body_location_text, e.intensity_score,
                e.participant_concern, bt.display_name AS signal_name
           FROM ilb_safety_event s
           LEFT JOIN ilb_safety_trigger t ON t.trigger_key = s.trigger_key
           LEFT JOIN ilb_subject_frontend_alias f
                  ON f.subject_key = s.subject_key AND f.status='active'
           LEFT JOIN ilb_body_signal_event e
                  ON s.source_kind = 'body_signal'
                 AND e.body_signal_id = CAST(SUBSTRING_INDEX(s.source_ref, ':', -1) AS UNSIGNED)
           LEFT JOIN ilb_body_signal_type bt ON bt.signal_type_key = e.signal_type_key
          WHERE s.resolution_status IN ('open','acknowledged')
          ORDER BY FIELD(s.urgency,'emergency_prompt','urgent_prompt','prompt_review','information'),
                   s.occurred_at ASC"
    )->fetchAll();

    $counts['open']   = count($openFlags);
    $counts['urgent'] = count(array_filter($openFlags,
        fn($f) => in_array($f['urgency'], ['emergency_prompt','urgent_prompt'], true)));

    if ($subject !== '') {
        $q = $p->prepare(
            "SELECT e.body_signal_id, e.signal_type_key, t.display_name, t.signal_group,
                    t.requires_safety_screen, e.signal_text, e.body_location_text,
                    e.observed_at, e.ended_at, e.intensity_score, e.frequency_pattern,
                    e.preceding_context_text, e.familiarity, e.participant_concern,
                    e.capture_channel
               FROM ilb_body_signal_event e
               JOIN ilb_body_signal_type t ON t.signal_type_key = e.signal_type_key
              WHERE e.subject_key = ?
              ORDER BY e.observed_at DESC
              LIMIT 200"
        );
        $q->execute([$subject]);
        $events = $q->fetchAll();
        $counts['events'] = count($events);
        $counts['types']  = count(array_unique(array_column($events, 'signal_type_key')));

        /* urgent_overrides_feedback: an open urgent or emergency flag for THIS
           subject suppresses ordinary interpretation. Policy, not preference. */
        foreach ($openFlags as $f) {
            if ($f['subject_key'] === $subject
                && in_array($f['urgency'], ['emergency_prompt','urgent_prompt'], true)) {
                $suppressed = true;
            }
        }

        if (!$suppressed) {
            $q = $p->prepare(
                "SELECT emotion_key, hormone_key, branch, body_key, body_signal_group,
                        requires_safety_screen, co_occurrences, avg_intensity,
                        avg_lag_minutes, first_seen, last_seen
                   FROM vw_ilb_emotion_body_memory
                  WHERE subject_key = ?
                  ORDER BY co_occurrences DESC, emotion_key"
            );
            $q->execute([$subject]);
            $patterns = $q->fetchAll();
        }
    }
}

$urgencyWord = [
    'emergency_prompt' => 'Emergency',
    'urgent_prompt'    => 'Urgent',
    'prompt_review'    => 'Review',
    'information'      => 'Information',
];
$famWord = ['new'=>'First time','familiar'=>'Happened before','changed'=>'Different this time','unsure'=>'Not sure'];
?><!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<meta name="robots" content="noindex,nofollow,noarchive">
<title>Signal review — I Love My Body</title>
<style>
:root{--bg:#f7f5f2;--card:#fff;--ink:#1d1a17;--soft:#6b625b;--line:#e2dbd3;
  --alert:#a8332a;--alert-bg:#fbecea;--warn:#8a5a12;--warn-bg:#fdf5e6;--ok:#2f6b45;--r:12px}
@media(prefers-color-scheme:dark){:root{--bg:#151210;--card:#1f1b17;--ink:#efe8e1;
  --soft:#a79c93;--line:#332b24;--alert:#f08a7e;--alert-bg:#2f1b18;--warn:#e0ad63;
  --warn-bg:#2b2013;--ok:#7fc79b}}
*{box-sizing:border-box}
body{margin:0;background:var(--bg);color:var(--ink);
  font:15px/1.5 ui-sans-serif,system-ui,"Segoe UI",Roboto,sans-serif}
.login{max-width:22rem;margin:5rem auto;padding:1.5rem;background:var(--card);
  border:1px solid var(--line);border-radius:var(--r)}
.login label{display:block;margin:0 0 .9rem;font-weight:600;font-size:.9rem}
.login input{width:100%;padding:.65rem;margin-top:.3rem;font:inherit;color:inherit;
  background:var(--bg);border:1px solid var(--line);border-radius:8px}
.eyebrow{letter-spacing:.09em;font-size:.72rem;color:var(--soft);margin:0 0 .3rem;font-weight:700}
header{display:flex;justify-content:space-between;align-items:center;gap:1rem;
  padding:.9rem 1.25rem;border-bottom:1px solid var(--line);background:var(--card);flex-wrap:wrap}
header b{letter-spacing:.06em}
header nav a{margin-left:1rem;color:var(--soft);text-decoration:none;font-size:.88rem}
main{max-width:62rem;margin:0 auto;padding:1.25rem}
h1{font-size:1.4rem;margin:.2rem 0 .3rem}
h2{font-size:1.05rem;margin:0}
.stats{display:grid;grid-template-columns:repeat(auto-fit,minmax(8rem,1fr));gap:.7rem;margin:1rem 0}
.stats article{background:var(--card);border:1px solid var(--line);border-radius:var(--r);padding:.8rem}
.stats b{display:block;font-size:1.5rem}
.stats span{color:var(--soft);font-size:.82rem}
.stats .alert{border-color:var(--alert);background:var(--alert-bg)}
.stats .alert b{color:var(--alert)}
.panel{background:var(--card);border:1px solid var(--line);border-radius:var(--r);
  padding:1.05rem;margin-bottom:1rem}
.panel-head{display:flex;justify-content:space-between;align-items:baseline;
  gap:1rem;margin-bottom:.7rem;flex-wrap:wrap}
.panel-head span{color:var(--soft);font-size:.82rem}
.flag{border:1px solid var(--warn);background:var(--warn-bg);border-radius:var(--r);
  padding:.95rem;margin-bottom:.8rem}
.flag.hot{border-color:var(--alert);background:var(--alert-bg)}
.tag{display:inline-block;padding:.14rem .55rem;border-radius:999px;font-size:.74rem;
  font-weight:700;letter-spacing:.04em;background:var(--warn);color:#fff}
.flag.hot .tag{background:var(--alert)}
.meta{color:var(--soft);font-size:.83rem;margin:.3rem 0}
.act{display:flex;gap:.5rem;margin-top:.7rem;flex-wrap:wrap;align-items:flex-start}
.act select,.act input{padding:.5rem;font:inherit;color:inherit;background:var(--bg);
  border:1px solid var(--line);border-radius:8px}
.act input{flex:1;min-width:13rem}
.act button{padding:.5rem 1rem;border:0;border-radius:8px;background:var(--ink);
  color:var(--bg);font:inherit;font-weight:600;cursor:pointer}
table{width:100%;border-collapse:collapse;font-size:.87rem}
th{text-align:left;color:var(--soft);font-weight:600;font-size:.76rem;
  letter-spacing:.05em;padding:.4rem .5rem;border-bottom:1px solid var(--line)}
td{padding:.5rem;border-bottom:1px solid var(--line);vertical-align:top}
tr:last-child td{border-bottom:0}
.wrap-x{overflow-x:auto}
.dot{width:.5rem;height:.5rem;border-radius:50%;display:inline-block;background:var(--warn)}
.notice{padding:.7rem 1rem;border-radius:8px;background:var(--card);
  border:1px solid var(--line);margin-bottom:1rem}
.empty{color:var(--soft);margin:.3rem 0}
.foot{color:var(--soft);font-size:.8rem;margin:1.5rem 0 3rem;line-height:1.6}
select.case{padding:.55rem;font:inherit;color:inherit;background:var(--card);
  border:1px solid var(--line);border-radius:8px;min-width:16rem}
</style>
</head>
<body>

<?php if (!$signed): ?>
<main class="login">
  <p class="eyebrow">OWNER REVIEW</p>
  <h1>Signal review</h1>
  <p class="meta">Protected review area.</p>
  <form method="post">
    <label>Username<input name="reviewer_user" autocomplete="username" required></label>
    <label>PIN<input name="reviewer_pin" type="password" inputmode="numeric" maxlength="6" autocomplete="current-password" required></label>
    <button class="act" style="padding:.6rem 1.1rem;border:0;border-radius:8px;background:var(--ink);color:var(--bg);font:inherit;font-weight:600;cursor:pointer">Open</button>
    <?php if ($error): ?><p style="color:var(--alert);margin:.8rem 0 0"><?= h($error) ?></p><?php endif; ?>
  </form>
</main>

<?php else: ?>
<header>
  <div><b>I LOVE MY BODY</b> <span class="meta">SIGNAL REVIEW</span></div>
  <nav><a href="admin.php">Case dashboard</a><a href="./">Participant app</a><a href="?logout=1">Sign out</a></nav>
</header>

<main>
  <?php if ($notice): ?><p class="notice"><?= h($notice) ?></p><?php endif; ?>

  <!-- ============ open safety flags, all cases ============ -->
  <section class="panel">
    <div class="panel-head">
      <h2>Open safety flags</h2>
      <span>Every case, oldest first</span>
    </div>

    <?php if (!$openFlags): ?>
      <p class="empty">Nothing open. When a flag is raised it appears here until someone closes it.</p>
    <?php else: ?>
      <?php foreach ($openFlags as $f):
        $hot = in_array($f['urgency'], ['emergency_prompt','urgent_prompt'], true); ?>
        <article class="flag <?= $hot ? 'hot' : '' ?>">
          <span class="tag"><?= h($urgencyWord[$f['urgency']] ?? $f['urgency']) ?></span>
          <b><?= h($f['frontend_label'] ?? 'Unlinked case') ?></b>
          <?php if ($f['resolution_status'] === 'acknowledged'): ?>
            <span class="meta">&middot; acknowledged, not closed</span>
          <?php endif; ?>

          <p class="meta">
            <?= h($f['trigger_name'] ?? $f['trigger_key']) ?>
            &middot; raised by <?= h($f['raised_by']) ?>
            &middot; <?= h($f['occurred_at']) ?>
          </p>

          <?php if ($f['signal_text'] !== null): ?>
            <p style="margin:.4rem 0">
              <b><?= h($f['signal_name']) ?></b>
              <?php if ($f['intensity_score'] !== null): ?>
                <span class="meta"><?= h($f['intensity_score']) ?>/10</span>
              <?php endif; ?>
              <br><?= h($f['signal_text']) ?>
              <?php if ($f['body_location_text']): ?>
                <span class="meta">&mdash; <?= h($f['body_location_text']) ?></span>
              <?php endif; ?>
            </p>
            <p class="meta">They described themselves as <?= h($f['participant_concern']) ?> worried.</p>
          <?php else: ?>
            <p class="meta">Source: <?= h($f['source_ref']) ?> (no linked signal found)</p>
          <?php endif; ?>

          <form method="post" class="act">
            <input type="hidden" name="csrf" value="<?= h($csrf) ?>">
            <input type="hidden" name="safety_event_id" value="<?= (int)$f['safety_event_id'] ?>">
            <select name="resolution_status" required>
              <option value="">What was done&hellip;</option>
              <option value="acknowledged">Seen, still open</option>
              <option value="referred">Referred to a clinician</option>
              <option value="resolved">Resolved</option>
              <option value="false_positive">Did not need action</option>
            </select>
            <input name="resolution_note" maxlength="1500" required
                   placeholder="What was done, and by whom">
            <button>Record</button>
          </form>
        </article>
      <?php endforeach; ?>
    <?php endif; ?>
  </section>

  <!-- ============ case selection ============ -->
  <form method="get" style="margin:0 0 1rem">
    <label class="eyebrow" for="case">SELECT AUTHORISED PARTICIPANT</label><br>
    <select class="case" id="case" name="case" onchange="this.form.submit()">
      <?php foreach ($cases as $rc): ?>
        <option value="<?= h($rc['public_case_key']) ?>"
          <?= $selected && $rc['public_case_key'] === $selected['public_case_key'] ? 'selected' : '' ?>>
          <?= h($rc['frontend_label']) ?>
        </option>
      <?php endforeach; ?>
    </select>
  </form>

  <h1><?= h($selected['frontend_label'] ?? 'No authorised participant') ?></h1>
  <p class="meta">Recorded signals. This page does not diagnose, and does not change any treatment.</p>

  <section class="stats">
    <article><b><?= (int)$counts['events'] ?></b><span>signals recorded</span></article>
    <article><b><?= (int)$counts['types'] ?></b><span>distinct kinds</span></article>
    <article class="<?= $counts['open'] ? 'alert' : '' ?>"><b><?= (int)$counts['open'] ?></b><span>flags open</span></article>
    <article class="<?= $counts['urgent'] ? 'alert' : '' ?>"><b><?= (int)$counts['urgent'] ?></b><span>urgent or emergency</span></article>
  </section>

  <!-- ============ patterns ============ -->
  <section class="panel">
    <div class="panel-head">
      <h2>Repeating sequences</h2>
      <span>Three or more occurrences within 48 hours</span>
    </div>

    <?php if ($suppressed): ?>
      <p class="empty"><b>Hidden.</b> This person has an open urgent flag. Ordinary
      interpretation is suppressed until it is closed, under the
      <code>urgent_overrides_feedback</code> policy. Close the flag above first.</p>

    <?php elseif (!$patterns): ?>
      <p class="empty">Nothing yet. A sequence appears here only after an emotion has
      been followed by a body signal three separate times, for this person. Below
      that it is not a pattern, it is noise.</p>

    <?php else: ?>
      <div class="wrap-x">
      <table>
        <thead><tr>
          <th>Emotion</th><th>Was followed by</th><th>Branch</th><th>Hormone</th>
          <th>Times</th><th>Avg strength</th><th>Typical gap</th><th>Last seen</th>
        </tr></thead>
        <tbody>
        <?php foreach ($patterns as $p2): ?>
          <tr>
            <td><?= h(str_replace('_',' ',$p2['emotion_key'])) ?></td>
            <td>
              <?= h(str_replace('_',' ',$p2['body_key'])) ?>
              <?php if ((int)$p2['requires_safety_screen'] === 1): ?><span class="dot" title="safety-screened signal"></span><?php endif; ?>
            </td>
            <td><?= h($p2['branch']) ?></td>
            <td><?= h($p2['hormone_key']) ?></td>
            <td><b><?= h($p2['co_occurrences']) ?></b></td>
            <td><?= h($p2['avg_intensity'] ?? '—') ?></td>
            <td><?= $p2['avg_lag_minutes'] === null ? '—' : h(round((float)$p2['avg_lag_minutes'] / 60, 1)) . ' h' ?></td>
            <td><?= h($p2['last_seen']) ?></td>
          </tr>
        <?php endforeach; ?>
        </tbody>
      </table>
      </div>
      <p class="meta" style="margin-top:.7rem">Something occurring alongside something
      else is not evidence that it caused it. These are sequences this person recorded,
      nothing more.</p>
    <?php endif; ?>
  </section>

  <!-- ============ the signals themselves ============ -->
  <section class="panel">
    <div class="panel-head">
      <h2>Recorded signals</h2>
      <span>Latest <?= (int)$counts['events'] ?><?= $counts['events'] >= 200 ? ' (capped at 200)' : '' ?></span>
    </div>

    <?php if (!$events): ?>
      <p class="empty">Nothing recorded for this participant yet.</p>
    <?php else: ?>
      <div class="wrap-x">
      <table>
        <thead><tr>
          <th>When</th><th>What</th><th>In their words</th><th>Where</th>
          <th>Str.</th><th>Before?</th><th>Worried</th><th>Preceded by</th>
        </tr></thead>
        <tbody>
        <?php foreach ($events as $e): ?>
          <tr>
            <td style="white-space:nowrap"><?= h($e['observed_at']) ?></td>
            <td>
              <?= h($e['display_name']) ?>
              <?php if ((int)$e['requires_safety_screen'] === 1): ?><span class="dot" title="safety-screened signal"></span><?php endif; ?>
              <br><span class="meta"><?= h(str_replace('_',' ',$e['signal_group'])) ?></span>
            </td>
            <td><?= h($e['signal_text']) ?></td>
            <td><?= h($e['body_location_text'] ?? '—') ?></td>
            <td><?= $e['intensity_score'] === null ? '—' : h($e['intensity_score']) ?></td>
            <td><?= h($famWord[$e['familiarity']] ?? $e['familiarity']) ?></td>
            <td><?= h($e['participant_concern']) ?></td>
            <td><?= h($e['preceding_context_text'] ?? '—') ?></td>
          </tr>
        <?php endforeach; ?>
        </tbody>
      </table>
      </div>
    <?php endif; ?>
  </section>

  <p class="foot">
    A flag stays open until someone closes it here. Every close is written to
    <code>ilb_safety_event</code> with a note and a timestamp, and cannot be undone
    from this page.<br>
    This dashboard describes what was recorded. It does not diagnose, does not
    recommend, and does not alter any prescription.
  </p>
</main>
<?php endif; ?>
</body>
</html>
