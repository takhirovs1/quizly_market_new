import 'package:flutter/material.dart';

import '../extension/context_extension.dart';

/// Simple section heading used in info/settings screens.
class SectionTitle extends StatelessWidget {
  const SectionTitle({required this.title, required this.color, super.key});

  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) => Text(title, style: context.x.textStyle.sfW700s18.copyWith(color: color));
}
