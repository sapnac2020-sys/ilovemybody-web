<?php
declare(strict_types=1);
require __DIR__ . "/_guard.php";

/**
 * Record a body signal.
 *
 * The page never interprets what is recorded. It asks, it stores, it shows
 * back what was stored. Interpretation lives elsewhere and is governed by
 * ilb_feedback_safety_policy.
 *
 * The safety screen shown here is a courtesy to the person. The screen that
 * actually protects them is in signal-api.php, server side, where a modified
 * browser cannot reach it.
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
<title>Record a signal</title>
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
textarea{min-height:5rem;resize:vertical}
.field{margin-bottom:1.05rem}
.row{display:flex;gap:.7rem}.row>*{flex:1}
.opt{color:var(--soft);font-weight:400;font-size:.85rem}
.chips{display:flex;flex-wrap:wrap;gap:.4rem;margin-top:.15rem}
.chip{padding:.45rem .8rem;border:1px solid var(--line);border-radius:999px;
  background:var(--bg);cursor:pointer;font-size:.9rem}
.chip[aria-pressed="true"]{background:var(--accent-soft);border-color:var(--accent);
  color:var(--accent);font-weight:600}
.scale{display:flex;gap:.25rem}
.scale button{flex:1;padding:.5rem 0;border:1px solid var(--line);background:var(--bg);
  border-radius:8px;cursor:pointer;font:inherit;color:inherit}
.scale button[aria-pressed="true"]{background:var(--accent);border-color:var(--accent);color:#fff}
button.go{width:100%;padding:.85rem;background:var(--accent);color:#fff;border:0;
  border-radius:10px;font:inherit;font-weight:650;cursor:pointer}
button.go[disabled]{opacity:.55;cursor:default}
.ghost{background:transparent;border:1px solid var(--line);color:inherit;
  padding:.75rem 1rem;border-radius:10px;font:inherit;cursor:pointer}
.safety{background:var(--warn-bg);border:1px solid var(--warn);border-radius:var(--radius);
  padding:1.15rem;margin-bottom:1rem}
.safety h2{margin:0 0 .5rem;font-size:1.1rem;color:var(--warn)}
.res{border-top:1px solid var(--line);padding-top:.7rem;margin-top:.7rem}
.res b{display:block}
.res a{color:var(--accent);font-weight:650;font-size:1.15rem;text-decoration:none}
.msg{padding:.8rem 1rem;border-radius:10px;margin-bottom:1rem;display:none}
.msg.err{display:block;background:var(--accent-soft);color:var(--accent)}
.msg.ok{display:block;background:var(--card);border:1px solid var(--line)}
.recent li{list-style:none;padding:.6rem 0;border-top:1px solid var(--line)}
.recent ul{margin:0;padding:0}
.recent .when{color:var(--soft);font-size:.82rem}
.hidden{display:none}
</style>
</head>
<body>
<main class="wrap">
  <h1>Record a signal</h1>
  <p class="lede">Whatever the body did, <?= htmlspecialchars($name, ENT_QUOTES) ?>. No judgement, no interpretation &mdash; this page only writes it down.</p>

  <div id="msg" class="msg" role="status"></div>

  <div id="safety" class="safety hidden" role="alert">
    <h2>Before this is recorded</h2>
    <p id="safetyWhy"></p>
    <p>An app cannot tell you whether this is serious. A person can.</p>
    <div id="safetyRes"></div>
    <div style="display:flex;gap:.6rem;margin-top:1rem;flex-wrap:wrap">
      <button type="button" class="go" style="flex:1;min-width:12rem" id="ackBtn">I have read this &mdash; record it</button>
      <button type="button" class="ghost" id="cancelBtn">Not now</button>
    </div>
  </div>

  <form id="form" class="card" novalidate>
    <div class="field">
      <label for="type">What did you notice?</label>
      <select id="type" name="signal_type_key" required>
        <option value="">Choose one&hellip;</option>
      </select>
      <p class="hint" id="typePrompt"></p>
    </div>

    <div class="field">
      <label for="text">In your own words</label>
      <textarea id="text" name="signal_text" maxlength="500" required
        placeholder="What happened, as you would say it out loud"></textarea>
      <p class="hint"><span id="count">0</span>/500</p>
    </div>

    <div class="field">
      <label for="loc">Where in the body <span class="opt">optional</span></label>
      <input id="loc" name="body_location_text" maxlength="255"
        placeholder="Under the right ribs, left side of the head&hellip;">
    </div>

    <div class="row field">
      <div>
        <label for="observed">When did it start</label>
        <input id="observed" name="observed_at" type="datetime-local" required>
      </div>
      <div>
        <label for="ended">When it stopped <span class="opt">optional</span></label>
        <input id="ended" name="ended_at" type="datetime-local">
      </div>
    </div>

    <div class="field">
      <label>How strong, 0 to 10 <span class="opt">optional</span></label>
      <div class="scale" id="scale"></div>
      <p class="hint">Your own sense of it. This is not a measurement.</p>
    </div>

    <div class="field">
      <label for="freq">How often <span class="opt">optional</span></label>
      <input id="freq" name="frequency_pattern" maxlength="255"
        placeholder="Comes in waves, every morning, first time&hellip;">
    </div>

    <div class="field">
      <label for="context">What was happening just before <span class="opt">optional</span></label>
      <textarea id="context" name="preceding_context_text"
        placeholder="Food, a conversation, waking, effort &mdash; anything you remember"></textarea>
    </div>

    <div class="field">
      <label>Has this happened before?</label>
      <div class="chips" id="fam" role="group"></div>
    </div>

    <div class="field">
      <label>How worried are you?</label>
      <div class="chips" id="concern" role="group"></div>
      <p class="hint">Saying you are worried is always heard. It is not a diagnosis either way.</p>
    </div>

    <button class="go" id="submit" type="submit">Record it</button>
  </form>

  <section class="card recent">
    <h2 style="font-size:1rem;margin:0 0 .3rem">Recently recorded</h2>
    <p class="hint" style="margin:0 0 .4rem">Only yours. Nothing here is shared.</p>
    <ul id="recent"></ul>
  </section>
</main>

<script>
const API = <?= json_encode($base . '/signal-api.php', JSON_UNESCAPED_SLASHES) ?>;

const GROUPS = {
  protective_reflex:'Protective reflexes', digestive:'Digestion',
  autonomic:'Breath and heart', energy_recovery:'Energy and rest',
  immune_inflammatory:'Immune and inflammation', neurological_sensory:'Nerves and senses',
  skin_hair_nail:'Skin, hair and nails', sexual_reproductive:'Sexual and reproductive',
  emotional:'Emotions', cognitive:'Thinking', behavioural:'What you did with it',
  functional:'Daily function', objective_silent:'Things with no feeling'
};
const FAM = {new:'First time', familiar:'Happened before', changed:'Different this time', unsure:'Not sure'};
const CONCERN = {none:'Not worried', low:'A little', moderate:'Somewhat', high:'Quite', urgent:'Very'};

const $ = s => document.querySelector(s);
let types = {}, state = {intensity:'', familiarity:'unsure', concern:'none'}, pendingAck = false;

function esc(s){ const d=document.createElement('div'); d.textContent = s==null?'':String(s); return d.innerHTML; }
function say(text, kind){ const m=$('#msg'); m.className='msg '+kind; m.textContent=text;
  if(kind) m.scrollIntoView({block:'nearest',behavior:'smooth'}); }

/* local datetime-local value, not UTC */
function localNow(){ const d=new Date(); d.setMinutes(d.getMinutes()-d.getTimezoneOffset());
  return d.toISOString().slice(0,16); }

function chips(el, map, key){
  el.innerHTML = '';
  Object.entries(map).forEach(([v,label]) => {
    const b = document.createElement('button');
    b.type='button'; b.className='chip'; b.textContent=label;
    b.setAttribute('aria-pressed', String(state[key]===v));
    b.onclick = () => { state[key]=v; chips(el,map,key); };
    el.appendChild(b);
  });
}

function scale(){
  const el=$('#scale'); el.innerHTML='';
  for(let i=0;i<=10;i++){
    const b=document.createElement('button');
    b.type='button'; b.textContent=i;
    b.setAttribute('aria-pressed', String(state.intensity===i));
    b.onclick = () => { state.intensity = (state.intensity===i) ? '' : i; scale(); };
    el.appendChild(b);
  }
}

async function loadTypes(){
  const r = await fetch(API+'?action=types', {credentials:'same-origin'});
  const j = await r.json();
  if(!j.ok) return say(j.error || 'Could not load the list.', 'err');
  types = {};
  const sel = $('#type');
  Object.entries(j.groups).forEach(([g, list]) => {
    const og = document.createElement('optgroup');
    og.label = GROUPS[g] || g.replace(/_/g,' ');
    list.forEach(t => {
      types[t.key] = t;
      const o = document.createElement('option');
      o.value = t.key; o.textContent = t.name;
      og.appendChild(o);
    });
    sel.appendChild(og);
  });
}

async function loadRecent(){
  const r = await fetch(API+'?action=recent', {credentials:'same-origin'});
  const j = await r.json();
  const ul = $('#recent');
  if(!j.ok || !j.events.length){ ul.innerHTML = '<li class="when">Nothing yet.</li>'; return; }
  ul.innerHTML = j.events.map(e =>
    '<li><b>'+esc(e.display_name)+'</b>'
    + (e.intensity_score!==null ? ' <span class="when">'+esc(e.intensity_score)+'/10</span>' : '')
    + '<br>'+esc(e.signal_text)
    + (e.body_location_text ? ' <span class="when">&mdash; '+esc(e.body_location_text)+'</span>' : '')
    + '<br><span class="when">'+esc(e.observed_at)+'</span></li>'
  ).join('');
}

function showSafety(j){
  $('#safetyWhy').textContent =
    'You recorded ' + j.signal_name.toLowerCase() + '. Signals like this one are worth having looked at.';
  $('#safetyRes').innerHTML = j.resources.map(r =>
    '<div class="res"><b>'+esc(r.resource_name)+'</b>'
    + '<a href="tel:'+esc(r.phone_primary)+'">'+esc(r.phone_primary)+'</a>'
    + (r.phone_alternate ? ' <span class="when">or '+esc(r.phone_alternate)+'</span>' : '')
    + '<div class="when">'+esc(r.operator_name)+' &middot; '+esc(r.hours_text)
    + (r.cost_text ? ' &middot; '+esc(r.cost_text) : '') + '</div></div>'
  ).join('');
  $('#safety').classList.remove('hidden');
  $('#safety').scrollIntoView({behavior:'smooth', block:'start'});
  pendingAck = true;
}

function payload(ack){
  return {
    signal_type_key: $('#type').value,
    signal_text: $('#text').value,
    body_location_text: $('#loc').value,
    observed_at: $('#observed').value,
    ended_at: $('#ended').value,
    intensity_score: state.intensity,
    frequency_pattern: $('#freq').value,
    preceding_context_text: $('#context').value,
    familiarity: state.familiarity,
    participant_concern: state.concern,
    safety_acknowledged: !!ack
  };
}

async function send(ack){
  $('#submit').disabled = true;
  try{
    const r = await fetch(API+'?action=save', {
      method:'POST', credentials:'same-origin',
      headers:{'Content-Type':'application/json'},
      body: JSON.stringify(payload(ack))
    });
    const j = await r.json();

    if(j.safety){ showSafety(j); say('', ''); return; }
    if(!j.ok){ say(j.error || 'That could not be saved.', 'err'); return; }

    $('#safety').classList.add('hidden'); pendingAck = false;
    $('#form').reset();
    state = {intensity:'', familiarity:'unsure', concern:'none'};
    chips($('#fam'), FAM, 'familiarity'); chips($('#concern'), CONCERN, 'concern'); scale();
    $('#observed').value = localNow(); $('#count').textContent = '0'; $('#typePrompt').textContent='';
    say(j.safety_raised
      ? 'Recorded, and flagged for a person to look at.'
      : 'Recorded.', 'ok');
    loadRecent();
  } catch(e){
    say('The connection dropped. Nothing was saved.', 'err');
  } finally {
    $('#submit').disabled = false;
  }
}

$('#type').addEventListener('change', e => {
  const t = types[e.target.value];
  $('#typePrompt').textContent = t ? t.prompt : '';
});
$('#text').addEventListener('input', e => { $('#count').textContent = e.target.value.length; });
$('#form').addEventListener('submit', e => { e.preventDefault(); send(pendingAck); });
$('#ackBtn').onclick = () => send(true);
$('#cancelBtn').onclick = () => {
  $('#safety').classList.add('hidden'); pendingAck = false;
  say('Nothing was recorded. It is still there when you want it.', 'ok');
};

$('#observed').value = localNow();
chips($('#fam'), FAM, 'familiarity');
chips($('#concern'), CONCERN, 'concern');
scale();
loadTypes();
loadRecent();
</script>
</body>
</html>
