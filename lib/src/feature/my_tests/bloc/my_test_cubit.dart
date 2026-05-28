import 'package:equatable/equatable.dart';

import '../../../common/util/sequential_cubit.dart';
import '../../../common/util/state_status.dart';
import '../data/my_test_repository.dart';
import '../models/test_mode.dart';

part 'my_test_state.dart';

class MyTestCubit extends SequentialCubit<MyTestState> {
  MyTestCubit({required this.myTestRepository}) : super(const MyTestState());

  final IMyTestRepository myTestRepository;

  Future<void> getMyTests({TestModelRequest? request}) => handle<void>((emit) async {
    emit(state.copyWith(status: .loading));
    final myTests = await myTestRepository.getMyTests(request ?? TestModelRequest());
    emit(state.copyWith(status: .success, myTests: myTests));
  }, errorHandler: (emit, error, stackTrace) => emit(state.copyWith(status: .error, errorMessage: error.toString())));

  Future<void> getTopTests({bool loadMore = false}) => handle<void>(
    (emit) async {
      if (loadMore) {
        if (state.topTests.length >= state.topTestsTotal || state.isTopTestsLoadingMore) return;
        emit(state.copyWith(isTopTestsLoadingMore: true));
        final nextOffset = state.topTestsOffset + state.topTestsLimit;
        final result = await myTestRepository.getTopTests(
          TestModelRequest(limit: state.topTestsLimit, offset: nextOffset),
        );
        emit(
          state.copyWith(
            isTopTestsLoadingMore: false,
            topTests: [...state.topTests, ...result.items],
            topTestsOffset: result.offset,
            topTestsLimit: result.limit,
            topTestsTotal: result.total,
          ),
        );
      } else {
        emit(state.copyWith(status: .loading));
        final result = await myTestRepository.getTopTests(TestModelRequest(limit: 20, offset: 0));
        emit(
          state.copyWith(
            status: .success,
            topTests: result.items,
            topTestsOffset: result.offset,
            topTestsLimit: result.limit,
            topTestsTotal: result.total,
          ),
        );
      }
    },
    errorHandler: (emit, error, stackTrace) {
      emit(state.copyWith(status: .error, isTopTestsLoadingMore: false, errorMessage: error.toString()));
    },
  );
}
