import 'package:video_player/video_player.dart';

/// Creates a controller for a stored gallery video reference (web).
///
/// On the web the gallery stores media as a `data:` URL which browsers
/// accept directly as a video source.
VideoPlayerController createGalleryVideoController(String reference) {
  return VideoPlayerController.networkUrl(Uri.parse(reference));
}
