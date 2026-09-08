import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../api/api_exception.dart';
import '../constants/colors.dart';
import '../providers/tax_provider.dart';

class ProcessingScreen extends StatefulWidget {
  final Map<String, dynamic> paymentArgs;

  const ProcessingScreen({super.key, required this.paymentArgs});

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> {
  @override
  void initState() {
    super.initState();
    _processPayment();
  }

  Future<void> _processPayment() async {
    final args = widget.paymentArgs;
    final billId = args['billId'] as String?;
    final paymentChannel = args['paymentChannel'] as String? ??
        ((args['isQris'] as bool? ?? false) ? 'qris' : 'bank_transfer');
    final bankCode = args['bankCode'] as String?;
    final paymentId = args['paymentId'] as int?;
    final bankName = args['bankName'] as String?;
    final pin = args['pin'] as String? ?? '';

    try {
      if (billId == null || billId.isEmpty) {
        throw const ApiException('Tagihan belum dipilih.');
      }
      if (paymentChannel == 'bank_transfer' && (bankCode == null || bankCode.isEmpty)) {
        throw const ApiException('Bank belum dipilih.');
      }
      final tx = await context.read<TaxProvider>().payBill(
        billId: billId,
        pin: pin,
        paymentChannel: paymentChannel,
        bankCode: bankCode,
        paymentId: paymentId,
        bankName: bankName,
      );
      if (!mounted) return;
      if (tx.isSuccess) {
        context.go('/success');
      } else {
        context.go('/await-payment');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgWhite,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppColors.primaryDark),
            const SizedBox(height: 24),
            Text(
              'Memproses Pembayaran...',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Mohon tunggu sebentar',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
