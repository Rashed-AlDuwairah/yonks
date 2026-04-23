import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'package:reels/core/theme/app_theme.dart';
import 'package:reels/features/downloader/models/video_info.dart';
import 'package:reels/shared/widgets/ios_button.dart';
import 'package:reels/shared/widgets/quality_card.dart';

// ═══════════════════════════════════════════════════════════════════════════════
//  QUALITY PICKER — iOS Bottom Sheet
//
//  ┌────────────────────────────────────┐
//  │             ── handle ──           │
//  │  ┌──────────────────────────────┐  │
//  │  │       thumbnail 16:9        │  │
//  │  └──────────────────────────────┘  │
//  │  Title · @uploader · 3:33         │
//  │                                    │
//  │  Select Quality                    │
//  │  ┌ 1080p  MP4  24.3 MB  ✓ ┐       │
//  │  ┌  720p  MP4  12.1 MB    ┐       │
//  │                                    │
//  │  ┌──── Download 1080p ─────────┐  │  ← sticky
//  └────────────────────────────────────┘
// ═══════════════════════════════════════════════════════════════════════════════

class QualityPickerScreen extends StatefulWidget {
  const QualityPickerScreen({
    super.key,
    required this.info,
    required this.url,
    required this.onDownload,
  });

  final VideoInfo info;
  final String url;
  final ValueChanged<String> onDownload;

  @override
  State<QualityPickerScreen> createState() => _QualityPickerScreenState();
}

class _QualityPickerScreenState extends State<QualityPickerScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.82,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // ── Drag handle ────────────────────────────────────
          _buildDragHandle(),

          // ── Scrollable content ─────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thumbnail
                  _buildThumbnail(),
                  const SizedBox(height: AppSpacing.lg),

                  // Video meta
                  _buildVideoMeta(),
                  const SizedBox(height: AppSpacing.xl),

                  // Section header
                  Text(
                    'Select Quality',
                    style: AppTypography.headline.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Quality cards
                  ...List.generate(widget.info.formats.length, (i) {
                    final fmt = widget.info.formats[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: QualityCard(
                        resolution: fmt.resolution,
                        format: fmt.ext.toUpperCase(),
                        fileSize: fmt.formattedSize,
                        isSelected: i == _selectedIndex,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _selectedIndex = i);
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          // ── Sticky download button ─────────────────────────
          Container(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.md + bottom,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(
                top: BorderSide(color: AppColors.separator, width: 0.5),
              ),
            ),
            child: IosButton(
              label:
                  'Download ${widget.info.formats[_selectedIndex].resolution}',
              icon: CupertinoIcons.arrow_down_to_line,
              onTap: () {
                HapticFeedback.mediumImpact();
                Navigator.of(context).pop();
                widget.onDownload(
                  widget.info.formats[_selectedIndex].formatId,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ─── Drag handle ──────────────────────────────────────────────────────

  Widget _buildDragHandle() {
    return Center(
      child: Container(
        width: 36,
        height: 5,
        margin: const EdgeInsets.only(top: 10, bottom: 14),
        decoration: BoxDecoration(
          color: AppColors.separator,
          borderRadius: BorderRadius.circular(2.5),
        ),
      ),
    );
  }

  // ─── Thumbnail ────────────────────────────────────────────────────────

  Widget _buildThumbnail() {
    return ClipRRect(
      borderRadius: AppRadius.mdAll,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: widget.info.thumbnail.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: widget.info.thumbnail,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: AppColors.surface2,
                  child: const Center(child: CupertinoActivityIndicator()),
                ),
                errorWidget: (context, url, error) => _thumbnailFallback(),
              )
            : _thumbnailFallback(),
      ),
    );
  }

  Widget _thumbnailFallback() {
    return Container(
      color: AppColors.surface2,
      child: const Center(
        child: Icon(
          CupertinoIcons.play_fill,
          color: AppColors.textTertiary,
          size: 36,
        ),
      ),
    );
  }

  // ─── Video meta ───────────────────────────────────────────────────────

  Widget _buildVideoMeta() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          widget.info.title,
          style: AppTypography.title3.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),

        const SizedBox(height: AppSpacing.sm),

        // Platform · uploader · duration
        Row(
          children: [
            _PlatformDot(platform: widget.info.platform),
            const SizedBox(width: AppSpacing.xs),
            Flexible(
              child: Text(
                '@${widget.info.uploader}',
                style: AppTypography.subheadline.copyWith(
                  color: AppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              '·',
              style: AppTypography.subheadline.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            _DurationPill(duration: widget.info.formattedDuration),
          ],
        ),
      ],
    );
  }
}

// ─── Platform color dot ──────────────────────────────────────────────────────

class _PlatformDot extends StatelessWidget {
  const _PlatformDot({required this.platform});

  final String platform;

  Color get _color => switch (platform) {
        'youtube' => AppColors.youtube,
        'twitter' => AppColors.twitter,
        'tiktok' => AppColors.tiktok,
        'instagram' => AppColors.instagram,
        'reddit' => const Color(0xFFFF5700),
        'facebook' => const Color(0xFF1877F2),
        _ => AppColors.textTertiary,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: _color, shape: BoxShape.circle),
    );
  }
}

// ─── Duration pill ──────────────────────────────────────────────────────────

class _DurationPill extends StatelessWidget {
  const _DurationPill({required this.duration});

  final String duration;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.surface3,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            duration,
            style: AppTypography.caption2.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ),
    );
  }
}
