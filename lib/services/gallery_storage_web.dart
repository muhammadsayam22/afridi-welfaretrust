



















































































import 'dart:convert';
import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

/// Gallery storage for the web build.
///
/// Browsers have no writable file system, so the media bytes are stored as
/// a `data:` URL string in SQLite. Data URLs stay available after a page
/// reload, which keeps the gallery working across app restarts.
Future<String> saveGalleryMedia(XFile file) async {
  final bytes = await file.readAsBytes();
  return 'data:${_mimeType(file.name)};base64,${base64Encode(bytes)}';
}

String _mimeType(String fileName) {
  final extension = fileName.contains('.')
      ? fileName.substring(fileName.lastIndexOf('.') + 1).toLowerCase()
      : '';

  switch (extension) {
    case 'jpg':
    case 'jpeg':
      return 'image/jpeg';
    case 'png':
      return 'image/png';
    case 'webp':
      return 'image/webp';
    case 'gif':
      return 'image/gif';
    case 'bmp':
      return 'image/bmp';
    case 'heic':
      return 'image/heic';
    case 'mp4':
      return 'video/mp4';
    case 'mov':
      return 'video/quicktime';
    case 'avi':
      return 'video/x-msvideo';
    case 'mkv':
      return 'video/x-matroska';
    case 'webm':
      return 'video/webm';
    case 'm4v':
      return 'video/x-m4v';
    case '3gp':
      return 'video/3gpp';
    default:
      return 'application/octet-stream';
  }
}

bool _isDataUrl(String reference) => reference.startsWith('data:');

Future<bool> galleryMediaExists(String reference) async =>
    _isDataUrl(reference);

Future<Uint8List?> galleryMediaBytes(String reference) async {
  if (!_isDataUrl(reference)) return null;
  try {
    final comma = reference.indexOf(',');
    if (comma < 0) return null;
    final metadata = reference.substring(5, comma);
    final payload = reference.substring(comma + 1);
    if (metadata.endsWith(';base64')) {
      return base64Decode(payload);
    }
    return utf8.encode(payload);
  } catch (_) {
    return null;
  }
}

Future<void> deleteGalleryMedia(String reference) async {
  // Data URLs live inside the database row - nothing else to clean up.
}
