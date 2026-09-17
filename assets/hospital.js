(() => {
  'use strict';
  const panels = [...document.querySelectorAll('[data-room-panel]')];
  const controls = [...document.querySelectorAll('[data-room], [data-open-room]')];
  const rail = [...document.querySelectorAll('.rail-item[data-room]')];

  function openRoom(name, updateHash = true) {
    if (!panels.some(p => p.dataset.roomPanel === name)) name = 'reception';
    panels.forEach(p => p.classList.toggle('active', p.dataset.roomPanel === name));
    rail.forEach(b => {
      const active = b.dataset.room === name;
      b.classList.toggle('active', active);
      b.setAttribute('aria-current', active ? 'page' : 'false');
    });
    document.body.dataset.room = name;
    if (updateHash) history.replaceState(null, '', name === 'reception' ? location.pathname : `#${name}`);
    document.querySelector(`[data-room-panel="${name}"]`)?.scrollTo?.({top:0,behavior:'instant'});
  }

  controls.forEach(c => c.addEventListener('click', e => {
    if (c.tagName === 'BUTTON') e.preventDefault();
    openRoom(c.dataset.room || c.dataset.openRoom);
  }));

  document.addEventListener('keydown', e => { if (e.key === 'Escape') openRoom('reception'); });
  openRoom(location.hash.slice(1) || 'reception', false);

  const picker = document.getElementById('concern-picker');
  document.getElementById('choose-concern')?.addEventListener('click', () => {
    picker.hidden = false;
    picker.scrollIntoView({behavior:'smooth',block:'center'});
  });

  const content = {
    illness: ['Begin with your medical picture.', 'We start with what happened, your diagnosis if known, reports, medicines and the body systems involved.'],
    recovery: ['Begin with recovery and function.', 'We start with the event, what has recovered, what still feels different, current medicines and measurable function.'],
    stress: ['Begin with the body impact of stress.', 'We connect what you feel to sleep, autonomic state, behaviour and measurable body signals without reducing everything to “stress”.'],
    direction: ['Begin with your present body state.', 'Explore what your body needs now, what is already working and what you want to improve.']
  };
  const next = document.getElementById('reception-next');
  const title = document.getElementById('reception-next-title');
  const copy = document.getElementById('reception-next-copy');
  const continueLink = document.getElementById('reception-register');

  document.querySelectorAll('[data-start-path]').forEach(button => button.addEventListener('click', () => {
    const key = button.dataset.startPath;
    document.querySelectorAll('[data-start-path]').forEach(x => x.classList.toggle('selected', x === button));
    title.textContent = content[key][0]; copy.textContent = content[key][1];
    continueLink.href = `/app/new.php?start=${encodeURIComponent(key)}`;
    next.hidden = false;
    sessionStorage.setItem('ilb_starting_path', key);
    next.scrollIntoView({behavior:'smooth',block:'nearest'});
  }));

  const jaadu = document.querySelector('.jaadu-launch');
  if (jaadu) jaadu.addEventListener('click', () => {
    const old = jaadu.innerHTML;
    jaadu.innerHTML = '✦ <span>Jaadu will guide this room soon</span>';
    setTimeout(() => jaadu.innerHTML = old, 1900);
  });
})();