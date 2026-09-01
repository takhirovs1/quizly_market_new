import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/util/error_util.dart';
import '../../../common/util/logger.dart';
import '../../../common/util/state_status.dart';
import '../data/upload_repository.dart';
import '../model/uploaded_test_model.dart';

part 'my_uploaded_tests_state.dart';

class MyUploadedTestsCubit extends Cubit<MyUploadedTestsCubitState> {
  MyUploadedTestsCubit({required this.uploadRepository}) : super(const MyUploadedTestsCubitState());

  final IUploadRepository uploadRepository;

  Future<void> fetchTests({String? status, bool refresh = false}) async {
    if (refresh) {
      emit(state.copyWith(status: StateStatus.loading, offset: 0, tests: []));
    } else {
      emit(state.copyWith(status: StateStatus.loading));
    }

    try {
      final tests = await uploadRepository.getMyUploadedTests(
        status: status ?? state.selectedStatus,
        limit: 50,
        offset: 0,
      );

      emit(
        state.copyWith(
          status: StateStatus.success,
          tests: tests,
          selectedStatus: status ?? state.selectedStatus,
          offset: tests.length,
          hasMore: tests.length >= 50,
        ),
      );
    } on Object catch (e, s) {
      info('FETCH MY UPLOADED TESTS ERROR: $e $s');
      emit(state.copyWith(status: StateStatus.error, errorMessage: ErrorUtil.toUserFriendlyMessage(e)));
    }
  }

  Future<void> filterByStatus(String? status) async {
    if (state.selectedStatus == status && state.status.isSuccess) return;
    await fetchTests(status: status, refresh: true);
  }

  Future<void> refresh() => fetchTests(status: state.selectedStatus, refresh: true);
}
