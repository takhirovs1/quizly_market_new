import 'package:equatable/equatable.dart';

import '../../../common/util/error_util.dart';
import '../../../common/util/sequential_cubit.dart';
import '../../../common/util/state_status.dart';
import '../data/test_attempt_repository.dart';
import '../model/test_attempt_model.dart';

part 'test_attempt_state.dart';

class TestAttemptCubit extends SequentialCubit<TestAttemptState> {
  TestAttemptCubit({required this.testAttemptRepository}) : super(const TestAttemptState());

  final ITestAttemptRepository testAttemptRepository;

  Future<void> getAttempts(String testId, {bool loadMore = false}) => handle<void>(
        (emit) async {
          if (loadMore) {
            if (state.attempts.length >= state.total) return;
            final nextOffset = state.offset + state.limit;
            final result = await testAttemptRepository.getAttempts(
              testId,
              TestAttemptRequest(limit: state.limit, offset: nextOffset),
            );
            emit(
              state.copyWith(
                attempts: [...state.attempts, ...result.items],
                offset: result.offset,
                limit: result.limit,
                total: result.total,
              ),
            );
          } else {
            emit(state.copyWith(status: StateStatus.loading));
            final result = await testAttemptRepository.getAttempts(
              testId,
              const TestAttemptRequest(limit: 20, offset: 0),
            );
            emit(
              state.copyWith(
                status: StateStatus.success,
                attempts: result.items,
                offset: result.offset,
                limit: result.limit,
                total: result.total,
              ),
            );
          }
        },
        errorHandler: (emit, error, stackTrace) {
          emit(
            state.copyWith(
              status: StateStatus.error,
              errorMessage: ErrorUtil.toUserFriendlyMessage(error),
            ),
          );
        },
      );
}
