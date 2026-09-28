import 'package:shared_preferences/shared_preferences.dart';

class TrialStatus {
  final bool active;
  final DateTime startedAt;
  final DateTime expiresAt;

  const TrialStatus({
    required this.active,
    required this.startedAt,
    required this.expiresAt,
  });
}

class TrialService {
  static const Duration trialDuration = Duration(days: 7);
  static const String _startedAtKey = 'cp_trial_started_at';

  static Future<TrialStatus> status() async {
    final prefs = await SharedPreferences.getInstance();

    final saved = prefs.getString(_startedAtKey);

    final DateTime startedAt;

    if (saved == null) {
      startedAt = DateTime.now();
      await prefs.setString(
        _startedAtKey,
        startedAt.toIso8601String(),
      );
    } else {
      startedAt = DateTime.tryParse(saved) ?? DateTime.now();

      if (DateTime.tryParse(saved) == null) {
        await prefs.setString(
          _startedAtKey,
          startedAt.toIso8601String(),
        );
      }
    }

    final expiresAt = startedAt.add(trialDuration);
    final active = DateTime.now().isBefore(expiresAt);

    return TrialStatus(
      active: active,
      startedAt: startedAt,
      expiresAt: expiresAt,
    );
  }
}
