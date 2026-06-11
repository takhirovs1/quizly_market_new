import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../../my_tests/models/test_model.dart';
import '../../my_tests/widgets/test_description_widget.dart';
import '../bloc/test_view.dart';
import '../state/test_mode_screen_state.dart';
import '../widgets/test_mode_item_widget.dart';
import '../widgets/test_mode_shimmer.dart';

class TestModeScreen extends StatefulWidget {
  const TestModeScreen({required this.testId, super.key});

  final String testId;

  @override
  State<TestModeScreen> createState() => _TestModeScreenState();
}

class _TestModeScreenState extends TestModeScreenState {
  @override
  Widget build(BuildContext context) => PopScope(
    canPop: false,
    onPopInvokedWithResult: (didPop, result) {
      if (!didPop) {
        onBackPressed();
      }
    },
    child: Scaffold(
      backgroundColor: context.x.colors.scaffoldBackground,
      appBar: QuizAppBar(
        telegramWebAppSafeAreaInsetTop: context.telegramWebApp.safeAreaInset.top.toDouble(),
        title: context.x.l10n.mode,
      ),
      body: BlocBuilder<TestView, TestViewState>(
        builder: (context, state) {
          final detail = state.detail;
          if (detail == null) {
            return const TestModeShimmer();
          }
          final testModel = TestModel(
            id: detail.id,
            categoryId: detail.categoryId,
            name: detail.name ?? '',
            description: detail.description ?? '',
            price: detail.price,
            isPurchased: detail.isPurchased,
            isLiked: detail.isLiked,
            questionCount: detail.questionCount,
            createdAt: detail.createdAt,
            academicYear: detail.academicYear,
            semester: detail.semester,
            code: detail.code,
            isArchived: detail.isArchived,
            createdBy: detail.academicYear != null ? '${detail.academicYear}' : null,
          );
          return LayoutBuilder(
            builder: (context, constraints) => constraints.maxWidth >= 800
                ? _buildWebLayout(context, testModel, constraints)
                : _buildMobileLayout(context, testModel, constraints),
          );
        },
      ),
    ),
  );

  // ─── WEB ─────────────────────────────────────────────────────────────────

  Widget _buildWebLayout(BuildContext context, TestModel testModel, BoxConstraints constraints) =>
      SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Padding(
              padding: const .all(28),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: .stretch,
                  children: [
                    // ── Left: Test details card ──────────────────────────────
                    Expanded(
                      flex: 5,
                      child: _WebInfoCard(
                        testModel: testModel,
                        onPressLike: onPressLike,
                        onPressShare: onPressShare,
                        onPressArchive: onPressArchive,
                      ),
                    ),
                    const SizedBox(width: 28),
                    // ── Right: Mode selection ────────────────────────────────
                    Expanded(
                      flex: 7,
                      child: Column(
                        crossAxisAlignment: .start,
                        mainAxisSize: .min,
                        children: [
                          _WebSectionHeader(
                            icon: Icons.grid_view_rounded,
                            title: context.x.l10n.chooseMode,
                            subtitle: context.x.l10n.chooseModeSubtitle,
                          ),
                          const SizedBox(height: 20),
                          ...List.generate(testModes.length, (index) {
                            final mode = testModes[index];
                            final isComingSoon = mode.type == .group || mode.type == .flashcard;
                            return Padding(
                              padding: .only(bottom: index < testModes.length - 1 ? 14 : 0),
                              child: _WebModeCard(
                                title: mode.title,
                                description: mode.description,
                                image: mode.image.svg(
                                  package: 'ui',
                                  width: 28,
                                  height: 28,
                                  colorFilter: .mode(context.x.colors.white, .srcATop),
                                ),
                                isComingSoon: isComingSoon,
                                onPressed: () => onPressTestMode(mode),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

  // ─── MOBILE ──────────────────────────────────────────────────────────────

  Widget _buildMobileLayout(BuildContext context, TestModel testModel, BoxConstraints constraints) => Padding(
    padding: const .symmetric(horizontal: 16, vertical: 12),
    child: Column(
      crossAxisAlignment: .start,
      children: [
        TestDescriptionWidget(
          test: testModel,
          onPressLike: onPressLike,
          onPressShare: onPressShare,
          onPressArchive: onPressArchive,
        ),
        const SizedBox(height: 16),
        Text(context.x.l10n.chooseMode, style: context.x.textStyle.sfW500s22.copyWith(color: context.x.colors.text)),
        const SizedBox(height: 12),
        Expanded(
          child: LayoutBuilder(
            builder: (context, gridConstraints) {
              final width = gridConstraints.maxWidth;
              // Guard against infinite height on first web frame
              final height = gridConstraints.maxHeight.isFinite
                  ? gridConstraints.maxHeight
                  : MediaQuery.sizeOf(context).height * 0.45;
              final itemWidth = (width - 12) / 2;
              final itemHeight = (height - 12) / 2;
              final childAspectRatio = (itemHeight > 0 && itemWidth > 0) ? (itemWidth / itemHeight) : 0.9;
              return GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: testModes.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: childAspectRatio.clamp(0.7, 1.8),
                ),
                itemBuilder: _buildMobileItem,
              );
            },
          ),
        ),
      ],
    ),
  );

  Widget _buildMobileItem(BuildContext context, int index) {
    final mode = testModes[index];
    return TestModeItemWidget(
      title: mode.title,
      description: mode.description,
      image: mode.image.svg(package: 'ui', width: 64, height: 64, colorFilter: .mode(context.x.colors.white, .srcATop)),
      isComingSoon: mode.type == .group || mode.type == .flashcard,
      onPressed: () => onPressTestMode(mode),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Web sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _WebInfoCard extends StatelessWidget {
  const _WebInfoCard({
    required this.testModel,
    required this.onPressLike,
    required this.onPressShare,
    this.onPressArchive,
  });

  final TestModel testModel;
  final VoidCallback onPressLike;
  final VoidCallback onPressShare;
  final VoidCallback? onPressArchive;

  @override
  Widget build(BuildContext context) {
    final colors = context.x.colors;
    return Container(
      decoration: BoxDecoration(
        color: colors.cardBackground2,
        borderRadius: .circular(24),
        border: .all(color: colors.primary.withValues(alpha: 0.1), width: 1.5),
        boxShadow: [BoxShadow(color: colors.black.withValues(alpha: 0.05), blurRadius: 24, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          // Gradient banner header
          Container(
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colors.primary, colors.primary.withValues(alpha: 0.7)],
                begin: .centerLeft,
                end: .centerRight,
              ),
              borderRadius: const .only(topLeft: .circular(23), topRight: .circular(23)),
            ),
            padding: const .symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), shape: .circle),
                  child: const Icon(Icons.school_rounded, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: .start,
                    mainAxisAlignment: .center,
                    children: [
                      Text(
                        'QuizlyMarket',
                        style: context.x.textStyle.sfW600s16.copyWith(
                          color: Colors.white,
                          fontSize: 11,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        context.x.l10n.enterTest,
                        style: context.x.textStyle.sfW600s16.copyWith(color: Colors.white, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const .all(20),
            child: TestDescriptionWidget(
              test: testModel,
              onPressLike: onPressLike,
              onPressShare: onPressShare,
              onPressArchive: onPressArchive,
            ),
          ),
        ],
      ),
    );
  }
}

class _WebSectionHeader extends StatelessWidget {
  const _WebSectionHeader({required this.icon, required this.title, required this.subtitle});

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = context.x.colors;
    return Row(
      crossAxisAlignment: .center,
      children: [
        Container(
          width: 4,
          height: 36,
          decoration: BoxDecoration(color: colors.primary, borderRadius: .circular(4)),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: .start,
          children: [
            Row(
              children: [
                Icon(icon, color: colors.primary, size: 18),
                const SizedBox(width: 8),
                Text(
                  title.toUpperCase(),
                  style: context.x.textStyle.sfW600s16.copyWith(color: colors.text, fontSize: 16, letterSpacing: 0.4),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Text(subtitle, style: context.x.textStyle.sfW400s12.copyWith(color: colors.gray)),
          ],
        ),
      ],
    );
  }
}

class _WebModeCard extends StatefulWidget {
  const _WebModeCard({
    required this.title,
    required this.description,
    required this.image,
    required this.onPressed,
    this.isComingSoon = false,
  });

  final String title;
  final String description;
  final Widget image;
  final VoidCallback onPressed;
  final bool isComingSoon;

  @override
  State<_WebModeCard> createState() => _WebModeCardState();
}

class _WebModeCardState extends State<_WebModeCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.x.colors;
    final textStyle = context.x.textStyle;
    final isActive = !widget.isComingSoon;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: isActive ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
      child: GestureDetector(
        onTap: isActive ? widget.onPressed : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: _isHovered && isActive ? colors.primary.withValues(alpha: 0.04) : colors.cardBackground2,
            borderRadius: .circular(18),
            border: .all(
              color: _isHovered && isActive
                  ? colors.primary.withValues(alpha: 0.4)
                  : colors.black.withValues(alpha: 0.06),
              width: _isHovered && isActive ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovered && isActive
                    ? colors.primary.withValues(alpha: 0.12)
                    : colors.black.withValues(alpha: 0.04),
                blurRadius: _isHovered && isActive ? 20 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const .symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              // Icon circle
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: isActive ? colors.primary : colors.gray.withValues(alpha: 0.25),
                  shape: .circle,
                  boxShadow: isActive && _isHovered
                      ? [
                          BoxShadow(
                            color: colors.primary.withValues(alpha: 0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [],
                ),
                child: Center(child: widget.image),
              ),
              const SizedBox(width: 16),
              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.title,
                            style: textStyle.sfW600s16.copyWith(
                              color: isActive ? colors.text : colors.gray,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        if (widget.isComingSoon) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const .symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: colors.primary.withValues(alpha: 0.1),
                              borderRadius: .circular(20),
                              border: .all(color: colors.primary.withValues(alpha: 0.2)),
                            ),
                            child: Text(
                              context.x.l10n.comingSoon,
                              style: textStyle.sfW500s11.copyWith(color: colors.primary, fontSize: 10),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.description,
                      style: textStyle.sfW400s12.copyWith(color: colors.gray),
                      maxLines: 2,
                      overflow: .ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Arrow
              AnimatedSlide(
                offset: _isHovered && isActive ? const Offset(0.2, 0) : Offset.zero,
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                child: Icon(
                  isActive ? Icons.arrow_forward_ios_rounded : Icons.lock_outline_rounded,
                  color: isActive
                      ? (_isHovered ? colors.primary : colors.gray.withValues(alpha: 0.5))
                      : colors.gray.withValues(alpha: 0.3),
                  size: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
