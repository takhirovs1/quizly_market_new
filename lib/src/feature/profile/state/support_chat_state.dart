part of '../screen/support_chat_screen.dart';

class MockSupportMessage {
  const MockSupportMessage({required this.text, required this.time, required this.isUser, this.isRead = true});
  final String text;
  final String time;
  final bool isUser;
  final bool isRead;
}

abstract class SupportChatState extends State<SupportChatScreen> {
  late final TextEditingController messageController;
  late final FocusNode messageFocusNode;
  late final ScrollController scrollController;
  late final ValueNotifier<bool> isSendActive;

  final List<MockSupportMessage> messages = [];

  void sendMessage() {
    final text = messageController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      messages.add(MockSupportMessage(text: text, time: _getCurrentTimeFormatted(), isUser: true, isRead: false));
    });
    messageController.clear();
    messageFocusNode.unfocus();

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
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(color: colors.buttonFill, borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        Icon(Icons.photo_library_outlined, color: colors.text, size: 20),
                        const SizedBox(width: 12),
                        Text(context.x.l10n.sendImage, style: textStyle.sfW500s14.copyWith(color: colors.text)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () {
                    Navigator.pop(sheetContext);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(color: colors.buttonFill, borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        Icon(Icons.article_outlined, color: colors.text, size: 20),
                        const SizedBox(width: 12),
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
      messages.addAll([
        MockSupportMessage(text: context.x.l10n.mockUserMessage, time: '09:24', isUser: true, isRead: true),
        MockSupportMessage(text: context.x.l10n.mockSupportMessage, time: '16:44', isUser: false),
      ]);
    }
  }

  @override
  void dispose() {
    messageController
      ..removeListener(_onMessageTextChanged)
      ..dispose();
    messageFocusNode.dispose();
    scrollController.dispose();
    isSendActive.dispose();
    super.dispose();
  }
}
