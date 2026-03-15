import 'package:flutter/material.dart';

// ─── Colors ──────────────────────────────────────────────────────────────────

class AppColors {
  // Gold / Champagne accent system
  static const primary = Color(0xFFC9A84C);        // rich gold
  static const primaryDark = Color(0xFFA8882E);    // deep gold
  static const primaryLight = Color(0xFFE2C97E);   // light champagne
  static const primaryGlow = Color(0x33C9A84C);    // gold glow

  // Teal accent (secondary)
  static const secondary = Color(0xFF4ECDC4);
  static const secondaryDark = Color(0xFF2EA89F);

  // Obsidian backgrounds
  static const background = Color(0xFF080810);     // near-black navy
  static const surface = Color(0xFF0F0F1C);        // card background
  static const surfaceElevated = Color(0xFF161625); // elevated surface
  static const card = Color(0xFF13131F);
  static const cardBorder = Color(0xFF252535);
  static const cardBorderGold = Color(0xFF3D3520);

  // Typography
  static const text = Color(0xFFF5F3EE);           // warm white
  static const textSecondary = Color(0xFF9896A4);
  static const textMuted = Color(0xFF55536A);

  // Status
  static const danger = Color(0xFFE05260);
  static const success = Color(0xFF3DD9AC);
  static const warning = Color(0xFFC9A84C);

  // Glass
  static const glass = Color(0x0DFFFFFF);
  static const glassBorder = Color(0x1AFFFFFF);
}

// ─── Gradients ────────────────────────────────────────────────────────────────

class AppGradients {
  static const gold = LinearGradient(
    colors: [AppColors.primaryLight, AppColors.primary, AppColors.primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const goldSimple = LinearGradient(
    colors: [AppColors.primary, AppColors.primaryDark],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const dark = LinearGradient(
    colors: [AppColors.background, AppColors.surface],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const heroScrim = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x99000000),
      Colors.transparent,
      Color(0xCC080810),
    ],
    stops: [0, 0.35, 1],
  );

  static const cardSheen = LinearGradient(
    colors: [Color(0x0DFFFFFF), Color(0x00FFFFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const accent = LinearGradient(
    colors: [AppColors.primary, AppColors.secondary],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}

// ─── Spacing ──────────────────────────────────────────────────────────────────

class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

// ─── Radius ───────────────────────────────────────────────────────────────────

class AppRadius {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double full = 999;
}

// ─── Shadows ──────────────────────────────────────────────────────────────────

class AppShadows {
  static List<BoxShadow> get small => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.4),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get medium => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.5),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get large => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.7),
          blurRadius: 40,
          offset: const Offset(0, 16),
        ),
      ];

  static List<BoxShadow> get goldGlow => [
        BoxShadow(
          color: AppColors.primary.withValues(alpha: 0.25),
          blurRadius: 24,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get card => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.6),
          blurRadius: 32,
          offset: const Offset(0, 12),
        ),
        BoxShadow(
          color: AppColors.primary.withValues(alpha: 0.04),
          blurRadius: 1,
          offset: const Offset(0, 0),
          spreadRadius: 1,
        ),
      ];
}

// ─── Theme ────────────────────────────────────────────────────────────────────

class AppTheme {
  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'Garamond', // Will fall back to serif system font
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.surface,
          error: AppColors.danger,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w700,
            letterSpacing: -1,
            color: AppColors.text,
          ),
          headlineLarge: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
            color: AppColors.text,
          ),
          headlineMedium: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
            color: AppColors.text,
          ),
          titleLarge: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
          bodyLarge: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            height: 1.6,
            color: AppColors.text,
          ),
          bodyMedium: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            height: 1.5,
            color: AppColors.textSecondary,
          ),
          labelSmall: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
            color: AppColors.textMuted,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceElevated,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: const BorderSide(color: AppColors.cardBorder, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: const BorderSide(color: AppColors.cardBorder, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: const BorderSide(color: AppColors.danger, width: 1),
          ),
          hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.background,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            minimumSize: const Size(double.infinity, 52),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          elevation: 0,
          titleTextStyle: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
          iconTheme: IconThemeData(color: AppColors.text),
        ),
      );
}