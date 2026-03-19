import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:local_source/local_source.dart';
import 'package:octopus/octopus.dart';
import 'package:ui/ui.dart';

import '../../../feature/authentication/data/authentication_repository.dart';
import '../../../feature/authentication/state/authentication_controller.dart';
import '../../../feature/settings/bloc/settings_bloc.dart';
import '../../service/api_service.dart';
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

  /// [DioContainer] for network requests
  late final DioContainer dios;

  /// [ApiService] for network requests
  late final ApiService apiService;

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

//--- Container models --- //
/// [DioContainer] is a container for [Dio] instances.
@immutable
final class DioContainer {
  const DioContainer({required this.dio});

  List<Dio> get all => [dio];

  final Dio dio;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DioContainer && other.dio == dio;
  }

  @override
  int get hashCode => dio.hashCode;
}

/// [RepositoryContainer] is a container for Repository instances.
final class RepositoryContainer {
  RepositoryContainer({required this.authenticationRepository});

  /// [IAuthenticationRepository] for authentication
  final IAuthenticationRepository authenticationRepository;
}
