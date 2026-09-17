(()=>{
  const nav=document.querySelector('.nav');
  const stage=document.querySelector('.stage');
  if(!nav||!stage||document.getElementById('weekly-plan')) return;
  const btn=document.createElement('button');
  btn.type='button';
  btn.dataset.panel='weekly-plan';
  btn.textContent='4. My 7-Day Plan';
  const reportBtn=[...nav.querySelectorAll('[data-panel]')].find(b=>b.dataset.panel==='reports');
  if(reportBtn) nav.insertBefore(btn,reportBtn); else nav.appendChild(btn);
  const renumber={reports:'5. Reports',numbers:'6. Measurements',science:'7. Evidence Layer'};
  Object.entries(renumber).forEach(([id,label])=>{const b=nav.querySelector(`[data-panel="${id}"]`);if(b)b.textContent=label;});
  const section=document.createElement('section');
  section.id='weekly-plan';
  section.className='panel';
  section.innerHTML=`<div class="section" style="padding:0;overflow:hidden"><div style="padding:12px 14px;border-bottom:1px solid #000;background:#fff"><div class="ey">NILESH · ILMB 7-DAY PLAN</div><h2 style="margin:3px 0 4px">Your starting food, movement and lifestyle plan</h2><p class="lead" style="margin:0">This starts from the stroke / vascular-risk disease plan. Your own measurements override the default wherever needed. Your prescribed medicines stay unchanged unless your treating clinician changes them.</p></div><iframe title="Nilesh 7-day ILMB plan" src="/app/disease-default-stroke.php?patient=nilesh" style="display:block;width:100%;height:calc(100% - 92px);min-height:620px;border:0;background:#fff"></iframe></div>`;
  const reports=document.getElementById('reports');
  if(reports) stage.insertBefore(section,reports); else stage.appendChild(section);
  btn.addEventListener('click',()=>{
    [...nav.querySelectorAll('[data-panel]')].forEach(b=>b.classList.toggle('active',b===btn));
    [...stage.querySelectorAll('.panel')].forEach(p=>p.classList.toggle('active',p===section));
    history.replaceState(null,'','#weekly-plan');
  });
  if(location.hash==='#weekly-plan') btn.click();
})();
