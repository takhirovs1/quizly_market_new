import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:ui/ui.dart';

import '../../../common/constant/constant.dart';
import '../../../common/extension/context_extension.dart';
import '../../../common/util/state_status.dart';
import '../cubit/session_cubit.dart';
import '../state/session_state.dart';

class SessionScreen extends StatefulWidget {
  const SessionScreen({super.key});

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends SessionState {
  @override
  Widget build(BuildContext context) => BlocConsumer<SessionCubit, SessionCubitState>(
    listener: (context, state) {
      if (state.status.isError) {
        context.x.showNotification(message: state.errorMessage ?? context.x.l10n.somethingWentWrong);
      }
      if (state.revokeStatus.isError) {
        context.x.showNotification(message: state.revokeErrorMessage ?? context.x.l10n.somethingWentWrong);
      }
    },
    builder: (context, state) {
      final isLoading = state.status == StateStatus.loading || state.revokeStatus == StateStatus.loading;

      return Scaffold(
        backgroundColor: context.x.colors.scaffoldBackground,
        body: Stack(
          children: [
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Back Button Row
                  Padding(
                    padding: const EdgeInsets.only(left: 16, top: 12),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: onBack,
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: context.x.colors.bannerBackground,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.arrow_back, color: context.x.colors.text, size: 20),
                        ),
                      ),
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          // Zoom Robot Image
                          Center(
                            child: Image.asset(
                              Assets.lib.images.zoomRobot.path,
                              package: Constant.packageUi,
                              width: 220,
                              height: 220,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Title
                          Text(
                            context.x.l10n.sessionLimitTitle,
                            style: context.x.textStyle.sfW700s18.copyWith(fontSize: 22, color: context.x.colors.text),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),

                          // Description
                          Text(
                            context.x.l10n.sessionLimitDescription,
                            style: context.x.textStyle.sfW400s14.copyWith(color: context.x.colors.gray),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),

                          // Sessions List
                          if (state.status == StateStatus.loading && state.sessions.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 40),
                              child: CircularProgressIndicator(),
                            )
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: state.sessions.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final session = state.sessions[index];
                                final isTelegram = session.deviceType.toLowerCase() == 'telegram';
                                final formattedDate = DateFormat(
                                  'd MMMM yyyy, HH:mm',
                                  Localizations.localeOf(context).languageCode,
                                ).format(session.createdAt);

                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: context.x.colors.bannerBackground,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    children: [
                                      // Left Icon (box container)
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.03),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        padding: const EdgeInsets.all(10),
                                        child: isTelegram
                                            ? Image.asset(
                                                Assets.lib.images.telegramLogo.path,
                                                package: Constant.packageUi,
                                                fit: BoxFit.contain,
                                              )
                                            : Assets.lib.icon.desktop.svg(
                                                package: Constant.packageUi,
                                                fit: BoxFit.contain,
                                              ),
                                      ),
                                      const SizedBox(width: 14),

                                      // Session Info text
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              session.deviceName,
                                              style: context.x.textStyle.sfW600s16.copyWith(
                                                color: context.x.colors.text,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${context.x.l10n.sessionAddedAt} $formattedDate',
                                              style: context.x.textStyle.sfW400s12.copyWith(
                                                color: context.x.colors.gray,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Action Revoke button
                                      IconButton(
                                        onPressed: () => onRevoke(session.id),
                                        icon: Assets.lib.icon.revoke.svg(
                                          package: Constant.packageUi,
                                          colorFilter: ColorFilter.mode(context.x.colors.gray, BlendMode.srcIn),
                                          width: 24,
                                          height: 24,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Loading blocker indicator
            if (isLoading)
              Container(
                color: Colors.black.withValues(alpha: 0.25),
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      );
    },
  );
}
