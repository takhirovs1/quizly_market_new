import 'package:equatable/equatable.dart';

import '../../../common/util/sequential_cubit.dart';
import '../../../common/util/state_status.dart';
import '../data/main_repository.dart';
import '../model/login_with_telegram.dart';

part 'main_state.dart';

class MainCubit extends SequentialCubit<MainState> {
  MainCubit({required this.mainRepository}) : super(const MainState());

  final IMainRepository mainRepository;

  Future<void> signInWithTelegram(LoginWithTelegramRequest request) => handle<void>((emit) async {
    emit(state.copyWith(status: .loading));
    final response = await mainRepository.signInWithTelegram(request);
    emit(state.copyWith(status: .success, loginWithTelegramResponse: response));
  }, errorHandler: (emit, error, stackTrace) => emit(state.copyWith(status: .error, errorMessage: error.toString())));

  Future<void> getMe() => handle<void>((emit) async {
    emit(state.copyWith(status: .loading));
    final me = await mainRepository.getMe();
    emit(state.copyWith(status: .success));
  });
}
