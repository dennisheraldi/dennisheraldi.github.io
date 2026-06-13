// Ambient "electric fluid" background.
//
// A flow field drives a swarm of particles whose glowing trails accumulate into
// branching, plasma-like filaments in cyan -- the signature "electric fluid"
// motion from the reference clips (empty / biochemical / idem). Trails fade
// each frame so the structure constantly morphs instead of filling in solid.
// Every few seconds the whole field briefly tears/RGB-splits, mimicking an
// analog signal dropping a frame.
//
// Performance guardrails:
//   - bails out entirely when the user prefers reduced motion
//   - scales the backing store by devicePixelRatio (capped at 2)
//   - thins particle count on small / low-power viewports
//   - pauses the rAF loop while the tab is hidden
(() => {
  const canvas = document.getElementById('bg-canvas');
  if (!canvas) return;

  const reduceMotion = window.matchMedia('(prefers-reduced-motion: reduce)');
  if (reduceMotion.matches) return;

  const ctx = canvas.getContext('2d', { alpha: true });
  if (!ctx) return;

  let dpr = Math.min(window.devicePixelRatio || 1, 2);
  let width = 0;
  let height = 0;
  let particles = [];
  let time = 0;
  let rafId = null;
  let running = false;

  // Glitch scheduling (the "dropped frame" tear).
  let nextGlitch = performance.now() + rand(10000, 16000);
  let glitchUntil = 0;
  let glitchOffset = 0;

  function rand(min, max) {
    return min + Math.random() * (max - min);
  }

  function particleCount() {
    const area = width * height;
    const base = Math.round(area / 8000);
    // Fewer on phones, where fill-rate is precious.
    const cap = width < 768 ? 110 : 240;
    return Math.max(80, Math.min(cap, base));
  }

  // Divergence-free "curl" flow field: velocity is the curl of a scalar
  // potential built from layered sines, which makes the flow swirl and braid
  // like a fluid (rather than drift in parallel streaks). Two octaves add
  // finer turbulence so trails fork into filaments. Returns a unit-ish vector.
  const vel = { x: 0, y: 0 };
  function flowVelocity(x, y, t) {
    const k1 = 0.0052;
    const w1 = 0.00005;
    const k2 = 0.014;
    const w2 = 0.00008;

    // Curl of P => (dP/dy, -dP/dx). Octave 1 (broad swirls).
    let vx =
      k1 * Math.cos(y * k1 - t * w1) +
      k1 * Math.cos((x + y) * k1 + t * w1 * 1.3);
    let vy =
      -(k1 * Math.cos(x * k1 + t * w1) +
        k1 * Math.cos((x + y) * k1 + t * w1 * 1.3));

    // Octave 2 (finer detail), weighted down.
    vx += 0.45 * (k2 * Math.cos(y * k2 + t * w2));
    vy += 0.45 * (-(k2 * Math.cos(x * k2 - t * w2)));

    const len = Math.hypot(vx, vy) || 1;
    vel.x = vx / len;
    vel.y = vy / len;
    return vel;
  }

  function makeParticle() {
    return {
      x: Math.random() * width,
      y: Math.random() * height,
      speed: rand(0.16, 0.5),
      life: rand(260, 760),
      age: Math.random() * 760,
    };
  }

  function resetParticle(p) {
    p.x = Math.random() * width;
    p.y = Math.random() * height;
    p.speed = rand(0.16, 0.5);
    p.life = rand(260, 760);
    p.age = 0;
  }

  function resize() {
    dpr = Math.min(window.devicePixelRatio || 1, 2);
    width = window.innerWidth;
    height = window.innerHeight;
    canvas.width = Math.floor(width * dpr);
    canvas.height = Math.floor(height * dpr);
    canvas.style.width = width + 'px';
    canvas.style.height = height + 'px';
    ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
    ctx.fillStyle = '#050505';
    ctx.fillRect(0, 0, width, height);
    particles = Array.from({ length: particleCount() }, makeParticle);
  }

  function drawTrails(offsetX, alphaScale) {
    ctx.globalCompositeOperation = 'lighter';
    ctx.lineCap = 'round';

    for (const p of particles) {
      const v = flowVelocity(p.x, p.y, time);
      const nx = p.x + v.x * p.speed;
      const ny = p.y + v.y * p.speed;

      // Saturated cyan body, whitening at the fast cores. Two passes give a
      // cheap bloom without per-stroke shadowBlur: a wide faint halo plus a
      // thin bright core. Additive blending lets overlaps bloom to white.
      const t = Math.min(p.speed / 0.5, 1);
      const r = Math.round(30 + 200 * t);
      const g = 238;
      const b = 255;

      ctx.beginPath();
      ctx.moveTo(p.x + offsetX, p.y);
      ctx.lineTo(nx + offsetX, ny);

      // Halo
      ctx.strokeStyle = `rgba(0,229,255,${0.028 * alphaScale})`;
      ctx.lineWidth = 3.5 + t * 2.5;
      ctx.stroke();

      // Core
      ctx.strokeStyle = `rgba(${r},${g},${b},${0.18 * alphaScale})`;
      ctx.lineWidth = 0.7 + t * 1.1;
      ctx.stroke();

      p.x = nx;
      p.y = ny;
      p.age++;

      if (
        p.age > p.life ||
        p.x < -20 ||
        p.x > width + 20 ||
        p.y < -20 ||
        p.y > height + 20
      ) {
        resetParticle(p);
      }
    }
    ctx.globalCompositeOperation = 'source-over';
  }

  function step(now) {
    if (!running) return;
    time = now;

    // Fade the previous frame toward black so trails dissipate and the field
    // keeps flowing rather than filling solid.
    ctx.globalCompositeOperation = 'source-over';
    ctx.fillStyle = 'rgba(5,5,5,0.035)';
    ctx.fillRect(0, 0, width, height);

    // Maybe trigger a micro-glitch tear.
    if (now >= nextGlitch) {
      glitchUntil = now + rand(70, 150);
      glitchOffset = rand(-22, 22);
      nextGlitch = now + rand(10000, 16000);
    }

    if (now < glitchUntil) {
      drawTrails(glitchOffset, 0.85); // cyan-shifted copy
      drawTrails(-glitchOffset * 0.5, 0.6); // counter-shifted ghost
    } else {
      drawTrails(0, 1);
    }

    rafId = requestAnimationFrame(step);
  }

  function start() {
    if (running) return;
    running = true;
    rafId = requestAnimationFrame(step);
  }

  function stop() {
    running = false;
    if (rafId != null) cancelAnimationFrame(rafId);
    rafId = null;
  }

  let resizeTimer = null;
  window.addEventListener('resize', () => {
    clearTimeout(resizeTimer);
    resizeTimer = setTimeout(resize, 150);
  });

  document.addEventListener('visibilitychange', () => {
    if (document.hidden) stop();
    else start();
  });

  reduceMotion.addEventListener?.('change', (e) => {
    if (e.matches) {
      stop();
      ctx.clearRect(0, 0, width, height);
    } else {
      resize();
      start();
    }
  });

  resize();
  start();
})();
