/// Data models matching the backend `/info` JSON contract.
library;

class VideoInfo {
  final String title;
  final String thumbnail;
  final int duration;
  final String uploader;
  final String platform;
  final List<VideoFormat> formats;

  const VideoInfo({
    required this.title,
    required this.thumbnail,
    required this.duration,
    required this.uploader,
    required this.platform,
    required this.formats,
  });

  factory VideoInfo.fromJson(Map<String, dynamic> json) => VideoInfo(
        title: json['title'] as String? ?? 'Untitled',
        thumbnail: json['thumbnail'] as String? ?? '',
        duration: json['duration'] as int? ?? 0,
        uploader: json['uploader'] as String? ?? 'Unknown',
        platform: json['platform'] as String? ?? 'other',
        formats: (json['formats'] as List<dynamic>? ?? [])
            .map((f) => VideoFormat.fromJson(f as Map<String, dynamic>))
            .toList(),
      );

  /// Human-friendly duration string: "3:42" or "1:02:15".
  String get formattedDuration {
    final h = duration ~/ 3600;
    final m = (duration % 3600) ~/ 60;
    final s = duration % 60;
    if (h > 0) {
      return '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}

class VideoFormat {
  final String formatId;
  final String resolution;
  final int width;
  final int height;
  final String ext;
  final int filesize;
  final String vcodec;
  final String acodec;
  final bool hasAudio;

  const VideoFormat({
    required this.formatId,
    required this.resolution,
    required this.width,
    required this.height,
    required this.ext,
    required this.filesize,
    required this.vcodec,
    required this.acodec,
    required this.hasAudio,
  });

  factory VideoFormat.fromJson(Map<String, dynamic> json) => VideoFormat(
        formatId: json['format_id'] as String? ?? '',
        resolution: json['resolution'] as String? ?? '',
        width: json['width'] as int? ?? 0,
        height: json['height'] as int? ?? 0,
        ext: json['ext'] as String? ?? 'mp4',
        filesize: json['filesize'] as int? ?? 0,
        vcodec: json['vcodec'] as String? ?? '',
        acodec: json['acodec'] as String? ?? '',
        hasAudio: json['has_audio'] as bool? ?? false,
      );

  /// Human-friendly file size: "24.3 MB", "1.2 GB".
  String get formattedSize {
    if (filesize <= 0) return 'Unknown size';
    const gb = 1024 * 1024 * 1024;
    const mb = 1024 * 1024;
    const kb = 1024;
    if (filesize >= gb) return '${(filesize / gb).toStringAsFixed(1)} GB';
    if (filesize >= mb) return '${(filesize / mb).toStringAsFixed(1)} MB';
    if (filesize >= kb) return '${(filesize / kb).toStringAsFixed(0)} KB';
    return '$filesize B';
  }
}

/// Structured API error matching the backend error contract.
class ApiError {
  final String code;
  final String message;
  final String? details;

  const ApiError({required this.code, required this.message, this.details});

  factory ApiError.fromJson(Map<String, dynamic> json) {
    final err = json['error'] as Map<String, dynamic>;
    return ApiError(
      code: err['code'] as String? ?? 'SERVER_ERROR',
      message: err['message'] as String? ?? 'An unknown error occurred.',
      details: err['details'] as String?,
    );
  }
}
