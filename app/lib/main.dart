import 'package:flutter/material.dart';
import 'app.dart';
import 'data/database.dart';
import 'core/trial_service.dart';
import 'features/auth/trial_expired_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DB.database;

  final trial = await TrialService.status();

  if (!trial.active) {
    runApp(
      TrialExpiredApp(
        expiresAt: trial.expiresAt,
      ),
    );
    return;
  }

  runApp(const ColonelApp());
}

class TrialExpiredApp extends StatelessWidget {
  final DateTime expiresAt;

  const TrialExpiredApp({
    super.key,
    required this.expiresAt,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TrialExpiredPage(
        expiresAt: expiresAt,
      ),
    );
  }
}
