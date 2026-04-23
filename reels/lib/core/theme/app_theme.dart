import 'package:flutter/cupertino.dart';

// ════════════════════════════════════════════════════════════════════════════════
//  REELS — iOS DESIGN SYSTEM
//  Following Apple Human Interface Guidelines (HIG) strictly.
//  Dark-mode first, SF Pro typography, 4pt grid, iOS-native palette.
// ════════════════════════════════════════════════════════════════════════════════

// ──────────────────────────────────────────────────────────────────────────────
//  COLORS  — iOS Dark Mode Palette
// ──────────────────────────────────────────────────────────────────────────────

abstract final class AppColors {
  // Backgrounds
  static const background = Color(0xFF000000);
  static const surface = Color(0xFF1C1C1E);
  static const surface2 = Color(0xFF2C2C2E);
  static const surface3 = Color(0xFF3A3A3C);

  // Accent / Semantic
  static const primary = Color(0xFF0A84FF);
  static const success = Color(0xFF30D158);
  static const warning = Color(0xFFFF9F0A);
  static const error = Color(0xFFFF453A);

  // Text hierarchy
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0x99FFFFFF); // 60 %
  static const textTertiary = Color(0x4DFFFFFF); // 30 %

  // Chrome
  static const separator = Color(0x26FFFFFF); // 15 %

  // Utility
  static const shimmerBase = Color(0xFF2C2C2E);
  static const shimmerHighlight = Color(0xFF3A3A3C);
  static const shadow = Color(0x26000000); // 15 % black

  // Platform brand colours (badges / accents)
  static const twitter = Color(0xFF1DA1F2);
  static const tiktok = Color(0xFF25F4EE);
  static const instagram = Color(0xFFE1306C);
  static const youtube = Color(0xFFFF0000);
}

// ──────────────────────────────────────────────────────────────────────────────
//  TYPOGRAPHY  — SF Pro (system font on iOS)
//
//  Flutter uses SF Pro automatically on iOS when no fontFamily is specified.
//  iOS switches between SF Pro Display (≥ 20 pt) and SF Pro Text (< 20 pt)
//  based on the point size — no manual family switch needed.
//
//  Letter-spacing and line-height values match Apple's typographic spec.
// ──────────────────────────────────────────────────────────────────────────────

abstract final class AppTypography {
  // Display — SF Pro Display (auto at ≥ 20 pt)
  static const largeTitle = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.37,
    height: 1.21, // 41 pt leading
    color: AppColors.textPrimary,
  );

  static const title1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.36,
    height: 1.21, // 34 pt
    color: AppColors.textPrimary,
  );

  static const title2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.35,
    height: 1.27, // 28 pt
    color: AppColors.textPrimary,
  );

  static const title3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.38,
    height: 1.25, // 25 pt
    color: AppColors.textPrimary,
  );

  // Text — SF Pro Text (auto at < 20 pt)
  static const headline = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.41,
    height: 1.29, // 22 pt
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
    height: 1.31, // 21 pt
    color: AppColors.textPrimary,
  );

  static const subheadline = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.24,
    height: 1.33, // 20 pt
    color: AppColors.textPrimary,
  );

  static const footnote = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.08,
    height: 1.38, // 18 pt
    color: AppColors.textPrimary,
  );

  static const caption1 = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.33, // 16 pt
    color: AppColors.textPrimary,
  );

  static const caption2 = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.07,
    height: 1.18, // 13 pt
    color: AppColors.textPrimary,
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
  static const double medium = 14;
  static const double large = 20;
  static const double extraLarge = 28;

  // Pre-built BorderRadius for convenience
  static final smAll = BorderRadius.circular(small);
  static final mdAll = BorderRadius.circular(medium);
  static final lgAll = BorderRadius.circular(large);
  static final xlAll = BorderRadius.circular(extraLarge);
}

// ──────────────────────────────────────────────────────────────────────────────
//  SHADOWS  — Subtle, 15 % opacity
// ──────────────────────────────────────────────────────────────────────────────

abstract final class AppShadows {
  static const subtle = [
    BoxShadow(
      color: AppColors.shadow,
      blurRadius: 20,
      offset: Offset(0, 4),
    ),
  ];

  static const elevated = [
    BoxShadow(
      color: Color(0x33000000), // 20 %
      blurRadius: 30,
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
  static const decelerate = Curves.decelerate;
}

// ──────────────────────────────────────────────────────────────────────────────
//  PRESS SCALE
// ──────────────────────────────────────────────────────────────────────────────

abstract final class AppPressScale {
  static const double factor = 0.97;
}

// ──────────────────────────────────────────────────────────────────────────────
//  CUPERTINO THEME DATA
// ──────────────────────────────────────────────────────────────────────────────

abstract final class AppTheme {
  static CupertinoThemeData get dark => const CupertinoThemeData(
        brightness: Brightness.dark,
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        barBackgroundColor: Color(0xE6000000), // 90 % black — blurred nav bar
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
