/// Media type values stored in the `gallery.media_type` column.
class GalleryMediaTypes {
  GalleryMediaTypes._();

  static const String photo = 'photo';
  static const String video = 'video';

  /// Friendly labels used by the gallery filter chips.
  static const List<String> all = [photo, video];

  static String labelFor(String mediaType) =>
      mediaType == video ? 'Video' : 'Photo';
}

/// A single photo or video entry of the `gallery` table.
///
/// Only a reference to the media file ([filePath]) is stored in SQLite -
/// either an absolute path inside the application documents directory
/// (Android / iOS / Windows / macOS / Linux) or a `data:` URL (web), so the
/// database stays small and the media survives an app restart.
class GalleryItem {
  final int? id;
  final String title;
  final String filePath;
  final String mediaType;
  final String createdAt;

  const GalleryItem({
    this.id,
    required this.title,
    required this.filePath,
    this.mediaType = GalleryMediaTypes.photo,
    required this.createdAt,
  });

  bool get isVideo => mediaType == GalleryMediaTypes.video;

  bool get isPhoto => !isVideo;

  factory GalleryItem.fromMap(Map<String, Object?> map) {
    return GalleryItem(
      id: map['id'] as int?,
      title: (map['title'] as String?) ?? '',
      filePath: (map['file_path'] as String?) ?? '',
      mediaType: (map['media_type'] as String?) ?? GalleryMediaTypes.photo,
      createdAt: (map['createdAt'] as String?) ??
          (map['created_at'] as String?) ??
          '',
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'file_path': filePath,
      'media_type': mediaType,
      'created_at': createdAt,
    };
  }

  GalleryItem copyWith({
    int? id,
    String? title,
    String? filePath,
    String? mediaType,
    String? createdAt,
  }) {
    return GalleryItem(
      id: id ?? this.id,
      title: title ?? this.title,
      filePath: filePath ?? this.filePath,
      mediaType: mediaType ?? this.mediaType,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
