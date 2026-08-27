import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../../my_tests/widgets/questions_carousel.dart';
import '../state/upload_confirm_state.dart';

class UploadConfirmScreen extends StatefulWidget {
  const UploadConfirmScreen({
    this.testName,
    this.university,
    this.description,
    this.price,
    this.questionCount = 100,
    super.key,
  });

  final String? testName;
  final String? university;
  final String? description;
  final String? price;
  final int questionCount;

  @override
  State<UploadConfirmScreen> createState() => _UploadConfirmScreenState();
}

class _UploadConfirmScreenState extends UploadConfirmState {
  @override
  Widget build(BuildContext context) {
    final colors = context.x.colors;
    final l10n = context.x.l10n;

    return Scaffold(
      backgroundColor: colors.scaffoldBackground,
      appBar: QuizAppBar(
        telegramWebAppSafeAreaInsetTop: context.telegramWebApp.safeAreaInset.top.toDouble(),
        title: l10n.upload,
        showBackButton: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWeb = constraints.maxWidth >= 800;
          if (isWeb) {
            return ClipRect(
              child: SingleChildScrollView(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Padding(
                      padding: const .all(28),
                      child: IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: .stretch,
                          children: [
                            // ── Left: Test details & benefits card ──────────────────────────
                            Expanded(flex: 5, child: _buildWebInfoCard(context)),
                            const SizedBox(width: 28),
                            // ── Right: Questions carousel & Payment ─────────────────────────
                            Expanded(flex: 7, child: _buildWebRightColumn(context)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          } else {
            return ListView(padding: const .fromLTRB(16, 12, 16, 24), children: _buildMobileContent(context));
          }
        },
      ),
      bottomNavigationBar: LayoutBuilder(
        builder: (context, constraints) {
          final isWeb = constraints.maxWidth >= 800;
          if (isWeb) {
            return const SizedBox.shrink();
          }
          return _buildMobileBottomBar(context);
        },
      ),
    );
  }

  List<Widget> _buildMobileContent(BuildContext context) {
    final colors = context.x.colors;
    final textStyle = context.x.textStyle;
    final l10n = context.x.l10n;
    final languageCode = Localizations.localeOf(context).languageCode;

    final displayName = widget.testName?.isNotEmpty == true
        ? widget.testName!
        : "O'zbekistonning eng yangi tarixi fanidan testlar";

    final displayUniversity = widget.university?.isNotEmpty == true
        ? widget.university!
        : 'Toshkent Davlat Iqtisodiyot Universiteti';

    final displayDesc = widget.description?.isNotEmpty == true
        ? widget.description!
        : 'Example test description, Example test description, Example test description';

    return [
      // 1. Test Title
      Text(
        displayName,
        style: textStyle.sfW700s18.copyWith(color: colors.text, fontSize: 20, fontWeight: .w700),
      ),
      const SizedBox(height: 6),

      // 2. University / Center
      Text(displayUniversity, style: textStyle.sfW500s14.copyWith(color: colors.bannerSecondaryText, fontSize: 15)),
      const SizedBox(height: 6),

      // 3. Test Description
      Text(displayDesc, style: textStyle.sfW400s14.copyWith(color: colors.bannerSecondaryText, fontSize: 13)),
      const SizedBox(height: 8),

      // 4. Question Count
      Text(
        '${widget.questionCount}ta savol',
        style: textStyle.sfW500s14.copyWith(color: colors.text, fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 16),

      // 5. Questions Carousel
      if (questions.isNotEmpty) ...[
        QuestionsCarousel(questions: questions, languageCode: languageCode, currentPage: currentPage),
        const SizedBox(height: 16),
      ],

      // 6. Benefits List with vector icons
      _buildBenefitRow(
        icon: Assets.lib.vectors.dollarIcon.svg(
          package: 'ui',
          width: 20,
          height: 20,
          colorFilter: ColorFilter.mode(colors.primary, .srcIn),
        ),
        content: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '${l10n.pricePerQuestion} ',
                style: textStyle.sfW500s14.copyWith(color: colors.text),
              ),
              TextSpan(
                text: "100 so'm",
                style: textStyle.sfW500s14.copyWith(color: colors.primary, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 10),

      _buildBenefitRow(
        icon: Assets.lib.vectors.cashbackIcon.svg(
          package: 'ui',
          width: 20,
          height: 20,
          colorFilter: ColorFilter.mode(colors.primary, .srcIn),
        ),
        content: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '${l10n.cashbackFromEverySale} ',
                style: textStyle.sfW500s14.copyWith(color: colors.text),
              ),
              TextSpan(
                text: '20%',
                style: textStyle.sfW500s14.copyWith(color: colors.primary, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 10),

      _buildBenefitRow(
        icon: Assets.lib.vectors.checkTickIcon.svg(
          package: 'ui',
          width: 20,
          height: 20,
          colorFilter: ColorFilter.mode(colors.primary, .srcIn),
        ),
        content: Text(l10n.retestFreeOption, style: textStyle.sfW500s14.copyWith(color: colors.text)),
      ),
      const SizedBox(height: 20),

      // 7. Payment Type Section
      Text(
        l10n.paymentType,
        style: textStyle.sfW600s16.copyWith(color: colors.text, fontSize: 17, fontWeight: .w600),
      ),
      const SizedBox(height: 8),

      ValueListenableBuilder(
        valueListenable: selectedPayment,
        builder: (context, payment, _) => PaymentCard(
          hasShadow: true,
          title: payment.title,
          subtitle: payment.subtitle,
          image: Image.asset(payment.icon, package: 'ui', width: payment.type == .card ? 44 : 54),
          onTap: onSwitchPaymentPressed,
          action: IconButton(onPressed: onSwitchPaymentPressed, icon: const Icon(Icons.unfold_more)),
        ),
      ),
      const SizedBox(height: 16),

      // 8. Report Error Link
      GestureDetector(
        onTap: onReportError,
        behavior: .opaque,
        child: Padding(
          padding: const .symmetric(vertical: 4),
          child: Row(
            mainAxisSize: .min,
            children: [
              Icon(Icons.help_outline_rounded, color: colors.error, size: 20),
              const SizedBox(width: 8),
              Text(
                l10n.reportErrorAbout,
                style: textStyle.sfW500s14.copyWith(color: colors.error, fontWeight: .w600),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 16),
    ];
  }

  Widget _buildWebInfoCard(BuildContext context) {
    final colors = context.x.colors;
    final textStyle = context.x.textStyle;
    final l10n = context.x.l10n;

    final displayName = widget.testName?.isNotEmpty == true
        ? widget.testName!
        : "O'zbekistonning eng yangi tarixi fanidan testlar";

    final displayUniversity = widget.university?.isNotEmpty == true
        ? widget.university!
        : 'Toshkent Davlat Iqtisodiyot Universiteti';

    final displayDesc = widget.description?.isNotEmpty == true
        ? widget.description!
        : 'Example test description, Example test description, Example test description';

    return Container(
      decoration: BoxDecoration(
        color: colors.cardBackground2,
        borderRadius: .circular(24),
        border: Border.all(color: colors.primary.withValues(alpha: 0.1), width: 1.5),
        boxShadow: [BoxShadow(color: colors.black.withValues(alpha: 0.05), blurRadius: 24, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          // Gradient header
          Container(
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colors.primary, colors.primary.withValues(alpha: 0.7)],
                begin: .centerLeft,
                end: .centerRight,
              ),
              borderRadius: const .only(topLeft: .circular(23), topRight: .circular(23)),
            ),
            padding: const .symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), shape: .circle),
                  child: const Icon(Icons.school_rounded, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: .start,
                    mainAxisAlignment: .center,
                    children: [
                      Text(
                        'QuizlyMarket',
                        style: textStyle.sfW600s16.copyWith(color: Colors.white, fontSize: 11, letterSpacing: 0.8),
                      ),
                      const SizedBox(height: 2),
                      Text(l10n.upload, style: textStyle.sfW600s16.copyWith(color: Colors.white, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const .all(20),
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Text(
                  displayName,
                  style: textStyle.sfW700s18.copyWith(color: colors.text, fontSize: 20, fontWeight: .w700),
                ),
                const SizedBox(height: 6),
                Text(
                  displayUniversity,
                  style: textStyle.sfW500s14.copyWith(color: colors.bannerSecondaryText, fontSize: 15),
                ),
                const SizedBox(height: 6),
                Text(displayDesc, style: textStyle.sfW400s14.copyWith(color: colors.bannerSecondaryText, fontSize: 13)),
                const SizedBox(height: 8),
                Text(
                  '${widget.questionCount}ta savol',
                  style: textStyle.sfW500s14.copyWith(color: colors.text, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 20),

                // Benefits
                _buildBenefitRow(
                  icon: Assets.lib.vectors.dollarIcon.svg(
                    package: 'ui',
                    width: 20,
                    height: 20,
                    colorFilter: ColorFilter.mode(colors.primary, .srcIn),
                  ),
                  content: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${l10n.pricePerQuestion} ',
                          style: textStyle.sfW500s14.copyWith(color: colors.text),
                        ),
                        TextSpan(
                          text: "100 so'm",
                          style: textStyle.sfW500s14.copyWith(color: colors.primary, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                _buildBenefitRow(
                  icon: Assets.lib.vectors.cashbackIcon.svg(
                    package: 'ui',
                    width: 20,
                    height: 20,
                    colorFilter: ColorFilter.mode(colors.primary, .srcIn),
                  ),
                  content: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${l10n.cashbackFromEverySale} ',
                          style: textStyle.sfW500s14.copyWith(color: colors.text),
                        ),
                        TextSpan(
                          text: '20%',
                          style: textStyle.sfW500s14.copyWith(color: colors.primary, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                _buildBenefitRow(
                  icon: Assets.lib.vectors.checkTickIcon.svg(
                    package: 'ui',
                    width: 20,
                    height: 20,
                    colorFilter: ColorFilter.mode(colors.primary, .srcIn),
                  ),
                  content: Text(l10n.retestFreeOption, style: textStyle.sfW500s14.copyWith(color: colors.text)),
                ),
                const SizedBox(height: 20),

                // Report error
                GestureDetector(
                  onTap: onReportError,
                  behavior: .opaque,
                  child: Row(
                    mainAxisSize: .min,
                    children: [
                      Icon(Icons.help_outline_rounded, color: colors.error, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        l10n.reportErrorAbout,
                        style: textStyle.sfW500s14.copyWith(color: colors.error, fontWeight: .w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebRightColumn(BuildContext context) {
    final colors = context.x.colors;
    final textStyle = context.x.textStyle;
    final l10n = context.x.l10n;
    final languageCode = Localizations.localeOf(context).languageCode;
    final totalPrice = widget.price?.isNotEmpty == true ? widget.price! : '20 000 UZS';

    return Column(
      crossAxisAlignment: .start,
      children: [
        if (questions.isNotEmpty) ...[
          QuestionsCarousel(questions: questions, languageCode: languageCode, currentPage: currentPage),
          const SizedBox(height: 20),
        ],
        Text(l10n.paymentType, style: textStyle.sfW600s16.copyWith(fontSize: 18, fontWeight: .w600)),
        const SizedBox(height: 8),
        ValueListenableBuilder(
          valueListenable: selectedPayment,
          builder: (context, payment, _) => PaymentCard(
            hasShadow: true,
            title: payment.title,
            subtitle: payment.subtitle,
            image: Image.asset(payment.icon, package: 'ui', width: payment.type == .card ? 32 : 54),
            onTap: onSwitchPaymentPressed,
            action: IconButton(onPressed: onSwitchPaymentPressed, icon: const Icon(Icons.unfold_more)),
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const .symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: colors.cardBackground2,
            borderRadius: .circular(16),
            border: Border.all(color: colors.divider),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    Text(l10n.total, style: textStyle.sfW400s14.copyWith(color: colors.bannerSecondaryText)),
                    const SizedBox(height: 2),
                    Text(
                      totalPrice,
                      style: textStyle.sfW700s18.copyWith(fontSize: 24, color: colors.primary, fontWeight: .w700),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                height: 48,
                child: FilledButton(
                  onPressed: isSubmitting ? null : onConfirmUpload,
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.primary,
                    padding: const .symmetric(horizontal: 28),
                    shape: RoundedRectangleBorder(borderRadius: .circular(12)),
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator.adaptive(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          l10n.uploadTestButton,
                          style: textStyle.sfW600s16.copyWith(color: colors.white, fontWeight: .w600),
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBenefitRow({required Widget icon, required Widget content}) {
    final colors = context.x.colors;

    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(color: colors.primary.withValues(alpha: 0.1), borderRadius: .circular(7)),
          child: Center(child: icon),
        ),
        const SizedBox(width: 10),
        Expanded(child: content),
      ],
    );
  }

  Widget _buildMobileBottomBar(BuildContext context) {
    final colors = context.x.colors;
    final textStyle = context.x.textStyle;
    final l10n = context.x.l10n;
    final totalPrice = widget.price?.isNotEmpty == true ? widget.price! : '20 000 UZS';

    return ColoredBox(
      color: colors.dialogBackground,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.dialogBackground,
          borderRadius: const .only(topLeft: .circular(16), topRight: .circular(16)),
          border: Border.all(color: colors.divider, width: 1),
          boxShadow: [
            BoxShadow(color: colors.black.withValues(alpha: .078), offset: const Offset(0, -3), blurRadius: 30),
          ],
        ),
        child: ClipRRect(
          borderRadius: const .only(topLeft: .circular(15), topRight: .circular(15)),
          child: Padding(
            padding: EdgeInsets.only(
              bottom: context.telegramWebApp.isSupported
                  ? context.telegramWebApp.safeAreaInset.bottom.toDouble() + 16
                  : 16,
              top: 16,
              left: 16,
              right: 16,
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      totalPrice,
                      style: textStyle.sfW700s18.copyWith(fontSize: 22, color: colors.primary, fontWeight: .w700),
                      textAlign: .center,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: FilledButton(
                        onPressed: isSubmitting ? null : onConfirmUpload,
                        style: FilledButton.styleFrom(
                          backgroundColor: colors.primary,
                          shape: RoundedRectangleBorder(borderRadius: .circular(12)),
                        ),
                        child: isSubmitting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator.adaptive(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                l10n.uploadTestButton,
                                style: textStyle.sfW600s16.copyWith(color: colors.white, fontWeight: .w600),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
