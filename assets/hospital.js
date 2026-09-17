(() => {
  'use strict';
  const panels=[...document.querySelectorAll('[data-room-panel]')];
  const controls=[...document.querySelectorAll('[data-room],[data-open-room]')];
  const rail=[...document.querySelectorAll('.rail-item[data-room]')];
  const roomOrder=['reception','journey','body','treatment','tests','therapies','evidence'];

  function openRoom(name,updateHash=true){
    if(!panels.some(p=>p.dataset.roomPanel===name)) name='reception';
    panels.forEach(p=>p.classList.toggle('active',p.dataset.roomPanel===name));
    rail.forEach(b=>{const a=b.dataset.room===name;b.classList.toggle('active',a);b.setAttribute('aria-current',a?'page':'false')});
    document.body.dataset.room=name;
    if(updateHash) history.replaceState(null,'',name==='reception'?location.pathname:`#${name}`);
    const idx=roomOrder.indexOf(name);document.documentElement.style.setProperty('--room-progress',`${Math.max(0,idx)/(roomOrder.length-1)*100}%`);
    document.querySelector(`[data-room-panel="${name}"]`)?.scrollIntoView({block:'start'});
  }
  controls.forEach(c=>c.addEventListener('click',e=>{if(c.tagName==='BUTTON')e.preventDefault();openRoom(c.dataset.room||c.dataset.openRoom)}));
  addEventListener('hashchange',()=>openRoom(location.hash.slice(1)||'reception',false));
  document.addEventListener('keydown',e=>{if(e.key==='Escape'){closeBody();closeGuide();openRoom('reception')}});
  openRoom(location.hash.slice(1)||'reception',false);

  const picker=document.getElementById('concern-picker');
  document.getElementById('choose-concern')?.addEventListener('click',()=>{picker.hidden=!picker.hidden;if(!picker.hidden)picker.scrollIntoView({behavior:'smooth',block:'center'})});
  const content={
    illness:['Begin with your medical picture.','We start with what happened, your diagnosis if known, reports, medicines and the body systems involved.'],
    recovery:['Begin with recovery and function.','We start with the event, what has recovered, what still feels different, current medicines and measurable function.'],
    stress:['Begin with the body impact of stress.','We connect what you feel to sleep, autonomic state, behaviour and measurable body signals without reducing everything to “stress”.'],
    direction:['Begin with your present body state.','Explore what your body needs now, what is already working and what you want to improve.']
  };
  const next=document.getElementById('reception-next'),title=document.getElementById('reception-next-title'),copy=document.getElementById('reception-next-copy'),continueLink=document.getElementById('reception-register');
  document.querySelectorAll('[data-start-path]').forEach(button=>button.addEventListener('click',()=>{const key=button.dataset.startPath;document.querySelectorAll('[data-start-path]').forEach(x=>x.classList.toggle('selected',x===button));title.textContent=content[key][0];copy.textContent=content[key][1];continueLink.href=`/app/new.php?start=${encodeURIComponent(key)}`;next.hidden=false;sessionStorage.setItem('ilb_starting_path',key);next.scrollIntoView({behavior:'smooth',block:'nearest'})}));

  const bodyInfo={
    brain:['Brain & nerves','Blood supply, motor control, sensation and plasticity.','The hospital asks: where is the lesion, what function changed, what recovered, what is still measurable, and what does current imaging actually prove?'],
    heart:['Heart & vessels','Blood pressure, flow, endothelial state and cardiac workload.','The hospital separates pressure, heart rate, vascular resistance and perfusion so treatment effects are not mixed together.'],
    blood:['Blood & clotting','Platelets, coagulation, fibrinolysis and bleeding balance.','We track both sides: protection from pathological clotting and the collateral cost of reducing normal hemostasis.'],
    liver:['Liver & metabolism','Lipids, glucose, substrate production and clearance.','Food chemistry, liver production, clearance and muscle use are connected to the same measurable outputs such as triglycerides, LDL and glucose.'],
    gut:['Gut & microbiome','Food chemistry, microbial metabolites, barrier, immune and vagal signals.','The gut is treated as a modifier pathway. We do not invent patient-specific metabolite production where the coefficient is unknown.'],
    kidney:['Kidney & fluids','Filtration, electrolytes, fluid chemistry and safety boundaries.','Kidney function changes what is safe to add through food, supplements and medicines.'],
    muscle:['Muscle & movement','Strength, gait, endurance, motor learning and recovery.','Rehabilitation is activated only against a measured deficit: force, gait, dexterity, balance, tone or endurance.'],
    mind:['Mind & autonomic state','Stress, sleep, behaviour and autonomic physiology.','The hospital connects lived experience to measurable body signals without claiming every physical problem is psychological.']
  };
  const drawer=document.getElementById('body-drawer'),drawerTitle=document.getElementById('body-drawer-title'),drawerSub=document.getElementById('body-drawer-sub'),drawerCopy=document.getElementById('body-drawer-copy');
  function openBody(key){const d=bodyInfo[key];if(!drawer||!d)return;drawerTitle.textContent=d[0];drawerSub.textContent=d[1];drawerCopy.textContent=d[2];drawer.hidden=false;requestAnimationFrame(()=>drawer.classList.add('open'))}
  function closeBody(){if(!drawer)return;drawer.classList.remove('open');setTimeout(()=>drawer.hidden=true,180)}
  document.querySelectorAll('[data-body-system]').forEach(b=>b.addEventListener('click',()=>openBody(b.dataset.bodySystem)));
  document.getElementById('body-drawer-close')?.addEventListener('click',closeBody);

  const guide=document.getElementById('jaadu-guide');
  function openGuide(){if(!guide)return;guide.hidden=false;requestAnimationFrame(()=>guide.classList.add('open'))}
  function closeGuide(){if(!guide)return;guide.classList.remove('open');setTimeout(()=>guide.hidden=true,180)}
  document.querySelector('.jaadu-launch')?.addEventListener('click',openGuide);
  document.getElementById('jaadu-close')?.addEventListener('click',closeGuide);
  guide?.querySelectorAll('[data-guide-room]').forEach(b=>b.addEventListener('click',()=>{closeGuide();openRoom(b.dataset.guideRoom)}));
})();