import 'package:flutter/material.dart';

/// FinTrack Signature Obsidian & Neo-Mint Design System
class AppTheme {
  // Brand Core Colors
  static const Color obsidianBg = Color(0xFF090D16); // Deep Cosmic Obsidian
  static const Color surfaceCard = Color(0xFF111726); // Smoked Glass Card
  static const Color surfaceCardElevated = Color(0xFF161E31); // Elevated Card
  static const Color borderLight = Color(0xFF1F293D); // Subtle Structural Border
  static const Color borderGlow = Color(0x3300F59B); // Subtle Neo-Mint Glow

  // Signature Accent Palette
  static const Color cyberMint = Color(0xFF00F59B); // Primary Brand Neon Mint
  static const Color electricIndigo = Color(0xFF6366F1); // Royal Indigo
  static const Color royalViolet = Color(0xFF8B5CF6); // Ultraviolet
  static const Color neonCoral = Color(0xFFFF4D6D); // Expense Coral
  static const Color electricCyan = Color(0xFF00D2FF); // Celestial Savings Cyan
  static const Color solarAmber = Color(0xFFFFB703); // Warm Solar Gold

  // Pocket Brand Gradients
  static const LinearGradient cashCardGradient = LinearGradient(
    colors: [Color(0xFF064E3B), Color(0xFF059669), Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient savingsCardGradient = LinearGradient(
    colors: [Color(0xFF0C4A6E), Color(0xFF0284C7), Color(0xFF00D2FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient seaBankGradient = LinearGradient(
    colors: [Color(0xFF7C2D12), Color(0xFFEA580C), Color(0xFFFB923C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bankJagoGradient = LinearGradient(
    colors: [Color(0xFF3B0764), Color(0xFF7E22CE), Color(0xFFFBBF24)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient titaniumCardGradient = LinearGradient(
    colors: [Color(0xFF0F172A), Color(0xFF1E1B4B), Color(0xFF0C1322)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient streakFlameGradient = LinearGradient(
    colors: [Color(0xFFB45309), Color(0xFFEA580C), Color(0xFFF59E0B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Modern Card Box Decoration
  static BoxDecoration glassCardDecoration({
    Color? color,
    Color? borderColor,
    double borderRadius = 20,
    bool glow = false,
  }) {
    return BoxDecoration(
      color: color ?? surfaceCard,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: borderColor ?? (glow ? cyberMint.withValues(alpha: 0.35) : borderLight),
        width: 1.2,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.35),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
        if (glow)
          BoxShadow(
            color: cyberMint.withValues(alpha: 0.12),
            blurRadius: 20,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
      ],
    );
  }

  // ThemeData Builder
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorSchemeSeed: cyberMint,
      scaffoldBackgroundColor: obsidianBg,
      fontFamily: null, // Clean default sans
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceCardElevated,
        labelStyle: const TextStyle(color: Colors.white70),
        hintStyle: const TextStyle(color: Colors.white30),
        prefixStyle: const TextStyle(color: cyberMint, fontWeight: FontWeight.bold),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: cyberMint, width: 1.5),
        ),
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        color: surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          side: BorderSide(color: borderLight),
        ),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorSchemeSeed: const Color(0xFF00C47C), // Slightly deeper mint for light
      scaffoldBackgroundColor: const Color(0xFFF0F4F8),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF0F4F8),
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: Color(0xFF0F172A),
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(color: Color(0xFF0F172A)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        labelStyle: const TextStyle(color: Color(0xFF64748B)),
        hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF00C47C), width: 1.5),
        ),
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          side: BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
    );
  }
}
