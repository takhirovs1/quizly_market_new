import { QUIZ_TOTAL, QUIZ_QUESTION_MS } from '../../core/constants.js';
import { QuizEngine } from '../../domain/usecases/QuizEngine.js';
import { getQuestions } from '../../data/quiz/quiz.repository.js';

// Binds the QuizEngine to the phone-mockup DOM: timer, ring, options, progress.
export function initQuiz(languageService) {
  const $ = (id) => document.getElementById(id);
  const ringEl = $('ring2'), tsec = $('tsec'), qtext = $('qtext'),
        opts = $('opts'), subj = $('subj'), counter = $('counter'), pillsEl = $('pills');
  const nextBtn = document.querySelector('.nextbtn');
  if (!ringEl || !opts) return;

  const RADIUS_C = 2 * Math.PI * 12;
  ringEl.style.strokeDasharray = RADIUS_C;
  const cells = [...opts.children];

  const engine = new QuizEngine({
    total: QUIZ_TOTAL,
    getQuestions: () => getQuestions(languageService.current),
  });

  // Independent real-time clock (1s per second).
  let remain = 6 * 60 + 39;
  const fmt = (s) => `${String(Math.floor(s / 60)).padStart(2, '0')}:${String(s % 60).padStart(2, '0')}`;
  tsec.textContent = fmt(remain);
  setInterval(() => { if (remain > 0) { remain--; tsec.textContent = fmt(remain); } }, 1000);

  let revealTimer, advanceTimer;
  const paintPills = () => [...pillsEl.children].forEach((b, i) => (b.className = engine.pills[i] || ''));
  const fillOptions = (q) => cells.forEach((el, i) => {
    el.className = 'opt';
    el.querySelector('.txt').textContent = q.options[i] || '';
  });

  function render() {
    const q = engine.current();
    subj.textContent = q.subject;
    qtext.textContent = q.text;
    counter.textContent = engine.counterLabel();
    fillOptions(q);
    paintPills();

    ringEl.style.transition = 'none';
    ringEl.style.strokeDashoffset = 0;
    requestAnimationFrame(() => {
      ringEl.style.transition = `stroke-dashoffset ${QUIZ_QUESTION_MS}ms linear`;
      ringEl.style.strokeDashoffset = RADIUS_C;
    });

    clearTimeout(revealTimer); clearTimeout(advanceTimer);
    revealTimer = setTimeout(() => { if (!engine.answered) cells[q.correctIndex].classList.add('correct'); }, QUIZ_QUESTION_MS * 0.72);
    advanceTimer = setTimeout(() => { engine.advance(); render(); }, QUIZ_QUESTION_MS);
  }

  cells.forEach((el, i) =>
    el.addEventListener('click', () => {
      const r = engine.pick(i);
      if (!r) return;
      clearTimeout(revealTimer);
      if (r.isCorrect) cells[i].classList.add('correct');
      else { cells[i].classList.add('wrong'); cells[r.correctIndex].classList.add('correct'); }
    })
  );
  nextBtn?.addEventListener('click', () => { engine.advance(); render(); });

  // Re-translate the visible question when the language changes.
  languageService.subscribe(() => {
    const q = engine.current();
    subj.textContent = q.subject;
    qtext.textContent = q.text;
    cells.forEach((el, i) => { el.querySelector('.txt').textContent = q.options[i] || ''; });
  });

  render();
}
