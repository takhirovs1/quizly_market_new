import 'package:flutter/material.dart';
import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../../my_tests/models/test_model.dart';
import '../../my_tests/widgets/test_description_widget.dart';

/// Left-hand info card for the flashcard setup web layout: a gradient banner
/// header followed by the shared [TestDescriptionWidget]. Mirrors the custom
/// mode screen's web layout so both screens feel the same on desktop.
class FlashcardWebInfoCard extends StatelessWidget {
  const FlashcardWebInfoCard({
    required this.testModel,
    required this.onPressLike,
    required this.onPressShare,
    this.onPressArchive,
    super.key,
  });

  final TestModel testModel;
  final VoidCallback onPressLike;
  final VoidCallback onPressShare;
  final VoidCallback? onPressArchive;

  @override
  Widget build(BuildContext context) {
    final colors = context.x.colors;
    return Container(
      decoration: BoxDecoration(
        color: colors.cardBackground2,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.primary.withValues(alpha: 0.1), width: 1.5),
        boxShadow: [BoxShadow(color: colors.black.withValues(alpha: 0.05), blurRadius: 24, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gradient banner header.
          Container(
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colors.primary, colors.primary.withValues(alpha: 0.7)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(23), topRight: Radius.circular(23)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(color: colors.white.withValues(alpha: 0.15), shape: BoxShape.circle),
                  child: Icon(Icons.style_rounded, color: colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'QuizlyMarket',
                        style: context.x.textStyle.sfW600s16.copyWith(
                          color: colors.white,
                          fontSize: 11,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        context.x.l10n.flashcardModeTitle,
                        style: context.x.textStyle.sfW600s16.copyWith(color: colors.white, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Content.
          Padding(
            padding: const EdgeInsets.all(20),
            child: TestDescriptionWidget(
              test: testModel,
              onPressLike: onPressLike,
              onPressShare: onPressShare,
              onPressArchive: onPressArchive,
            ),
          ),
        ],
      ),
    );
  }
}
