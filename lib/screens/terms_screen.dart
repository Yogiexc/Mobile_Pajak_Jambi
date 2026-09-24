import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/colors.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primaryDark, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Ketentuan Layanan',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryDark,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ketentuan Layanan',
                style: GoogleFonts.lora(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.italic,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Berlaku efektif sejak: 1 Januari 2024',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              _buildHeading('1. Persetujuan'),
              _buildParagraph('Dengan mengunduh, mengakses, dan menggunakan aplikasi Mobile Pajak Jambi, Anda setuju untuk terikat dengan syarat dan ketentuan ini.'),
              _buildHeading('2. Akun Pengguna'),
              _buildParagraph('Anda bertanggung jawab penuh atas kerahasiaan akun dan kata sandi Anda. Semua transaksi yang dilakukan melalui akun Anda dianggap sebagai tanggung jawab Anda sepenuhnya.'),
              _buildHeading('3. Pembayaran Pajak'),
              _buildParagraph('Layanan ini memfasilitasi pembayaran pajak daerah. Pembayaran dianggap sah jika telah divalidasi oleh sistem perbankan dan terekam di sistem pemerintah daerah Kota Jambi.'),
              _buildHeading('4. Gangguan Layanan'),
              _buildParagraph('Kami berusaha memberikan layanan terbaik 24/7. Namun, kami tidak bertanggung jawab atas keterlambatan atau kegagalan sistem yang disebabkan oleh pemeliharaan jaringan, gangguan koneksi internet, atau hal-hal di luar kendali kami.'),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeading(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryDark,
        ),
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 14,
        color: AppColors.textSecondary,
        height: 1.6,
      ),
    );
  }
}
