// Soft spotlight glow + ring cursor with a click pulse. Disabled on touch devices.
export function initCursorFx() {
  if (window.matchMedia('(hover:none)').matches) return;
  const spot = document.getElementById('spot');
  const ring = document.getElementById('ring');
  if (!spot || !ring) return;

  let mx = innerWidth / 2, my = innerHeight / 2;
  let sx = mx, sy = my, rx = mx, ry = my, scale = 1, scaleTarget = 1, shown = false;

  addEventListener('mousemove', (e) => {
    mx = e.clientX; my = e.clientY;
    if (!shown) { shown = true; spot.style.opacity = 1; ring.style.opacity = 1; }
  });
  addEventListener('mouseout', (e) => {
    if (!e.relatedTarget) { spot.style.opacity = 0; ring.style.opacity = 0; shown = false; }
  });
  addEventListener('mousedown', () => (scaleTarget = 1.8));
  addEventListener('mouseup', () => (scaleTarget = 1));

  const lerp = (a, b, n) => a + (b - a) * n;
  (function loop() {
    sx = lerp(sx, mx, 0.12); sy = lerp(sy, my, 0.12);
    rx = lerp(rx, mx, 0.25); ry = lerp(ry, my, 0.25);
    scale = lerp(scale, scaleTarget, 0.2);
    spot.style.transform = `translate(${sx}px,${sy}px) translate(-50%,-50%)`;
    ring.style.transform = `translate(${rx}px,${ry}px) translate(-50%,-50%) scale(${scale})`;
    requestAnimationFrame(loop);
  })();
}
