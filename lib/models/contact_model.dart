/// Contact message model reflecting the `contacts` table.
class ContactMessage {
  final int? id;
  final String name;
  final String phone;
  final String email;
  final String subject;
  final String message;
  final String createdAt;

  const ContactMessage({
    this.id,
    required this.name,
    this.phone = "",
    this.email = "",
    this.subject = "",
    required this.message,
    required this.createdAt,
  });

  factory ContactMessage.fromMap(Map<String, Object?> map) {
    return ContactMessage(
      id: map["id"] as int?,
      name: (map["name"] as String?) ?? "",
      phone: (map["phone"] as String?) ?? "",
      email: (map["email"] as String?) ?? "",
      subject: (map["subject"] as String?) ?? "",
      message: (map["message"] as String?) ?? "",
      createdAt: (map["created_at"] as String?) ?? "",
    );
  }

  Map<String, Object?> toMap() {
    return {
      "id": id,
      "name": name,
      "phone": phone,
      "email": email,
      "subject": subject,
      "message": message,
      "created_at": createdAt,
    };
  }
}
