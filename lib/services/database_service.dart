import 'package:sqflite/sqflite.dart';

import '../database/db_helper.dart';
import '../models/contact_model.dart';
import '../models/donation_model.dart';
import '../models/project_model.dart';
import '../models/volunteer_model.dart';

/// Database service wrapper for database operations
class DatabaseService {
  DatabaseService._();

  static final DatabaseService instance = DatabaseService._();

  Future<Database?> get database => DbHelper.instance.database;

  Future<bool> initialize() => DbHelper.instance.initializeDatabase();

  // Donations
  Future<int?> insertDonation(Donation donation) async {
    return await DbHelper.instance.insertDonation(donation);
  }

  Future<List<Donation>> getDonations({
    String? search,
    String? status,
    String? category,
    String? dateFrom,
    String? dateTo,
  }) async {
    return await DbHelper.instance.getDonations(
      search: search,
      status: status,
      category: category,
      dateFrom: dateFrom,
      dateTo: dateTo,
    );
  }

  Future<int?> updateDonationStatus(int id, String status) {
    return DbHelper.instance.updateDonationStatus(id, status);
  }

  Future<DonationStats> donationStats() {
    return DbHelper.instance.donationStats();
  }

  Future<int?> updateDonation(Donation donation) async {
    final db = await database;
    if (db == null) return null;
    return await db.update(
      "donations",
      donation.toMap(),
      where: "id = ?",
      whereArgs: [donation.id],
    );
  }

  Future<int?> deleteDonation(int id) async {
    final db = await database;
    if (db == null) return null;
    return await db.delete(
      "donations",
      where: "id = ?",
      whereArgs: [id],
    );
  }

  // Volunteers
  Future<int?> insertVolunteer(Volunteer volunteer) async {
    return await DbHelper.instance.insertVolunteer(volunteer);
  }

  Future<List<Volunteer>> getVolunteers() async {
    return await DbHelper.instance.getVolunteers();
  }

  Future<int?> updateVolunteer(Volunteer volunteer) async {
    final db = await database;
    if (db == null) return null;
    return await db.update(
      "volunteers",
      volunteer.toMap(),
      where: "id = ?",
      whereArgs: [volunteer.id],
    );
  }

  Future<int?> deleteVolunteer(int id) async {
    final db = await database;
    if (db == null) return null;
    return await db.delete(
      "volunteers",
      where: "id = ?",
      whereArgs: [id],
    );
  }

  // Contacts
  Future<int?> insertContact(ContactMessage contact) async {
    return await DbHelper.instance.insertContact(contact);
  }

  Future<List<ContactMessage>> getContacts() async {
    return await DbHelper.instance.getContacts();
  }

  Future<int?> deleteContact(int id) async {
    final db = await database;
    if (db == null) return null;
    return await db.delete(
      "contacts",
      where: "id = ?",
      whereArgs: [id],
    );
  }

  // Projects
  Future<int?> insertProject(Project project) async {
    return await DbHelper.instance.insertProject(project);
  }

  Future<List<Project>> getProjects() async {
    return await DbHelper.instance.getProjects();
  }

  Future<List<Project>> getProjectsByCategory(String category) async {
    return await DbHelper.instance.getProjectsByCategory(category);
  }

  Future<int?> updateProject(Project project) async {
    return await DbHelper.instance.updateProject(project);
  }

  Future<int?> deleteProject(int id) async {
    return await DbHelper.instance.deleteProject(id);
  }

  // Category tables
  Future<List<Education>> getEducationProjects() async {
    return await DbHelper.instance.getEducationProjects();
  }

  Future<List<Food>> getFoodProjects() async {
    return await DbHelper.instance.getFoodProjects();
  }

  Future<List<Medical>> getMedicalProjects() async {
    return await DbHelper.instance.getMedicalProjects();
  }

  Future<List<CleanWater>> getCleanWaterProjects() async {
    return await DbHelper.instance.getCleanWaterProjects();
  }
}
