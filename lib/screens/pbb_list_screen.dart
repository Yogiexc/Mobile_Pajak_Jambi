import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
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
          child: taxProvider.isLoading
              ? _buildShimmerLoading(context)
              : nopList.isEmpty
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
                          padding: const EdgeInsets.fromLTRB(20, 4, 20, 96),
                          itemCount: nopList.length,
                          itemBuilder: (context, index) {
                            return _NopCard(
                              nop: nopList[index],
                              currencyFormatter: currencyFormatter,
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
            Image.asset(
              'assets/images/MaskotAngsaJambi_CariData.png',
              height: 120,
              errorBuilder: (context, error, stackTrace) =>
                  Icon(Icons.home_work_outlined, size: 80, color: AppColors.textHint.withValues(alpha: 0.5)),
            ),
            const SizedBox(height: 24),
            Text('Belum Ada PBB Terdaftar', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.primaryDark)),
            const SizedBox(height: 12),
            Text(
              'Ayo daftarkan Nomor Objek Pajak (NOP) PBB kamu sekarang!',
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

  Widget _buildShimmerLoading(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 4),
            child: Container(width: 200, height: 24, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
            child: Container(width: 300, height: 16, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
              itemCount: 4,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  height: 120, // Approximate height of the card
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _NopCard extends StatelessWidget {
  final NopData nop;
  final NumberFormat currencyFormatter;

  const _NopCard({
    required this.nop,
    required this.currencyFormatter,
  });

  @override
  Widget build(BuildContext context) {
    final hasUnpaid = nop.hasUnpaid;
    final noBills = nop.bills.isEmpty;

    final String statusText;
    final Color statusColor;
    final IconData statusIcon;
    if (noBills) {
      statusText = 'Tidak Ada Tagihan';
      statusColor = AppColors.textHint;
      statusIcon = Icons.info_outline;
    } else if (hasUnpaid) {
      statusText = '${nop.unpaidBills.length} Belum Dibayar';
      statusColor = AppColors.warning;
      statusIcon = Icons.circle_outlined;
    } else {
      statusText = 'Semua Lunas';
      statusColor = AppColors.success;
      statusIcon = Icons.check_circle;
    }

    final sortedBills = [...nop.bills]..sort((a, b) {
        final ay = int.tryParse(a.taxPeriod) ?? 0;
        final by = int.tryParse(b.taxPeriod) ?? 0;
        return by.compareTo(ay);
      });
    final bills = sortedBills.take(4).toList()
      ..sort((a, b) {
        final ay = int.tryParse(a.taxPeriod) ?? 0;
        final by = int.tryParse(b.taxPeriod) ?? 0;
        return ay.compareTo(by);
      });
    final hiddenCount = sortedBills.length - bills.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE6EBF1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push('/pbb-detail/${nop.nopNumber}'),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Hero(
                      tag: 'pbb_icon_${nop.nopNumber}',
                      child: Container(  
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F3FC),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.home_rounded, color: Color(0xFF3B82F6), size: 22),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nop.objectName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              height: 1.35,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'NOP: ${nop.nopNumber}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(statusIcon, size: 12, color: statusColor),
                                const SizedBox(width: 4),
                                Text(
                                  statusText,
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: statusColor,
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
                if (bills.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: Color(0xFFE8EDF2)),
                  const SizedBox(height: 12),
                  for (var i = 0; i < bills.length; i += 2) ...[
                    if (i > 0) const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: _PeriodChip(bill: bills[i], formatter: currencyFormatter)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: i + 1 < bills.length
                              ? _PeriodChip(bill: bills[i + 1], formatter: currencyFormatter)
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ],
                  if (hiddenCount > 0) ...[
                    const SizedBox(height: 10),
                    Text(
                      'Lihat $hiddenCount periode lainnya',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PeriodChip extends StatelessWidget {
  final NopBill bill;
  final NumberFormat formatter;

  const _PeriodChip({required this.bill, required this.formatter});

  @override
  Widget build(BuildContext context) {
    final paid = bill.isPaid;
    final color = paid ? AppColors.success : AppColors.warning;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            paid ? Icons.check_circle : Icons.circle_outlined,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              '${bill.taxPeriod}  ${formatter.format(bill.totalAmount)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

