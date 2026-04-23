import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'package:reels/core/theme/app_theme.dart';

// ════════════════════════════════════════════════════════════════════════════════
//  VIDEO THUMBNAIL CARD — Library Grid Item
//
//  ┌──────────────────────┐
//  │ 🏷 Platform          │  ← top-left platform icon badge
//  │                      │
//  │                      │
//  │                      │
//  │                      │
//  │           ▐ 0:30 ▌   │  ← bottom-right blurred duration badge
//  └──────────────────────┘
//
//  Features:
//   • Auto aspect ratio (9:16 portrait / 16:9 landscape)
//   • Platform icon badge (X, TikTok, Instagram, YouTube)
//   • Duration badge with blur background
//   • CupertinoContextMenu long-press (Share, Delete, Copy Link)
//   • Scale-down press animation
// ════════════════════════════════════════════════════════════════════════════════

/// Supported video source platforms.
enum VideoPlatform {
  twitter,
  tiktok,
  instagram,
  youtube,
  other;

  String get label => switch (this) {
        twitter => '𝕏',
        tiktok => '♪',
        instagram => '◎',
        youtube => '▶',
        other => '•',
      };

  Color get color => switch (this) {
        twitter => AppColors.twitter,
        tiktok => AppColors.tiktok,
        instagram => AppColors.instagram,
        youtube => AppColors.youtube,
        other => AppColors.surface3,
      };
}

class VideoThumbnailCard extends StatefulWidget {
  const VideoThumbnailCard({
    super.key,
    required this.thumbnail,
    this.duration,
    this.platform = VideoPlatform.other,
    this.aspectRatio = 9 / 16,
    this.onTap,
    this.onShare,
    this.onDelete,
    this.onCopyLink,
  });

  /// The thumbnail image widget (e.g. CachedNetworkImage, Image.file).
  final Widget thumbnail;

  /// Video duration — rendered as "M:SS" or "H:MM:SS".
  final Duration? duration;

  /// Source platform for the icon badge.
  final VideoPlatform platform;

  /// Aspect ratio of the card. Defaults to 9:16 (portrait).
  final double aspectRatio;

  final VoidCallback? onTap;
  final VoidCallback? onShare;
  final VoidCallback? onDelete;
  final VoidCallback? onCopyLink;

  @override
  State<VideoThumbnailCard> createState() => _VideoThumbnailCardState();
}

class _VideoThumbnailCardState extends State<VideoThumbnailCard> {
  bool _pressed = false;

  // ── Duration formatter ──────────────────────────────────────────────────
  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    if (h > 0) {
      return '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  // ── Build the visual thumbnail (shared between normal + context menu) ──
  Widget _buildContent() {
    return AspectRatio(
      aspectRatio: widget.aspectRatio,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface2,
          borderRadius: AppRadius.mdAll,
          boxShadow: AppShadows.subtle,
        ),
        child: ClipRRect(
          borderRadius: AppRadius.mdAll,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ── Thumbnail image ─────────────────────────────
              widget.thumbnail,

              // ── Platform badge (top-left) ───────────────────
              if (widget.platform != VideoPlatform.other)
                Positioned(
                  left: AppSpacing.sm,
                  top: AppSpacing.sm,
                  child: _PlatformBadge(platform: widget.platform),
                ),

              // ── Duration badge (bottom-right) ───────────────
              if (widget.duration != null)
                Positioned(
                  right: AppSpacing.sm,
                  bottom: AppSpacing.sm,
                  child: _DurationBadge(
                    label: _formatDuration(widget.duration!),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasContextActions =
        widget.onShare != null ||
        widget.onDelete != null ||
        widget.onCopyLink != null;

    final card = GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap?.call();
      },
      child: AnimatedScale(
        scale: _pressed ? AppPressScale.factor : 1.0,
        duration: AppDurations.fast,
        curve: AppCurves.standard,
        child: _buildContent(),
      ),
    );

    if (!hasContextActions) return card;

    // ── Wrap with CupertinoContextMenu for long-press actions ──────────
    return CupertinoContextMenu.builder(
      actions: _buildContextActions(context),
      builder: (context, animation) {
        // When the context menu animation is in progress, replace
        // our card with the preview version (no press animation).
        if (animation.value > 0) {
          return _buildContent();
        }
        return card;
      },
    );
  }

  List<Widget> _buildContextActions(BuildContext context) {
    return [
      if (widget.onShare != null)
        CupertinoContextMenuAction(
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
            HapticFeedback.mediumImpact();
            widget.onShare!();
          },
          trailingIcon: CupertinoIcons.share,
          child: const Text('Share'),
        ),
      if (widget.onCopyLink != null)
        CupertinoContextMenuAction(
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
            HapticFeedback.mediumImpact();
            widget.onCopyLink!();
          },
          trailingIcon: CupertinoIcons.link,
          child: const Text('Copy Link'),
        ),
      if (widget.onDelete != null)
        CupertinoContextMenuAction(
          isDestructiveAction: true,
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
            HapticFeedback.mediumImpact();
            widget.onDelete!();
          },
          trailingIcon: CupertinoIcons.delete,
          child: const Text('Delete'),
        ),
    ];
  }
}

// ─── PLATFORM BADGE ──────────────────────────────────────────────────────────

class _PlatformBadge extends StatelessWidget {
  const _PlatformBadge({required this.platform});

  final VideoPlatform platform;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(7),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: platform.color.withAlpha(204), // 80 %
            borderRadius: BorderRadius.circular(7),
          ),
          child: Center(
            child: Text(
              platform.label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: CupertinoColors.white,
                height: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── DURATION BADGE ──────────────────────────────────────────────────────────

class _DurationBadge extends StatelessWidget {
  const _DurationBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 6,
            vertical: 3,
          ),
          decoration: BoxDecoration(
            color: const Color(0xB3000000), // 70 % black
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            label,
            style: AppTypography.caption2.copyWith(
              color: CupertinoColors.white,
              fontWeight: FontWeight.w600,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ),
    );
  }
}
