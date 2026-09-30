import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/util/error_util.dart';
import '../../../common/util/logger.dart';
import '../../../common/util/state_status.dart';
import '../data/upload_repository.dart';
import '../model/manual_test_create_model.dart';

part 'create_test_state.dart';

class CreateTestCubit extends Cubit<CreateTestState> {
  CreateTestCubit({required this.uploadRepository}) : super(const CreateTestState());

  final IUploadRepository uploadRepository;

  Future<void> submitManualTest(ManualTestCreateRequest request) async {
    emit(state.copyWith(status: StateStatus.loading));
    try {
      final response = await uploadRepository.createManualTest(request);
      emit(state.copyWith(status: StateStatus.success, createdTest: response));
    } on Object catch (e, s) {
      info('CREATE MANUAL TEST CUBIT ERROR: $e $s');
      emit(state.copyWith(status: StateStatus.error, errorMessage: ErrorUtil.toUserFriendlyMessage(e)));
    }
  }
}
