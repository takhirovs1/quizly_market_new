import 'package:flutter/cupertino.dart' show CupertinoButton;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ui/ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../common/extension/context_extension.dart';
import '../bloc/support_chat_cubit.dart';
import '../model/support_chat_model.dart';

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
        child: BlocConsumer<SupportChatCubit, SupportChatCubitState>(
          listenWhen: (prev, curr) =>
              (curr.messages.length > prev.messages.length && !prev.status.isLoadingMore) ||
              (curr.status.isError && !prev.status.isError) ||
              curr.sendErrorCount != prev.sendErrorCount,
          listener: (context, state) {
            if (state.status.isError || state.sendErrorCount != 0) {
              final msg = state.errorMessage;
              if (msg != null) {
                context.x.showNotification(
                  message: msg,
                  isError: true,
                  top: context.telegramWebApp.isSupported
                      ? context.telegramWebApp.safeAreaInset.top.toDouble() + 56
                      : MediaQuery.paddingOf(context).top + 56,
                );
              }
            } else {
              _scrollToBottom();
            }
          },
          builder: (context, state) {
            final content = _buildChatContent(context, state, colors, textStyle);
            if (isMobile) return content;
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Container(
                  margin: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: colors.cardBackground2,
                    borderRadius: .circular(20),
                    border: Border.all(color: colors.divider),
                  ),
                  child: ClipRRect(borderRadius: .circular(20), child: content),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildChatContent(
    BuildContext context,
    SupportChatCubitState state,
    ThemeColors colors,
    AppTypography textStyle,
  ) =>
      Column(
        children: [
          Expanded(
            child: state.status.isLoading
                ? const Center(child: CircularProgressIndicator())
                : Stack(
                    alignment: .topCenter,
                    children: [
                      ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 16),
                        itemCount: state.messages.length,
                        itemBuilder: (context, index) =>
                            _buildMessage(context, state.messages[index], colors, textStyle),
                      ),
                      if (state.status.isLoadingMore)
                        Positioned(
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: colors.buttonFill,
                              borderRadius: .circular(16),
                            ),
                            child: const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
          _buildInputBar(context, state, colors, textStyle),
        ],
      );

  Widget _buildMessage(
    BuildContext context,
    SupportMessageModel msg,
    ThemeColors colors,
    AppTypography textStyle,
  ) {
    final isUser = msg.isUser;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Align(
        alignment: isUser ? .centerRight : .centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: context.x.isMobile ? MediaQuery.sizeOf(context).width * 0.85 : 480,
          ),
          decoration: BoxDecoration(
            color: isUser ? colors.primary : colors.buttonFill,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isUser ? 16 : 0),
              bottomRight: Radius.circular(isUser ? 0 : 16),
            ),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: isUser ? .end : .start,
            mainAxisSize: .min,
            children: [
              if (!isUser)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    'Quizly support',
                    style: textStyle.sfW400s14.copyWith(color: colors.gray),
                  ),
                ),
              if (msg.replyTo != null) _buildReplyPreview(msg.replyTo!, colors, textStyle, isUser),
              if (msg.photos.isNotEmpty) _buildPhotos(msg.photos),
              if (msg.text != null && msg.text!.isNotEmpty)
                Text(
                  msg.text!,
                  style: textStyle.sfW400s14.copyWith(
                    color: isUser ? Colors.white : colors.text,
                  ),
                ),
              const SizedBox(height: 4),
              Text(
                msg.formattedTime,
                style: textStyle.sfW400s12.copyWith(
                  color: isUser ? Colors.white.withValues(alpha: 0.7) : colors.gray,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReplyPreview(
    SupportReplyToModel reply,
    ThemeColors colors,
    AppTypography textStyle,
    bool isUser,
  ) =>
      Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: isUser ? Colors.white.withValues(alpha: 0.6) : colors.primary,
              width: 3,
            ),
          ),
          color: isUser
              ? Colors.white.withValues(alpha: 0.15)
              : colors.primary.withValues(alpha: 0.08),
          borderRadius: .circular(4),
        ),
        child: Text(
          reply.textPreview ?? (reply.hasPhoto ? '🖼 Photo' : ''),
          style: textStyle.sfW400s12.copyWith(
            color: isUser ? Colors.white.withValues(alpha: 0.8) : colors.gray,
          ),
          maxLines: 1,
          overflow: .ellipsis,
        ),
      );

  Widget _buildPhotos(List<SupportPhotoModel> photos) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Column(
      mainAxisSize: .min,
      children: photos
          .map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: ClipRRect(
                borderRadius: .circular(8),
                child: Image.network(p.url, fit: .cover, width: double.infinity),
              ),
            ),
          )
          .toList(),
    ),
  );

  Widget _buildInputBar(
    BuildContext context,
    SupportChatCubitState state,
    ThemeColors colors,
    AppTypography textStyle,
  ) =>
      ListenableBuilder(
        listenable: messageFocusNode,
        builder: (context, _) {
          final isFocused = messageFocusNode.hasFocus;
          return Container(
            padding: EdgeInsets.only(
              left: 12,
              right: 12,
              top: 8,
              bottom: isFocused
                  ? context.telegramWebApp.contentSafeAreaInset.bottom + 12
                  : context.telegramWebApp.contentSafeAreaInset.bottom + 24,
            ),
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
                      borderRadius: .circular(12),
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
                          borderRadius: .circular(22),
                          borderSide: BorderSide(color: colors.divider),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: .circular(22),
                          borderSide: BorderSide(color: colors.divider),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: .circular(22),
                          borderSide: BorderSide(color: colors.primary),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ValueListenableBuilder<bool>(
                  valueListenable: isSendActive,
                  builder: (context, active, _) => CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: active && !state.isSending ? sendMessage : null,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: active ? colors.primary : colors.transparent,
                        borderRadius: .circular(12),
                        border: Border.all(
                          color: active ? colors.primary : colors.divider,
                          width: 1.5,
                        ),
                      ),
                      child: state.isSending
                          ? Padding(
                              padding: const EdgeInsets.all(12),
                              child: CircularProgressIndicator(
                                color: colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Icon(
                              Icons.send,
                              color: active ? colors.white : colors.gray,
                              size: 20,
                            ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
}
