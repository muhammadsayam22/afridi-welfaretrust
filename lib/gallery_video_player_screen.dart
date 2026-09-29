import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'database/db_helper.dart';
import 'models/gallery_model.dart';
import 'services/gallery_storage.dart';
import 'services/gallery_video_controller.dart';
import 'theme/app_colors.dart';
import 'widgets/management_common.dart';

/// Video playback screen for a gallery item.
///
/// The video never starts automatically - the user controls playback with
/// play / pause, seek and restart buttons. Unsupported or missing files are
/// reported with a friendly error state instead of crashing.
class GalleryVideoPlayerScreen extends StatefulWidget {
  const GalleryVideoPlayerScreen({super.key, required this.item});

  final GalleryItem item;

  @override
  State<GalleryVideoPlayerScreen> createState() =>
      _GalleryVideoPlayerScreenState();
}

class _GalleryVideoPlayerScreenState extends State<GalleryVideoPlayerScreen> {
  VideoPlayerController? _controller;
  bool _initializing = true;
  String? _error;
  bool _deleting = false;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  @override
  void dispose() {
    final controller = _controller;
    if (controller != null) {
      controller.removeListener(_onTick);
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _initController() async {
    setState(() {
      _initializing = true;
      _error = null;
    });

    VideoPlayerController? controller;
    try {
      controller = createGalleryVideoController(widget.item.filePath);
      await controller.initialize();

      if (!mounted) {
        await controller.dispose();
        return;
      }

      controller.addListener(_onTick);
      setState(() {
        _controller = controller;
        _initializing = false;
      });
    } catch (_) {
      try {
        await controller?.dispose();
      } catch (_) {
        // Ignore cleanup failures.
      }
      if (!mounted) return;
      setState(() {
        _controller = null;
        _initializing = false;
        _error = 'This video cannot be played on this device. '
            'The file may be missing or the format is not supported.';
      });
    }
  }

  void _onTick() {
    if (mounted) setState(() {});
  }

  void _togglePlayback() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    if (controller.value.isCompleted) {
      controller.seekTo(Duration.zero);
      controller.play();
      return;
    }

    if (controller.value.isPlaying) {
      controller.pause();
    } else {
      controller.play();
    }
  }

  void _seekBy(Duration delta) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    var position = controller.value.position + delta;
    if (position < Duration.zero) position = Duration.zero;

    final duration = controller.value.duration;
    if (duration > Duration.zero && position > duration) position = duration;

    controller.seekTo(position);
  }

  Future<void> _delete() async {
    if (_deleting) return;

    final confirmed = await confirmDelete(
      context,
      title: 'Delete Video',
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
      showAppMessage(context, 'Could not delete this video.');
      return;
    }

    Navigator.pop(context, true);
  }

  String _timeLabel(Duration value) {
    String two(int n) => n.toString().padLeft(2, '0');
    final minutes = value.inMinutes;
    final seconds = value.inSeconds % 60;
    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      return '$hours:${two(minutes % 60)}:${two(seconds)}';
    }
    return '$minutes:${two(seconds)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1512),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1512),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.item.title.isEmpty ? 'Video' : widget.item.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Delete video',
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
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_initializing) {
      return const Center(child: CircularProgressIndicator());
    }

    final error = _error;
    if (error != null) {
      return _errorState(error);
    }

    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return _errorState('This video is not available right now.');
    }

    final value = controller.value;
    final duration = value.duration;
    final position = value.position.inMilliseconds
        .clamp(0, duration.inMilliseconds)
        .toDouble();
    final maxSlider = duration.inMilliseconds.toDouble() <= 0
        ? 1.0
        : duration.inMilliseconds.toDouble();

    return Column(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: _togglePlayback,
            child: Container(
              color: Colors.black,
              width: double.infinity,
              child: Center(
                child: AspectRatio(
                  aspectRatio: value.aspectRatio <= 0
                      ? 16 / 9
                      : value.aspectRatio,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      VideoPlayer(controller),
                      if (!value.isPlaying)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.35),
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(14),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 46,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(22)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Slider(
                value: position,
                max: maxSlider,
                activeColor: AppColors.primary,
                inactiveColor: AppColors.lightGreen,
                onChanged: (newValue) {
                  controller.seekTo(
                    Duration(milliseconds: newValue.round()),
                  );
                },
              ),
              Row(
                children: [
                  Text(
                    _timeLabel(value.position),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _timeLabel(duration),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    tooltip: 'Back 10 seconds',
                    onPressed: () => _seekBy(const Duration(seconds: -10)),
                    icon: const Icon(Icons.replay_10_rounded,
                        color: AppColors.primary),
                  ),
                  const SizedBox(width: 6),
                  SizedBox(
                    width: 62,
                    height: 62,
                    child: FilledButton(
                      onPressed: _togglePlayback,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: const CircleBorder(),
                        padding: EdgeInsets.zero,
                      ),
                      child: Icon(
                        value.isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        size: 34,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  IconButton(
                    tooltip: 'Forward 10 seconds',
                    onPressed: () => _seekBy(const Duration(seconds: 10)),
                    icon: const Icon(Icons.forward_10_rounded,
                        color: AppColors.primary),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _errorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.videocam_off_rounded,
                size: 70, color: Colors.grey.shade500),
            const SizedBox(height: 14),
            const Text(
              'Video unavailable',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade400,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: _initController,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white54),
                  ),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Try Again'),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: _delete,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: const BorderSide(color: Colors.redAccent),
                  ),
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: const Text('Remove'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
