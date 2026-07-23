(() => {
  const canvas = document.getElementById('scene');
  if (!canvas) return;
  const context = canvas.getContext('2d');
  if (!context) return;

  let width = 0;
  let height = 0;
  let ratio = 1;
  let pointerX = 0;
  let pointerY = 0;
  let targetX = 0;
  let targetY = 0;
  const particles = [];
  const total = innerWidth < 680 ? 120 : 210;

  for (let index = 0; index < total; index += 1) {
    const longitude = Math.random() * Math.PI * 2;
    const latitude = Math.acos(2 * Math.random() - 1);
    const radius = .68 + Math.random() * .34;
    particles.push({
      x: radius * Math.sin(latitude) * Math.cos(longitude),
      y: radius * Math.cos(latitude),
      z: radius * Math.sin(latitude) * Math.sin(longitude),
      size: .55 + Math.random() * 1.45,
      phase: Math.random() * Math.PI * 2
    });
  }

  function resize() {
    ratio = Math.min(devicePixelRatio || 1, 2);
    width = innerWidth;
    height = innerHeight;
    canvas.width = width * ratio;
    canvas.height = height * ratio;
    canvas.style.width = `${width}px`;
    canvas.style.height = `${height}px`;
    context.setTransform(ratio, 0, 0, ratio, 0, 0);
  }

  function rotate(point, angleY, angleX) {
    const cosineY = Math.cos(angleY);
    const sineY = Math.sin(angleY);
    const x1 = point.x * cosineY - point.z * sineY;
    const z1 = point.x * sineY + point.z * cosineY;
    const cosineX = Math.cos(angleX);
    const sineX = Math.sin(angleX);
    return {
      x: x1,
      y: point.y * cosineX - z1 * sineX,
      z: point.y * sineX + z1 * cosineX
    };
  }

  function render(milliseconds) {
    const time = milliseconds * .0001;
    pointerX += (targetX - pointerX) * .025;
    pointerY += (targetY - pointerY) * .025;
    context.clearRect(0, 0, width, height);

    const scale = Math.min(width, height) * .54;
    const centreX = width * .5 + pointerX * 42;
    const centreY = height * .46 + pointerY * 30;
    const projected = particles.map((particle) => {
      const point = rotate(particle, time + pointerX * .22, Math.sin(time * .72) * .17 + pointerY * .1);
      const depth = 1.55 + point.z * .45;
      return {
        x: centreX + point.x * scale / depth,
        y: centreY + point.y * scale / depth,
        z: point.z,
        alpha: .26 + (point.z + 1) * .31,
        size: particle.size * (1.1 + (point.z + 1) * .52),
        phase: particle.phase
      };
    });

    for (let first = 0; first < projected.length; first += 1) {
      const a = projected[first];
      for (let second = first + 1; second < projected.length; second += 1) {
        const b = projected[second];
        const dx = a.x - b.x;
        const dy = a.y - b.y;
        const distanceSquared = dx * dx + dy * dy;
        const threshold = width < 680 ? 72 : 92;
        if (distanceSquared < threshold * threshold) {
          const opacity = (1 - Math.sqrt(distanceSquared) / threshold) * .22 * Math.min(a.alpha, b.alpha);
          context.beginPath();
          context.moveTo(a.x, a.y);
          context.lineTo(b.x, b.y);
          context.strokeStyle = `rgba(244,170,190,${opacity})`;
          context.lineWidth = .65;
          context.stroke();
        }
      }
    }

    projected
      .sort((a, b) => a.z - b.z)
      .forEach((point) => {
        const pulse = 1 + Math.sin(milliseconds * .0016 + point.phase) * .18;
        const radius = point.size * pulse;
        const glow = context.createRadialGradient(point.x, point.y, 0, point.x, point.y, radius * 5.5);
        glow.addColorStop(0, `rgba(255,250,245,${Math.min(1, point.alpha + .28)})`);
        glow.addColorStop(.2, `rgba(250,205,184,${point.alpha})`);
        glow.addColorStop(.52, `rgba(240,125,170,${point.alpha * .42})`);
        glow.addColorStop(1, 'rgba(240,125,170,0)');
        context.fillStyle = glow;
        context.beginPath();
        context.arc(point.x, point.y, radius * 5.5, 0, Math.PI * 2);
        context.fill();
      });

    requestAnimationFrame(render);
  }

  addEventListener('pointermove', (event) => {
    targetX = event.clientX / width - .5;
    targetY = event.clientY / height - .5;
  }, { passive: true });
  addEventListener('resize', resize, { passive: true });
  resize();
  requestAnimationFrame(render);
})();
