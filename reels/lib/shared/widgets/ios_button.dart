import 'dart:ui';

import 'package:flutter/cupertino.dart';

import 'package:reels/core/theme/app_theme.dart';
import 'package:reels/shared/widgets/pressable.dart';

// ════════════════════════════════════════════════════════════════════════════════
//  iOS BUTTON — Three Variants
//
//  • Primary   — Filled blue, 54 pt height, glowing shadow
//  • Secondary — Heavy Glass / blur backdrop, subtle inner border
//  • Destructive — Filled red
// ════════════════════════════════════════════════════════════════════════════════

enum IosButtonVariant { primary, secondary, destructive }

class IosButton extends StatelessWidget {
  const IosButton({
    super.key,
    required this.label,
    required this.onTap,
    this.variant = IosButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.enabled = true,
    this.fullWidth = true,
  });

  final String label;
  final VoidCallback? onTap;
  final IosButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool enabled;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final isDisabled = !enabled || isLoading;

    return Pressable(
      onTap: isDisabled ? null : onTap,
      haptic: true,
      enabled: !isDisabled,
      child: AnimatedOpacity(
        opacity: isDisabled ? 0.45 : 1.0,
        duration: AppDurations.normal,
        curve: AppCurves.standard,
        child: switch (variant) {
          IosButtonVariant.primary => _PrimaryBody(
              label: label,
              icon: icon,
              isLoading: isLoading,
              fullWidth: fullWidth,
            ),
          IosButtonVariant.secondary => _SecondaryBody(
              label: label,
              icon: icon,
              isLoading: isLoading,
              fullWidth: fullWidth,
            ),
          IosButtonVariant.destructive => _DestructiveBody(
              label: label,
              icon: icon,
              isLoading: isLoading,
              fullWidth: fullWidth,
            ),
        },
      ),
    );
  }
}

// ─── PRIMARY ─────────────────────────────────────────────────────────────────

class _PrimaryBody extends StatelessWidget {
  const _PrimaryBody({
    required this.label,
    this.icon,
    required this.isLoading,
    required this.fullWidth,
  });

  final String label;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54, // Slightly taller for premium feel
      width: fullWidth ? double.infinity : null,
      padding: fullWidth
          ? null
          : const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: AppRadius.mdAll,
        boxShadow: AppShadows.glowPrimary, // New glowing shadow
      ),
      child: Center(
        child: _ButtonContent(
          label: label,
          icon: icon,
          isLoading: isLoading,
          textColor: CupertinoColors.white,
        ),
      ),
    );
  }
}

// ─── SECONDARY (Glass / Blur) ────────────────────────────────────────────────

class _SecondaryBody extends StatelessWidget {
  const _SecondaryBody({
    required this.label,
    this.icon,
    required this.isLoading,
    required this.fullWidth,
  });

  final String label;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadius.mdAll,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24), // Much stronger blur
        child: Container(
          height: 54,
          width: fullWidth ? double.infinity : null,
          padding: fullWidth
              ? null
              : const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          decoration: BoxDecoration(
            color: const Color(0x1AFFFFFF), // 10% white for deep glass
            borderRadius: AppRadius.mdAll,
            border: Border.all(
              color: AppColors.glassBorder,
              width: 0.5,
            ),
          ),
          child: Center(
            child: _ButtonContent(
              label: label,
              icon: icon,
              isLoading: isLoading,
              textColor: AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── DESTRUCTIVE ─────────────────────────────────────────────────────────────

class _DestructiveBody extends StatelessWidget {
  const _DestructiveBody({
    required this.label,
    this.icon,
    required this.isLoading,
    required this.fullWidth,
  });

  final String label;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      width: fullWidth ? double.infinity : null,
      padding: fullWidth
          ? null
          : const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.error,
        borderRadius: AppRadius.mdAll,
        boxShadow: [
          BoxShadow(
            color: AppColors.error.withAlpha(51),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: _ButtonContent(
          label: label,
          icon: icon,
          isLoading: isLoading,
          textColor: CupertinoColors.white,
        ),
      ),
    );
  }
}

// ─── SHARED CONTENT ROW ──────────────────────────────────────────────────────

class _ButtonContent extends StatelessWidget {
  const _ButtonContent({
    required this.label,
    this.icon,
    required this.isLoading,
    required this.textColor,
  });

  final String label;
  final IconData? icon;
  final bool isLoading;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return CupertinoActivityIndicator(color: textColor);
    }

    final textWidget = Text(
      label,
      style: AppTypography.headline.copyWith(
        color: textColor,
        fontWeight: FontWeight.w700, // Bolder text for buttons
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );

    if (icon == null) return textWidget;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: textColor, size: 20),
        const SizedBox(width: AppSpacing.sm),
        Flexible(child: textWidget),
      ],
    );
  }
}
