import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/auth_cubit.dart';
import '../screen/verify_otp_screen.dart';

abstract class VerifyOtpState extends State<VerifyOtpScreen> {
  late final AuthCubit authCubit;
  late final TextEditingController pinController;
  late final FocusNode pinFocusNode;

  Timer? _timer;
  final secondsRemaining = ValueNotifier<int>(59);
  final hasError = ValueNotifier<bool>(false);
  final isVerifying = ValueNotifier<bool>(false);

  void startTimer() {
    _timer?.cancel();
    secondsRemaining.value = 59;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsRemaining.value == 0) {
        timer.cancel();
      } else {
        secondsRemaining.value--;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    authCubit = context.read<AuthCubit>();
    pinController = TextEditingController();
    pinFocusNode = FocusNode();
    startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    pinController.dispose();
    pinFocusNode.dispose();
    secondsRemaining.dispose();
    hasError.dispose();
    isVerifying.dispose();
    super.dispose();
  }

  Future<void> verifyCode(String code) async {
    if (isVerifying.value) return;
    isVerifying.value = true;
    hasError.value = false;
    try {
      await authCubit.verifyTelegramOtp(code);
    } finally {
      if (mounted) {
        isVerifying.value = false;
      }
    }
  }

  Future<void> resendCode() async {
    pinController.clear();
    hasError.value = false;
    await authCubit.signInWithTelegram();
    startTimer();
  }
}
