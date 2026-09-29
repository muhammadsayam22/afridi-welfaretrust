/// Volunteer model reflecting the `volunteers` table.
class Volunteer {
  final int? id;
  final String name;
  final String phone;
  final String email;
  final String city;
  final String area;
  final String availability;
  final String message;
  final String createdAt;

  const Volunteer({
    this.id,
    required this.name,
    this.phone = "",
    this.email = "",
    this.city = "",
    this.area = "",
    this.availability = "",
    this.message = "",
    required this.createdAt,
  });

  factory Volunteer.fromMap(Map<String, Object?> map) {
    return Volunteer(
      id: map["id"] as int?,
      name: (map["name"] as String?) ?? (map["full_name"] as String?) ?? "",
      phone: (map["phone"] as String?) ?? "",
      email: (map["email"] as String?) ?? "",
      city: (map["city"] as String?) ?? "",
      area: (map["area"] as String?) ??
          (map["volunteer_area"] as String?) ??
          "",
      availability: (map["availability"] as String?) ?? "",
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
      "city": city,
      "area": area,
      "availability": availability,
      "message": message,
      "created_at": createdAt,
    };
  }
}