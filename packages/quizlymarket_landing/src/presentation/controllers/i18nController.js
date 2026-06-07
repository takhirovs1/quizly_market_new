import { messages, heroTitle } from '../../data/i18n/index.js';
import { LANG_META } from '../../core/constants.js';

// Applies translations to [data-i18n] / [data-i18n-html] nodes and reacts to language changes.
export function initI18n(languageService) {
  const lsFlag = document.getElementById('lsFlag');
  const lsCode = document.getElementById('lsCode');
  const lsMenu = document.getElementById('lsMenu');

  function apply(lang) {
    const dict = messages[lang] || {};
    document.querySelectorAll('[data-i18n]').forEach((el) => {
      const k = el.getAttribute('data-i18n');
      if (dict[k] != null) el.textContent = dict[k];
    });
    document.querySelectorAll('[data-i18n-html]').forEach((el) => {
      el.innerHTML = heroTitle[lang];
    });
    if (lsFlag) lsFlag.textContent = LANG_META[lang][0];
    if (lsCode) lsCode.textContent = LANG_META[lang][1];
    document.documentElement.setAttribute('lang', lang);
    lsMenu?.querySelectorAll('button').forEach((b) =>
      b.classList.toggle('active', b.dataset.lang === lang)
    );
  }

  languageService.subscribe(apply);
  apply(languageService.current);
}
