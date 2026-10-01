import 'dart:math' show pi;

import 'package:flutter/material.dart';

import '../../../common/extension/context_extension.dart';
import '../model/flashcard_response_model.dart';

class FlashcardCardWidget extends StatefulWidget {
  const FlashcardCardWidget({
    required this.card,
    required this.isFlipped,
    required this.onTap,
    super.key,
  });

  final FlashcardCardModel card;
  final bool isFlipped;
  final VoidCallback onTap;

  @override
  State<FlashcardCardWidget> createState() => _FlashcardCardWidgetState();
}

class _FlashcardCardWidgetState extends State<FlashcardCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _showBack = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.addListener(() {
      final showBack = _controller.value >= 0.5;
      if (showBack != _showBack) {
        setState(() => _showBack = showBack);
      }
    });
  }

  @override
  void didUpdateWidget(FlashcardCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFlipped != oldWidget.isFlipped) {
      if (widget.isFlipped) {
        _controller.forward();
      } else {
        _controller.reverse();
        _showBack = false;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: widget.onTap,
    child: AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final angle = _animation.value * pi;
        final isFirstHalf = angle < pi / 2;
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle),
          child: isFirstHalf
              ? _CardFace(text: widget.card.front, imageUrl: widget.card.imageUrl, isFront: true)
              : Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..rotateY(pi),
                  child: _CardFace(
                    text: widget.card.back,
                    imageUrl: widget.card.imageUrl,
                    isFront: false,
                    explanation: widget.card.explanation,
                  ),
                ),
        );
      },
    ),
  );
}

class _CardFace extends StatelessWidget {
  const _CardFace({
    required this.text,
    required this.isFront,
    this.imageUrl,
    this.explanation,
  });

  final String text;
  final bool isFront;
  final String? imageUrl;
  final String? explanation;

  @override
  Widget build(BuildContext context) {
    final colors = context.x.colors;
    final textStyles = context.x.textStyle;

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: MediaQuery.sizeOf(context).height * 0.52),
      decoration: BoxDecoration(
        color: isFront ? colors.cardBackground2 : colors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isFront
              ? colors.primary.withValues(alpha: 0.15)
              : colors.primary.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.black.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (!isFront)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Javob',
                style: textStyles.sfW500s14.copyWith(color: colors.primary, fontSize: 12),
              ),
            ),
          if (imageUrl != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl!,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
            const SizedBox(height: 20),
          ],
          Text(
            text,
            textAlign: TextAlign.center,
            style: textStyles.sfW500s16.copyWith(
              fontSize: 18,
              height: 1.5,
              color: colors.text,
            ),
          ),
          if (explanation != null && explanation!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Divider(color: colors.divider),
            const SizedBox(height: 12),
            Text(
              explanation!,
              textAlign: TextAlign.center,
              style: textStyles.sfW400s14.copyWith(color: colors.gray, height: 1.4),
            ),
          ],
          const SizedBox(height: 8),
          if (isFront)
            Text(
              '👆 Bosing',
              style: textStyles.sfW400s14.copyWith(color: colors.gray, fontSize: 12),
            ),
        ],
      ),
    );
  }
}
