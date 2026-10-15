import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../bloc/friends_cubit.dart';
import '../models/friend_user_model.dart';
import '../screen/friends_screen.dart';
import '../widgets/add_friend_sheet.dart';

abstract class FriendsScreenState extends State<FriendsScreen> {
  late final FriendsCubit friendsCubit;

  @override
  void initState() {
    super.initState();
    friendsCubit = context.read<FriendsCubit>()..loadAll();
    context.setupTelegramBackButton();
  }

  @override
  void dispose() {
    context.teardownTelegramBackButton();
    super.dispose();
  }

  Future<void> onRefresh() async {
    context.telegramWebApp.hapticImpact(.light);
    await friendsCubit.loadAll();
  }

  void onRetrySection(String key) => friendsCubit.retrySection(key);

  /// Referral is how friends join by default — the invite banner shares the
  /// user's referral deep link (code passed in via the route).
  void onShareInvite() {
    context.telegramWebApp.hapticImpact(.light);
    context.shareReferral(widget.inviteCode);
  }

  void onAddFriend() {
    context.telegramWebApp.hapticImpact(.light);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.x.colors.bottomSheetBackground,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => AddFriendSheet(cubit: friendsCubit),
    );
  }

  void onAcceptRequest(String requestId) {
    context.telegramWebApp.hapticImpact(.light);
    friendsCubit.acceptRequest(requestId);
  }

  void onRejectRequest(String requestId) {
    context.telegramWebApp.hapticImpact(.light);
    friendsCubit.rejectRequest(requestId);
  }

  Future<void> onRemoveFriend(FriendUser user) async {
    context.telegramWebApp.hapticImpact(.medium);
    final confirmed = await _confirmRemove(user);
    if (confirmed == true) friendsCubit.removeFriend(user.id);
  }

  Future<bool?> _confirmRemove(FriendUser user) {
    final l10n = context.x.l10n;
    final colors = context.x.colors;
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: colors.bottomSheetBackground,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.friendsRemoveTitle, textAlign: TextAlign.center, style: context.x.textStyle.sfW600s16),
              const SizedBox(height: 8),
              Text(
                l10n.friendsRemoveConfirm(user.name),
                textAlign: TextAlign.center,
                style: context.x.textStyle.sfW400s14.copyWith(color: context.x.homeColors.text3),
              ),
              const SizedBox(height: 20),
              CustomButton(
                onTap: () => Navigator.pop(sheetContext, true),
                color: colors.error,
                textColor: colors.white,
                title: l10n.friendsRemove,
              ),
              const SizedBox(height: 10),
              CustomButton(
                onTap: () => Navigator.pop(sheetContext, false),
                color: colors.scaffoldBackground,
                textColor: colors.text,
                title: l10n.cancel,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
