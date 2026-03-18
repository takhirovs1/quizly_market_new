import '../../ui.dart';
import '../extension/context_extension.dart';

class TermsAndPrivacyText extends StatelessWidget {
  const TermsAndPrivacyText({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        child: Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: context.x.textStyle.sfW400s14.copyWith(color: context.x.colors.gray),
          textAlign: TextAlign.center,
        ),
      ),
    );
}
