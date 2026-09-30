import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'features/auth/login_page.dart';

class ColonelApp extends StatefulWidget {
  const ColonelApp({super.key});

  @override
  State<ColonelApp> createState() => _ColonelAppState();
}

class _ColonelAppState extends State<ColonelApp> {
  final controller = ThemeController.instance;

  @override
  void initState() {
    super.initState();
    controller.addListener(_themeChanged);
  }

  void _themeChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    controller.removeListener(_themeChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CP POS 6.5',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: controller.mode,
      home: const LoginPage(),
    );
  }
}
