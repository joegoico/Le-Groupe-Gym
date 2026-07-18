import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Backgrounds
  static const background = Color(0xFF131315);
  static const surfaceLowest = Color(0xFF0E0E10);
  static const surfaceContainerLow = Color(0xFF1C1B1D);
  static const surfaceContainer = Color(0xFF201F22);
  static const surfaceContainerHigh = Color(0xFF2A2A2C);
  static const surfaceContainerHighest = Color(0xFF353437);
  static const surfaceBright = Color(0xFF39393B);

  // Primary
  static const primary = Color(0xFFC3F400); // Electric Lime
  static const primaryDim = Color(0xFFABD600);
  static const onPrimary = Color(0xFF283500);

  // Text
  static const onSurface = Color(0xFFE5E1E4);
  static const onSurfaceVariant = Color(0xFFC4C9AC);
  static const onPrimaryFixed = Color(0xFF161e00);

  // Outline
  static const outline = Color(0xFF8E9379);
  static const outlineVariant = Color(0xFF444933);

  // Tertiary (Electric Blue)
  static const tertiary = Color(0xFFADC6FF);
  static const tertiaryContainer = Color(0xFF004395);

  // Status
  static const error = Color(0xFFFFB4AB);
  static const errorContainer = Color(0xFF93000A);

  static const success = Color(0xFF219653);
  static const successContainer = Color(0xFF7ECC3B);
  static const successContent = Color(0xFF0D1F00);

  static const warningLow = Color(0xFFFFD966);
  static const warningLowContent = Color(0xFF332900);
}

class AppRadius {
  static const sm = Radius.circular(4);
  static const md = Radius.circular(8);
  static const lg = Radius.circular(12);
  static const xl = Radius.circular(16);
  static const full = Radius.circular(9999);
}

class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
}

class AppTextStyles {
  static TextStyle get headlineLg => GoogleFonts.hankenGrotesk(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.01,
    color: AppColors.onSurface,
  );

  static TextStyle get titleMd => GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
  );
  static TextStyle get titleCards => GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
  );

  static TextStyle get buttonText => GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.onPrimaryFixed,
  );

  static TextStyle get labelCaps => GoogleFonts.robotoMono(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.05,
    color: AppColors.onSurfaceVariant,
  );

  static TextStyle get subtittles => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w200,
    color: AppColors.onSurface,
  );
  static TextStyle get subtittlesBold => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
  );
}
