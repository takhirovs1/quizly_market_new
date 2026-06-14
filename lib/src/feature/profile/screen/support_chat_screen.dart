import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart' show CupertinoButton;
import 'package:image_picker/image_picker.dart';
import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';

part '../state/support_chat_state.dart';

class SupportChatScreen extends StatefulWidget {
  const SupportChatScreen({super.key});

  @override
  State<SupportChatScreen> createState() => _SupportChatScreenState();
}

class _SupportChatScreenState extends SupportChatState {
  @override
  Widget build(BuildContext context) {
    final colors = context.x.colors;
    final textStyle = context.x.textStyle;
    final isMobile = context.x.isMobile;

    return Scaffold(
      backgroundColor: colors.scaffoldBackground,
      appBar: QuizAppBar(
        title: context.x.l10n.supportChatTitle,
        telegramWebAppSafeAreaInsetTop: context.telegramWebApp.safeAreaInset.top.toDouble(),
      ),
      body: SafeArea(
        child: isMobile
            ? _buildChatContent(context, colors, textStyle)
            : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Container(
                    margin: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: colors.cardBackground2,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: colors.divider),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: _buildChatContent(context, colors, textStyle),
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildChatContent(BuildContext context, ThemeColors colors, AppTypography textStyle) => Column(
    children: [
      Expanded(
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.only(top: 48, left: 16, right: 16, bottom: 16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                if (msg.isUser) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: context.x.isMobile ? MediaQuery.sizeOf(context).width * 0.85 : 480,
                        ),
                        decoration: BoxDecoration(
                          color: colors.primary,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                            bottomLeft: Radius.circular(16),
                          ),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              msg.text,
                              style: textStyle.sfW400s14.copyWith(color: Colors.white),
                              textAlign: TextAlign.start,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  msg.time,
                                  style: textStyle.sfW400s12.copyWith(color: Colors.white.withValues(alpha: 0.7)),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  msg.isRead ? Icons.done_all_rounded : Icons.done_rounded,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: context.x.isMobile ? MediaQuery.sizeOf(context).width * 0.85 : 480,
                        ),
                        decoration: BoxDecoration(
                          color: colors.buttonFill,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                            bottomRight: Radius.circular(16),
                          ),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Quizly support', style: textStyle.sfW400s14.copyWith(color: colors.gray)),
                            const SizedBox(height: 4),
                            Text(
                              msg.text,
                              style: textStyle.sfW400s14.copyWith(color: colors.text),
                              textAlign: TextAlign.start,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [Text(msg.time, style: textStyle.sfW400s12.copyWith(color: colors.gray))],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
            Positioned(
              top: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: colors.buttonFill, borderRadius: BorderRadius.circular(16)),
                child: Text(
                  context.x.l10n.mockDateSeparator,
                  style: textStyle.sfW500s11.copyWith(color: context.x.colors.text),
                ),
              ),
            ),
          ],
        ),
      ),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: context.x.isMobile ? colors.scaffoldBackground : colors.cardBackground2,
          border: Border(top: BorderSide(color: colors.divider, width: 0.5)),
        ),
        child: Row(
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => _showAttachmentBottomSheet(context),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colors.primary, width: 1.5),
                ),
                child: Icon(Icons.attach_file_rounded, color: colors.primary, size: 20),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SizedBox(
                height: 44,
                child: TextField(
                  controller: messageController,
                  focusNode: messageFocusNode,
                  onSubmitted: (_) => sendMessage(),
                  style: textStyle.sfW400s14.copyWith(color: colors.text),
                  decoration: InputDecoration(
                    hintText: context.x.l10n.messageInputHint,
                    hintStyle: textStyle.sfW400s14.copyWith(color: colors.gray),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    filled: true,
                    fillColor: colors.textFieldBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(22),
                      borderSide: BorderSide(color: colors.divider),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(22),
                      borderSide: BorderSide(color: colors.divider),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(22),
                      borderSide: BorderSide(color: colors.primary),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ValueListenableBuilder<bool>(
              valueListenable: isSendActive,
              builder: (context, active, child) => CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: active ? sendMessage : null,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: active ? colors.primary : colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: active ? colors.primary : colors.divider, width: 1.5),
                  ),
                  child: Icon(Icons.send, color: active ? colors.white : colors.gray, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
