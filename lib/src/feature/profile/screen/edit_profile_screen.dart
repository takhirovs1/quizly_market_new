import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../../../common/util/state_status.dart';
import '../bloc/profile_cubit.dart';
import '../state/edit_profile_state.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends EditProfileState {
  @override
  Widget build(BuildContext context) {
    final colors = context.x.colors;
    final textStyle = context.x.textStyle;

    return BlocBuilder<ProfileCubit, ProfileState>(
      bloc: cubit,
      builder: (context, state) {
        final user = state.user;
        final displayNameStr = user?.name ?? user?.displayName ?? '';
        final firstLetter = displayNameStr.isNotEmpty ? displayNameStr[0].toUpperCase() : '';

        final fallbackAvatar = Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(color: colors.primary.withValues(alpha: 0.15), shape: BoxShape.circle),
          alignment: Alignment.center,
          child: Text(firstLetter, style: textStyle.sfW700s28.copyWith(color: colors.primary, fontSize: 36)),
        );

        final avatarUrl = user?.avatarUrl;
        Widget avatarWidget;
        if (state.status == StateStatus.loading && avatarUrl == null) {
          avatarWidget = const Center(child: CircularProgressIndicator.adaptive());
        } else if (avatarUrl != null && avatarUrl.isNotEmpty) {
          avatarWidget = Image.network(
            avatarUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(child: CircularProgressIndicator.adaptive());
            },
            errorBuilder: (context, error, stackTrace) {
              if (avatarUrl.toLowerCase().contains('.svg') || avatarUrl.toLowerCase().contains('userpic')) {
                return SvgPicture.network(
                  avatarUrl,
                  fit: BoxFit.cover,
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
          backgroundColor: colors.scaffoldBackground,
          appBar: QuizAppBar(
            title: context.x.l10n.updateProfile,
            telegramWebAppSafeAreaInsetTop: context.telegramWebApp.safeAreaInset.top.toDouble(),
          ),
          body: SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  children: [
                    // Profile avatar block
                    Center(
                      child: GestureDetector(
                        onTap: onPickAndUploadAvatar,
                        behavior: HitTestBehavior.opaque,
                        child: Stack(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: colors.primary, width: 2),
                              ),
                              child: ClipRRect(borderRadius: BorderRadius.circular(50), child: avatarWidget),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(color: colors.primary, shape: BoxShape.circle),
                                child: Icon(CupertinoIcons.camera_fill, color: colors.white, size: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Name editing field
                    AppTextField(title: context.x.l10n.fullName, controller: nameController),
                    const SizedBox(height: 24),

                    // Save Button
                    CustomButton(
                      title: context.x.l10n.save,
                      onTap: onSavePressed,
                      isLoading: state.status == StateStatus.loading,
                    ),
                  ],
                ),
              ),
            ),
          ),
          bottomNavigationBar: SafeArea(
            minimum: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: CupertinoButton(
                onPressed: onDeleteAccountPressed,
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(context.x.l10n.deleteAccount, style: textStyle.sfW600s16.copyWith(color: colors.error)),
              ),
            ),
          ),
        );
      },
    );
  }
}
