// Animated count-up for the hero statistics.
export function initCounters() {
  const animate = (el) => {
    const to = +el.dataset.to;
    const suffix = el.dataset.suffix || '';
    const duration = 1400;
    const start = performance.now();
    (function tick(now) {
      const p = Math.min((now - start) / duration, 1);
      const eased = 1 - Math.pow(1 - p, 3);
      el.textContent =
        Math.round(to * eased).toLocaleString('en-US').replace(/,/g, ' ') + (p >= 1 ? suffix : '');
      if (p < 1) requestAnimationFrame(tick);
    })(start);
  };
  const io = new IntersectionObserver(
    (entries) => entries.forEach((e) => {
      if (e.isIntersecting) { animate(e.target); io.unobserve(e.target); }
    }),
    { threshold: 0.6 }
  );
  document.querySelectorAll('.count').forEach((el) => io.observe(el));
}
