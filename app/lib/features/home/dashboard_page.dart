import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants.dart';
import '../../core/license/license_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils.dart';
import '../../core/widgets.dart';
import '../../data/database.dart';
import '../../models/models.dart';
import '../settings/finance_page.dart';

class DashboardPage extends StatefulWidget {
  final String username;
  final String role;
  final ValueChanged<String>? onQuickAccess;
  const DashboardPage({super.key, required this.username, this.role = 'Kasir', this.onQuickAccess});
  @override State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int omzet = 0, transaksi = 0, item = 0, pengeluaran = 0;
  List<SaleModel> recent = [];

  @override void initState() { super.initState(); load(); }

  Future<void> load() async {
    final all = await DB.sales();
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    var om = 0, tr = 0;
    for (final raw in all) {
      final s = SaleModel.fromMap(raw);
      final d = DateTime.tryParse(s.time);
      if (d != null && !d.isBefore(start) && d.isBefore(end) && !s.returned) { om += s.total; tr++; }
    }
    final db = await DB.database;
    final ymd = (DateTime d) {
      final y = d.year.toString().padLeft(4, '0');
      final m = d.month.toString().padLeft(2, '0');
      final day = d.day.toString().padLeft(2, '0');
      return '$y-$m-$day';
    };
    final rows = await db.rawQuery(
      '''SELECT COALESCE(SUM(si.qty),0) jumlah
         FROM sale_items si INNER JOIN sales s ON s.id=si.sale_id
         WHERE s.sale_time >= ? AND s.sale_time < ? AND s.returned=0''',
      ['${ymd(start)} 00:00:00', '${ymd(end)} 00:00:00'],
    );
    var expenseToday = 0;
    if (widget.role == 'Administrator') expenseToday = await DB.expenseTotal(start, end);
    if (!mounted) return;
    setState(() {
      omzet = om; transaksi = tr; item = (rows.first['jumlah'] as num).toInt();
      pengeluaran = expenseToday; recent = all.take(5).map(SaleModel.fromMap).toList();
    });
  }

  @override Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return RefreshIndicator(
      color: AppColors.red,
      onRefresh: load,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildHeader(context, isDark),
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xxxl),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _sectionTitle('Ringkasan Hari Ini', 'Performa penjualan hari ini'),
              const SizedBox(height: AppSpacing.md),
              LayoutBuilder(builder: (context, c) {
                final cross = c.maxWidth >= 900 ? 4 : 2;
                return GridView.count(
                  crossAxisCount: cross, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: AppSpacing.md, crossAxisSpacing: AppSpacing.md,
                  childAspectRatio: cross == 4 ? 1.9 : 1.55,
                  children: [
                    _stat('Omzet', rp(omzet), Icons.payments_rounded, true),
                    _stat('Transaksi', '$transaksi', Icons.receipt_long_rounded, false, onTap: showTransactions),
                    _stat('Item Terjual', '$item', Icons.inventory_2_rounded, false, onTap: showItemsSold),
                    if (widget.role == 'Administrator')
                      _stat('Pengeluaran', rp(pengeluaran), Icons.account_balance_wallet_rounded, false, onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const FinancePage()));
                      })
                    else
                      _stat('Status', 'V6.5.0', Icons.verified_rounded, false),
                  ],
                );
              }),
              const SizedBox(height: AppSpacing.xxxl),
              _sectionTitle('Akses Cepat', 'Fitur yang sering digunakan'),
              const SizedBox(height: AppSpacing.md),
              LayoutBuilder(builder: (context, c) {
                final cols = c.maxWidth >= 900 ? 4 : 2;
                return GridView.count(
                  crossAxisCount: cols, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: AppSpacing.md, mainAxisSpacing: AppSpacing.md,
                  childAspectRatio: cols == 4 ? 2.15 : 1.9,
                  children: [
                    _quick('Transaksi Baru', Icons.point_of_sale_rounded, 'transaksi'),
                    _quick('Laporan', Icons.analytics_rounded, 'laporan'),
                    if (widget.role == 'Administrator') _quick('Produk', Icons.restaurant_menu_rounded, 'produk'),
                    if (widget.role == 'Administrator') _quick('Printer', Icons.print_rounded, 'printer'),
                  ],
                );
              }),
              const SizedBox(height: AppSpacing.xxxl),
              _sectionTitle('Transaksi Terbaru', '5 transaksi terakhir'),
              const SizedBox(height: AppSpacing.md),
              if (recent.isEmpty)
                _emptyState(Icons.receipt_long_rounded, 'Belum ada transaksi', 'Transaksi terbaru akan muncul di sini.')
              else
                ...recent.map((s) => _recentSale(context, s)),
              const SizedBox(height: AppSpacing.md),
              Center(child: TextButton.icon(
                onPressed: showTransactions,
                icon: const Icon(Icons.arrow_forward_rounded, size: 17),
                label: const Text('Lihat semua transaksi'),
              )),
              const CopyrightFooter(),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    final base = isDark ? const Color(0xFF090B10) : const Color(0xFFD71920);
    final mid = isDark ? const Color(0xFF17080D) : const Color(0xFFB90F18);
    final deep = isDark ? const Color(0xFF030407) : const Color(0xFF78060C);
    final secondary = Colors.white.withValues(alpha: .78);

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        MediaQuery.of(context).padding.top + 14,
        AppSpacing.lg,
        18,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.red.withValues(alpha: isDark ? .38 : .22),
          width: 1,
        ),
        gradient: LinearGradient(
          colors: [base, mid, deep],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: const [0, .52, 1],
        ),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: .55)
                : AppColors.red.withValues(alpha: .20),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: -18,
            right: -18,
            top: -2,
            height: 176,
            child: IgnorePointer(
              child: Opacity(
                opacity: isDark ? .12 : .16,
                child: Image.asset(
                  'assets/images/cp_header_artwork.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
          ),
          Positioned(
            right: -6,
            bottom: -4,
            width: 154,
            height: 154,
            child: IgnorePointer(
              child: Opacity(
                opacity: isDark ? .92 : .94,
                child: Image.asset(
                  'assets/images/cp_pos_header_illustration.png',
                  fit: BoxFit.contain,
                  alignment: Alignment.bottomRight,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: isDark ? .12 : .02),
                      Colors.transparent,
                      deep.withValues(alpha: .72),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: -70,
            top: -72,
            child: Container(
              width: 210,
              height: 210,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: .08),
                  width: 26,
                ),
              ),
            ),
          ),
          Positioned(
            right: 12,
            bottom: -90,
            child: Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: .025),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .10),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: .16),
                      ),
                    ),
                    child: const CpLogo(size: 50),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CP POS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: .5,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Professional Point of Sale',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .10),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: .12),
                      ),
                    ),
                    child: const Icon(
                      Icons.notifications_none_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                'Selamat datang, ${widget.username}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -.3,
                ),
              ),
              const SizedBox(height: 7),
              Row(
                children: [
                  _headerPill(Icons.person_outline_rounded, widget.role),
                  const SizedBox(width: 7),
                  _headerPill(Icons.verified_rounded, 'Trial 6.5'),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      'Kelola penjualan, stok, dan laporan dalam satu tempat.',
                      style: TextStyle(
                        color: secondary,
                        fontSize: 12.5,
                        height: 1.3,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  FilledButton.icon(
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
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.red,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 13,
                        vertical: 10,
                      ),
                      minimumSize: Size.zero,
                    ),
                    icon: const Icon(
                      Icons.workspace_premium_rounded,
                      size: 17,
                    ),
                    label: const Text(
                      'Upgrade',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _activateLicense,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  icon: const Icon(Icons.key_outlined, size: 16),
                  label: const Text(
                    'Aktivasi Lisensi',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerPill(IconData icon, String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(color: Colors.white.withValues(alpha: .11), borderRadius: BorderRadius.circular(999), border: Border.all(color: Colors.white.withValues(alpha: .12))),
    child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 14, color: Colors.white), const SizedBox(width: 5), Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800))]),
  );

  Widget _sectionTitle(String title, String subtitle) => Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900, letterSpacing: -.2)),
      const SizedBox(height: 3),
      Text(subtitle, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.w600)),
    ])),
    Container(width: 7, height: 7, decoration: const BoxDecoration(color: AppColors.red, shape: BoxShape.circle)),
  ]);

  Widget _quick(String title, IconData icon, String action) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => widget.onQuickAccess?.call(action),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.red.withValues(alpha: .16),
                      AppColors.red.withValues(alpha: .06),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(
                    color: AppColors.red.withValues(alpha: .10),
                  ),
                ),
                child: Icon(icon, color: AppColors.red, size: 20),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: colors.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stat(
    String title,
    String value,
    IconData icon,
    bool primary, {
    VoidCallback? onTap,
  }) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        onTap: onTap,
        child: Stack(
          children: [
            Positioned(
              right: -28,
              top: -34,
              child: Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.red.withValues(
                    alpha: primary ? .055 : .025,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: primary
                            ? [
                                AppColors.red.withValues(alpha: .18),
                                AppColors.red.withValues(alpha: .06),
                              ]
                            : [
                                colors.onSurface.withValues(alpha: .065),
                                colors.onSurface.withValues(alpha: .025),
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: primary
                            ? AppColors.red.withValues(alpha: .12)
                            : colors.onSurface.withValues(alpha: .05),
                      ),
                    ),
                    child: Icon(
                      icon,
                      color: primary ? AppColors.red : colors.onSurface,
                      size: 21,
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: colors.onSurfaceVariant,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            if (onTap != null)
                              Icon(
                                Icons.chevron_right_rounded,
                                size: 17,
                                color: colors.onSurfaceVariant,
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        FittedBox(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            value,
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                              color: primary
                                  ? AppColors.red
                                  : colors.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _recentSale(BuildContext context, SaleModel sale) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 4),
        leading: Container(width: 42, height: 42, decoration: BoxDecoration(color: AppColors.red.withValues(alpha: .10), borderRadius: BorderRadius.circular(13)), child: const Icon(Icons.receipt_long_rounded, color: AppColors.red, size: 20)),
        title: Text(sale.no, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text('${sale.time} • ${sale.cashier}', style: TextStyle(color: colors.onSurfaceVariant, fontSize: 11.5, fontWeight: FontWeight.w600)),
        trailing: Text(rp(sale.total), style: const TextStyle(color: AppColors.red, fontWeight: FontWeight.w900)),
      ),
    );
  }

  Widget _emptyState(IconData icon, String title, String subtitle) {
    final colors = Theme.of(context).colorScheme;
    return Card(child: Padding(padding: const EdgeInsets.all(24), child: Column(children: [
      Container(width: 54, height: 54, decoration: BoxDecoration(color: colors.onSurface.withValues(alpha: .05), borderRadius: BorderRadius.circular(16)), child: Icon(icon, color: colors.onSurfaceVariant)),
      const SizedBox(height: 12),
      Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
      const SizedBox(height: 4),
      Text(subtitle, textAlign: TextAlign.center, style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12)),
    ])));
  }

  Future<void> _activateLicense() async {
    final controller = TextEditingController();
    final code = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Aktivasi Lisensi'),
        content: TextField(controller: controller, maxLines: 4, decoration: const InputDecoration(labelText: 'Kode Aktivasi', hintText: 'Tempel kode aktivasi di sini', border: OutlineInputBorder())),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('BATAL')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, controller.text.trim()), child: const Text('AKTIVASI')),
        ],
      ),
    );
    controller.dispose();
    if (code == null || code.isEmpty || !context.mounted) return;
    final ok = await LicenseService.saveLicense(code);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? 'Lisensi berhasil diaktifkan.' : 'Gagal: ${LicenseService.lastError}')));
  }

  Future<void> showTransactions() async {
    final summary = await DB.daySummary(DateTime.now());
    final sales = (summary['sales'] as List).map((e) => SaleModel.fromMap(e as Map<String, dynamic>)).toList();
    if (!mounted) return;
    if (sales.isEmpty) {
      await showDialog<void>(context: context, builder: (_) => const AlertDialog(title: Text('Transaksi'), content: Text('Belum ada transaksi hari ini.')));
      return;
    }
    await showModalBottomSheet<void>(
      context: context, isScrollControlled: true,
      builder: (_) => SafeArea(child: SizedBox(
        height: MediaQuery.of(context).size.height * .72,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Transaksi Hari Ini', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Expanded(child: ListView.builder(itemCount: sales.length, itemBuilder: (_, i) {
              final sale = sales[i];
              return ListTile(dense: true, leading: const Icon(Icons.receipt_long_rounded, color: AppColors.red), title: Text(sale.no, style: const TextStyle(fontWeight: FontWeight.w800)), subtitle: Text('${sale.time} • ${sale.payment}'), trailing: Text(rp(sale.total), style: const TextStyle(fontWeight: FontWeight.w800)));
            })),
          ]),
        ),
      )),
    );
  }

  Future<void> showItemsSold() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    final rows = await DB.bestSelling(start, end);
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context, isScrollControlled: true,
      builder: (_) => SafeArea(child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Item Terjual Hari Ini', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          if (rows.isEmpty) const Padding(padding: EdgeInsets.all(16), child: Text('Belum ada item terjual hari ini.')),
          ...rows.take(12).map((r) => ListTile(
            dense: true,
            leading: CircleAvatar(radius: 17, backgroundColor: AppColors.red.withValues(alpha: .10), foregroundColor: AppColors.red, child: Text('${r['qty']}')),
            title: Text(r['name'].toString(), style: const TextStyle(fontWeight: FontWeight.w800)),
            trailing: Text(rp(r['omzet'] as num), style: const TextStyle(fontWeight: FontWeight.w800)),
          )),
        ]),
      )),
    );
  }
}
