/// Native (iOS/Android) implementation — saves to Camera Roll and deletes temp file.
library;

import 'dart:io';

import 'package:photo_manager/photo_manager.dart';

Future<void> saveToPhotos(String filePath, String title) async {
  final permission = await PhotoManager.requestPermissionExtend();
  if (!permission.isAuth) return;

  final file = File(filePath);
  if (!file.existsSync()) return;

  await PhotoManager.editor.saveVideo(file, title: title);
}

void deleteFile(String filePath) {
  try {
    File(filePath).deleteSync();
  } catch (_) {}
}
