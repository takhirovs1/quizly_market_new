part of 'profile_cubit.dart';

class ProfileState extends Equatable {
  const ProfileState({this.status = .idle, this.errorMessage, this.user});

  final StateStatus status;
  final String? errorMessage;
  final ProfileModelResponse? user;

  ProfileState copyWith({StateStatus? status, String? errorMessage, ProfileModelResponse? user}) => ProfileState(
    status: status ?? this.status,
    errorMessage: errorMessage ?? this.errorMessage,
    user: user ?? this.user,
  );

  @override
  List<Object?> get props => [status, errorMessage, user];
}
