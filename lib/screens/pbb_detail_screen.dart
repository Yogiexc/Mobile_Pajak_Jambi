import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../constants/colors.dart';
import '../providers/tax_provider.dart';

class PbbDetailScreen extends StatelessWidget {
  final String nopNumber;
  const PbbDetailScreen({super.key, required this.nopNumber});

  @override
  Widget build(BuildContext context) {
    final taxProvider = context.watch<TaxProvider>();
    final nopData = taxProvider.nopData.cast<NopData?>().firstWhere(
      (n) => n?.nopNumber == nopNumber,
      orElse: () => null,
    );

    if (nopData == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primaryDark, size: 20),
            onPressed: () => context.pop(),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: const Center(child: Text('Data NOP tidak ditemukan')),
      );
    }

    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final dateFormat = DateFormat('dd MMM yyyy', 'id_ID');
    final pendingBillsForNop = taxProvider.pendingBills
        .where((b) => b.taxId == nopNumber && b.title == 'Pajak PBB')
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primaryDark, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Detail Objek PBB',
          style: GoogleFonts.lora(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontStyle: FontStyle.italic,
            color: AppColors.primaryDark,
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () => taxProvider.refreshDashboard(),
        color: AppColors.primaryDark,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Kartu Info Objek
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 16, offset: const Offset(0, 6))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
                          child: const Icon(Icons.home_work, color: Colors.blue, size: 28),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(nopData.objectName, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primaryDark)),
                              const SizedBox(height: 4),
                              Text('NOP: ${nopData.nopNumber}', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                        if (nopData.isVerified)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.verified, size: 12, color: AppColors.success),
                                const SizedBox(width: 4),
                                Text('Terverifikasi', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.success)),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    _infoRow(Icons.person_outline, 'Pemilik', nopData.ownerName),
                    const SizedBox(height: 6),
                    _infoRow(Icons.location_on_outlined, 'Alamat', nopData.objectAddress),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Banner tagihan belum bayar
              if (nopData.hasUnpaid) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8F0),
                    border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${nopData.unpaidBills.length} Tagihan Belum Dibayar', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primaryDark)),
                            Text('Total: ${currencyFormatter.format(nopData.totalUnpaid)}', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Riwayat semua periode
              Text('Riwayat Tagihan per Periode', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primaryDark)),
              const SizedBox(height: 10),

              if (nopData.bills.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                  child: Center(child: Text('Belum ada tagihan untuk objek ini', style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary))),
                )
              else
                ...nopData.bills.map((bill) {
                  final isPaid = bill.isPaid;
                  final pendingBill = pendingBillsForNop.cast<TaxBill?>().firstWhere(
                    (b) => b?.id == bill.id,
                    orElse: () => null,
                  );

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: (isPaid ? AppColors.success : AppColors.warning).withValues(alpha: 0.25)),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 3))],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(color: (isPaid ? AppColors.success : AppColors.warning).withValues(alpha: 0.1), shape: BoxShape.circle),
                                  child: Icon(
                                    isPaid ? Icons.check_circle_outline : Icons.access_time_outlined,
                                    size: 18,
                                    color: isPaid ? AppColors.success : AppColors.warning,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Periode ${bill.taxPeriod}', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primaryDark)),
                                    Text(
                                      'Jatuh tempo: ${dateFormat.format(bill.dueDate)}',
                                      style: GoogleFonts.inter(fontSize: 11, color: (bill.isOverdue && !isPaid) ? Colors.red : AppColors.textSecondary),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: (isPaid ? AppColors.success : AppColors.warning).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                              child: Text(bill.statusLabel, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: isPaid ? AppColors.success : AppColors.warning)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(height: 1),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (bill.penalty > 0) ...[
                                  Text('Pokok: ${currencyFormatter.format(bill.amountDue)}', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary)),
                                  Text('Denda: ${currencyFormatter.format(bill.penalty)}', style: GoogleFonts.inter(fontSize: 11, color: Colors.red)),
                                ],
                                Text(
                                  currencyFormatter.format(bill.totalAmount),
                                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: isPaid ? AppColors.success : AppColors.primaryDark),
                                ),
                              ],
                            ),
                            if (!isPaid && pendingBill != null)
                              ElevatedButton(
                                onPressed: () {
                                  context.push('/tax-detail');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryDark,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  elevation: 0,
                                ),
                                child: Text('Bayar Sekarang', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700)),
                              )
                            else if (isPaid)
                              TextButton.icon(
                                onPressed: () {
                                  final tx = taxProvider.history.cast<TaxTransaction?>().firstWhere(
                                    (t) => t?.title.toUpperCase().contains('PBB') == true && t?.namaObjek == nopData.objectName,
                                    orElse: () => null,
                                  );
                                  if (tx != null) context.push('/receipt', extra: tx.id);
                                },
                                icon: const Icon(Icons.receipt_long_outlined, size: 16),
                                label: Text('Lihat Bukti', style: GoogleFonts.inter(fontSize: 12)),
                                style: TextButton.styleFrom(foregroundColor: AppColors.primaryBlue),
                              ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Text('$label: ', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
        Expanded(child: Text(value, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryDark))),
      ],
    );
  }
}
