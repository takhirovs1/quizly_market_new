import 'package:flutter/gestures.dart';

import '../../ui.dart';
import '../extension/context_extension.dart';

class TermsAndPrivacyText extends StatefulWidget {
  const TermsAndPrivacyText({
    required this.prefix,
    required this.termsText,
    required this.middle,
    required this.privacyText,
    required this.suffix,
    super.key,
    this.onTermsTap,
    this.onPrivacyTap,
  });

  final String prefix;
  final String termsText;
  final String middle;
  final String privacyText;
  final String suffix;

  final VoidCallback? onTermsTap;
  final VoidCallback? onPrivacyTap;

  @override
  State<TermsAndPrivacyText> createState() => _TermsAndPrivacyTextState();
}

class _TermsAndPrivacyTextState extends State<TermsAndPrivacyText> {
  late final TapGestureRecognizer _termsRecognizer;
  late final TapGestureRecognizer _privacyRecognizer;

  @override
  void initState() {
    super.initState();
    _termsRecognizer = TapGestureRecognizer()..onTap = widget.onTermsTap;
    _privacyRecognizer = TapGestureRecognizer()..onTap = widget.onPrivacyTap;
  }

  @override
  void didUpdateWidget(covariant TermsAndPrivacyText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.onTermsTap != widget.onTermsTap) _termsRecognizer.onTap = widget.onTermsTap;
    if (oldWidget.onPrivacyTap != widget.onPrivacyTap) _privacyRecognizer.onTap = widget.onPrivacyTap;
  }

  @override
  void dispose() {
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: widget.prefix),
            TextSpan(
              text: widget.termsText,
              style: TextStyle(color: context.x.colors.primary),
              recognizer: _termsRecognizer,
            ),
            TextSpan(text: widget.middle),
            TextSpan(
              text: widget.privacyText,
              style: TextStyle(color: context.x.colors.primary),
              recognizer: _privacyRecognizer,
            ),
            TextSpan(text: widget.suffix),
          ],
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: context.x.textStyle.sfW400s14.copyWith(color: context.x.colors.black),
        textAlign: TextAlign.center,
      ),
    ),
  );
}
