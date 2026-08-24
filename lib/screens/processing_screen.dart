import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
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
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final billId = widget.paymentArgs['billId'] as String;
    final bankName = widget.paymentArgs['bankName'] as String;
    final isQris = widget.paymentArgs['isQris'] as bool;

    // Process payment in provider
    context.read<TaxProvider>().payBill(billId, bankName, isQris);

    // Go to success
    context.go('/success', extra: widget.paymentArgs);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
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
