import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../constants/colors.dart';
import '../constants/tax_config.dart';
import '../providers/tax_provider.dart';
import 'package:go_router/go_router.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _selectedTaxType = 'Semua Pajak';
  String _selectedPeriod = 'Bulan Ini';

  final List<String> _taxTypes = ['Semua Pajak', 'Pajak PBB', 'Pajak Lainnya'];
  final List<String> _periods = ['Bulan Ini', '3 Bulan Terakhir', '6 Bulan Terakhir', 'Tahun Ini'];

  void _showFilterSheet(String title, List<String> options, String currentValue, Function(String) onSelected) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ...options.map((option) => ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                title: Text(
                  option,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: option == currentValue ? FontWeight.w700 : FontWeight.w500,
                    color: option == currentValue ? AppColors.primaryDark : AppColors.textPrimary,
                  ),
                ),
                trailing: option == currentValue ? const Icon(Icons.check, color: AppColors.primaryDark) : null,
                onTap: () {
                  onSelected(option);
                  Navigator.pop(context);
                },
              )),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final taxProvider = context.watch<TaxProvider>();
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    
    // Filter logic
    final now = DateTime.now();
    DateTime cutoffDate;
    
    if (_selectedPeriod == 'Bulan Ini') {
      cutoffDate = DateTime(now.year, now.month, 1);
    } else if (_selectedPeriod == '3 Bulan Terakhir') {
      cutoffDate = DateTime(now.year, now.month - 3, 1);
    } else if (_selectedPeriod == '6 Bulan Terakhir') {
      cutoffDate = DateTime(now.year, now.month - 6, 1);
    } else { // Tahun Ini
      cutoffDate = DateTime(now.year, 1, 1);
    }

    List<TaxTransaction> filteredHistory = taxProvider.history.where((tx) {
      bool passType = true;
      if (_selectedTaxType == 'Pajak PBB') {
        // Backend kirim tax_type_label: "PBB-P2" untuk semua jenis PBB
        passType = tx.title.toUpperCase().contains('PBB');
      } else if (_selectedTaxType == 'Pajak Lainnya') {
        passType = !tx.title.toUpperCase().contains('PBB');
      }
      
      bool passDate = tx.date.isAfter(cutoffDate);
      return passType && passDate;
    }).toList();

    // Calculate total spending for the selected filter
    final double totalSpending = filteredHistory
        .where((tx) => tx.isSuccess)
        .fold(0, (sum, tx) => sum + tx.amount);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFFC4E0F4), // Light blue to match Home
        ),
        child: Stack(
          children: [
            Positioned(
              top: 40,
              right: -20,
              child: Image.asset(
                'assets/images/illustration.png',
                height: 180,
                fit: BoxFit.contain,
              ),
            ),
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            if (Navigator.of(context).canPop())
                              GestureDetector(
                                onTap: () => context.pop(),
                                child: const Padding(
                                  padding: EdgeInsets.only(right: 16),
                                  child: Icon(Icons.arrow_back, color: AppColors.primaryDark),
                                ),
                              ),
                            Text(
                              'Riwayat',
                              style: GoogleFonts.lora(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Content
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: AppColors.bgWhite,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                      ),
                      child: Column(
                        children: [
                          // Spending summary
                          Container(
                            margin: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.primaryDark,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryDark.withValues(alpha: 0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Pengeluaran ($_selectedPeriod)',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: Colors.white70,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      currencyFormatter.format(totalSpending),
                                      style: GoogleFonts.inter(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.account_balance_wallet, color: Colors.white),
                                ),
                              ],
                            ),
                          ),

                          // Filters
                          Padding(
                            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => _showFilterSheet('Pilih Jenis Pajak', _taxTypes, _selectedTaxType, (val) => setState(() => _selectedTaxType = val)),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Jenis Pajak', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
                                        const SizedBox(height: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                          decoration: BoxDecoration(
                                            border: Border.all(color: AppColors.textHint.withValues(alpha: 0.3)),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(_selectedTaxType, style: GoogleFonts.inter(fontSize: 13, color: AppColors.primaryDark)),
                                              const Icon(Icons.keyboard_arrow_down, color: AppColors.textHint, size: 18),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => _showFilterSheet('Pilih Periode', _periods, _selectedPeriod, (val) => setState(() => _selectedPeriod = val)),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Periode', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
                                        const SizedBox(height: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                          decoration: BoxDecoration(
                                            border: Border.all(color: AppColors.textHint.withValues(alpha: 0.3)),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Icon(Icons.calendar_today_outlined, color: AppColors.textHint, size: 14),
                                              const SizedBox(width: 6),
                                              Expanded(child: Text(_selectedPeriod, style: GoogleFonts.inter(fontSize: 13, color: AppColors.primaryDark), overflow: TextOverflow.ellipsis)),
                                              const Icon(Icons.keyboard_arrow_down, color: AppColors.textHint, size: 18),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Expanded(
                            child: RefreshIndicator(
                              color: AppColors.primaryDark,
                              onRefresh: () => context.read<TaxProvider>().refreshDashboard(),
                              child: filteredHistory.isEmpty 
                                ? SingleChildScrollView(
                                    physics: const AlwaysScrollableScrollPhysics(),
                                    child: SizedBox(
                                      height: MediaQuery.of(context).size.height * 0.5,
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.history_outlined, size: 64, color: AppColors.textHint),
                                            const SizedBox(height: 16),
                                            Text(
                                              'Belum Ada Riwayat',
                                              style: GoogleFonts.inter(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Pembayaran yang berhasil\nakan muncul di sini.',
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.inter(
                                                fontSize: 14,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                    physics: const AlwaysScrollableScrollPhysics(),
                                    padding: const EdgeInsets.symmetric(horizontal: 24),
                                    itemCount: filteredHistory.length + 1, // +1 for the info footer
                                    itemBuilder: (context, index) {
                                      if (index == filteredHistory.length) {
                                        return Container(
                                          margin: const EdgeInsets.only(top: 16, bottom: 32),
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: AppColors.bgBlueLight,
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.info_outline, color: AppColors.primaryBlue, size: 20),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Text(
                                                  'Menampilkan riwayat pembayaran\nuntuk periode terpilih.',
                                                  style: GoogleFonts.inter(
                                                    fontSize: 12,
                                                    color: AppColors.primaryBlue,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }

                                      final item = filteredHistory[index];
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          if (index == 0 || filteredHistory[index].date.month != filteredHistory[index-1].date.month)
                                            _buildMonthGroup(DateFormat('MMMM yyyy', 'id_ID').format(item.date)),
                                          _buildHistoryItem(
                                            item: item,
                                            formatter: currencyFormatter,
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildMonthGroup(String month) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: Text(
        month,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.textLight,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildHistoryItem({
    required TaxTransaction item,
    required NumberFormat formatter,
  }) {
    final config = TaxConfigManager.getDetailConfig(item.title);

    return GestureDetector(
      onTap: () {
        if (item.isPending) {
          context.read<TaxProvider>().inspectTransaction(item);
          context.push('/await-payment');
          return;
        }
        if (item.isSuccess) {
          context.push('/receipt', extra: item.id);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: config.color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(config.icon, color: config.color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 2),
                // Tampilkan nama objek pajak jika ada
                if (item.namaObjek.isNotEmpty && item.namaObjek != '-')
                  Text(
                    item.namaObjek,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryDark.withValues(alpha: 0.7),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 2),
                Text(
                  item.bankName,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('dd MMM yyyy • HH:mm', 'id_ID').format(item.date),
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (item.isSuccess
                          ? AppColors.successLight
                          : item.isPending
                              ? AppColors.warningLight
                              : AppColors.dangerLight)
                      .withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  item.statusLabel,
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: item.isSuccess
                        ? AppColors.success
                        : item.isPending
                            ? AppColors.warning
                            : AppColors.danger,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                formatter.format(item.amount),
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark,
                ),
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }
}
