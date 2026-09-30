import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:local_source/local_source.dart';
import 'package:octopus/octopus.dart';
import 'package:ui/ui.dart';

import '../../../feature/authentication/data/authentication_repository.dart';
import '../../../feature/authentication/state/authentication_controller.dart';
import '../../../feature/main/data/main_repository.dart';
import '../../../feature/my_tests/data/my_test_repository.dart';
import '../../../feature/profile/data/profile_repository.dart';
import '../../../feature/settings/bloc/settings_bloc.dart';
import '../../../feature/upload/data/upload_repository.dart';
import '../../service/api_client.dart';
import 'app_metadata.dart';
import 'debug_config.dart';
import 'firebase_remote_config_values.dart';

/// {@template dependencies}
/// Application dependencies.
/// {@endtemplate}
class Dependencies {
  /// {@macro dependencies}
  Dependencies();

  /// App metadata
  late final AppMetadata metadata;

  /// Database
  late final LocalSource localSource;

  /// [ApiClient] for network requests
  late final ApiClient apiClient;

  /// A controller for the [AuthenticationScope] navigator.
  late final ValueNotifier<List<OctopusRoute>> authNavigator;

  /// A controller for the [MainNavigator] navigator.
  late final ValueNotifier<List<OctopusRoute>> navigator;

  /// [SettingsBloc] for app settings
  late final SettingsBloc settingsBloc;

  /// [AuthenticationController] for authentication
  late final AuthenticationController authenticationController;

  /// [RepositoryContainer] for repositories
  late final RepositoryContainer repository;

  /// [Connectivity] for connectivity
  late final Connectivity connectivity;

  /// [FirebaseRemoteConfigValues] for firebase remote config values
  late final FirebaseRemoteConfigValues firebaseRemoteConfigValues;

  /// [DebugConfig] for app debug settings
  late final ValueNotifier<DebugConfig> appDebugSettings;

  @override
  String toString() => 'Dependencies{}';
}

/// [RepositoryContainer] is a container for Repository instances.
final class RepositoryContainer {
  RepositoryContainer({
    required this.authenticationRepository,
    required this.mainRepository,
    required this.myTestRepository,
    required this.profileRepository,
    required this.uploadRepository,
  });

  /// [IAuthenticationRepository] for authentication
  final IAuthenticationRepository authenticationRepository;

  /// [IMainRepository] for main
  final IMainRepository mainRepository;

  /// [IMyTestRepository] for my tests
  final IMyTestRepository myTestRepository;

  /// [IProfileRepository] for profile / current user
  final IProfileRepository profileRepository;

  /// [IUploadRepository] for customer test uploads
  final IUploadRepository uploadRepository;
}
