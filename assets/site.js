(() => {
  const menuButton = document.querySelector('.menu-button');
  const nav = document.getElementById('site-nav');
  menuButton.addEventListener('click', () => {
    const open = nav.classList.toggle('open');
    menuButton.setAttribute('aria-expanded', String(open));
  });
  nav.querySelectorAll('a').forEach(link => link.addEventListener('click', () => {
    nav.classList.remove('open');
    menuButton.setAttribute('aria-expanded', 'false');
  }));

  const evidence = {
    medical: ['Official, regulatory and clinical sources','What does the medical record establish?','Reports, tests, units, medicines and clinical guidance retain their dates, sources, scope and limitations.',['WHO','LOINC','UCUM','IFCC','CDSCO','DailyMed','RxNorm']],
    food: ['Food identity and chemistry','What is in the food—and how was it prepared?','Composition, ingredients, quantity, combinations and preparation are connected without assuming the same response in every person.',['ICMR–NIN','IFCT','FSSAI','USDA FoodData Central','FAO INFOODS','NIH ODS']],
    mind: ['Validated measures and neuroscience','What can be measured responsibly?','Official instruments remain separate from our own discovery questions. A score supports reflection and review; it does not define or diagnose a person.',['WHO-5','PHQ-9','GAD-7','IPIP','Rosenberg SES','Allen Brain Atlas']],
    traditional: ['Traditional and interpretive knowledge','Which framework is speaking?','Ayurveda, yoga, acupuncture, acupressure, energy practices and philosophy keep their original names and are never disguised as biomedical proof.',['Classical texts','Reviewed scholarship','Practice provenance','Evidence label','Safety boundary']],
    personal: ['Private longitudinal evidence','What happened for this person?','Reports, check-ins, body signals, actions and follow-up form a personal timeline. A repeated personal pattern is not automatically universal proof.',['Medical reports','Prescriptions','Assessments','Body signals','Actions','Follow-up']]
  };
  const detail = document.getElementById('evidence-detail');
  document.querySelectorAll('[data-evidence]').forEach(button => button.addEventListener('click', () => {
    document.querySelectorAll('[data-evidence]').forEach(item => item.classList.remove('active'));
    button.classList.add('active');
    const [small,title,text,sources] = evidence[button.dataset.evidence];
    detail.innerHTML = `<small>${small}</small><h3>${title}</h3><p>${text}</p><div>${sources.map(source => `<span>${source}</span>`).join('')}</div><button type="button" id="source-button">How a source is shown →</button>`;
    document.getElementById('source-button').addEventListener('click', () => sourceDialog.showModal());
  }));

  const sourceDialog = document.getElementById('source-dialog');
  document.getElementById('source-button').addEventListener('click', () => sourceDialog.showModal());
  sourceDialog.querySelector('button').addEventListener('click', () => sourceDialog.close());
  sourceDialog.addEventListener('click', event => { if (event.target === sourceDialog) sourceDialog.close(); });

  const jaaduButton = document.getElementById('jaadu-button');
  const jaadu = document.getElementById('jaadu');
  const setJaadu = open => {
    jaadu.hidden = !open;
    jaadu.classList.toggle('open', open);
    jaaduButton.setAttribute('aria-expanded', String(open));
  };
  jaaduButton.addEventListener('click', () => setJaadu(!jaadu.classList.contains('open')));
  jaadu.querySelector('.jaadu-close').addEventListener('click', () => setJaadu(false));
  jaadu.querySelectorAll('a').forEach(link => link.addEventListener('click', () => setJaadu(false)));

  const canvas = document.getElementById('dna-field');
  if (!canvas) return;
  const ctx = canvas.getContext('2d');
  let width, height, dpr, points = [];
  function makePoints() {
    points = [];
    const cx = width * .67, cy = height * .48, length = Math.min(height * 1.25, 980);
    const count = Math.max(58, Math.floor(width / 18));
    for (let i = 0; i < count; i++) {
      const t = i / (count - 1), y = cy - length * .47 + t * length * .94;
      const wave = Math.sin(t * Math.PI * 5.2), spread = Math.min(width * .22, 290);
      [-1,1].forEach(side => points.push({baseX:cx + side * wave * spread,baseY:y,x:0,y:0,phase:Math.random()*6.28,size:.7+Math.random()*1.4,helix:true,side,t,spread,cx}));
    }
    for (let i=0;i<70;i++) points.push({baseX:width*(.16+Math.random()*.8),baseY:height*(.04+Math.random()*.92),x:0,y:0,phase:Math.random()*6.28,size:.45+Math.random()*.9});
  }
  function resize() {
    width=innerWidth;height=innerHeight;dpr=Math.min(devicePixelRatio||1,2);
    canvas.width=width*dpr;canvas.height=height*dpr;canvas.style.width=width+'px';canvas.style.height=height+'px';
    ctx.setTransform(dpr,0,0,dpr,0,0);makePoints();
  }
  function draw(time=0) {
    ctx.clearRect(0,0,width,height);
    const tick=time*.00032;
    points.forEach(p=>{
      if(p.helix){
        const movingWave=Math.sin(p.t*Math.PI*5.2+tick*3.4);
        p.x=p.cx+p.side*movingWave*p.spread+Math.sin(tick+p.phase)*7;
        p.y=p.baseY+Math.cos(tick*2+p.phase)*5;
      }else{
        p.x=p.baseX+Math.sin(tick*1.4+p.phase)*8;
        p.y=p.baseY+Math.cos(tick*1.1+p.phase)*6;
      }
    });
    for(let i=0;i<points.length;i++) for(let j=i+1;j<Math.min(points.length,i+15);j++){
      const a=points[i],b=points[j],distance=Math.hypot(a.x-b.x,a.y-b.y);
      if(distance<145){ctx.strokeStyle=`rgba(242,183,163,${(1-distance/145)*.34})`;ctx.lineWidth=.72;ctx.beginPath();ctx.moveTo(a.x,a.y);ctx.lineTo(b.x,b.y);ctx.stroke()}
    }
    points.forEach(p=>{const g=ctx.createRadialGradient(p.x,p.y,0,p.x,p.y,p.size*6);g.addColorStop(0,'rgba(255,236,224,1)');g.addColorStop(.28,'rgba(244,176,161,.75)');g.addColorStop(1,'rgba(239,163,151,0)');ctx.fillStyle=g;ctx.beginPath();ctx.arc(p.x,p.y,p.size*6,0,Math.PI*2);ctx.fill()});
    requestAnimationFrame(draw);
  }
  addEventListener('resize',resize,{passive:true});resize();draw();
})();
