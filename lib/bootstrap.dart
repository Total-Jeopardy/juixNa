import 'package:flutter/material.dart';
import 'package:juix_na/main.dart';
import 'package:provider/provider.dart';
import 'app/theme_controller.dart';
import 'core/auth/token_store.dart';
import 'core/network/api_client.dart';

/// App-wide dependency injection.
/// Creates single instances of shared services and provides them to the app.
Future<Widget> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1) Core singletons
  final tokenStore = TokenStore();

  // Replace this with your real backend base URL when ready.
  const baseUrl = 'http://127.0.0.1:8000';

  final apiClient = ApiClient(
    baseUrl: baseUrl,
    tokenProvider: () => tokenStore.getAccessToken(),
  );

  // 2) Provide dependencies to the whole app
  return MultiProvider(
    providers: [
      Provider<TokenStore>.value(value: tokenStore),
      Provider<ApiClient>.value(value: apiClient),
      ChangeNotifierProvider<ThemeController>(
        create: (_) => ThemeController(),
      ),
    ],
    child: const MainApp(),
  );
}
