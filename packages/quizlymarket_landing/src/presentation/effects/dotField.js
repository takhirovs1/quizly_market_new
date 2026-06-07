// Interactive hero dot field: dots repel from the cursor and grow, then ease back.
export function initDotField() {
  const sec = document.querySelector('.hero');
  const cv = document.getElementById('hdots');
  if (!sec || !cv) return;
  const ctx = cv.getContext('2d');
  const dpr = Math.min(window.devicePixelRatio || 1, 2);
  const GAP = 30, RADIUS = 130, FORCE = 28;
  let dots = [], W = 0, H = 0, mx = -999, my = -999;

  function build() {
    const r = sec.getBoundingClientRect();
    W = cv.width = r.width * dpr; H = cv.height = r.height * dpr;
    cv.style.width = r.width + 'px'; cv.style.height = r.height + 'px';
    dots = [];
    for (let y = GAP; y < r.height; y += GAP)
      for (let x = GAP; x < r.width; x += GAP) dots.push({ hx: x, hy: y, x, y });
  }
  build();
  window.addEventListener('resize', build);
  sec.addEventListener('mousemove', (e) => {
    const r = sec.getBoundingClientRect(); mx = e.clientX - r.left; my = e.clientY - r.top;
  });
  sec.addEventListener('mouseleave', () => { mx = -999; my = -999; });

  (function loop() {
    ctx.clearRect(0, 0, W, H);
    for (const d of dots) {
      const dx = d.hx - mx, dy = d.hy - my, dist = Math.hypot(dx, dy);
      let tx = d.hx, ty = d.hy, sc = 1;
      if (dist < RADIUS) {
        const f = 1 - dist / RADIUS, a = Math.atan2(dy, dx);
        tx = d.hx + Math.cos(a) * f * FORCE; ty = d.hy + Math.sin(a) * f * FORCE; sc = 1 + f * 1.6;
      }
      d.x += (tx - d.x) * 0.15; d.y += (ty - d.y) * 0.15;
      const op = Math.min(0.22 + (sc - 1) * 0.45, 0.8);
      ctx.beginPath();
      ctx.fillStyle = `rgba(255,255,255,${op})`;
      ctx.arc(d.x * dpr, d.y * dpr, 1.3 * sc * dpr, 0, Math.PI * 2);
      ctx.fill();
    }
    requestAnimationFrame(loop);
  })();
}
