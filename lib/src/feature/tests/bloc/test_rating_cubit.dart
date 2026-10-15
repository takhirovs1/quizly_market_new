import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/util/logger.dart';
import '../../../common/util/state_status.dart';
import '../../my_tests/data/home_repository.dart';
import '../model/test_rating_model.dart';

/// State for the per-test rating screen (Figma "C · Test rating").
class TestRatingState extends Equatable {
  const TestRatingState({this.status = StateStatus.idle, this.data, this.error});

  final StateStatus status;
  final TestRatingResponse? data;
  final String? error;

  TestRatingState copyWith({StateStatus? status, TestRatingResponse? data, String? error}) =>
      TestRatingState(status: status ?? this.status, data: data ?? this.data, error: error);

  @override
  List<Object?> get props => [status, data, error];
}

class TestRatingCubit extends Cubit<TestRatingState> {
  TestRatingCubit({required this.repository}) : super(const TestRatingState());

  final IHomeRepository repository;

  Future<void> load(String testId) async {
    emit(state.copyWith(status: StateStatus.loading, error: null));
    try {
      final data = await repository.getTestRating(testId);
      emit(state.copyWith(status: StateStatus.success, data: data));
    } on Object catch (e, s) {
      info('TEST RATING LOAD ERROR: $e $s');
      emit(state.copyWith(status: StateStatus.error, error: e.toString()));
    }
  }
}
