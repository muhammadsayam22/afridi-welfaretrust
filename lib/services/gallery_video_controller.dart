import 'package:video_player/video_player.dart';

import 'gallery_video_controller_io.dart'
    if (dart.library.html) 'gallery_video_controller_web.dart' as impl;

/// Creates the video controller that matches the current platform.
///
/// * IO platforms play the file stored in the app documents folder.
/// * Web plays the `data:` URL reference created by the web storage layer.
VideoPlayerController createGalleryVideoController(String reference) =>
    impl.createGalleryVideoController(reference);
