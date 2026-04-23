import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:shimmer/shimmer.dart';

import 'package:reels/core/theme/app_theme.dart';
import 'package:reels/core/utils/cubit.dart';
import 'package:reels/shared/widgets/download_progress_card.dart';
import 'package:reels/shared/widgets/ios_button.dart';
import 'package:reels/shared/widgets/ios_text_field.dart';
import 'package:reels/features/downloader/cubit/downloader_cubit.dart';
import 'package:reels/features/downloader/cubit/downloader_state.dart';
import 'package:reels/features/downloader/services/api_service.dart';
import 'quality_picker_screen.dart';

// ═══════════════════════════════════════════════════════════════════════════════
//  HOME SCREEN
//
//  ┌───────────────────────────────┐
//  │  Reels           (large title)│
//  │  Paste any video link         │
//  │                               │
//  │  ┌─ 🔗 Paste URL…  📋 ──────┐│
//  │  └────────────────────────────┘│
//  │  ● YouTube detected           │
//  │                               │
//  │  ┌──── Fetch Video ───────┐   │
//  │  └────────────────────────┘   │
//  │                               │
//  │  ── state content ──          │
//  │  (empty / shimmer / progress  │
//  │   / completed / error)        │
//  └───────────────────────────────┘
// ═══════════════════════════════════════════════════════════════════════════════

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final DownloaderCubit _cubit;
  late final TextEditingController _urlController;
  late final AnimationController _pulseCtrl;

  String _detectedPlatform = 'other';

  // ─── Lifecycle ─────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();

    _cubit = DownloaderCubit(
      apiService: GetIt.instance<ApiService>(),
      notifications: GetIt.instance(),
    );

    _urlController = TextEditingController()..addListener(_onUrlChanged);

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _autoPasteFromClipboard();
  }

  @override
  void dispose() {
    _urlController.removeListener(_onUrlChanged);
    _urlController.dispose();
    _pulseCtrl.dispose();
    _cubit.dispose();
    super.dispose();
  }

  // ─── URL helpers ───────────────────────────────────────────────────────

  void _onUrlChanged() {
    final platform = _detectPlatform(_urlController.text.trim());
    if (platform != _detectedPlatform) {
      setState(() => _detectedPlatform = platform);
    }
  }

  Future<void> _autoPasteFromClipboard() async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null && _isVideoUrl(data!.text!)) {
      _urlController.text = data.text!;
    }
  }

  bool _isVideoUrl(String text) {
    try {
      final uri = Uri.parse(text.trim());
      return uri.hasScheme &&
          uri.scheme.startsWith('http') &&
          uri.host.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  String _detectPlatform(String url) {
    if (url.isEmpty) return 'other';
    try {
      final host = Uri.parse(url).host.toLowerCase().replaceFirst('www.', '');
      if (host.contains('youtube') || host.contains('youtu.be')) {
        return 'youtube';
      }
      if (host.contains('twitter') || host.contains('x.com')) return 'twitter';
      if (host.contains('tiktok')) return 'tiktok';
      if (host.contains('instagram')) return 'instagram';
      if (host.contains('reddit')) return 'reddit';
      if (host.contains('facebook') || host.contains('fb.')) return 'facebook';
      if (host.contains('vimeo')) return 'vimeo';
    } catch (_) {}
    return 'other';
  }

  // ─── Actions ───────────────────────────────────────────────────────────

  Future<void> _onFetchVideo() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;
    HapticFeedback.mediumImpact();

    await _cubit.fetchVideoInfo(url);

    if (mounted && _cubit.state is DownloaderInfoLoaded) {
      _showQualityPicker(_cubit.state as DownloaderInfoLoaded);
    }
  }

  void _showQualityPicker(DownloaderInfoLoaded loadedState) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => QualityPickerScreen(
        info: loadedState.info,
        url: loadedState.url,
        onDownload: (formatId) {
          _cubit.startDownload(
            info: loadedState.info,
            url: loadedState.url,
            formatId: formatId,
          );
        },
      ),
    );
  }

  // ─── Build ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: CubitBuilder<DownloaderCubit, DownloaderState>(
        cubit: _cubit,
        builder: (context, state) {
          return CustomScrollView(
            slivers: [
              // Nav bar
              const CupertinoSliverNavigationBar(
                largeTitle: Text('Reels'),
                border: null,
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppSpacing.xs),

                      // Subtitle
                      Text(
                        'Paste any video link',
                        style: AppTypography.subheadline.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // URL field
                      IosTextField(
                        controller: _urlController,
                        onSubmitted: (_) => _onFetchVideo(),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Platform badge
                      _PlatformBadge(platform: _detectedPlatform),
                      const SizedBox(height: AppSpacing.lg),

                      // Fetch button
                      IosButton(
                        label: 'Fetch Video',
                        icon: CupertinoIcons.arrow_down_doc,
                        isLoading: state is DownloaderFetchingInfo,
                        enabled: state is! DownloaderFetchingInfo &&
                            state is! DownloaderDownloading,
                        onTap: _onFetchVideo,
                      ),
                      const SizedBox(height: AppSpacing.xxl),

                      // State-specific content
                      _buildStateContent(state),

                      const SizedBox(height: AppSpacing.xxl),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStateContent(DownloaderState state) {
    return AnimatedSwitcher(
      duration: AppDurations.normal,
      child: switch (state) {
        DownloaderInitial() =>
          _EmptyState(key: const ValueKey('empty'), pulseCtrl: _pulseCtrl),
        DownloaderFetchingInfo() =>
          const _LoadingState(key: ValueKey('loading')),
        DownloaderInfoLoaded() => const SizedBox.shrink(key: ValueKey('loaded')),
        DownloaderDownloading(
          info: final info,
          progress: final p,
          speed: final s,
        ) =>
          _DownloadingState(
            key: const ValueKey('downloading'),
            info: info,
            progress: p,
            speed: s,
            onCancel: _cubit.cancelDownload,
          ),
        DownloaderCompleted(info: final info) => _CompletedState(
            key: const ValueKey('completed'),
            info: info,
            onReset: _cubit.reset,
          ),
        DownloaderError(code: final code, message: final msg) => _ErrorState(
            key: const ValueKey('error'),
            code: code,
            message: msg,
            onRetry: _onFetchVideo,
          ),
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  PLATFORM BADGE — shown below the URL field when a platform is detected
// ═══════════════════════════════════════════════════════════════════════════════

class _PlatformBadge extends StatelessWidget {
  const _PlatformBadge({required this.platform});

  final String platform;

  static const _platformData = <String, (String, Color, IconData)>{
    'youtube': ('YouTube', Color(0xFFFF0000), CupertinoIcons.play_rectangle_fill),
    'twitter': ('Twitter / X', Color(0xFF1DA1F2), CupertinoIcons.chat_bubble_fill),
    'tiktok': ('TikTok', Color(0xFF25F4EE), CupertinoIcons.music_note),
    'instagram': ('Instagram', Color(0xFFE1306C), CupertinoIcons.camera_fill),
    'reddit': ('Reddit', Color(0xFFFF5700), CupertinoIcons.bubble_left_fill),
    'facebook': ('Facebook', Color(0xFF1877F2), CupertinoIcons.person_2_fill),
    'vimeo': ('Vimeo', Color(0xFF1AB7EA), CupertinoIcons.play_circle_fill),
  };

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: AppDurations.normal,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.15),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: _platformData.containsKey(platform)
          ? _buildBadge(_platformData[platform]!)
          : const SizedBox.shrink(key: ValueKey('none')),
    );
  }

  Widget _buildBadge((String label, Color color, IconData icon) data) {
    final (label, color, icon) = data;
    return Container(
      key: ValueKey(platform),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(26), // 10%
        borderRadius: AppRadius.smAll,
        border: Border.all(color: color.withAlpha(64), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: AppSpacing.sm),
          Text(
            '$label detected',
            style: AppTypography.subheadline.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  EMPTY STATE — animated pulsing icon + instruction + platform icons
// ═══════════════════════════════════════════════════════════════════════════════

class _EmptyState extends StatelessWidget {
  const _EmptyState({super.key, required this.pulseCtrl});

  final AnimationController pulseCtrl;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.xl),

          // Animated icon
          AnimatedBuilder(
            animation: pulseCtrl,
            builder: (context, child) {
              return Opacity(
                opacity: 0.35 + 0.45 * pulseCtrl.value,
                child: Transform.scale(
                  scale: 0.92 + 0.08 * pulseCtrl.value,
                  child: child,
                ),
              );
            },
            child: const Icon(
              CupertinoIcons.arrow_down_circle,
              size: 64,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          Text(
            'Ready to Download',
            style: AppTypography.title3.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Paste a link from YouTube, TikTok,\nInstagram, Twitter, or any platform',
            style: AppTypography.subheadline.copyWith(
              color: AppColors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppSpacing.xxl),

          // Supported platforms row
          const _SupportedPlatformsRow(),
        ],
      ),
    );
  }
}

// ─── Supported platforms strip ───────────────────────────────────────────────

class _SupportedPlatformsRow extends StatelessWidget {
  const _SupportedPlatformsRow();

  static const _platforms = <(String, Color)>[
    ('▶', Color(0xFFFF0000)), // YouTube
    ('𝕏', Color(0xFF1DA1F2)), // Twitter
    ('♪', Color(0xFF25F4EE)), // TikTok
    ('◎', Color(0xFFE1306C)), // Instagram
    ('●', Color(0xFFFF5700)), // Reddit
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final (label, color) in _platforms) ...[
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withAlpha(26),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: color,
                  height: 1,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  LOADING STATE — shimmer skeleton
// ═══════════════════════════════════════════════════════════════════════════════

class _LoadingState extends StatelessWidget {
  const _LoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surface2,
      highlightColor: AppColors.surface3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail skeleton
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.mdAll,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Title skeleton
          Container(
            height: 18,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            height: 18,
            width: 220,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Format card skeletons
          for (int i = 0; i < 3; i++) ...[
            Container(
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadius.mdAll,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  DOWNLOADING STATE — uses DownloadProgressCard from design system
// ═══════════════════════════════════════════════════════════════════════════════

class _DownloadingState extends StatelessWidget {
  const _DownloadingState({
    super.key,
    required this.info,
    required this.progress,
    required this.speed,
    required this.onCancel,
  });

  final dynamic info; // VideoInfo
  final double progress;
  final String speed;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return DownloadProgressCard(
      title: info.title as String,
      progress: progress,
      speed: speed.isNotEmpty ? speed : null,
      status: DownloadStatus.downloading,
      thumbnail: (info.thumbnail as String).isNotEmpty
          ? CachedNetworkImage(
              imageUrl: info.thumbnail as String,
              fit: BoxFit.cover,
            )
          : null,
      onCancel: onCancel,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  COMPLETED STATE — success checkmark + "Download Another"
// ═══════════════════════════════════════════════════════════════════════════════

class _CompletedState extends StatelessWidget {
  const _CompletedState({
    super.key,
    required this.info,
    required this.onReset,
  });

  final dynamic info;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.xl),
          const Icon(
            CupertinoIcons.checkmark_circle_fill,
            size: 64,
            color: AppColors.success,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Download Complete!',
            style: AppTypography.title3.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${info.title}\nSaved to Camera Roll',
            style: AppTypography.subheadline.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.xl),
          IosButton(
            label: 'Download Another',
            icon: CupertinoIcons.arrow_down_circle,
            variant: IosButtonVariant.secondary,
            onTap: onReset,
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  ERROR STATE — icon per error code + message + retry
// ═══════════════════════════════════════════════════════════════════════════════

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    super.key,
    required this.code,
    required this.message,
    required this.onRetry,
  });

  final String code;
  final String message;
  final VoidCallback onRetry;

  IconData get _icon => switch (code) {
        'INVALID_URL' => CupertinoIcons.exclamationmark_triangle_fill,
        'UNSUPPORTED_PLATFORM' => CupertinoIcons.xmark_circle_fill,
        'PRIVATE_VIDEO' => CupertinoIcons.lock_fill,
        'GEO_RESTRICTED' => CupertinoIcons.globe,
        'SERVER_ERROR' => CupertinoIcons.wifi_slash,
        _ => CupertinoIcons.exclamationmark_circle_fill,
      };

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.xl),
          Icon(_icon, size: 52, color: AppColors.error),
          const SizedBox(height: AppSpacing.lg),
          Text(
            message,
            style: AppTypography.body.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          IosButton(
            label: 'Try Again',
            icon: CupertinoIcons.refresh,
            variant: IosButtonVariant.secondary,
            onTap: onRetry,
          ),
        ],
      ),
    );
  }
}
