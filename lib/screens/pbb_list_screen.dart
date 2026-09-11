import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../constants/colors.dart';
import '../providers/tax_provider.dart';

class PbbListScreen extends StatelessWidget {
  const PbbListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final taxProvider = context.watch<TaxProvider>();
    final nopList = taxProvider.nopData;

    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primaryDark, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Daftar PBB Anda',
          style: GoogleFonts.lora(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            fontStyle: FontStyle.italic,
            color: AppColors.primaryDark,
          ),
        ),
        centerTitle: true,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(color: Colors.white),
        child: SafeArea(
          child: nopList.isEmpty
              ? RefreshIndicator(
                  onRefresh: () => taxProvider.refreshDashboard(),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.8,
                      child: _buildEmptyState(context),
                    ),
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 4),
                      child: Text(
                        'Objek Pajak Terdaftar',
                        style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primaryDark),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                      child: Text(
                        'Ketuk objek untuk melihat rincian & status tagihan per periode',
                        style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () => taxProvider.refreshDashboard(),
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                          itemCount: nopList.length,
                          itemBuilder: (context, index) {
                            final nop = nopList[index];
                            final hasUnpaid = nop.hasUnpaid;
                            final noBills = nop.bills.isEmpty;

                            // Status label & warna
                            String statusText;
                            Color statusColor;
                            IconData statusIcon;
                            if (noBills) {
                              statusText = 'Tidak Ada Tagihan';
                              statusColor = AppColors.textHint;
                              statusIcon = Icons.info_outline;
                            } else if (hasUnpaid) {
                              statusText = '${nop.unpaidBills.length} Belum Dibayar';
                              statusColor = AppColors.warning;
                              statusIcon = Icons.access_time;
                            } else {
                              statusText = 'Semua Lunas';
                              statusColor = AppColors.success;
                              statusIcon = Icons.check_circle;
                            }

                            return InkWell(
                              onTap: () => context.push('/pbb-detail/${nop.nopNumber}'),
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 14),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Header: ikon + nama + status
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: const Icon(Icons.home_work, color: Colors.blue, size: 24),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                nop.objectName,
                                                style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primaryDark),
                                              ),
                                              const SizedBox(height: 3),
                                              Text(
                                                'NOP: ${nop.nopNumber}',
                                                style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: statusColor.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(statusIcon, size: 11, color: statusColor),
                                              const SizedBox(width: 3),
                                              Text(statusText, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: statusColor)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),

                                    // Ringkasan periode tagihan
                                    if (nop.bills.isNotEmpty) ...[
                                      const SizedBox(height: 12),
                                      const Divider(height: 1),
                                      const SizedBox(height: 12),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 6,
                                        children: nop.bills.map((bill) {
                                          final paid = bill.isPaid;
                                          return Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                            decoration: BoxDecoration(
                                              color: (paid ? AppColors.success : AppColors.warning).withValues(alpha: 0.08),
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: (paid ? AppColors.success : AppColors.warning).withValues(alpha: 0.3)),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(paid ? Icons.check_circle : Icons.radio_button_unchecked, size: 12, color: paid ? AppColors.success : AppColors.warning),
                                                const SizedBox(width: 5),
                                                Text(
                                                  '${bill.taxPeriod}  ${currencyFormatter.format(bill.totalAmount)}',
                                                  style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: paid ? AppColors.success : AppColors.warning),
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ],

                                    // Footer: total belum bayar + chevron
                                    if (hasUnpaid) ...[
                                      const SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('Total Belum Dibayar', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary)),
                                              Text(
                                                currencyFormatter.format(nop.totalUnpaid),
                                                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.primaryDark),
                                              ),
                                            ],
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                            decoration: BoxDecoration(
                                              color: AppColors.primaryDark,
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Text('Bayar', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                                          ),
                                        ],
                                      ),
                                    ] else ...[
                                      const SizedBox(height: 8),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text('Lihat Detail', style: GoogleFonts.inter(fontSize: 12, color: AppColors.primaryBlue, fontWeight: FontWeight.w600)),
                                            const SizedBox(width: 4),
                                            const Icon(Icons.chevron_right, size: 16, color: AppColors.primaryBlue),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
      floatingActionButton: nopList.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () {
                final encodedTitle = Uri.encodeComponent('Pajak PBB');
                context.push('/check-tax/$encodedTitle');
              },
              backgroundColor: AppColors.primaryDark,
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text('Tambah NOP', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white)),
            )
          : null,
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.home_work_outlined, size: 80, color: AppColors.textHint.withValues(alpha: 0.5)),
            const SizedBox(height: 24),
            Text('Belum Ada PBB Terdaftar', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.primaryDark)),
            const SizedBox(height: 12),
            Text(
              'Anda belum mendaftarkan Nomor Objek Pajak (NOP) PBB. Silakan daftarkan terlebih dahulu.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary, height: 1.5),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  final encodedTitle = Uri.encodeComponent('Pajak PBB');
                  context.push('/check-tax/$encodedTitle');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text('Daftarkan NOP PBB', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

