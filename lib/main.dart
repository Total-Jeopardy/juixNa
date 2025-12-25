import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:juix_na/app/theme.dart';
import 'package:juix_na/bootstrap.dart';
import 'package:juix_na/app/theme_controller.dart';
import 'package:juix_na/core/auth/auth_guard.dart';
import 'package:juix_na/features/inventory/view/screens/inventory_overview_screen.dart';

Future<void> main() async {
  final app = await bootstrap();
  runApp(ProviderScope(child: app));
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeControllerProvider);

    return MaterialApp(
      title: 'JuixNa',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      // AuthGuard automatically shows LoginScreen or InventoryOverviewScreen
      // based on authentication status
      home: const AuthGuard(
        authenticatedChild: InventoryOverviewScreen(),
      ),
    );
  }
}
