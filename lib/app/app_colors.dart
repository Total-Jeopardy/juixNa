import 'package:flutter/material.dart';

/// Core JuixNa brand colors + semantic system.
class AppColors {
  // ── Brand ──────────────────────────────────────────────────────────────
  /// Main creamy background used for app scaffold
  static const creamBackground = Color(0xFFFFF6E8); // alt: 0xFFFFF9F0
  static const background = creamBackground;

  /// Primary mango orange (buttons, key highlights)
  static const mango = Color(0xFFFFA51F);

  /// Gradient endpoints for primary CTAs, headers, etc.
  static const mangoGradientStart = Color(0xFFFF8A00);
  static const mangoGradientEnd = Color(0xFFFFBD3B);
  static const mangoDark = mangoGradientStart;
  static const mangoLight = mangoGradientEnd;

  /// Deep green for headings, main brand text
  static const deepGreen = Color(0xFF0B3A2E);

  // ── Neutral / text ─────────────────────────────────────────────────────
  static const textPrimary = Color(0xFF1F2933); // dark gray
  static const textSecondary = Color(0xFF6B7280); // muted gray
  static const textMuted = Color.fromARGB(255, 118, 129, 151);
  static const textOnPrimary = Colors.white;
  static const textOnDark = Colors.white;

  static const borderSubtle = Color(0xFFE5E7EB);
  static const borderSoft = borderSubtle;
  static const borderStrong = Color(0xFFCBD2E1);

  static const surface = Colors.white;
  static const surfaceMuted = Color(0xFFF3F4F6);
  static const backgroundAlt = surfaceMuted;

  // Dark neutrals for the inventory experience
  static const darkBackground = Color(0xFF17110D);
  static const darkSurface = Color(0xFF1E1712);
  static const darkCard = Color(0xFF251C15);
  static const darkPill = Color(0xFF2E221A);
  static const darkTextPrimary = Color(0xFFEDE6DD);
  static const darkTextMuted = Color(0xFFB9AD9F);

  // ── States / semantic ──────────────────────────────────────────────────
  static const success = Color(0xFF10B981); // teal/green
  static const successSoft = Color(0xFFD1FAE5);

  static const warning = Color(0xFFF59E0B);
  static const warningSoft = Color(0xFFFEF3C7);

  static const error = Color(0xFFEF4444);
  static const errorSoft = Color(0xFFFEE2E2);

  static const info = Color(0xFF3B82F6);
  static const infoSoft = Color(0xFFDBEAFE);

  // ── Shadows / overlays ─────────────────────────────────────────────────
  static const shadowSoft = Color(0x1A000000); // 10% black
  static const overlay = Color(0x66000000); // 40% black
  static const dividerSubtle = borderSubtle;
}

/// Useful gradients centralized here.
class AppGradients {
  static const primary = LinearGradient(
    colors: [AppColors.mangoGradientStart, AppColors.mangoGradientEnd],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// For big top sections / headers
  static const header = LinearGradient(
    colors: [Color(0xFFFFF3D8), Color(0xFFFFF9F0)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

/// Shared radii (JuixNa = rounded everywhere, soft)
class AppRadii {
  static const double xs = 6;
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 18;
  static const double xl = 24;
  static const double pill = 999;
}

/// Shared elevation / shadow tokens.
class AppShadows {
  static const soft = [
    BoxShadow(
      blurRadius: 12,
      offset: Offset(0, 6),
      color: AppColors.shadowSoft,
    ),
  ];

  static const chip = [
    BoxShadow(blurRadius: 6, offset: Offset(0, 3), color: AppColors.shadowSoft),
  ];
}
