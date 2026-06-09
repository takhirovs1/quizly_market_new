import 'package:equatable/equatable.dart';
import 'package:local_source/local_source.dart';

import '../../../common/util/error_util.dart';
import '../../../common/util/sequential_cubit.dart';
import '../../../common/util/state_status.dart';
import '../data/main_repository.dart';
import '../model/login_with_telegram.dart';

part 'main_state.dart';

class MainCubit extends SequentialCubit<MainState> {
  MainCubit({required this.mainRepository, required this.localSource}) : super(const MainState());

  final IMainRepository mainRepository;
  final LocalSource localSource;

  Future<void> signInWithTelegram(LoginWithTelegramRequest request) => handle<void>(
    (emit) async {
      emit(state.copyWith(status: .loading));
      final response = await mainRepository.signInWithTelegram(request);
      await localSource.setAccessToken(response.accessToken);
      await localSource.setRefreshToken(response.refreshToken);
      emit(state.copyWith(status: .success, loginWithTelegramResponse: response));
    },
    errorHandler: (emit, error, stackTrace) =>
        emit(state.copyWith(status: .error, errorMessage: ErrorUtil.toUserFriendlyMessage(error))),
  );

  Future<void> getMe() => handle<void>((emit) async {
    emit(state.copyWith(status: .loading));
    await mainRepository.getMe();
    emit(state.copyWith(status: .success));
  });
}
