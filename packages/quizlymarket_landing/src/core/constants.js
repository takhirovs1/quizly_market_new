// Cross-cutting constants (no DOM, no business logic).
export const DEFAULT_LANG = 'uz';
export const STORAGE_KEY = 'qm_lang';

export const QUIZ_TOTAL = 25;
export const QUIZ_QUESTION_MS = 10_000; // each question lasts 10s, then auto-advances

// [flag, short code] per supported language
export const LANG_META = {
  uz: ['🇺🇿', 'UZ'],
  ru: ['🇷🇺', 'RU'],
  en: ['🇬🇧', 'EN'],
  kk: ['🇰🇿', 'KK'],
};

export const BRAND = { blue: '#1C59F2', cyan: '#41D6FF', ink: '#0A1330' };
