import 'package:flutter/material.dart';

import '../../../common/extension/context_extension.dart';

class TestModeItemWidget extends StatefulWidget {
  const TestModeItemWidget({
    required this.title,
    required this.description,
    required this.image,
    required this.onPressed,
    this.isComingSoon = false,
    super.key,
  });

  final String title;
  final String description;
  final Widget image;
  final VoidCallback onPressed;
  final bool isComingSoon;

  @override
  State<TestModeItemWidget> createState() => _TestModeItemWidgetState();
}

class _TestModeItemWidgetState extends State<TestModeItemWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.x.colors;
    final textStyle = context.x.textStyle;

    final isActive = !widget.isComingSoon;
    final borderColor = _isHovered && isActive ? colors.primary : colors.black.withValues(alpha: 0.06);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: isActive ? widget.onPressed : null,
        child: AnimatedScale(
          scale: _isHovered && isActive ? 1.03 : 1.0,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Card dimensions — always bounded because StackFit.expand
              final cardH = constraints.maxHeight.isFinite ? constraints.maxHeight : 160.0;
              final cardW = constraints.maxWidth.isFinite ? constraints.maxWidth : 160.0;
              final minSide = cardW < cardH ? cardW : cardH;

              // Responsive scaling
              final circleSize = (minSide * 0.32).clamp(28.0, 60.0);
              final iconPadding = (circleSize * 0.28).clamp(7.0, 15.0);
              final titleFontSize = (minSide * 0.090).clamp(11.0, 16.0);
              final descFontSize = (minSide * 0.065).clamp(9.0, 12.0);
              final gapAbove = (cardH * 0.06).clamp(4.0, 14.0);
              final gapBelow = (cardH * 0.03).clamp(2.0, 6.0);
              final hPad = (cardW * 0.07).clamp(4.0, 14.0);

              return Stack(
                // ── KEY FIX: expand forces ALL cards to fill the GridView cell ──
                fit: .expand,
                clipBehavior: .none,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    decoration: BoxDecoration(
                      color: colors.cardBackground2,
                      borderRadius: .circular(20),
                      border: .all(color: borderColor, width: _isHovered && isActive ? 2.0 : 1.0),
                      boxShadow: [
                        BoxShadow(
                          color: isActive
                              ? colors.primary.withValues(alpha: _isHovered ? 0.12 : 0.04)
                              : colors.black.withValues(alpha: 0.04),
                          offset: const Offset(0, 6),
                          blurRadius: _isHovered && isActive ? 20 : 12,
                          spreadRadius: 0,
                        ),
                        BoxShadow(
                          color: colors.black.withValues(alpha: 0.03),
                          offset: .zero,
                          blurRadius: 3,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: .symmetric(horizontal: hPad, vertical: 4),
                      child: Column(
                        crossAxisAlignment: .center,
                        mainAxisAlignment: .center,
                        children: [
                          // Icon circle
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: isActive ? colors.primary : colors.gray.withValues(alpha: 0.3),
                              shape: .circle,
                            ),
                            child: Padding(
                              padding: .all(iconPadding),
                              child: SizedBox(
                                width: circleSize - iconPadding * 2,
                                height: circleSize - iconPadding * 2,
                                child: FittedBox(fit: .contain, child: widget.image),
                              ),
                            ),
                          ),
                          SizedBox(height: gapAbove),
                          // Title
                          Text(
                            widget.title,
                            style: textStyle.sfW600s16.copyWith(
                              color: isActive ? colors.text : colors.gray,
                              fontSize: titleFontSize,
                              height: 1.2,
                            ),
                            textAlign: .center,
                            maxLines: 1,
                            overflow: .ellipsis,
                          ),
                          SizedBox(height: gapBelow),
                          // Description
                          Text(
                            widget.description,
                            style: textStyle.sfW400s12.copyWith(
                              color: colors.gray,
                              fontSize: descFontSize,
                              height: 1.3,
                            ),
                            textAlign: .center,
                            maxLines: 2,
                            overflow: .ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Coming Soon badge — positioned child, unaffected by StackFit.expand
                  if (widget.isComingSoon)
                    Positioned(
                      top: 7,
                      right: 7,
                      child: Container(
                        padding: const .symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(color: colors.primary, borderRadius: .circular(20)),
                        child: Text(
                          context.x.l10n.comingSoon,
                          style: textStyle.sfW500s11.copyWith(color: colors.white, fontSize: 8, fontWeight: .w600),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
