(()=>{
  const nav=document.querySelector('.nav');
  const stage=document.querySelector('.stage');
  if(!nav||!stage) return;

  const style=document.createElement('style');
  style.textContent=`
    #weekly-plan.panel{height:100%;min-height:0}
    #weekly-plan .weekly-shell{height:100%;min-height:0;display:grid;grid-template-rows:auto 1fr auto;border:1px solid #000;border-radius:14px;overflow:hidden;background:#fff}
    #weekly-plan .weekly-head{padding:12px 14px;border-bottom:1px solid #000;background:#fff}
    #weekly-plan .weekly-head h2{margin:3px 0 4px}
    #weekly-plan .weekly-head p{margin:0;color:rgba(0,0,0,.62);font-size:11px}
    #weekly-plan .weekly-scroll{min-height:0;height:100%;overflow:auto;-webkit-overflow-scrolling:touch;overscroll-behavior:contain;background:#fff}
    #weekly-plan iframe{display:block;width:100%;height:1400px;min-height:1400px;border:0;background:#fff}
    #weekly-plan .weekly-nav{display:flex;align-items:center;justify-content:space-between;gap:10px;padding:9px 12px;border-top:1px solid #000;background:#fff;position:sticky;bottom:0;z-index:30}
    #weekly-plan .weekly-nav button{border:1px solid #000;border-radius:999px;padding:9px 14px;background:#fff;color:#000;font-weight:900;cursor:pointer;white-space:nowrap}
    #weekly-plan .weekly-nav .next{background:#ff008c;color:#fff;border-color:#ff008c}
    #weekly-plan .weekly-nav span{font-size:10px;font-weight:800;color:rgba(0,0,0,.55);text-align:center}
    @media(max-width:900px){#weekly-plan.panel{height:auto}#weekly-plan .weekly-shell{height:auto;min-height:calc(100dvh - 110px)}#weekly-plan .weekly-scroll{height:72dvh;overflow:auto}#weekly-plan iframe{height:1700px;min-height:1700px}}
    @media(max-width:600px){#weekly-plan .weekly-head{padding:10px}#weekly-plan .weekly-nav{position:sticky;bottom:0;padding:8px}#weekly-plan .weekly-nav span{display:none}#weekly-plan iframe{height:2200px;min-height:2200px}}
  `;
  document.head.appendChild(style);

  let section=document.getElementById('weekly-plan');
  let btn=nav.querySelector('[data-panel="weekly-plan"]');
  if(!btn){
    btn=document.createElement('button');
    btn.type='button';
    btn.dataset.panel='weekly-plan';
    const reportBtn=nav.querySelector('[data-panel="reports"]');
    if(reportBtn) nav.insertBefore(btn,reportBtn); else nav.appendChild(btn);
  }
  btn.textContent='4. My 7-Day Plan';

  const renumber={reports:'5. Reports',numbers:'6. Measurements',science:'7. Evidence Layer'};
  Object.entries(renumber).forEach(([id,label])=>{const b=nav.querySelector(`[data-panel="${id}"]`);if(b)b.textContent=label;});

  if(!section){
    section=document.createElement('section');
    section.id='weekly-plan';
    section.className='panel';
    section.innerHTML=`<div class="weekly-shell"><div class="weekly-head"><div class="ey">NILESH · ILMB 7-DAY PLAN</div><h2>Your food, movement and lifestyle plan</h2><p>Scroll inside this plan to see all 7 days, recipes and lifestyle instructions. Use Previous / Next to move through your patient file.</p></div><div class="weekly-scroll" tabindex="0"><iframe title="Nilesh 7-day ILMB plan" src="/app/disease-default-stroke.php?patient=nilesh&embed=1"></iframe></div><div class="weekly-nav"><button type="button" class="prev">← Previous</button><span>Plan scrolls here · navigation stays visible</span><button type="button" class="next">Next →</button></div></div>`;
    const reports=document.getElementById('reports');
    if(reports) stage.insertBefore(section,reports); else stage.appendChild(section);
  }

  const order=['compare','deep','path','weekly-plan','reports','numbers','science'];
  const buttons=()=>order.map(id=>nav.querySelector(`[data-panel="${id}"]`)).filter(Boolean);
  const panels=()=>order.map(id=>document.getElementById(id)).filter(Boolean);
  function show(id){
    buttons().forEach(b=>b.classList.toggle('active',b.dataset.panel===id));
    panels().forEach(p=>p.classList.toggle('active',p.id===id));
    history.replaceState(null,'','#'+id);
    const p=document.getElementById(id);
    if(p&&p.querySelector('.section')) p.querySelector('.section').scrollTop=0;
  }
  buttons().forEach(b=>b.onclick=()=>show(b.dataset.panel));
  section.querySelector('.prev').onclick=()=>show('path');
  section.querySelector('.next').onclick=()=>show('reports');

  if(location.hash==='#weekly-plan') show('weekly-plan');
})();
