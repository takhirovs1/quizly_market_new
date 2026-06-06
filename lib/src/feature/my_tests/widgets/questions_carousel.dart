import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../models/demo_test_model.dart';
import 'question_card_widget.dart';

class QuestionsCarousel extends StatefulWidget {
  const QuestionsCarousel({required this.questions, required this.languageCode, required this.currentPage, super.key});

  final List<DemoQuestion> questions;
  final String languageCode;
  final ValueNotifier<int> currentPage;

  @override
  State<QuestionsCarousel> createState() => _QuestionsCarouselState();
}

class _QuestionsCarouselState extends State<QuestionsCarousel> {
  late final PageController _pageController;
  late final List<GlobalKey> _measureKeys;
  double? _maxHeight;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _measureKeys = .generate(widget.questions.length, (_) => GlobalKey());
    WidgetsBinding.instance.addPostFrameCallback(_measureHeights);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _measureHeights(_) {
    var max = 0.0;
    for (final key in _measureKeys) {
      final h = key.currentContext?.size?.height ?? 0.0;
      if (h > max) max = h;
    }
    if (max > 0 && mounted) setState(() => _maxHeight = max.ceilToDouble() + 2.0);
  }

  BoxDecoration _cardDecoration(BuildContext context) => BoxDecoration(
    color: context.x.colors.cardBackground2,
    borderRadius: .circular(24),
    boxShadow: [
      BoxShadow(color: context.x.colors.black.withValues(alpha: .08), offset: const Offset(0, 12), blurRadius: 56),
      BoxShadow(color: context.x.colors.black.withValues(alpha: .05), offset: .zero, blurRadius: 3),
    ],
  );

  Widget _buildCard(BuildContext context, DemoQuestion question, {Key? key}) => Padding(
    key: key,
    padding: const .symmetric(horizontal: 16),
    child: DecoratedBox(
      decoration: _cardDecoration(context),
      child: Padding(
        padding: const .all(20),
        child: QuestionCardWidget(question: question, languageCode: widget.languageCode),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => Column(
    children: [
      const SizedBox(height: 28),
      Offstage(
        child: Column(
          crossAxisAlignment: .stretch,
          children: [
            for (int i = 0; i < widget.questions.length; i++)
              _buildCard(context, widget.questions[i], key: _measureKeys[i]),
          ],
        ),
      ),
      if (_maxHeight != null) ...[
        SizedBox(
          height: _maxHeight,
          child: PageView.builder(
            clipBehavior: .none,
            controller: _pageController,
            itemCount: widget.questions.length,
            onPageChanged: (index) => widget.currentPage.value = index,
            itemBuilder: (context, index) => _buildCard(context, widget.questions[index]),
          ),
        ),
        const SizedBox(height: 8),
        ValueListenableBuilder(
          valueListenable: widget.currentPage,
          builder: (context, current, _) => Row(
            mainAxisAlignment: .center,
            children: [
              PageIndicator(
                selectedPage: current,
                totalPages: widget.questions.length,
                onPageSelected: (index) => _pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                ),
              ),
            ],
          ),
        ),
      ],
    ],
  );
}
