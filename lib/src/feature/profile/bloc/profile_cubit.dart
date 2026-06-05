import 'package:equatable/equatable.dart';

import '../../../common/util/sequential_cubit.dart';
import '../../../common/util/state_status.dart';
import '../data/profile_repository.dart';
import '../model/profile_model.dart';

part 'profile_state.dart';

class ProfileCubit extends SequentialCubit<ProfileState> {
  ProfileCubit({required this.profileRepository}) : super(const ProfileState());

  final IProfileRepository profileRepository;

  Future<void> loadProfile() => handle<void>((emit) async {
    emit(state.copyWith(status: .loading));
    final user = await profileRepository.getProfile();
    emit(state.copyWith(status: .success, user: user));
  }, errorHandler: (emit, error, stackTrace) => emit(state.copyWith(status: .error, errorMessage: error.toString())));

  Future<void> updateLanguage(String language) => handle<void>((emit) async {
    await profileRepository.updateLanguage(language);
  });
}
