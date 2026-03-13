class QuestionModel {
  QuestionModel({required this.id, required this.question, required this.answers});
  final int id;
  final String question;
  final List<AnswerModel> answers;
}

class AnswerModel {
  AnswerModel({required this.id, required this.text, required this.isCorrect});
  final int id;
  final String text;
  final bool isCorrect;
}
