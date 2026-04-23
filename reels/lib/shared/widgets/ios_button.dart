import 'dart:ui';

import 'package:flutter/cupertino.dart';

import 'package:reels/core/theme/app_theme.dart';
import 'package:reels/shared/widgets/pressable.dart';

// ════════════════════════════════════════════════════════════════════════════════
//  iOS BUTTON — Three Variants
//
//  • Primary   — Filled blue, 50 pt height, full width
//  • Secondary — Glass / blur backdrop, semi-transparent
//  • Destructive — Filled red
//
//  All variants include:
//   - Medium-impact haptic on tap
//   - Scale-down to 0.97 on press
//   - 300 ms ease-in-out transitions
//   - Loading state with CupertinoActivityIndicator
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
      height: 50,
      width: fullWidth ? double.infinity : null,
      padding: fullWidth
          ? null
          : const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: AppRadius.mdAll,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(51), // 20 %
            blurRadius: 16,
            offset: const Offset(0, 6),
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
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          height: 50,
          width: fullWidth ? double.infinity : null,
          padding: fullWidth
              ? null
              : const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          decoration: BoxDecoration(
            color: const Color(0x33FFFFFF), // 20 % white glass tint
            borderRadius: AppRadius.mdAll,
            border: Border.all(
              color: const Color(0x1AFFFFFF), // 10 % white border
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
      height: 50,
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
            blurRadius: 16,
            offset: const Offset(0, 6),
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
      style: AppTypography.headline.copyWith(color: textColor),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );

    if (icon == null) return textWidget;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: textColor, size: 18),
        const SizedBox(width: AppSpacing.sm),
        Flexible(child: textWidget),
      ],
    );
  }
}
