import 'package:flutter/cupertino.dart';

import 'package:reels/core/theme/app_theme.dart';

/// Placeholder Library screen — will be implemented in a future prompt.
class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: CustomScrollView(
        slivers: [
          const CupertinoSliverNavigationBar(
            largeTitle: Text('Library'),
            border: null,
          ),
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
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
          ),
        ],
      ),
    );
  }
}
