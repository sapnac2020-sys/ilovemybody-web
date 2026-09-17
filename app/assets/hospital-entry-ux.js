(()=>{'use strict';
function ready(fn){if(document.readyState==='loading')document.addEventListener('DOMContentLoaded',fn);else fn();}
ready(()=>{
  const shell=document.getElementById('loginShell');
  const legacy=document.getElementById('login');
  const brand=shell?.querySelector('.login-brand');
  if(!shell||!legacy||document.getElementById('hospitalEntry'))return;

  legacy.style.display='none';
  if(brand){
    const purpose=brand.querySelector('.login-purpose');
    if(purpose) purpose.textContent='See your medical story, understand what each treatment is doing, add your own measurements and explore how your body is changing — one private journey, in one place.';
    const h1=brand.querySelector('h1');
    if(h1) h1.innerHTML='Your body.<br><em>Your journey.</em>';
    const flow=brand.querySelector('.login-flow');
    if(flow) flow.innerHTML='<div><i>1</i><b>Enter</b><span>Use your Patient ID</span></div><div><i>2</i><b>Explore</b><span>Your body, reports and medicines</span></div><div><i>3</i><b>Track</b><span>See what changes over time</span></div>';
  }

  const card=document.createElement('section');
  card.id='hospitalEntry';
  card.className='login-card hospital-entry';
  card.innerHTML=`
    <div class="entry-head">
      <p class="eyebrow">I LOVE MY BODY · PRIVATE PATIENT SPACE</p>
      <h2>How would you like to enter?</h2>
      <p class="entry-intro">A first-time patient should not need a mobile PIN. Use the Patient ID and password given by the hospital. Mobile + PIN is only a returning-patient convenience.</p>
    </div>
    <div class="entry-tabs" role="tablist" aria-label="Sign-in method">
      <button type="button" class="active" data-entry-tab="id">Patient ID</button>
      <button type="button" data-entry-tab="mobile">Mobile + PIN</button>
    </div>
    <form id="patientIdLogin" class="entry-panel active" data-entry-panel="id" method="post" novalidate>
      <div class="entry-badge">FIRST VISIT / PATIENT DASHBOARD</div>
      <label class="field">Patient ID<input id="patientId" name="user_id" autocomplete="username" autocapitalize="none" spellcheck="false" placeholder="e.g. nilesh" required></label>
      <label class="field">Password<input id="patientPassword" name="password" type="password" autocomplete="current-password" placeholder="Hospital-issued password" required></label>
      <button class="primary" type="submit">Open my private dashboard <span>→</span></button>
      <p id="patientIdError" class="error" role="alert"></p>
      <small class="entry-help">Your Patient ID opens your own private dashboard. You can add a mobile number and PIN later if you want faster sign-in.</small>
    </form>
    <form id="mobilePinLogin" class="entry-panel" data-entry-panel="mobile" novalidate>
      <div class="entry-badge secondary">RETURNING PATIENT</div>
      <label class="field">Mobile number<input id="entryMobile" inputmode="tel" autocomplete="tel" maxlength="15" placeholder="Registered mobile number" required></label>
      <label class="field">6-digit PIN<input id="entryPin" inputmode="numeric" pattern="[0-9]{6}" maxlength="6" autocomplete="current-password" placeholder="6 digits" required></label>
      <button class="primary" type="submit">Continue my existing journey <span>→</span></button>
      <p id="entryMobileError" class="error" role="alert"></p>
      <small class="entry-help">Use this only if you have already set up a mobile number and 6-digit PIN.</small>
    </form>
    <div class="entry-divider"><span>or</span></div>
    <button id="entryPreview" class="browse-btn" type="button">Explore the hospital journey without signing in <span>→</span></button>
    <small class="browse-note">You can understand the experience before sharing any personal information.</small>
    <div class="privacy-strip"><b>Private by design</b><span>Your medical information is not shown on the public hospital website.</span></div>`;
  legacy.insertAdjacentElement('afterend',card);

  const css=document.createElement('style');
  css.textContent=`
    .hospital-entry{align-self:center}.hospital-entry h2{margin-bottom:8px}.entry-intro{font-size:.88rem;line-height:1.55;margin:0 0 16px;color:var(--muted)}
    .entry-tabs{display:grid;grid-template-columns:1fr 1fr;gap:5px;padding:5px;background:var(--paper);border:1px solid var(--line);border-radius:12px;margin:0 0 16px}
    .entry-tabs button{border:0;background:transparent;border-radius:8px;padding:10px 8px;font:700 .78rem var(--sans);color:var(--muted);cursor:pointer}.entry-tabs button.active{background:#fff;color:var(--ink);box-shadow:0 1px 7px rgba(0,0,0,.08)}
    .entry-panel{display:none}.entry-panel.active{display:block}.entry-badge{display:inline-flex;padding:5px 8px;border-radius:999px;background:rgba(var(--neon-rgb),.11);color:var(--ink);font-size:.65rem;font-weight:800;letter-spacing:.06em;margin-bottom:6px}.entry-badge.secondary{background:var(--paper);color:var(--muted)}
    .entry-help{display:block;margin-top:10px;line-height:1.45;color:var(--muted)}.entry-divider{display:flex;align-items:center;gap:10px;margin:18px 0 12px;color:var(--muted);font-size:.7rem}.entry-divider:before,.entry-divider:after{content:'';height:1px;background:var(--line);flex:1}
    .privacy-strip{display:grid;grid-template-columns:auto 1fr;gap:8px 12px;margin-top:16px;padding:12px;border-radius:11px;background:var(--paper);border:1px solid var(--line);font-size:.72rem}.privacy-strip b{white-space:nowrap}.privacy-strip span{color:var(--muted);line-height:1.45}
    @media(max-width:760px){.entry-tabs{grid-template-columns:1fr 1fr}.privacy-strip{grid-template-columns:1fr}.hospital-entry{margin-top:0}}
  `;
  document.head.appendChild(css);

  card.querySelectorAll('[data-entry-tab]').forEach(btn=>btn.addEventListener('click',()=>{
    card.querySelectorAll('[data-entry-tab]').forEach(x=>x.classList.toggle('active',x===btn));
    card.querySelectorAll('[data-entry-panel]').forEach(x=>x.classList.toggle('active',x.dataset.entryPanel===btn.dataset.entryTab));
    const focus=btn.dataset.entryTab==='id'?document.getElementById('patientId'):document.getElementById('entryMobile');
    setTimeout(()=>focus?.focus(),50);
  }));

  document.getElementById('patientIdLogin')?.addEventListener('submit',e=>{
    e.preventDefault();
    const id=(document.getElementById('patientId')?.value||'').trim().toLowerCase();
    const pw=document.getElementById('patientPassword')?.value||'';
    const err=document.getElementById('patientIdError');
    if(!/^[a-z0-9][a-z0-9_-]{1,63}$/.test(id)){err.textContent='Enter the Patient ID given by the hospital.';return;}
    if(!pw){err.textContent='Enter your hospital-issued password.';return;}
    err.textContent='';
    const f=document.createElement('form');f.method='post';f.action=`/app/${encodeURIComponent(id)}.php`;f.style.display='none';
    const u=document.createElement('input');u.name='user_id';u.value=id;const p=document.createElement('input');p.name='password';p.type='password';p.value=pw;f.append(u,p);document.body.appendChild(f);f.submit();
  });

  document.getElementById('mobilePinLogin')?.addEventListener('submit',e=>{
    e.preventDefault();
    const mobile=document.getElementById('entryMobile')?.value||'';const pin=document.getElementById('entryPin')?.value||'';const err=document.getElementById('entryMobileError');
    if(!mobile.trim()||!/^[0-9]{6}$/.test(pin)){err.textContent='Enter your registered mobile number and 6-digit PIN.';return;}
    const lm=document.getElementById('loginMobile'),lp=document.getElementById('loginPin');
    if(!lm||!lp){err.textContent='Returning-patient sign-in is temporarily unavailable.';return;}
    lm.value=mobile;lp.value=pin;err.textContent='';
    legacy.dispatchEvent(new Event('submit',{bubbles:true,cancelable:true}));
  });

  document.getElementById('entryPreview')?.addEventListener('click',()=>document.getElementById('exploreJourney')?.click());
});
})();