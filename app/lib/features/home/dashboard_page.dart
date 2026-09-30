import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants.dart';
import '../../core/license/license_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/cp_visual.dart';
import '../../core/utils.dart';
import '../../core/widgets.dart';
import '../../data/database.dart';
import '../../models/models.dart';
import '../settings/finance_page.dart';
import '../settings/settings_page.dart';

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

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.red,
      onRefresh: load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xxxl),
        children: [
          _masterWelcome(context),
          const SizedBox(height: AppSpacing.xl),
          _sectionTitle('Ringkasan Hari Ini', 'Performa penjualan hari ini'),
          const SizedBox(height: AppSpacing.md),
          LayoutBuilder(builder: (context,c) {
            final cross=c.maxWidth>=900?4:2;
            return GridView.count(
              crossAxisCount:cross, shrinkWrap:true, physics:const NeverScrollableScrollPhysics(),
              mainAxisSpacing:AppSpacing.md, crossAxisSpacing:AppSpacing.md,
              childAspectRatio:cross==4?1.95:1.55,
              children:[
                _stat('Omzet',rp(omzet),Icons.payments_rounded,AppColors.red),
                _stat('Transaksi','$transaksi',Icons.receipt_long_rounded,CpVisual.blue,onTap:showTransactions),
                _stat('Item Terjual','$item',Icons.inventory_2_rounded,CpVisual.green,onTap:showItemsSold),
                if(widget.role=='Administrator') _stat('Pengeluaran',rp(pengeluaran),Icons.account_balance_wallet_rounded,CpVisual.gold,onTap:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>const FinancePage())))
                else _stat('Status','V6.5.0',Icons.verified_rounded,CpVisual.cyan),
              ],
            );
          }),
          const SizedBox(height:AppSpacing.xl),
          _sectionTitle('Akses Cepat','Fitur utama CP POS'),
          const SizedBox(height:AppSpacing.md),
          LayoutBuilder(builder:(context,c){
            final cols=c.maxWidth>=1100?5:(c.maxWidth>=700?3:2);
            return GridView.count(
              crossAxisCount:cols, shrinkWrap:true, physics:const NeverScrollableScrollPhysics(),
              crossAxisSpacing:AppSpacing.md, mainAxisSpacing:AppSpacing.md,
              childAspectRatio:cols==5?1.72:1.65,
              children:[
                _quick('Penjualan',Icons.point_of_sale_rounded,'transaksi',AppColors.red),
                _quick('Stok',Icons.inventory_2_rounded,'stok',CpVisual.blue),
                _quick('Laporan',Icons.analytics_rounded,'laporan',CpVisual.purple),
                if(widget.role=='Administrator') _quick('Admin',Icons.admin_panel_settings_rounded,'admin',CpVisual.green),
                if(widget.role=='Administrator') _quick('Keuangan',Icons.account_balance_wallet_rounded,'keuangan',CpVisual.gold),
              ],
            );
          }),
          const SizedBox(height:AppSpacing.xl),
          _sectionTitle('Transaksi Terbaru','5 transaksi terakhir'),
          const SizedBox(height:AppSpacing.md),
          if(recent.isEmpty) _emptyState(Icons.receipt_long_rounded,'Belum ada transaksi','Transaksi terbaru akan muncul di sini.') else ...recent.map((s)=>_recentSale(context,s)),
          const SizedBox(height:AppSpacing.md),
          Center(child:TextButton.icon(onPressed:showTransactions,icon:const Icon(Icons.arrow_forward_rounded,size:17),label:const Text('Lihat semua transaksi'))),
          const CopyrightFooter(),
        ],
      ),
    );
  }

  Widget _masterWelcome(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight:238),
      decoration:BoxDecoration(
        gradient:const LinearGradient(begin:Alignment.topLeft,end:Alignment.bottomRight,colors:[Color(0xFF31080D),Color(0xFF0B0D12),Color(0xFF090C12)]),
        borderRadius:BorderRadius.circular(24),
        border:Border.all(color:AppColors.red.withValues(alpha:.72),width:1.2),
        boxShadow:[BoxShadow(color:AppColors.red.withValues(alpha:.20),blurRadius:24,spreadRadius:-8)],
      ),
      clipBehavior:Clip.antiAlias,
      child:Stack(children:[
        Positioned(right:-8,bottom:-6,child:Image.asset('assets/images/cp_pos_header_illustration.png',width:300,height:205,fit:BoxFit.contain)),
        Positioned(top:14,right:14,child:Container(width:40,height:40,decoration:BoxDecoration(color:Colors.white.withValues(alpha:.10),shape:BoxShape.circle,border:Border.all(color:Colors.white.withValues(alpha:.16))),child:const Icon(Icons.notifications_none_rounded,color:Colors.white,size:21))),
        Padding(
          padding:const EdgeInsets.fromLTRB(20,18,20,16),
          child:ConstrainedBox(
            constraints:const BoxConstraints(maxWidth:560),
            child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
              Row(children:[const CpLogo(size:42),const SizedBox(width:10),const Text('CP POS',style:TextStyle(color:Colors.white,fontSize:18,fontWeight:FontWeight.w900)),const SizedBox(width:8),const Text('Professional Point of Sale',style:TextStyle(color:Colors.white70,fontSize:11.5,fontWeight:FontWeight.w700))]),
              const SizedBox(height:24),
              Text('Selamat datang, ${widget.username}',style:const TextStyle(color:Colors.white,fontSize:24,fontWeight:FontWeight.w900)),
              const SizedBox(height:9),
              Wrap(spacing:8,runSpacing:7,children:[_headerPill(Icons.person_outline_rounded,widget.role),_headerPill(Icons.workspace_premium_outlined,'Trial 6.5')]),
              const SizedBox(height:10),
              const SizedBox(width:430,child:Text('Kelola penjualan, stok, laporan, dan keuangan dari satu sistem kasir modern.',style:TextStyle(color:Colors.white70,fontSize:12.5,height:1.4,fontWeight:FontWeight.w600))),
              const SizedBox(height:12),
              Row(children:[
                FilledButton.icon(onPressed:_activateLicense,style:FilledButton.styleFrom(backgroundColor:Colors.white,foregroundColor:AppColors.red,elevation:0,padding:const EdgeInsets.symmetric(horizontal:14,vertical:10),minimumSize:Size.zero),icon:const Icon(Icons.key_rounded,size:17),label:const Text('Aktivasi Lisensi',style:TextStyle(fontWeight:FontWeight.w900))),
                const SizedBox(width:10),
                TextButton(onPressed:()=>ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Untuk berlangganan, hubungi cp.colonel.pos@gmail.com'))),style:TextButton.styleFrom(foregroundColor:Colors.white,padding:EdgeInsets.zero,minimumSize:Size.zero,tapTargetSize:MaterialTapTargetSize.shrinkWrap),child:const Text('Berlangganan Sekarang',style:TextStyle(fontWeight:FontWeight.w800,decoration:TextDecoration.underline))),
              ]),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _headerPill(IconData icon,String label)=>Container(
    padding:const EdgeInsets.symmetric(horizontal:10,vertical:6),
    decoration:BoxDecoration(color:Colors.white.withValues(alpha:.11),borderRadius:BorderRadius.circular(999),border:Border.all(color:Colors.white.withValues(alpha:.14))),
    child:Row(mainAxisSize:MainAxisSize.min,children:[Icon(icon,size:14,color:Colors.white),const SizedBox(width:5),Text(label,style:const TextStyle(color:Colors.white,fontSize:11,fontWeight:FontWeight.w800))]),
  );

  Widget _sectionTitle(String title,String subtitle)=>Row(crossAxisAlignment:CrossAxisAlignment.end,children:[
    Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:const TextStyle(fontSize:19,fontWeight:FontWeight.w900,letterSpacing:-.2)),const SizedBox(height:3),Text(subtitle,style:TextStyle(color:Theme.of(context).colorScheme.onSurfaceVariant,fontSize:12,fontWeight:FontWeight.w600))])),
    Container(width:7,height:7,decoration:const BoxDecoration(color:AppColors.red,shape:BoxShape.circle)),
  ]);

  Widget _quick(String title, IconData icon, String action, Color accent) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final surface = dark ? CpVisual.darkSurface : CpVisual.lightSurface;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withValues(alpha: dark ? .16 : .045),
            surface,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accent.withValues(alpha: dark ? .78 : .34),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: dark ? .20 : .08),
            blurRadius: dark ? 18 : 10,
            spreadRadius: dark ? 1 : 0,
          ),
        ],
      ),
      child: InkWell(
        onTap: () => widget.onQuickAccess?.call(action),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(13),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: CpVisual.iconTile(accent, dark: dark),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 21,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w900,
                ),
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
    Color accent, {
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final surface = dark ? CpVisual.darkSurface : CpVisual.lightSurface;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withValues(alpha: dark ? .15 : .035),
            surface,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accent.withValues(alpha: dark ? .78 : .34),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: dark ? .20 : .08),
            blurRadius: dark ? 18 : 10,
            spreadRadius: dark ? 1 : 0,
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: CpVisual.iconTile(accent, dark: dark),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 21,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.chevron_right_rounded,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
            ],
          ),
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
