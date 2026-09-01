import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/service/api_client.dart';
import '../../../common/util/error_util.dart';
import '../../../common/util/logger.dart';
import '../../../common/util/state_status.dart';
import '../data/upload_repository.dart';
import '../model/publish_models.dart';

part 'upload_confirm_cubit_state.dart';

class UploadConfirmCubit extends Cubit<UploadConfirmCubitState> {
  UploadConfirmCubit({required this.uploadRepository}) : super(const UploadConfirmCubitState());

  final IUploadRepository uploadRepository;
  Timer? _pollingTimer;

  @override
  Future<void> close() {
    _pollingTimer?.cancel();
    return super.close();
  }

  /// Fetches publish quote for the draft test (`GET /api/tests/:id/publish-quote`).
  Future<void> fetchQuote(String testId) async {
    emit(state.copyWith(quoteStatus: StateStatus.loading));
    try {
      final quote = await uploadRepository.getPublishQuote(testId);
      emit(state.copyWith(quoteStatus: StateStatus.success, quote: quote));
    } on Object catch (e, s) {
      info('FETCH PUBLISH QUOTE ERROR: $e $s');
      emit(state.copyWith(quoteStatus: StateStatus.error, errorMessage: ErrorUtil.toUserFriendlyMessage(e)));
    }
  }

  /// Publishes draft test from user wallet (`POST /api/payments/tests/:id/publish`).
  Future<void> publishFromWallet(String testId) async {
    emit(state.copyWith(publishStatus: StateStatus.loading, isInsufficientBalance: false));
    try {
      final response = await uploadRepository.publishFromWallet(testId);
      emit(state.copyWith(publishStatus: StateStatus.success, walletResult: response));
    } on ApiResponseException catch (e, s) {
      info('PUBLISH WALLET API EXCEPTION: $e $s');
      final is402 = e.statusCode == 402;
      emit(
        state.copyWith(
          publishStatus: StateStatus.error,
          isInsufficientBalance: is402,
          errorMessage: is402 ? null : ErrorUtil.toUserFriendlyMessage(e),
        ),
      );
    } on Object catch (e, s) {
      info('PUBLISH WALLET UNKNOWN ERROR: $e $s');
      emit(state.copyWith(publishStatus: StateStatus.error, errorMessage: ErrorUtil.toUserFriendlyMessage(e)));
    }
  }

  /// Initiates payment checkout (`POST /api/payments/tests/:id/publish/checkout`).
  Future<String?> publishViaCheckout(String testId, {required String provider, String? redirectUrl}) async {
    emit(state.copyWith(publishStatus: StateStatus.loading));
    try {
      final checkout = await uploadRepository.publishCheckout(testId, provider: provider, redirectUrl: redirectUrl);

      emit(state.copyWith(publishStatus: StateStatus.success, checkoutResult: checkout));

      return checkout.url;
    } on Object catch (e, s) {
      info('PUBLISH CHECKOUT ERROR: $e $s');
      emit(state.copyWith(publishStatus: StateStatus.error, errorMessage: ErrorUtil.toUserFriendlyMessage(e)));
      return null;
    }
  }

  /// Polls payment status until completed.
  void startPaymentPolling(String paymentId, {VoidCallback? onCompleted, VoidCallback? onFailed}) {
    _pollingTimer?.cancel();
    var attempts = 0;
    const maxAttempts = 30; // 30 * 2s = 60s

    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      attempts++;
      if (attempts > maxAttempts) {
        timer.cancel();
        return;
      }

      try {
        final status = await uploadRepository.getPaymentStatus(paymentId);
        if (status.isCompleted) {
          timer.cancel();
          emit(state.copyWith(publishStatus: StateStatus.success));
          onCompleted?.call();
        } else if (status.isFailed) {
          timer.cancel();
          emit(
            state.copyWith(
              publishStatus: StateStatus.error,
              isPaymentFailed: true,
            ),
          );
          onFailed?.call();
        }
      } on Object catch (_) {}
    });
  }
}
