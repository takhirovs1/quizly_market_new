import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../../../common/extension/number_extension.dart';
import '../bloc/import_mapping_cubit.dart';
import '../bloc/upload_pricing_cubit.dart';
import '../state/file_upload_state.dart';
import '../widget/import_mapping_step.dart';

class FileUploadScreen extends StatefulWidget {
  const FileUploadScreen({super.key});

  @override
  State<FileUploadScreen> createState() => _FileUploadScreenState();
}

class _FileUploadScreenState extends FileUploadState {
  @override
  Widget build(BuildContext context) {
    final colors = context.x.colors;
    final l10n = context.x.l10n;

    return BlocListener<ImportMappingCubit, ImportMappingState>(
      bloc: mappingCubit,
      listenWhen: (prev, next) => prev.parseStatus != next.parseStatus,
      listener: (context, state) {
        if (state.parseStatus.isSuccess && step == 0) goToMappingStep();
        if (state.parseStatus.isError) {
          context.x.showNotification(message: l10n.fileParseFailed, isError: true);
        }
      },
      child: PopScope(
        canPop: canPopScreen,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) onBackFromMapping();
        },
        child: Scaffold(
          backgroundColor: colors.scaffoldBackground,
          appBar: QuizAppBar(
            title: step == 0 ? l10n.fileUploadTitle : l10n.importMappingTitle,
            telegramWebAppSafeAreaInsetTop: context.telegramWebApp.safeAreaInset.top.toDouble(),
            showBackButton: true,
            onBackPressed: step == 0 ? null : onBackFromMapping,
          ),
          body: SafeArea(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: step == 0
                  ? _MetaStep(key: const ValueKey('meta'), state: this)
                  : ImportMappingStep(key: const ValueKey('mapping'), cubit: mappingCubit, onConfirm: onConfirmMapping),
            ),
          ),
        ),
      ),
    );
  }
}

/// Step 1 — the shared meta form + "attach any file" area.
class _MetaStep extends StatelessWidget {
  const _MetaStep({required this.state, super.key});

  final FileUploadState state;

  @override
  Widget build(BuildContext context) {
    final colors = context.x.colors;
    final isDark = context.x.isDarkMode;
    final isMobile = context.x.isMobile;

    final fields = _buildFields(context);

    if (isMobile) {
      return ListView(padding: const .symmetric(horizontal: 16, vertical: 12), children: fields);
    }
    return Center(
      child: SingleChildScrollView(
        padding: const .symmetric(vertical: 24, horizontal: 16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: isDark ? colors.cardBackground2 : colors.white,
              borderRadius: .circular(20),
              border: Border.all(color: colors.divider),
            ),
            child: Padding(
              padding: const .all(24),
              child: Column(mainAxisSize: .min, crossAxisAlignment: .stretch, children: fields),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFields(BuildContext context) {
    final colors = context.x.colors;
    final textStyle = context.x.textStyle;
    final l10n = context.x.l10n;
    final isDark = context.x.isDarkMode;
    final fillColor = isDark ? colors.cardBackground2 : colors.buttonFill;

    Widget label(String text, {bool required = false}) => RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: text,
            style: textStyle.sfW500s16.copyWith(color: colors.text, fontWeight: .w500),
          ),
          if (required)
            TextSpan(
              text: ' *',
              style: textStyle.sfW500s14.copyWith(color: colors.error, fontWeight: .w600),
            ),
        ],
      ),
    );

    Widget field({
      required TextEditingController controller,
      required FocusNode focusNode,
      required String hint,
      List<TextInputFormatter>? formatters,
      TextInputType? keyboardType,
    }) => CustomTextFiled(
      controller: controller,
      focusNode: focusNode,
      hintText: hint,
      hintStyle: textStyle.sfW400s16.copyWith(color: colors.bannerSecondaryText),
      style: textStyle.sfW500s16.copyWith(color: colors.text),
      fillColor: fillColor,
      enabledBorderColor: colors.transparent,
      borderColor: colors.primary,
      borderWidth: 1.2,
      borderRadius: .circular(12),
      contentPadding: const .symmetric(horizontal: 16, vertical: 14),
      keyboardType: keyboardType,
      inputFormatters: formatters,
    );

    return [
      Text(
        l10n.fillInformationToUploadTest,
        style: textStyle.sfW700s18.copyWith(color: colors.text, fontWeight: .w700),
      ),
      const SizedBox(height: 4),
      Text(l10n.attachAnyFileHint, style: textStyle.sfW400s14.copyWith(color: colors.bannerSecondaryText)),
      const SizedBox(height: 14),

      // Live pricing banner: "Har bir savol: X UZS • Cashback: Y%".
      BlocBuilder<UploadPricingCubit, UploadPricingState>(
        bloc: state.pricingCubit,
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

      label(l10n.universityOrCenterName, required: true),
      const SizedBox(height: 6),
      field(controller: state.universityController, focusNode: state.universityFocus, hint: l10n.schoolNameHint),
      const SizedBox(height: 14),

      label(l10n.testName, required: true),
      const SizedBox(height: 6),
      field(controller: state.testNameController, focusNode: state.testNameFocus, hint: l10n.testNameHint),
      const SizedBox(height: 14),

      label(l10n.testDescription),
      const SizedBox(height: 6),
      field(controller: state.descriptionController, focusNode: state.descriptionFocus, hint: l10n.testDescriptionHint),
      const SizedBox(height: 14),

      label(l10n.priceLabel),
      const SizedBox(height: 6),
      field(
        controller: state.priceController,
        focusNode: state.priceFocus,
        hint: l10n.priceHint,
        keyboardType: .number,
        formatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(9), UZSFormatter()],
      ),
      const SizedBox(height: 14),

      // Mualliflikni ko'rsatish
      Container(
        padding: const .symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(color: fillColor, borderRadius: .circular(12)),
        child: Row(
          mainAxisAlignment: .spaceBetween,
          children: [
            Text(l10n.showAuthorship, style: textStyle.sfW500s16.copyWith(color: colors.text)),
            CupertinoSwitch(
              value: state.showAuthorship,
              onChanged: state.onToggleAuthorship,
              activeTrackColor: colors.primary,
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),

      // Attach file / parsing shimmer.
      BlocBuilder<ImportMappingCubit, ImportMappingState>(
        bloc: state.mappingCubit,
        builder: (context, mappingState) {
          if (mappingState.parseStatus.isLoading) {
            return Column(
              crossAxisAlignment: .stretch,
              children: [
                const ShimmerBox(height: 56, radius: 14),
                const SizedBox(height: 8),
                const ShimmerBox(height: 120, radius: 14),
                const SizedBox(height: 8),
                Center(
                  child: Text(l10n.parsingFile, style: textStyle.sfW400s14.copyWith(color: colors.bannerSecondaryText)),
                ),
              ],
            );
          }
          return _AttachFileCard(enabled: state.isMetaValid, onTap: state.onAttachFile);
        },
      ),
      const SizedBox(height: 12),

      // Xatolik to'g'risida xabar berish
      GestureDetector(
        onTap: state.onReportError,
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
      const SizedBox(height: 8),
    ];
  }
}

class _AttachFileCard extends StatelessWidget {
  const _AttachFileCard({required this.enabled, required this.onTap});

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.x.colors;
    final textStyle = context.x.textStyle;
    final l10n = context.x.l10n;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 150),
      opacity: enabled ? 1 : 0.5,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          padding: const .symmetric(vertical: 22),
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.05),
            borderRadius: .circular(14),
            border: Border.all(color: colors.primary.withValues(alpha: 0.5), width: 1.2),
          ),
          child: Column(
            children: [
              Assets.lib.vectors.attachFile.svg(
                package: 'ui',
                width: 28,
                height: 28,
                colorFilter: ColorFilter.mode(colors.primary, .srcIn),
              ),
              const SizedBox(height: 8),
              Text(l10n.attachFile, style: textStyle.sfW600s16.copyWith(color: colors.primary)),
              const SizedBox(height: 4),
              Padding(
                padding: const .symmetric(horizontal: 24),
                child: Text(
                  l10n.supportedFormatsHint,
                  style: textStyle.sfW400s14.copyWith(color: colors.bannerSecondaryText),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
