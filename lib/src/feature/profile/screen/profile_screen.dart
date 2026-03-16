import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../state/profile_screen_state.dart';
import '../widget/profile_payment_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ProfileScreenState {
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.x.colors.scaffoldBackground,
    body: NestedScrollView(
      headerSliverBuilder: (context, innerBoxScrolled) => [
        SliverAppBar(
          backgroundColor: context.x.colors.scaffoldBackground,
          surfaceTintColor: context.x.colors.transparent,
          expandedHeight: expandedHeaderHeight(context),
          floating: false,
          pinned: true,
          centerTitle: true,
          flexibleSpace: LayoutBuilder(
            builder: (context, constraints) {
              final layout = headerLayout(context, constraints);
              return Stack(
                fit: .expand,
                children: [
                  ColoredBox(color: context.x.colors.scaffoldBackground),
                  SafeArea(
                    bottom: false,
                    child: Align(
                      alignment: Alignment(0, -0.25 * (1 - layout.t)),
                      child: Opacity(
                        opacity: layout.headerAlpha,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: (constraints.maxHeight - MediaQuery.paddingOf(context).top - 8).clamp(
                              0.0,
                              10000.0,
                            ),
                          ),
                          child: FittedBox(
                            fit: .scaleDown,
                            alignment: .bottomCenter,
                            child: Column(
                              mainAxisSize: .min,
                              children: [
                                ClipRRect(
                                  borderRadius: .circular(layout.avatar / 2),
                                  child: SizedBox(
                                    width: 100,
                                    height: 100,
                                    child: Assets.lib.images.samandar.image(package: 'ui', fit: .cover),
                                  ),
                                ),
                                SizedBox(height: headerNameSpacing(layout.expandedHeight)),
                                Padding(
                                  padding: .symmetric(horizontal: nameHorizontalPadding(layout.width)),
                                  child: Text(
                                    'Samandar Takhirov',
                                    maxLines: 1,
                                    overflow: .ellipsis,
                                    textAlign: .center,
                                    style: context.x.textStyle.w700s28.copyWith(
                                      fontSize: nameSizeExpanded(layout.width),
                                      color: context.x.colors.primary,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Padding(
                                  padding: .symmetric(horizontal: phoneHorizontalPadding(layout.width)),
                                  child: Text(
                                    'ID: 1234567890 User: @Takhirovs',
                                    maxLines: 1,
                                    overflow: .ellipsis,
                                    textAlign: .center,
                                    style: context.x.textStyle.w400s14.copyWith(
                                      fontSize: phoneSize(layout.width),
                                      color: context.x.colors.gray,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SafeArea(
                    bottom: false,
                    child: Align(
                      alignment: .topCenter,
                      child: SizedBox(
                        height: kToolbarHeight,
                        child: Center(
                          child: Opacity(
                            opacity: layout.titleAlpha,
                            child: Padding(
                              padding: .symmetric(horizontal: collapsedTitleHorizontalPadding(layout.width)),
                              child: Text(
                                'Samandar Takhirov',
                                maxLines: 1,
                                overflow: .ellipsis,
                                textAlign: .center,
                                style: context.x.textStyle.w700s16.copyWith(
                                  fontSize: nameSizeCollapsed(layout.width),
                                  color: context.x.colors.primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
      body: RefreshIndicator.adaptive(
        onRefresh: onRefresh,
        child: ListView(
          padding: const .symmetric(vertical: 16),
          shrinkWrap: true,
          children: [
            ProfilePaymentCard(
              balance: '100 000 000 UZS',
              cardNumber: '1234567890',
              onCopyCardNumber: () => onCopyCardNumber('1234567890'),
            ),
            Padding(
              padding: menuSliverPadding(context),
              child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: const .symmetric(vertical: 16),
                itemCount: menuRows.length,
                itemBuilder: (context, index) {
                  final row = menuRows[index];
                  return switch (row.type) {
                    .header => Padding(
                      padding: .only(top: index == 0 ? 0 : 8, bottom: 8),
                      child: Text(
                        row.titleBuilder?.call(context) ?? '',
                        style: context.x.textStyle.w600s16.copyWith(color: context.x.colors.black),
                      ),
                    ),
                    .item => Padding(
                      padding: const .only(bottom: 6),
                      child: ActionListTile(
                        leading: row.titleBuilder?.call(context) ?? '',
                        onPressed: row.onTap ?? () {},
                        icon: row.leading,
                        iconColor: context.x.colors.black,
                        textColor: context.x.colors.black,
                      ),
                    ),
                    .spacer => SizedBox(height: row.spacerHeight),
                  };
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
