import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../models/gallery_model.dart';
import '../services/gallery_storage.dart';

/// Renders the thumbnail of a gallery photo inside a fixed size box.
///
/// Falls back to a placeholder when the media file is missing or unreadable
/// so a deleted file never crashes the gallery.
class GalleryThumbnail extends StatelessWidget {
  const GalleryThumbnail({
    super.key,
    required this.item,
    this.iconSize = 46,
  });

  final GalleryItem item;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    if (item.isVideo) {
      return const ColoredBox(color: Color(0xFF10231C));
    }

    if (item.filePath.isEmpty) {
      return _placeholder();
    }

    return FutureBuilder<Uint8List?>(
      future: galleryMediaBytes(item.filePath),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const ColoredBox(color: Color(0xFFEDF3F0));
        }

        final bytes = snapshot.data;
        if (bytes == null || bytes.isEmpty) {
          return _placeholder();
        }

        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          gaplessPlayback: true,
          errorBuilder: (context, error, stackTrace) => _placeholder(),
        );
      },
    );
  }

  Widget _placeholder() {
    return ColoredBox(
      color: const Color(0xFFEDF3F0),
      child: Center(
        child: Icon(
          Icons.broken_image_outlined,
          size: iconSize,
          color: Colors.grey.shade400,
        ),
      ),
    );
  }
}
