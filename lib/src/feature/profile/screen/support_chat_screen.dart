import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import 'package:ui/ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../common/extension/context_extension.dart';
import '../bloc/support_chat_cubit.dart';
import '../model/support_chat_model.dart';

part '../state/support_chat_state.dart';

// ─── Date-separator helper ───────────────────────────────────────────────────

String _dayLabel(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final d = DateTime(date.year, date.month, date.day);
  if (d == today) return 'Bugun';
  if (d == yesterday) return 'Kecha';
  return '${date.day}.${date.month.toString().padLeft(2, '0')}.${date.year}';
}

// Builds a flat list of items ordered oldest→newest.
// ListView uses reverse:true so index-0 is visual bottom.
List<Object> _buildItems(List<SupportMessageModel> messages) {
  final items = <Object>[];
  DateTime? lastDay;
  for (final m in messages) {
    final day = DateTime(m.createdAt.year, m.createdAt.month, m.createdAt.day);
    if (lastDay == null || day != lastDay) {
      items.add(day);
      lastDay = day;
    }
    items.add(m);
  }
  // reverse so newest is at index 0 (visual bottom with reverse:true)
  return items.reversed.toList();
}

// ─── Screen ──────────────────────────────────────────────────────────────────

class SupportChatScreen extends StatefulWidget {
  const SupportChatScreen({super.key});

  @override
  State<SupportChatScreen> createState() => _SupportChatScreenState();
}

class _SupportChatScreenState extends SupportChatState {
  // Tracks the current "visible" date label shown in the sticky overlay
  String _currentStickyLabel = '';

  @override
  Widget build(BuildContext context) {
    final colors = context.x.colors;
    final textStyle = context.x.textStyle;
    final isMobile = context.x.isMobile;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final headerBg = isDark ? const Color(0xFF17212B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF1E2936) : const Color(0xFFEBEDF2);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: headerBg,
      appBar: QuizAppBar(
        title: 'Yordam',
        telegramWebAppSafeAreaInsetTop: context.telegramWebApp.safeAreaInset.top.toDouble(),
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
          },
          builder: (context, state) {
            final content = _buildChatContent(context, state, colors, textStyle, isDark, borderColor);
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

  // ─── Chat body ─────────────────────────────────────────────────────────────

  Widget _buildChatContent(
    BuildContext context,
    SupportChatCubitState state,
    ThemeColors colors,
    AppTypography textStyle,
    bool isDark,
    Color borderColor,
  ) => Column(
    children: [
      // Pinned banner
      if (pinnedMessage != null) _buildPinnedBanner(colors, textStyle, isDark, borderColor),

      // Messages area
      Expanded(child: _buildMessagesList(context, state, colors, textStyle, isDark)),

      // Input bar
      _buildInputBar(context, state, colors, textStyle, isDark, borderColor),
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
        color: isDark ? Colors.black.withValues(alpha: 0.45) : Colors.white.withValues(alpha: 0.15),
        colorBlendMode: isDark ? BlendMode.darken : BlendMode.lighten,
      ),

      if (state.status.isLoading)
        Center(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.4), borderRadius: .circular(12)),
            child: const CircularProgressIndicator(color: Color(0xFF3B82F6), strokeWidth: 2.5),
          ),
        )
      else
        // NotificationListener detects scroll to find the top-visible date
        NotificationListener<ScrollNotification>(
          onNotification: (n) {
            _updateStickyLabel(n, state.messages);
            return false;
          },
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              // Messages ListView
              Builder(
                builder: (context) {
                  final items = _buildItems(state.messages);
                  return ListView.builder(
                    controller: scrollController,
                    reverse: true,
                    padding: const EdgeInsets.only(left: 12, right: 12, top: 44, bottom: 8),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      if (item is DateTime) {
                        return _buildInlineDate(item);
                      }
                      if (item is SupportMessageModel) {
                        return _buildMessage(context, item, colors, textStyle, isDark);
                      }
                      return const SizedBox.shrink();
                    },
                  );
                },
              ),

              // Sticky date label at top (Telegram-style)
              if (_currentStickyLabel.isNotEmpty) Positioned(top: 8, child: _buildDateChip(_currentStickyLabel)),

              // Load-more indicator
              if (state.status.isLoadingMore)
                Positioned(
                  top: 8,
                  child: ClipRRect(
                    borderRadius: .circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.25),
                          borderRadius: .circular(20),
                        ),
                        child: const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
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

  /// Updates [_currentStickyLabel] by finding which date group is at the top.
  void _updateStickyLabel(ScrollNotification n, List<SupportMessageModel> messages) {
    if (messages.isEmpty) return;
    // With reverse:true the "top" of the screen = most recent scroll position.
    // We look at the scroll offset to find the closest date group.
    // Simple heuristic: determine the date of the latest visible message.
    // We compute which day corresponds to the current scroll position by
    // traversing from the bottom of the message list.
    final pos = scrollController.hasClients ? scrollController.position.pixels : 0.0;
    final maxExtent = scrollController.hasClients ? scrollController.position.maxScrollExtent : 0.0;
    // Fraction of how far scrolled toward oldest messages
    final fraction = maxExtent > 0 ? (pos / maxExtent).clamp(0.0, 1.0) : 0.0;
    // Map fraction to message index (0 = newest, len-1 = oldest)
    final idx = (fraction * (messages.length - 1)).round().clamp(0, messages.length - 1);
    final msg = messages[messages.length - 1 - idx];
    final label = _dayLabel(msg.createdAt);
    if (label != _currentStickyLabel) {
      setState(() => _currentStickyLabel = label);
    }
  }

  // Inline date separator (appears in the list, scrolls with messages)
  Widget _buildInlineDate(DateTime date) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Center(child: _buildDateChip(_dayLabel(date))),
  );

  // Shared date chip widget
  Widget _buildDateChip(String label) => ClipRRect(
    borderRadius: .circular(12),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.28), borderRadius: .circular(12)),
        child: Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
    ),
  );

  // ─── Pinned message banner ─────────────────────────────────────────────────

  Widget _buildPinnedBanner(ThemeColors colors, AppTypography textStyle, bool isDark, Color borderColor) {
    final bg = isDark ? const Color(0xFF17212B) : Colors.white;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 36,
            decoration: BoxDecoration(color: const Color(0xFF3B82F6), borderRadius: .circular(2)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              mainAxisSize: .min,
              children: [
                const Text(
                  'Pinned Message',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF3B82F6)),
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
  }

  // ─── Single message bubble ─────────────────────────────────────────────────

  Widget _buildMessage(
    BuildContext context,
    SupportMessageModel msg,
    ThemeColors colors,
    AppTypography textStyle,
    bool isDark,
  ) {
    final isUser = msg.isUser;

    final bubbleBg = isUser
        ? (isDark ? const Color(0xFF182533) : Colors.white)
        : (isDark ? const Color(0xFF2B5278) : const Color(0xFFEEFFDE));

    final textColor = isDark ? Colors.white : Colors.black;

    final timeColor = isUser
        ? (isDark ? Colors.white.withValues(alpha: 0.6) : const Color(0xFF64748B))
        : (isDark ? Colors.white.withValues(alpha: 0.7) : const Color(0xFF5E8F57));

    final checkColor = isDark ? Colors.white.withValues(alpha: 0.7) : const Color(0xFF5E8F57);

    final borderRadius = BorderRadius.only(
      topLeft: const Radius.circular(16),
      topRight: const Radius.circular(16),
      bottomLeft: Radius.circular(isUser ? 16 : 0),
      bottomRight: Radius.circular(isUser ? 0 : 16),
    );

    // If message is ONLY photos (no text), render without bubble container
    final hasText = msg.text != null && msg.text!.isNotEmpty;
    final hasPhotos = msg.photos.isNotEmpty;

    return GestureDetector(
      onLongPress: () => _showMessageActions(context, msg, colors, textStyle),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 4),
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
                if (hasPhotos) _buildPhotos(context, msg.photos, isUser, isDark, borderRadius),

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
                          color: Colors.black.withValues(alpha: 0.1),
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
                        if (msg.replyTo != null) _buildReplyPreview(msg.replyTo!, colors, textStyle, isUser, isDark),

                        // Text
                        if (hasText) Text(msg.text!, style: TextStyle(fontSize: 13.5, color: textColor, height: 1.5)),

                        const SizedBox(height: 2),

                        // Timestamp
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(msg.formattedTime, style: TextStyle(fontSize: 9, color: timeColor, height: 1)),
                            if (isUser) ...[const SizedBox(width: 3), _DoubleCheck(color: checkColor)],
                          ],
                        ),
                      ],
                    ),
                  ),

                // If only photos — show time overlay on the last photo
                if (hasPhotos && !hasText && msg.replyTo == null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2, right: 4, left: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                      children: [
                        Text(msg.formattedTime, style: TextStyle(fontSize: 9, color: timeColor, height: 1)),
                        if (isUser) ...[const SizedBox(width: 3), _DoubleCheck(color: checkColor)],
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Photos (tappable → custom fullscreen viewer) ────────────────────────

  Widget _buildPhotos(
    BuildContext context,
    List<SupportPhotoModel> photos,
    bool isUser,
    bool isDark,
    BorderRadius bubbleRadius,
  ) {
    final urls = photos.map((p) => p.url).toList();
    return ClipRRect(
      borderRadius: bubbleRadius,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: photos.asMap().entries.map((entry) {
          final i = entry.key;
          final p = entry.value;
          return GestureDetector(
            onTap: () => _openImageViewer(context, urls, i),
            child: Hero(
              tag: 'chat_photo_${p.url}_$i',
              child: Image.network(
                p.url,
                fit: BoxFit.cover,
                width: double.infinity,
                loadingBuilder: (ctx, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    height: 180,
                    color: isDark ? const Color(0xFF1E2936) : const Color(0xFFE8EDF5),
                    child: Center(
                      child: CircularProgressIndicator(
                        value: progress.expectedTotalBytes != null
                            ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                            : null,
                        color: const Color(0xFF3B82F6),
                        strokeWidth: 2,
                      ),
                    ),
                  );
                },
                errorBuilder: (_, __, ___) => Container(
                  height: 100,
                  color: isDark ? const Color(0xFF1E2936) : const Color(0xFFE8EDF5),
                  child: const Center(child: Icon(Icons.broken_image_outlined, color: Colors.grey, size: 32)),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _openImageViewer(BuildContext context, List<String> urls, int initialIndex) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: false,
        barrierColor: Colors.transparent,
        pageBuilder: (_, __, ___) => _ChatImageViewer(urls: urls, initialIndex: initialIndex),
        transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 220),
      ),
    );
  }

  // Reply preview inside bubble
  Widget _buildReplyPreview(
    SupportReplyToModel reply,
    ThemeColors colors,
    AppTypography textStyle,
    bool isUser,
    bool isDark,
  ) {
    final lineColor = isUser
        ? (isDark ? Colors.white.withValues(alpha: 0.5) : const Color(0xFF3B82F6))
        : const Color(0xFF3B82F6);
    final bgColor = isUser
        ? Colors.white.withValues(alpha: isDark ? 0.12 : 0.0)
        : const Color(0xFF3B82F6).withValues(alpha: 0.08);

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: lineColor, width: 3)),
        color: bgColor,
        borderRadius: const BorderRadius.only(topRight: Radius.circular(4), bottomRight: Radius.circular(4)),
      ),
      child: Text(
        reply.textPreview ?? (reply.hasPhoto ? '🖼 Photo' : ''),
        style: textStyle.sfW400s12.copyWith(color: isUser ? Colors.white.withValues(alpha: 0.8) : colors.gray),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  // ─── Long-press action sheet ───────────────────────────────────────────────

  void _showMessageActions(BuildContext context, SupportMessageModel msg, ThemeColors colors, AppTypography textStyle) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => BottomSheetView(
        title: '',
        isCenterTitle: false,
        onClose: () => Navigator.pop(context),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _actionTile(
                icon: Icons.reply,
                label: 'Reply',
                colors: colors,
                textStyle: textStyle,
                onTap: () {
                  Navigator.pop(context);
                  setReplyTo(msg);
                },
              ),
              const SizedBox(height: 8),
              _actionTile(
                icon: Icons.push_pin_outlined,
                label: 'Pin message',
                colors: colors,
                textStyle: textStyle,
                onTap: () {
                  Navigator.pop(context);
                  setPinned(msg);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionTile({
    required IconData icon,
    required String label,
    required ThemeColors colors,
    required AppTypography textStyle,
    required VoidCallback onTap,
  }) => InkWell(
    onTap: onTap,
    borderRadius: .circular(12),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(color: colors.buttonFill, borderRadius: .circular(12)),
      child: Row(
        spacing: 10,
        children: [
          Icon(icon, color: colors.text, size: 20),
          Text(label, style: textStyle.sfW500s14.copyWith(color: colors.text)),
        ],
      ),
    ),
  );

  // ─── Input bar ─────────────────────────────────────────────────────────────

  Widget _buildInputBar(
    BuildContext context,
    SupportChatCubitState state,
    ThemeColors colors,
    AppTypography textStyle,
    bool isDark,
    Color borderColor,
  ) {
    const kButtonSize = 44.0; // uniform height for all buttons
    final barBg = isDark ? const Color(0xFF17212B) : Colors.white;
    final safeBottom = MediaQuery.paddingOf(context).bottom;
    final inputBg = isDark ? const Color(0xFF1E2936) : const Color(0xFFF0F2F5);
    final inputBorder = isDark ? const Color(0xFF2A3347) : const Color(0xFFDEE2E9);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Reply banner ────────────────────────────────────────────────
        if (replyToMessage != null)
          Container(
            padding: const EdgeInsets.fromLTRB(0, 8, 12, 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF13172A) : const Color(0xFFF5F7FB),
              border: Border(top: BorderSide(color: borderColor)),
            ),
            child: Row(
              children: [
                Container(
                  width: 3,
                  height: 40,
                  margin: const EdgeInsets.only(left: 12, right: 10),
                  decoration: const BoxDecoration(
                    color: Color(0xFF3B82F6),
                    borderRadius: BorderRadius.only(topRight: Radius.circular(8), bottomRight: Radius.circular(8)),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: .start,
                    mainAxisSize: .min,
                    children: [
                      Text(
                        replyToMessage!.isUser ? 'Sizga javob' : 'Quizly support ga javob',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF3B82F6)),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        replyToMessage!.text ?? (replyToMessage!.photos.isNotEmpty ? '🖼 Photo' : ''),
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
                isDark: isDark,
                onTap: () => _showAttachmentBottomSheet(context),
                child: Icon(
                  Icons.attach_file_rounded,
                  color: isDark ? Colors.white.withValues(alpha: 0.55) : const Color(0xFF8A9BB0),
                  size: 21,
                ),
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
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white : const Color(0xFF202732),
                        height: 1.4,
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.newline,
                      decoration: InputDecoration(
                        hintText: context.x.l10n.messageInputHint,
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white.withValues(alpha: 0.35) : const Color(0xFFA0A9BA),
                        ),
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
                  isDark: isDark,
                  onTap: active && !state.isSending ? sendMessage : null,
                  filled: active,
                  child: state.isSending
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Icon(
                          Icons.send_rounded,
                          color: active
                              ? Colors.white
                              : (isDark ? Colors.white.withValues(alpha: 0.3) : const Color(0xFFA0A9BA)),
                          size: 20,
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Uniform square button used for attach & send
  Widget _barButton({
    required double size,
    required bool isDark,
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
        color: filled ? const Color(0xFF3B82F6) : Colors.transparent,
        borderRadius: .circular(12),
        border: filled
            ? null
            : Border.all(color: isDark ? const Color(0xFF2A3347) : const Color(0xFFDEE2E9), width: 1.5),
      ),
      child: child,
    ),
  );
}

// ─── Double-check widget ──────────────────────────────────────────────────────

class _DoubleCheck extends StatelessWidget {
  const _DoubleCheck({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) => CustomPaint(
    size: const Size(14, 9),
    painter: _DoubleCheckPainter(color: color),
  );
}

class _DoubleCheckPainter extends CustomPainter {
  const _DoubleCheckPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

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
  }

  @override
  bool shouldRepaint(_DoubleCheckPainter old) => old.color != color;
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
  double _bgOpacity = 1.0;

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
      backgroundColor: Colors.black.withValues(alpha: _bgOpacity),
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
                  maxScale: 5.0,
                  child: Hero(
                    tag: 'chat_photo_${widget.urls[index]}_$index',
                    child: Image.network(
                      widget.urls[index],
                      fit: BoxFit.contain,
                      loadingBuilder: (ctx, child, progress) {
                        if (progress == null) return child;
                        return SizedBox(
                          width: 48,
                          height: 48,
                          child: CircularProgressIndicator(
                            value: progress.expectedTotalBytes != null
                                ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                                : null,
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        );
                      },
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.broken_image_outlined, color: Colors.white54, size: 64),
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
                  colors: [Colors.black.withValues(alpha: 0.55), Colors.transparent],
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 24),
                    onPressed: _dismiss,
                  ),
                  const Spacer(),
                  if (widget.urls.length > 1)
                    Text(
                      '${_current + 1} / ${widget.urls.length}',
                      style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
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
