import { STORAGE_KEY } from '../../core/constants.js';

// Infrastructure: persists the chosen language (localStorage).
export class LanguagePreferenceRepository {
  get() {
    try { return localStorage.getItem(STORAGE_KEY); } catch { return null; }
  }
  save(lang) {
    try { localStorage.setItem(STORAGE_KEY, lang); } catch { /* storage unavailable */ }
  }
}
