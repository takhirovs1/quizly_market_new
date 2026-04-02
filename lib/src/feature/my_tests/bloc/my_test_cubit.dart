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
    await myTestRepository.getMyTests(request ?? TestModelRequest());
    emit(state.copyWith(status: .success));
  }, errorHandler: (emit, error, stackTrace) => emit(state.copyWith(status: .error, errorMessage: error.toString())));
}
