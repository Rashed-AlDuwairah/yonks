/// Web stub — photo saving and file deletion are no-ops on web.
library;

Future<void> saveToPhotos(String filePath, String title) async {
  // Not supported on web — no-op
}

void deleteFile(String filePath) {
  // Not supported on web — no-op
}
