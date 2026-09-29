import 'package:afridiwelfaretrust/database/db_helper.dart';
import 'package:afridiwelfaretrust/models/donation_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Integration tests for the donation flow backed by the real `DbHelper`.
///
/// On desktop/VM these run against a project-local SQLite file inside
/// `.dart_tool/sqflite_common_ffi/databases`, so they never touch the
/// app's real on-device database.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  group('Donation database', () {
    final cleanedUp = <int>[];

    setUpAll(() async {
      await DbHelper.instance.initializeDatabase();
    });

    tearDown(() async {
      for (final id in cleanedUp) {
        await DbHelper.instance.deleteDonation(id);
      }
      cleanedUp.clear();
    });

    test('insertDonation saves all fields and defaults status + date', () async {
      final id = await DbHelper.instance.insertDonation(
        Donation(
          donorName: 'Ali Khan',
          phone: '0300-1234567',
          email: 'ali@test.com',
          amount: 5000,
          category: 'Education',
          paymentMethod: 'Bank Transfer',
          transactionId: 'TXN-100',
          message: 'Support children education',
          createdAt: DateTime(2026, 9, 20).toIso8601String(),
        ),
      );

      expect(id, isNotNull);
      if (id != null) cleanedUp.add(id);

      final all = await DbHelper.instance.getDonations();
      final saved = all.where((d) => d.id == id).toList();
      expect(saved, hasLength(1));
      expect(saved.first.donorName, 'Ali Khan');
      expect(saved.first.phone, '0300-1234567');
      expect(saved.first.amount, 5000);
      expect(saved.first.category, 'Education');
      expect(saved.first.paymentMethod, 'Bank Transfer');
      expect(saved.first.transactionId, 'TXN-100');
      expect(saved.first.status, DonationConstants.statusPending);
      expect(saved.first.donationDate, isNotEmpty);
      expect(saved.first.receiptNumber, startsWith('AWT-DON-'));
    });

    test('receipt numbers are unique for every donation', () async {
      final firstId = await DbHelper.instance.insertDonation(
        Donation(
          donorName: 'First Donor',
          amount: 500,
          paymentMethod: 'Cash',
          createdAt: DateTime.now().toIso8601String(),
        ),
      );
      final secondId = await DbHelper.instance.insertDonation(
        Donation(
          donorName: 'Second Donor',
          amount: 750,
          paymentMethod: 'Easypaisa',
          transactionId: 'EP-2',
          createdAt: DateTime.now().toIso8601String(),
        ),
      );

      expect(firstId, isNotNull);
      expect(secondId, isNotNull);
      if (firstId != null) cleanedUp.add(firstId);
      if (secondId != null) cleanedUp.add(secondId);

      final all = await DbHelper.instance.getDonations();
      final first = all.firstWhere((d) => d.id == firstId);
      final second = all.firstWhere((d) => d.id == secondId);

      expect(first.receiptNumber, isNotEmpty);
      expect(second.receiptNumber, isNotEmpty);
      expect(first.receiptNumber, isNot(second.receiptNumber));
    });

    test('updateDonationStatus changes the record in place (no duplicate)',
        () async {
      final id = await DbHelper.instance.insertDonation(
        Donation(
          donorName: 'Status Donor',
          amount: 1000,
          category: 'Zakat',
          paymentMethod: 'Cash',
          createdAt: DateTime.now().toIso8601String(),
        ),
      );

      expect(id, isNotNull);
      if (id != null) cleanedUp.add(id);

      final changed = await DbHelper.instance.updateDonationStatus(
          id!, DonationConstants.statusVerified);
      expect(changed, 1);

      final all = await DbHelper.instance.getDonations();
      final matching = all.where((d) => d.id == id).toList();
      expect(matching, hasLength(1));
      expect(matching.first.status, DonationConstants.statusVerified);

      final rejected = await DbHelper.instance.updateDonationStatus(
          id, DonationConstants.statusRejected);
      expect(rejected, 1);
    });

    test('filtered search finds donations by donor name and receipt number',
        () async {
      final idA = await DbHelper.instance.insertDonation(
        Donation(
          donorName: 'Zara Unique Name',
          phone: '0311-9998888',
          amount: 2000,
          category: 'Food',
          paymentMethod: 'JazzCash',
          transactionId: 'JC-A9',
          createdAt: DateTime(2026, 8, 1).toIso8601String(),
        ),
      );
      final idB = await DbHelper.instance.insertDonation(
        Donation(
          donorName: 'Common Name',
          phone: '0322-1112222',
          amount: 1500,
          category: 'Medical',
          paymentMethod: 'Bank Transfer',
          transactionId: 'BT-B7',
          createdAt: DateTime(2026, 8, 2).toIso8601String(),
        ),
      );

      expect(idA, isNotNull);
      expect(idB, isNotNull);
      if (idA != null) cleanedUp.add(idA);
      if (idB != null) cleanedUp.add(idB);

      final byName =
          await DbHelper.instance.getDonations(search: 'Zara Unique');
      expect(byName.where((d) => d.id == idA), hasLength(1));
      expect(byName.where((d) => d.id == idB), isEmpty);

      final byStatus =
          await DbHelper.instance.getDonations(status: 'Pending');
      expect(byStatus.where((d) => d.id == idA), hasLength(1));

      final all = await DbHelper.instance.getDonations(category: 'Food');
      expect(all.where((d) => d.id == idA), hasLength(1));
      expect(all.where((d) => d.id == idB), isEmpty);

      final receipts = await DbHelper.instance.getDonations();
      final idACard = receipts.where((d) => d.id == idA).first;
      final byReceipt = await DbHelper.instance
          .getDonations(search: idACard.receiptNumber);
      expect(byReceipt.where((d) => d.id == idA), hasLength(1));
    });

    test('editing keeps the same record (no new row created)', () async {
      final id = await DbHelper.instance.insertDonation(
        Donation(
          donorName: 'Before Edit',
          amount: 400,
          category: 'Clean Water',
          paymentMethod: 'Cash',
          createdAt: DateTime.now().toIso8601String(),
        ),
      );

      expect(id, isNotNull);
      if (id != null) cleanedUp.add(id);

      final allBefore = await DbHelper.instance.getDonations();
      final original = allBefore.firstWhere((d) => d.id == id);

      final updated = Donation(
        id: original.id,
        donorName: 'After Edit',
        phone: original.phone,
        email: original.email,
        amount: 999,
        category: 'General Donation',
        paymentMethod: original.paymentMethod,
        transactionId: original.transactionId,
        message: original.message,
        donationDate: original.donationDate,
        status: original.status,
        receiptNumber: original.receiptNumber,
        createdAt: original.createdAt,
      );
      final rowsAffected = await DbHelper.instance.updateDonation(updated);
      expect(rowsAffected, greaterThan(0));

      final allAfter = await DbHelper.instance.getDonations();
      final matching = allAfter.where((d) => d.id == id).toList();
      expect(matching, hasLength(1));
      expect(matching.first.donorName, 'After Edit');
      expect(matching.first.amount, 999);
      expect(matching.first.category, 'General Donation');
    });

    test('donationStats calculates totals from the database', () async {
      final id = await DbHelper.instance.insertDonation(
        Donation(
          donorName: 'Stats Donor',
          amount: 2500,
          category: 'General Donation',
          paymentMethod: 'Bank Transfer',
          transactionId: 'STATS-1',
          createdAt: DateTime.now().toIso8601String(),
        ),
      );
      expect(id, isNotNull);
      if (id != null) cleanedUp.add(id);

      final stats = await DbHelper.instance.donationStats();
      expect(stats.totalDonations, greaterThan(0));
      expect(stats.totalAmount, greaterThanOrEqualTo(2500));
      expect(stats.pendingCount, greaterThan(0));
      expect(stats.verifiedCount, greaterThanOrEqualTo(0));
      expect(stats.rejectedCount, greaterThanOrEqualTo(0));
    });
  });
}