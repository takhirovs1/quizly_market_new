import 'dart:math' show pi;

import 'package:flutter/material.dart';

import '../model/flashcard_response_model.dart';
import 'flashcard_card_faces.dart';
import 'flashcard_card_parts.dart';

/// Study flashcard with a 3D Y-flip between the question (front) and the
/// answer (back). Flip: rotateY 0→180°, 400ms, cubic(0.4, 0, 0.2, 1), content
/// swaps at 90° with the back face mirror-corrected (02a ↔ 02b).
class FlashcardCardWidget extends StatefulWidget {
  const FlashcardCardWidget({required this.card, required this.isFlipped, required this.onFlip, super.key});

  final FlashcardCardModel card;
  final bool isFlipped;
  final VoidCallback onFlip;

  @override
  State<FlashcardCardWidget> createState() => _FlashcardCardWidgetState();
}

class _FlashcardCardWidgetState extends State<FlashcardCardWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _animation = CurvedAnimation(parent: _controller, curve: const Cubic(0.4, 0, 0.2, 1));
    if (widget.isFlipped) _controller.value = 1;
  }

  @override
  void didUpdateWidget(FlashcardCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFlipped != oldWidget.isFlipped) {
      widget.isFlipped ? _controller.forward() : _controller.reverse();
    }
    // A new card always starts on its front.
    if (widget.card.id != oldWidget.card.id && !widget.isFlipped) {
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _animation,
    builder: (context, _) {
      final angle = _animation.value * pi;
      final showFront = angle < pi / 2;
      return Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateY(angle),
        child: showFront
            ? FlashcardCardShell(
                child: FlashcardCardFront(card: widget.card, onFlip: widget.onFlip),
              )
            : Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()..rotateY(pi),
                child: FlashcardCardShell(
                  child: FlashcardCardBack(card: widget.card, onFlip: widget.onFlip),
                ),
              ),
      );
    },
  );
}
