import 'dart:math' show pi;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import '../../../common/extension/context_extension.dart';
import '../model/flashcard_response_model.dart';
import 'flashcard_card_widget.dart';
import 'flashcard_ghost_card.dart';
import 'flashcard_swipe_stamp.dart';

/// Swipeable flashcard deck (02a/02b/02c).
///
/// Motion (per the Figma motion notes):
/// - Horizontal drag only; card follows the finger, rotation = dx/20 (±12°),
///   stamp opacity = |dx|/120, plus a colored edge glow.
/// - Commit threshold: 35% of width OR velocity > 800 px/s → the card flies off
///   in 250ms ease-out (right = Bilaman, left = Bilmayman). Otherwise it springs
///   back (stiffness 300, damping 25).
/// - A ghost "next card" sits behind and animates scale 0.94→1, y 12→0 (200ms)
///   as it becomes the top card.
class FlashcardDeckView extends StatefulWidget {
  const FlashcardDeckView({
    required this.card,
    required this.isFlipped,
    required this.hasNext,
    required this.onFlip,
    required this.onKnown,
    required this.onUnknown,
    required this.swipeProgress,
    super.key,
  });

  final FlashcardCardModel card;
  final bool isFlipped;
  final bool hasNext;
  final VoidCallback onFlip;
  final VoidCallback onKnown;
  final VoidCallback onUnknown;

  /// Signed swipe progress (-1..1) published for the footer buttons.
  final ValueNotifier<double> swipeProgress;

  @override
  State<FlashcardDeckView> createState() => FlashcardDeckViewState();
}

class FlashcardDeckViewState extends State<FlashcardDeckView> with TickerProviderStateMixin {
  late final AnimationController _physics; // unbounded: drives horizontal dx
  late final AnimationController _entrance; // next-card entrance (200ms)
  double _dragDx = 0;
  bool _committing = false;
  double _deckWidth = 0; // cached from LayoutBuilder (avoids reading context.size mid-layout)

  static const double _maxRotationDeg = 12;
  static const double _velocityThreshold = 800;

  @override
  void initState() {
    super.initState();
    _physics = AnimationController.unbounded(vsync: this)
      ..addListener(() {
        setState(() => _dragDx = _physics.value);
        _publishProgress();
      });
    _entrance = AnimationController(vsync: this, duration: const Duration(milliseconds: 200), value: 1);
  }

  @override
  void didUpdateWidget(FlashcardDeckView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.card.id != oldWidget.card.id) {
      _physics.stop();
      _dragDx = 0;
      _committing = false;
      _entrance.forward(from: 0);
    }
  }

  void _publishProgress() {
    final width = _width;
    final commitDistance = width * 0.35;
    widget.swipeProgress.value = commitDistance == 0 ? 0 : (_dragDx / commitDistance).clamp(-1.0, 1.0);
  }

  double get _width => _deckWidth > 0 ? _deckWidth : MediaQuery.sizeOf(context).width;

  @override
  void dispose() {
    _physics.dispose();
    _entrance.dispose();
    super.dispose();
  }

  // ── Public API (called by the footer answer buttons) ──────────────────────
  void flyOff({required bool known}) {
    if (_committing) return;
    _commit(known: known);
  }

  // ── Gestures ──────────────────────────────────────────────────────────────
  void _onDragUpdate(DragUpdateDetails details) {
    if (_committing) return;
    _physics.stop();
    setState(() => _dragDx += details.delta.dx);
    _publishProgress();
  }

  void _onDragEnd(DragEndDetails details) {
    if (_committing) return;
    final width = _width;
    final velocity = details.primaryVelocity ?? 0;
    final passedDistance = _dragDx.abs() > width * 0.35;
    final passedVelocity = velocity.abs() > _velocityThreshold;

    if (passedDistance || passedVelocity) {
      final known = (passedVelocity ? velocity : _dragDx) > 0;
      _commit(known: known);
    } else {
      _springBack(velocity);
    }
  }

  void _commit({required bool known}) {
    _committing = true;
    widget.swipeProgress.value = known ? 1 : -1;
    final target = (known ? 1 : -1) * _width * 1.5;
    context.telegramWebApp.hapticImpact(.light);
    _physics
      ..stop()
      ..value = _dragDx;
    _physics.animateTo(target, duration: const Duration(milliseconds: 250), curve: Curves.easeOut).whenComplete(() {
      if (!mounted) return;
      // Reset the shared progress before advancing: the cubit rebuild that
      // follows runs didUpdateWidget during build, so we must not notify
      // the footer listener there.
      widget.swipeProgress.value = 0;
      known ? widget.onKnown() : widget.onUnknown();
    });
  }

  void _springBack(double velocity) {
    _physics
      ..stop()
      ..value = _dragDx;
    final sim = SpringSimulation(const SpringDescription(mass: 1, stiffness: 300, damping: 25), _dragDx, 0, velocity);
    _physics.animateWith(sim);
  }

  @override
  Widget build(BuildContext context) {
    final rotation = (_dragDx / 20).clamp(-_maxRotationDeg, _maxRotationDeg) * pi / 180;
    final stampOpacity = (_dragDx.abs() / 120).clamp(0.0, 1.0);
    final known = _dragDx >= 0;

    return Padding(
      // Vertical-only padding: the Stack spans the full width so the edge glow
      // can bleed to the screen edges. Cards get their own horizontal inset.
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: LayoutBuilder(
        builder: (context, c) {
          _deckWidth = c.maxWidth;
          final cardW = (c.maxWidth - 32).clamp(0.0, 420.0);
          final cardH = (c.maxHeight - 44).clamp(0.0, 520.0);
          return SizedBox(
            width: c.maxWidth,
            height: c.maxHeight,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // Note: the colored swipe glow is rendered full-bleed at the
                // screen level (flashcard_screen.dart) so it spans the whole
                // screen width, not just this width-capped deck.

                // Ghost cards behind: narrower and lower so they peek at the bottom (02b).
                if (widget.hasNext) FlashcardGhostCard(width: cardW - 44, height: cardH, translateY: 22),
                if (widget.hasNext) FlashcardGhostCard(width: cardW - 22, height: cardH, translateY: 11),

                // Top (interactive) card.
                AnimatedBuilder(
                  animation: _entrance,
                  builder: (context, child) {
                    final t = Curves.easeOut.transform(_entrance.value);
                    final enterScale = 0.94 + 0.06 * t;
                    final enterDy = 12 * (1 - t);
                    return Transform.translate(
                      offset: Offset(_dragDx, enterDy),
                      child: Transform.rotate(
                        angle: rotation,
                        child: Transform.scale(scale: enterScale, child: child),
                      ),
                    );
                  },
                  child: SizedBox(
                    width: cardW,
                    height: cardH,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: widget.onFlip,
                      onHorizontalDragUpdate: _onDragUpdate,
                      onHorizontalDragEnd: _onDragEnd,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned.fill(
                            child: FlashcardCardWidget(
                              card: widget.card,
                              isFlipped: widget.isFlipped,
                              onFlip: widget.onFlip,
                            ),
                          ),
                          // Swipe stamp.
                          if (stampOpacity > 0.01)
                            Positioned(
                              top: 28,
                              left: known ? 24 : null,
                              right: known ? null : 24,
                              child: Opacity(
                                opacity: stampOpacity,
                                child: Transform.rotate(
                                  angle: (known ? -10 : 10) * pi / 180,
                                  child: FlashcardSwipeStamp(known: known),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
