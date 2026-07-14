import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../../../common/extension/number_extension.dart';
import '../../../common/util/state_status.dart';
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
    child: BlocConsumer<ProfileCubit, ProfileState>(
      listenWhen: (prev, curr) =>
          curr.linkErrorCount != prev.linkErrorCount ||
          (curr.status == StateStatus.error && prev.status != StateStatus.error),
      listener: (context, state) {
        if (state.status == StateStatus.error && state.errorMessage != null) {
          context.x.showNotification(
            message: state.errorMessage!,
            isError: true,
            top: switch (context.telegramWebApp.isSupported) {
              true => context.telegramWebApp.safeAreaInset.top.toDouble() + 56,
              false => MediaQuery.paddingOf(context).top + 56,
            },
          );
        } else {
          context.x.showNotification(
            message: context.x.l10n.accountAlreadyLinked,
            isError: true,
            top: switch (context.telegramWebApp.isSupported) {
              true => context.telegramWebApp.safeAreaInset.top.toDouble() + 56,
              false => MediaQuery.paddingOf(context).top + 56,
            },
          );
        }
      },
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

        final isMobile = context.x.isMobile || context.x.isTablet;

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
                                              : Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    if (user?.telegramChatId != null) ...[
                                                      Text(
                                                        'Telegram ID: ${user.telegramChatId}',
                                                        style: context.x.textStyle.sfW400s14.copyWith(
                                                          fontSize: phoneSize(layout.width),
                                                          color: context.x.colors.gray,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 2),
                                                    ],
                                                    if (user.username != null && user.username!.isNotEmpty) ...[
                                                      Text(
                                                        '@${user.username}',
                                                        style: context.x.textStyle.sfW400s14.copyWith(
                                                          fontSize: phoneSize(layout.width),
                                                          color: context.x.colors.gray,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 2),
                                                    ],
                                                    if (user?.email != null && user.email!.isNotEmpty)
                                                      Text(
                                                        user.email!,
                                                        style: context.x.textStyle.sfW400s14.copyWith(
                                                          fontSize: phoneSize(layout.width),
                                                          color: context.x.colors.gray,
                                                        ),
                                                      ),
                                                  ],
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
                                      padding: EdgeInsets.symmetric(
                                        horizontal: collapsedTitleHorizontalPadding(layout.width),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          SizedBox(height: context.telegramWebApp.safeAreaInset.top.toDouble() + 10),
                                          if (isShimmer)
                                            const ProfileShimmer(child: ShimmerBox(width: 100, height: 16, radius: 4))
                                          else
                                            Text(
                                              displayNameStr,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: Alignment.center == Alignment.center
                                                  ? TextAlign.center
                                                  : TextAlign.left,
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
                  padding: EdgeInsets.only(top: 16, bottom: context.x.isMobile ? 16 : 24),
                  shrinkWrap: true,
                  children: [
                    ProfilePaymentCard(
                      balance: user?.balance?.formatUzs ?? '0 UZS',
                      cardNumber: user?.paymentCode ?? '',
                      onCopyCardNumber: () => onCopyCardNumber(user?.paymentCode ?? ''),
                      isLoading: isShimmer,
                    ),
                    Padding(
                      padding: menuSliverPadding(context),
                      child: ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        padding: const .symmetric(vertical: 16),
                        itemCount: menuRowsFor(state.user).length,
                        itemBuilder: (context, index) {
                          final row = menuRowsFor(state.user)[index];
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
                                isComingSoon: row.isComingSoon,
                                isConnected: row.isConnected,
                                isLogout: row.isLogout,
                                canTapWhenConnected: row.canTapWhenConnected,
                                comingSoonText: row.comingSoonText?.call(context) ?? '',
                                connectedText: row.connectedText?.call(context) ?? '',
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
                            DecoratedBox(
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
                                      false => Column(
                                        mainAxisSize: .min,
                                        children: [
                                          if (user?.telegramChatId != null) ...[
                                            Row(
                                              mainAxisAlignment: .center,
                                              children: [
                                                Text(
                                                  'ID: ${user!.telegramChatId}',
                                                  style: context.x.textStyle.sfW400s14.copyWith(
                                                    color: context.x.colors.gray,
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                if (user?.username != null && user.username!.isNotEmpty) ...[
                                                  Text(
                                                    '@${user.username}',
                                                    style: context.x.textStyle.sfW400s14.copyWith(
                                                      color: context.x.colors.gray,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                ],
                                              ],
                                            ),
                                          ],
                                          if (user?.email != null && user!.email!.isNotEmpty)
                                            Text(
                                              user.email!,
                                              style: context.x.textStyle.sfW400s14.copyWith(
                                                color: context.x.colors.gray,
                                              ),
                                            ),
                                        ],
                                      ),
                                    },
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            ProfilePaymentCard(
                              balance: user?.balance?.formatUzs ?? '0 UZS',
                              cardNumber: user?.paymentCode ?? '',
                              onCopyCardNumber: () => onCopyCardNumber(user?.paymentCode ?? ''),
                              isLoading: isShimmer,
                              padding: EdgeInsets.zero,
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
                                itemCount: menuRowsFor(state.user).length,
                                itemBuilder: (context, index) {
                                  final row = menuRowsFor(state.user)[index];
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
                                        isComingSoon: row.isComingSoon,
                                        isConnected: row.isConnected,
                                        isLogout: row.isLogout,
                                        canTapWhenConnected: row.canTapWhenConnected,
                                        comingSoonText: row.comingSoonText?.call(context) ?? '',
                                        connectedText: row.connectedText?.call(context) ?? '',
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
