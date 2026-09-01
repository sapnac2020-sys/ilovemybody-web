<!doctype html>
<html lang="en"><head>
 <meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1,viewport-fit=cover">
 <meta name="robots" content="noindex,nofollow,noarchive"><meta name="theme-color" content="#09070b">
 <title>My Happy Space · I Love My Body</title>
 <link rel="preconnect" href="https://fonts.googleapis.com"><link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
 <link href="https://fonts.googleapis.com/css2?family=Cormorant+Garamond:ital,wght@0,500;0,600;1,500;1,600&family=DM+Sans:wght@400;500;600;700&family=Playfair+Display:ital,wght@0,500;1,500&display=swap" rel="stylesheet">
 <link rel="stylesheet" href="assets/app.css?v=60">
</head><body>
<div id="gate" class="boot-card">Opening your private space…</div>

<main id="loginShell" class="login-shell" hidden>
 <section class="login-brand"><div><p class="eyebrow">I LOVE MY BODY · MY HAPPY SPACE</p><h1>Your health story,<br><em>connected.</em></h1><p class="login-purpose">Understand where you are, what may be affecting you and what helps—without changing your current medical treatment.</p><div class="who-row"><span>Living with an illness</span><span>Anxious or stressed</span><span>Struggling with addiction</span><span>Seeking direction</span></div><div class="login-flow"><div><i>1</i><b>Share</b><span>Reports and medicines</span></div><div><i>2</i><b>Understand</b><span>10 guided assessment days</span></div><div><i>3</i><b>Begin</b><span>Your 7-week journey</span></div></div><button id="exploreJourney" class="primary explore-cta" type="button">I am new — show me how it works <span>→</span></button></div><small>EVERYTHING IS CONNECTED.</small></section>
 <form id="login" class="login-card"><p class="eyebrow">RETURNING PATIENT</p><h2>Enter your<br><em>space.</em></h2><p class="muted">Continue your private journey.</p><label class="field">Mobile number<input id="loginMobile" inputmode="tel" autocomplete="tel" maxlength="15" required></label><label class="field">6-digit PIN<input id="loginPin" inputmode="numeric" pattern="[0-9]{6}" maxlength="6" autocomplete="current-password" required></label><button class="primary" type="submit">Enter my space <span>→</span></button><button class="browse-btn" id="browseApp" type="button">Preview the patient journey <span>→</span></button><small class="browse-note">No login is needed to preview.</small><p id="loginError" class="error" role="alert"></p></form>
</main>

<div id="app" class="app-shell" hidden>
 <aside class="side">
  <button class="brand-mark" data-view="today" data-tip="Dashboard">♥</button>
  <nav class="patient-rail" aria-label="My tools">
   <button class="active" data-view="today" data-tip="My dashboard" aria-label="My dashboard">⌂</button>
   <button data-view="records" data-tip="My records" aria-label="My records">▤</button>
   <button data-view="checkin" data-tip="Check in" aria-label="Check in">✓</button>
   <button data-view="journal" data-tip="My journal" aria-label="My journal">✎</button>
   <button data-view="view" data-tip="Display settings" aria-label="Display settings">Aa</button>
  </nav>
  <button id="logoutHint" class="rail-person" data-tip="Private profile"><i>●</i><span id="caseLabel">PRIVATE</span></button>
 </aside>

 <header class="topbar"><div class="wordmark"><b>I Love My Body</b><small>MY HAPPY SPACE</small></div><div class="phase-mini"><span id="phaseLabel">STARTING POINT</span><b id="phaseProgress"><i></i></b></div><button id="previewSignIn" class="preview-signin" hidden>Sign in to save</button><button data-view="view" class="profile-chip"><span id="mobileCaseLabel">My view</span><i>●</i></button></header>

 <main class="workspace">
  <header class="workspace-head"><div><p class="eyebrow" id="viewEyebrow">TODAY</p><h1 id="viewTitle">Good morning, <em id="personName">friend.</em></h1></div><div class="date-chip"><b id="todayDate"></b><small>YOUR DAY</small></div></header>

  <section class="view active dashboard" data-view-panel="today">
   <div class="journey-map" aria-label="Your complete journey">
    <span class="active"><b>1</b>Medical picture</span><i>→</i>
    <span><b>2</b>10-day assessment</span><i>→</i>
    <span><b>3</b>Connected summary</span><i>→</i>
    <span><b>4</b>7-week journey</span><i>→</i>
    <span><b>5</b>2-day review</span><i>→</i>
    <span><b>6</b>Finish or continue</span>
   </div>
   <div class="dashboard-grid">
    <article class="current-step">
     <p class="eyebrow">YOUR CURRENT STEP · 1 OF 6</p>
     <h2>Build your medical picture</h2>
     <p class="step-purpose">This gives us a factual starting point before we ask about the rest of your life.</p>
     <div class="step-requirements">
      <span><i>1</i>Upload the reports you already have</span>
      <span><i>2</i>Add current prescriptions and medicines</span>
      <span><i>3</i>Confirm that your available records are complete</span>
     </div>
     <button class="primary" data-go="records">Add my available records <span>→</span></button>
     <small>Missing documents are allowed. You can return and add them later.</small>
    </article>
    <aside class="expect-panel">
     <p class="eyebrow">WHAT TO EXPECT</p>
     <h3>Your journey, explained</h3>
     <dl>
      <div><dt>Why this matters</dt><dd>We compare future change with a clear beginning.</dd></div>
      <div><dt>This step is complete when</dt><dd>You confirm that you have added everything currently available.</dd></div>
      <div><dt>What happens next</dt><dd>One short guided assessment each day for ten days.</dd></div>
      <div><dt>Total pathway</dt><dd>10 days → 7 weeks → 2-day review → optional 7 weeks.</dd></div>
     </dl>
    </aside>
   </div>
   <div class="dashboard-tools" aria-label="Optional tools"><span>Optional today</span><button data-go="checkin">Check in</button><button data-go="journal">Write in my journal</button><button data-go="view">Change my display</button></div>
  </section>

  <section class="view" data-view-panel="start">
   <div class="begin-card">
    <div class="begin-copy"><p class="eyebrow">LET US BEGIN GENTLY</p><h2>What would you like to share <em>first?</em></h2><p>Start with what you already have. You can stop and return at any time.</p></div>
    <div class="begin-actions"><button class="primary" data-go="records">I have a report or prescription <span>→</span></button><button class="quiet" data-go="checkin">I want to tell you how I feel <span>→</span></button></div>
    <div class="next-note"><b>That is all for now.</b><span>After this, we will guide you one small step at a time.</span></div>
   </div>
  </section>

  <form id="checkin">
   <section class="view" data-view-panel="checkin">
    <div class="section-intro"><div><p class="eyebrow">DAILY CHECK-IN</p><h2>What is your body <em>telling you?</em></h2></div><p>Choose only what feels relevant now. You may return at any time.</p></div>
    <div class="step-tabs"><button type="button" class="active" data-check-step="feel">Feel</button><button type="button" data-check-step="body">Body</button><button type="button" data-check-step="food">Food</button><button type="button" data-check-step="action">Action</button></div>
    <div class="check-step active" data-check-panel="feel"><div class="score-grid"><label><span>Happiness</span><output>5</output><input name="state.happiness" type="range" min="0" max="10" value="5"></label><label><span>Energy</span><output>5</output><input name="state.energy" type="range" min="0" max="10" value="5"></label><label><span>Calm</span><output>5</output><input name="state.calm" type="range" min="0" max="10" value="5"></label><label><span>Connection</span><output>5</output><input name="state.connection" type="range" min="0" max="10" value="5"></label></div><div class="question-grid"><label class="field">What do you feel?<input name="mind.emotion" placeholder="One word is enough"></label><label class="field">What happened before it?<input name="mind.event" placeholder="A person, place, event or memory"></label></div></div>
    <div class="check-step" data-check-panel="body"><div class="score-grid"><label><span>Discomfort</span><output>0</output><input name="state.discomfort" type="range" min="0" max="10" value="0"></label><label><span>Stress</span><output>5</output><input name="state.stress" type="range" min="0" max="10" value="5"></label><label><span>Anger</span><output>0</output><input name="mind.anger" type="range" min="0" max="10" value="0"></label><label><span>Sense of control</span><output>5</output><input name="mind.control" type="range" min="0" max="10" value="5"></label></div><div class="metric-grid"><label><span>Sleep</span><input name="behaviour.sleep_minutes" inputmode="numeric" placeholder="—"><b>minutes</b></label><label><span>Movement</span><input name="behaviour.movement_minutes" inputmode="numeric" placeholder="—"><b>minutes</b></label></div><button class="outline-btn" type="button" id="measureToggle">＋ Add glucose, blood pressure, pulse or weight</button><div id="measureBox" class="measurement-grid" hidden><label>Fasting glucose<input name="measurements.fasting_glucose" inputmode="decimal" placeholder="mg/dL"></label><label>Other glucose<input name="measurements.other_glucose" inputmode="decimal" placeholder="mg/dL"></label><label>BP upper<input name="measurements.systolic_bp" inputmode="numeric" placeholder="mmHg"></label><label>BP lower<input name="measurements.diastolic_bp" inputmode="numeric" placeholder="mmHg"></label><label>Pulse<input name="measurements.pulse" inputmode="numeric" placeholder="beats/min"></label><label>Weight<input name="measurements.weight" inputmode="decimal" placeholder="kg"></label></div><h3 class="subhead">Medicines today</h3><p class="muted">A record only. This app never changes a prescription.</p><div id="medicineList"></div></div>
    <div class="check-step" data-check-panel="food"><p class="gentle-note">A food photograph is optional. You can simply name what you ate—or skip food today.</p><div id="foodList"></div><button class="outline-btn" type="button" id="addFood">＋ Add food or drink</button></div>
    <div class="check-step" data-check-panel="action"><div class="question-grid"><label class="field wide">What action did you take for yourself today?<textarea name="state.affecting" rows="4" placeholder="Rest, movement, expression, conversation, work, food—or something else"></textarea></label><label class="field wide">What might help tomorrow?<textarea name="state.better" rows="4" placeholder="A small loving choice is enough"></textarea></label></div><div class="safety"><b>Do any of these need urgent attention?</b><div><label><input type="checkbox" name="safety.chest_pain"> New or severe chest pain</label><label><input type="checkbox" name="safety.breathing_difficulty"> Serious difficulty breathing</label><label><input type="checkbox" name="safety.fainting"> Fainting</label><label><input type="checkbox" name="safety.sudden_weakness"> Sudden weakness or speech difficulty</label><label><input type="checkbox" name="safety.confusion"> New confusion</label></div><p>If any apply, do not wait for this app. Seek urgent medical help.</p></div></div>
    <div class="savebar"><span>Saved privately when you complete the check-in</span><button type="submit" id="submit" class="primary">Complete check-in →</button></div>
   </section>
  </form>

  <section class="view" data-view-panel="journal">
   <div class="journal-layout"><div><p class="eyebrow">PRIVATE JOURNAL</p><h2>Write without <em>judgement.</em></h2><p>Express a thought, memory, desire, question or moment. It can be one line.</p><div class="prompt-chips"><button data-prompt="What am I carrying today?">What am I carrying?</button><button data-prompt="What gave me energy today?">What gave me energy?</button><button data-prompt="What do I need but have not said?">What remains unsaid?</button><button data-prompt="What choice would be led by love?">A love-led choice?</button></div></div><form id="journalForm" class="journal-paper"><label for="journalText" id="journalPrompt">What would you like to say?</label><textarea id="journalText" rows="12" placeholder="Begin anywhere…"></textarea><div><small id="journalState">Private draft saved on this device</small><button class="primary" type="submit">Save today’s reflection →</button></div></form></div>
  </section>

  <section class="view" data-view-panel="journey">
   <div class="section-intro"><div><p class="eyebrow">YOUR JOURNEY</p><h2>Understand. Act. <em>Observe.</em></h2></div><p>Every journey is personal. The second seven weeks is not automatic; it follows the two-day review.</p></div>
   <div class="journey-track"><article class="active"><i>01</i><b>Starting point</b><strong>10 days</strong><span>Reports, medicines, lived experience and assessments across ten dimensions.</span></article><article><i>02</i><b>First journey</b><strong>7 weeks</strong><span>Small love-led actions, daily observation and selected support.</span></article><article><i>03</i><b>Review</b><strong>2 days</strong><span>Repeat relevant reports and assessments; compare like with like.</span></article><article><i>04</i><b>Continue</b><strong>7 weeks</strong><span>Only if useful, with a refined direction based on what was learned.</span></article></div>
   <div class="source-row"><button data-source="food_chemical_energy"><b>Food chemistry</b><span>See source →</span></button><button data-source="food_personal_response"><b>Personal response</b><span>See source →</span></button><button data-source="clinical_checkpoint"><b>Clinical comparison</b><span>See source →</span></button></div>
  </section>

  <section class="view" data-view-panel="records">
   <div class="section-intro"><div><p class="eyebrow">PRIVATE RECORDS</p><h2>Your medical <em>starting point.</em></h2></div><p>Upload new reports and prescriptions, see existing documents, and maintain your current medicine record.</p></div><div class="record-actions"><label class="upload"><b>Upload report</b><small>PDF or photograph</small><input type="file" accept="application/pdf,image/*" capture="environment" data-upload="laboratory_report"></label><label class="upload"><b>Upload prescription</b><small>PDF or photograph</small><input type="file" accept="application/pdf,image/*" capture="environment" data-upload="prescription"></label><button id="addMedicine"><b>Add medicine</b><small>Name, label and photograph</small></button><a class="upload" href="test-results.php"><b>Add test values</b><small>Keep name, unit and range exactly</small></a></div><div class="records-grid"><section><h3>Existing reports</h3><div id="documentList"></div></section><section><h3>Medicines</h3><div id="medicineRecords"></div></section></div>
  </section>

  <section class="view" data-view-panel="view">
   <div class="section-intro"><div><p class="eyebrow">MY VIEW</p><h2>Make this space <em>yours.</em></h2></div><p>Choose one accent, one background and a comfortable text size. Your choices are remembered on this device.</p></div><div class="preference-grid"><section><h3>Accent colour</h3><div id="themeChoices" class="theme-choices"></div></section><section><h3>Background colour</h3><div class="background-choices"><button data-background="light"><i></i><span>Soft light</span></button><button data-background="tint"><i></i><span>Colour wash</span></button><button data-background="dark"><i></i><span>Soft dark</span></button></div></section><section><h3>Text size</h3><div class="option-tabs"><button data-size="compact">Compact</button><button data-size="comfortable">Comfortable</button><button data-size="large">Large</button></div></section></div>
  </section>

  <section class="view completion" data-view-panel="done"><i>✓</i><p class="eyebrow">TODAY IS RECORDED</p><h2>Thank you for listening<br><em>to your body.</em></h2><button class="primary" data-go="today">Return home →</button></section>
 </main>

 <nav class="bottom-nav" aria-label="Mobile navigation"><button data-view="today">Dashboard</button><button data-view="checkin">Check-in</button><button data-view="journal">Journal</button><button data-view="records">Reports</button></nav>
</div>

<section id="medicineEditor" class="sheet" hidden><div class="sheet-card"><button class="close" aria-label="Close">×</button><p class="eyebrow">MEDICINE RECORD</p><h2 id="editorTitle">Add medicine</h2><input type="hidden" id="editId"><label class="field">Name on label<input id="editName"></label><label class="field">Strength/composition<input id="editStrength"></label><label class="field">Dose taken<input id="editDose"></label><label class="field">How often<input id="editFrequency"></label><label class="field">Usual time<input id="editTime"></label><button class="primary" id="saveMedicine">Save medicine</button><label class="upload mini"><b>Take or upload medicine photo</b><input id="medicinePhoto" type="file" accept="image/*" capture="environment"></label></div></section>
<section id="sourceSheet" class="sheet" hidden><div class="sheet-card source-card"><button class="close" aria-label="Close">×</button><p class="eyebrow">SOURCE + BOUNDARY</p><div id="sourceContent"></div></div></section>

<template id="foodTemplate"><article class="food-card"><header><div><b>Food or drink</b><small>Only what you wish to record</small></div><button type="button" class="remove-food">Remove</button></header><div class="food-questions"><fieldset><legend>WHEN?</legend><div class="tabs"><label><input data-food="type" type="radio" value="breakfast"><span>Morning</span></label><label><input data-food="type" type="radio" value="lunch"><span>Lunch</span></label><label><input data-food="type" type="radio" value="snack"><span>Evening</span></label><label><input data-food="type" type="radio" value="dinner"><span>Dinner</span></label><label><input data-food="type" type="radio" value="other"><span>Late</span></label></div></fieldset><fieldset><legend>WHERE?</legend><div class="tabs"><label><input data-food="where" type="radio" value="home"><span>Home</span></label><label><input data-food="where" type="radio" value="work"><span>Work</span></label><label><input data-food="where" type="radio" value="restaurant"><span>Out</span></label><label><input data-food="where" type="radio" value="travel"><span>Travel</span></label></div></fieldset><fieldset class="wide"><legend>WHAT?</legend><input class="quick-text" data-food="detail" placeholder="Food or drink name"><div class="tabs"><label><input data-food="what" type="radio" value="home meal"><span>Home meal</span></label><label><input data-food="what" type="radio" value="outside meal"><span>Outside</span></label><label><input data-food="what" type="radio" value="snack"><span>Snack</span></label><label><input data-food="what" type="radio" value="sweet"><span>Sweet</span></label><label><input data-food="what" type="radio" value="drink"><span>Drink</span></label></div></fieldset><fieldset><legend>WHY?</legend><div class="tabs"><label><input data-food="reason" type="radio" value="physical hunger"><span>Hungry</span></label><label><input data-food="reason" type="radio" value="usual meal time"><span>Routine</span></label><label><input data-food="reason" type="radio" value="craving"><span>Craving</span></label><label><input data-food="reason" type="radio" value="stress or emotion"><span>Emotion</span></label><label><input data-food="reason" type="radio" value="social occasion"><span>Social</span></label></div></fieldset><fieldset><legend>WITH WHOM?</legend><div class="tabs"><label><input data-food="with_whom" type="radio" value="alone"><span>Alone</span></label><label><input data-food="with_whom" type="radio" value="family"><span>Family</span></label><label><input data-food="with_whom" type="radio" value="friends"><span>Friends</span></label><label><input data-food="with_whom" type="radio" value="colleagues"><span>Colleagues</span></label></div></fieldset><fieldset class="wide"><legend>HOW DID IT FEEL?</legend><div class="tabs feel-tabs"><label><input data-food="response" type="radio" value="light"><span>Light</span></label><label><input data-food="response" type="radio" value="satisfied"><span>Satisfied</span></label><label><input data-food="response" type="radio" value="energetic"><span>Energetic</span></label><label><input data-food="response" type="radio" value="sleepy"><span>Sleepy</span></label><label><input data-food="response" type="radio" value="heavy"><span>Heavy</span></label><label><input data-food="response" type="radio" value="bloated"><span>Bloated</span></label><label><input data-food="response" type="radio" value="no noticeable change"><span>No change</span></label></div></fieldset></div></article></template>
<script src="assets/app.js?v=60"></script></body></html>
