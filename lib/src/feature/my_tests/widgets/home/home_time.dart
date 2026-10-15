import 'package:ui/ui.dart';

import '../../../../common/extension/context_extension.dart';

/// Localized "N soat oldin" style relative time for the Continue card.
String homeRelativeTime(BuildContext context, DateTime? time) {
  if (time == null) return '';
  final l10n = context.x.l10n;
  var diff = DateTime.now().difference(time);
  if (diff.isNegative) diff = Duration.zero;
  if (diff.inMinutes < 1) return l10n.homeTimeJustNow;
  if (diff.inMinutes < 60) return l10n.homeTimeMinutesAgo(diff.inMinutes);
  if (diff.inHours < 24) return l10n.homeTimeHoursAgo(diff.inHours);
  return l10n.homeTimeDaysAgo(diff.inDays);
}
