import 'package:equatable/equatable.dart';

import '../../../common/util/sequential_cubit.dart';
import '../../../common/util/state_status.dart';
import '../data/my_test_repository.dart';
import '../models/test_mode.dart';

part 'my_test_state.dart';

class MyTestCubit extends SequentialCubit<MyTestState> {
  MyTestCubit({required this.myTestRepository}) : super(const MyTestState());

  final IMyTestRepository myTestRepository;

  Future<void> initialize({String? search, int limit = 5}) => handle<void>(
    (emit) async {
      emit(state.copyWith(status: .loading, search: search ?? ''));
      final results = await Future.wait([
        myTestRepository.getMyTests(TestModelRequest(limit: limit, offset: 0, search: search)),
        myTestRepository.getTopTests(TestModelRequest(limit: limit, offset: 0, search: search)),
      ]);
      final myResult = results[0];
      final topResult = results[1];
      emit(
        state.copyWith(
          status: .success,
          myTests: myResult.items,
          myTestsOffset: myResult.offset,
          myTestsLimit: myResult.limit,
          myTestsTotal: myResult.total,
          topTests: topResult.items,
          topTestsOffset: topResult.offset,
          topTestsLimit: topResult.limit,
          topTestsTotal: topResult.total,
        ),
      );
    },
    errorHandler: (emit, error, stackTrace) {
      emit(state.copyWith(status: .error, errorMessage: error.toString()));
    },
  );

  Future<void> getMyTests({bool loadMore = false, String? search}) => handle<void>(
    (emit) async {
      final currentSearch = search ?? state.search;
      if (loadMore) {
        if (state.myTests.length >= state.myTestsTotal || state.isMyTestsLoadingMore) return;
        emit(state.copyWith(isMyTestsLoadingMore: true));
        final nextOffset = state.myTestsOffset + state.myTestsLimit;
        final result = await myTestRepository.getMyTests(
          TestModelRequest(
            limit: state.myTestsLimit,
            offset: nextOffset,
            search: currentSearch.isEmpty ? null : currentSearch,
          ),
        );
        emit(
          state.copyWith(
            isMyTestsLoadingMore: false,
            myTests: [...state.myTests, ...result.items],
            myTestsOffset: result.offset,
            myTestsLimit: result.limit,
            myTestsTotal: result.total,
          ),
        );
      } else {
        emit(state.copyWith(status: .loading, search: currentSearch));
        final result = await myTestRepository.getMyTests(
          TestModelRequest(limit: 20, offset: 0, search: currentSearch.isEmpty ? null : currentSearch),
        );
        emit(
          state.copyWith(
            status: .success,
            myTests: result.items,
            myTestsOffset: result.offset,
            myTestsLimit: result.limit,
            myTestsTotal: result.total,
          ),
        );
      }
    },
    errorHandler: (emit, error, stackTrace) {
      emit(state.copyWith(status: .error, isMyTestsLoadingMore: false, errorMessage: error.toString()));
    },
  );

  Future<void> getTopTests({bool loadMore = false, String? search}) => handle<void>(
    (emit) async {
      final currentSearch = search ?? state.search;
      if (loadMore) {
        if (state.topTests.length >= state.topTestsTotal || state.isTopTestsLoadingMore) return;
        emit(state.copyWith(isTopTestsLoadingMore: true));
        final nextOffset = state.topTestsOffset + state.topTestsLimit;
        final result = await myTestRepository.getTopTests(
          TestModelRequest(
            limit: state.topTestsLimit,
            offset: nextOffset,
            search: currentSearch.isEmpty ? null : currentSearch,
          ),
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
        emit(state.copyWith(status: .loading, search: currentSearch));
        final result = await myTestRepository.getTopTests(
          TestModelRequest(limit: 20, offset: 0, search: currentSearch.isEmpty ? null : currentSearch),
        );
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
