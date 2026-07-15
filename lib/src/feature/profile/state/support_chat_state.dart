part of '../screen/support_chat_screen.dart';

abstract class SupportChatState extends State<SupportChatScreen> {
  late final TextEditingController messageController;
  late final FocusNode messageFocusNode;
  late final ScrollController scrollController;
  late final ValueNotifier<bool> isSendActive;

  SupportChatCubit get _cubit => context.read<SupportChatCubit>();

  void sendMessage() {
    final text = messageController.text.trim();
    if (text.isEmpty) return;
    _cubit.sendMessage(text);
    messageController.clear();
    messageFocusNode.unfocus();
    _scrollToBottom();
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
      final image = await picker.pickImage(source: .gallery);
      if (image == null) return;
      final bytes = await image.readAsBytes();
      final uploaded = await _cubit.uploadFile(bytes, image.name);
      if (uploaded == null || !mounted) return;
      _cubit.sendMessage('', photoPaths: [uploaded.path]);
      _scrollToBottom();
    } on Object catch (e) {
      debugPrint('SupportChatState._pickImage: $e');
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
            child: InkWell(
              onTap: () {
                Navigator.pop(sheetContext);
                _pickImage();
              },
              borderRadius: .circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(color: colors.buttonFill, borderRadius: .circular(12)),
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
          ),
        );
      },
    );
  }

  void _onMessageChanged() => isSendActive.value = messageController.text.trim().isNotEmpty;

  @override
  void initState() {
    isSendActive = ValueNotifier<bool>(false);
    messageController = TextEditingController()..addListener(_onMessageChanged);
    messageFocusNode = FocusNode();
    scrollController = ScrollController()..addListener(_onScroll);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _cubit.initialize());
  }

  void _onScroll() {
    if (scrollController.position.pixels <= 80) _cubit.loadMore();
  }

  @override
  void dispose() {
    messageController
      ..removeListener(_onMessageChanged)
      ..dispose();
    messageFocusNode.dispose();
    scrollController
      ..removeListener(_onScroll)
      ..dispose();
    isSendActive.dispose();
    super.dispose();
  }

  Future<void> openTelegramLink(String url) async {
    context.telegramWebApp.hapticImpact(.light);
    await launchUrl(.parse(url));
  }
}
