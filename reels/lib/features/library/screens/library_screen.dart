import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';

import 'package:reels/core/theme/app_theme.dart';
import 'package:reels/features/library/services/library_store.dart';
import 'package:reels/shared/widgets/video_thumbnail_card.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late final LibraryStore _store;
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _store = GetIt.I<LibraryStore>();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  VideoPlatform _parsePlatform(String p) {
    try {
      return VideoPlatform.values.byName(p.toLowerCase());
    } catch (_) {
      return VideoPlatform.other;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Force rebuild when tab is switched to ensure fresh data
    final entries = _store.entries;

    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: const Text('Library'),
            backgroundColor: AppColors.background.withAlpha(200), // Glass header
            border: null,
          ),
          if (entries.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _buildEmptyState(),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Larger, more cinematic 2-column layout
                  childAspectRatio: 9 / 16,
                  crossAxisSpacing: AppSpacing.md,
                  mainAxisSpacing: AppSpacing.md,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final entry = entries[index];
                    return VideoThumbnailCard(
                      thumbnail: CachedNetworkImage(
                        imageUrl: entry.thumbnail,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Container(
                          color: AppColors.surface,
                          child: const Center(
                            child: Icon(CupertinoIcons.video_camera,
                                color: AppColors.textTertiary),
                          ),
                        ),
                      ),
                      duration: Duration(seconds: entry.duration),
                      platform: _parsePlatform(entry.platform),
                      onDelete: () async {
                        await _store.removeEntry(entry.id);
                        setState(() {}); // refresh UI
                      },
                      onTap: () {
                        // TODO: Open native iOS player
                      },
                    );
                  },
                  childCount: entries.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Animated glowing icon
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              final scale = 1.0 + (_pulseController.value * 0.05);
              final opacity = 0.5 + (_pulseController.value * 0.5);
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(opacity * 0.3),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      CupertinoIcons.rectangle_on_rectangle_angled,
                      size: 64,
                      color: AppColors.primary.withOpacity(opacity),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Your Library',
            style: AppTypography.title2.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
            child: Text(
              'Downloaded videos will appear here.\nStart by downloading your first video!',
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl * 2), // Lift up slightly
        ],
      ),
    );
  }
}
