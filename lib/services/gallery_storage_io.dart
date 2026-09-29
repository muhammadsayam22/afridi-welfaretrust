import 'dart:io';
import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Gallery storage for platforms with a real file system.
///
/// Media is copied into the application documents directory so it stays
/// available after the app is restarted and needs no storage permissions.

const String galleryFolderName = 'gallery';

Future<Directory> _galleryDirectory() async {
  final documents = await getApplicationDocumentsDirectory();
  final directory = Directory(p.join(documents.path, galleryFolderName));
  if (!await directory.exists()) {
    await directory.create(recursive: true);
  }
  return directory;
}

String _safeFileName(String original) {
  final name = p.basename(original).trim();
  final cleaned = name.replaceAll(RegExp(r'[^\w\.\-]+'), '_');
  if (cleaned.isEmpty || cleaned == '.') return 'media';
  return cleaned;
}

/// Copies the picked file into the app documents gallery folder.
Future<String> saveGalleryMedia(XFile file) async {
  final directory = await _galleryDirectory();
  final stamp = DateTime.now().microsecondsSinceEpoch;
  final destination = p.join(directory.path, '${stamp}_${_safeFileName(file.name)}');

  try {
    await file.saveTo(destination);
  } catch (_) {
    // Some pickers only expose bytes - fall back to a byte copy.
    final bytes = await file.readAsBytes();
    await File(destination).writeAsBytes(bytes, flush: true);
  }

  return destination;
}

/// Whether the stored file still exists on disk.
Future<bool> galleryMediaExists(String reference) async {
  if (reference.isEmpty) return false;
  if (reference.startsWith('data:')) return true;
  try {
    return await File(reference).exists();
  } catch (_) {
    return false;
  }
}

/// Reads the media bytes (used for photo previews and thumbnails).
Future<Uint8List?> galleryMediaBytes(String reference) async {
  if (reference.isEmpty) return null;
  try {
    final file = File(reference);
    if (!await file.exists()) return null;
    return await file.readAsBytes();
  } catch (_) {
    return null;
  }
}

/// Deletes the media file, ignoring missing/locked files.
Future<void> deleteGalleryMedia(String reference) async {
  if (reference.isEmpty || reference.startsWith('data:')) return;
  try {
    final file = File(reference);
    if (await file.exists()) {
      await file.delete();
    }
  } catch (_) {
    // Best effort - the database row is removed either way.
  }
}
