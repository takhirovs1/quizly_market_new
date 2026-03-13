import 'package:ui/ui.dart';

import '../screen/more_recommendation_screen.dart';

abstract class MoreRecommendationScreenState extends State<MoreRecommendationScreen> {
  late final TextEditingController searchController;

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
