import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

import '../../../common/service/auth_service.dart';
import '../../../common/util/app_enum.dart';
import '../../../common/util/error_util.dart';
import '../../../common/util/sequential_cubit.dart';
import '../../../common/util/state_status.dart';
import '../../my_tests/models/test_model.dart';
import '../data/profile_repository.dart';
import '../model/profile_model.dart';
import '../model/referral_model.dart';
import '../model/referral_summary_model.dart';
import '../model/topup_model.dart';
import '../model/transaction_model.dart';

part 'profile_state.dart';

class ProfileCubit extends SequentialCubit<ProfileState> {
  ProfileCubit({required this.profileRepository}) : super(const ProfileState());

  final IProfileRepository profileRepository;

  Future<void> loadProfile() => handle<void>(
    (emit) async {
      emit(state.copyWith(status: .loading));
      final user = await profileRepository.getProfile();
      emit(state.copyWith(status: .success, user: user));
    },
    errorHandler: (emit, error, stackTrace) =>
        emit(state.copyWith(status: .error, errorMessage: ErrorUtil.toUserFriendlyMessage(error))),
  );

  Future<void> updateLanguage(String language) => handle<void>((emit) async {
    await profileRepository.updateLanguage(language);
  });

  Future<TopUpResponse?> topUp(int amount, PaymentProvider provider) => handle<TopUpResponse>(
    (emit) async {
      emit(state.copyWith(status: .loading));
      final request = TopUpRequest(amount: amount, provider: provider);
      final response = await profileRepository.topUp(request);
      emit(state.copyWith(status: .success));
      return response;
    },
    errorHandler: (emit, error, stackTrace) {
      emit(state.copyWith(status: .error, errorMessage: ErrorUtil.toUserFriendlyMessage(error)));
    },
  );

  Future<void> linkGoogle() => handle<void>(
    (emit) async {
      final response = await AuthService.signInWithGoogle();
      if (response == null) return;
      await profileRepository.linkGoogle(response.idToken);
      emit(state.copyWith(status: StateStatus.loading));
      final user = await profileRepository.getProfile();
      emit(state.copyWith(status: StateStatus.success, user: user));
    },
    errorHandler: (emit, error, stackTrace) {
      if (error is DioException && error.response?.statusCode == 409) {
        emit(state.copyWith(linkErrorCount: state.linkErrorCount + 1));
      } else {
        emit(state.copyWith(status: StateStatus.error, errorMessage: ErrorUtil.toUserFriendlyMessage(error)));
      }
    },
  );

  Future<void> linkApple() => handle<void>(
    (emit) async {
      final response = await AuthService.signInWithApple();
      if (response == null) return;
      await profileRepository.linkApple(response.idToken);
      emit(state.copyWith(status: StateStatus.loading));
      final user = await profileRepository.getProfile();
      emit(state.copyWith(status: StateStatus.success, user: user));
    },
    errorHandler: (emit, error, stackTrace) {
      if (error is DioException && error.response?.statusCode == 409) {
        emit(state.copyWith(linkErrorCount: state.linkErrorCount + 1));
      } else {
        emit(state.copyWith(status: StateStatus.error, errorMessage: ErrorUtil.toUserFriendlyMessage(error)));
      }
    },
  );

  Future<void> unlinkProvider(String provider) => handle<void>(
    (emit) async {
      await profileRepository.unlinkProvider(provider);
      emit(state.copyWith(status: StateStatus.loading));
      final user = await profileRepository.getProfile();
      emit(state.copyWith(status: StateStatus.success, user: user));
    },
    errorHandler: (emit, error, stackTrace) {
      emit(state.copyWith(status: StateStatus.error, errorMessage: ErrorUtil.toUserFriendlyMessage(error)));
    },
  );

  Future<void> loadArchiveTests() => handle<void>(
    (emit) async {
      emit(state.copyWith(archiveStatus: .loading));
      final result = await profileRepository.getArchivedTests();
      emit(
        state.copyWith(
          archiveStatus: .success,
          archiveTests: result.items,
          archiveLimit: result.limit,
          archiveOffset: result.offset,
          archiveTotal: result.total,
        ),
      );
    },
    errorHandler: (emit, error, stackTrace) {
      emit(state.copyWith(archiveStatus: .error, archiveErrorMessage: ErrorUtil.toUserFriendlyMessage(error)));
    },
  );

  Future<void> loadMoreArchiveTests() => handle<void>(
    (emit) async {
      if (!state.archiveHasMore || state.isArchiveLoadingMore) return;
      emit(state.copyWith(archiveStatus: .loadingMore));
      final nextOffset = state.archiveOffset + state.archiveLimit;
      final result = await profileRepository.getArchivedTests(limit: state.archiveLimit, offset: nextOffset);
      emit(
        state.copyWith(
          archiveStatus: .success,
          archiveTests: [...state.archiveTests, ...result.items],
          archiveLimit: result.limit,
          archiveOffset: result.offset,
          archiveTotal: result.total,
        ),
      );
    },
    errorHandler: (emit, error, stackTrace) {
      emit(state.copyWith(archiveStatus: .error, archiveErrorMessage: ErrorUtil.toUserFriendlyMessage(error)));
    },
  );

  Future<void> unarchiveTest(String testId) => handle<void>(
    (emit) async {
      await profileRepository.unarchiveTest(testId);
      emit(
        state.copyWith(
          archiveTests: state.archiveTests.where((t) => t.id != testId).toList(),
          archiveTotal: state.archiveTotal - 1,
        ),
      );
    },
    errorHandler: (emit, error, stackTrace) {
      emit(state.copyWith(archiveStatus: .error, archiveErrorMessage: ErrorUtil.toUserFriendlyMessage(error)));
    },
  );

  Future<void> deleteArchiveTest(String testId) => handle<void>(
    (emit) async {
      await profileRepository.deleteArchiveTest(testId);
      emit(
        state.copyWith(
          archiveTests: state.archiveTests.where((t) => t.id != testId).toList(),
          archiveTotal: state.archiveTotal - 1,
        ),
      );
    },
    errorHandler: (emit, error, stackTrace) {
      emit(state.copyWith(archiveStatus: .error, archiveErrorMessage: ErrorUtil.toUserFriendlyMessage(error)));
    },
  );

  Future<void> getTransactions({bool loadMore = false}) => handle<void>(
    (emit) async {
      if (loadMore) {
        if (state.transactions.length >= state.transactionsTotal) return;
        if (state.status == StateStatus.loadingMore) return;
        emit(state.copyWith(status: StateStatus.loadingMore));
        final nextOffset = state.transactionsOffset + state.transactionsLimit;
        final result = await profileRepository.getTransactions(
          TransactionRequest(limit: state.transactionsLimit, offset: nextOffset),
        );
        emit(
          state.copyWith(
            status: StateStatus.success,
            transactions: [...state.transactions, ...result.items],
            transactionsOffset: result.offset,
            transactionsLimit: result.limit,
            transactionsTotal: result.total,
          ),
        );
      } else {
        emit(state.copyWith(status: StateStatus.loading));
        final result = await profileRepository.getTransactions(const TransactionRequest(limit: 20, offset: 0));
        emit(
          state.copyWith(
            status: StateStatus.success,
            transactions: result.items,
            transactionsOffset: result.offset,
            transactionsLimit: result.limit,
            transactionsTotal: result.total,
          ),
        );
      }
    },
    errorHandler: (emit, error, stackTrace) {
      emit(state.copyWith(status: StateStatus.error, errorMessage: ErrorUtil.toUserFriendlyMessage(error)));
    },
  );

  Future<void> getReferralSummary() => handle<void>(
    (emit) async {
      emit(state.copyWith(referralStatus: .loading));
      final referralSummary = await profileRepository.getReferralSummary();
      emit(state.copyWith(referralStatus: .success, referralSummary: referralSummary));
    },
    errorHandler: (emit, error, stackTrace) {
      emit(state.copyWith(referralStatus: .error, referralErrorMessage: ErrorUtil.toUserFriendlyMessage(error)));
    },
  );

  Future<void> getReferrals() => handle<void>(
    (emit) async {
      emit(state.copyWith(referralListStatus: StateStatus.loading));
      final result = await profileRepository.getReferrals(limit: 20, offset: 0);
      emit(
        state.copyWith(
          referralListStatus: StateStatus.success,
          referralItems: result.items,
          referralLimit: result.limit,
          referralOffset: result.offset,
          referralTotal: result.total,
        ),
      );
    },
    errorHandler: (emit, error, stackTrace) {
      emit(state.copyWith(referralListStatus: StateStatus.error));
    },
  );

  Future<void> loadMoreReferrals() => handle<void>(
    (emit) async {
      if (!state.referralHasMore || state.isReferralListLoadingMore) return;
      emit(state.copyWith(referralListStatus: StateStatus.loadingMore));
      final nextOffset = state.referralOffset + state.referralLimit;
      final result = await profileRepository.getReferrals(limit: state.referralLimit, offset: nextOffset);
      emit(
        state.copyWith(
          referralListStatus: StateStatus.success,
          referralItems: [...state.referralItems, ...result.items],
          referralLimit: result.limit,
          referralOffset: result.offset,
          referralTotal: result.total,
        ),
      );
    },
    errorHandler: (emit, error, stackTrace) {
      emit(state.copyWith(referralListStatus: StateStatus.error));
    },
  );

  Future<void> updateName(String name) => handle<void>(
    (emit) async {
      emit(state.copyWith(status: .loading));
      await profileRepository.updateName(name);
      final user = await profileRepository.getProfile();
      emit(state.copyWith(status: StateStatus.success, user: user));
    },
    errorHandler: (emit, error, stackTrace) =>
        emit(state.copyWith(status: StateStatus.error, errorMessage: ErrorUtil.toUserFriendlyMessage(error))),
  );

  Future<void> uploadAvatar(List<int> bytes, String fileName) => handle<void>(
    (emit) async {
      emit(state.copyWith(status: StateStatus.loading));
      final user = await profileRepository.uploadAvatar(bytes, fileName);
      emit(state.copyWith(status: StateStatus.success, user: user));
    },
    errorHandler: (emit, error, stackTrace) =>
        emit(state.copyWith(status: StateStatus.error, errorMessage: ErrorUtil.toUserFriendlyMessage(error))),
  );

  Future<void> deleteAccount() => handle<void>(
    (emit) async {
      emit(state.copyWith(status: StateStatus.loading));
      await profileRepository.deleteAccount();
      emit(state.copyWith(status: StateStatus.success));
    },
    errorHandler: (emit, error, stackTrace) =>
        emit(state.copyWith(status: StateStatus.error, errorMessage: ErrorUtil.toUserFriendlyMessage(error))),
  );

  Future<void> updateProfile({required String firstName, required String lastName, required String? gender}) =>
      handle<void>(
        (emit) async {
          emit(state.copyWith(status: StateStatus.loading));
          await profileRepository.updateProfile(firstName: firstName, lastName: lastName, gender: gender);
          final user = await profileRepository.getProfile();
          emit(state.copyWith(status: StateStatus.success, user: user));
        },
        errorHandler: (emit, error, stackTrace) =>
            emit(state.copyWith(status: StateStatus.error, errorMessage: ErrorUtil.toUserFriendlyMessage(error))),
      );
}
