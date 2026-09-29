import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'database/db_helper.dart';
import 'models/gallery_model.dart';
import 'services/gallery_storage.dart';
import 'widgets/management_common.dart';

/// Full screen photo preview with zoom and deletion support.
///
/// Returns `true` to the caller when the media was deleted so the gallery
/// can refresh. Missing files are shown as a friendly placeholder instead
/// of crashing.
class GalleryPhotoViewerScreen extends StatefulWidget {
  const GalleryPhotoViewerScreen({super.key, required this.item});

  final GalleryItem item;

  @override
  State<GalleryPhotoViewerScreen> createState() =>
      _GalleryPhotoViewerScreenState();
}

class _GalleryPhotoViewerScreenState extends State<GalleryPhotoViewerScreen> {
  bool _deleting = false;

  Future<void> _delete() async {
    if (_deleting) return;

    final confirmed = await confirmDelete(
      context,
      title: 'Delete Photo',
      message: 'Are you sure you want to delete this item?',
    );
    if (!confirmed || !mounted) return;

    setState(() => _deleting = true);

    final id = widget.item.id;
    final affected = id == null
        ? null
        : await DbHelper.instance.deleteGalleryItem(id);
    await deleteGalleryMedia(widget.item.filePath);

    if (!mounted) return;

    if (affected == null || affected <= 0) {
      setState(() => _deleting = false);
      showAppMessage(context, 'Could not delete this photo.');
      return;
    }

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.item.title.isEmpty ? 'Photo' : widget.item.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Delete photo',
            onPressed: _delete,
            icon: _deleting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.delete_outline_rounded,
                    color: Colors.redAccent),
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<Uint8List?>(
          future: galleryMediaBytes(widget.item.filePath),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            final bytes = snapshot.data;
            if (bytes == null || bytes.isEmpty) {
              return _missingFile();
            }

            return InteractiveViewer(
              maxScale: 5,
              child: Center(
                child: Image.memory(
                  bytes,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      _missingFile(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _missingFile() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.broken_image_outlined,
                size: 70, color: Colors.grey.shade500),
            const SizedBox(height: 14),
            const Text(
              'Photo not available',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'The file for this gallery item is missing or was '
              'removed from this device.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade400,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: _delete,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white54),
              ),
              icon: const Icon(Icons.delete_outline_rounded),
              label: const Text('Remove from Gallery'),
            ),
          ],
        ),
      ),
    );
  }
}
