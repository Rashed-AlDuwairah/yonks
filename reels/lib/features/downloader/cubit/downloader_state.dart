import 'package:reels/features/downloader/models/video_info.dart';

/// Sealed state hierarchy for the download flow.
///
/// ```
/// Initial ─→ FetchingInfo ─→ InfoLoaded ─→ Downloading ─→ Completed
///                  │               │              │
///                  └───→ Error ←───┘──────────────┘
/// ```
sealed class DownloaderState {
  const DownloaderState();
}

/// Nothing happening yet — show the empty state.
class DownloaderInitial extends DownloaderState {
  const DownloaderInitial();
}

/// Fetching video info from the backend.
class DownloaderFetchingInfo extends DownloaderState {
  final String url;
  const DownloaderFetchingInfo({required this.url});
}

/// Info fetched — ready to show quality picker.
class DownloaderInfoLoaded extends DownloaderState {
  final VideoInfo info;
  final String url;
  const DownloaderInfoLoaded({required this.info, required this.url});
}

/// Download in progress.
class DownloaderDownloading extends DownloaderState {
  final VideoInfo info;
  final String formatId;
  final double progress; // 0.0 … 1.0
  final String speed; // e.g. "12.5 MB/s"

  const DownloaderDownloading({
    required this.info,
    required this.formatId,
    this.progress = 0.0,
    this.speed = '',
  });
}

/// Download finished, video saved to Camera Roll.
class DownloaderCompleted extends DownloaderState {
  final VideoInfo info;
  const DownloaderCompleted({required this.info});
}

/// Something went wrong — show error + retry.
class DownloaderError extends DownloaderState {
  final String code;
  final String message;
  final String? url;
  const DownloaderError({required this.code, required this.message, this.url});
}
