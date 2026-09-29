import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/license/license_service.dart';

class TrialExpiredPage extends StatefulWidget {
  final DateTime expiresAt;

  const TrialExpiredPage({
    super.key,
    required this.expiresAt,
  });

  @override
  State<TrialExpiredPage> createState() => _TrialExpiredPageState();
}

class _TrialExpiredPageState extends State<TrialExpiredPage> {
  final _codeController = TextEditingController();

  bool _loading = false;
  String? _error;
  String? _success;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _activate() async {
    final code = _codeController.text.trim();

    if (code.isEmpty) {
      setState(() => _error = 'Masukkan kode aktivasi.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _success = null;
    });

    final ok = await LicenseService.saveLicense(code);

    if (!mounted) return;

    setState(() {
      _loading = false;
      if (ok) {
        _success =
            'Aktivasi berhasil. Silakan tutup dan buka kembali aplikasi.';
        _codeController.clear();
      } else {
        _error = 'Gagal: ${LicenseService.lastError}';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final expiryText =
        '${widget.expiresAt.day.toString().padLeft(2, '0')}/'
        '${widget.expiresAt.month.toString().padLeft(2, '0')}/'
        '${widget.expiresAt.year}';

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
                    const SizedBox(height: 24),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Masukkan Kode Aktivasi',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _codeController,
                      decoration: const InputDecoration(
                        hintText: 'Masukkan kode aktivasi',
                        border: OutlineInputBorder(),
                      ),
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _activate(),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _loading ? null : _activate,
                        icon: _loading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.key),
                        label: Text(
                          _loading ? 'Memeriksa...' : 'AKTIVASI',
                        ),
                      ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                    if (_success != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _success!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    const SizedBox(height: 6),
                    const Text(
                      'Ingin melanjutkan dan menambah layanan?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final uri = Uri(
                          scheme: 'mailto',
                          path: 'cp.colonel.pos@gmail.com',
                          queryParameters: {
                            'subject': 'Saya ingin menambah layanan',
                          },
                        );
                        await launchUrl(uri);
                      },
                      icon: const Icon(Icons.email_outlined),
                      label: const Text('cp.colonel.pos@gmail.com'),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Klik email untuk mengirim: Saya ingin menambah layanan',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, height: 1.4),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Data aplikasi tidak dihapus.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14),
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
