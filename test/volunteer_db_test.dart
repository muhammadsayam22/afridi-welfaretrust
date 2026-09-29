import 'package:afridiwelfaretrust/database/db_helper.dart';
import 'package:afridiwelfaretrust/models/volunteer_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Integration tests for the volunteer flow backed by the real `DbHelper`.
///
/// On desktop/VM these run against a project-local SQLite file inside
/// `.dart_tool/sqflite_common_ffi/databases`, so they never touch the
/// app's real on-device database.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  group('Volunteer database', () {
    final cleanedUp = <int>[];

    setUpAll(() async {
      await DbHelper.instance.initializeDatabase();
    });

    tearDown(() async {
      for (final id in cleanedUp) {
        await DbHelper.instance.deleteVolunteer(id);
      }
      cleanedUp.clear();
    });

    test('insertVolunteer saves all fields including city and availability',
        () async {
      final id = await DbHelper.instance.insertVolunteer(
        Volunteer(
          name: 'Test Volunteer',
          phone: '0300-1234567',
          email: 'volunteer@test.com',
          city: 'Lahore',
          area: 'Education',
          availability: 'Weekends',
          message: 'I want to help children study',
          createdAt: DateTime.now().toIso8601String(),
        ),
      );

      expect(id, isNotNull);
      if (id != null) cleanedUp.add(id);

      final all = await DbHelper.instance.getVolunteers();
      final saved = all.where((v) => v.id == id).toList();
      expect(saved, hasLength(1));
      expect(saved.first.name, 'Test Volunteer');
      expect(saved.first.city, 'Lahore');
      expect(saved.first.area, 'Education');
      expect(saved.first.availability, 'Weekends');
      expect(saved.first.message, 'I want to help children study');
    });

    test('record survives a database reopen (app restart)',
        () async {
      final id = await DbHelper.instance.insertVolunteer(
        Volunteer(
          name: 'Persistent Volunteer',
          phone: '0311-7654321',
          email: 'persist@test.com',
          city: 'Karachi',
          area: 'Medical Support',
          availability: 'Full Time',
          message: 'Persisting across restart',
          createdAt: DateTime.now().toIso8601String(),
        ),
      );

      expect(id, isNotNull);
      if (id != null) cleanedUp.add(id);

      // Simulate an app restart: close the handle, then reopen from disk.
      await DbHelper.instance.closeDatabase();
      final reopened = await DbHelper.instance.database;
      expect(reopened, isNotNull);

      final all = await DbHelper.instance.getVolunteers();
      final saved = all.where((v) => v.id == id).toList();
      expect(saved, hasLength(1));
      expect(saved.first.name, 'Persistent Volunteer');
      expect(saved.first.city, 'Karachi');
    });

    test('getVolunteers returns newest first and deleteVolunteer removes rows',
        () async {
      final firstId = await DbHelper.instance.insertVolunteer(
        Volunteer(
          name: 'First Volunteer',
          createdAt: DateTime(2025, 1, 1).toIso8601String(),
        ),
      );
      final secondId = await DbHelper.instance.insertVolunteer(
        Volunteer(
          name: 'Second Volunteer',
          createdAt: DateTime(2026, 1, 1).toIso8601String(),
        ),
      );

      expect(firstId, isNotNull);
      expect(secondId, isNotNull);
      if (firstId != null) cleanedUp.add(firstId);
      if (secondId != null) cleanedUp.add(secondId);

      final all = await DbHelper.instance.getVolunteers();
      final idsToIndex = <int, int>{
        for (var i = 0; i < all.length; i++) all[i].id!: i,
      };
      expect(idsToIndex[secondId], lessThan(idsToIndex[firstId]!));

      final removed = await DbHelper.instance.deleteVolunteer(firstId!);
      expect(removed, 1);

      final afterDelete = await DbHelper.instance.getVolunteers();
      expect(afterDelete.where((v) => v.id == firstId), isEmpty);
    });
  });
}