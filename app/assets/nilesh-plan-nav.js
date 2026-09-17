(()=>{
  'use strict';
  function ready(fn){document.readyState==='loading'?document.addEventListener('DOMContentLoaded',fn):fn();}
  ready(()=>{
    const nav=document.querySelector('.nav');
    const stage=document.querySelector('.stage');
    if(!nav||!stage)return;

    const style=document.createElement('style');
    style.textContent=`
      #plan.panel{height:100%;min-height:0}
      #plan .plan-shell{height:100%;min-height:0;display:grid;grid-template-rows:auto 1fr auto;border:1px solid #000;border-radius:14px;overflow:hidden;background:#fff}
      #plan .plan-head{padding:12px 14px 8px;border-bottom:1px solid #000}
      #plan .plan-head h2{margin:2px 0 3px;font-size:24px;line-height:1.08}
      #plan .plan-head p{margin:0;color:rgba(0,0,0,.62);font-size:11px}
      #plan .plan-scroll{min-height:0;overflow:auto;-webkit-overflow-scrolling:touch;overscroll-behavior:contain;background:#fff}
      #plan iframe{display:block;width:100%;height:100%;min-height:900px;border:0;background:#fff}
      .patient-step-nav{display:flex;justify-content:space-between;gap:10px;align-items:center;padding:9px 12px;border-top:1px solid #000;background:#fff;position:sticky;bottom:0;z-index:20}
      .patient-step-nav button{border:1px solid #000;border-radius:999px;padding:9px 14px;background:#fff;color:#000;font-weight:900;cursor:pointer}
      .patient-step-nav button.next{background:#ff008c;color:#fff;border-color:#ff008c}
      .patient-step-nav span{font-size:10px;font-weight:800;color:rgba(0,0,0,.55);text-align:center}
      @media(max-width:900px){#plan.panel{height:auto}#plan .plan-shell{height:auto;min-height:calc(100dvh - 120px)}#plan .plan-scroll{height:70dvh;overflow:auto}#plan iframe{min-height:1200px}}
    `;
    document.head.appendChild(style);

    const existing=[...nav.querySelectorAll('[data-panel]')];
    let planBtn=nav.querySelector('[data-panel="plan"]');
    if(!planBtn){
      planBtn=document.createElement('button');
      planBtn.dataset.panel='plan';
      const pathBtn=nav.querySelector('[data-panel="path"]');
      if(pathBtn&&pathBtn.nextSibling) nav.insertBefore(planBtn,pathBtn.nextSibling); else nav.appendChild(planBtn);
    }

    const order=['compare','deep','path','plan','reports','numbers','science'];
    const labels={compare:'Pharmacy = ILMB',deep:'Full Causal Flow',path:'Actual ILMB Path',plan:'My 7-Day Plan',reports:'Reports',numbers:'Measurements',science:'Evidence Layer'};
    order.forEach((id,i)=>{const b=nav.querySelector(`[data-panel="${id}"]`);if(b)b.textContent=`${i+1}. ${labels[id]}`});

    let plan=document.getElementById('plan');
    if(!plan){
      plan=document.createElement('section');
      plan.id='plan';
      plan.className='panel';
      plan.innerHTML=`<div class="plan-shell"><div class="plan-head"><div class="ey">MY 7-DAY PLAN</div><h2>Food, movement and lifestyle for this week</h2><p>This starts from the stroke / vascular-risk plan and is then adjusted using Nilesh's own measurements and safety limits.</p></div><div class="plan-scroll"><iframe title="Nilesh 7-Day Plan" loading="eager" src="/app/disease-default-stroke.php?embed=1"></iframe></div><div class="patient-step-nav"><button type="button" class="prev">← Previous</button><span>Scroll inside this plan to see every day, recipe and lifestyle instruction.</span><button type="button" class="next">Next →</button></div></div>`;
      const reports=document.getElementById('reports');
      if(reports)stage.insertBefore(plan,reports);else stage.appendChild(plan);
    }

    function allButtons(){return order.map(id=>nav.querySelector(`[data-panel="${id}"]`)).filter(Boolean)}
    function allPanels(){return order.map(id=>document.getElementById(id)).filter(Boolean)}
    function show(id){
      allButtons().forEach(b=>b.classList.toggle('active',b.dataset.panel===id));
      allPanels().forEach(p=>p.classList.toggle('active',p.id===id));
      try{history.replaceState(null,'','#'+id)}catch(e){}
    }
    allButtons().forEach(b=>b.onclick=()=>show(b.dataset.panel));

    const prev=plan.querySelector('.prev'),next=plan.querySelector('.next');
    prev.addEventListener('click',()=>show('path'));
    next.addEventListener('click',()=>show('reports'));

    const h=location.hash.slice(1);
    if(order.includes(h))show(h);
  });
})();
