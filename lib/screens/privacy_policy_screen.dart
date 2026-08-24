import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
          'Kebijakan Privasi',
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
                'Kebijakan Privasi',
                style: GoogleFonts.lora(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.italic,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Pembaruan Terakhir: 23 Agustus 2026',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              _buildParagraph('Kami di Mobile Pajak Jambi sangat menjaga privasi dan keamanan data pengguna. Kebijakan Privasi ini menjelaskan bagaimana kami mengumpulkan, menggunakan, dan melindungi informasi pribadi Anda saat menggunakan aplikasi ini.'),
              _buildHeading('1. Pengumpulan Informasi'),
              _buildParagraph('Kami mengumpulkan informasi pribadi yang Anda berikan secara langsung saat mendaftar akun, seperti NIK, alamat email, dan Nomor Pokok Wajib Pajak Daerah (NPWPD) atau Nomor Objek Pajak (NOP).'),
              _buildHeading('2. Penggunaan Informasi'),
              _buildParagraph('Informasi yang dikumpulkan digunakan semata-mata untuk keperluan administrasi perpajakan daerah, memproses pembayaran, dan memberikan layanan serta pemberitahuan terkait tagihan pajak Anda.'),
              _buildHeading('3. Keamanan Data'),
              _buildParagraph('Kami menerapkan langkah-langkah keamanan teknis untuk mencegah akses, perubahan, atau pengungkapan yang tidak sah terhadap data pribadi Anda.'),
              _buildHeading('4. Berbagi Informasi'),
              _buildParagraph('Kami tidak akan menjual atau menyewakan informasi pribadi Anda kepada pihak ketiga. Data Anda hanya dibagikan dengan instansi pemerintah daerah terkait sesuai hukum yang berlaku.'),
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
