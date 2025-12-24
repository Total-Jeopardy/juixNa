import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Consumer;
import 'package:juix_na/app/theme.dart';
import 'package:juix_na/bootstrap.dart';
import 'package:juix_na/features/inventory/view/screens/stock_movement_screen.dart';
import 'package:juix_na/app/theme_controller.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  final app = await bootstrap();
  runApp(ProviderScope(child: app));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeController>(
      builder: (context, themeController, _) {
        return MaterialApp(
          title: 'JuixNa',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeController.mode,
          home: const Scaffold(body: StockMovementScreen()),
        );
      },
    );
  }
}
