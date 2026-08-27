import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
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

    return Scaffold(
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
                  Padding(
                    padding: const .fromLTRB(16, 8, 16, 16),
                    child: _buildSubmitButton(),
                  ),
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
                          crossAxisAlignment: .stretch,
                          mainAxisSize: .min,
                          children: [
                            ..._buildFormFields(context),
                            const SizedBox(height: 12),
                            _buildSubmitButton(),
                          ],
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

      // File Card & Action
      if (uploadedFileName == null) ...[
        // Instruction download card
        _buildExampleFileCard(),
        const SizedBox(height: 10),

        // Attach file button
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
      ] else ...[
        // Uploaded file card
        _buildUploadedFileCard(),

        // Issues warning box if any
        if (fileIssues.isNotEmpty) ...[const SizedBox(height: 10), _buildFileIssuesBox()],
      ],
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
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(9),
          UZSFormatter(),
        ],
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
        decoration: BoxDecoration(color: colors.buttonFill, borderRadius: .circular(12)),
        child: Row(
          mainAxisAlignment: .spaceBetween,
          children: [
            Text(l10n.showAuthorship, style: textStyle.sfW500s16.copyWith(color: colors.text)),
            CupertinoSwitch(
              value: showAuthorship,
              onChanged: onToggleAuthorship,
              activeTrackColor: colors.primary,
            ),
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

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: FilledButton(
        onPressed: isUploading ? null : onSubmitUpload,
        style: FilledButton.styleFrom(
          backgroundColor: colors.primary,
          shape: RoundedRectangleBorder(borderRadius: .circular(12)),
        ),
        child: isUploading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator.adaptive(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                l10n.upload,
                style: textStyle.sfW600s16.copyWith(color: colors.white, fontWeight: .w600),
              ),
      ),
    );
  }

  Widget _buildExampleFileCard() {
    final colors = context.x.colors;
    final textStyle = context.x.textStyle;
    final l10n = context.x.l10n;

    return Container(
      padding: const .symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(color: colors.buttonFill, borderRadius: .circular(12)),
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

  Widget _buildUploadedFileCard() {
    final colors = context.x.colors;
    final textStyle = context.x.textStyle;
    final l10n = context.x.l10n;

    return Container(
      padding: const .symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(color: colors.buttonFill, borderRadius: .circular(12)),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: colors.error.withValues(alpha: 0.1), borderRadius: .circular(10)),
            child: Center(
              child: Assets.lib.vectors.fileIcon.svg(
                package: 'ui',
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(colors.error, .srcIn),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Text(
                  uploadedFileName ?? '',
                  style: textStyle.sfW500s16.copyWith(color: colors.text, fontWeight: .w500),
                  maxLines: 1,
                  overflow: .ellipsis,
                ),
                const SizedBox(height: 2),
                Text(l10n.excelDocument, style: textStyle.sfW400s14.copyWith(color: colors.bannerSecondaryText)),
              ],
            ),
          ),
          CupertinoButton(
            onPressed: onRemoveUploadedFile,
            padding: const .all(6),
            minimumSize: .zero,
            child: Icon(Icons.delete_outline_rounded, color: colors.primary, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildFileIssuesBox() {
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
        ...fileIssues.map(
          (issue) => Padding(
            padding: const .only(top: 2),
            child: Text('- $issue', style: textStyle.sfW400s14.copyWith(color: colors.text)),
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
