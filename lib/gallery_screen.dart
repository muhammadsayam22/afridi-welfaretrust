import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'database/db_helper.dart';
import 'gallery_photo_viewer_screen.dart';
import 'gallery_video_player_screen.dart';
import 'models/gallery_model.dart';
import 'services/gallery_storage.dart';
import 'theme/app_colors.dart';
import 'utils/formats.dart';
import 'widgets/gallery_thumbnail.dart';
import 'widgets/management_common.dart';

/// Photo + video gallery backed by the local SQLite database.
///
/// Media files are copied into the application storage (or encoded for the
/// web build) and only their reference is stored in the `gallery` table, so
/// everything survives an app restart. Supports uploading, searching,
/// filtering by type, previews and confirmation protected deletion.
class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  List<GalleryItem> _items = const [];
  bool _loading = true;
  bool _saving = false;
  String _typeFilter = 'All';
  Timer? _debounce;

  static const List<String> _filters = ['All', 'Photos', 'Videos'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final mediaType = _typeFilter == 'Photos'
        ? GalleryMediaTypes.photo
        : (_typeFilter == 'Videos' ? GalleryMediaTypes.video : null);

    final items = await DbHelper.instance.getGalleryItems(
      search: _searchController.text,
      mediaType: mediaType,
    );

    if (!mounted) return;
    setState(() {
      _items = items;
      _loading = false;
    });
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), _load);
  }

  // ================================================================
  // UPLOAD
  // ================================================================

  Future<void> _showUploadSheet() async {
    if (_saving) return;

    final source = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(18, 18, 18, 6),
              child: Text(
                'Upload Media',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ),
            const SizedBox(height: 4),
            ListTile(
              leading: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.lightGreen,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.image_rounded,
                    color: AppColors.primary),
              ),
              title: const Text(
                'Select Photo',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: const Text('JPG, JPEG, PNG or WEBP'),
              onTap: () => Navigator.pop(context, 'photo'),
            ),
            const Divider(height: 1),
            ListTile(
              leading: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.videocam_rounded,
                    color: Colors.blue),
              ),
              title: const Text(
                'Select Video',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: const Text('MP4, MOV, AVI (platform supported)'),
              onTap: () => Navigator.pop(context, 'video'),
            ),
            const Divider(height: 1),
            ListTile(
              leading: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child:
                    Icon(Icons.close_rounded, color: Colors.grey.shade600),
              ),
              title: const Text(
                'Cancel',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (source == null || !mounted) return;

    try {
      final XFile? file = source == 'photo'
          ? await _picker.pickImage(source: ImageSource.gallery)
          : await _picker.pickVideo(source: ImageSource.gallery);

      if (file == null || !mounted) return;
      await _saveMedia(file, source);
    } catch (_) {
      if (mounted) {
        showAppMessage(context, 'Could not open the media picker.');
      }
    }
  }

  Future<void> _saveMedia(XFile file, String mediaType) async {
    final suggested = _baseName(file.name);
    final title = await _askTitle(suggested);
    if (title == null || !mounted) return;

    setState(() => _saving = true);

    String reference;
    try {
      reference = await saveGalleryMedia(file);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      showAppMessage(context, 'Could not save the selected media.');
      return;
    }

    final id = await DbHelper.instance.insertGallery(
      GalleryItem(
        title: title,
        filePath: reference,
        mediaType:
            mediaType == 'video' ? GalleryMediaTypes.video : GalleryMediaTypes.photo,
        createdAt: DateTime.now().toIso8601String(),
      ),
    );

    if (!mounted) return;
    setState(() => _saving = false);

    if (id == null) {
      await deleteGalleryMedia(reference);
      if (mounted) showAppMessage(context, 'Could not save this media item.');
      return;
    }

    showAppMessage(context, 'Media uploaded successfully.');
    _load();
  }

  Future<String?> _askTitle(String suggested) async {
    return showDialog<String>(
      context: context,
      builder: (context) => _MediaTitleDialog(suggested: suggested),
    );
  }

  String _baseName(String fileName) {
    final name = fileName.trim();
    final dot = name.lastIndexOf('.');
    if (dot <= 0) return name.isEmpty ? 'Media' : name;
    return name.substring(0, dot);
  }

  // ================================================================
  // OPEN / DELETE
  // ================================================================

  Future<void> _openItem(GalleryItem item) async {
    final changed = item.isVideo
        ? await Get.to<bool>(() => GalleryVideoPlayerScreen(item: item))
        : await Get.to<bool>(() => GalleryPhotoViewerScreen(item: item));

    if (changed == true && mounted) _load();
  }

  Future<void> _deleteItem(GalleryItem item) async {
    final confirmed = await confirmDelete(
      context,
      title: 'Delete Media',
      message: 'Are you sure you want to delete this item?',
    );
    if (!confirmed || !mounted) return;

    final affected = await DbHelper.instance.deleteGalleryItem(item.id ?? -1);
    await deleteGalleryMedia(item.filePath);

    if (!mounted) return;

    if (affected == null || affected <= 0) {
      showAppMessage(context, 'Could not delete this media item.');
      return;
    }

    showAppMessage(context, 'Media deleted.');
    _load();
  }

  // ================================================================
  // UI
  // ================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Gallery',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Upload media',
            onPressed: _showUploadSheet,
            icon: const Icon(Icons.upload_rounded),
            color: Colors.white,
          ),
          IconButton(
            tooltip: 'Refresh',
            onPressed: _load,
            icon: const Icon(Icons.refresh_rounded),
            color: Colors.white,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showUploadSheet,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_photo_alternate_rounded),
        label: const Text(
          'Upload Media',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildFilters(),
            Expanded(child: _buildGrid()),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 14, 15, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _searchController,
            onChanged: (_) => _onSearchChanged(),
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Search media by title',
              prefixIcon:
                  const Icon(Icons.search_rounded, color: AppColors.primary),
              suffixIcon: _searchController.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear search',
                      icon: const Icon(Icons.clear_rounded, color: Colors.grey),
                      onPressed: () {
                        _searchController.clear();
                        _load();
                      },
                    ),
              filled: true,
              fillColor: Theme.of(context).cardColor,
              isDense: true,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final filter in _filters)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(filter),
                      selected: _typeFilter == filter,
                      onSelected: (_) {
                        setState(() => _typeFilter = filter);
                        _load();
                      },
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: _typeFilter == filter
                            ? Colors.white
                            : AppColors.darkGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      side: BorderSide(
                        color: _typeFilter == filter
                            ? AppColors.primary
                            : Colors.grey.shade300,
                      ),
                      showCheckmark: false,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_items.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _load,
      color: AppColors.primary,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: LayoutBuilder(
            builder: (context, constraints) {
              const padding = 15.0;
              const spacing = 14.0;

              final width = constraints.maxWidth;
              final columns = width >= 1080
                  ? 4
                  : (width >= 780 ? 3 : (width >= 480 ? 2 : 2));
              final tileWidth =
                  (width - (padding * 2) - (spacing * (columns - 1))) /
                      columns;
              final extent = ((tileWidth - 16) * 0.75) + 74;

              return GridView.builder(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.all(padding),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  mainAxisSpacing: spacing,
                  crossAxisSpacing: spacing,
                  mainAxisExtent: extent,
                ),
                itemCount: _items.length,
                itemBuilder: (context, index) => _buildTile(_items[index]),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTile(GalleryItem item) {
    final isVideo = item.isVideo;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _openItem(item),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  GalleryThumbnail(item: item),
                  if (isVideo)
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.15),
                            Colors.black.withValues(alpha: 0.55),
                          ],
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.play_circle_fill_rounded,
                          color: Colors.white,
                          size: 52,
                        ),
                      ),
                    ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: (isVideo ? Colors.blue : AppColors.primary)
                            .withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        GalleryMediaTypes.labelFor(item.mediaType),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 4, 4),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title.isEmpty ? 'Untitled' : item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        formatDateLabel(item.createdAt),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Open media',
                  onPressed: () => _openItem(item),
                  icon: Icon(
                    isVideo
                        ? Icons.play_arrow_rounded
                        : Icons.fullscreen_rounded,
                    size: 20,
                    color: AppColors.primary,
                  ),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 30, minHeight: 30),
                ),
                IconButton(
                  tooltip: 'Delete media',
                  onPressed: () => _deleteItem(item),
                  icon: const Icon(Icons.delete_outline_rounded,
                      size: 20, color: Colors.red),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 30, minHeight: 30),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_library_outlined,
                size: 70, color: Colors.grey.shade400),
            const SizedBox(height: 14),
            const Text(
              'No media found',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Upload photos and videos to build the '
              'Afridi Welfare Trust gallery.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: _showUploadSheet,
              icon: const Icon(Icons.upload_rounded),
              label: const Text('Upload Media'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small dialog asking for the media title before saving an upload.
class _MediaTitleDialog extends StatefulWidget {
  const _MediaTitleDialog({required this.suggested});

  final String suggested;

  @override
  State<_MediaTitleDialog> createState() => _MediaTitleDialogState();
}

class _MediaTitleDialogState extends State<_MediaTitleDialog> {
  late final TextEditingController _controller;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.suggested);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Row(
        children: [
          Icon(Icons.edit_rounded, color: AppColors.primary),
          SizedBox(width: 10),
          Expanded(child: Text('Media Title')),
        ],
      ),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            labelText: 'Title *',
            hintText: 'Enter a title for this media',
            prefixIcon: const Icon(Icons.title_rounded,
                color: AppColors.primary),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
          validator: (value) => (value ?? '').trim().isEmpty
              ? 'Please enter a title'
              : null,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton.icon(
          onPressed: () {
            if (!(_formKey.currentState?.validate() ?? false)) return;
            Navigator.pop(context, _controller.text.trim());
          },
          icon: const Icon(Icons.save_rounded, size: 18),
          label: const Text(
            'Save',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
