part of '../screen/support_chat_screen.dart';

abstract class SupportChatState extends State<SupportChatScreen> {
  late final TextEditingController messageController;
  late final FocusNode messageFocusNode;
  late final ScrollController scrollController;
  late final ValueNotifier<bool> isSendActive;

  bool showStickyHeader = false;
  Timer? _stickyHeaderTimer;

  void _onScrollUpdate() {
    _stickyHeaderTimer?.cancel();
    if (!showStickyHeader) {
      setState(() => showStickyHeader = true);
    }
    _stickyHeaderTimer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() => showStickyHeader = false);
      }
    });
  }

  // Reply & pin state (triggers setState via setters)
  SupportMessageModel? replyToMessage;
  SupportMessageModel? pinnedMessage;
  SupportMessageModel? editingMessage;

  final Map<String, GlobalKey> messageKeys = {};
  String? highlightedMessageId;

  void scrollToMessage(String messageId) {
    final key = messageKeys[messageId];
    if (key == null) return;

    if (key.currentContext != null) {
      _performScrollAndHighlight(key.currentContext!, messageId);
    } else {
      // Lazy item is disposed / offscreen. Jump close to its estimated offset first.
      final index = _cubit.state.messages.indexWhere((m) => m.id == messageId);
      if (index != -1) {
        // Average message height is ~110 pixels in reversed ListView
        final estOffset = index * 110.0;
        if (scrollController.hasClients) {
          scrollController.jumpTo(estOffset.clamp(0.0, scrollController.position.maxScrollExtent));
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (key.currentContext != null) {
            _performScrollAndHighlight(key.currentContext!, messageId);
          }
        });
      }
    }
  }

  void _performScrollAndHighlight(BuildContext targetContext, String messageId) {
    Scrollable.ensureVisible(targetContext, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    setState(() => highlightedMessageId = messageId);
    Timer(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() => highlightedMessageId = null);
      }
    });
  }

  late final SupportChatCubit _cubit;

  void sendMessage() {
    final text = messageController.text.trim();
    if (text.isEmpty) return;
    _sendTyping(false);
    if (editingMessage != null) {
      _cubit.editMessage(editingMessage!.id, text);
      setEditingMessage(null);
    } else {
      _cubit.sendMessage(text, replyToId: replyToMessage?.id);
      messageController.clear();
      setState(() => replyToMessage = null);
      _scrollToBottom();
    }
  }

  void setReplyTo(SupportMessageModel? msg) => setState(() {
    replyToMessage = msg;
    editingMessage = null;
  });
  void setPinned(SupportMessageModel? msg) => setState(() => pinnedMessage = msg);
  void setEditingMessage(SupportMessageModel? msg) => setState(() {
    editingMessage = msg;
    replyToMessage = null;
    if (msg != null) {
      messageController.text = msg.text ?? '';
      messageFocusNode.requestFocus();
    } else {
      messageController.clear();
    }
  });

  // With ListView reverse:true, position 0 = newest messages at visual bottom.
  // jumpTo(0) always shows the latest message instantly.
  void _scrollToBottom({bool instant = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) return;
      if (instant) {
        scrollController.jumpTo(0);
      } else {
        scrollController.animateTo(0, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      }
    });
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;
      final bytes = await image.readAsBytes();
      final uploaded = await _cubit.uploadFile(bytes, image.name);
      if (uploaded == null || !mounted) return;
      _cubit.sendMessage(
        '',
        photos: [SupportPhotoModel(path: uploaded.path, url: uploaded.url)],
      );
      _scrollToBottom();
    } on Object catch (e) {
      debugPrint('SupportChatState._pickImage: $e');
    }
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.pickFiles(type: FileType.any);
      if (result == null || result.files.isEmpty) return;
      final file = result.files.first;
      final bytes = file.bytes ?? (file.path != null ? await io.File(file.path!).readAsBytes() : null);
      if (bytes == null) return;
      final uploaded = await _cubit.uploadFile(bytes, file.name);
      if (uploaded == null || !mounted) return;
      _cubit.sendMessage(
        '',
        photos: [SupportPhotoModel(path: uploaded.path, url: uploaded.url)],
      );
      _scrollToBottom();
    } on Object catch (e) {
      debugPrint('SupportChatState._pickFile: $e');
    }
  }

  void _showAttachmentBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        final colors = context.x.colors;
        final textStyle = context.x.textStyle;
        return BottomSheetView(
          title: context.x.l10n.attachmentSheetTitle,
          isCenterTitle: false,
          onClose: () => Navigator.pop(sheetContext),
          child: Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _pickImage();
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(color: colors.buttonFill, borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      spacing: 8,
                      children: [
                        Assets.lib.icon.imageIcon.svg(
                          package: 'ui',
                          width: 22,
                          height: 22,
                          colorFilter: ColorFilter.mode(colors.text, BlendMode.srcIn),
                        ),
                        Text(context.x.l10n.sendImage, style: textStyle.sfW500s14.copyWith(color: colors.text)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _pickFile();
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(color: colors.buttonFill, borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      spacing: 8,
                      children: [
                        Icon(Icons.insert_drive_file_outlined, color: colors.text, size: 22),
                        Text(context.x.l10n.sendFile, style: textStyle.sfW500s14.copyWith(color: colors.text)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Timer? _sendTypingFalseTimer;
  DateTime? _lastTypingSentTime;

  void _onMessageChanged() {
    isSendActive.value = messageController.text.trim().isNotEmpty;
    _handleTypingProgress();
  }

  void _onFocusChanged() {
    if (!messageFocusNode.hasFocus) {
      _sendTyping(false);
    }
  }

  void _handleTypingProgress() {
    final text = messageController.text.trim();
    if (text.isEmpty) {
      _sendTyping(false);
      return;
    }

    final now = DateTime.now();
    if (_lastTypingSentTime == null || now.difference(_lastTypingSentTime!) > const Duration(seconds: 2)) {
      _sendTyping(true);
    }

    _sendTypingFalseTimer?.cancel();
    _sendTypingFalseTimer = Timer(const Duration(seconds: 3), () {
      _sendTyping(false);
    });
  }

  void _sendTyping(bool typing) {
    if (typing) {
      _lastTypingSentTime = DateTime.now();
    } else {
      _lastTypingSentTime = null;
      _sendTypingFalseTimer?.cancel();
    }
    _cubit.sendTyping(typing);
  }

  void _onTelegramBackTapped() {
    Navigator.of(context).maybePop();
  }

  @override
  void initState() {
    _cubit = context.read<SupportChatCubit>();
    isSendActive = ValueNotifier<bool>(false);
    messageController = TextEditingController()..addListener(_onMessageChanged);
    messageFocusNode = FocusNode()..addListener(_onFocusChanged);
    scrollController = ScrollController();
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cubit.initialize();
      _cubit.markAsRead();
      final initialMessage = widget.initialMessage;
      if (initialMessage != null && initialMessage.isNotEmpty) {
        _cubit.sendMessage(initialMessage);
      }
      context.setupTelegramBackButton(_onTelegramBackTapped);
    });
  }

  @override
  void dispose() {
    context.teardownTelegramBackButton(_onTelegramBackTapped);
    _stickyHeaderTimer?.cancel();
    _sendTypingFalseTimer?.cancel();
    _sendTyping(false);
    messageController
      ..removeListener(_onMessageChanged)
      ..dispose();
    messageFocusNode
      ..removeListener(_onFocusChanged)
      ..dispose();
    isSendActive.dispose();
    scrollController.dispose();
    super.dispose();
  }

  Future<void> openTelegramLink(String url) async {
    context.telegramWebApp.hapticImpact(.light);
    await launchUrl(Uri.parse(url));
  }
}
