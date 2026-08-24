import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/colors.dart';
import '../utils/responsive.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.welcomeBg,
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxHeight < 700;
              return Column(
                children: [
              SizedBox(height: compact ? 24 : 50),
              Column(
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    height: compact ? 56 : context.sp(80),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'PEMERINTAH\nKOTA JAMBI',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: compact ? 9 : 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: compact ? 16 : 32),
              
              Text(
                'Bayar Pajak,\nBangun Jambi',
                textAlign: TextAlign.center,
                style: GoogleFonts.lora(
                  fontSize: context.sp(compact ? 24 : 28),
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
                padding: EdgeInsets.symmetric(horizontal: context.pagePadding)
                    .copyWith(bottom: compact ? 24 : 40, top: 16),
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
              );
            },
          ),
        ),
      ),
    );
  }
}
