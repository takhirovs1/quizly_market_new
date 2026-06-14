part of '../screen/support_chat_screen.dart';

class MockSupportMessage {
  MockSupportMessage({
    required this.text,
    required this.time,
    required this.isUser,
    this.isRead = true,
    this.hasAdminButton = false,
  });
  String text;
  final String time;
  final bool isUser;
  final bool isRead;
  final bool hasAdminButton;
}

abstract class SupportChatState extends State<SupportChatScreen> {
  late final TextEditingController messageController;
  late final FocusNode messageFocusNode;
  late final ScrollController scrollController;
  late final ValueNotifier<bool> isSendActive;

  final List<MockSupportMessage> messages = [];
  Timer? _typingTimer;
  bool _hasSentAutoResponse = false;

  void _startWelcomeMessageTyping(String fullText) {
    final welcomeMessage = MockSupportMessage(text: '', time: _getCurrentTimeFormatted(), isUser: false);
    setState(() {
      messages.add(welcomeMessage);
    });

    var charIndex = 0;
    _typingTimer = Timer.periodic(const Duration(milliseconds: 15), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      charIndex += 2;
      if (charIndex >= fullText.length) {
        setState(() {
          welcomeMessage.text = fullText;
        });
        timer.cancel();
      } else {
        setState(() {
          welcomeMessage.text = fullText.substring(0, charIndex);
        });
      }
    });
  }

  void sendMessage() {
    final text = messageController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      messages.add(MockSupportMessage(text: text, time: _getCurrentTimeFormatted(), isUser: true, isRead: false));
    });
    messageController.clear();
    messageFocusNode.unfocus();
    _scrollToBottom();

    if (!_hasSentAutoResponse) {
      _hasSentAutoResponse = true;
      Future.delayed(const Duration(seconds: 1), () {
        if (!mounted) return;
        setState(() {
          messages.add(
            MockSupportMessage(
              text: context.x.l10n.supportAutoReply,
              time: _getCurrentTimeFormatted(),
              isUser: false,
              hasAdminButton: true,
            ),
          );
        });
        _scrollToBottom();
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          messages.add(
            MockSupportMessage(
              text: '🖼️ ${image.name}',
              time: _getCurrentTimeFormatted(),
              isUser: true,
              isRead: false,
            ),
          );
        });
        _scrollToBottom();
      }
    } on Object catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.pickFiles();
      if (result != null && result.files.single.name.isNotEmpty) {
        final fileName = result.files.single.name;
        setState(() {
          messages.add(
            MockSupportMessage(text: '📁 $fileName', time: _getCurrentTimeFormatted(), isUser: true, isRead: false),
          );
        });
        _scrollToBottom();
      }
    } on Object catch (e) {
      debugPrint('Error picking file: $e');
    }
  }

  String _getCurrentTimeFormatted() {
    final now = DateTime.now();
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
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
                          colorFilter: .mode(colors.text, .srcIn),
                        ),

                        Text(context.x.l10n.sendImage, style: textStyle.sfW500s14.copyWith(color: colors.text)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
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
                        Assets.lib.icon.fileIcon.svg(
                          package: 'ui',
                          width: 22,
                          height: 22,
                          colorFilter: .mode(colors.text, .srcIn),
                        ),
                        Text(context.x.l10n.uploadFile, style: textStyle.sfW500s14.copyWith(color: colors.text)),
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

  void _onMessageTextChanged() {
    isSendActive.value = messageController.text.trim().isNotEmpty;
  }

  @override
  void initState() {
    isSendActive = ValueNotifier<bool>(false);
    messageController = TextEditingController()..addListener(_onMessageTextChanged);
    messageFocusNode = FocusNode();
    scrollController = ScrollController();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (messages.isEmpty) {
      _startWelcomeMessageTyping(context.x.l10n.supportWelcomeMessage);
    }
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    messageController
      ..removeListener(_onMessageTextChanged)
      ..dispose();
    messageFocusNode.dispose();
    scrollController.dispose();
    isSendActive.dispose();
    super.dispose();
  }

  Future<void> openTelegramLink(String url) async {
    context.telegramWebApp.hapticImpact(.light);
    await launchUrl(.parse(url));
  }
}
