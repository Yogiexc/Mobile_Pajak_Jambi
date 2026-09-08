import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../constants/payment_options.dart';
import '../providers/tax_provider.dart';

class PaymentMethodScreen extends StatefulWidget {
  final String? billId;
  const PaymentMethodScreen({super.key, this.billId});

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  int? _selectedPaymentId;
  String _selectedName = '';
  String _paymentChannel = '';
  String? _bankCode;

  void _selectChannel({
    required String name,
    required String channel,
    String? bankCode,
    int? paymentId,
  }) {
    setState(() {
      _selectedName = name;
      _paymentChannel = channel;
      _bankCode = bankCode;
      _selectedPaymentId = paymentId;
    });
  }

  @override
  Widget build(BuildContext context) {
    final banks = context.watch<TaxProvider>().linkedBanks;
    final canContinue = _paymentChannel.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primaryDark, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Pilih Metode Pembayaran',
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
        color: Colors.white,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      Text(
                        'METODE TERSIMPAN',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (banks.isEmpty)
                        Text(
                          'Belum ada metode tersimpan. Pilih bank atau QRIS di bawah.',
                          style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ...banks.map((bank) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildMethodCard(
                              name: bank.name,
                              subtitle: bank.number,
                              icon: bank.type == 'qris' ? Icons.qr_code_2 : Icons.account_balance,
                              selected: _selectedPaymentId == bank.id,
                              onTap: () => _selectChannel(
                                name: bank.name,
                                channel: bank.type,
                                bankCode: bank.type == 'qris' ? null : bank.provider,
                                paymentId: bank.id,
                              ),
                            ),
                          )),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: () => context.push('/linked-bank'),
                          child: Text(
                            'Kelola rekening',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'TRANSFER BANK',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...PaymentOptions.banks.map((bank) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildMethodCard(
                              name: bank.label,
                              subtitle: 'Virtual Account',
                              icon: Icons.account_balance,
                              selected: _selectedPaymentId == null &&
                                  _paymentChannel == 'bank_transfer' &&
                                  _bankCode == bank.code,
                              onTap: () => _selectChannel(
                                name: bank.label,
                                channel: 'bank_transfer',
                                bankCode: bank.code,
                              ),
                            ),
                          )),
                      Text(
                        'LAINNYA',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildMethodCard(
                        name: 'QRIS',
                        subtitle: 'Scan & bayar',
                        icon: Icons.qr_code_2,
                        selected: _selectedPaymentId == null && _paymentChannel == 'qris',
                        onTap: () => _selectChannel(
                          name: 'QRIS',
                          channel: 'qris',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: canContinue
                        ? () {
                            context.push('/summary', extra: {
                              'billId': widget.billId,
                              'paymentId': _selectedPaymentId,
                              'bankName': _selectedName,
                              'isQris': _paymentChannel == 'qris',
                              'paymentChannel': _paymentChannel,
                              'bankCode': _bankCode,
                            });
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: canContinue
                          ? AppColors.primaryDark
                          : Colors.grey.withValues(alpha: 0.5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Lanjut',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMethodCard({
    required String name,
    required String subtitle,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.primaryDark : AppColors.textHint.withValues(alpha: 0.3),
            width: selected ? 2 : 1,
          ),
          boxShadow: [
            if (selected)
              BoxShadow(
                color: AppColors.primaryDark.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.bgBlueLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.primaryBlue, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? AppColors.primaryDark : AppColors.textHint,
                  width: 2,
                ),
              ),
              child: selected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
