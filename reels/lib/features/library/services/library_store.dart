import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'package:reels/features/library/models/library_entry.dart';

/// A lightweight, JSON-based local database for storing downloaded video metadata.
class LibraryStore {
  static const _fileName = 'reels_library.json';
  File? _file;
  List<LibraryEntry> _entries = [];

  Future<void> init() async {
    final directory = await getApplicationDocumentsDirectory();
    _file = File('${directory.path}/$_fileName');

    if (await _file!.exists()) {
      try {
        final contents = await _file!.readAsString();
        final List<dynamic> jsonList = jsonDecode(contents);
        _entries = jsonList.map((j) => LibraryEntry.fromJson(j)).toList();
      } catch (e) {
        // If file is corrupted, start fresh
        _entries = [];
      }
    }
  }

  List<LibraryEntry> get entries => List.unmodifiable(_entries);

  Future<void> addEntry(LibraryEntry entry) async {
    _entries.insert(0, entry); // Newest first
    await _save();
  }

  Future<void> removeEntry(String id) async {
    _entries.removeWhere((e) => e.id == id);
    await _save();
  }

  Future<void> _save() async {
    if (_file == null) return;
    final jsonList = _entries.map((e) => e.toJson()).toList();
    await _file!.writeAsString(jsonEncode(jsonList));
  }
}
