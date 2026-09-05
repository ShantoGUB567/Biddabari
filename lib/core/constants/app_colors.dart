import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Brand Colors (Biddabari Emerald / Forest Green)
  static const Color primary = Color(0xFF0D6E4F);
  static const Color primaryLight = Color(0xFF13966C);
  static const Color primaryDark = Color(0xFF094D37);
  static const Color primarySubtle = Color(0xFFE8F5EE);

  // Accent & Action Colors
  static const Color accent = Color(0xFFFF6B00);
  static const Color accentLight = Color(0xFFFF8B38);
  static const Color accentSubtle = Color(0xFFFFF1E6);

  // Discount / Badge Colors
  static const Color discountRed = Color(0xFFDC2626);
  static const Color discountBadgeBg = Color(0xFFFFEBEB);
  static const Color countdownBg = Color(0xFFFEF2F2);
  static const Color countdownText = Color(0xFFB91C1C);

  // Stats Indicator Colors
  static const Color statDuration = Color(0xFF2563EB); // Blue
  static const Color statClass = Color(0xFF7C3AED);    // Purple
  static const Color statExam = Color(0xFF059669);     // Emerald
  static const Color statLive = Color(0xFFDC2626);     // Crimson Red

  // Background & Surface
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Colors.white;
  static const Color surfaceCard = Colors.white;
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFF1F5F9);

  // Text Colors
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textStrikeThrough = Color(0xFF94A3B8);

  // Status & Alerts
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color offline = Color(0xFF64748B);

  // Shimmer Colors
  static const Color shimmerBase = Color(0xFFE2E8F0);
  static const Color shimmerHighlight = Color(0xFFF8FAFC);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0D6E4F), Color(0xFF13966C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFFF6B00), Color(0xFFFF8B38)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroOverlay = LinearGradient(
    colors: [Colors.black54, Colors.transparent],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
  );
}
