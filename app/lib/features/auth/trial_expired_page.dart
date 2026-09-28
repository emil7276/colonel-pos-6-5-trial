import 'package:flutter/material.dart';

class TrialExpiredPage extends StatelessWidget {
  final DateTime expiresAt;

  const TrialExpiredPage({
    super.key,
    required this.expiresAt,
  });

  @override
  Widget build(BuildContext context) {
    final expiryText =
        '${expiresAt.day.toString().padLeft(2, '0')}/'
        '${expiresAt.month.toString().padLeft(2, '0')}/'
        '${expiresAt.year}';

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.lock_clock_outlined,
                size: 72,
              ),
              const SizedBox(height: 24),
              const Text(
                'Masa Trial Berakhir',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Trial aplikasi ini telah berakhir pada $expiryText.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),
              const Text(
                'Data aplikasi tidak dihapus. '
                'Gunakan aktivasi yang valid untuk melanjutkan penggunaan.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
