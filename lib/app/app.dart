import 'package:flutter/material.dart';

class JuixNaApp extends StatelessWidget {
  const JuixNaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JuixNa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const Placeholder(), // we'll replace with Login/Dashboard later
    );
  }
}
