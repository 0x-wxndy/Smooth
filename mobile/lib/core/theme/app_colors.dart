import 'package:flutter/material.dart';

/// Samooth brand — reinterpreted from client vision (teal hub + soft section accents).
abstract final class AppColors {
  // Brand
  static const primary = Color(0xFF0D9488); // teal
  static const primaryDark = Color(0xFF0F766E);
  static const primarySoft = Color(0xFFCCFBF1);
  static const navy = Color(0xFF0F1C2E);
  static const navySoft = Color(0xFF1A2A40);

  // Role / section accents (marketplace-style color coding)
  static const accentBlue = Color(0xFF3B82F6);
  static const accentPurple = Color(0xFF7C3AED);
  static const accentGreen = Color(0xFF059669);
  static const accentOrange = Color(0xFFE5A844);
  static const accentPink = Color(0xFFEC4899);

  static const secondary = accentPurple;
  static const accent = Color(0xFF14B8A6);

  static const background = Color(0xFFF4F7FA);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceVariant = Color(0xFFEEF2F6);

  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF64748B);
  static const textMuted = Color(0xFF94A3B8);

  static const border = Color(0xFFE2E8F0);
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);
  static const coin = Color(0xFFFBBF24);

  // Pastel metric cards
  static const pastelMint = Color(0xFFD1FAE5);
  static const pastelBlue = Color(0xFFDBEAFE);
  static const pastelLavender = Color(0xFFEDE9FE);
  static const pastelPeach = Color(0xFFFFEDD5);
  static const pastelSky = Color(0xFFE0F2FE);

  static const gradientPrimary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, Color(0xFF2DD4BF)],
  );

  static const gradientHero = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFEC4899), Color(0xFF6366F1), Color(0xFF0EA5E9)],
  );

  static const gradientNavy = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [navy, navySoft],
  );

  static const gradientWarm = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF472B6), Color(0xFFA78BFA)],
  );
}
