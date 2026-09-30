import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../core/trial_service.dart';
import '../../core/license/license_service.dart';
import '../../core/widgets.dart';
import '../../core/theme/theme_controller.dart';
import '../../core/theme/cp_visual.dart';
import '../auth/login_page.dart';
import '../pos/pos_page.dart';
import '../reports/report_page.dart';
import '../settings/settings_page.dart';
import '../settings/menu_page.dart';
import '../settings/printer_page.dart';
import '../settings/finance_page.dart';
import 'dashboard_page.dart';

class HomePage extends StatefulWidget {
  final String username;
  final String role;

  const HomePage({super.key, required this.username, required this.role});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int index = 0;
  final posKey = GlobalKey<PosPageState>();

  String? _quote;
  Timer? _quoteTimer;
  TrialStatus? _trialStatus;
  LicenseInfo? _licenseInfo;

  void showQuote(String quote) {
    _quoteTimer?.cancel();
    if (!mounted) return;

    setState(() => _quote = quote);

    _quoteTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() => _quote = null);
      }
    });
  }

  void hideQuote() {
    _quoteTimer?.cancel();
    if (mounted) {
      setState(() => _quote = null);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadTrialStatus();
  }

  Future<void> _loadTrialStatus() async {
    final status = await TrialService.status();
    final license = await LicenseService.getLicense();
    if (mounted) {
      setState(() { _trialStatus = status; _licenseInfo = license; });
    }
  }

String _trialLabel() {
  final license = _licenseInfo;
  if (license != null && license.isActive) {
    final remaining = license.expiresAt.difference(DateTime.now());
    final days = (remaining.inHours / 24).ceil().clamp(1, 9999);
    String planLabel;
    switch (license.plan) {
      case "7D": planLabel = "7 HARI"; break;
      case "1M": planLabel = "1 BULAN"; break;
      case "3M": planLabel = "3 BULAN"; break;
      case "1Y": planLabel = "1 TAHUN"; break;
      default: planLabel = license.plan;
    }
    return "AKTIF • $planLabel • Sisa $days hari";
  }
  final status = _trialStatus;
  if (status == null) return "TRIAL";
  final remaining = status.expiresAt.difference(DateTime.now());
  final days = (remaining.inHours / 24).ceil().clamp(1, 7);
  return "TRIAL • Sisa $days hari";
}

  @override
  void dispose() {
    _quoteTimer?.cancel();
    super.dispose();
  }

  Future<void> logout() async {
    ThemeController.instance.resetToSystem();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  void quickAccess(String action) {
    switch (action) {
      case 'transaksi':
        selectPage(1);
        break;
      case 'laporan':
        selectPage(2);
        break;
      case 'produk':
        if (widget.role != 'Administrator') return;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MenuPage()),
        );
        break;
      case 'printer':
        if (widget.role != 'Administrator') return;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PrinterPage()),
        );
        break;
    }
  }

  void selectPage(int value) {
    setState(() => index = value);
    if (value == 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        posKey.currentState?.load();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardPage(
        username: widget.username,
        role: widget.role,
        onQuickAccess: quickAccess,
      ),
      PosPage(key: posKey, cashier: widget.username, onTransactionSuccess: showQuote),
      ReportPage(role: widget.role),
      if (widget.role == 'Administrator') SettingsPage(username: widget.username),
      if (widget.role == 'Administrator') const FinancePage(),
    ];
    final titles = [
      'Dashboard',
      'Transaksi',
      'Laporan',
      if (widget.role == 'Administrator') 'Pengaturan',
      if (widget.role == 'Administrator') 'Keuangan',
    ];

    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 124,
        flexibleSpace: const CpMasterHeaderBackground(),
        titleSpacing: 4,
        leadingWidth: 56,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: CpLogo(size: 42),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('CP POS', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: .2)),
            Text('${widget.username} • ${widget.role}', style: const TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w700)),
            Row(children: [
              Text(_trialLabel(), style: const TextStyle(fontSize: 10.5, color: Color(0xFF7DE7F2), fontWeight: FontWeight.w900)),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Untuk berlangganan, hubungi cp.colonel.pos@gmail.com'))),
                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap, foregroundColor: const Color(0xFFFF3942)),
                child: const Text('Berlangganan Sekarang', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, decoration: TextDecoration.underline)),
              ),
            ]),
          ],
        ),
        actions: [
          PopupMenuButton<ThemeMode>(
            tooltip: 'Pilih tema',
            icon: Icon(Theme.of(context).brightness == Brightness.dark ? Icons.dark_mode_rounded : Icons.light_mode_rounded),
            onSelected: (mode) async { await ThemeController.instance.setMode(mode); },
            itemBuilder: (_) => [
              CheckedPopupMenuItem(value: ThemeMode.system, checked: ThemeController.instance.mode == ThemeMode.system, child: const Text('Sistem / Otomatis')),
              CheckedPopupMenuItem(value: ThemeMode.light, checked: ThemeController.instance.mode == ThemeMode.light, child: const Text('Mode Terang')),
              CheckedPopupMenuItem(value: ThemeMode.dark, checked: ThemeController.instance.mode == ThemeMode.dark, child: const Text('Mode Gelap')),
            ],
          ),
          IconButton(tooltip: 'Logout', onPressed: logout, icon: const Icon(Icons.logout_rounded)),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: Container(
            color: theme.scaffoldBackgroundColor,
            child: Stack(
              children: [
                Positioned.fill(
                  child: IndexedStack(
                    index: index,
                    children: pages,
                  ),
                ),
            if (_quote != null)
              Positioned(
                top: 8,
                left: 8,
                right: 8,
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: -1.0, end: 0.0),
                  duration: const Duration(milliseconds: 420),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, value * 100),
                      child: child,
                    );
                  },
                  child: Dismissible(
                    key: ValueKey(_quote),
                    direction: DismissDirection.vertical,
                    onDismissed: (_) => hideQuote(),
                    child: Material(
                      elevation: 7,
                      borderRadius: BorderRadius.circular(14),
                      color: red,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 13, 8, 13),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 1),
                              child: Icon(
                                Icons.format_quote_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 9),
                            Expanded(
                              child: Text(
                                _quote!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  height: 1.35,
                                ),
                              ),
                            ),
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              onPressed: hideQuote,
                              icon: const Icon(
                                Icons.close_rounded,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: selectPage,
        destinations: [
          const NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
          const NavigationDestination(icon: Icon(Icons.point_of_sale_outlined), selectedIcon: Icon(Icons.point_of_sale_rounded), label: 'Transaksi'),
          const NavigationDestination(icon: Icon(Icons.analytics_outlined), selectedIcon: Icon(Icons.analytics_rounded), label: 'Laporan'),
          if (widget.role == 'Administrator')
            const NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings_rounded),
              label: 'Admin',
            ),
          if (widget.role == 'Administrator')
            const NavigationDestination(
              icon: Icon(Icons.account_balance_wallet_outlined),
              selectedIcon: Icon(Icons.account_balance_wallet_rounded),
              label: 'Keuangan',
            ),
        ],
      ),
    );
  }
}
