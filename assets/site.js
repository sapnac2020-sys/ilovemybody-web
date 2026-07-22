(() => {
  const views = [...document.querySelectorAll('[data-view]')];
  const navItems = [...document.querySelectorAll('.nav-item')];
  const routeControls = [...document.querySelectorAll('[data-route]')];

  function showRoute(route, updateHash = true) {
    if (!views.some(v => v.dataset.view === route)) route = 'home';
    views.forEach(v => v.classList.toggle('is-active', v.dataset.view === route));
    navItems.forEach(item => {
      const active = item.dataset.route === route;
      item.classList.toggle('is-active', active);
      active ? item.setAttribute('aria-current', 'page') : item.removeAttribute('aria-current');
    });
    if (updateHash) history.replaceState(null, '', `#${route}`);
    document.querySelector(`[data-view="${route}"]`)?.scrollTo(0, 0);
    document.getElementById('site-main').focus({preventScroll:true});
  }

  routeControls.forEach(control => control.addEventListener('click', event => {
    if (control.tagName === 'A') event.preventDefault();
    showRoute(control.dataset.route);
  }));
  window.addEventListener('hashchange', () => showRoute(location.hash.slice(1), false));
  showRoute(location.hash.slice(1) || 'home', false);

  const layers = {
    medical: ['Your medical baseline','Illnesses, operations, family history, reports, prescriptions, medicines and clinical measurements form the starting point—not the entire person.','Stored with date, source and review status.'],
    physical: ['Your physical systems','Heart, circulation, oxygen, nervous system, brain, hormones, immunity, metabolism, inflammation, digestion, gut function and repair.','Measured values remain separate from felt experience.'],
    food: ['What you feed your body','Food identity, chemistry, ingredients, quantity, combinations, preparation, timing, medicines, air, water and information.','Technology estimates; the person confirms.'],
    mind: ['What you feed your mind','Thoughts, beliefs, memories, fear, love, guilt, shame, confidence, identity, relationships, purpose and emotional experience.','A feeling is real; it is not automatically a diagnosis.'],
    signals: ['How your body speaks','Pain, fatigue, cravings, hunger, burping, gas, bowel changes, sleep, sweating, breathing, pulse, discomfort and pleasure.','A signal invites attention, not automatic interpretation.'],
    actions: ['What you choose and do','Eating, movement, rest, sleep, breathing, expression, work, relationships and the action taken after a body signal.','Choice is observed without guilt or moral judgement.'],
    environment: ['The world around you','People, place, noise, air, water, light, work, social context and other exposures that shape daily experience.','Context may modify a response without being its sole cause.'],
    response: ['Your biological response','Brain and gut signalling, nervous-system regulation, hormones, immunity, circulation, oxygen use, metabolism, recovery and gene regulation.','Direct biological claims require appropriate measurement.']
  };
  const detail = document.getElementById('layer-detail');
  document.querySelectorAll('#connection-orbit button').forEach(button => button.addEventListener('click', () => {
    document.querySelectorAll('#connection-orbit button').forEach(b => b.classList.remove('is-active'));
    button.classList.add('is-active');
    const [title, text, note] = layers[button.dataset.layer];
    detail.innerHTML = `<small>Connected layer</small><h3>${title}</h3><p>${text}</p><b>${note}</b>`;
  }));

  const evidence = {
    food: ['Food chemistry & composition','What is in the food?','Used for food identity, ingredients, nutrients, chemical composition, quantity, processing and preparation context.',['ICMR–NIN','Indian Food Composition Tables','FSSAI','USDA FoodData Central','FAO INFOODS','NIH ODS'],'composition and identity','the same personal response in everyone'],
    medical: ['Reports, pathology & medicines','What does the medical record establish?','Used to standardise tests, units, medicine identities, regulatory labels and clinical interpretation boundaries.',['WHO','ICD-11','LOINC','UCUM','IFCC','CLSI','CDSCO','DailyMed','RxNorm'],'standardisation, labels and guidance','an automated diagnosis or medicine change'],
    mind: ['Clinical psychology & neuroscience','What can be measured responsibly?','Validated instruments support screening and comparison. Brain datasets support anatomy and pathway research—not mind reading.',['WHO-5','PHQ-9','GAD-7','PROMIS','APA PsycNet','Allen Brain Atlas','BrainSpan','Human Connectome Project'],'validated measurement and research context','that a score independently diagnoses a person'],
    pathways: ['Biochemistry & biological pathways','How might the connection work?','Used to map chemicals, enzymes, metabolites, reactions, pathways and possible mechanisms.',['Reactome','Rhea','BRENDA','PubChem','ChEMBL','NIST','PharmGKB'],'mechanisms, reactions and identifiers','that a plausible mechanism caused one patient’s outcome'],
    traditional: ['Traditional & interpretive knowledge','What framework is being used?','Ayurveda, yoga, acupuncture, acupressure, chakra traditions, philosophy and personal teachers retain their own labels and sources.',['Classical texts','Reviewed scholarship','Ayurveda','Yoga','Acupuncture','Acupressure','Bhagavad Gita','Author philosophy'],'tradition, meaning and practice provenance','biomedical proof'],
    personal: ['Personal longitudinal evidence','What happened for this person?','Reports, prescriptions, food photographs, check-ins, body signals, actions, sessions and follow-up create private within-person evidence.',['Medical reports','Prescriptions','Daily check-ins','Food events','Body signals','Assessments','Actions','Follow-ups'],'the individual timeline and repeated personal patterns','that the same result applies universally']
  };
  const evidenceCard = document.getElementById('evidence-card');
  document.querySelectorAll('[data-evidence]').forEach(button => button.addEventListener('click', () => {
    document.querySelectorAll('[data-evidence]').forEach(b => b.classList.remove('is-active'));
    button.classList.add('is-active');
    const [small,title,text,sources,supports,notProve] = evidence[button.dataset.evidence];
    evidenceCard.innerHTML = `<small>${small}</small><h3>${title}</h3><p>${text}</p><div class="source-list">${sources.map(s=>`<span>${s}</span>`).join('')}</div><footer><b>What it supports:</b> ${supports}. <b>What it does not prove:</b> ${notProve}.</footer>`;
  }));

  const dialog = document.getElementById('source-dialog');
  document.getElementById('source-demo').addEventListener('click', () => dialog.showModal());
  dialog.querySelector('.dialog-close').addEventListener('click', () => dialog.close());
  dialog.addEventListener('click', e => { if (e.target === dialog) dialog.close(); });

  const jaadu = document.getElementById('jaadu-panel');
  const jaaduTrigger = document.getElementById('jaadu-trigger');
  function setJaadu(open) {
    jaadu.classList.toggle('is-open', open); jaadu.setAttribute('aria-hidden', String(!open));
    jaaduTrigger.setAttribute('aria-expanded', String(open));
  }
  jaaduTrigger.addEventListener('click', () => setJaadu(!jaadu.classList.contains('is-open')));
  document.getElementById('jaadu-close').addEventListener('click', () => setJaadu(false));
  document.querySelectorAll('[data-jaadu]').forEach(button => button.addEventListener('click', () => { setJaadu(false); showRoute(button.dataset.jaadu); }));

  const canvas = document.getElementById('dna-field');
  const ctx = canvas.getContext('2d');
  let width, height, dpr, points = [], raf;
  const reduced = matchMedia('(prefers-reduced-motion: reduce)').matches;
  function resize() {
    dpr = Math.min(devicePixelRatio || 1, 2); width = innerWidth; height = innerHeight;
    canvas.width = width*dpr; canvas.height = height*dpr; canvas.style.width=`${width}px`; canvas.style.height=`${height}px`;
    ctx.setTransform(dpr,0,0,dpr,0,0); makePoints();
  }
  function makePoints() {
    points=[]; const cx=width*.63, cy=height*.48, length=Math.min(width*.68,1100), count=Math.max(52,Math.floor(width/17));
    for(let i=0;i<count;i++){
      const t=i/(count-1), y=cy-length*.42+t*length*.84, wave=Math.sin(t*Math.PI*5.4), spread=Math.min(width*.21,310);
      points.push({x:cx+wave*spread,y,baseX:cx+wave*spread,baseY:y,phase:Math.random()*Math.PI*2,size:Math.random()*1.8+.6,strand:i%2});
      points.push({x:cx-wave*spread,y,baseX:cx-wave*spread,baseY:y,phase:Math.random()*Math.PI*2,size:Math.random()*1.8+.6,strand:(i%2)+2});
    }
    for(let i=0;i<Math.min(80,Math.floor(width/13));i++) points.push({x:width*(.19+Math.random()*.69),y:height*(.08+Math.random()*.84),baseX:0,baseY:0,phase:Math.random()*6.28,size:Math.random()*1.2+.3,strand:9,free:true});
  }
  function draw(time=0) {
    ctx.clearRect(0,0,width,height); const tick=time*.00022;
    points.forEach((p,i)=>{if(!reduced){p.x=(p.free?p.x:p.baseX)+Math.sin(tick*2+p.phase)*3;p.y=(p.free?p.y:p.baseY)+Math.cos(tick*1.5+p.phase)*2}if(p.free){p.x+=Math.sin(p.phase)*.025;p.y+=Math.cos(p.phase)*.02}});
    ctx.lineWidth=.55;
    for(let i=0;i<points.length;i++){const a=points[i];for(let j=i+1;j<Math.min(points.length,i+18);j++){const b=points[j],dx=a.x-b.x,dy=a.y-b.y,dist=Math.hypot(dx,dy);if(dist<145){ctx.strokeStyle=`rgba(238,184,160,${(1-dist/145)*.22})`;ctx.beginPath();ctx.moveTo(a.x,a.y);ctx.lineTo(b.x,b.y);ctx.stroke()}}}
    points.forEach(p=>{const glow=ctx.createRadialGradient(p.x,p.y,0,p.x,p.y,p.size*5);glow.addColorStop(0,'rgba(255,224,201,.96)');glow.addColorStop(.28,'rgba(235,171,145,.65)');glow.addColorStop(1,'rgba(235,171,145,0)');ctx.fillStyle=glow;ctx.beginPath();ctx.arc(p.x,p.y,p.size*5,0,Math.PI*2);ctx.fill()});
    if(!reduced) raf=requestAnimationFrame(draw);
  }
  addEventListener('resize', resize, {passive:true}); resize(); draw();
})();
