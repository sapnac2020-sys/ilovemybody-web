<?php
declare(strict_types=1);

/**
 * Record today's reading, as a prediction that can be wrong.
 *
 * This page deliberately shows no measurement of any kind. Not the ring
 * numbers, not a baseline, not yesterday's outcome. If the person making
 * the reading can see the figure they are predicting, there is nothing
 * left to test. reading-api.php returns no values either, so the omission
 * holds even if this page is modified.
 *
 * The prediction is locked the instant it is submitted. There is no edit.
 */

require __DIR__ . '/lib.php';
start_private_session();
if (empty($_SESSION["ilb_login_id"])) { header("Location: index.php"); exit; }
$case = require_case();
$name = (string)($case['frontend_label'] ?? 'you');
$base = rtrim((string)(cfg()['app']['base_path'] ?? '/app'), '/');
?>
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
<title>Today's reading</title>
<style>
:root{
  --bg:#fbf9f7; --card:#fff; --ink:#241f1c; --soft:#6d635c; --line:#e6dfd8;
  --accent:#a8433a; --accent-soft:#fbeeec; --warn:#8a4a12; --warn-bg:#fdf3e7;
  --radius:14px;
}
@media (prefers-color-scheme:dark){
  :root{ --bg:#17140f; --card:#211d18; --ink:#f0e9e2; --soft:#a89d94;
         --line:#332c25; --accent:#e8887c; --accent-soft:#2e1e1c;
         --warn:#e8b070; --warn-bg:#2d2114; }
}
*{box-sizing:border-box}
body{margin:0;background:var(--bg);color:var(--ink);
  font:16px/1.55 ui-sans-serif,system-ui,"Segoe UI",Roboto,sans-serif;
  padding:0 0 4rem}
.wrap{max-width:33rem;margin:0 auto;padding:1.25rem}
h1{font-size:1.45rem;margin:.4rem 0 .2rem;font-weight:650;letter-spacing:-.01em}
.lede{color:var(--soft);margin:0 0 1.5rem}
.card{background:var(--card);border:1px solid var(--line);border-radius:var(--radius);
  padding:1.15rem;margin-bottom:1rem}
label{display:block;font-weight:600;margin:0 0 .3rem;font-size:.94rem}
.hint{color:var(--soft);font-size:.85rem;margin:.3rem 0 0}
input,select,textarea{width:100%;padding:.7rem .8rem;font:inherit;color:inherit;
  background:var(--bg);border:1px solid var(--line);border-radius:10px}
input:focus,select:focus,textarea:focus{outline:2px solid var(--accent);outline-offset:1px}
textarea{min-height:4.5rem;resize:vertical}
.field{margin-bottom:1.05rem}
.opt{color:var(--soft);font-weight:400;font-size:.85rem}
.chips{display:flex;flex-wrap:wrap;gap:.4rem;margin-top:.15rem}
.chip{padding:.45rem .8rem;border:1px solid var(--line);border-radius:999px;
  background:var(--bg);cursor:pointer;font-size:.9rem;color:inherit}
.chip[aria-pressed="true"]{background:var(--accent-soft);border-color:var(--accent);
  color:var(--accent);font-weight:600}
button.go{width:100%;padding:.85rem;background:var(--accent);color:#fff;border:0;
  border-radius:10px;font:inherit;font-weight:650;cursor:pointer}
button.go[disabled]{opacity:.55;cursor:default}
.ghost{background:transparent;border:1px solid var(--line);color:inherit;
  padding:.75rem 1rem;border-radius:10px;font:inherit;cursor:pointer;width:100%}
.msg{padding:.8rem 1rem;border-radius:10px;margin-bottom:1rem;display:none}
.msg.err{display:block;background:var(--accent-soft);color:var(--accent)}
.msg.ok{display:block;background:var(--card);border:1px solid var(--line)}
.note{background:var(--warn-bg);border:1px solid var(--warn);border-radius:var(--radius);
  padding:.9rem 1.05rem;margin-bottom:1rem;font-size:.9rem}
.note b{color:var(--warn)}
.keyword{background:var(--accent-soft);border-left:3px solid var(--accent);
  padding:.6rem .8rem;border-radius:0 8px 8px 0;margin-top:.5rem;font-size:.92rem}
.keyword .pos{color:var(--soft);font-size:.84rem;display:block;margin-top:.2rem}
.prog li{list-style:none;padding:.6rem 0;border-top:1px solid var(--line);font-size:.9rem}
.prog ul{margin:0;padding:0}
.prog .bar{height:6px;background:var(--line);border-radius:3px;margin-top:.35rem;overflow:hidden}
.prog .bar i{display:block;height:100%;background:var(--accent)}
.prog .meta{color:var(--soft);font-size:.82rem}
.hidden{display:none}
h2{font-size:1.05rem;margin:0 0 .6rem}
</style>
</head>
<body>
<main class="wrap">
  <h1>Today&rsquo;s reading</h1>
  <p class="lede">A reading that cannot be wrong cannot be tested, <?= htmlspecialchars($name, ENT_QUOTES) ?>. Say what you expect <em>before</em> the numbers are known, and it locks.</p>

  <div id="msg" class="msg" role="status"></div>

  <div class="note">
    <b>No numbers on this page.</b> Nothing you are predicting is shown here, and
    the server will not send it. That is deliberate &mdash; if you could see
    today&rsquo;s figure there would be nothing left to test.
  </div>

  <form id="form" class="card" novalidate>
    <div class="field">
      <label for="source">Who is making this reading?</label>
      <select id="source" name="prediction_source" required>
        <option value="">Choose one&hellip;</option>
        <option value="redikall_reading">A reading of a point on the map</option>
        <option value="model_derived">Worked out from the database</option>
        <option value="participant_report">What the person says themselves</option>
      </select>
    </div>

    <div class="field hidden" id="pointField">
      <label for="point">Which point?</label>
      <select id="point" name="chakra_code">
        <option value="">Choose a point&hellip;</option>
      </select>
      <div id="keyword" class="keyword hidden"></div>
    </div>

    <div class="field">
      <label for="marker">What should move?</label>
      <select id="marker" name="predicted_marker_key" required>
        <option value="">Choose one&hellip;</option>
      </select>
      <p class="hint">Only measures with a personal baseline can be predicted. Without one there is no direction to be right or wrong about.</p>
    </div>

    <div class="field">
      <label>Which way, against that person&rsquo;s own baseline?</label>
      <div class="chips" id="dir" role="group">
        <button type="button" class="chip" data-v="up" aria-pressed="false">Higher</button>
        <button type="button" class="chip" data-v="down" aria-pressed="false">Lower</button>
        <button type="button" class="chip" data-v="no_change" aria-pressed="false">No real change</button>
      </div>
    </div>

    <div class="field">
      <label for="rationale">Why? <span class="opt">optional</span></label>
      <textarea id="rationale" name="rationale" maxlength="400"
        placeholder="What led you to this. Recorded, never interpreted."></textarea>
    </div>

    <div class="field">
      <label>Have you already seen today&rsquo;s numbers?</label>
      <div class="chips" id="saw" role="group">
        <button type="button" class="chip" data-v="no" aria-pressed="false">No</button>
        <button type="button" class="chip" data-v="yes" aria-pressed="false">Yes</button>
      </div>
      <p class="hint">Answer honestly. A &ldquo;yes&rdquo; is still recorded &mdash; it simply does not count toward the test. A dishonest &ldquo;no&rdquo; would quietly ruin the whole dataset.</p>
    </div>

    <button type="submit" class="go" id="submit">Lock today&rsquo;s reading</button>
    <p class="hint" style="text-align:center;margin-top:.6rem">Once locked it cannot be edited or deleted.</p>
  </form>

  <div class="card">
    <h2>Where this has got to</h2>
    <div class="prog" id="progress"><p class="hint">Nothing counted yet.</p></div>
    <button type="button" class="ghost" id="resolveBtn" style="margin-top:.9rem">
      Resolve any readings whose measurement has arrived
    </button>
    <p class="hint">Resolving copies the outcome from the measurement itself. Nobody chooses it.</p>
  </div>
</main>

<script>
const API = 'reading-api.php';
const $ = s => document.querySelector(s);
let DIR = null, SAW = null, POINTS = {};

function msg(text, kind){
  const m = $('#msg'); m.textContent = text; m.className = 'msg ' + kind;
  if (kind === 'ok') setTimeout(()=>{ m.className='msg'; }, 6000);
}

async function call(action, method, body){
  const opt = { method, headers:{'Content-Type':'application/json'} };
  if (body) opt.body = JSON.stringify(body);
  const r = await fetch(API + '?action=' + action, opt);
  return r.json();
}

function chipGroup(sel, set){
  document.querySelectorAll(sel + ' .chip').forEach(b => {
    b.addEventListener('click', () => {
      document.querySelectorAll(sel + ' .chip').forEach(x => x.setAttribute('aria-pressed','false'));
      b.setAttribute('aria-pressed','true');
      set(b.dataset.v);
    });
  });
}
chipGroup('#dir', v => DIR = v);
chipGroup('#saw', v => SAW = v);

$('#source').addEventListener('change', e => {
  $('#pointField').classList.toggle('hidden', e.target.value !== 'redikall_reading');
});

$('#point').addEventListener('change', e => {
  const code = e.target.value;
  const box = $('#keyword');
  if (!code || !POINTS[code]) { box.classList.add('hidden'); return; }
  const p = POINTS[code];
  box.innerHTML = '<strong>' + p.keyword.replace(/</g,'&lt;') + '</strong>' +
    '<span class="pos">' + p.position.replace(/</g,'&lt;') + '</span>';
  box.classList.remove('hidden');
});

async function loadSetup(){
  const d = await call('setup','GET');
  if (!d.ok) { msg(d.error || 'Could not load.','err'); return; }

  const m = $('#marker');
  if (!d.markers.length) {
    m.innerHTML = '<option value="">No measure has a baseline yet</option>';
    $('#submit').disabled = true;
    msg('No measure has a personal baseline yet, so nothing can be predicted. A baseline has to exist first.','err');
  } else {
    d.markers.forEach(x => {
      const o = document.createElement('option');
      o.value = x.marker_key;
      o.textContent = (x.name || x.marker_key) + (x.unit_text ? ' (' + x.unit_text + ')' : '');
      m.appendChild(o);
    });
  }

  const sel = $('#point');
  Object.keys(d.points).forEach(region => {
    const g = document.createElement('optgroup');
    g.label = region.replace(/_/g,' ');
    d.points[region].forEach(p => {
      POINTS[p.code] = p;
      const o = document.createElement('option');
      o.value = p.code;
      o.textContent = p.code + ' — ' + p.position;
      g.appendChild(o);
    });
    sel.appendChild(g);
  });

  if (d.already_today) {
    msg('A reading is already locked for today.','ok');
  }
}

async function loadProgress(){
  const d = await call('progress','GET');
  const box = $('#progress');
  if (!d.ok || !d.progress.length) { box.innerHTML = '<p class="hint">Nothing counted yet.</p>'; return; }
  const ul = document.createElement('ul');
  d.progress.forEach(p => {
    const pct = Math.min(100, Math.round(100 * p.valid_pairs / 32));
    const li = document.createElement('li');
    li.innerHTML =
      '<strong>' + p.prediction_source.replace(/_/g,' ') + '</strong> · ' + p.predicted_marker_key +
      '<div class="bar"><i style="width:' + pct + '%"></i></div>' +
      '<div class="meta">' + p.valid_pairs + ' of 32 counted · ' +
      p.hits + ' hit · ' + p.power_status + '</div>';
    ul.appendChild(li);
  });
  box.innerHTML = ''; box.appendChild(ul);
}

$('#resolveBtn').addEventListener('click', async () => {
  const d = await call('resolve','POST',{});
  if (!d.ok) { msg(d.error || 'Could not resolve.','err'); return; }
  msg(d.resolved ? (d.resolved + ' reading(s) resolved from the measurements.')
                 : (d.note || 'Nothing to resolve yet.'), 'ok');
  loadProgress();
});

$('#form').addEventListener('submit', async e => {
  e.preventDefault();
  const source = $('#source').value;
  if (!source)  return msg('Say who is making this reading.','err');
  if (source === 'redikall_reading' && !$('#point').value) return msg('Choose the point you are reading.','err');
  if (!$('#marker').value) return msg('Choose what should move.','err');
  if (!DIR) return msg('Say which way you expect it to move.','err');
  if (!SAW) return msg('Please answer whether you have seen today’s numbers.','err');

  $('#submit').disabled = true;
  const d = await call('predict','POST',{
    prediction_source: source,
    chakra_code: $('#point').value || null,
    predicted_marker_key: $('#marker').value,
    predicted_direction: DIR,
    reader_saw_measurement: SAW,
    rationale: $('#rationale').value || null
  });
  $('#submit').disabled = false;

  if (!d.ok) { msg(d.error || 'That could not be recorded.','err'); return; }
  msg(d.counts
      ? 'Locked. It counts toward the test.'
      : 'Locked and recorded — but it will not count, because the numbers were already seen.', 'ok');
  $('#form').reset();
  $('#keyword').classList.add('hidden');
  $('#pointField').classList.add('hidden');
  document.querySelectorAll('.chip').forEach(x => x.setAttribute('aria-pressed','false'));
  DIR = null; SAW = null;
  loadProgress();
});

loadSetup();
loadProgress();
</script>
</body>
</html>
