import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:octopus/octopus.dart';
import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../cubit/auth_cubit.dart';
import '../state/verify_otp_state.dart';

class VerifyOtpScreen extends StatefulWidget {
  const VerifyOtpScreen({super.key});

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends VerifyOtpState {
  @override
  Widget build(BuildContext context) => BlocConsumer<AuthCubit, AuthState>(
    listener: (context, state) {
      if (state.status.isSuccess) {
        context.octopus.navigate('home');
      }
      if (state.status.isError) {
        hasError.value = true;
      }
    },
    builder: (context, state) => Scaffold(
      backgroundColor: context.x.colors.white,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back Button
                  GestureDetector(
                    onTap: () => context.octopus.pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: context.x.colors.gray.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: context.x.colors.text),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Title
                  Text(
                    context.x.l10n.verificationCodeSent,
                    style: context.x.textStyle.sfW700s28.copyWith(fontSize: 24, color: context.x.colors.text),
                  ),
                  const SizedBox(height: 8),

                  // Description
                  Text(
                    context.x.l10n.verificationCodeSentDesc,
                    style: context.x.textStyle.sfW400s14.copyWith(color: context.x.colors.gray, height: 1.4),
                  ),
                  const SizedBox(height: 24),

                  // Hidden text field + Row of boxes
                  Stack(
                    children: [
                      Opacity(
                        opacity: 0,
                        child: SizedBox(
                          height: 56,
                          child: TextField(
                            controller: pinController,
                            focusNode: pinFocusNode,
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            onChanged: (val) {
                              if (hasError.value) hasError.value = false;
                              if (val.length == 6) {
                                verifyCode(val);
                              }
                            },
                            decoration: const InputDecoration(counterText: '', border: InputBorder.none),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => pinFocusNode.requestFocus(),
                        child: ListenableBuilder(
                          listenable: .merge([pinController, pinFocusNode, hasError]),
                          builder: (context, _) {
                            final text = pinController.text;
                            final hasFocus = pinFocusNode.hasFocus;
                            final isError = hasError.value;

                            return LayoutBuilder(
                              builder: (context, constraints) {
                                final boxWidth = (constraints.maxWidth - 40) / 6;

                                return Row(
                                  mainAxisAlignment: .spaceBetween,
                                  children: .generate(6, (index) {
                                    final isCharTyped = index < text.length;
                                    final isCurrentFocused = hasFocus && index == text.length;

                                    Color boxColor;
                                    Border? border;

                                    if (isError) {
                                      boxColor = context.x.colors.error.withValues(alpha: 0.1);
                                      border = Border.all(color: context.x.colors.error, width: 1.5);
                                    } else if (isCharTyped || isCurrentFocused) {
                                      boxColor = context.x.colors.primary.withValues(alpha: 0.1);
                                      border = Border.all(color: context.x.colors.primary, width: 1.5);
                                    } else {
                                      boxColor = context.x.colors.gray.withValues(alpha: 0.1);
                                    }

                                    return Container(
                                      width: boxWidth,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        color: boxColor,
                                        border: border,
                                        borderRadius: .circular(12),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        isCharTyped ? text[index] : '',
                                        style: context.x.textStyle.sfW600s16.copyWith(
                                          fontSize: 18,
                                          color: isError ? context.x.colors.error : context.x.colors.primary,
                                        ),
                                      ),
                                    );
                                  }),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Error Message or Timer
                  ValueListenableBuilder<bool>(
                    valueListenable: hasError,
                    builder: (context, isError, _) {
                      if (isError) {
                        return Row(
                          children: [
                            Icon(Icons.error_rounded, color: context.x.colors.error, size: 16),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                context.x.l10n.invalidVerificationCode,
                                style: context.x.textStyle.sfW400s12.copyWith(color: context.x.colors.error),
                              ),
                            ),
                          ],
                        );
                      }
                      return ValueListenableBuilder<int>(
                        valueListenable: secondsRemaining,
                        builder: (context, seconds, _) => Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              context.x.l10n.resendCodeIn,
                              style: context.x.textStyle.sfW400s14.copyWith(color: context.x.colors.text),
                            ),
                            Text(
                              '00:${seconds.toString().padLeft(2, '0')}',
                              style: context.x.textStyle.sfW500s14.copyWith(color: context.x.colors.primary),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const Spacer(),

                  // Bottom Button
                  ValueListenableBuilder<bool>(
                    valueListenable: hasError,
                    builder: (context, isError, _) => ListenableBuilder(
                      listenable: .merge([pinController, isVerifying]),
                      builder: (context, _) {
                        final isBtnEnabled =
                            pinController.text.length == 6 && !state.status.isLoading && !isVerifying.value;

                        return SizedBox(
                          width: double.infinity,
                          child: CustomButton(
                            title: isError ? context.x.l10n.resend : context.x.l10n.continueText,
                            onTap: isError ? resendCode : (isBtnEnabled ? () => verifyCode(pinController.text) : null),
                            isLoading: state.status.isLoading || isVerifying.value,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
