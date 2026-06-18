import 'package:equatable/equatable.dart';

import '../../../common/util/error_util.dart';
import '../../../common/util/sequential_cubit.dart';
import '../../../common/util/state_status.dart';
import '../../my_tests/models/test_model.dart';
import '../../tests/data/test_view_repository.dart';
import '../data/profile_repository.dart';

class ArchiveCubitState extends Equatable {
  const ArchiveCubitState({
    this.status = StateStatus.idle,
    this.tests = const [],
    this.limit = 20,
    this.offset = 0,
    this.total = 0,
    this.errorMessage,
  });

  final StateStatus status;
  final List<TestModel> tests;
  final int limit;
  final int offset;
  final int total;
  final String? errorMessage;

  bool get isLoadingMore => status == .loadingMore;
  bool get hasMore => tests.length < total;

  ArchiveCubitState copyWith({
    StateStatus? status,
    List<TestModel>? tests,
    int? limit,
    int? offset,
    int? total,
    String? errorMessage,
  }) => ArchiveCubitState(
    status: status ?? this.status,
    tests: tests ?? this.tests,
    limit: limit ?? this.limit,
    offset: offset ?? this.offset,
    total: total ?? this.total,
    errorMessage: errorMessage ?? this.errorMessage,
  );

  @override
  List<Object?> get props => [status, tests, limit, offset, total, errorMessage];
}

class ArchiveCubit extends SequentialCubit<ArchiveCubitState> {
  ArchiveCubit({required this.profileRepository, required this.testViewRepository}) : super(const ArchiveCubitState());

  final IProfileRepository profileRepository;
  final ITestViewRepository testViewRepository;

  Future<void> loadTests() => handle<void>(
    (emit) async {
      emit(state.copyWith(status: .loading));
      final result = await profileRepository.getArchivedTests(ArchiveTestRequest());
      emit(
        state.copyWith(
          status: .success,
          tests: result.items,
          limit: result.limit,
          offset: result.offset,
          total: result.total,
        ),
      );
    },
    errorHandler: (emit, error, stackTrace) {
      emit(state.copyWith(status: .error, errorMessage: ErrorUtil.toUserFriendlyMessage(error)));
    },
  );

  Future<void> loadMore() => handle<void>(
    (emit) async {
      if (!state.hasMore || state.isLoadingMore) return;
      emit(state.copyWith(status: .loadingMore));
      final nextOffset = state.offset + state.limit;
      final result = await profileRepository.getArchivedTests(
        ArchiveTestRequest(limit: state.limit, offset: nextOffset),
      );
      emit(
        state.copyWith(
          status: .success,
          tests: [...state.tests, ...result.items],
          limit: result.limit,
          offset: result.offset,
          total: result.total,
        ),
      );
    },
    errorHandler: (emit, error, stackTrace) {
      emit(state.copyWith(status: .error, errorMessage: ErrorUtil.toUserFriendlyMessage(error)));
    },
  );

  Future<void> unarchiveTest(String testId) => handle<void>(
    (emit) async {
      await testViewRepository.unarchiveTest(testId);
      emit(state.copyWith(tests: state.tests.where((t) => t.id != testId).toList(), total: state.total - 1));
    },
    errorHandler: (emit, error, stackTrace) {
      emit(state.copyWith(status: .error, errorMessage: ErrorUtil.toUserFriendlyMessage(error)));
    },
  );

  Future<void> deleteTest(String testId) => handle<void>((emit) {
    emit(state.copyWith(tests: state.tests.where((t) => t.id != testId).toList(), total: state.total - 1));
  });
}
