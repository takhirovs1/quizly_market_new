import 'package:ui/ui.dart';

import '../screen/recommendation_screen.dart';

abstract class RecommendationScreenState extends State<RecommendationScreen> {
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
