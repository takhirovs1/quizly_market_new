import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../gen/assets.gen.dart';

/// Animated icons backed by the Lottie files in `lib/lottie`.
///
/// The emoji-style ones ([fire], [lamp], [cup], [prize]) are multi-coloured and
/// should be shown as-is; the line-style menu icons are single-colour and are
/// meant to be tinted via [QuizLottieIcon.color].
enum QuizLottie {
  fire,
  lamp,
  cup,
  prize,
  addFriends,
  archive,
  bookCollection,
  check,
  delete,
  progress,
  revert,
  share,
  urgent;

  String get asset => switch (this) {
    QuizLottie.fire => Assets.lib.lottie.fire,
    QuizLottie.lamp => Assets.lib.lottie.lamp,
    QuizLottie.cup => Assets.lib.lottie.cup,
    QuizLottie.prize => Assets.lib.lottie.prise,
    QuizLottie.addFriends => Assets.lib.lottie.addFriends,
    QuizLottie.archive => Assets.lib.lottie.archive,
    QuizLottie.bookCollection => Assets.lib.lottie.bookCollection,
    QuizLottie.check => Assets.lib.lottie.check,
    QuizLottie.delete => Assets.lib.lottie.delete,
    QuizLottie.progress => Assets.lib.lottie.progress,
    QuizLottie.revert => Assets.lib.lottie.revert,
    QuizLottie.share => Assets.lib.lottie.share,
    QuizLottie.urgent => Assets.lib.lottie.urgent,
  };
}

class QuizLottieIcon extends StatelessWidget {
  const QuizLottieIcon(this.icon, {this.size = 16, this.repeat = true, this.color, super.key});

  final QuizLottie icon;
  final double size;
  final bool repeat;

  /// Tints every fill and stroke of the animation. `null` keeps the original colours.
  final Color? color;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: Lottie.asset(
      icon.asset,
      package: 'ui',
      width: size,
      height: size,
      repeat: repeat,
      fit: BoxFit.contain,
      delegates: color == null
          ? null
          : LottieDelegates(
              values: [
                ValueDelegate.color(const ['**'], value: color),
                ValueDelegate.strokeColor(const ['**'], value: color),
              ],
            ),
    ),
  );
}
