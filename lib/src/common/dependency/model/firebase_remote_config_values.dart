import 'package:meta/meta.dart';

import '../../service/remote_config_service.dart';

/// {@template firebase_remote_config_values}
/// Firebase remote config values.
/// {@endtemplate}
@immutable
final class FirebaseRemoteConfigValues {
  /// {@macro firebase_remote_config_values}
  const FirebaseRemoteConfigValues({required this.updateData, required this.supportLink});

  final (AppUpdate, String, String) updateData;
  final String supportLink;

  FirebaseRemoteConfigValues copyWith({(AppUpdate, String, String)? updateData, String? supportLink}) =>
      FirebaseRemoteConfigValues(
        updateData: updateData ?? this.updateData,
        supportLink: supportLink ?? this.supportLink,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FirebaseRemoteConfigValues && other.updateData == updateData && other.supportLink == supportLink;
  }

  @override
  int get hashCode => updateData.hashCode ^ supportLink.hashCode;

  @override
  String toString() => '''FirebaseRemoteConfigValues(updateData: $updateData, supportLink: $supportLink)''';
}
