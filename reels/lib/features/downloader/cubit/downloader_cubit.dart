import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';

import 'package:reels/core/utils/cubit.dart';
import 'package:reels/features/downloader/models/video_info.dart';
import 'package:reels/features/downloader/services/api_service.dart';
import 'downloader_state.dart';

// ═══════════════════════════════════════════════════════════════════════════════
//  DOWNLOADER CUBIT
//
//  Orchestrates: fetch info → pick quality → download → save to Photos → notify.
// ═══════════════════════════════════════════════════════════════════════════════

class DownloaderCubit extends Cubit<DownloaderState> {
  final ApiService _api;
  final FlutterLocalNotificationsPlugin? _notifications;

  CancelToken? _cancelToken;

  DownloaderCubit({
    required ApiService apiService,
    FlutterLocalNotificationsPlugin? notifications,
  })  : _api = apiService,
        _notifications = notifications,
        super(const DownloaderInitial());

  // ─── Fetch video info ──────────────────────────────────────────────────

  Future<void> fetchVideoInfo(String url) async {
    emit(DownloaderFetchingInfo(url: url));

    try {
      final info = await _api.fetchVideoInfo(url);
      emit(DownloaderInfoLoaded(info: info, url: url));
    } on ApiException catch (e) {
      emit(DownloaderError(code: e.code, message: e.message, url: url));
    } catch (e) {
      emit(DownloaderError(
        code: 'SERVER_ERROR',
        message: 'An unexpected error occurred.',
        url: url,
      ));
    }
  }

  // ─── Start download ────────────────────────────────────────────────────

  Future<void> startDownload({
    required VideoInfo info,
    required String url,
    required String formatId,
  }) async {
    _cancelToken = CancelToken();
    emit(DownloaderDownloading(info: info, formatId: formatId));

    try {
      // Build save path
      final dir = await getTemporaryDirectory();
      final format = info.formats.firstWhere(
        (f) => f.formatId == formatId,
        orElse: () => info.formats.first,
      );
      final safeName = info.title
          .replaceAll(RegExp(r'[^\w\s\-]'), '')
          .trim()
          .replaceAll(RegExp(r'\s+'), '_');
      final fileName = '${safeName.isEmpty ? 'video' : safeName}.${format.ext}';
      final savePath = '${dir.path}/$fileName';

      // Download with progress
      await _api.downloadVideo(
        videoUrl: url,
        formatId: formatId,
        savePath: savePath,
        cancelToken: _cancelToken,
        onProgress: (progress, speed) {
          emit(DownloaderDownloading(
            info: info,
            formatId: formatId,
            progress: progress,
            speed: speed,
          ));
        },
      );

      // Save to Camera Roll
      await _saveToPhotos(savePath, info.title);

      // Clean up temp file
      try {
        File(savePath).deleteSync();
      } catch (_) {}

      // Local notification
      await _showCompletionNotification(info.title);

      emit(DownloaderCompleted(info: info));
    } on ApiException catch (e) {
      if (e.code == 'CANCELLED') {
        emit(const DownloaderInitial());
        return;
      }
      emit(DownloaderError(code: e.code, message: e.message, url: url));
    } catch (e) {
      emit(DownloaderError(
        code: 'DOWNLOAD_FAILED',
        message: 'Download failed. Please try again.',
        url: url,
      ));
    }
  }

  // ─── Cancel / Reset ────────────────────────────────────────────────────

  void cancelDownload() {
    _cancelToken?.cancel();
    _cancelToken = null;
    emit(const DownloaderInitial());
  }

  void reset() {
    _cancelToken?.cancel();
    _cancelToken = null;
    emit(const DownloaderInitial());
  }

  // ─── Save to Camera Roll ──────────────────────────────────────────────

  Future<void> _saveToPhotos(String filePath, String title) async {
    final permission = await PhotoManager.requestPermissionExtend();
    if (!permission.isAuth) return;

    final file = File(filePath);
    if (!file.existsSync()) return;

    await PhotoManager.editor.saveVideo(file, title: title);
  }

  // ─── Notification ──────────────────────────────────────────────────────

  Future<void> _showCompletionNotification(String title) async {
    if (_notifications == null) return;

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch % 100000,
      '✅ Download Complete',
      '$title saved to Camera Roll',
      const NotificationDetails(
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _cancelToken?.cancel();
    super.dispose();
  }
}
