import 'package:ui/ui.dart';

import '../../../../common/extension/context_extension.dart';
import '../../models/home/ads_model.dart';

/// Figma "Sponsor Card" + carousel — native home ads. A swipeable track with
/// page dots; ✕ dismisses (handled by [onDismiss]).
class SponsorCarousel extends StatefulWidget {
  const SponsorCarousel({
    required this.ads,
    required this.onTapAd,
    required this.onDismiss,
    required this.onImpression,
    super.key,
  });

  final List<AdItem> ads;
  final void Function(AdItem ad) onTapAd;
  final void Function(AdItem ad) onDismiss;
  final void Function(AdItem ad) onImpression;

  @override
  State<SponsorCarousel> createState() => _SponsorCarouselState();
}

class _SponsorCarouselState extends State<SponsorCarousel> {
  final _controller = PageController(viewportFraction: 0.97);
  int _page = 0;

  @override
  void initState() {
    super.initState();
    if (widget.ads.isNotEmpty) widget.onImpression(widget.ads.first);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hc = context.x.homeColors;
    final ads = widget.ads;
    return Column(
      children: [
        SizedBox(
          height: 232,
          child: PageView.builder(
            controller: _controller,
            itemCount: ads.length,
            onPageChanged: (i) {
              setState(() => _page = i);
              widget.onImpression(ads[i]);
            },
            itemBuilder: (context, i) => Padding(
              padding: EdgeInsets.only(right: i == ads.length - 1 ? 0 : 8),
              child: SponsorCard(
                ad: ads[i],
                index: i,
                onTap: () => widget.onTapAd(ads[i]),
                onDismiss: () => widget.onDismiss(ads[i]),
              ),
            ),
          ),
        ),
        if (ads.length > 1) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < ads.length; i++) ...[
                if (i > 0) const SizedBox(width: 6),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: i == _page ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: i == _page ? hc.primary : hc.border,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

class SponsorCard extends StatelessWidget {
  const SponsorCard({required this.ad, required this.index, required this.onTap, required this.onDismiss, super.key});

  final AdItem ad;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  static List<List<Color>> _gradients(BuildContext context) {
    final colors = context.x.colors;
    return [
      [context.x.homeColors.heroGradientStart, colors.brandCyan],
      [colors.sponsorOrange, colors.sponsorPink],
      [colors.violet, colors.brandCyan],
    ];
  }

  String get _initials {
    final parts = ad.sponsorName.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final hc = context.x.homeColors;
    final gradients = _gradients(context);
    final gradient = gradients[index % gradients.length];
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: hc.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: hc.cardShadow, blurRadius: 16, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 130,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: gradient),
              ),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      ad.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: quizText(20, wHeavy, hc.onAccent),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: context.x.colors.pureBlack.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(context.x.l10n.homeSponsorTag, style: quizText(11, wSemibold, hc.onAccent)),
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                      onTap: onDismiss,
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        width: 32,
                        height: 32,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: hc.onAccent.withValues(alpha: 0.2), shape: BoxShape.circle),
                        child: Icon(Icons.close_rounded, size: 16, color: hc.onAccent),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: hc.primaryTint, borderRadius: BorderRadius.circular(12)),
                    child: Text(_initials, style: quizText(14, wBold, hc.primary)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      ad.sponsorName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: quizText(12, wMedium, hc.text3),
                    ),
                  ),
                  const SizedBox(width: 12),
                  QuizButton(label: ad.ctaText, size: QuizButtonSize.s, onTap: onTap),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
