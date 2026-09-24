import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../constants/colors.dart';
import '../providers/tax_provider.dart';

class NpwpdDetailScreen extends StatelessWidget {
  final String taxComponentLabel;

  const NpwpdDetailScreen({super.key, required this.taxComponentLabel});

  @override
  Widget build(BuildContext context) {
    final taxProvider = context.watch<TaxProvider>();
    final npwpdData = taxProvider.npwpdData;
    
    if (npwpdData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Pajak')),
        body: const Center(child: Text('Data NPWPD tidak ditemukan')),
      );
    }

    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final taxBills = npwpdData.bills.where((b) {
      final api = b.taxComponentLabel.toLowerCase().replaceAll('pajak ', '').replaceAll('pbjt ', '').replaceAll(' ', '');
      final title = taxComponentLabel.toLowerCase().replaceAll('pajak ', '').replaceAll('pbjt ', '').replaceAll(' ', '');
      if (api == title) return true;
      if (title.contains('makanan') && (api.contains('restoran') || api.contains('makanan'))) return true;
      if (title.contains('listrik') && (api.contains('penerangan') || api.contains('listrik'))) return true;
      if (title.contains('mineral') && (api.contains('mineral') || api.contains('logam'))) return true;
      if (title.contains('hiburan') && api.contains('hiburan')) return true;
      if (title.contains('hotel') && api.contains('hotel')) return true;
      if (title.contains('parkir') && api.contains('parkir')) return true;
      if (title.contains('reklame') && api.contains('reklame')) return true;
      if (title.contains('airtanah') && (api.contains('airtanah') || api.contains('air'))) return true;
      if (title.contains('walet') && (api.contains('walet') || api.contains('burung'))) return true;
      return false;
    }).toList();
    final unpaidBills = taxBills.where((b) => !b.isPaid).toList();
    final hasUnpaid = unpaidBills.isNotEmpty;


    return Scaffold(
      backgroundColor: AppColors.bgWhite,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new, size: 16, color: AppColors.primaryDark),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Detail $taxComponentLabel',
                      style: GoogleFonts.lora(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        fontStyle: FontStyle.italic,
                        color: AppColors.primaryDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Info NPWPD Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primaryBlue, AppColors.primaryDark],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryBlue.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'NPWPD',
                                style: GoogleFonts.inter(color: Colors.white70, fontSize: 12),
                              ),
                              if (npwpdData.isVerified)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.verified, color: Colors.white, size: 12),
                                      const SizedBox(width: 4),
                                      Text('Terverifikasi', style: GoogleFonts.inter(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            npwpdData.npwpdNumber,
                            style: GoogleFonts.inter(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 16),
                          const Divider(color: Colors.white24, height: 1),
                          const SizedBox(height: 16),
                          _buildDetailRow('Nama Usaha', npwpdData.businessName),
                          const SizedBox(height: 8),
                          _buildDetailRow('Pemilik', npwpdData.ownerName),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Riwayat Tagihan',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryDark,
                          ),
                        ),
                        if (hasUnpaid)
                          Text(
                            '${unpaidBills.length} Belum Dibayar',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.warning,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    if (taxBills.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: Text(
                            'Belum ada tagihan untuk jenis pajak ini.',
                            style: GoogleFonts.inter(color: AppColors.textHint),
                          ),
                        ),
                      )
                    else
                      ...taxBills.map((bill) {
                        final isPaid = bill.isPaid;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: (isPaid ? AppColors.success : AppColors.warning).withValues(alpha: 0.3),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: (isPaid ? AppColors.success : AppColors.warning).withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Periode ${bill.taxPeriod}',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: isPaid ? AppColors.success : AppColors.warning,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        isPaid ? Icons.check_circle : Icons.access_time_filled,
                                        size: 14,
                                        color: isPaid ? AppColors.success : AppColors.warning,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        bill.statusLabel,
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: isPaid ? AppColors.success : AppColors.warning,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total Tagihan',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    currencyFormatter.format(bill.totalAmount),
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primaryDark,
                                    ),
                                  ),
                                ],
                              ),
                              if (bill.penalty > 0) ...[
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Denda',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: AppColors.warning,
                                      ),
                                    ),
                                    Text(
                                      currencyFormatter.format(bill.penalty),
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.warning,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              
                              if (!isPaid) ...[
                                const SizedBox(height: 16),
                                const Divider(height: 1),
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      // Push to tax detail or directly to payment
                                      // Using /detail with bill.id to go directly to payment detail
                                      context.push('/detail', extra: bill.id);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryBlue,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Text(
                                      'Bayar Tagihan Ini',
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ] else if (isPaid) ...[
                                const SizedBox(height: 16),
                                const Divider(height: 1),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton.icon(
                                    onPressed: () {
                                      // Prioritas 1: cocokkan berdasarkan billId (id_bills)
                                      TaxTransaction? target = taxProvider.history.cast<TaxTransaction?>().firstWhere(
                                        (t) => t?.billId != null && t!.billId == bill.id,
                                        orElse: () => null,
                                      );
                                      // Prioritas 2: cocokkan berdasarkan taxPeriod + objectName
                                      target ??= taxProvider.history.cast<TaxTransaction?>().firstWhere(
                                        (t) =>
                                            t?.title.toUpperCase().contains('PBB') == false &&
                                            t?.namaObjek == npwpdData.businessName &&
                                            t?.taxPeriod != null && t!.taxPeriod == bill.taxPeriod,
                                        orElse: () => null,
                                      );
                                      // Prioritas 3: fallback by objectName
                                      target ??= taxProvider.history.cast<TaxTransaction?>().firstWhere(
                                        (t) =>
                                            t?.title.toUpperCase().contains('PBB') == false &&
                                            t?.namaObjek == npwpdData.businessName,
                                        orElse: () => null,
                                      );
                                      
                                      if (target != null) {
                                        context.push('/receipt', extra: target.id);
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Bukti pembayaran tidak ditemukan')),
                                        );
                                      }
                                    },
                                    icon: const Icon(Icons.receipt_long_outlined, size: 16),
                                    label: Text('Lihat Bukti', style: GoogleFonts.inter(fontSize: 12)),
                                    style: TextButton.styleFrom(foregroundColor: AppColors.primaryBlue),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      }),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.inter(color: Colors.white70, fontSize: 13)),
        Text(value, style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
