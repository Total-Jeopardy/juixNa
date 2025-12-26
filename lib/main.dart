import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:juix_na/app/router.dart';
import 'package:juix_na/app/theme.dart';
import 'package:juix_na/bootstrap.dart';
import 'package:juix_na/app/theme_controller.dart';

Future<void> main() async {
  final app = await bootstrap();
  runApp(ProviderScope(child: app));
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeControllerProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'JuixNa',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
