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

class _LibraryScreenState extends State<LibraryScreen> {
  late final LibraryStore _store;

  @override
  void initState() {
    super.initState();
    _store = GetIt.I<LibraryStore>();
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
      child: CustomScrollView(
        slivers: [
          const CupertinoSliverNavigationBar(
            largeTitle: Text('Library'),
            border: null,
          ),
          if (entries.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      CupertinoIcons.play_rectangle,
                      size: 56,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Your Library',
                      style: AppTypography.title3.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                      child: Text(
                        'Downloaded videos will appear here.\nStart by downloading your first video!',
                        style: AppTypography.subheadline.copyWith(
                          color: AppColors.textTertiary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(AppSpacing.md),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 9 / 16,
                  crossAxisSpacing: AppSpacing.sm,
                  mainAxisSpacing: AppSpacing.sm,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final entry = entries[index];
                    return VideoThumbnailCard(
                      thumbnail: CachedNetworkImage(
                        imageUrl: entry.thumbnail,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => const Center(
                          child: Icon(CupertinoIcons.video_camera, color: AppColors.textTertiary),
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
}
