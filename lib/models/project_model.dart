/// Project model reflecting various project/category tables.
class Project {
  final int? id;
  final String title;
  final String description;
  final String image;
  final String category;
  final String status;
  final String createdAt;

  const Project({
    this.id,
    required this.title,
    this.description = "",
    this.image = "",
    this.category = "",
    this.status = "",
    required this.createdAt,
  });

  factory Project.fromMap(Map<String, Object?> map) {
    return Project(
      id: map["id"] as int?,
      title: (map["title"] as String?) ?? "",
      description: (map["description"] as String?) ?? "",
      image: (map["image"] as String?) ?? "",
      category: (map["category"] as String?) ?? "",
      status: (map["status"] as String?) ?? "",
      createdAt: (map["createdAt"] as String?) ?? (map["created_at"] as String?) ?? "",
    );
  }

  Map<String, Object?> toMap() {
    return {
      "id": id,
      "title": title,
      "description": description,
      "image": image,
      "category": category,
      "status": status,
      "created_at": createdAt,
    };
  }
}

/// Marker used for rows that belong to the public category pages.
const String kProgramRecordType = 'program';

/// Marker used for rows created through the management screens.
const String kManagementRecordType = 'record';

/// Education model (education table).
///
/// Besides the public "program" rows used by the Education category page,
/// this table also stores beneficiary records created in the Education
/// Management screen (see [recordType]).
class Education {
  final int? id;
  final String title;
  final String description;
  final String image;
  final String guardianName;
  final String classLevel;
  final String institute;
  final String contact;
  final String area;
  final String status;
  final String recordDate;
  final String recordType;
  final String createdAt;

  const Education({
    this.id,
    required this.title,
    this.description = "",
    this.image = "",
    this.guardianName = "",
    this.classLevel = "",
    this.institute = "",
    this.contact = "",
    this.area = "",
    this.status = "",
    this.recordDate = "",
    this.recordType = kProgramRecordType,
    required this.createdAt,
  });

  /// Whether this row was created through the Education Management screen.
  bool get isManagementRecord => recordType == kManagementRecordType;

  factory Education.fromMap(Map<String, Object?> map) {
    return Education(
      id: map["id"] as int?,
      title: (map["title"] as String?) ?? "",
      description: (map["description"] as String?) ?? "",
      image: (map["image"] as String?) ?? "",
      guardianName: (map["guardian_name"] as String?) ?? "",
      classLevel: (map["class_level"] as String?) ?? "",
      institute: (map["institute"] as String?) ?? "",
      contact: (map["contact"] as String?) ?? "",
      area: (map["area"] as String?) ?? "",
      status: (map["status"] as String?) ?? "",
      recordDate: (map["record_date"] as String?) ?? "",
      recordType: (map["record_type"] as String?) ?? kProgramRecordType,
      createdAt: (map["createdAt"] as String?) ?? (map["created_at"] as String?) ?? "",
    );
  }

  Map<String, Object?> toMap() {
    return {
      "id": id,
      "title": title,
      "description": description,
      "image": image,
      "guardian_name": guardianName,
      "class_level": classLevel,
      "institute": institute,
      "contact": contact,
      "area": area,
      "status": status,
      "record_date": recordDate,
      "record_type": recordType,
      "created_at": createdAt,
    };
  }
}


/// Food model (food table).
class Food {
  final int? id;
  final String title;
  final String description;
  final String image;
  final String familyMembers;
  final String packageType;
  final String quantity;
  final String contact;
  final String area;
  final String distributionDate;
  final String status;
  final String recordType;
  final String createdAt;

  const Food({
    this.id,
    required this.title,
    this.description = "",
    this.image = "",
    this.familyMembers = "",
    this.packageType = "",
    this.quantity = "",
    this.contact = "",
    this.area = "",
    this.distributionDate = "",
    this.status = "",
    this.recordType = kProgramRecordType,
    required this.createdAt,
  });

  /// Whether this row was created through the Food Management screen.
  bool get isManagementRecord => recordType == kManagementRecordType;

  factory Food.fromMap(Map<String, Object?> map) {
    return Food(
      id: map["id"] as int?,
      title: (map["title"] as String?) ?? "",
      description: (map["description"] as String?) ?? "",
      image: (map["image"] as String?) ?? "",
      familyMembers: (map["family_members"] as String?) ?? "",
      packageType: (map["package_type"] as String?) ?? "",
      quantity: (map["quantity"] as String?) ?? "",
      contact: (map["contact"] as String?) ?? "",
      area: (map["area"] as String?) ?? "",
      distributionDate: (map["distribution_date"] as String?) ?? "",
      status: (map["status"] as String?) ?? "",
      recordType: (map["record_type"] as String?) ?? kProgramRecordType,
      createdAt: (map["createdAt"] as String?) ?? (map["created_at"] as String?) ?? "",
    );
  }

  Map<String, Object?> toMap() {
    return {
      "id": id,
      "title": title,
      "description": description,
      "image": image,
      "family_members": familyMembers,
      "package_type": packageType,
      "quantity": quantity,
      "contact": contact,
      "area": area,
      "distribution_date": distributionDate,
      "status": status,
      "record_type": recordType,
      "created_at": createdAt,
    };
  }
}


/// Medical model (medical table).
class Medical {
  final int? id;
  final String title;
  final String description;
  final String image;
  final String age;
  final String contact;
  final String medicalIssue;
  final String treatment;
  final String doctor;
  final String area;
  final String assistance;
  final String recordDate;
  final String status;
  final String recordType;
  final String createdAt;

  const Medical({
    this.id,
    required this.title,
    this.description = "",
    this.image = "",
    this.age = "",
    this.contact = "",
    this.medicalIssue = "",
    this.treatment = "",
    this.doctor = "",
    this.area = "",
    this.assistance = "",
    this.recordDate = "",
    this.status = "",
    this.recordType = kProgramRecordType,
    required this.createdAt,
  });

  /// Whether this row was created through the Medical Management screen.
  bool get isManagementRecord => recordType == kManagementRecordType;

  factory Medical.fromMap(Map<String, Object?> map) {
    return Medical(
      id: map["id"] as int?,
      title: (map["title"] as String?) ?? "",
      description: (map["description"] as String?) ?? "",
      image: (map["image"] as String?) ?? "",
      age: (map["age"] as String?) ?? "",
      contact: (map["contact"] as String?) ?? "",
      medicalIssue: (map["medical_issue"] as String?) ?? "",
      treatment: (map["treatment"] as String?) ?? "",
      doctor: (map["doctor"] as String?) ?? "",
      area: (map["area"] as String?) ?? "",
      assistance: (map["assistance"] as String?) ?? "",
      recordDate: (map["record_date"] as String?) ?? "",
      status: (map["status"] as String?) ?? "",
      recordType: (map["record_type"] as String?) ?? kProgramRecordType,
      createdAt: (map["createdAt"] as String?) ?? (map["created_at"] as String?) ?? "",
    );
  }

  Map<String, Object?> toMap() {
    return {
      "id": id,
      "title": title,
      "description": description,
      "image": image,
      "age": age,
      "contact": contact,
      "medical_issue": medicalIssue,
      "treatment": treatment,
      "doctor": doctor,
      "area": area,
      "assistance": assistance,
      "record_date": recordDate,
      "status": status,
      "record_type": recordType,
      "created_at": createdAt,
    };
  }
}


/// Clean Water model (clean_water table).
class CleanWater {
  final int? id;
  final String title;
  final String description;
  final String image;
  final String location;
  final String waterType;
  final String beneficiaries;
  final String estimatedCost;
  final String status;
  final String startDate;
  final String completionDate;
  final String recordType;
  final String createdAt;

  const CleanWater({
    this.id,
    required this.title,
    this.description = "",
    this.image = "",
    this.location = "",
    this.waterType = "",
    this.beneficiaries = "",
    this.estimatedCost = "",
    this.status = "",
    this.startDate = "",
    this.completionDate = "",
    this.recordType = kProgramRecordType,
    required this.createdAt,
  });

  /// Whether this row was created through the Clean Water Management screen.
  bool get isManagementRecord => recordType == kManagementRecordType;

  factory CleanWater.fromMap(Map<String, Object?> map) {
    return CleanWater(
      id: map["id"] as int?,
      title: (map["title"] as String?) ?? "",
      description: (map["description"] as String?) ?? "",
      image: (map["image"] as String?) ?? "",
      location: (map["location"] as String?) ?? "",
      waterType: (map["water_type"] as String?) ?? "",
      beneficiaries: (map["beneficiaries"] as String?) ?? "",
      estimatedCost: (map["estimated_cost"] as String?) ?? "",
      status: (map["status"] as String?) ?? "",
      startDate: (map["start_date"] as String?) ?? "",
      completionDate: (map["completion_date"] as String?) ?? "",
      recordType: (map["record_type"] as String?) ?? kProgramRecordType,
      createdAt: (map["createdAt"] as String?) ?? (map["created_at"] as String?) ?? "",
    );
  }

  Map<String, Object?> toMap() {
    return {
      "id": id,
      "title": title,
      "description": description,
      "image": image,
      "location": location,
      "water_type": waterType,
      "beneficiaries": beneficiaries,
      "estimated_cost": estimatedCost,
      "status": status,
      "start_date": startDate,
      "completion_date": completionDate,
      "record_type": recordType,
      "created_at": createdAt,
    };
  }
}
