import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../providers/tax_provider.dart';
import '../api/api_exception.dart';

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
    final paymentId = args['paymentId'] as int?;
    final bankName = args['bankName'] as String? ?? '-';
    final isQris = args['isQris'] as bool? ?? false;
    final pin = args['pin'] as String? ?? '';

    try {
      if (billId == null || paymentId == null) {
        throw const ApiException('Metode pembayaran belum dipilih.');
      }
      await context.read<TaxProvider>().payBill(
        billId: billId,
        paymentId: paymentId,
        pin: pin,
        bankName: bankName,
        isQris: isQris,
      );
      if (!mounted) return;
      context.go('/success');
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
