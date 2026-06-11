import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:octopus/octopus.dart';
import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../../../common/router/pages.dart';
import '../../my_tests/models/test_model.dart';
import '../bloc/recommendation_cubit.dart';
import '../screen/recommendation_screen.dart';

abstract class RecommendationScreenState extends State<RecommendationScreen> {
  late final RecommendationCubit recommendationCubit;
  late final TextEditingController searchController;
  late final ScrollController scrollController;
  Timer? _debounceTimer;
  var _isLoadingMore = false;

  String _lastText = '';

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController()..addListener(_onSearchChanged);
    _lastText = searchController.text;
    scrollController = ScrollController()..addListener(_onScroll);
    recommendationCubit = context.read<RecommendationCubit>()..initialize();
  }

  void _onSearchChanged() {
    final text = searchController.text;
    if (text == _lastText) return;
    _lastText = text;

    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    final query = text.trim();
    if (query.isNotEmpty && query.length <= 3) return;

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (query.isEmpty) {
        recommendationCubit.initialize();
      } else {
        recommendationCubit.getAllTests(search: query);
      }
    });
  }

  void _onScroll() {
    if (_isLoadingMore || !scrollController.hasClients) return;
    final maxScroll = scrollController.position.maxScrollExtent;
    final currentScroll = scrollController.position.pixels;
    if (maxScroll - currentScroll <= 200) {
      _isLoadingMore = true;
      recommendationCubit.getAllTests(loadMore: true).whenComplete(() => _isLoadingMore = false);
    }
  }

  void onBuyTestPressed(TestModel test) =>
      context.octopus.push(Routes.purchaseTest, arguments: <String, String>{'id': test.id?.toString() ?? ''});

  void onShareTestPressed(TestModel test) {
    context.telegramWebApp.hapticImpact(.light);
    context.shareTest(
      test.name ?? '',
      test.categoryName ?? '',
      test.description ?? '',
      test.price?.toString() ?? '0',
      test.questionCount?.toString() ?? '0',
      code: test.code,
    );
  }

  void onLikeTestPressed(TestModel test) {
    context.telegramWebApp.hapticImpact(.light);
    recommendationCubit.toggleLikeTest(test);
  }

  Future<void> onRefresh() async {
    context.telegramWebApp.hapticImpact(.light);
    await recommendationCubit.initialize(search: searchController.text);
  }

  @override
  void dispose() {
    searchController.dispose();
    _debounceTimer?.cancel();
    scrollController.dispose();
    super.dispose();
  }
}
