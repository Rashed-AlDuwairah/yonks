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
//  │  ┌──── Download 1080p ─────────┐  │  ← sticky floating button
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

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
        child: Container(
          height: screenHeight * 0.85, // Slightly taller
          decoration: BoxDecoration(
            color: AppColors.background.withAlpha(200), // Deep glass background
            border: Border(
              top: BorderSide(
                color: const Color(0x33FFFFFF), // Subtle top rim light
                width: 0.5,
              ),
            ),
          ),
          child: Stack(
            children: [
              Column(
                children: [
                  // ── Drag handle ────────────────────────────────────
                  _buildDragHandle(),

                  // ── Scrollable content ─────────────────────────────
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        0,
                        AppSpacing.lg,
                        AppSpacing.xxl * 3, // Extra padding for floating button
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Thumbnail
                          _buildThumbnail(),
                          const SizedBox(height: AppSpacing.xl),

                          // Video meta
                          _buildVideoMeta(),
                          const SizedBox(height: AppSpacing.xxl),

                          // Section header
                          Text(
                            'Select Quality',
                            style: AppTypography.title3.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),

                          // Quality cards
                          ...List.generate(widget.info.formats.length, (i) {
                            final fmt = widget.info.formats[i];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: AppSpacing.md), // slightly more spacing
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
                ],
              ),

              // ── Sticky floating download button ─────────────────────────
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      padding: EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.lg,
                        AppSpacing.lg,
                        AppSpacing.lg + bottom,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.background.withAlpha(0),
                            AppColors.background.withAlpha(200),
                            AppColors.background,
                          ],
                        ),
                      ),
                      child: IosButton(
                        label: 'Download ${widget.info.formats[_selectedIndex].resolution}',
                        icon: CupertinoIcons.arrow_down_to_line_alt, // More elegant icon
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          Navigator.of(context).pop();
                          widget.onDownload(
                            widget.info.formats[_selectedIndex].formatId,
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Drag handle ──────────────────────────────────────────────────────

  Widget _buildDragHandle() {
    return Center(
      child: Container(
        width: 40, // Slightly wider
        height: 5,
        margin: const EdgeInsets.only(top: 12, bottom: 20),
        decoration: BoxDecoration(
          color: const Color(0x66FFFFFF), // More translucent white
          borderRadius: BorderRadius.circular(2.5),
        ),
      ),
    );
  }

  // ─── Thumbnail ────────────────────────────────────────────────────────

  Widget _buildThumbnail() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: AppRadius.lgAll, // Larger radius
        boxShadow: [
          BoxShadow(
            color: const Color(0x33000000), // Subtle shadow
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: AppRadius.lgAll,
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: widget.info.thumbnail.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: widget.info.thumbnail,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: AppColors.surface,
                    child: const Center(child: CupertinoActivityIndicator()),
                  ),
                  errorWidget: (context, url, error) => _thumbnailFallback(),
                )
              : _thumbnailFallback(),
        ),
      ),
    );
  }

  Widget _thumbnailFallback() {
    return Container(
      color: AppColors.surface,
      child: const Center(
        child: Icon(
          CupertinoIcons.play_fill,
          color: AppColors.textTertiary,
          size: 40,
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
          style: AppTypography.title2.copyWith( // Larger
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),

        const SizedBox(height: AppSpacing.sm),

        // Platform · uploader · duration
        Row(
          children: [
            _PlatformDot(platform: widget.info.platform),
            const SizedBox(width: AppSpacing.sm),
            Flexible(
              child: Text(
                '@${widget.info.uploader}',
                style: AppTypography.body.copyWith( // Slightly larger
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              '·',
              style: AppTypography.subheadline.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
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
      width: 10, // slightly larger
      height: 10,
      decoration: BoxDecoration(
        color: _color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: _color.withAlpha(128),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
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
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16), // Deeper blur
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0x66000000), // Glassier black
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: const Color(0x1AFFFFFF), // Subtle white border
              width: 0.5,
            ),
          ),
          child: Text(
            duration,
            style: AppTypography.caption1.copyWith(
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
