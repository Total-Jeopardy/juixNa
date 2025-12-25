/// Application configuration for different environments.
class AppConfig {
  /// The base URL for the API backend.
  final String baseUrl;

  /// Environment name (for logging/debugging).
  final String environment;

  /// Timeout duration for API requests.
  final Duration apiTimeout;

  const AppConfig({
    required this.baseUrl,
    required this.environment,
    this.apiTimeout = const Duration(seconds: 25),
  });

  /// Production configuration (default).
  static const AppConfig production = AppConfig(
    baseUrl: 'https://juixna-api.onrender.com',
    environment: 'production',
  );

  /// Development configuration (local backend).
  static const AppConfig development = AppConfig(
    baseUrl: 'http://127.0.0.1:8000',
    environment: 'development',
  );

  /// Staging configuration (if you have a staging server).
  static const AppConfig staging = AppConfig(
    baseUrl: 'https://juixna-api-staging.onrender.com',
    environment: 'staging',
  );

  /// Get the current configuration based on environment.
  ///
  /// In a real app, you might:
  /// - Use compile-time constants (--dart-define)
  /// - Read from environment variables
  /// - Use a config file
  ///
  /// For now, we default to production but allow override via [forceEnvironment].
  static AppConfig getCurrent({AppConfig? forceEnvironment}) {
    if (forceEnvironment != null) {
      return forceEnvironment;
    }

    // Check for compile-time constant (set via --dart-define=ENV=dev)
    // This would be: const String.fromEnvironment('ENV', defaultValue: 'prod')
    // For now, default to production
    const env = String.fromEnvironment('ENV', defaultValue: 'prod');

    switch (env.toLowerCase()) {
      case 'dev':
      case 'development':
        return development;
      case 'staging':
        return staging;
      case 'prod':
      case 'production':
      default:
        return production;
    }
  }

  @override
  String toString() =>
      'AppConfig(environment: $environment, baseUrl: $baseUrl)';
}

/// Test accounts for development and testing.
/// These match the backend test accounts.
class TestAccounts {
  /// Admin test account
  static const admin = TestAccount(
    email: 'admin@example.com',
    password: 'secret123',
    role: 'Admin',
  );

  /// Manager test account
  static const manager = TestAccount(
    email: 'manager@example.com',
    password: 'secret123',
    role: 'Manager',
  );

  /// Staff test account
  static const staff = TestAccount(
    email: 'staff@example.com',
    password: 'secret123',
    role: 'Staff',
  );

  /// All test accounts
  static const all = [admin, manager, staff];
}

/// Test account credentials.
class TestAccount {
  final String email;
  final String password;
  final String role;

  const TestAccount({
    required this.email,
    required this.password,
    required this.role,
  });

  @override
  String toString() => 'TestAccount(email: $email, role: $role)';
}
