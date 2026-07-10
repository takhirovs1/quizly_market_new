import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:octopus/octopus.dart';
import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../../../common/router/pages.dart';
import '../bloc/profile_cubit.dart';
import '../screen/edit_profile_screen.dart';

abstract class EditProfileState extends State<EditProfileScreen> {
  late final ProfileCubit cubit;
  late final TextEditingController nameController;

  @override
  void initState() {
    cubit = context.read<ProfileCubit>()..loadProfile();
    final user = cubit.state.user;
    nameController = TextEditingController(text: user?.name ?? user?.displayName ?? '');
    super.initState();
    context.setupTelegramBackButton();
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  Future<void> onPickAndUploadAvatar() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      final isTelegram = context.telegramWebApp.isSupported;
      if (isTelegram) {
        context.telegramWebApp.hapticImpact(.light);
      } else {
        await HapticFeedback.lightImpact();
      }

      await cubit.uploadAvatar(image.path);

      if (!mounted) return;
      final safeAreaTop = isTelegram
          ? context.telegramWebApp.safeAreaInset.top.toDouble() + 56
          : MediaQuery.paddingOf(context).top + 56;

      context.x.showNotification(message: 'Muvaffaqiyatli yuklandi', top: safeAreaTop);
    } catch (e) {
      if (!mounted) return;
      final safeAreaTop = context.telegramWebApp.isSupported
          ? context.telegramWebApp.safeAreaInset.top.toDouble() + 56
          : MediaQuery.paddingOf(context).top + 56;

      context.x.showNotification(message: 'Xatolik: ${e.toString()}', top: safeAreaTop);
    }
  }

  Future<void> onSavePressed() async {
    final name = nameController.text.trim();
    if (name.isEmpty) return;
    try {
      final isTelegram = context.telegramWebApp.isSupported;
      if (isTelegram) {
        context.telegramWebApp.hapticImpact(.light);
      } else {
        await HapticFeedback.lightImpact();
      }

      await cubit.updateName(name);

      if (!mounted) return;
      final safeAreaTop = isTelegram
          ? context.telegramWebApp.safeAreaInset.top.toDouble() + 56
          : MediaQuery.paddingOf(context).top + 56;

      context.x.showNotification(message: 'Muvaffaqiyatli saqlandi', top: safeAreaTop);
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      final safeAreaTop = context.telegramWebApp.isSupported
          ? context.telegramWebApp.safeAreaInset.top.toDouble() + 56
          : MediaQuery.paddingOf(context).top + 56;

      context.x.showNotification(message: 'Xatolik: ${e.toString()}', top: safeAreaTop);
    }
  }

  void onDeleteAccountPressed() {
    if (context.telegramWebApp.isSupported) {
      context.telegramWebApp.hapticImpact(.light);
    } else {
      HapticFeedback.lightImpact();
    }
    final screenContext = context;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: dialogContext.x.colors.transparent,
        child: Center(
          child: LogoutDialog(
            title: dialogContext.x.l10n.deleteAccount,
            description: dialogContext.x.l10n.deleteAccountConfirm,
            cancelButtonText: dialogContext.x.l10n.cancel,
            successButtonText: dialogContext.x.l10n.delete,
            onCancelButtonPressed: () => dialogContext.bottomSheetPop(),
            onSuccessButtonPressed: () async {
              dialogContext.bottomSheetPop();
              try {
                await cubit.deleteAccount();
                await screenContext.x.dependencies.authenticationController.signOut();
                if (!screenContext.mounted) return;
                if (screenContext.telegramWebApp.isSupported) {
                  screenContext.telegramWebApp.close();
                } else {
                  screenContext.octopus.push(Routes.login);
                }
              } catch (e) {
                if (!screenContext.mounted) return;
                final safeAreaTop = screenContext.telegramWebApp.isSupported
                    ? screenContext.telegramWebApp.safeAreaInset.top.toDouble() + 56
                    : MediaQuery.paddingOf(screenContext).top + 56;

                screenContext.x.showNotification(message: 'Xatolik: ${e.toString()}', top: safeAreaTop);
              }
            },
          ),
        ),
      ),
    );
  }
}
