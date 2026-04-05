import 'package:ui/ui.dart';

class TestModeModel {
  TestModeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    required this.type,
  });

  final int id;
  final String title;
  final String description;
  final SvgGenImage  image;
  final TestMode type;
}

enum TestMode { custom, university, group, flashcard }
