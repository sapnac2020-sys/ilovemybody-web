(()=>{'use strict';
function addReviewLinks(){
 const rail=document.querySelector('.patient-rail');
 if(rail&&!rail.querySelector('[data-hospital-review]')){
  const a=document.createElement('a');a.href='hospital-review.php';a.dataset.hospitalReview='1';a.setAttribute('aria-label','My hospital review');a.setAttribute('data-tip','Reports + medicines review');a.textContent='◎';a.style.cssText='display:grid;place-items:center;text-decoration:none;color:inherit;min-height:44px;border-radius:12px';rail.appendChild(a);
 }
 const actions=document.querySelector('.record-actions');
 if(actions&&!actions.querySelector('[data-hospital-review]')){
  const a=document.createElement('a');a.href='hospital-review.php';a.dataset.hospitalReview='1';a.className='upload';a.innerHTML='<b>Review my reports + medicines</b><small>Reassuring · attention · unknowns · side effects · ILMB target</small>';actions.appendChild(a);
 }
 const tools=document.querySelector('.dashboard-tools');
 if(tools&&!tools.querySelector('[data-hospital-review]')){
  const a=document.createElement('a');a.href='hospital-review.php';a.dataset.hospitalReview='1';a.textContent='Hospital review';a.style.cssText='text-decoration:none;color:inherit;border:1px solid var(--line);border-radius:999px;padding:7px 11px;background:#fff;font-size:.72rem;font-weight:700';tools.appendChild(a);
 }
}
function routePreview(){
 const p=new URLSearchParams(location.search);if(p.get('preview')!=='1')return;
 let tries=0;const timer=setInterval(()=>{
  tries++;
  const browse=document.querySelector('#browseApp');
  if(browse&&document.querySelector('#loginShell')&&!document.querySelector('#loginShell').hidden){browse.click();clearInterval(timer);setTimeout(()=>{const target=(location.hash||'#records').slice(1);const b=document.querySelector(`[data-view="${target}"],[data-go="${target}"]`);if(b)b.click();},80);}
  if(tries>40)clearInterval(timer);
 },100);
}
function markFlow(){
 const records=document.querySelector('[data-view-panel="records"] .section-intro');
 if(records&&!records.querySelector('[data-flow-note]')){
  const p=document.createElement('p');p.dataset.flowNote='1';p.style.cssText='margin-top:10px;padding:10px 12px;border-left:3px solid var(--neon);background:rgba(var(--neon-rgb),.05);border-radius:8px;font-size:.75rem;line-height:1.5';p.innerHTML='<b>Step 1:</b> add reports and prescriptions → <b>Step 2:</b> add exact test values → <b>Step 3:</b> open Hospital Review to see reassuring findings, concerns, prescription mechanisms, side-effect paths and ILMB targets.';records.appendChild(p);
 }
}
function init(){addReviewLinks();markFlow();routePreview();}
if(document.readyState==='loading')document.addEventListener('DOMContentLoaded',init);else init();
})();