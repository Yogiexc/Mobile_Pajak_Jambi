import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/tax_provider.dart';
import '../constants/colors.dart';

class ForgotAuthScreen extends StatefulWidget {
  final String purpose; // 'reset_password' or 'reset_pin'

  const ForgotAuthScreen({super.key, required this.purpose});

  @override
  State<ForgotAuthScreen> createState() => _ForgotAuthScreenState();
}

class _ForgotAuthScreenState extends State<ForgotAuthScreen> {
  final _nikController = TextEditingController();
  String _selectedChannel = 'email'; // Default channel
  bool _isLoading = false;

  @override
  void dispose() {
    _nikController.dispose();
    super.dispose();
  }

  Future<void> _handleRequestOtp() async {
    if (_nikController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan NIK terlebih dahulu.'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await context.read<TaxProvider>().requestOtp(
        _nikController.text.trim(),
        widget.purpose,
        _selectedChannel,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kode OTP berhasil dikirim.'), backgroundColor: AppColors.success),
      );
      context.push('/otp-verification', extra: {
        'nik': _nikController.text.trim(),
        'purpose': widget.purpose,
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.purpose == 'reset_password' ? 'Lupa Kata Sandi' : 'Lupa PIN';
    final description = widget.purpose == 'reset_password' 
        ? 'Masukkan NIK Anda untuk mengatur ulang kata sandi.'
        : 'Masukkan NIK Anda untuk mengatur ulang PIN.';

    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16)),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              description,
              style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            Text(
              'Nomor Induk Kependudukan (NIK)',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nikController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Masukkan 16 digit NIK',
                hintStyle: GoogleFonts.inter(color: AppColors.textHint, fontSize: 14),
                filled: true,
                fillColor: AppColors.bgWhite,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Kirim Kode OTP via:',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: _selectedChannel == 'email' ? AppColors.primary : Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
                color: _selectedChannel == 'email' ? AppColors.primary.withValues(alpha: 0.05) : Colors.white,
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => setState(() => _selectedChannel = 'email'),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Icon(
                        _selectedChannel == 'email' ? Icons.radio_button_checked : Icons.radio_button_off,
                        color: _selectedChannel == 'email' ? AppColors.primary : Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Email', style: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 14)),
                            Text('Kirim ke email yang terdaftar', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: _selectedChannel == 'sms' ? AppColors.primary : Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
                color: _selectedChannel == 'sms' ? AppColors.primary.withValues(alpha: 0.05) : Colors.white,
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => setState(() => _selectedChannel = 'sms'),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Icon(
                        _selectedChannel == 'sms' ? Icons.radio_button_checked : Icons.radio_button_off,
                        color: _selectedChannel == 'sms' ? AppColors.primary : Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Nomor HP (SMS/WA)', style: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 14)),
                            Text('Kirim ke nomor HP yang terdaftar', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleRequestOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        'Kirim Kode OTP',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
