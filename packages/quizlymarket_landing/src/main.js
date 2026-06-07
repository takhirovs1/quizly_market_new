// App composition root: wires data → domain → presentation.
import './presentation/styles/index.css';

import { LanguagePreferenceRepository } from './data/repositories/LanguagePreferenceRepository.js';
import { LanguageService } from './domain/usecases/LanguageService.js';

import { initI18n } from './presentation/controllers/i18nController.js';
import { initNav } from './presentation/controllers/navController.js';
import { initReveal } from './presentation/controllers/revealController.js';
import { initCounters } from './presentation/controllers/countersController.js';
import { initQuiz } from './presentation/controllers/quizController.js';
import { initDotField } from './presentation/effects/dotField.js';
import { initCursorFx } from './presentation/effects/cursorFx.js';

function boot() {
  const languageService = new LanguageService(new LanguagePreferenceRepository());

  initI18n(languageService);
  initNav(languageService);
  initReveal();
  initCounters();
  initQuiz(languageService);
  initDotField();
  initCursorFx();
}

if (document.readyState !== 'loading') boot();
else document.addEventListener('DOMContentLoaded', boot);
