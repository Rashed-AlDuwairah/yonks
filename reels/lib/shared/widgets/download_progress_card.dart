import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'package:reels/core/theme/app_theme.dart';
import 'package:reels/shared/widgets/pressable.dart';

// ════════════════════════════════════════════════════════════════════════════════
//  DOWNLOAD PROGRESS CARD
//
//  Layout (left-to-right):
//  ┌──────────────────────────────────────────────┐
//  │ ┌──────────┐  Title of the video…            │
//  │ │thumbnail │  ████████████░░░░ 80 %           │
//  │ │          │  12.5 MB/s               [✕]     │
//  │ └──────────┘                                  │
//  └──────────────────────────────────────────────┘
//
//  Features:
//   • Animated progress bar (iOS blue, rounded)
//   • Deep frosted glass background
//   • Speed indicator
//   • Cancel button with haptic
//   • Thumbnail placeholder via shimmer slot
//   • Status labels: Downloading, Paused, Complete, Failed
// ════════════════════════════════════════════════════════════════════════════════

enum DownloadStatus { downloading, paused, complete, failed }

class DownloadProgressCard extends StatelessWidget {
  const DownloadProgressCard({
    super.key,
    required this.title,
    required this.progress,
    this.thumbnail,
    this.speed,
    this.downloadedSize,
    this.totalSize,
    this.status = DownloadStatus.downloading,
    this.onCancel,
    this.onRetry,
    this.onTap,
  });

  /// Video title — truncated to 1 line.
  final String title;

  /// 0.0 … 1.0
  final double progress;

  /// Thumbnail widget (e.g. CachedNetworkImage, Image.memory, etc.)
  final Widget? thumbnail;

  /// e.g. "12.5 MB/s"
  final String? speed;

  /// e.g. "48.2 MB"
  final String? downloadedSize;

  /// e.g. "156 MB"
  final String? totalSize;

  final DownloadStatus status;
  final VoidCallback? onCancel;
  final VoidCallback? onRetry;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      haptic: false,
      child: ClipRRect(
        borderRadius: AppRadius.mdAll,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: const Color(0x1AFFFFFF), // Deep glass
              borderRadius: AppRadius.mdAll,
              border: Border.all(
                color: AppColors.glassBorder,
                width: 0.5,
              ),
            ),
            child: Row(
              children: [
                // ── Thumbnail ─────────────────────────────────────
                _Thumbnail(thumbnail: thumbnail),

                const SizedBox(width: AppSpacing.md),

                // ── Info column ───────────────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title
                      Text(
                        title,
                        style: AppTypography.subheadline.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: AppSpacing.sm),

                      // Progress bar + percentage
                      Row(
                        children: [
                          Expanded(
                            child: _ProgressBar(
                              progress: progress,
                              status: status,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            '${(progress * 100).toInt()} %',
                            style: AppTypography.caption1.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.xs),

                      // Speed / size row
                      Row(
                        children: [
                          Expanded(child: _StatusRow(this)),
                          if (status == DownloadStatus.failed && onRetry != null)
                            _ActionButton(
                              icon: CupertinoIcons.refresh,
                              color: AppColors.warning,
                              onTap: onRetry!,
                            )
                          else if (status != DownloadStatus.complete &&
                              onCancel != null)
                            _ActionButton(
                              icon: CupertinoIcons.clear_thick_circled,
                              color: AppColors.textTertiary,
                              onTap: onCancel!,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── THUMBNAIL ───────────────────────────────────────────────────────────────

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({this.thumbnail});

  final Widget? thumbnail;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadius.smAll,
      child: SizedBox(
        width: 64,
        height: 64,
        child: thumbnail ??
            Container(
              color: AppColors.surface, // Darker surface underneath
              child: const Center(
                child: Icon(
                  CupertinoIcons.play_fill,
                  color: AppColors.textTertiary,
                  size: 22,
                ),
              ),
            ),
      ),
    );
  }
}

// ─── PROGRESS BAR ────────────────────────────────────────────────────────────

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({
    required this.progress,
    required this.status,
  });

  final double progress;
  final DownloadStatus status;

  Color get _fillColor => switch (status) {
        DownloadStatus.downloading => AppColors.primary,
        DownloadStatus.paused => AppColors.warning,
        DownloadStatus.complete => AppColors.success,
        DownloadStatus.failed => AppColors.error,
      };

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            // Track
            Container(
              height: 4,
              width: constraints.maxWidth,
              decoration: BoxDecoration(
                color: const Color(0x33FFFFFF), // Brighter track on dark glass
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Fill
            AnimatedContainer(
              duration: AppDurations.normal,
              curve: AppCurves.standard,
              height: 4,
              width: constraints.maxWidth * progress.clamp(0.0, 1.0),
              decoration: BoxDecoration(
                color: _fillColor,
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  if (status == DownloadStatus.downloading)
                    BoxShadow(
                      color: _fillColor.withAlpha(128),
                      blurRadius: 8,
                      offset: const Offset(0, 0),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─── STATUS ROW ──────────────────────────────────────────────────────────────

class _StatusRow extends StatelessWidget {
  const _StatusRow(this.card);

  final DownloadProgressCard card;

  @override
  Widget build(BuildContext context) {
    final parts = <String>[];

    switch (card.status) {
      case DownloadStatus.downloading:
        if (card.speed != null) parts.add(card.speed!);
        break;
      case DownloadStatus.paused:
        parts.add('Paused');
        break;
      case DownloadStatus.complete:
        parts.add('Complete');
        break;
      case DownloadStatus.failed:
        parts.add('Failed');
        break;
    }

    if (card.downloadedSize != null && card.totalSize != null) {
      parts.add('${card.downloadedSize} / ${card.totalSize}');
    } else if (card.downloadedSize != null) {
      parts.add(card.downloadedSize!);
    }

    final color = switch (card.status) {
      DownloadStatus.failed => AppColors.error,
      DownloadStatus.complete => AppColors.success,
      _ => AppColors.textTertiary,
    };

    return Text(
      parts.join('  ·  '),
      style: AppTypography.caption1.copyWith(
        color: color,
        fontWeight: FontWeight.w500,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

// ─── SMALL ACTION BUTTON ─────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.only(left: AppSpacing.sm),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}
