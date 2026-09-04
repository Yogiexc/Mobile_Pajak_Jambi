import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../constants/colors.dart';
import '../constants/tax_config.dart';
import '../providers/tax_provider.dart';

class SummaryScreen extends StatelessWidget {
  final String? billId;
  final int? paymentId;
  final String bankName;
  final bool isQris;

  const SummaryScreen({
    super.key,
    this.billId,
    this.paymentId,
    this.bankName = 'Mandiri',
    this.isQris = false,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    // Get bill from provider
    final taxProvider = context.watch<TaxProvider>();
    final bill = taxProvider.pendingBills.cast<TaxBill?>().firstWhere(
      (b) => b?.id == billId, 
      orElse: () => taxProvider.pendingBills.isNotEmpty ? taxProvider.pendingBills.first : null
    );

    if (bill == null) {
      return Scaffold(
        backgroundColor: AppColors.bgWhite,
        appBar: AppBar(backgroundColor: AppColors.bgWhite, elevation: 0),
        body: const Center(child: Text('Tagihan tidak ditemukan')),
      );
    }
    
    final config = TaxConfigManager.getDetailConfig(bill.title);
    final shortLabel = config.inputLabel.split('(').first.trim();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primaryDark, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Ringkasan Pembayaran',
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
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: SafeArea(
          child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bill.title,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildRow('Nama Wajib Pajak', taxProvider.userName ?? 'Pengguna'),
                    const SizedBox(height: 16),
                    _buildRow(shortLabel, bill.taxId),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(color: Color(0xFFF3F4F6), height: 1),
                    ),
                    _buildRow('Tagihan', currencyFormatter.format(bill.amount)),
                    const SizedBox(height: 16),
                    _buildRow('Denda', 'Rp 0'),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(color: Color(0xFFF3F4F6), height: 1),
                    ),
                    _buildRow('Total Bayar', currencyFormatter.format(bill.amount), isBold: true),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Bank Info Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.bgBlueLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        isQris ? Icons.qr_code_2 : Icons.account_balance,
                        color: AppColors.primaryBlue,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bankName,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryDark,
                            ),
                          ),
                          Text(
                            'Metode pembayaran',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.pop(),
                      child: Text(
                        'Ubah',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const Spacer(),
              
              // Pay Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    context.push('/pin', extra: {
                      'billId': bill.id,
                      'paymentId': paymentId,
                      'bankName': bankName,
                      'isQris': isQris,
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Bayar Sekarang - ${currencyFormatter.format(bill.amount)}',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Dengan membayar, kamu menyetujui\nSyarat & Ketentuan Lunas.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w500,
            color: isBold ? AppColors.primaryDark : AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
            color: AppColors.primaryDark,
          ),
        ),
      ],
    );
  }
}
