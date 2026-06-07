import { quizData } from './quiz.data.js';
import { Question } from '../../domain/models/Question.js';

// Maps the raw data source into domain Question entities for a language.
export function getQuestions(lang) {
  const list = quizData[lang] || quizData.uz;
  return list.map((q) => new Question(q.subj, q.q, q.o, q.c));
}
