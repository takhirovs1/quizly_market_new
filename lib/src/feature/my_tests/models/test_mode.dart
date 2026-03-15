class TestModel {
  TestModel({
    required this.id,
    required this.title,
    required this.description,
    required this.author,
    required this.price,
    required this.questions,
  });

  final int id;
  final String title;
  final String description;
  final String author;
  final int price;
  final List<QuestionModel> questions;
}

class QuestionModel {
  QuestionModel({required this.id, required this.question, required this.answers});

  final int id;
  final String question;
  final List<AnswerModel> answers;
}
class AnswerModel {
  AnswerModel({
    required this.id,
    required this.text,
    required this.isCorrect,
  });

  final int id;
  final String text;
  final bool isCorrect;
}