import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../../../common/extension/number_extension.dart';
import '../bloc/profile_cubit.dart';
import '../state/profile_screen_state.dart';
import '../widget/profile_payment_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ProfileScreenState {
  @override
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
    value: SystemUiOverlayStyle(
      statusBarColor: context.x.colors.scaffoldBackground,
      statusBarIconBrightness: Theme.of(context).brightness == .dark ? Brightness.light : Brightness.dark,
      statusBarBrightness: Theme.of(context).brightness,
    ),
    child: BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        final user = state.user;
        final isShimmer = user == null;

        if (isShimmer && state.status.isError) {
          return Scaffold(
            backgroundColor: context.x.colors.scaffoldBackground,
            body: Center(
              child: Padding(
                padding: const .all(24),
                child: Column(
                  mainAxisAlignment: .center,
                  children: [
                    Text(
                      context.x.l10n.failedToLoadProfile,
                      textAlign: .center,
                      style: context.x.textStyle.sfW500s16.copyWith(color: context.x.colors.error),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.read<ProfileCubit>().loadProfile(),
                      child: Text(context.x.l10n.retry),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final isMobile = context.x.isMobile;

        if (isMobile) {
          return Scaffold(
            backgroundColor: context.x.colors.scaffoldBackground,
            body: NestedScrollView(
              headerSliverBuilder: (context, innerBoxScrolled) => [
                SliverAppBar(
                  backgroundColor: context.x.colors.scaffoldBackground,
                  surfaceTintColor: context.x.colors.transparent,
                  expandedHeight: expandedHeaderHeight(context),
                  toolbarHeight: context.telegramWebApp.isSupported
                      ? context.telegramWebApp.safeAreaInset.top + 56
                      : 56,
                  floating: false,
                  pinned: true,
                  centerTitle: true,
                  flexibleSpace: LayoutBuilder(
                    builder: (context, constraints) {
                      final layout = headerLayout(context, constraints);

                      final displayNameStr = user != null ? formatProfileName(user.displayName) : '';
                      final idStr = user != null ? 'ID: ${user.telegramChatId ?? user.id ?? ""}' : '';
                      final usernameStr = user != null && user.username != null && user.username!.isNotEmpty
                          ? ' User: @${user.username}'
                          : '';
                      final subtitleStr = '$idStr$usernameStr';

                      final firstLetter = displayNameStr.isNotEmpty ? displayNameStr[0].toUpperCase() : '';
                      final fallbackAvatar = Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: context.x.colors.primary.withValues(alpha: 0.15),
                          shape: .circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          firstLetter,
                          style: context.x.textStyle.sfW700s28.copyWith(color: context.x.colors.primary, fontSize: 36),
                        ),
                      );

                      final avatarUrl = user?.avatarUrl;
                      Widget avatarWidget;
                      if (isShimmer) {
                        avatarWidget = const ProfileShimmer(child: ShimmerBox(width: 100, height: 100, radius: 50));
                      } else if (avatarUrl != null && avatarUrl.isNotEmpty) {
                        avatarWidget = Image.network(
                          avatarUrl,
                          fit: .cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(child: CircularProgressIndicator.adaptive());
                          },
                          errorBuilder: (context, error, stackTrace) {
                            if (avatarUrl.toLowerCase().contains('.svg') ||
                                avatarUrl.toLowerCase().contains('userpic')) {
                              return SvgPicture.network(
                                avatarUrl,
                                fit: .cover,
                                placeholderBuilder: (context) => fallbackAvatar,
                                errorBuilder: (context, error, stackTrace) => fallbackAvatar,
                              );
                            }
                            return fallbackAvatar;
                          },
                        );
                      } else {
                        avatarWidget = fallbackAvatar;
                      }

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
                                    alignment: Alignment.bottomCenter,
                                    child: Column(
                                      mainAxisSize: .min,
                                      children: [
                                        SizedBox(
                                          height: context.telegramWebApp.isSupported
                                              ? context.telegramWebApp.safeAreaInset.top.toDouble()
                                              : 0,
                                        ),
                                        ClipRRect(
                                          borderRadius: .circular(layout.avatar / 2),
                                          child: SizedBox(width: 100, height: 100, child: avatarWidget),
                                        ),
                                        SizedBox(height: headerNameSpacing(layout.expandedHeight)),
                                        Padding(
                                          padding: .symmetric(horizontal: nameHorizontalPadding(layout.width)),
                                          child: isShimmer
                                              ? const ProfileShimmer(
                                                  child: ShimmerBox(width: 180, height: 28, radius: 4),
                                                )
                                              : Text(
                                                  displayNameStr,
                                                  maxLines: 1,
                                                  overflow: .ellipsis,
                                                  textAlign: .center,
                                                  style: context.x.textStyle.sfW700s28.copyWith(
                                                    fontSize: nameSizeExpanded(layout.width),
                                                    color: context.x.colors.primary,
                                                  ),
                                                ),
                                        ),
                                        const SizedBox(height: 4),
                                        Padding(
                                          padding: .symmetric(horizontal: phoneHorizontalPadding(layout.width)),
                                          child: isShimmer
                                              ? const ProfileShimmer(
                                                  child: ShimmerBox(width: 120, height: 16, radius: 4),
                                                )
                                              : Text(
                                                  subtitleStr,
                                                  maxLines: 1,
                                                  overflow: .ellipsis,
                                                  textAlign: .center,
                                                  style: context.x.textStyle.sfW400s14.copyWith(
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
                              alignment: Alignment.topCenter,
                              child: SizedBox(
                                height: kToolbarHeight,
                                child: Center(
                                  child: Opacity(
                                    opacity: layout.titleAlpha,
                                    child: Padding(
                                      padding: .symmetric(horizontal: collapsedTitleHorizontalPadding(layout.width)),
                                      child: Column(
                                        crossAxisAlignment: .center,
                                        mainAxisAlignment: .center,
                                        children: [
                                          SizedBox(height: context.telegramWebApp.safeAreaInset.top.toDouble() + 10),
                                          if (isShimmer)
                                            const ProfileShimmer(child: ShimmerBox(width: 100, height: 16, radius: 4))
                                          else
                                            Text(
                                              displayNameStr,
                                              maxLines: 1,
                                              overflow: .ellipsis,
                                              textAlign: .center,
                                              style: context.x.textStyle.sfW700s16.copyWith(
                                                fontSize: nameSizeCollapsed(layout.width),
                                                color: context.x.colors.primary,
                                              ),
                                            ),
                                        ],
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
                  padding: .only(top: 16, bottom: context.x.isMobile ? 16 : 24),
                  shrinkWrap: true,
                  children: [
                    ProfilePaymentCard(
                      balance: user?.balance?.formatUzs ?? '0 UZS',
                      cardNumber: '${user?.telegramChatId ?? user?.id ?? ""}',
                      onCopyCardNumber: () => onCopyCardNumber('${user?.telegramChatId ?? user?.id ?? ""}'),
                      isLoading: isShimmer,
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
                                style: context.x.textStyle.sfW600s16.copyWith(color: context.x.colors.text),
                              ),
                            ),
                            .item => Padding(
                              padding: const .only(bottom: 6),
                              child: ActionListTile(
                                leading: row.titleBuilder?.call(context) ?? '',
                                onPressed: row.onTap ?? () {},
                                icon: row.leading,
                                iconColor: context.x.colors.text,
                                textColor: context.x.colors.text,
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
        } else {
          // Desktop Version Layout
          final displayNameStr = user != null ? formatProfileName(user.displayName) : '';
          final idStr = user != null ? 'ID: ${user.telegramChatId ?? user.id ?? ""}' : '';
          final usernameStr = user != null && user.username != null && user.username!.isNotEmpty
              ? ' User: @${user.username}'
              : '';
          final subtitleStr = '$idStr$usernameStr';

          final firstLetter = displayNameStr.isNotEmpty ? displayNameStr[0].toUpperCase() : '';
          final fallbackAvatar = Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(color: context.x.colors.primary.withValues(alpha: 0.15), shape: .circle),
            alignment: Alignment.center,
            child: Text(
              firstLetter,
              style: context.x.textStyle.sfW700s28.copyWith(color: context.x.colors.primary, fontSize: 36),
            ),
          );

          final avatarUrl = user?.avatarUrl;
          Widget avatarWidget;
          if (isShimmer) {
            avatarWidget = const ProfileShimmer(child: ShimmerBox(width: 100, height: 100, radius: 50));
          } else if (avatarUrl != null && avatarUrl.isNotEmpty) {
            avatarWidget = Image.network(
              avatarUrl,
              fit: .cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(child: CircularProgressIndicator.adaptive());
              },
              errorBuilder: (context, error, stackTrace) {
                if (avatarUrl.toLowerCase().contains('.svg') || avatarUrl.toLowerCase().contains('userpic')) {
                  return SvgPicture.network(
                    avatarUrl,
                    fit: .cover,
                    placeholderBuilder: (context) => fallbackAvatar,
                    errorBuilder: (context, error, stackTrace) => fallbackAvatar,
                  );
                }
                return fallbackAvatar;
              },
            );
          } else {
            avatarWidget = fallbackAvatar;
          }

          return Scaffold(
            backgroundColor: context.x.colors.scaffoldBackground,
            appBar: QuizAppBar(
              title: context.x.l10n.profile,
              telegramWebAppSafeAreaInsetTop: context.telegramWebApp.safeAreaInset.top.toDouble(),
            ),
            body: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Row(
                  crossAxisAlignment: .start,
                  children: [
                    // Left column: Info card & balance card (Fixed/Static)
                    Expanded(
                      flex: 4,
                      child: Padding(
                        padding: const .only(left: 16, right: 16, top: 24),
                        child: Column(
                          crossAxisAlignment: .stretch,
                          children: [
                            Padding(
                              padding: const .symmetric(horizontal: 16),
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: context.x.colors.cardBackground2,
                                  borderRadius: .circular(20),
                                  border: Border.all(color: context.x.colors.divider),
                                ),
                                child: Padding(
                                  padding: const .all(24),
                                  child: Column(
                                    children: [
                                      ClipRRect(
                                        borderRadius: .circular(50),
                                        child: SizedBox(width: 100, height: 100, child: avatarWidget),
                                      ),
                                      const SizedBox(height: 16),
                                      switch (isShimmer) {
                                        true => const ProfileShimmer(
                                          child: ShimmerBox(width: 180, height: 28, radius: 4),
                                        ),
                                        false => Text(
                                          displayNameStr,
                                          maxLines: 1,
                                          overflow: .ellipsis,
                                          textAlign: .center,
                                          style: context.x.textStyle.sfW700s28.copyWith(
                                            fontSize: 24,
                                            color: context.x.colors.text,
                                          ),
                                        ),
                                      },
                                      const SizedBox(height: 6),
                                      switch (isShimmer) {
                                        true => const ProfileShimmer(
                                          child: ShimmerBox(width: 120, height: 16, radius: 4),
                                        ),
                                        false => Text(
                                          subtitleStr,
                                          maxLines: 1,
                                          overflow: .ellipsis,
                                          textAlign: .center,
                                          style: context.x.textStyle.sfW400s14.copyWith(color: context.x.colors.gray),
                                        ),
                                      },
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            ProfilePaymentCard(
                              balance: user?.balance?.formatUzs ?? '0 UZS',
                              cardNumber: '${user?.telegramChatId ?? user?.id ?? ""}',
                              onCopyCardNumber: () => onCopyCardNumber('${user?.telegramChatId ?? user?.id ?? ""}'),
                              isLoading: isShimmer,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    // Right column: Settings options (Independently Scrollable)
                    Expanded(
                      flex: 6,
                      child: RefreshIndicator.adaptive(
                        onRefresh: onRefresh,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const .only(left: 16, right: 16, top: 24, bottom: 120),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: context.x.colors.cardBackground2,
                              borderRadius: .circular(20),
                              border: Border.all(color: context.x.colors.divider),
                            ),
                            child: Padding(
                              padding: const .symmetric(horizontal: 20, vertical: 16),
                              child: ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                padding: EdgeInsets.zero,
                                itemCount: menuRows.length,
                                itemBuilder: (context, index) {
                                  final row = menuRows[index];
                                  return switch (row.type) {
                                    .header => Padding(
                                      padding: .only(top: index == 0 ? 0 : 16, bottom: 8),
                                      child: Text(
                                        row.titleBuilder?.call(context) ?? '',
                                        style: context.x.textStyle.sfW600s16.copyWith(color: context.x.colors.text),
                                      ),
                                    ),
                                    .item => Padding(
                                      padding: const .only(bottom: 6),
                                      child: ActionListTile(
                                        leading: row.titleBuilder?.call(context) ?? '',
                                        onPressed: row.onTap ?? () {},
                                        icon: row.leading,
                                        iconColor: context.x.colors.text,
                                        textColor: context.x.colors.text,
                                      ),
                                    ),
                                    .spacer => SizedBox(height: row.spacerHeight),
                                  };
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
    ),
  );
}

class ProfileShimmer extends StatelessWidget {
  const ProfileShimmer({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == .dark;
    return Shimmer.fromColors(
      baseColor: isDark ? const Color(0x20FFFFFF) : const Color(0xFFE2E8F0),
      highlightColor: isDark ? const Color(0x40FFFFFF) : const Color(0xFFF1F5F9),
      child: child,
    );
  }
}
