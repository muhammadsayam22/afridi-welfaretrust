import 'dart:io';

import 'package:afridiwelfaretrust/database/db_helper.dart';
import 'package:afridiwelfaretrust/models/gallery_model.dart';
import 'package:afridiwelfaretrust/services/gallery_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Integration tests for the Education / Food / Medical / Clean Water
/// management records and the photo + video gallery, all backed by the real
/// `DbHelper`.
///
/// On desktop/VM these run against a project-local SQLite file inside
/// `.dart_tool/sqflite_common_ffi/databases`, so they never touch the
/// app's real on-device database.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  final managementCleanup = <MapEntry<String, int>>[];
  final galleryCleanup = <int>[];

  Future<void> cleanup() async {
    for (final entry in managementCleanup) {
      await DbHelper.instance.deleteManagementRecord(entry.key, entry.value);
    }
    managementCleanup.clear();

    for (final id in galleryCleanup) {
      await DbHelper.instance.deleteGalleryItem(id);
    }
    galleryCleanup.clear();
  }

  group('Education management', () {
    setUpAll(() async {
      await DbHelper.instance.initializeDatabase();
    });

    tearDown(cleanup);

    test('insert, search, update and delete an education record', () async {
      final id = await DbHelper.instance.insertManagementRecord('education', {
        'title': 'Test Student Alpha',
        'guardian_name': 'Father of Alpha',
        'class_level': 'Class 5',
        'institute': 'Govt High School',
        'contact': '0300-1112223',
        'area': 'Peshawar',
        'status': 'Active',
        'record_date': '2026-01-05',
        'description': 'Needs books',
      });

      expect(id, isNotNull);
      managementCleanup.add(MapEntry('education', id!));

      final found = await DbHelper.instance.getManagementRecords(
        'education',
        search: 'Alpha',
        searchColumns: ['title', 'area', 'institute'],
      );
      final match = found.where((row) => row['id'] == id).toList();
      expect(match, hasLength(1));
      expect(match.first['title'], 'Test Student Alpha');
      expect(match.first['guardian_name'], 'Father of Alpha');
      expect(match.first['class_level'], 'Class 5');
      expect(match.first['record_date'], '2026-01-05');
      expect(match.first['status'], 'Active');

      final updated = await DbHelper.instance.updateManagementRecord(
        'education',
        id,
        {'status': 'Completed', 'class_level': 'Class 6'},
      );
      expect(updated, 1);

      final byStatus = await DbHelper.instance.getManagementRecords(
        'education',
        status: 'Completed',
        search: 'Alpha',
        searchColumns: ['title'],
      );
      expect(byStatus.where((row) => row['id'] == id), hasLength(1));

      final programs = await DbHelper.instance.getEducationProjects();
      expect(programs.any((item) => item.id == id), isFalse);

      final removed =
          await DbHelper.instance.deleteManagementRecord('education', id);
      expect(removed, 1);

      final afterDelete = await DbHelper.instance.getManagementRecords(
        'education',
        search: 'Alpha',
        searchColumns: ['title'],
      );
      expect(afterDelete.where((row) => row['id'] == id), isEmpty);
    });

    test('unknown tables are rejected', () async {
      final id = await DbHelper.instance.insertManagementRecord(
        'donations',
        {'title': 'Nope'},
      );
      expect(id, isNull);
    });
  });

  group('Food management', () {
    setUpAll(() async {
      await DbHelper.instance.initializeDatabase();
    });

    tearDown(cleanup);

    test('insert, update and delete a food record', () async {
      final id = await DbHelper.instance.insertManagementRecord('food', {
        'title': 'Test Family Bravo',
        'family_members': '6',
        'package_type': 'Monthly Ration',
        'quantity': '2 packs',
        'contact': '0311-4445556',
        'area': 'Kohat',
        'distribution_date': '2026-02-10',
        'status': 'Scheduled',
      });

      expect(id, isNotNull);
      managementCleanup.add(MapEntry('food', id!));

      final found = await DbHelper.instance.getManagementRecords(
        'food',
        search: 'Bravo',
        searchColumns: ['title', 'package_type'],
      );
      final match = found.where((row) => row['id'] == id).toList();
      expect(match, hasLength(1));
      expect(match.first['family_members'], '6');
      expect(match.first['distribution_date'], '2026-02-10');

      final updated = await DbHelper.instance.updateManagementRecord(
        'food',
        id,
        {'status': 'Distributed'},
      );
      expect(updated, 1);

      final removed =
          await DbHelper.instance.deleteManagementRecord('food', id);
      expect(removed, 1);
    });
  });

  group('Medical management', () {
    setUpAll(() async {
      await DbHelper.instance.initializeDatabase();
    });

    tearDown(cleanup);

    test('insert, update and delete a medical record', () async {
      final id = await DbHelper.instance.insertManagementRecord('medical', {
        'title': 'Test Patient Charlie',
        'age': '40',
        'contact': '0322-7778889',
        'medical_issue': 'Malaria',
        'treatment': 'Course of tablets',
        'doctor': 'District Hospital',
        'area': 'Mardan',
        'assistance': '5000',
        'record_date': '2026-03-01',
        'status': 'Under Treatment',
      });

      expect(id, isNotNull);
      managementCleanup.add(MapEntry('medical', id!));

      final found = await DbHelper.instance.getManagementRecords(
        'medical',
        search: 'Malaria',
        searchColumns: ['medical_issue', 'title'],
      );
      final match = found.where((row) => row['id'] == id).toList();
      expect(match, hasLength(1));
      expect(match.first['age'], '40');
      expect(match.first['doctor'], 'District Hospital');
      expect(match.first['assistance'], '5000');

      final updated = await DbHelper.instance.updateManagementRecord(
        'medical',
        id,
        {'status': 'Recovered'},
      );
      expect(updated, 1);

      final removed =
          await DbHelper.instance.deleteManagementRecord('medical', id);
      expect(removed, 1);
    });
  });

  group('Clean water management', () {
    setUpAll(() async {
      await DbHelper.instance.initializeDatabase();
    });

    tearDown(cleanup);

    test('insert, update and delete a clean water record', () async {
      final id = await DbHelper.instance.insertManagementRecord('clean_water', {
        'title': 'Test Well Delta',
        'location': 'Village Darra',
        'water_type': 'Water Well',
        'beneficiaries': '120',
        'estimated_cost': '75000',
        'status': 'In Progress',
        'start_date': '2026-01-15',
        'completion_date': '',
        'description': 'Deep well near the mosque',
      });

      expect(id, isNotNull);
      managementCleanup.add(MapEntry('clean_water', id!));

      final found = await DbHelper.instance.getManagementRecords(
        'clean_water',
        search: 'Darra',
        searchColumns: ['title', 'location'],
      );
      final match = found.where((row) => row['id'] == id).toList();
      expect(match, hasLength(1));
      expect(match.first['beneficiaries'], '120');
      expect(match.first['estimated_cost'], '75000');

      final updated = await DbHelper.instance.updateManagementRecord(
        'clean_water',
        id,
        {'status': 'Completed', 'completion_date': '2026-04-01'},
      );
      expect(updated, 1);

      final removed =
          await DbHelper.instance.deleteManagementRecord('clean_water', id);
      expect(removed, 1);
    });
  });

  group('Gallery', () {
    setUpAll(() async {
      await DbHelper.instance.initializeDatabase();
    });

    tearDown(cleanup);

    test('photo and video entries survive a database restart', () async {
      final stamp = DateTime.now().microsecondsSinceEpoch;
      final photoId = await DbHelper.instance.insertGallery(GalleryItem(
        title: 'Test Photo $stamp',
        filePath: '/missing/photo_$stamp.jpg',
        mediaType: GalleryMediaTypes.photo,
        createdAt: DateTime.now().toIso8601String(),
      ));
      final videoId = await DbHelper.instance.insertGallery(GalleryItem(
        title: 'Test Video $stamp',
        filePath: '/missing/video_$stamp.mp4',
        mediaType: GalleryMediaTypes.video,
        createdAt: DateTime.now().toIso8601String(),
      ));

      expect(photoId, isNotNull);
      expect(videoId, isNotNull);
      if (photoId != null) galleryCleanup.add(photoId);
      if (videoId != null) galleryCleanup.add(videoId);

      // Simulate an app restart: close the handle, reopen it from disk.
      await DbHelper.instance.closeDatabase();
      final reopened = await DbHelper.instance.database;
      expect(reopened, isNotNull);

      final bySearch = await DbHelper.instance
          .getGalleryItems(search: 'Test Photo $stamp');
      final photo = bySearch.where((item) => item.id == photoId).toList();
      expect(photo, hasLength(1));
      expect(photo.first.isPhoto, isTrue);
      expect(photo.first.filePath, '/missing/photo_$stamp.jpg');

      final videos = await DbHelper.instance
          .getGalleryItems(mediaType: GalleryMediaTypes.video);
      final video = videos.where((item) => item.id == videoId).toList();
      expect(video, hasLength(1));
      expect(video.first.isVideo, isTrue);

      final photos = await DbHelper.instance
          .getGalleryItems(mediaType: GalleryMediaTypes.photo);
      expect(photos.any((item) => item.id == photoId), isTrue);

      final removedPhoto =
          await DbHelper.instance.deleteGalleryItem(photoId!);
      expect(removedPhoto, 1);

      final removedVideo =
          await DbHelper.instance.deleteGalleryItem(videoId!);
      expect(removedVideo, 1);

      galleryCleanup.clear();
    });

    test('deleting a missing id is a no-op', () async {
      final removed = await DbHelper.instance.deleteGalleryItem(-999);
      expect(removed, 0);
    });
  });

  group('Gallery storage (IO)', () {
    test('reads, reports and deletes stored files gracefully', () async {
      final directory = await Directory.systemTemp.createTemp('awt_gallery');
      final file = File(p.join(directory.path, 'sample.jpg'));
      await file.writeAsBytes([1, 2, 3, 4]);

      expect(await galleryMediaExists(file.path), isTrue);

      final bytes = await galleryMediaBytes(file.path);
      expect(bytes, isNotNull);
      expect(bytes, hasLength(4));

      await deleteGalleryMedia(file.path);
      expect(await galleryMediaExists(file.path), isFalse);
      expect(await galleryMediaBytes(file.path), isNull);

      // Missing files must never throw.
      expect(await galleryMediaExists('${directory.path}/gone.jpg'), isFalse);
      expect(await galleryMediaBytes('${directory.path}/gone.jpg'), isNull);
      await deleteGalleryMedia('${directory.path}/gone.jpg');

      await directory.delete(recursive: true);
    });
  });
}
