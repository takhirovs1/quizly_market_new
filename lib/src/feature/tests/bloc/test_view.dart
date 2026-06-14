import 'package:equatable/equatable.dart';

import '../../../common/util/error_util.dart';
import '../../../common/util/logger.dart' as log_util;
import '../../../common/util/sequential_cubit.dart';
import '../../../common/util/state_status.dart';
import '../../my_tests/models/demo_test_model.dart';
import '../data/test_view_repository.dart';
import '../model/test_attempt_model.dart';
import '../model/test_request_response_models.dart';

part 'test_view_state.dart';

class TestView extends SequentialCubit<TestViewState> {
  TestView({required this.testViewRepository}) : super(const TestViewState());

  final ITestViewRepository testViewRepository;

  Future<void> getAttempts(String testId, {bool loadMore = false}) => handle<void>(
    (emit) async {
      if (loadMore) {
        if (state.attempts.length >= state.total) return;
        final nextOffset = state.offset + state.limit;
        final result = await testViewRepository.getAttempts(
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
        final result = await testViewRepository.getAttempts(testId, const TestAttemptRequest(limit: 20, offset: 0));
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
      emit(state.copyWith(status: StateStatus.error, errorMessage: ErrorUtil.toUserFriendlyMessage(error)));
    },
  );

  Future<void> getTestDetail(String testId, TestDetailRequest request) => handle<void>(
    (emit) async {
      emit(state.copyWith(status: StateStatus.loading));
      final response = await testViewRepository.getTestDetail(testId, request);
      emit(state.copyWith(status: StateStatus.success, detail: response.data));
    },
    errorHandler: (emit, error, stackTrace) {
      emit(state.copyWith(status: StateStatus.error, errorMessage: ErrorUtil.toUserFriendlyMessage(error)));
    },
  );

  Future<void> getTestQuestions(String testId, TestDetailRequest request) => handle<void>(
    (emit) async {
      emit(state.copyWith(status: StateStatus.loading));
      final newQuestions = await testViewRepository.getTestQuestions(testId, request);
      final currentDetail = state.detail;
      if (currentDetail != null) {
        emit(
          state.copyWith(
            status: StateStatus.success,
            detail: currentDetail.copyWith(questions: newQuestions),
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: StateStatus.success,
            detail: DemoTestDetail(id: testId, questions: newQuestions),
          ),
        );
      }
    },
    errorHandler: (emit, error, stackTrace) {
      emit(state.copyWith(status: StateStatus.error, errorMessage: ErrorUtil.toUserFriendlyMessage(error)));
    },
  );

  Future<void> loadNextQuestionsChunk(String testId, TestDetailRequest request) => handle<void>(
    (emit) async {
      final newQuestions = await testViewRepository.getTestQuestions(testId, request);
      final currentDetail = state.detail;
      if (currentDetail != null) {
        final updatedQuestions = [...?currentDetail.questions, ...newQuestions];
        emit(state.copyWith(detail: currentDetail.copyWith(questions: updatedQuestions)));
      }
    },
    errorHandler: (emit, error, stackTrace) {
      log_util.info('LOAD NEXT QUESTIONS CHUNK ERROR: $error $stackTrace');
    },
  );

  Future<void> toggleLike(String testId) => handle<void>(
    (emit) async {
      final detail = state.detail;
      if (detail == null || detail.id != testId) return;

      final currentIsLiked = detail.isLiked ?? false;
      final updatedDetail = detail.copyWith(isLiked: !currentIsLiked);
      emit(state.copyWith(detail: updatedDetail));

      if (currentIsLiked) {
        await testViewRepository.unlikeTest(testId);
      } else {
        await testViewRepository.likeTest(testId);
      }
    },
    errorHandler: (emit, error, stackTrace) {
      final detail = state.detail;
      if (detail != null && detail.id == testId) {
        final currentIsLiked = detail.isLiked ?? false;
        final revertedDetail = detail.copyWith(isLiked: !currentIsLiked);
        emit(state.copyWith(detail: revertedDetail));
      }
    },
  );

  Future<void> toggleArchive(String testId) => handle<void>(
    (emit) async {
      final detail = state.detail;
      if (detail == null || detail.id != testId) return;

      final currentIsArchived = detail.isArchived ?? false;
      final updatedDetail = detail.copyWith(isArchived: !currentIsArchived);
      emit(state.copyWith(detail: updatedDetail));

      if (currentIsArchived) {
        await testViewRepository.unarchiveTest(testId);
      } else {
        await testViewRepository.archiveTest(testId);
      }
    },
    errorHandler: (emit, error, stackTrace) {
      final detail = state.detail;
      if (detail != null && detail.id == testId) {
        final currentIsArchived = detail.isArchived ?? false;
        final revertedDetail = detail.copyWith(isArchived: !currentIsArchived);
        emit(state.copyWith(detail: revertedDetail));
      }
    },
  );

  Future<StartAttemptResponse> startAttempt(String testId, StartAttemptRequest request) => handle<StartAttemptResponse>(
    (emit) async {
      final response = await testViewRepository.startAttempt(testId, request);
      return response;
    },
    errorHandler: (emit, error, stackTrace) {
      emit(state.copyWith(status: StateStatus.error, errorMessage: ErrorUtil.toUserFriendlyMessage(error)));
    },
  ).then((value) => value ?? const StartAttemptResponse(attemptId: ''));

  Future<FinishAttemptResponse> finishAttempt(String testId, String attemptId, FinishAttemptRequest request) =>
      handle<FinishAttemptResponse>(
        (emit) async {
          final response = await testViewRepository.finishAttempt(testId, attemptId, request);
          return response;
        },
        errorHandler: (emit, error, stackTrace) {
          emit(state.copyWith(status: StateStatus.error, errorMessage: ErrorUtil.toUserFriendlyMessage(error)));
        },
      ).then((value) => value ?? const FinishAttemptResponse());
}
