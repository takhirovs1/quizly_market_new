import 'dart:async';
import 'dart:io' as io;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:octopus/octopus.dart';
import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../../../common/router/pages.dart';
import '../bloc/profile_cubit.dart';
import '../model/profile_model.dart';
import '../screen/edit_profile_screen.dart';

abstract class EditProfileState extends State<EditProfileScreen> {
  late final ProfileCubit cubit;
  late final TextEditingController firstNameController;
  late final TextEditingController lastNameController;
  late final TextEditingController usernameController;
  late final TextEditingController genderController;
  late final StreamSubscription<ProfileState> _subscription;
  String? gender;
  bool isSaving = false;

  @override
  void initState() {
    cubit = context.read<ProfileCubit>()..loadProfile();
    firstNameController = TextEditingController();
    lastNameController = TextEditingController();
    usernameController = TextEditingController();
    genderController = TextEditingController();

    final initialUser = cubit.state.user;
    if (initialUser != null) {
      _populateFields(initialUser);
    }

    _subscription = cubit.stream.listen((state) {
      if (state.user != null) {
        _populateFields(state.user!);
      }
    });

    super.initState();
    context.setupTelegramBackButton();
  }

  void _populateFields(ProfileModelResponse user) {
    if (firstNameController.text.isEmpty) {
      if (user.firstName != null && user.firstName!.isNotEmpty) {
        firstNameController.text = user.firstName!;
      } else if (user.name != null && user.name!.isNotEmpty) {
        final parts = user.name!.trim().split(' ');
        if (parts.isNotEmpty) {
          firstNameController.text = parts.first;
        }
      }
    }
    if (lastNameController.text.isEmpty) {
      if (user.lastName != null && user.lastName!.isNotEmpty) {
        lastNameController.text = user.lastName!;
      } else if (user.name != null && user.name!.isNotEmpty) {
        final parts = user.name!.trim().split(' ');
        if (parts.length > 1) {
          lastNameController.text = parts.sublist(1).join(' ');
        }
      }
    }
    if (usernameController.text.isEmpty && user.username != null) {
      usernameController.text = user.username!;
    }
    if (gender == null && user.gender != null) {
      gender = user.gender;
      _updateGenderText();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateGenderText();
  }

  void _updateGenderText() {
    if (!mounted) return;
    genderController.text = gender == 'male'
        ? context.x.l10n.male
        : gender == 'female'
        ? context.x.l10n.female
        : context.x.l10n.genderNotSpecified;
  }

  @override
  void dispose() {
    _subscription.cancel();
    firstNameController.dispose();
    lastNameController.dispose();
    usernameController.dispose();
    genderController.dispose();
    super.dispose();
  }

  Future<void> onPickAndUploadAvatar() async {
    final isTelegram = context.telegramWebApp.isSupported;
    if (isTelegram) {
      final textColor = context.x.colors.text;
      await showModalBottomSheet<void>(
        backgroundColor: context.x.colors.transparent,
        context: context,
        isScrollControlled: true,
        builder: (sheetContext) => CustomBottomSheet(
          maxHeightFactor: .6,
          isScrollable: false,
          title: Row(
            children: [
              Expanded(
                child: Text(
                  context.x.l10n.updateProfile,
                  style: context.x.textStyle.sfW700s18.copyWith(color: textColor),
                ),
              ),
              IconButton(
                onPressed: () => sheetContext.bottomSheetPop(),
                icon: Icon(Icons.close_rounded, color: textColor),
              ),
            ],
          ),
          children: [
            SelectionPillButton(
              label: context.x.l10n.camera,
              isSelected: false,
              onTap: () {
                sheetContext.bottomSheetPop();
                _pickAndUpload(ImageSource.camera);
              },
            ),
            const SizedBox(height: 8),
            SelectionPillButton(
              label: context.x.l10n.file,
              isSelected: false,
              onTap: () {
                sheetContext.bottomSheetPop();
                _pickAndUploadFile();
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      );
    } else {
      _pickAndUpload(ImageSource.gallery);
    }
  }

  Future<void> _pickAndUpload(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: source);
      if (image == null) return;

      final isTelegram = context.telegramWebApp.isSupported;
      if (isTelegram) {
        context.telegramWebApp.hapticImpact(.light);
      } else {
        await HapticFeedback.lightImpact();
      }

      final bytes = await image.readAsBytes();
      await cubit.uploadAvatar(bytes, image.name);

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

  Future<void> _pickAndUploadFile() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'webp', 'heic'],
      );
      if (result == null || result.files.single.name.isEmpty) return;

      final file = result.files.single;
      final bytes = file.bytes ?? (file.path != null ? await io.File(file.path!).readAsBytes() : null);
      if (bytes == null) return;

      final isTelegram = context.telegramWebApp.isSupported;
      if (isTelegram) {
        context.telegramWebApp.hapticImpact(.light);
      } else {
        await HapticFeedback.lightImpact();
      }

      await cubit.uploadAvatar(bytes, file.name);

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

  Future<void> onGenderPressed() async {
    final textColor = context.x.colors.text;
    final options = <({String label, String? value})>[
      (label: context.x.l10n.male, value: 'male'),
      (label: context.x.l10n.female, value: 'female'),
    ];

    if (context.telegramWebApp.isSupported) {
      context.telegramWebApp.hapticImpact(.light);
    } else {
      await HapticFeedback.lightImpact();
    }

    if (!mounted) return;
    await showModalBottomSheet<void>(
      backgroundColor: context.x.colors.transparent,
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => CustomBottomSheet(
        maxHeightFactor: .6,
        isScrollable: false,
        title: Row(
          children: [
            Expanded(
              child: Text(context.x.l10n.gender, style: context.x.textStyle.sfW700s18.copyWith(color: textColor)),
            ),
            IconButton(
              onPressed: () => sheetContext.bottomSheetPop(),
              icon: Icon(Icons.close_rounded, color: textColor),
            ),
          ],
        ),
        children: [
          for (final option in options) ...[
            SelectionPillButton(
              label: option.label,
              isSelected: gender == option.value,
              onTap: () {
                setState(() {
                  gender = option.value;
                  _updateGenderText();
                });
                sheetContext.bottomSheetPop();
              },
            ),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Future<void> onSavePressed() async {
    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();
    if (firstName.isEmpty) return;
    try {
      setState(() => isSaving = true);
      final isTelegram = context.telegramWebApp.isSupported;
      if (isTelegram) {
        context.telegramWebApp.hapticImpact(.light);
      } else {
        await HapticFeedback.lightImpact();
      }

      await cubit.updateProfile(firstName: firstName, lastName: lastName, gender: gender);

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
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
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
