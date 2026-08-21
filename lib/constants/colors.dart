import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors based on Figma "SIMPATTI"
  static const Color primaryDark = Color(0xFF1B2332); // Dark color for buttons like "Masuk"
  static const Color primaryBlue = Color(0xFF1E88E5); // Blue accents
  
  static const Color bgBlueLight = Color(0xFFE3F2FD);
  static const Color bgWhite = Color(0xFFF9FAFB);
  static const Color surface = Color(0xFFFFFFFF);
  
  // Accents
  static const Color yellowLight = Color(0xFFFFD54F);
  static const Color yellowDark = Color(0xFFFFB300);
  
  // Text
  static const Color textPrimary = Color(0xFF1B2332);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textLight = Color(0xFF9CA3AF);
  static const Color textHint = Color(0xFFD1D5DB);
  
  // Status
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color danger = Color(0xFFEF4444);
  static const Color dangerLight = Color(0xFFFEE2E2);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);

  // Gradients
  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [yellowLight, yellowDark],
  );

  static const LinearGradient welcomeBg = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFE8F1F8), Color(0xFF98C5E7)],
  );

  // --- Aliases to fix compilation for other screens ---
  static const Color primary = primaryDark;
  static const Color background = bgWhite;
  static const Color accent = yellowDark;
  static const Color accentDark = Color(0xFFF57F17);
  static const Color info = primaryBlue;

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1B4D8E), Color(0xFF0D2B52)],
  );
  
  static const LinearGradient goldGradient = buttonGradient;
}
