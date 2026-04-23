import 'package:dio/dio.dart';

import 'package:reels/core/constants/api_constants.dart';
import 'package:reels/features/downloader/models/video_info.dart';

// ═══════════════════════════════════════════════════════════════════════════════
//  API SERVICE — Dio wrapper for the Reels Python backend.
// ═══════════════════════════════════════════════════════════════════════════════

/// Thrown when the backend returns a structured error or a network fault occurs.
class ApiException implements Exception {
  final String code;
  final String message;
  final String? details;
  const ApiException({required this.code, required this.message, this.details});

  @override
  String toString() => 'ApiException($code): $message';
}

class ApiService {
  late final Dio _dio;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
      ),
    );
  }

  // ─── /info ─────────────────────────────────────────────────────────────

  /// Fetch video metadata and available formats.
  Future<VideoInfo> fetchVideoInfo(String url) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/info',
        queryParameters: {'url': url},
      );

      final data = response.data!;

      // Backend may return 200 with an error body in some edge cases
      if (data.containsKey('error')) {
        final err = ApiError.fromJson(data);
        throw ApiException(
          code: err.code,
          message: err.message,
          details: err.details,
        );
      }

      return VideoInfo.fromJson(data);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  // ─── /download ─────────────────────────────────────────────────────────

  /// Download video to [savePath] with live progress callback.
  ///
  /// Returns the save path on success.
  Future<String> downloadVideo({
    required String videoUrl,
    required String formatId,
    required String savePath,
    void Function(double progress, String speed)? onProgress,
    CancelToken? cancelToken,
  }) async {
    int lastBytes = 0;
    DateTime lastTime = DateTime.now();

    try {
      await _dio.download(
        '/download',
        savePath,
        queryParameters: {'url': videoUrl, 'format_id': formatId},
        cancelToken: cancelToken,
        options: Options(receiveTimeout: ApiConstants.downloadTimeout),
        onReceiveProgress: (received, total) {
          if (total <= 0) return;

          final progress = (received / total).clamp(0.0, 1.0);

          // Speed calculation (update every 500 ms to avoid jitter)
          String speed = '';
          final now = DateTime.now();
          final elapsed = now.difference(lastTime);
          if (elapsed.inMilliseconds >= 500) {
            final bps = (received - lastBytes) / (elapsed.inMilliseconds / 1000);
            speed = _formatSpeed(bps);
            lastBytes = received;
            lastTime = now;
          }

          onProgress?.call(progress, speed);
        },
      );
      return savePath;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        throw const ApiException(code: 'CANCELLED', message: 'Download cancelled.');
      }
      throw _mapDioError(e);
    }
  }

  // ─── Helpers ───────────────────────────────────────────────────────────

  ApiException _mapDioError(DioException e) {
    // Try to extract structured error from response body
    if (e.response?.data is Map<String, dynamic>) {
      try {
        final err = ApiError.fromJson(e.response!.data as Map<String, dynamic>);
        return ApiException(code: err.code, message: err.message, details: err.details);
      } catch (_) {
        // Ignore parse failures — fall through to generic error
      }
    }

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.connectionError) {
      return const ApiException(
        code: 'SERVER_ERROR',
        message: 'Cannot reach the server.\nMake sure the backend is running.',
      );
    }

    return ApiException(
      code: 'SERVER_ERROR',
      message: 'Something went wrong. Please try again.',
      details: e.message,
    );
  }

  static String _formatSpeed(double bytesPerSecond) {
    const mb = 1024 * 1024;
    const kb = 1024;
    if (bytesPerSecond >= mb) {
      return '${(bytesPerSecond / mb).toStringAsFixed(1)} MB/s';
    }
    if (bytesPerSecond >= kb) {
      return '${(bytesPerSecond / kb).toStringAsFixed(0)} KB/s';
    }
    return '${bytesPerSecond.toStringAsFixed(0)} B/s';
  }
}
