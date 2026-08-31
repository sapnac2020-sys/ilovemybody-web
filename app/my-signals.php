<?php
declare(strict_types=1);
require __DIR__ . "/_guard.php";

/**
 * A person's own record of their signals.
 *
 * This page shows someone their own data back. That is a different job from
 * the reviewer dashboard and carries different risks, so three rules apply
 * here that do not apply there:
 *
 *   1. No hormone, no organ, no branch. The reviewer sees the chain because
 *      the reviewer is checking the model. Showing a person "cortisol, fight
 *      branch" invites them to read a mechanism into their own body that the
 *      data does not support. They see their own sequence and nothing under it.
 *
 *   2. Sequences are collapsed. vw_ilb_emotion_body_memory returns one row per
 *      hormone route, so anger->pain arrives twice with the same count. Those
 *      are the same pairs counted along two paths. MAX, never SUM.
 *
 *   3. urgent_overrides_feedback. An open urgent flag replaces the sequence
 *      panel with the safety pathway. Not alongside it. Instead of it.
 *
 * ilb_feedback_safety_policy also forbids diagnosis, cure claims and moral
 * labelling. Nothing here says what anything means.
 */

require __DIR__ . '/lib.php';
start_private_session();
if (empty($_SESSION["ilb_login_id"])) { header("Location: index.php"); exit; }
$case = require_case();
$subject = (string)$case['subject_key'];
$name    = (string)($case['frontend_label'] ?? 'you');
$base    = rtrim((string)(cfg()['app']['base_path'] ?? '/app'), '/');
$pdo     = db();

function h(mixed $v): string { return htmlspecialchars((string)$v, ENT_QUOTES, 'UTF-8'); }

/* --- their own entries --- */
$q = $pdo->prepare(
    "SELECT e.body_signal_id, t.display_name, t.signal_group, e.signal_text,
            e.body_location_text, e.observed_at, e.ended_at, e.intensity_score,
            e.frequency_pattern, e.preceding_context_text, e.familiarity,
            e.participant_concern
       FROM ilb_body_signal_event e
       JOIN ilb_body_signal_type t ON t.signal_type_key = e.signal_type_key
      WHERE e.subject_key = ?
      ORDER BY e.observed_at DESC
      LIMIT 300"
);
$q->execute([$subject]);
$events = $q->fetchAll();

/* --- any open flag of their own --- */
$q = $pdo->prepare(
    "SELECT urgency, occurred_at, resolution_status
       FROM ilb_safety_event
      WHERE subject_key = ? AND resolution_status IN ('open','acknowledged')
      ORDER BY FIELD(urgency,'emergency_prompt','urgent_prompt','prompt_review','information')
      LIMIT 1"
);
$q->execute([$subject]);
$openFlag = $q->fetch() ?: null;
$suppress = $openFlag && in_array($openFlag['urgency'], ['emergency_prompt','urgent_prompt'], true);

$resources = [];
if ($openFlag) {
    $resources = $pdo->query(
        "SELECT resource_name, operator_name, phone_primary, phone_alternate,
                hours_text, cost_text
           FROM ilb_safety_resource
          WHERE status='active' ORDER BY display_order, resource_name"
    )->fetchAll();
}

/* --- sequences, collapsed across hormone routes --- */
$patterns = [];
if (!$suppress) {
    $q = $pdo->prepare(
        "SELECT emotion_key, body_key,
                MAX(co_occurrences)  AS times,
                MAX(avg_intensity)   AS strength,
                MAX(avg_lag_minutes) AS lag_minutes,
                MAX(last_seen)       AS last_seen
           FROM vw_ilb_emotion_body_memory
          WHERE subject_key = ?
          GROUP BY emotion_key, body_key
          ORDER BY times DESC, emotion_key"
    );
    $q->execute([$subject]);
    $patterns = $q->fetchAll();
}

/* --- span --- */
$span = '';
if ($events) {
    $first = strtotime((string)end($events)['observed_at']);
    $days  = max(1, (int)ceil((time() - $first) / 86400));
    $span  = $days === 1 ? 'today' : "over $days days";
}

$words = ['new'=>'first time','familiar'=>'happened before','changed'=>'different this time','unsure'=>'not sure'];
?><!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1,viewport-fit=cover">
<meta name="robots" content="noindex,nofollow,noarchive">
<title>What you have recorded</title>
<style>
:root{--bg:#fbf9f7;--card:#fff;--ink:#241f1c;--soft:#6d635c;--line:#e6dfd8;
  --accent:#a8433a;--accent-soft:#fbeeec;--warn:#8a4a12;--warn-bg:#fdf3e7;--r:14px}
@media(prefers-color-scheme:dark){:root{--bg:#17140f;--card:#211d18;--ink:#f0e9e2;
  --soft:#a89d94;--line:#332c25;--accent:#e8887c;--accent-soft:#2e1e1c;
  --warn:#e8b070;--warn-bg:#2d2114}}
*{box-sizing:border-box}
body{margin:0;background:var(--bg);color:var(--ink);padding:0 0 4rem;
  font:16px/1.55 ui-sans-serif,system-ui,"Segoe UI",Roboto,sans-serif}
.wrap{max-width:34rem;margin:0 auto;padding:1.25rem}
h1{font-size:1.45rem;margin:.4rem 0 .2rem;font-weight:650;letter-spacing:-.01em}
h2{font-size:1.05rem;margin:0 0 .2rem}
.lede{color:var(--soft);margin:0 0 1.4rem}
.card{background:var(--card);border:1px solid var(--line);border-radius:var(--r);
  padding:1.1rem;margin-bottom:1rem}
.safety{background:var(--warn-bg);border:1px solid var(--warn)}
.safety h2{color:var(--warn)}
.res{border-top:1px solid var(--line);padding-top:.65rem;margin-top:.65rem}
.res b{display:block}
.res a{color:var(--accent);font-weight:650;font-size:1.15rem;text-decoration:none}
.meta{color:var(--soft);font-size:.85rem}
.seq{padding:.75rem 0;border-top:1px solid var(--line)}
.seq:first-of-type{border-top:0}
.seq .line{font-size:1.02rem}
.seq b{font-weight:650}
.count{display:inline-block;background:var(--accent-soft);color:var(--accent);
  border-radius:999px;padding:.1rem .6rem;font-size:.82rem;font-weight:700}
.day{margin:1.3rem 0 .4rem;font-size:.8rem;letter-spacing:.06em;color:var(--soft);font-weight:700}
.ev{border-left:2px solid var(--line);padding:.1rem 0 .1rem .85rem;margin-bottom:.9rem}
.ev .top{display:flex;justify-content:space-between;gap:.6rem;align-items:baseline}
.ev .name{font-weight:650}
.ev p{margin:.25rem 0}
.pill{font-size:.76rem;color:var(--soft);border:1px solid var(--line);
  border-radius:999px;padding:.05rem .5rem;margin-right:.3rem;display:inline-block}
.go{display:block;text-align:center;padding:.85rem;background:var(--accent);color:#fff;
  border-radius:10px;font-weight:650;text-decoration:none;margin-bottom:1rem}
.foot{color:var(--soft);font-size:.83rem;line-height:1.6;margin:1.6rem 0 0}
</style>
</head>
<body>
<main class="wrap">

  <h1>What you have recorded</h1>
  <p class="lede">Your own words, <?= h($name) ?>, kept as you wrote them.</p>

  <a class="go" href="<?= h($base) ?>/signal.php">Record something new</a>

  <?php if ($openFlag): ?>
    <section class="card safety">
      <h2><?= $suppress ? 'Please read this first' : 'Something you flagged' ?></h2>
      <p>
        <?php if ($suppress): ?>
          You told us you were worried about something you recorded on
          <?= h(substr((string)$openFlag['occurred_at'], 0, 10)) ?>. That is being
          looked at by a person. Until then, this page will not show you patterns
          &mdash; a guess from an app is not what you need right now.
        <?php else: ?>
          Something you recorded on <?= h(substr((string)$openFlag['occurred_at'], 0, 10)) ?>
          has been passed to a person to look at.
        <?php endif; ?>
      </p>
      <p>If it is getting worse, or you are frightened, do not wait for us.</p>
      <?php foreach ($resources as $r): ?>
        <div class="res">
          <b><?= h($r['resource_name']) ?></b>
          <a href="tel:<?= h($r['phone_primary']) ?>"><?= h($r['phone_primary']) ?></a>
          <?php if ($r['phone_alternate']): ?><span class="meta">or <?= h($r['phone_alternate']) ?></span><?php endif; ?>
          <div class="meta"><?= h($r['operator_name']) ?> &middot; <?= h($r['hours_text']) ?><?= $r['cost_text'] ? ' &middot; ' . h($r['cost_text']) : '' ?></div>
        </div>
      <?php endforeach; ?>
    </section>
  <?php endif; ?>

  <?php if (!$events): ?>
    <section class="card">
      <h2>Nothing yet</h2>
      <p class="meta">Once you record something it will stay here. Nothing is
      shared, and nothing is scored.</p>
    </section>

  <?php else: ?>

    <section class="card">
      <h2><?= count($events) ?> recorded<?= $span ? ' ' . h($span) : '' ?></h2>
      <p class="meta">Only you and the person reviewing your case can see these.</p>
    </section>

    <?php if (!$suppress && $patterns): ?>
      <section class="card">
        <h2>What has tended to follow what</h2>
        <p class="meta" style="margin:.15rem 0 .6rem">
          Only sequences you have recorded three or more times, within two days of
          each other.
        </p>
        <?php foreach ($patterns as $p): ?>
          <div class="seq">
            <div class="line">
              <b><?= h(ucfirst(str_replace('_',' ', (string)$p['emotion_key']))) ?></b>
              was followed by
              <b><?= h(str_replace('_',' ', (string)$p['body_key'])) ?></b>
              <span class="count"><?= h($p['times']) ?>&times;</span>
            </div>
            <p class="meta">
              <?php if ($p['lag_minutes'] !== null): ?>
                usually about <?= h(round((float)$p['lag_minutes'] / 60, 1)) ?> hours later<?php endif; ?>
              <?php if ($p['strength'] !== null): ?>
                &middot; strength around <?= h(round((float)$p['strength'])) ?>/10<?php endif; ?>
              &middot; last on <?= h(substr((string)$p['last_seen'], 0, 10)) ?>
            </p>
          </div>
        <?php endforeach; ?>
        <p class="meta" style="margin-top:.9rem">
          <b>One thing that matters:</b> two things happening in order does not mean
          the first caused the second. This is a list of what you wrote down, not an
          explanation of it, and it is not a diagnosis. If a sequence here worries
          you, it is worth showing to a doctor rather than solving alone.
        </p>
      </section>

    <?php elseif (!$suppress): ?>
      <section class="card">
        <h2>No repeating sequences yet</h2>
        <p class="meta">A sequence only appears here after the same emotion has been
        followed by the same body signal three separate times. Below that it could
        easily be chance, so showing it would mislead you.</p>
      </section>
    <?php endif; ?>

    <section>
      <h2 style="margin-bottom:.2rem">Everything, most recent first</h2>
      <?php $lastDay = null; foreach ($events as $e):
        $day = substr((string)$e['observed_at'], 0, 10);
        if ($day !== $lastDay): $lastDay = $day; ?>
          <p class="day"><?= h(date('D j M Y', strtotime($day))) ?></p>
        <?php endif; ?>
        <article class="ev">
          <div class="top">
            <span class="name"><?= h($e['display_name']) ?></span>
            <span class="meta"><?= h(substr((string)$e['observed_at'], 11, 5)) ?></span>
          </div>
          <p><?= h($e['signal_text']) ?></p>
          <p>
            <?php if ($e['body_location_text']): ?><span class="pill"><?= h($e['body_location_text']) ?></span><?php endif; ?>
            <?php if ($e['intensity_score'] !== null): ?><span class="pill"><?= h($e['intensity_score']) ?>/10</span><?php endif; ?>
            <span class="pill"><?= h($words[$e['familiarity']] ?? $e['familiarity']) ?></span>
            <?php if ($e['frequency_pattern']): ?><span class="pill"><?= h($e['frequency_pattern']) ?></span><?php endif; ?>
          </p>
          <?php if ($e['preceding_context_text']): ?>
            <p class="meta">Just before: <?= h($e['preceding_context_text']) ?></p>
          <?php endif; ?>
        </article>
      <?php endforeach; ?>
    </section>

  <?php endif; ?>

  <p class="foot">
    This page describes only what you recorded. It does not diagnose anything, does
    not tell you what to do, and never says a food, feeling or choice was good or
    bad.<br><br>
    To correct or remove an entry, ask through the app &mdash; entries are not
    edited here, so that the record stays as you first wrote it.
  </p>
</main>
</body>
</html>
