import 'package:reels/features/downloader/models/video_info.dart';

/// Represents a downloaded video stored in the local library.
class LibraryEntry {
  final String id;
  final String title;
  final String thumbnail;
  final String platform;
  final int duration;
  final String resolution;
  final int filesize;
  final DateTime downloadedAt;
  final String localPath;

  const LibraryEntry({
    required this.id,
    required this.title,
    required this.thumbnail,
    required this.platform,
    required this.duration,
    required this.resolution,
    required this.filesize,
    required this.downloadedAt,
    required this.localPath,
  });

  factory LibraryEntry.fromVideoInfo({
    required VideoInfo info,
    required String formatId,
    required String localPath,
  }) {
    final format = info.formats.firstWhere(
      (f) => f.formatId == formatId,
      orElse: () => info.formats.first,
    );

    return LibraryEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: info.title,
      thumbnail: info.thumbnail,
      platform: info.platform,
      duration: info.duration,
      resolution: format.resolution,
      filesize: format.filesize,
      downloadedAt: DateTime.now(),
      localPath: localPath,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'thumbnail': thumbnail,
        'platform': platform,
        'duration': duration,
        'resolution': resolution,
        'filesize': filesize,
        'downloadedAt': downloadedAt.toIso8601String(),
        'localPath': localPath,
      };

  factory LibraryEntry.fromJson(Map<String, dynamic> json) => LibraryEntry(
        id: json['id'] as String,
        title: json['title'] as String,
        thumbnail: json['thumbnail'] as String,
        platform: json['platform'] as String,
        duration: json['duration'] as int,
        resolution: json['resolution'] as String,
        filesize: json['filesize'] as int,
        downloadedAt: DateTime.parse(json['downloadedAt'] as String),
        localPath: json['localPath'] as String,
      );
}
