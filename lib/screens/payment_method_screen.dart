import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../providers/tax_provider.dart';

class PaymentMethodScreen extends StatefulWidget {
  final String? billId;
  const PaymentMethodScreen({super.key, this.billId});

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  int? _selectedId;
  String? _selectedName;
  bool _isQris = false;
  bool _busy = false;

  Future<void> _selectPreset(String name, String type) async {
    setState(() => _busy = true);
    try {
      final method = await context.read<TaxProvider>().ensurePaymentMethod(
        provider: name,
        type: type,
        maskedNumber: type == 'qris' ? 'QRIS' : null,
      );
      if (!mounted) return;
      setState(() {
        _selectedId = method.id;
        _selectedName = method.name;
        _isQris = method.type == 'qris';
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final banks = context.watch<TaxProvider>().linkedBanks;

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
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: SafeArea(
          child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                  selected: _selectedId == bank.id,
                  onTap: () {
                    setState(() {
                      _selectedId = bank.id;
                      _selectedName = bank.name;
                      _isQris = bank.type == 'qris';
                    });
                  },
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
              const SizedBox(height: 16),
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
                selected: _isQris && _selectedName == 'QRIS',
                onTap: () => _selectPreset('QRIS', 'qris'),
              ),
              const SizedBox(height: 12),
              _buildMethodCard(
                name: 'Mandiri',
                subtitle: 'Transfer bank',
                icon: Icons.account_balance,
                selected: !_isQris && _selectedName == 'Mandiri',
                onTap: () => _selectPreset('Mandiri', 'bank_transfer'),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _busy || _selectedId == null
                      ? null
                      : () {
                          context.push('/summary', extra: {
                            'billId': widget.billId,
                            'paymentId': _selectedId,
                            'bankName': _selectedName,
                            'isQris': _isQris,
                          });
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedId != null ? AppColors.primaryDark : Colors.grey.withValues(alpha: 0.5),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _busy
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
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
