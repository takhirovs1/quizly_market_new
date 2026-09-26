import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../../../common/extension/number_extension.dart';
import '../bloc/upload_pricing_cubit.dart';
import '../state/file_upload_state.dart' show UZSFormatter;
import '../state/manual_upload_state.dart';

class ManualUploadScreen extends StatefulWidget {
  const ManualUploadScreen({super.key});

  @override
  State<ManualUploadScreen> createState() => _ManualUploadScreenState();
}

class _ManualUploadScreenState extends ManualUploadState {
  @override
  Widget build(BuildContext context) {
    final colors = context.x.colors;
    final l10n = context.x.l10n;
    final isDark = context.x.isDarkMode;
    final isMobile = context.x.isMobile;

    return Scaffold(
      backgroundColor: colors.scaffoldBackground,
      appBar: QuizAppBar(
        title: l10n.testUploadTitle,
        telegramWebAppSafeAreaInsetTop: context.telegramWebApp.safeAreaInset.top.toDouble(),
        showBackButton: true,
      ),
      body: SafeArea(
        child: isMobile
            ? ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                children: _buildFormFields(context),
              )
            : Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: isDark ? colors.cardBackground2 : colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: colors.divider),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [..._buildFormFields(context), const SizedBox(height: 12), _buildSubmitButton()],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
      ),
      bottomNavigationBar: (isMobile && MediaQuery.viewInsetsOf(context).bottom == 0)
          ? SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 8,
                  bottom: context.telegramWebApp.isSupported
                      ? context.telegramWebApp.safeAreaInset.bottom.toDouble() + 8
                      : 16,
                ),
                child: _buildSubmitButton(),
              ),
            )
          : null,
    );
  }

  List<Widget> _buildFormFields(BuildContext context) {
    final colors = context.x.colors;
    final textStyle = context.x.textStyle;
    final l10n = context.x.l10n;
    final isDark = context.x.isDarkMode;

    return [
      // Title
      Text(
        l10n.fillInformationToCreateTest,
        style: textStyle.sfW700s18.copyWith(color: colors.text, fontWeight: .w700),
      ),
      const SizedBox(height: 14),

      // Live pricing banner: "Har bir savol: X UZS • Cashback: Y%".
      BlocBuilder<UploadPricingCubit, UploadPricingState>(
        bloc: pricingCubit,
        builder: (context, pricingState) {
          if (pricingState.status.isLoading) {
            return const Padding(padding: .only(bottom: 12), child: ShimmerBox(height: 44, radius: 12));
          }
          final pricing = pricingState.pricing;
          return Container(
            padding: const .all(12),
            margin: const .only(bottom: 12),
            decoration: BoxDecoration(
              color: isDark ? colors.cardBackground2 : colors.buttonFill,
              borderRadius: .circular(12),
              border: Border.all(color: colors.divider),
            ),
            child: Row(
              children: [
                Icon(CupertinoIcons.info_circle, size: 18, color: colors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.pricingPerQuestionInfo(pricing.perQuestionPrice.formatUzs, pricing.cashbackPercent),
                    style: textStyle.sfW500s14.copyWith(color: colors.text, fontSize: 13),
                  ),
                ),
              ],
            ),
          );
        },
      ),

      // Field 1: University / O'quv markaz nomi
      _buildFieldLabel(l10n.universityOrCenterName, isRequired: true),
      const SizedBox(height: 6),
      CustomTextFiled(
        controller: universityController,
        focusNode: universityFocus,
        hintText: l10n.schoolNameHint,
        hintStyle: textStyle.sfW400s16.copyWith(color: colors.bannerSecondaryText),
        style: textStyle.sfW500s16.copyWith(color: colors.text),
        fillColor: isDark ? colors.cardBackground2 : colors.buttonFill,
        enabledBorderColor: colors.transparent,
        borderColor: colors.primary,
        borderWidth: 1.2,
        borderRadius: .circular(12),
        contentPadding: const .symmetric(horizontal: 16, vertical: 14),
        onSubmitted: (_) => testNameFocus.requestFocus(),
      ),
      const SizedBox(height: 14),

      // Field 2: Test nomi
      _buildFieldLabel(l10n.testName, isRequired: true),
      const SizedBox(height: 6),
      CustomTextFiled(
        controller: testNameController,
        focusNode: testNameFocus,
        hintText: l10n.testNameHint,
        hintStyle: textStyle.sfW400s16.copyWith(color: colors.bannerSecondaryText),
        style: textStyle.sfW500s16.copyWith(color: colors.text),
        fillColor: isDark ? colors.cardBackground2 : colors.buttonFill,
        enabledBorderColor: colors.transparent,
        borderColor: colors.primary,
        borderWidth: 1.2,
        borderRadius: .circular(12),
        contentPadding: const .symmetric(horizontal: 16, vertical: 14),
        onSubmitted: (_) => descriptionFocus.requestFocus(),
      ),
      const SizedBox(height: 14),

      // Field 3: Test tavsifi
      _buildFieldLabel(l10n.testDescription),
      const SizedBox(height: 6),
      CustomTextFiled(
        controller: descriptionController,
        focusNode: descriptionFocus,
        hintText: l10n.testDescriptionHint,
        hintStyle: textStyle.sfW400s16.copyWith(color: colors.bannerSecondaryText),
        style: textStyle.sfW500s16.copyWith(color: colors.text),
        fillColor: isDark ? colors.cardBackground2 : colors.buttonFill,
        enabledBorderColor: colors.transparent,
        borderColor: colors.primary,
        borderWidth: 1.2,
        borderRadius: .circular(12),
        contentPadding: const .symmetric(horizontal: 16, vertical: 14),
      ),
      const SizedBox(height: 14),

      // Field 4: Narxi (so'm) — 0/bo'sh → bepul
      _buildFieldLabel(l10n.priceLabel),
      const SizedBox(height: 6),
      CustomTextFiled(
        controller: priceController,
        focusNode: priceFocus,
        hintText: l10n.priceHint,
        hintStyle: textStyle.sfW400s16.copyWith(color: colors.bannerSecondaryText),
        style: textStyle.sfW500s16.copyWith(color: colors.text),
        keyboardType: .number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(9), UZSFormatter()],
        fillColor: isDark ? colors.cardBackground2 : colors.buttonFill,
        enabledBorderColor: colors.transparent,
        borderColor: colors.primary,
        borderWidth: 1.2,
        borderRadius: .circular(12),
        contentPadding: const .symmetric(horizontal: 16, vertical: 14),
      ),
      const SizedBox(height: 14),

      // Field 5: Mualiflikni korsatish Switch Tile
      Container(
        padding: const .symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isDark ? colors.cardBackground2 : colors.buttonFill,
          borderRadius: .circular(12),
        ),
        child: Row(
          mainAxisAlignment: .spaceBetween,
          children: [
            Text(l10n.showAuthorship, style: textStyle.sfW500s16.copyWith(color: colors.text)),
            CupertinoSwitch(value: showAuthorship, onChanged: onToggleAuthorship, activeTrackColor: colors.primary),
          ],
        ),
      ),
      const SizedBox(height: 12),

      if (context.isTelegramSupported) ...[
        // Field 5: To'liq ekran rejimidan chiqish Switch Tile
        Container(
          padding: const .symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: isDark ? colors.cardBackground2 : colors.buttonFill,
            borderRadius: .circular(12),
          ),
          child: Row(
            mainAxisAlignment: .spaceBetween,
            children: [
              Text(l10n.exitFullScreenMode, style: textStyle.sfW500s16.copyWith(color: colors.text)),
              CupertinoSwitch(
                value: exitFullScreen,
                onChanged: onToggleExitFullScreen,
                activeTrackColor: colors.primary,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Description under exit full screen switch
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: l10n.exitFullScreenModeDescription,
                style: textStyle.sfW400s14.copyWith(color: colors.bannerSecondaryText, height: 1.35),
              ),
              TextSpan(
                text: ' *',
                style: textStyle.sfW500s14.copyWith(color: colors.error, fontWeight: .w600),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ] else
        const SizedBox(height: 4),
    ];
  }

  Widget _buildSubmitButton() {
    final colors = context.x.colors;
    final textStyle = context.x.textStyle;
    final l10n = context.x.l10n;

    final enabled = canProceed;

    return AnimatedOpacity(
      opacity: enabled ? 1.0 : 0.5,
      duration: const Duration(milliseconds: 250),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: FilledButton(
          onPressed: enabled ? onSubmitProceed : null,
          style: FilledButton.styleFrom(
            backgroundColor: colors.primary,
            disabledBackgroundColor: colors.primary,
            shape: RoundedRectangleBorder(borderRadius: .circular(12)),
          ),
          child: Text(
            l10n.proceedToCreateTest,
            style: textStyle.sfW600s16.copyWith(color: colors.white, fontWeight: .w600),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label, {bool isRequired = false}) {
    final colors = context.x.colors;
    final textStyle = context.x.textStyle;

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: label,
            style: textStyle.sfW500s16.copyWith(color: colors.text, fontWeight: .w500),
          ),
          if (isRequired)
            TextSpan(
              text: ' *',
              style: textStyle.sfW500s14.copyWith(color: colors.error, fontWeight: .w600),
            ),
        ],
      ),
    );
  }
}
