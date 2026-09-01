import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../providers/tax_provider.dart';

class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tx = context.watch<TaxProvider>().lastTransaction;
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final dateFormat = DateFormat('dd MMMM yyyy • HH:mm', 'id_ID');

    return Scaffold(
      backgroundColor: AppColors.bgWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                 width: 64,
                 height: 64,
                 decoration: BoxDecoration(
                   color: AppColors.success,
                   shape: BoxShape.circle,
                   boxShadow: [
                     BoxShadow(
                       color: AppColors.success.withValues(alpha: 0.3),
                       blurRadius: 16,
                       offset: const Offset(0, 8),
                     ),
                   ],
                 ),
                 child: const Icon(Icons.check, color: Colors.white, size: 32),
               ),
               const SizedBox(height: 24),
              Text(
                'Pembayaran Berhasil',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                currencyFormatter.format(tx?.amount ?? 0),
                style: GoogleFonts.lora(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                tx?.title ?? 'Pajak Daerah',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),
              _buildDetailColumn(
                'Tanggal',
                tx == null ? '-' : dateFormat.format(tx.date),
              ),
              const SizedBox(height: 24),
              _buildDetailColumn(
                'ID Transaksi',
                tx?.transactionRef.isNotEmpty == true
                    ? tx!.transactionRef
                    : (tx?.id ?? '-'),
              ),
              const SizedBox(height: 24),
              _buildDetailColumn('Metode Pembayaran', tx?.bankName ?? '-'),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    context.go('/receipt', extra: tx?.id ?? '');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Lihat Bukti Pembayaran',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.go('/home'),
                child: Text(
                  'Kembali ke Beranda',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryDark,
          ),
        ),
      ],
    );
  }
}
