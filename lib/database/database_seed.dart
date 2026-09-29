import '../models/project_model.dart';

/// Database seed data for Afridi Welfare Trust
class DatabaseSeed {
  static List<Education> getEducationSeeds() {
    final now = DateTime.now().toIso8601String();
    return [
      Education(
        title: 'Free Primary Education',
        description: 'Providing quality primary education to underprivileged children in rural areas.',
        image: 'assets/edu1.jpg',
        createdAt: now,
      ),
      Education(
        title: 'Scholarship Program',
        description: 'Merit-based scholarships for deserving students to continue higher education.',
        image: 'assets/edu2.jpg',
        createdAt: now,
      ),
      Education(
        title: 'School Supplies Drive',
        description: 'Distributing books, uniforms and stationery to needy students.',
        image: 'assets/edu3.jpg',
        createdAt: now,
      ),
    ];
  }

  static List<Food> getFoodSeeds() {
    final now = DateTime.now().toIso8601String();
    return [
      Food(
        title: 'Daily Meal Program',
        description: 'Nutritious meals provided to children and families in need.',
        image: 'assets/food1.jpg',
        createdAt: now,
      ),
      Food(
        title: 'Ramadan Food Packages',
        description: 'Special food packages distributed during the holy month of Ramadan.',
        image: 'assets/food2.jpg',
        createdAt: now,
      ),
      Food(
        title: 'Emergency Relief',
        description: 'Immediate food assistance during natural disasters and crises.',
        image: 'assets/food3.jpg',
        createdAt: now,
      ),
    ];
  }

  static List<Medical> getMedicalSeeds() {
    final now = DateTime.now().toIso8601String();
    return [
      Medical(
        title: 'Free Medical Camps',
        description: 'Regular health check-ups and medical consultations for the community.',
        image: 'assets/med1.jpg',
        createdAt: now,
      ),
      Medical(
        title: 'Medicine Distribution',
        description: 'Providing essential medicines to those who cannot afford them.',
        image: 'assets/med2.jpg',
        createdAt: now,
      ),
      Medical(
        title: 'Mother & Child Care',
        description: 'Specialized healthcare services for mothers and children.',
        image: 'assets/med3.jpg',
        createdAt: now,
      ),
    ];
  }

  static List<CleanWater> getCleanWaterSeeds() {
    final now = DateTime.now().toIso8601String();
    return [
      CleanWater(
        title: 'Water Well Installation',
        description: 'Installing deep water wells in water-scarce villages.',
        image: 'assets/water1.jpg',
        createdAt: now,
      ),
      CleanWater(
        title: 'Water Purification Systems',
        description: 'Providing clean drinking water through filtration systems.',
        image: 'assets/water2.jpg',
        createdAt: now,
      ),
      CleanWater(
        title: 'Water Tank Distribution',
        description: 'Ensuring access to safe water storage facilities.',
        image: 'assets/water3.jpg',
        createdAt: now,
      ),
    ];
  }
}
