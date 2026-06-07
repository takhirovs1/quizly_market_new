// Domain entity: a single quiz question.
export class Question {
  constructor(subject, text, options, correctIndex) {
    this.subject = subject;
    this.text = text;
    this.options = options;          // string[]
    this.correctIndex = correctIndex; // index into options
  }
  isCorrect(i) { return i === this.correctIndex; }
}
