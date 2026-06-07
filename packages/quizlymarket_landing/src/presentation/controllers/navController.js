// Wires the mobile burger menu and the language dropdown.
export function initNav(languageService) {
  const burger = document.getElementById('burger');
  const menu = document.getElementById('menu');
  burger?.addEventListener('click', () => menu.classList.toggle('open'));
  menu?.querySelectorAll('a').forEach((a) =>
    a.addEventListener('click', () => menu.classList.remove('open'))
  );

  const ls = document.getElementById('langSwitch');
  const lsBtn = document.getElementById('lsBtn');
  const lsMenu = document.getElementById('lsMenu');
  if (!lsBtn) return;

  lsBtn.addEventListener('click', (e) => { e.stopPropagation(); ls.classList.toggle('open'); });
  document.addEventListener('click', () => ls.classList.remove('open'));
  lsMenu.querySelectorAll('button').forEach((b) =>
    b.addEventListener('click', () => {
      languageService.set(b.dataset.lang);
      ls.classList.remove('open');
    })
  );
}
