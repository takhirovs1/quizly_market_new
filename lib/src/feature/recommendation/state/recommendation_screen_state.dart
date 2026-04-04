import 'package:ui/ui.dart';

import '../../../common/constant/constant.dart';
import '../../../common/extension/context_extension.dart';
import '../screen/recommendation_screen.dart';

abstract class RecommendationScreenState extends State<RecommendationScreen> {
  late final TextEditingController searchController;

  void onShareButtonPressed(String title, String companyName, String description, String price, String questionAmount) {
    const fallbackProductId = '1234567';
    const link = '${Constant.botUrl}?startapp=$fallbackProductId';
    final message =
        'Решайте тесты удобно и быстро в QuizlyMarket 😊.\n\nУниверситет: $companyName\nКурс: $description\nПредмет: $title\nКоличество вопросов: $questionAmount ta\n\nСсылка: $link';
    final shareLink = 'https://t.me/share/url?url=${Uri.encodeComponent(message)}';
    context.telegramWebApp.openTelegramLink(shareLink);
  }

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
