import 'package:flutter/cupertino.dart';

// ════════════════════════════════════════════════════════════════════════════════
//  REELS — iOS DESIGN SYSTEM
//  Following Apple Human Interface Guidelines (HIG) strictly.
//  Dark-mode first, SF Pro typography, 4pt grid, iOS-native palette.
// ════════════════════════════════════════════════════════════════════════════════

// ──────────────────────────────────────────────────────────────────────────────
//  COLORS  — iOS Dark Mode Palette (AMOLED)
// ──────────────────────────────────────────────────────────────────────────────

abstract final class AppColors {
  // Backgrounds - True Black
  static const background = Color(0xFF000000);
  
  // Surfaces (Slightly elevated from black)
  static const surface = Color(0xFF141415); // Deepest gray
  static const surface2 = Color(0xFF1C1C1E);
  static const surface3 = Color(0xFF2C2C2E);

  // Accent / Semantic - Vibrant iOS Blue
  static const primary = Color(0xFF0A84FF);
  static const primaryGlow = Color(0x330A84FF); // 20% opacity for glowing
  static const success = Color(0xFF30D158);
  static const warning = Color(0xFFFF9F0A);
  static const error = Color(0xFFFF453A);

  // Text hierarchy
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0x99FFFFFF); // 60%
  static const textTertiary = Color(0x4DFFFFFF); // 30%

  // Chrome
  static const separator = Color(0x26FFFFFF); // 15%
  static const glassBorder = Color(0x1AFFFFFF); // 10%

  // Utility
  static const shimmerBase = Color(0xFF1C1C1E);
  static const shimmerHighlight = Color(0xFF2C2C2E);
  static const shadow = Color(0x80000000); // 50% black for deep shadows

  // Platform brand colours (badges / accents)
  static const twitter = Color(0xFF1DA1F2);
  static const tiktok = Color(0xFF25F4EE);
  static const instagram = Color(0xFFE1306C);
  static const youtube = Color(0xFFFF0000);
}

// ──────────────────────────────────────────────────────────────────────────────
//  TYPOGRAPHY  — SF Pro (system font on iOS)
// ──────────────────────────────────────────────────────────────────────────────

abstract final class AppTypography {
  // Display — SF Pro Display (auto at ≥ 20 pt)
  static const largeTitle = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.37,
    height: 1.21,
    color: AppColors.textPrimary,
  );

  static const title1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.36,
    height: 1.21,
    color: AppColors.textPrimary,
  );

  static const title2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.35,
    height: 1.27,
    color: AppColors.textPrimary,
  );

  static const title3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.38,
    height: 1.25,
    color: AppColors.textPrimary,
  );

  // Text — SF Pro Text (auto at < 20 pt)
  static const headline = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.41,
    height: 1.29,
    color: AppColors.textPrimary,
  );

  static const body = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.41,
    height: 1.29,
    color: AppColors.textPrimary,
  );

  static const callout = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.32,
    height: 1.31,
    color: AppColors.textPrimary,
  );

  static const subheadline = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.24,
    height: 1.33,
    color: AppColors.textPrimary,
  );

  static const footnote = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.08,
    height: 1.38,
    color: AppColors.textPrimary,
  );

  static const caption1 = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.33,
    color: AppColors.textPrimary,
  );

  static const caption2 = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.07,
    height: 1.18,
    color: AppColors.textSecondary,
  );
}

// ──────────────────────────────────────────────────────────────────────────────
//  SPACING  — 4 pt Grid
// ──────────────────────────────────────────────────────────────────────────────

abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double base = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;
  static const double huge = 48;
}

// ──────────────────────────────────────────────────────────────────────────────
//  CORNER RADIUS  — iOS conventions
// ──────────────────────────────────────────────────────────────────────────────

abstract final class AppRadius {
  static const double small = 10;
  static const double medium = 16; // Increased for a softer, premium look
  static const double large = 24;
  static const double extraLarge = 32;

  static final smAll = BorderRadius.circular(small);
  static final mdAll = BorderRadius.circular(medium);
  static final lgAll = BorderRadius.circular(large);
  static final xlAll = BorderRadius.circular(extraLarge);
}

// ──────────────────────────────────────────────────────────────────────────────
//  SHADOWS
// ──────────────────────────────────────────────────────────────────────────────

abstract final class AppShadows {
  static const subtle = [
    BoxShadow(
      color: AppColors.shadow,
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  static const elevated = [
    BoxShadow(
      color: AppColors.shadow,
      blurRadius: 32,
      offset: Offset(0, 12),
    ),
  ];
  
  static const glowPrimary = [
    BoxShadow(
      color: AppColors.primaryGlow,
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];
}

// ──────────────────────────────────────────────────────────────────────────────
//  ANIMATION TOKENS
// ──────────────────────────────────────────────────────────────────────────────

abstract final class AppDurations {
  static const fast = Duration(milliseconds: 150);
  static const normal = Duration(milliseconds: 300);
  static const slow = Duration(milliseconds: 500);
}

abstract final class AppCurves {
  static const standard = Curves.easeInOut;
  static const spring = Curves.easeOutCubic;
  static const bouncy = Curves.elasticOut;
  static const decelerate = Curves.decelerate;
}

// ──────────────────────────────────────────────────────────────────────────────
//  PRESS SCALE
// ──────────────────────────────────────────────────────────────────────────────

abstract final class AppPressScale {
  static const double factor = 0.96; // Slightly more pronounced scale down
}

// ──────────────────────────────────────────────────────────────────────────────
//  CUPERTINO THEME DATA
// ──────────────────────────────────────────────────────────────────────────────

abstract final class AppTheme {
  static CupertinoThemeData get dark => const CupertinoThemeData(
        brightness: Brightness.dark,
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        barBackgroundColor: Color(0xB3000000), // 70% black — blurred nav bar
        textTheme: CupertinoTextThemeData(
          primaryColor: AppColors.primary,
          textStyle: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            letterSpacing: -0.41,
            height: 1.29,
          ),
          navTitleTextStyle: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.41,
          ),
          navLargeTitleTextStyle: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 34,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.37,
          ),
          actionTextStyle: TextStyle(
            color: AppColors.primary,
            fontSize: 17,
            letterSpacing: -0.41,
          ),
          tabLabelTextStyle: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            letterSpacing: 0,
          ),
        ),
      );
}

