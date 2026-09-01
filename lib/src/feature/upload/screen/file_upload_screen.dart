import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../../../common/extension/number_extension.dart';
import '../bloc/file_upload_cubit.dart';
import '../bloc/upload_pricing_cubit.dart';
import '../state/file_upload_state.dart';

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
    final isDark = context.x.isDarkMode;
    final isMobile = context.x.isMobile;

    return BlocListener<FileUploadCubit, FileUploadCubitState>(
      bloc: fileUploadCubit,
      listener: (context, state) {
        if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
          context.x.showNotification(message: state.errorMessage!, isError: true);
        }
      },
      child: Scaffold(
        backgroundColor: colors.scaffoldBackground,
        appBar: QuizAppBar(
          title: l10n.fileUploadTitle,
          telegramWebAppSafeAreaInsetTop: context.telegramWebApp.safeAreaInset.top.toDouble(),
          showBackButton: true,
        ),
        body: SafeArea(
          child: isMobile
              ? Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: const .symmetric(horizontal: 16, vertical: 12),
                        children: _buildFormFields(context),
                      ),
                    ),
                    Padding(padding: const .fromLTRB(16, 8, 16, 16), child: _buildSubmitButton()),
                  ],
                )
              : Center(
                  child: SingleChildScrollView(
                    padding: const .symmetric(vertical: 24, horizontal: 16),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: isDark ? colors.cardBackground2 : colors.white,
                          borderRadius: .circular(20),
                          border: Border.all(color: colors.divider),
                        ),
                        child: Padding(
                          padding: const .all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: .min,
                            children: [..._buildFormFields(context), const SizedBox(height: 12), _buildSubmitButton()],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ),
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
        l10n.fillInformationToUploadTest,
        style: textStyle.sfW700s18.copyWith(color: colors.text, fontWeight: .w700),
      ),
      const SizedBox(height: 4),

      // Subtitle with required mark
      RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: l10n.uploadFileAccordingToInstruction,
              style: textStyle.sfW400s14.copyWith(color: colors.bannerSecondaryText),
            ),
            TextSpan(
              text: ' *',
              style: textStyle.sfW500s14.copyWith(color: colors.error, fontWeight: .w600),
            ),
          ],
        ),
      ),
      const SizedBox(height: 14),

      // Dynamic Pricing info card from UploadPricingCubit
      BlocBuilder<UploadPricingCubit, UploadPricingState>(
        bloc: pricingCubit,
        builder: (context, pricingState) {
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

      // File Card & Action
      BlocBuilder<FileUploadCubit, FileUploadCubitState>(
        bloc: fileUploadCubit,
        builder: (context, state) {
          if (state.fileName == null) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildExampleFileCard(),
                const SizedBox(height: 10),
                Align(
                  alignment: .centerLeft,
                  child: CupertinoButton(
                    onPressed: onAttachFile,
                    padding: .zero,
                    child: Row(
                      mainAxisSize: .min,
                      children: [
                        Assets.lib.vectors.attachFile.svg(
                          package: 'ui',
                          width: 22,
                          height: 22,
                          colorFilter: ColorFilter.mode(colors.primary, .srcIn),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.attachFile,
                          style: textStyle.sfW500s16.copyWith(color: colors.primary, fontWeight: .w500),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildUploadedFileCard(state),
              if (state.validationStatus.isLoading) ...[
                const SizedBox(height: 8),
                const Center(child: CupertinoActivityIndicator()),
              ] else if (state.errors.isNotEmpty) ...[
                const SizedBox(height: 10),
                _buildFileIssuesBox(state.errors),
              ] else if (state.warnings.isNotEmpty) ...[
                const SizedBox(height: 10),
                _buildWarningsBox(state.warnings),
              ],
            ],
          );
        },
      ),
      const SizedBox(height: 16),

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

      // Field 4: Narxi
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

      // Field 5: Mualliflikni ko'rsatish Switch Tile
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

      // Report Error Link
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
      const SizedBox(height: 8),
    ];
  }

  Widget _buildSubmitButton() {
    final colors = context.x.colors;
    final textStyle = context.x.textStyle;
    final l10n = context.x.l10n;

    return BlocBuilder<FileUploadCubit, FileUploadCubitState>(
      bloc: fileUploadCubit,
      builder: (context, state) {
        final isLoading = state.importStatus.isLoading;
        final isEnabled = state.isValid && !isLoading;

        return SizedBox(
          width: double.infinity,
          height: 50,
          child: FilledButton(
            onPressed: isEnabled ? onSubmitUpload : null,
            style: FilledButton.styleFrom(
              backgroundColor: colors.primary,
              disabledBackgroundColor: colors.primary.withValues(alpha: 0.4),
              shape: RoundedRectangleBorder(borderRadius: .circular(12)),
            ),
            child: isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator.adaptive(
                      valueColor: AlwaysStoppedAnimation<Color>(colors.white),
                    ),
                  )
                : Text(
                    l10n.upload,
                    style: textStyle.sfW600s16.copyWith(color: colors.white, fontWeight: .w600),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildExampleFileCard() {
    final colors = context.x.colors;
    final textStyle = context.x.textStyle;
    final l10n = context.x.l10n;
    final isDark = context.x.isDarkMode;

    return Container(
      padding: const .symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? colors.cardBackground2 : colors.buttonFill,
        borderRadius: .circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: colors.primary.withValues(alpha: 0.1), borderRadius: .circular(10)),
            child: Center(
              child: Assets.lib.vectors.fileIcon.svg(
                package: 'ui',
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(colors.primary, .srcIn),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Text(
                  l10n.instructionFileName,
                  style: textStyle.sfW500s16.copyWith(color: colors.text, fontWeight: .w500),
                ),
                const SizedBox(height: 2),
                Text(l10n.excelDocument, style: textStyle.sfW400s14.copyWith(color: colors.bannerSecondaryText)),
              ],
            ),
          ),
          CupertinoButton(
            onPressed: onDownloadExampleFile,
            padding: const .all(6),
            minimumSize: .zero,
            child: Icon(Icons.file_download_outlined, color: colors.primary, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadedFileCard(FileUploadCubitState state) {
    final colors = context.x.colors;
    final textStyle = context.x.textStyle;
    final l10n = context.x.l10n;
    final isDark = context.x.isDarkMode;
    final hasErrors = state.hasErrors;

    return Container(
      padding: const .symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? colors.cardBackground2 : colors.buttonFill,
        borderRadius: .circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: (hasErrors ? colors.error : colors.primary).withValues(alpha: 0.1),
              borderRadius: .circular(10),
            ),
            child: Center(
              child: Assets.lib.vectors.fileIcon.svg(
                package: 'ui',
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(hasErrors ? colors.error : colors.primary, .srcIn),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Text(
                  state.fileName ?? '',
                  style: textStyle.sfW500s16.copyWith(color: colors.text, fontWeight: .w500),
                  maxLines: 1,
                  overflow: .ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  state.questionCount > 0
                      ? l10n.questionsFound(state.questionCount)
                      : l10n.excelDocument,
                  style: textStyle.sfW400s14.copyWith(color: colors.bannerSecondaryText),
                ),
              ],
            ),
          ),
          CupertinoButton(
            onPressed: onRemoveUploadedFile,
            padding: const .all(6),
            minimumSize: .zero,
            child: Icon(CupertinoIcons.xmark, color: colors.primary, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildFileIssuesBox(List<dynamic> errors) {
    final colors = context.x.colors;
    final textStyle = context.x.textStyle;
    final l10n = context.x.l10n;

    return Column(
      crossAxisAlignment: .start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: l10n.fileHasIssues,
                style: textStyle.sfW600s16.copyWith(color: colors.text, fontWeight: .w700, fontSize: 14),
              ),
              TextSpan(
                text: ' *',
                style: textStyle.sfW600s16.copyWith(color: colors.error, fontWeight: .w700, fontSize: 14),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        ...errors.map(
          (issue) => Padding(
            padding: const .only(top: 2),
            child: Text(
              issue is String ? '- $issue' : '- ${l10n.rowErrorMessage(issue.row as int, issue.message.toString())}',
              style: textStyle.sfW400s14.copyWith(color: colors.error),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWarningsBox(List<String> warnings) {
    final colors = context.x.colors;
    final textStyle = context.x.textStyle;

    return Column(
      crossAxisAlignment: .start,
      children: [
        ...warnings.map(
          (w) => Padding(
            padding: const .only(top: 2),
            child: Text('ℹ $w', style: textStyle.sfW400s14.copyWith(color: colors.primary)),
          ),
        ),
      ],
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
