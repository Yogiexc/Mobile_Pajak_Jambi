import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/colors.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE8F1F8),
              Color(0xFF98C5E7),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 50),
              // Actual Logo from Figma
              Column(
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    height: 80,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'PEMERINTAH\nKOTA JAMBI',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Title
              Text(
                'Bayar Pajak,\nBangun Jambi',
                textAlign: TextAlign.center,
                style: GoogleFonts.lora(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.italic,
                  color: AppColors.primaryDark,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Untuk Jambi yang Maju',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              
              // Actual Illustration from Figma (Flexible to avoid overflow)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Image.asset(
                    'assets/images/illustration.png',
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              
              // Button (overlaps slightly or sits just below)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24).copyWith(bottom: 40, top: 16),
                child: Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: AppColors.buttonGradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.yellowDark.withValues(alpha: 0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () => context.go('/login'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Mulai',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
