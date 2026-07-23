(() => {
  if (typeof THREE === 'undefined') return;
  const canvas = document.getElementById('scene');
  if (!canvas) return;

  const renderer = new THREE.WebGLRenderer({ canvas, antialias: true, alpha: true });
  renderer.setPixelRatio(Math.min(window.devicePixelRatio || 1, 2));

  const scene = new THREE.Scene();
  scene.fog = new THREE.FogExp2(0x100812, 0.0035);
  const camera = new THREE.PerspectiveCamera(56, innerWidth / innerHeight, 0.1, 400);
  camera.position.set(0, 0, 66);

  function glowTexture() {
    const c = document.createElement('canvas');
    c.width = c.height = 64;
    const x = c.getContext('2d');
    const g = x.createRadialGradient(32, 32, 0, 32, 32, 32);
    g.addColorStop(0, 'rgba(255,255,255,1)');
    g.addColorStop(.28, 'rgba(255,230,210,.9)');
    g.addColorStop(.62, 'rgba(240,157,187,.4)');
    g.addColorStop(1, 'rgba(240,157,187,0)');
    x.fillStyle = g;
    x.fillRect(0, 0, 64, 64);
    const texture = new THREE.Texture(c);
    texture.needsUpdate = true;
    return texture;
  }

  const group = new THREE.Group();
  scene.add(group);
  const count = innerWidth < 680 ? 360 : 620;
  const radius = 40;
  const positions = [];
  const colours = [];
  const nodes = [];
  const peach = new THREE.Color(0xf3c2a7);
  const rose = new THREE.Color(0xf09abb);
  const pearl = new THREE.Color(0xffeadc);

  for (let i = 0; i < count; i++) {
    const u = Math.random();
    const v = Math.random();
    const theta = Math.PI * 2 * u;
    const phi = Math.acos(2 * v - 1);
    const r = radius * (.72 + Math.random() * .5);
    const px = r * Math.sin(phi) * Math.cos(theta);
    const py = r * Math.cos(phi);
    const pz = r * Math.sin(phi) * Math.sin(theta);
    positions.push(px, py, pz);
    nodes.push([px, py, pz]);
    const colour = peach.clone().lerp(Math.random() < .5 ? rose : pearl, Math.random() * .6);
    colours.push(colour.r, colour.g, colour.b);
  }

  const pointGeometry = new THREE.BufferGeometry();
  pointGeometry.setAttribute('position', new THREE.Float32BufferAttribute(positions, 3));
  pointGeometry.setAttribute('color', new THREE.Float32BufferAttribute(colours, 3));
  group.add(new THREE.Points(pointGeometry, new THREE.PointsMaterial({
    size: 1.7,
    map: glowTexture(),
    vertexColors: true,
    transparent: true,
    blending: THREE.AdditiveBlending,
    depthWrite: false,
    opacity: 1
  })));

  const linePositions = [];
  const lineColours = [];
  let edges = 0;
  for (let a = 0; a < nodes.length && edges < 1250; a++) {
    for (let b = a + 1; b < nodes.length && edges < 1250; b++) {
      const dx = nodes[a][0] - nodes[b][0];
      const dy = nodes[a][1] - nodes[b][1];
      const dz = nodes[a][2] - nodes[b][2];
      const distance = Math.sqrt(dx * dx + dy * dy + dz * dz);
      if (distance < radius * .4 && Math.random() < .5) {
        linePositions.push(...nodes[a], ...nodes[b]);
        lineColours.push(.95, .78, .68, .9, .6, .68);
        edges++;
      }
    }
  }

  const lineGeometry = new THREE.BufferGeometry();
  lineGeometry.setAttribute('position', new THREE.Float32BufferAttribute(linePositions, 3));
  lineGeometry.setAttribute('color', new THREE.Float32BufferAttribute(lineColours, 3));
  group.add(new THREE.LineSegments(lineGeometry, new THREE.LineBasicMaterial({
    vertexColors: true,
    transparent: true,
    opacity: .3,
    blending: THREE.AdditiveBlending,
    depthWrite: false
  })));

  let targetX = 0;
  let targetY = 0;
  let mouseX = 0;
  let mouseY = 0;
  addEventListener('pointermove', event => {
    targetX = event.clientX / innerWidth - .5;
    targetY = event.clientY / innerHeight - .5;
  }, { passive: true });

  function resize() {
    renderer.setSize(innerWidth, innerHeight, false);
    camera.aspect = innerWidth / innerHeight;
    camera.updateProjectionMatrix();
  }
  addEventListener('resize', resize, { passive: true });
  resize();

  const clock = new THREE.Clock();
  function animate() {
    const elapsed = clock.getElapsedTime();
    group.rotation.y = elapsed * .055;
    group.rotation.x = Math.sin(elapsed * .18) * .12;
    group.rotation.z = Math.sin(elapsed * .11) * .05;
    mouseX += (targetX - mouseX) * .035;
    mouseY += (targetY - mouseY) * .035;
    camera.position.x = mouseX * 18;
    camera.position.y = -mouseY * 13;
    camera.lookAt(0, 0, 0);
    renderer.render(scene, camera);
    requestAnimationFrame(animate);
  }
  animate();
})();
