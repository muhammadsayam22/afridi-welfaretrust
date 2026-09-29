/// Donation model reflecting the `donations` table.
class Donation {
  final int? id;
  final String donorName;
  final String phone;
  final String email;
  final double amount;
  final String category;
  final String paymentMethod;
  final String transactionId;
  final String message;
  final String donationDate;
  final String status;
  final String receiptNumber;
  final String createdAt;

  const Donation({
    this.id,
    required this.donorName,
    this.phone = "",
    this.email = "",
    required this.amount,
    String purpose = "", // Legacy alias for [category].
    String? category,
    this.paymentMethod = "",
    this.transactionId = "",
    this.message = "",
    this.donationDate = "",
    this.status = "",
    this.receiptNumber = "",
    required this.createdAt,
  }) : category = category ?? purpose;

  factory Donation.fromMap(Map<String, Object?> map) {
    return Donation(
      id: map["id"] as int?,
      donorName: (map["donor_name"] as String?) ?? "",
      phone: (map["phone"] as String?) ?? "",
      email: (map["email"] as String?) ?? "",
      amount: ((map["amount"] as num?) ?? 0).toDouble(),
      category: (map["category"] as String?) ??
          (map["purpose"] as String?) ??
          "",
      paymentMethod: (map["payment_method"] as String?) ?? "",
      transactionId: (map["transaction_id"] as String?) ?? "",
      message: (map["message"] as String?) ?? (map["notes"] as String?) ?? "",
      donationDate: (map["donation_date"] as String?) ?? "",
      status: (map["status"] as String?) ?? DonationConstants.statusPending,
      receiptNumber: (map["receipt_number"] as String?) ?? "",
      createdAt: (map["created_at"] as String?) ?? "",
    );
  }

  Map<String, Object?> toMap() {
    return {
      "id": id,
      "donor_name": donorName,
      "phone": phone,
      "email": email,
      "amount": amount,
      "category": category,
      "payment_method": paymentMethod,
      "transaction_id": transactionId,
      "message": message,
      "donation_date": donationDate,
      "status": status,
      "receipt_number": receiptNumber,
      "created_at": createdAt,
    };
  }
}

/// Shared constants used across the donation management feature.
class DonationConstants {
  DonationConstants._();

  static const String statusPending = "Pending";
  static const String statusVerified = "Verified";
  static const String statusRejected = "Rejected";

  static const List<String> statuses = [
    statusPending,
    statusVerified,
    statusRejected,
  ];

  static const List<String> categories = [
    'General Donation',
    'Education',
    'Food',
    'Medical',
    'Clean Water',
    'Zakat',
  ];

  static const List<String> paymentMethods = [
    'Cash',
    'Bank Transfer',
    'Easypaisa',
    'JazzCash',
  ];
}

/// Aggregate donation statistics calculated from the database.
class DonationStats {
  final int totalDonations;
  final double totalAmount;
  final int pendingCount;
  final int verifiedCount;
  final int rejectedCount;

  const DonationStats({
    required this.totalDonations,
    required this.totalAmount,
    required this.pendingCount,
    required this.verifiedCount,
    required this.rejectedCount,
  });

  const DonationStats.empty()
      : totalDonations = 0,
        totalAmount = 0,
        pendingCount = 0,
        verifiedCount = 0,
        rejectedCount = 0;
}