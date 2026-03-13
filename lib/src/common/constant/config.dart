/// Config for app.
sealed class Config {
  const Config._();

  // --- ENVIRONMENT --- //
  static final EnvironmentFlavor environment = EnvironmentFlavor.from(
    const String.fromEnvironment('ENVIRONMENT', defaultValue: 'development'),
  );

  // --- API --- //
  static const String apiBaseUrl = String.fromEnvironment('BASE_URL', defaultValue: '');

  // --- IS IOS --- //
  static const bool kIsIos = String.fromEnvironment('config.platform', defaultValue: '') == 'ios';

  // --- IS ANDROID --- //
  static const bool kIsAndroid = String.fromEnvironment('config.platform', defaultValue: '') == 'android';

  // --- Telegram API Base Url --- //
  static const String telegramApiBaseUrl = String.fromEnvironment(
    'TELEGRAM_API_BASE_URL',
    defaultValue: 'https://api.telegram.org',
  );
}

/// Environment flavor.
/// e.g. development, staging, production
enum EnvironmentFlavor {
  /// Development
  development('development'),

  /// Staging
  staging('staging'),

  /// Production
  production('production');

  /// Create environment flavor.
  const EnvironmentFlavor(this.value);

  /// Create environment flavor from string.
  factory EnvironmentFlavor.from(String? value) => switch (value?.trim().toLowerCase()) {
    'development' || 'debug' || 'develop' || 'dev' => development,
    'staging' || 'profile' || 'stage' || 'stg' => staging,
    'production' || 'release' || 'prod' || 'prd' => production,
    _ => const bool.fromEnvironment('dart.vm.product') ? production : development,
  };

  /// development, staging, production
  final String value;

  /// Whether the environment is development.
  bool get isDevelopment => this == development;

  /// Whether the environment is staging.
  bool get isStaging => this == staging;

  /// Whether the environment is production.
  bool get isProduction => this == production;
}
