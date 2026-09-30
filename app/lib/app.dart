import 'package:flutter/material.dart';
import 'core/constants.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/login_page.dart';

class ColonelApp extends StatelessWidget {
  const ColonelApp({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: red,
      brightness: Brightness.light,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CP POS 6.5',
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      theme: AppTheme.light(),
      home: const LoginPage(),
    );
  }
}
