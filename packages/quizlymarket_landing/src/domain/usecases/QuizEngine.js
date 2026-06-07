// Use case: pure quiz state machine (no DOM, no timers).
// Tracks progress pills, current question and answer state.
export class QuizEngine {
  constructor({ total = 25, getQuestions }) {
    this.total = total;
    this.getQuestions = getQuestions;     // () => Question[]
    this.absIndex = 4;                    // 0-based question number in the whole test
    this.qi = 0;                          // index into the demo question list
    this.answered = false;
    this.pills = ['no', 'no', 'ok', 'no', 'cur', '', '', '']; // 8 progress chips
  }

  current() {
    const q = this.getQuestions();
    return q[this.qi % q.length];
  }

  // Returns null if already answered, otherwise the resolution.
  pick(i) {
    if (this.answered) return null;
    this.answered = true;
    const q = this.current();
    return { selected: i, correctIndex: q.correctIndex, isCorrect: q.isCorrect(i) };
  }

  advance() {
    const pi = this.absIndex % 8;
    this.pills[pi] = 'ok';
    const next = (pi + 1) % 8;
    if (next === 0) this.pills = Array(8).fill(''); // new row of 8
    this.pills[next] = 'cur';
    this.absIndex = (this.absIndex + 1) % this.total;
    this.qi = (this.qi + 1) % this.getQuestions().length;
    this.answered = false;
    return this.current();
  }

  counterLabel() { return `${this.absIndex + 1}/${this.total}`; }
}
