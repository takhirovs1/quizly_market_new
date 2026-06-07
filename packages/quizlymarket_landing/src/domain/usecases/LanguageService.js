import { LANG_META, DEFAULT_LANG } from '../../core/constants.js';

// Use case: holds the current language, persists it and notifies subscribers.
export class LanguageService {
  constructor(repository, fallback = DEFAULT_LANG) {
    this.repo = repository;
    const saved = repository.get();
    this._lang = saved && LANG_META[saved] ? saved : fallback;
    this._subs = new Set();
  }
  get current() { return this._lang; }
  get available() { return Object.keys(LANG_META); }

  set(lang) {
    if (!LANG_META[lang]) return;
    this._lang = lang;
    this.repo.save(lang);
    this._emit();
  }
  subscribe(fn) { this._subs.add(fn); return () => this._subs.delete(fn); }
  _emit() { this._subs.forEach((fn) => fn(this._lang)); }
}
