(() => {
  const panels = [...document.querySelectorAll('[data-room-panel]')];
  const controls = [...document.querySelectorAll('[data-room], [data-open-room]')];
  const rail = [...document.querySelectorAll('.rail-item[data-room]')];

  function openRoom(name, updateHash = true) {
    if (!panels.some(panel => panel.dataset.roomPanel === name)) name = 'reception';
    panels.forEach(panel => panel.classList.toggle('active', panel.dataset.roomPanel === name));
    rail.forEach(button => {
      const active = button.dataset.room === name;
      button.classList.toggle('active', active);
      button.setAttribute('aria-current', active ? 'page' : 'false');
    });
    document.body.dataset.room = name;
    if (updateHash) history.replaceState(null, '', name === 'reception' ? location.pathname : `#${name}`);
  }

  controls.forEach(control => control.addEventListener('click', () => {
    openRoom(control.dataset.room || control.dataset.openRoom);
  }));

  document.addEventListener('keydown', event => {
    if (event.key === 'Escape') openRoom('reception');
  });

  openRoom(location.hash.slice(1) || 'reception', false);

  const pathContent = {
    illness: [
      'Begin with your present medical picture.',
      'Add your latest reports, prescriptions, medicines and what you are experiencing. Missing records will never stop you from beginning.'
    ],
    stress: [
      'Begin with what is creating pressure.',
      'Tell us how stress is showing up in your body and daily life, then add any reports or medicines you already have.'
    ],
    addiction: [
      'Begin privately and without judgement.',
      'We start with safety, present patterns, medicines and support—not a label. You decide what you are ready to share.'
    ],
    direction: [
      'Begin with your present life picture.',
      'The 10-day assessment explores values, confidence, relationships, work, money, feelings, instinct and what you want from life.'
    ]
  };
  const next = document.getElementById('reception-next');
  const nextTitle = document.getElementById('reception-next-title');
  const nextCopy = document.getElementById('reception-next-copy');
  const register = document.getElementById('reception-register');
  document.querySelectorAll('[data-start-path]').forEach(button => {
    button.addEventListener('click', () => {
      const key = button.dataset.startPath;
      const content = pathContent[key];
      document.querySelectorAll('[data-start-path]').forEach(item => item.classList.toggle('selected', item === button));
      nextTitle.textContent = content[0];
      nextCopy.textContent = content[1];
      register.href = `/app/?mode=register&start=${encodeURIComponent(key)}`;
      next.hidden = false;
      sessionStorage.setItem('ilb_starting_path', key);
      next.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
    });
  });

  const jaadu = document.querySelector('.jaadu-launch');
  if (jaadu) {
    jaadu.addEventListener('click', () => {
      jaadu.innerHTML = '✦ <span>Jaadu is being prepared</span>';
      window.setTimeout(() => {
        jaadu.innerHTML = '✦ <span>Ask Jaadu</span>';
      }, 2200);
    });
  }
})();
