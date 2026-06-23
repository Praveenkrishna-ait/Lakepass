import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

// Design tokens inspired by Adra Product Studio's design language
// Clean, modern, light/dark alternating sections with premium feel
class AppColors {
  // ── Light Mode Palette ──
  static const Color background = Color(0xFFFFFFFF);       // Pure white
  static const Color backgroundAlt = Color(0xFFF8FAFC);    // Off-white / light blue-gray
  static const Color surface = Color(0xFFFFFFFF);           // Card surface
  static const Color surfaceDark = Color(0xFF030712);       // Dark section bg
  static const Color surfaceDarkAlt = Color(0xFF0B0F19);   // Dark section card

  // ── Primary Brand Colors ──
  static const Color primary = Color(0xFF0F172A);           // Dark charcoal (main heading)
  static const Color primaryLight = Color(0xFF334155);      // Slate for body
  static const Color accent = Color(0xFFF97316);            // Orange accent (section labels)
  static const Color accentLight = Color(0xFFFB923C);       // Light orange
  static const Color cta = Color(0xFF0F172A);               // CTA button bg (dark)
  static const Color ctaText = Color(0xFFFFFFFF);           // CTA button text

  // ── Text Colors ──
  static const Color textPrimary = Color(0xFF0F172A);       // Near-black headings
  static const Color textSecondary = Color(0xFF475569);     // Slate body text
  static const Color textMuted = Color(0xFF94A3B8);         // Muted / placeholder
  static const Color textLight = Color(0xFFFFFFFF);         // White text on dark
  static const Color textLightMuted = Color(0xFF94A3B8);    // Muted on dark

  // ── Borders ──
  static const Color border = Color(0xFFE2E8F0);            // Light gray border
  static const Color borderDark = Color(0xFF1E293B);        // Dark section border

  // ── Status ──
  static const Color success = Color(0xFF22C55E);           // Green
  static const Color error = Color(0xFFEF4444);             // Red
  static const Color warning = Color(0xFFF59E0B);           // Amber

  // ── Glow / Shadow ──
  static const Color glowBlue = Color(0xFF3B82F6);          // Blue glow for edges
  static const Color glowViolet = Color(0xFF8B5CF6);        // Violet glow
}

class ApiConstants {
  static const String baseUrl = kReleaseMode 
      ? 'https://lakepass-backend.vercel.app/api'
      : 'http://localhost:5000/api';
}
