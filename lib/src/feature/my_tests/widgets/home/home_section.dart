import 'package:ui/ui.dart';

import '../../../../common/extension/context_extension.dart';
import '../../../../common/util/state_status.dart';

/// Maps one Home section's [StateStatus] to skeleton / inline-error / content.
/// Idle + loading show the [skeleton]; error shows a retry card; success shows
/// [child]. Each section is independent, so one error never blocks the rest.
class HomeSection extends StatelessWidget {
  const HomeSection({
    required this.status,
    required this.skeleton,
    required this.onRetry,
    required this.child,
    this.errorMessage,
    super.key,
  });

  final StateStatus status;
  final Widget skeleton;
  final VoidCallback onRetry;
  final Widget child;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    if (status.isError) {
      final l10n = context.x.l10n;
      return QuizInlineError(
        title: l10n.homeInlineErrorTitle,
        message: errorMessage ?? l10n.homeInlineErrorBody,
        retryLabel: l10n.homeRetry,
        onRetry: onRetry,
      );
    }
    if (status.isSuccess) return child;
    return skeleton;
  }
}
