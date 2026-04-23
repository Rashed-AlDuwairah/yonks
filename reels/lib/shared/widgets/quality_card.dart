import 'package:flutter/cupertino.dart';

import 'package:reels/core/theme/app_theme.dart';
import 'package:reels/shared/widgets/pressable.dart';

// ════════════════════════════════════════════════════════════════════════════════
//  QUALITY CARD — Video Quality Selection
//
//  Displays a single quality option with:
//   • Resolution badge (e.g. 1080p, 720p) — prominent
//   • Format tag (MP4, WebM) — pill badge
//   • File size — secondary text
//   • Animated checkmark when selected
//   • iOS-style selection highlight (primary tint border)
//   • Scale-down press animation + haptic
// ════════════════════════════════════════════════════════════════════════════════

class QualityCard extends StatelessWidget {
  const QualityCard({
    super.key,
    required this.resolution,
    required this.format,
    required this.fileSize,
    this.qualityLabel,
    this.isSelected = false,
    this.onTap,
  });

  /// e.g. "1080p", "720p", "480p", "4K"
  final String resolution;

  /// e.g. "MP4", "WebM", "MOV"
  final String format;

  /// e.g. "24.3 MB", "156 MB"
  final String fileSize;

  /// Optional quality descriptor — "Full HD", "HD", "SD"
  final String? qualityLabel;

  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.normal,
        curve: AppCurves.standard,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withAlpha(18) // ~7 % blue tint
              : AppColors.surface,
          borderRadius: AppRadius.mdAll,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.separator,
            width: isSelected ? 1.5 : 0.5,
          ),
        ),
        child: Row(
          children: [
            // ── Resolution badge ────────────────────────────────
            _ResolutionBadge(
              resolution: resolution,
              isSelected: isSelected,
            ),

            const SizedBox(width: AppSpacing.md),

            // ── Format tag + file size ──────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      _FormatPill(format: format),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        fileSize,
                        style: AppTypography.subheadline.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  if (qualityLabel != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      qualityLabel!,
                      style: AppTypography.caption1.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: AppSpacing.sm),

            // ── Checkmark ───────────────────────────────────────
            _AnimatedCheckmark(isSelected: isSelected),
          ],
        ),
      ),
    );
  }
}

// ─── RESOLUTION BADGE ────────────────────────────────────────────────────────

class _ResolutionBadge extends StatelessWidget {
  const _ResolutionBadge({
    required this.resolution,
    required this.isSelected,
  });

  final String resolution;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppDurations.normal,
      curve: AppCurves.standard,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : AppColors.surface2,
        borderRadius: AppRadius.smAll,
      ),
      child: Text(
        resolution,
        style: AppTypography.headline.copyWith(
          color: isSelected ? CupertinoColors.white : AppColors.textPrimary,
          fontSize: 15,
        ),
      ),
    );
  }
}

// ─── FORMAT PILL ─────────────────────────────────────────────────────────────

class _FormatPill extends StatelessWidget {
  const _FormatPill({required this.format});

  final String format;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface3,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        format.toUpperCase(),
        style: AppTypography.caption2.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ─── ANIMATED CHECKMARK ──────────────────────────────────────────────────────

class _AnimatedCheckmark extends StatelessWidget {
  const _AnimatedCheckmark({required this.isSelected});

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: AppDurations.normal,
      switchInCurve: AppCurves.spring,
      switchOutCurve: AppCurves.standard,
      transitionBuilder: (child, animation) {
        return ScaleTransition(
          scale: animation,
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      child: isSelected
          ? Icon(
              CupertinoIcons.checkmark_circle_fill,
              key: const ValueKey('checked'),
              color: AppColors.primary,
              size: 24,
            )
          : const SizedBox(
              key: ValueKey('unchecked'),
              width: 24,
              height: 24,
            ),
    );
  }
}
