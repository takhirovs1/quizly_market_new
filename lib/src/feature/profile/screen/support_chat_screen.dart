import 'dart:async';
import 'dart:io' as io;
import 'dart:math';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ui/ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../common/extension/context_extension.dart';
import '../bloc/profile_cubit.dart';
import '../bloc/support_chat_cubit.dart';
import '../model/support_chat_model.dart';

part '../state/support_chat_state.dart';

// ─── Date-separator helper ───────────────────────────────────────────────────

String _dayLabel(BuildContext context, DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final local = date.toLocal();
  final d = DateTime(local.year, local.month, local.day);
  if (d == today) return context.x.l10n.today;
  if (d == yesterday) return context.x.l10n.yesterday;
  return '${local.day}.${local.month.toString().padLeft(2, '0')}.${local.year}';
}

// ─── Screen ──────────────────────────────────────────────────────────────────

class SupportChatScreen extends StatefulWidget {
  const SupportChatScreen({this.initialMessage, super.key});

  final String? initialMessage;

  @override
  State<SupportChatScreen> createState() => _SupportChatScreenState();
}

class _SupportChatScreenState extends SupportChatState {
  @override
  Widget build(BuildContext context) {
    final colors = context.x.colors;
    final textStyle = context.x.textStyle;
    final isMobile = context.x.isMobile;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<SupportChatCubit, SupportChatCubitState>(
      buildWhen: (prev, curr) => prev.isAdminTyping != curr.isAdminTyping,
      builder: (context, chatState) => Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: colors.chatSurface,
        appBar: QuizAppBar(
          title: context.x.l10n.supportChatTitle,
          telegramWebAppSafeAreaInsetTop: context.telegramWebApp.safeAreaInset.top.toDouble(),
          subtitle: Visibility(
            visible: chatState.isAdminTyping,
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
            child: AppBarTypingIndicator(text: context.x.l10n.typing),
          ),
        ),
        body: SafeArea(
          bottom: false,
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

              final hasUnreadAdmin = state.messages.any((m) => !m.isUser && !m.viewed);
              if (hasUnreadAdmin) {
                _cubit.markAsRead();
              }
            },
            builder: (context, state) {
              final content = _buildChatContent(context, state, colors, textStyle, isDark);
              if (isMobile) return content;
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Container(
                    margin: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: colors.cardBackground2,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: colors.divider),
                    ),
                    child: ClipRRect(borderRadius: BorderRadius.circular(20), child: content),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ─── Chat body ─────────────────────────────────────────────────────────────

  Widget _buildChatContent(
    BuildContext context,
    SupportChatCubitState state,
    ThemeColors colors,
    AppTypography textStyle,
    bool isDark,
  ) => Column(
    children: [
      // Pinned banner
      if (pinnedMessage != null) _buildPinnedBanner(colors, textStyle),

      // Messages area
      Expanded(child: _buildMessagesList(context, state, colors, textStyle, isDark)),

      // Input bar
      _buildInputBar(context, state, colors, textStyle),
    ],
  );

  // ─── Messages list with sticky date header ─────────────────────────────────

  Widget _buildMessagesList(
    BuildContext context,
    SupportChatCubitState state,
    ThemeColors colors,
    AppTypography textStyle,
    bool isDark,
  ) => Stack(
    fit: StackFit.expand,
    children: [
      // Wallpaper background
      Image(
        image: Assets.lib.images.wallhaven7pzqz3.provider(package: 'ui'),
        fit: BoxFit.cover,
        color: colors.chatWallpaperOverlay,
        colorBlendMode: isDark ? BlendMode.darken : BlendMode.lighten,
      ),

      if (state.status.isLoading)
        _buildShimmerLoading(colors)
      else
        NotificationListener<ScrollNotification>(
          onNotification: (n) {
            final pos = n.metrics;
            if (pos.pixels >= pos.maxScrollExtent - 80) {
              _cubit.loadMore();
            }
            if (n is ScrollUpdateNotification) {
              _onScrollUpdate();
            }
            return false;
          },
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              // Messages Grouped ListView
              GroupedListView<SupportMessageModel, DateTime>(
                elements: state.messages,
                groupBy: (msg) {
                  final l = msg.createdAt.toLocal();
                  return DateTime(l.year, l.month, l.day);
                },
                groupComparator: (a, b) => a.compareTo(b),
                itemComparator: (a, b) => a.createdAt.compareTo(b.createdAt),
                groupSeparatorBuilder: (date) => _buildInlineDate(context, date),
                groupStickyHeaderBuilder: (msg) => _buildStickyHeader(context, msg),
                itemBuilder: (context, msg) => _buildMessage(context, msg, colors, textStyle),
                order: GroupedListOrder.DESC,
                reverse: true,
                controller: scrollController,
                useStickyGroupSeparators: true,
                floatingHeader: true,
                padding: const EdgeInsets.only(top: 44, bottom: 8),
              ),

              // Load-more indicator
              if (state.status.isLoadingMore)
                Positioned(
                  top: 8,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: colors.pureBlack.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(color: colors.pureWhite, strokeWidth: 2),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
    ],
  );
  Widget _buildShimmerLoading(ThemeColors colors) {
    final baseColor = colors.chatShimmerBase;
    final highlightColor = colors.chatShimmerHighlight;

    Widget shimmerWrapper(Widget child) =>
        Shimmer.fromColors(baseColor: baseColor, highlightColor: highlightColor, child: child);

    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
      children: [
        // Left bubble (admin)
        Align(
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              shimmerWrapper(const ShimmerBox(width: 140, height: 48, radius: 16)),
              const SizedBox(height: 12),
              shimmerWrapper(const ShimmerBox(width: 220, height: 64, radius: 16)),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Right bubble (user)
        Align(
          alignment: Alignment.centerRight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              shimmerWrapper(const ShimmerBox(width: 180, height: 48, radius: 16)),
              const SizedBox(height: 12),
              shimmerWrapper(const ShimmerBox(width: 110, height: 48, radius: 16)),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Left bubble (admin)
        Align(
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [shimmerWrapper(const ShimmerBox(width: 200, height: 48, radius: 16))],
          ),
        ),
      ],
    );
  }

  Widget _buildStickyHeader(BuildContext context, SupportMessageModel msg) {
    final date = DateTime(msg.createdAt.year, msg.createdAt.month, msg.createdAt.day);
    return IgnorePointer(
      ignoring: !showStickyHeader,
      child: AnimatedOpacity(
        opacity: showStickyHeader ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(padding: const .only(top: 10, bottom: 6), child: _buildDateChip(_dayLabel(context, date))),
        ),
      ),
    );
  }

  // Inline date separator (appears in the list, scrolls with messages)
  Widget _buildInlineDate(BuildContext context, DateTime date) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Center(child: _buildDateChip(_dayLabel(context, date))),
  );

  // Shared date chip widget
  Widget _buildDateChip(String label) => ClipRRect(
    borderRadius: .circular(12),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: context.x.colors.pureBlack.withValues(alpha: 0.28),
          borderRadius: .circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(color: context.x.colors.pureWhite, fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
    ),
  );

  // ─── Pinned message banner ─────────────────────────────────────────────────

  Widget _buildPinnedBanner(ThemeColors colors, AppTypography textStyle) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
    decoration: BoxDecoration(
      color: colors.chatSurface,
      border: Border(bottom: BorderSide(color: colors.chatBorder)),
    ),
    child: Row(
      children: [
        Container(
          width: 3,
          height: 36,
          decoration: BoxDecoration(color: colors.chatAccent, borderRadius: .circular(2)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: .start,
            mainAxisSize: .min,
            children: [
              Text(
                context.x.l10n.pinnedMessage,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: colors.chatAccent),
              ),
              const SizedBox(height: 2),
              Text(
                pinnedMessage!.text ?? '',
                style: textStyle.sfW400s12.copyWith(color: colors.gray),
                maxLines: 1,
                overflow: .ellipsis,
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => setPinned(null),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Icon(Icons.close, size: 18, color: colors.gray),
          ),
        ),
      ],
    ),
  );

  // ─── Single message bubble ─────────────────────────────────────────────────

  Widget _buildMessage(BuildContext context, SupportMessageModel msg, ThemeColors colors, AppTypography textStyle) {
    final isUser = msg.isUser;

    Color bubbleBg = isUser ? colors.chatBubbleUser : colors.chatBubbleAdmin;
    if (msg.isPending) {
      bubbleBg = bubbleBg.withValues(alpha: 0.6);
    }

    final textColor = colors.dialogText;

    final timeColor = isUser ? colors.chatTimeUser : colors.chatTimeAdmin;

    final checkColor = colors.chatTimeAdmin;

    final borderRadius = BorderRadius.only(
      topLeft: const Radius.circular(16),
      topRight: const Radius.circular(16),
      bottomLeft: Radius.circular(isUser ? 16 : 0),
      bottomRight: Radius.circular(isUser ? 0 : 16),
    );

    // If message is ONLY photos (no text), render without bubble container
    final hasText = msg.text != null && msg.text!.isNotEmpty;
    final hasPhotos = msg.photos.isNotEmpty;

    final key = messageKeys.putIfAbsent(msg.id, () => GlobalKey());
    final isHighlighted = msg.id == highlightedMessageId;

    return AnimatedContainer(
      key: key,
      duration: const Duration(milliseconds: 300),
      color: isHighlighted ? colors.chatHighlight : colors.transparent,
      width: double.infinity,
      child: GestureDetector(
        onLongPressStart: (details) => _showMessageActions(context, msg, colors, textStyle, details.globalPosition),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 4, left: 4, right: 4),
          child: Align(
            alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.sizeOf(context).width * (context.x.isMobile ? 0.72 : 0.62),
              ),
              child: Column(
                crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Photos (outside bubble, Telegram-style)
                  if (hasPhotos) _buildPhotos(context, msg, isUser, borderRadius),

                  // Text bubble (only if there's text)
                  if (hasText || msg.replyTo != null)
                    Container(
                      decoration: BoxDecoration(
                        color: bubbleBg,
                        borderRadius: hasPhotos
                            ? BorderRadius.only(
                                bottomLeft: Radius.circular(isUser ? 16 : 0),
                                bottomRight: Radius.circular(isUser ? 0 : 16),
                              )
                            : borderRadius,
                        boxShadow: [
                          BoxShadow(
                            color: colors.pureBlack.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.fromLTRB(11, 8, 11, 7),
                      child: Column(
                        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Reply preview
                          if (msg.replyTo != null) _buildReplyPreview(msg.replyTo!, colors, textStyle, isUser),

                          // Text
                          if (hasText) Text(msg.text!, style: TextStyle(fontSize: 13.5, color: textColor, height: 1.5)),

                          const SizedBox(height: 2),

                          // Timestamp
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(msg.formattedTime, style: TextStyle(fontSize: 9, color: timeColor, height: 1)),
                              if (isUser) ...[
                                const SizedBox(width: 3),
                                if (msg.isPending)
                                  Icon(Icons.access_time_rounded, size: 10, color: timeColor)
                                else if (msg.isFailed)
                                  Icon(Icons.error_outline_rounded, size: 12, color: colors.chatDanger)
                                else
                                  _MessageStatusCheck(color: checkColor, viewed: msg.viewed),
                              ],
                            ],
                          ),
                        ],
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

  // ─── Photos (tappable → custom fullscreen viewer) ────────────────────────

  Widget _buildPhotos(BuildContext context, SupportMessageModel msg, bool isUser, BorderRadius bubbleRadius) {
    final photos = msg.photos;
    final urls = photos.map((p) => p.url).toList();
    final hasText = msg.text != null && msg.text!.isNotEmpty;
    final showTimeOnImage = !hasText && msg.replyTo == null;

    return ClipRRect(
      borderRadius: bubbleRadius,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: photos.asMap().entries.map((entry) {
          final i = entry.key;
          final p = entry.value;
          return GestureDetector(
            onTap: () => _openImageViewer(context, urls, i),
            child: AspectRatio(
              aspectRatio: 16 / 10,
              child: Hero(
                tag: 'chat_photo_${p.url}_$i',
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _buildNetworkImage(imageUrl: p.url, fit: BoxFit.cover),
                    if (showTimeOnImage && i == photos.length - 1) _buildImageTimeOverlay(msg, isUser),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildImageTimeOverlay(SupportMessageModel msg, bool isUser) => Positioned(
    bottom: 8,
    right: 8,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          color: context.x.colors.pureBlack.withValues(alpha: 0.45),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                msg.formattedTime,
                style: TextStyle(fontSize: 9, color: context.x.colors.pureWhite, fontWeight: FontWeight.w500),
              ),
              if (isUser) ...[
                const SizedBox(width: 3),
                if (msg.isPending)
                  Icon(Icons.access_time_rounded, size: 10, color: context.x.colors.pureWhite)
                else if (msg.isFailed)
                  Icon(Icons.error_outline_rounded, size: 12, color: context.x.colors.chatDanger)
                else
                  _MessageStatusCheck(color: context.x.colors.pureWhite.withValues(alpha: 0.9), viewed: msg.viewed),
              ],
            ],
          ),
        ),
      ),
    ),
  );

  void _openImageViewer(BuildContext context, List<String> urls, int initialIndex) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: false,
        barrierColor: context.x.colors.transparent,
        pageBuilder: (_, _, _) => _ChatImageViewer(urls: urls, initialIndex: initialIndex),
        transitionsBuilder: (_, anim, _, child) => FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 220),
      ),
    );
  }

  // Reply preview inside bubble
  Widget _buildReplyPreview(SupportReplyToModel reply, ThemeColors colors, AppTypography textStyle, bool isUser) {
    SupportMessageModel? repliedMsg;
    for (final m in _cubit.state.messages) {
      if (m.id == reply.id) {
        repliedMsg = m;
        break;
      }
    }
    final photoUrl = repliedMsg != null && repliedMsg.photos.isNotEmpty ? repliedMsg.photos.first.url : null;

    final lineColor = isUser ? colors.chatReplyUserAccent : colors.chatAccent;
    final bgColor = isUser ? colors.chatReplyUserBackground : colors.chatReplyAdminBackground;
    final titleColor = lineColor;
    final subtitleColor = colors.chatReplySubtitle;

    String senderName;
    if (reply.sender == 'user') {
      String? profileName;
      try {
        final profileState = context.read<ProfileCubit>().state;
        final user = profileState.user;
        profileName = (user?.name?.isNotEmpty == true ? user?.name : null) ?? user?.displayName;
      } on Object catch (_) {}
      senderName = profileName ?? context.x.l10n.you;
    } else if (reply.sender == 'admin') {
      senderName = context.x.l10n.chatSupportSenderName;
    } else {
      senderName = reply.sender;
    }

    final hasImage = reply.hasPhoto && photoUrl != null;

    return GestureDetector(
      onTap: () => scrollToMessage(reply.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: lineColor, width: 3)),
          color: bgColor,
          borderRadius: const BorderRadius.only(topRight: Radius.circular(4), bottomRight: Radius.circular(4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (hasImage) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: _buildNetworkImage(
                  imageUrl: photoUrl,
                  width: 36,
                  height: 36,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 36,
                    height: 36,
                    color: colors.chatImagePlaceholder,
                    child: Center(
                      child: SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(strokeWidth: 1.5, color: colors.chatAccent),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 36,
                    height: 36,
                    color: colors.chatImagePlaceholder,
                    child: Icon(Icons.broken_image, size: 16, color: colors.chatImageErrorIcon),
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    senderName,
                    style: textStyle.sfW500s12.copyWith(color: titleColor, fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    reply.textPreview ?? (reply.hasPhoto ? context.x.l10n.photo : ''),
                    style: textStyle.sfW500s11.copyWith(color: subtitleColor, fontWeight: FontWeight.w400),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Long-press action sheet ───────────────────────────────────────────────

  Future<void> _showMessageActions(
    BuildContext context,
    SupportMessageModel msg,
    ThemeColors colors,
    AppTypography textStyle,
    Offset tapPosition,
  ) async {
    final position = RelativeRect.fromRect(
      Rect.fromLTWH(tapPosition.dx, tapPosition.dy, 0, 0),
      Offset.zero & MediaQuery.sizeOf(context),
    );

    final menuBg = colors.chatMenuBackground;
    final textThemeColor = colors.text;
    final iconColor = colors.chatMenuIcon;

    final isUserMessage = msg.sender == 'user';

    final result = await showMenu<String>(
      context: context,
      position: position,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: menuBg,
      constraints: const BoxConstraints(minWidth: 160, maxWidth: 200),
      items: [
        if (msg.isFailed) ...[
          PopupMenuItem<String>(
            value: 'retry',
            height: 38,
            child: Row(
              children: [
                Icon(Icons.refresh_rounded, color: colors.chatRetry, size: 20),
                const SizedBox(width: 12),
                Text(context.x.l10n.retry, style: TextStyle(color: colors.chatRetry, fontSize: 14)),
              ],
            ),
          ),
          PopupMenuItem<String>(
            value: 'delete',
            height: 38,
            child: Row(
              children: [
                QuizLottieIcon(QuizLottie.delete, size: 20, color: colors.chatDanger),
                const SizedBox(width: 12),
                Text(context.x.l10n.delete, style: TextStyle(color: colors.chatDanger, fontSize: 14)),
              ],
            ),
          ),
        ] else ...[
          PopupMenuItem<String>(
            value: 'reply',
            height: 38,
            child: Row(
              children: [
                Icon(Icons.reply_rounded, color: iconColor, size: 20),
                const SizedBox(width: 12),
                Text(context.x.l10n.replyAction, style: TextStyle(color: textThemeColor, fontSize: 14)),
              ],
            ),
          ),
          if (msg.text != null && msg.text!.isNotEmpty) ...[
            PopupMenuItem<String>(
              value: 'pin',
              height: 38,
              child: Row(
                children: [
                  Icon(Icons.push_pin_outlined, color: iconColor, size: 20),
                  const SizedBox(width: 12),
                  Text(context.x.l10n.pin, style: TextStyle(color: textThemeColor, fontSize: 14)),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'copy',
              height: 38,
              child: Row(
                children: [
                  Icon(Icons.copy_rounded, color: iconColor, size: 20),
                  const SizedBox(width: 12),
                  Text(context.x.l10n.copy, style: TextStyle(color: textThemeColor, fontSize: 14)),
                ],
              ),
            ),
          ],
          if (isUserMessage && msg.text != null && msg.text!.isNotEmpty)
            PopupMenuItem<String>(
              value: 'edit',
              height: 38,
              child: Row(
                children: [
                  Icon(Icons.edit_rounded, color: iconColor, size: 20),
                  const SizedBox(width: 12),
                  Text(context.x.l10n.edit, style: TextStyle(color: textThemeColor, fontSize: 14)),
                ],
              ),
            ),
          if (isUserMessage)
            PopupMenuItem<String>(
              value: 'delete',
              height: 38,
              child: Row(
                children: [
                  QuizLottieIcon(QuizLottie.delete, size: 20, color: colors.chatDanger),
                  const SizedBox(width: 12),
                  Text(context.x.l10n.delete, style: TextStyle(color: colors.chatDanger, fontSize: 14)),
                ],
              ),
            ),
        ],
      ],
    );

    if (result == null) return;

    switch (result) {
      case 'retry':
        _cubit.retryMessage(msg).ignore();
        break;
      case 'reply':
        setReplyTo(msg);
        break;
      case 'pin':
        setPinned(msg);
        break;
      case 'copy':
        if (msg.text != null) {
          await Clipboard.setData(ClipboardData(text: msg.text!));
          if (context.mounted) {
            context.x.showNotification(
              message: context.x.l10n.messageCopied,
              isError: false,
              top: context.telegramWebApp.isSupported
                  ? context.telegramWebApp.safeAreaInset.top.toDouble() + 56
                  : MediaQuery.paddingOf(context).top + 56,
            );
          }
        }
        break;
      case 'edit':
        setEditingMessage(msg);
        break;
      case 'delete':
        _cubit.deleteMessage(msg.id);
        break;
    }
  }

  // ─── Input bar ─────────────────────────────────────────────────────────────

  Widget _buildInputBar(
    BuildContext context,
    SupportChatCubitState state,
    ThemeColors colors,
    AppTypography textStyle,
  ) {
    const kButtonSize = 44.0; // uniform height for all buttons
    final barBg = colors.chatSurface;
    final borderColor = colors.chatBorder;
    final safeBottom = context.telegramWebApp.isSupported
        ? context.telegramWebApp.safeAreaInset.bottom.toDouble() + 12
        : MediaQuery.paddingOf(context).bottom;
    final inputBg = colors.chatInputBackground;
    final inputBorder = colors.chatInputBorder;

    return TextFieldTapRegion(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {},
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Reply banner ────────────────────────────────────────────────
            if (replyToMessage != null)
              Container(
                padding: const EdgeInsets.fromLTRB(0, 8, 12, 8),
                decoration: BoxDecoration(
                  color: colors.chatBannerBackground,
                  border: Border(top: BorderSide(color: borderColor)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 3,
                      height: 40,
                      margin: const EdgeInsets.only(left: 12, right: 10),
                      decoration: BoxDecoration(
                        color: colors.chatAccent,
                        borderRadius: BorderRadius.only(topRight: Radius.circular(8), bottomRight: Radius.circular(8)),
                      ),
                    ),
                    if (replyToMessage!.photos.isNotEmpty) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: _buildNetworkImage(
                          imageUrl: replyToMessage!.photos.first.url,
                          width: 36,
                          height: 36,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: .start,
                        mainAxisSize: .min,
                        children: [
                          Text(
                            replyToMessage!.isUser ? context.x.l10n.replyToYou : context.x.l10n.replyToSupport,
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: colors.chatAccent),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            replyToMessage!.text ??
                                (replyToMessage!.photos.isNotEmpty ? context.x.l10n.photoLabel : ''),
                            style: textStyle.sfW400s12.copyWith(color: colors.gray),
                            maxLines: 1,
                            overflow: .ellipsis,
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setReplyTo(null),
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Icon(Icons.close, size: 18, color: colors.gray),
                      ),
                    ),
                  ],
                ),
              ),

            // ── Editing banner ────────────────────────────────────────────────
            if (editingMessage != null)
              Container(
                padding: const EdgeInsets.fromLTRB(0, 8, 12, 8),
                decoration: BoxDecoration(
                  color: colors.chatBannerBackground,
                  border: Border(top: BorderSide(color: borderColor)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 3,
                      height: 40,
                      margin: const EdgeInsets.only(left: 12, right: 10),
                      decoration: BoxDecoration(
                        color: colors.chatEditAccent,
                        borderRadius: BorderRadius.only(topRight: Radius.circular(8), bottomRight: Radius.circular(8)),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            context.x.l10n.edit,
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: colors.chatEditAccent),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            editingMessage!.text ?? '',
                            style: textStyle.sfW400s12.copyWith(color: colors.gray),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setEditingMessage(null),
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Icon(Icons.close, size: 18, color: colors.gray),
                      ),
                    ),
                  ],
                ),
              ),

            // ── Input row ───────────────────────────────────────────────────
            Container(
              padding: EdgeInsets.only(left: 10, right: 10, top: 8, bottom: safeBottom + 8),
              decoration: BoxDecoration(
                color: barBg,
                border: Border(top: BorderSide(color: borderColor, width: 0.5)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ── Attach button ─────────────────────────────────────────
                  _barButton(
                    size: kButtonSize,
                    colors: colors,
                    onTap: () => _showAttachmentBottomSheet(context),
                    child: Icon(Icons.attach_file_rounded, color: colors.chatAttachIcon, size: 21),
                  ),

                  const SizedBox(width: 8),

                  // ── Text field ────────────────────────────────────────────
                  Expanded(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: kButtonSize, maxHeight: 110),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: inputBg,
                          borderRadius: .circular(22),
                          border: Border.all(color: inputBorder),
                        ),
                        child: TextField(
                          controller: messageController,
                          focusNode: messageFocusNode,
                          onSubmitted: (_) => sendMessage(),
                          style: TextStyle(fontSize: 14, color: colors.text, height: 1.4),
                          maxLines: null,
                          textInputAction: TextInputAction.newline,
                          decoration: InputDecoration(
                            hintText: context.x.l10n.messageInputHint,
                            hintStyle: TextStyle(fontSize: 14, color: colors.chatInputHint),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // ── Send button ───────────────────────────────────────────
                  ValueListenableBuilder<bool>(
                    valueListenable: isSendActive,
                    builder: (context, active, _) => _barButton(
                      size: kButtonSize,
                      colors: colors,
                      onTap: active && !state.isSending ? sendMessage : null,
                      filled: active,
                      child: state.isSending
                          ? Padding(
                              padding: const EdgeInsets.all(12),
                              child: CircularProgressIndicator(color: colors.pureWhite, strokeWidth: 2),
                            )
                          : Icon(
                              Icons.send_rounded,
                              color: active ? colors.pureWhite : colors.chatSendInactive,
                              size: 20,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Uniform square button used for attach & send
  Widget _barButton({
    required double size,
    required ThemeColors colors,
    required Widget child,
    VoidCallback? onTap,
    bool filled = false,
  }) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: filled ? colors.chatAccent : colors.transparent,
        shape: BoxShape.circle,
        border: filled ? null : Border.all(color: colors.chatInputBorder, width: 1.5),
      ),
      child: child,
    ),
  );
}

// ─── Lightweight fullscreen image viewer (no sqflite / no external cache) ────

class _ChatImageViewer extends StatefulWidget {
  const _ChatImageViewer({required this.urls, required this.initialIndex});

  final List<String> urls;
  final int initialIndex;

  @override
  State<_ChatImageViewer> createState() => _ChatImageViewerState();
}

class _ChatImageViewerState extends State<_ChatImageViewer> {
  late PageController _pageCtrl;
  late int _current;
  double _bgOpacity = 1;

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex;
    _pageCtrl = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  void _dismiss() => Navigator.of(context).maybePop();

  @override
  Widget build(BuildContext context) {
    final safeTop = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: context.x.colors.pureBlack.withValues(alpha: _bgOpacity),
      body: Stack(
        children: [
          // ── PageView of images ─────────────────────────────────────────────
          PageView.builder(
            controller: _pageCtrl,
            itemCount: widget.urls.length,
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder: (context, index) => GestureDetector(
              onVerticalDragUpdate: (d) {
                final delta = d.primaryDelta ?? 0;
                if (delta > 0) {
                  setState(() => _bgOpacity = (1.0 - delta / 300).clamp(0.0, 1.0));
                }
              },
              onVerticalDragEnd: (_) {
                if (_bgOpacity < 0.7) {
                  _dismiss();
                } else {
                  setState(() => _bgOpacity = 1.0);
                }
              },
              child: Center(
                child: InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 5,
                  child: Hero(
                    tag: 'chat_photo_${widget.urls[index]}_$index',
                    child: _buildNetworkImage(
                      imageUrl: widget.urls[index],
                      fit: BoxFit.contain,
                      placeholder: (context, url) => SizedBox(
                        width: 48,
                        height: 48,
                        child: Center(
                          child: CircularProgressIndicator(color: context.x.colors.pureWhite, strokeWidth: 2.5),
                        ),
                      ),
                      errorWidget: (context, url, error) => Icon(
                        Icons.broken_image_outlined,
                        color: context.x.colors.pureWhite.withValues(alpha: 0.54),
                        size: 64,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Top bar with close button & page counter ───────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(top: safeTop + 4, left: 4, right: 16, bottom: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [context.x.colors.pureBlack.withValues(alpha: 0.55), context.x.colors.transparent],
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.close, color: context.x.colors.pureWhite, size: 24),
                    onPressed: _dismiss,
                  ),
                  const Spacer(),
                  if (widget.urls.length > 1)
                    Text(
                      '${_current + 1} / ${widget.urls.length}',
                      style: TextStyle(color: context.x.colors.pureWhite, fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildNetworkImage({
  required String imageUrl,
  required BoxFit fit,
  double? width,
  double? height,
  Widget Function(BuildContext, String)? placeholder,
  Widget Function(BuildContext, String, Object)? errorWidget,
}) {
  if (kIsWeb) {
    return Image.network(
      imageUrl,
      fit: fit,
      width: width,
      height: height,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        if (placeholder != null) return placeholder(context, imageUrl);
        return Container(
          width: width,
          height: height,
          color: context.x.colors.chatImagePlaceholder,
          child: Center(child: CircularProgressIndicator(color: context.x.colors.chatAccent, strokeWidth: 2)),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        if (errorWidget != null) return errorWidget(context, imageUrl, error);
        return Container(
          width: width,
          height: height,
          color: context.x.colors.chatImagePlaceholder,
          child: Center(child: Icon(Icons.broken_image_outlined, color: context.x.colors.chatImageErrorIcon, size: 32)),
        );
      },
    );
  } else {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      width: width,
      height: height,
      placeholder: placeholder != null
          ? (context, url) => placeholder(context, url)
          : (context, url) => Container(
              color: context.x.colors.chatImagePlaceholder,
              child: Center(child: CircularProgressIndicator(color: context.x.colors.chatAccent, strokeWidth: 2)),
            ),
      errorWidget: errorWidget != null
          ? (context, url, error) => errorWidget(context, url, error)
          : (context, url, error) => Container(
              color: context.x.colors.chatImagePlaceholder,
              child: Center(
                child: Icon(Icons.broken_image_outlined, color: context.x.colors.chatImageErrorIcon, size: 32),
              ),
            ),
    );
  }
}

class _MessageStatusCheck extends StatelessWidget {
  const _MessageStatusCheck({required this.color, required this.viewed});
  final Color color;
  final bool viewed;

  @override
  Widget build(BuildContext context) => CustomPaint(
    size: const Size(14, 9),
    painter: _MessageStatusCheckPainter(color: color, viewed: viewed),
  );
}

class _MessageStatusCheckPainter extends CustomPainter {
  const _MessageStatusCheckPainter({required this.color, required this.viewed});
  final Color color;
  final bool viewed;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    if (viewed) {
      final path1 = Path()
        ..moveTo(0, size.height * 0.5)
        ..lineTo(size.width * 0.28, size.height)
        ..lineTo(size.width * 0.62, 0);
      canvas.drawPath(path1, paint);

      final path2 = Path()
        ..moveTo(size.width * 0.38, size.height * 0.5)
        ..lineTo(size.width * 0.66, size.height)
        ..lineTo(size.width, 0);
      canvas.drawPath(path2, paint);
    } else {
      final path = Path()
        ..moveTo(size.width * 0.2, size.height * 0.5)
        ..lineTo(size.width * 0.48, size.height)
        ..lineTo(size.width * 0.85, 0.1);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_MessageStatusCheckPainter old) => old.color != color || old.viewed != viewed;
}

class _BouncingDots extends StatefulWidget {
  const _BouncingDots({required this.color});
  final Color color;

  @override
  State<_BouncingDots> createState() => _BouncingDotsState();
}

class _BouncingDotsState extends State<_BouncingDots> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final delay = index * 0.2;
            final double value = (sin((_controller.value * 2 * pi) - (delay * 2 * pi)) + 1) / 2;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              width: 3.5,
              height: 3.5,
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.3 + 0.7 * value),
                shape: BoxShape.circle,
              ),
            );
          },
        );
      }),
    );
  }
}
