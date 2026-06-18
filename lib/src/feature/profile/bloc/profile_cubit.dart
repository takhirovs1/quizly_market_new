import 'package:equatable/equatable.dart';

import '../../../common/util/app_enum.dart';
import '../../../common/util/error_util.dart';
import '../../../common/util/sequential_cubit.dart';
import '../../../common/util/state_status.dart';
import '../../my_tests/models/test_model.dart';
import '../data/profile_repository.dart';
import '../model/profile_model.dart';
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

  void deleteArchiveTest(String testId) => emit(
    state.copyWith(
      archiveTests: state.archiveTests.where((t) => t.id != testId).toList(),
      archiveTotal: state.archiveTotal - 1,
    ),
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
}
