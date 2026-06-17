class AuthServiceResponse {
  const AuthServiceResponse({required this.idToken});

  /// The identity token from the provider (Google / Apple).
  /// Sent to the backend as `id_token` to obtain backend JWT tokens.
  final String idToken;
}
