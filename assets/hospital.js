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
