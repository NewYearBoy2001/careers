import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  // ── Page headings (white, on gradient header) ──────────────────
  static TextStyle pageTitle({double fontSize = 22}) =>
      GoogleFonts.inter(
        fontSize: fontSize,
        fontWeight: FontWeight.w500,        // was w700
        color: Colors.white,
        letterSpacing: -0.3,
        height: 1.1,
      );

  // ── Section headings (on white background) ──────────────────────
  static TextStyle sectionTitle({double fontSize = 18}) =>
      GoogleFonts.inter(
        fontSize: fontSize,
        fontWeight: FontWeight.w500,        // was w700
        color: AppColors.textPrimary,     // was textPrimary (near-black)
        letterSpacing: -0.2,
      );

  // ── Section heading with primary color accent ───────────────────
  static TextStyle sectionTitleAccent({double fontSize = 18}) =>
      GoogleFonts.inter(
        fontSize: fontSize,
        fontWeight: FontWeight.w500,
        color: AppColors.primary,
        letterSpacing: -0.2,
      );

  // ── Card title (college name in card/details) ───────────────────
  static TextStyle cardTitle({double fontSize = 15}) =>
      GoogleFonts.inter(
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: -0.2,
      );

  // ── Sub-section labels inside cards ────────────────────────────
  static TextStyle subSectionTitle({double fontSize = 16}) =>
      GoogleFonts.inter(
        fontSize: fontSize,
        fontWeight: FontWeight.w500,        // was w600
        color: AppColors.textSecondary,     // was textPrimary
      );

  static TextStyle screenTitle({double fontSize = 18}) =>
      GoogleFonts.inter(
        fontSize: fontSize,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
        letterSpacing: -0.2,
      );

// ── Large hero heading (on gradient bg, like Edit Profile) ─────
  static TextStyle heroTitle({double fontSize = 24}) =>
      GoogleFonts.inter(
        fontSize: fontSize,
        fontWeight: FontWeight.w500,        // was w700
        color: AppColors.textPrimary,
        letterSpacing: -0.4,
      );
}