import 'dart:io';

import 'package:video_player/video_player.dart';

/// Creates a controller for a stored gallery video file (IO platforms).
VideoPlayerController createGalleryVideoController(String reference) {
  if (reference.startsWith('data:')) {
    // Defensive fallback - a data URL should never be stored on IO builds.
    return VideoPlayerController.networkUrl(Uri.parse(reference));
  }
  return VideoPlayerController.file(File(reference));
}
