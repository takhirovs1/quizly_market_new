import 'package:meta/meta.dart';
import 'package:ui/ui.dart';

/// {@template user}
/// The user entry model.
/// {@endtemplate}
@immutable
sealed class User with _UserPatternMatching, _UserShortcuts {
  /// {@macro user}
  const User._();

  /// {@macro user}
  @literal
  const factory User.unauthenticated() = UnauthenticatedUser;

  /// {@macro user}
  const factory User.authenticated({required String id, required String token, required String refreshToken}) =
      AuthenticatedUser;

  /// The user's id.
  abstract final String? id;

  /// The user's token.
  abstract final String? token;

  /// The user's refresh token.
  abstract final String? refreshToken;

  Map<String, Object?> toJson();
}

/// {@macro user}
///
/// Unauthenticated user.
class UnauthenticatedUser extends User {
  /// {@macro user}
  const UnauthenticatedUser() : super._();

  @override
  String? get id => null;

  @override
  String? get token => null;

  @override
  String? get refreshToken => null;

  @override
  bool get isAuthenticated => false;

  @override
  Map<String, Object?> toJson() => <String, Object?>{
    'type': 'user',
    'status': 'unauthenticated',
    'authenticated': false,
    'id': null,
    'token': null,
    'refresh_token': null,
  };

  @override
  T map<T>({
    required T Function(UnauthenticatedUser user) unauthenticated,
    required T Function(AuthenticatedUser user) authenticated,
  }) => unauthenticated(this);

  @override
  User copyWith({ValueGetter<String?>? id, ValueGetter<String?>? token, ValueGetter<String?>? refreshToken}) =>
      id != null && id() != null
      ? AuthenticatedUser(
          id: id()!,
          token: token != null ? token()! : this.token ?? '',
          refreshToken: refreshToken != null ? refreshToken()! : this.refreshToken ?? '',
        )
      : const UnauthenticatedUser();

  @override
  int get hashCode => -1;

  @override
  bool operator ==(Object other) => identical(this, other) || other is UnauthenticatedUser && id == other.id;

  @override
  String toString() => 'UnauthenticatedUser{}';
}

/// {@macro user}
final class AuthenticatedUser extends User {
  /// {@macro user}
  const AuthenticatedUser({required this.id, required this.token, required this.refreshToken}) : super._();

  @override
  @nonVirtual
  final String id;

  @override
  @nonVirtual
  final String token;

  @override
  @nonVirtual
  final String refreshToken;

  @override
  @nonVirtual
  bool get isAuthenticated => true;

  @override
  Map<String, Object?> toJson() => <String, Object?>{
    'type': 'user',
    'status': 'authenticated',
    'authenticated': true,
    'id': id,
    'refresh_token': refreshToken,
  };

  @override
  T map<T>({
    required T Function(UnauthenticatedUser user) unauthenticated,
    required T Function(AuthenticatedUser user) authenticated,
  }) => authenticated(this);

  @override
  AuthenticatedUser copyWith({
    ValueGetter<String?>? id,
    ValueGetter<String?>? token,
    ValueGetter<String?>? refreshToken,
  }) => AuthenticatedUser(
    id: id != null ? id()! : this.id,
    token: token != null ? token()! : this.token,
    refreshToken: refreshToken != null ? refreshToken()! : this.refreshToken,
  );

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(Object other) => identical(this, other) || other is AuthenticatedUser && id == other.id;

  @override
  String toString() => 'AuthenticatedUser{id: $id}';
}

mixin _UserPatternMatching {
  /// Pattern matching on [User] subclasses.
  T map<T>({
    required T Function(UnauthenticatedUser user) unauthenticated,
    required T Function(AuthenticatedUser user) authenticated,
  });

  /// Pattern matching on [User] subclasses.
  T maybeMap<T>({
    required T Function() orElse,
    T Function(UnauthenticatedUser user)? unauthenticated,
    T Function(AuthenticatedUser user)? authenticated,
  }) => map<T>(
    unauthenticated: (user) => unauthenticated?.call(user) ?? orElse(),
    authenticated: (user) => authenticated?.call(user) ?? orElse(),
  );

  /// Pattern matching on [User] subclasses.
  T? mapOrNull<T>({
    T Function(UnauthenticatedUser user)? unauthenticated,
    T Function(AuthenticatedUser user)? authenticated,
  }) => map<T?>(
    unauthenticated: (user) => unauthenticated?.call(user),
    authenticated: (user) => authenticated?.call(user),
  );
}

mixin _UserShortcuts on _UserPatternMatching {
  /// User is authenticated.
  bool get isAuthenticated;

  /// User is not authenticated.
  bool get isNotAuthenticated => !isAuthenticated;

  /// Copy with new values.
  User copyWith({ValueGetter<String?>? id, ValueGetter<String?>? token, ValueGetter<String?>? refreshToken});
}
