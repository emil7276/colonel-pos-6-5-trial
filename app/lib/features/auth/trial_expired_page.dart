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
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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
                    const SizedBox(height: 18),
                    const Text(
                      'Untuk perpanjangan atau aktivasi layanan, '
                      'silakan hubungi:',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const SelectableText(
                      'cp_colonel_pos@gmail.com',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Data aplikasi tidak dihapus. '
                      'Gunakan aktivasi yang valid untuk melanjutkan penggunaan.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
