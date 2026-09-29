/// Platform aware storage for gallery media files.
///
/// * IO platforms (Android / iOS / Windows / macOS / Linux): the picked file
///   is copied into `<app documents>/gallery/` so it survives an app restart
///   and the absolute path is stored in SQLite.
/// * Web: there is no writable file system, so the bytes are stored as a
///   `data:` URL in the `file_path` column (the only persistent option on
///   the web) which keeps records available after a reload.
///
/// Every helper degrades gracefully - a deleted or missing file never
/// throws, it simply reports `false` / `null` so the UI can show a
/// placeholder instead of crashing.
library;

import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

import 'gallery_storage_io.dart'
    if (dart.library.html) 'gallery_storage_web.dart' as storage;

/// Copies (or encodes) the picked media and returns the reference that must
/// be saved in the `gallery.file_path` column.
Future<String> saveGalleryMedia(XFile file) => storage.saveGalleryMedia(file);

/// Whether the stored reference still points at readable media.
Future<bool> galleryMediaExists(String reference) =>
    storage.galleryMediaExists(reference);

/// Raw bytes of the media, used for photo previews. Returns `null` when the
/// file is missing or unreadable.
Future<Uint8List?> galleryMediaBytes(String reference) =>
    storage.galleryMediaBytes(reference);

/// Removes the stored media file. Safe to call for missing files.
Future<void> deleteGalleryMedia(String reference) =>
    storage.deleteGalleryMedia(reference);
