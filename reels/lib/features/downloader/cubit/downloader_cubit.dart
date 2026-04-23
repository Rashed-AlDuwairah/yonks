import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';

import 'package:reels/core/utils/cubit.dart';
import 'package:reels/features/downloader/models/video_info.dart';
import 'package:reels/features/downloader/services/api_service.dart';
import 'package:reels/features/library/models/library_entry.dart';
import 'package:reels/features/library/services/library_store.dart';
import 'downloader_state.dart';

// Conditional imports for non-web platforms
import 'package:reels/features/downloader/cubit/_save_stub.dart'
    if (dart.library.io) 'package:reels/features/downloader/cubit/_save_native.dart'
    as save_impl;

// ═══════════════════════════════════════════════════════════════════════════════
//  DOWNLOADER CUBIT
//
//  Orchestrates: fetch info → pick quality → download → save to Photos → notify.
// ═══════════════════════════════════════════════════════════════════════════════

class DownloaderCubit extends Cubit<DownloaderState> {
  final ApiService _api;
  final LibraryStore _libraryStore;
  final FlutterLocalNotificationsPlugin? _notifications;

  CancelToken? _cancelToken;

  DownloaderCubit({
    required ApiService apiService,
    required LibraryStore libraryStore,
    FlutterLocalNotificationsPlugin? notifications,
  })  : _api = apiService,
        _libraryStore = libraryStore,
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
      if (kIsWeb) {
        // On web: simulate download progress for preview purposes
        for (int i = 1; i <= 10; i++) {
          await Future.delayed(const Duration(milliseconds: 300));
          emit(DownloaderDownloading(
            info: info,
            formatId: formatId,
            progress: i / 10,
            speed: '${(i * 1.2).toStringAsFixed(1)} MB/s',
          ));
        }
        emit(DownloaderCompleted(info: info));
        return;
      }

      // Native platforms: real download
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

      // Save to Camera Roll (iOS/Android only)
      await save_impl.saveToPhotos(savePath, info.title);

      // Clean up temp file
      save_impl.deleteFile(savePath);

      // Save to local JSON library
      final entry = LibraryEntry.fromVideoInfo(
        info: info,
        formatId: formatId,
        localPath: savePath, // We keep the path even if deleted, just for metadata
      );
      await _libraryStore.addEntry(entry);

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

  // ─── Notification ──────────────────────────────────────────────────────

  Future<void> _showCompletionNotification(String title) async {
    if (_notifications == null || kIsWeb) return;

    await _notifications!.show(
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
