import 'package:ui/ui.dart';

import '../../my_tests/models/test_mode.dart';
import '../screens/test_mode_screen.dart';

abstract class TestModeScreenState extends State<TestModeScreen> {
  final TestModel test = TestModel(
    id: 1,
    title: 'O’zbekistonning eng yangi tarixi fanidan testlar',
    description: 'O’zbekiston tarixi bo‘yicha test savollari',
    author: 'Toshkent Davlat Iqtisodiyot Universiteti',
    price: 20000,
    questions: [
      QuestionModel(
        id: 1,
        question: 'O’zbekiston qachon davlat mustaqilligini e’lon qilgan?',
        answers: [
          AnswerModel(id: 1, text: '1990-yil 20-iyun', isCorrect: false),
          AnswerModel(id: 2, text: '1991-yil 31-avgust', isCorrect: true),
          AnswerModel(id: 3, text: '1992-yil 8-dekabr', isCorrect: false),
          AnswerModel(id: 4, text: '1993-yil 1-yanvar', isCorrect: false),
        ],
      ),
      QuestionModel(
        id: 2,
        question: 'O’zbekiston Respublikasi Konstitutsiyasi qachon qabul qilingan?',
        answers: [
          AnswerModel(id: 1, text: '1992-yil 8-dekabr', isCorrect: true),
          AnswerModel(id: 2, text: '1991-yil 31-avgust', isCorrect: false),
          AnswerModel(id: 3, text: '1993-yil 1-yanvar', isCorrect: false),
          AnswerModel(id: 4, text: '1995-yil 9-may', isCorrect: false),
        ],
      ),
      QuestionModel(
        id: 3,
        question: 'O’zbekiston poytaxti qaysi shahar?',
        answers: [
          AnswerModel(id: 1, text: 'Samarqand', isCorrect: false),
          AnswerModel(id: 2, text: 'Buxoro', isCorrect: false),
          AnswerModel(id: 3, text: 'Toshkent', isCorrect: true),
          AnswerModel(id: 4, text: 'Andijon', isCorrect: false),
        ],
      ),
      QuestionModel(
        id: 4,
        question: 'O’zbekiston bayrog‘i qachon tasdiqlangan?',
        answers: [
          AnswerModel(id: 1, text: '1991-yil 18-noyabr', isCorrect: true),
          AnswerModel(id: 2, text: '1992-yil 8-dekabr', isCorrect: false),
          AnswerModel(id: 3, text: '1993-yil 1-yanvar', isCorrect: false),
          AnswerModel(id: 4, text: '1990-yil 20-iyun', isCorrect: false),
        ],
      ),
      QuestionModel(
        id: 5,
        question: 'O’zbekiston davlat gerbi qachon qabul qilingan?',
        answers: [
          AnswerModel(id: 1, text: '1992-yil 2-iyul', isCorrect: true),
          AnswerModel(id: 2, text: '1991-yil 31-avgust', isCorrect: false),
          AnswerModel(id: 3, text: '1993-yil 1-yanvar', isCorrect: false),
          AnswerModel(id: 4, text: '1995-yil 9-may', isCorrect: false),
        ],
      ),
    ],
  );
  void onPressLike() {}
  void onPressShare() {}
}
