import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:juix_na/main.dart';
import 'core/auth/token_store.dart';
import 'core/config/app_config.dart';
import 'core/network/api_client.dart';

/// Riverpod provider for TokenStore.
final tokenStoreProvider = Provider<TokenStore>((ref) {
  return TokenStore();
});

/// Riverpod provider for ApiClient.
final apiClientProvider = Provider<ApiClient>((ref) {
  final tokenStore = ref.watch(tokenStoreProvider);
  final config = AppConfig.getCurrent();

  return ApiClient(
    baseUrl: config.baseUrl,
    tokenProvider: () => tokenStore.getAccessToken(),
    timeout: config.apiTimeout,
  );
});

/// App-wide dependency injection.
/// Creates single instances of shared services and provides them to the app.
///
/// Note: With Riverpod, providers are automatically created when accessed.
/// We don't need to manually create instances here - the providers handle it.
/// However, if you need to override with specific instances (e.g., for testing),
/// you can use ProviderScope.overrides.
Future<Widget> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Return the app - Riverpod providers are automatically available via ProviderScope
  // TokenStore and ApiClient are provided via Riverpod providers above
  // ThemeController is provided via NotifierProvider (see theme_controller.dart)
  return const MainApp();
}
