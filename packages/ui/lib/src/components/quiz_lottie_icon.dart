import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// SVG icons backed by the files in `lib/icon` (prefixed `q_`).
///
/// The emoji-style ones ([fire], [lamp], [cup], [prize]) are multi-coloured and
/// should be shown as-is; the line-style ones are single-colour and are
/// meant to be tinted via [QuizLottieIcon.color].
enum QuizLottie {
  fire('q_fire'),
  lamp('q_lamp'),
  cup('q_cup'),
  prize('q_prize'),
  addFriends('q_add_friends'),
  archive('q_archive'),
  bookCollection('q_book_collection'),
  check('q_check'),
  delete('q_delete'),
  progress('q_progress'),
  revert('q_revert'),
  share('q_share'),
  urgent('q_urgent');

  const QuizLottie(this._name);

  final String _name;

  String get asset => 'lib/icon/$_name.svg';
}

class QuizLottieIcon extends StatelessWidget {
  // [repeat] is kept for call-site compatibility; SVG icons are static.
  const QuizLottieIcon(this.icon, {this.size = 16, this.repeat = true, this.color, super.key});

  final QuizLottie icon;
  final double size;
  final bool repeat;

  /// Tints the whole icon. `null` keeps the original colours.
  final Color? color;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: SvgPicture.asset(
      icon.asset,
      package: 'ui',
      width: size,
      height: size,
      fit: BoxFit.contain,
      colorFilter: color == null ? null : ColorFilter.mode(color!, BlendMode.srcIn),
    ),
  );
}
