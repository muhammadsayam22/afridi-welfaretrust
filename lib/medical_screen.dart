
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'database/db_helper.dart';
import 'models/project_model.dart';
import 'widgets/database_program_grid.dart';


class MedicalScreen extends StatelessWidget {
  const MedicalScreen({super.key});

  static const Color primaryGreen = Color(0xFF087F5B);
  static const Color secondGreen = Color(0xFF12B886);
  static const Color darkGreen = Color(0xFF063B2B);
  static const Color lightGreen = Color(0xFFE8F5E9);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),

      // =========================================================
      // APP BAR
      // =========================================================

      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,

        title: const Row(
          children: [
            Icon(
              Icons.local_hospital_rounded,
              size: 27,
            ),
            SizedBox(width: 10),
            Text(
              "Medical Support",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),

      // =========================================================
      // BODY
      // =========================================================

      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const SizedBox(height: 18),

            // =====================================================
            // HERO SECTION
            // =====================================================

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),

              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),

                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      primaryGreen,
                      secondGreen,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),

                  borderRadius: BorderRadius.circular(25),

                  boxShadow: [
                    BoxShadow(
                      color: primaryGreen.withValues(alpha: 0.25),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),

                child: Row(
                  children: [

                    Expanded(
                      flex: 6,

                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [

                          Container(
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),

                            decoration: BoxDecoration(
                              color:
                                  Colors.white.withValues(alpha: 0.15),
                              borderRadius:
                                  BorderRadius.circular(30),
                            ),

                            child: const Text(
                              "HEALTHCARE FOR EVERYONE",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ),

                          const SizedBox(height: 15),

                          const Text(
                            "Care For Health,\nHope For Life",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              height: 1.15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 12),

                          const Text(
                            "Helping people access essential healthcare, "
                            "medicines and medical assistance when they "
                            "need it most.",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              height: 1.6,
                            ),
                          ),

                          const SizedBox(height: 20),

                         
                        ],
                      ),
                    ),

                    if (width > 500)
                      Expanded(
                        flex: 4,

                        child: Column(
                          children: [

                            Icon(
                              Icons.local_hospital_rounded,
                              size: 110,
                              color:
                                  Colors.white.withValues(alpha: 0.18),
                            ),

                            const SizedBox(height: 5),

                            Icon(
                              Icons.favorite_rounded,
                              size: 35,
                              color:
                                  Colors.white.withValues(alpha: 0.15),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // =====================================================
            // MISSION
            // =====================================================

            _sectionTitle(
              "Our Medical Mission",
              "Healthcare should never be a privilege",
            ),

            const SizedBox(height: 16),

            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 18),

              child: Container(
                width: double.infinity,

                padding: const EdgeInsets.all(21),

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius:
                      BorderRadius.circular(21),

                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.black.withValues(alpha: 0.05),
                      blurRadius: 14,
                      offset:
                          const Offset(0, 5),
                    ),
                  ],
                ),

                child: Column(
                  children: [

                    Container(
                      width: 70,
                      height: 70,

                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEE),
                        shape: BoxShape.circle,
                      ),

                      child: const Icon(
                        Icons.health_and_safety_rounded,
                        color: Colors.red,
                        size: 35,
                      ),
                    ),

                    const SizedBox(height: 14),

                    const Text(
                      "Health & Dignity For All",
                      textAlign: TextAlign.center,

                      style: TextStyle(
                        color: primaryGreen,
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      "Afridi Welfare Trust works to support "
                      "people and families who face difficulties "
                      "accessing essential healthcare. We aim to "
                      "provide medical assistance and help people "
                      "get the care they need.",

                      textAlign: TextAlign.center,

                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 13,
                        height: 1.7,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // =====================================================
            // MEDICAL PROGRAMS
            // =====================================================

            _sectionTitle(
              "Our Medical Programs",
              "Different ways we support healthcare",
            ),

            const SizedBox(height: 16),

            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 18),

              child: DatabaseProgramGrid<Medical>(
                loader: DbHelper.instance.getMedicalProjects(),
                selector: (item) => ProgramRecord(
                  title: item.title,
                  description: item.description,
                  image: item.image,
                ),
                fallbackIcon: Icons.medical_services_rounded,
                fallbackColor: Colors.red,
              ),
            ),

            const SizedBox(height: 32),

            // =====================================================
            // HEALTHCARE SERVICES
            // =====================================================

            _sectionTitle(
              "Healthcare Support",
              "Essential areas where help can make a difference",
            ),

            const SizedBox(height: 16),

            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 18),

              child: Container(
                padding: const EdgeInsets.all(18),

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius:
                      BorderRadius.circular(20),

                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.black.withValues(alpha: 0.05),
                      blurRadius: 12,
                      offset:
                          const Offset(0, 5),
                    ),
                  ],
                ),

                child: Column(
                  children: [

                    _medicalItem(
                      Icons.medication_rounded,
                      "Medicines",
                      "Essential medicine assistance",
                    ),

                    _medicalItem(
                      Icons.local_hospital_rounded,
                      "Hospital Care",
                      "Support for necessary treatment",
                    ),

                    _medicalItem(
                      Icons.biotech_rounded,
                      "Medical Tests",
                      "Help with essential testing",
                    ),

                    _medicalItem(
                      Icons.health_and_safety_rounded,
                      "Health Awareness",
                      "Promoting better health awareness",
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // =====================================================
            // IMPACT
            // =====================================================

            _sectionTitle(
              "Our Medical Impact",
              "Every helping hand can bring hope",
            ),

            const SizedBox(height: 16),

            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 18),

              child: Container(
                padding:
                    const EdgeInsets.symmetric(
                  vertical: 23,
                  horizontal: 8,
                ),

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius:
                      BorderRadius.circular(22),

                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.black.withValues(alpha: 0.05),
                      blurRadius: 14,
                      offset:
                          const Offset(0, 5),
                    ),
                  ],
                ),

                child: Row(
                  children: [

                    _impactItem(
                      Icons.people_alt_rounded,
                      "Patients",
                      "Supported",
                    ),

                    _verticalDivider(),

                    _impactItem(
                      Icons.medication_rounded,
                      "Medicines",
                      "Assisted",
                    ),

                    _verticalDivider(),

                    _impactItem(
                      Icons.health_and_safety_rounded,
                      "Health",
                      "Improved",
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // =====================================================
            // HOW WE HELP
            // =====================================================

            _sectionTitle(
              "How We Help",
              "Our approach to medical assistance",
            ),

            const SizedBox(height: 16),

            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 18),

              child: Column(
                children: [

                  _helpStep(
                    number: "01",
                    icon: Icons.search_rounded,
                    title: "Identify the Need",
                    description:
                        "We identify people and families "
                        "who need healthcare assistance.",
                  ),

                  _helpStep(
                    number: "02",
                    icon: Icons.fact_check_rounded,
                    title: "Understand the Situation",
                    description:
                        "We understand the medical and "
                        "support needs of the individual.",
                  ),

                  _helpStep(
                    number: "03",
                    icon: Icons.medical_services_rounded,
                    title: "Arrange Support",
                    description:
                        "We work to provide appropriate "
                        "medical assistance where possible.",
                  ),

                  _helpStep(
                    number: "04",
                    icon: Icons.favorite_rounded,
                    title: "Provide Care",
                    description:
                        "We aim to support people with "
                        "compassion, dignity and care.",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // =====================================================
            // WHY HEALTHCARE
            // =====================================================

            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 18),

              child: Container(
                width: double.infinity,

                padding: const EdgeInsets.all(23),

                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),

                  borderRadius:
                      BorderRadius.circular(22),

                  border: Border.all(
                    color: const Color(0xFFB7E4C7),
                  ),
                ),

                child: Column(
                  children: [

                    Container(
                      width: 62,
                      height: 62,

                      decoration: const BoxDecoration(
                        color: primaryGreen,
                        shape: BoxShape.circle,
                      ),

                      child: const Icon(
                        Icons.favorite_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),

                    const SizedBox(height: 14),

                    const Text(
                      "Why Healthcare Matters",
                      textAlign: TextAlign.center,

                      style: TextStyle(
                        color: primaryGreen,
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      "Good healthcare can protect families, "
                      "reduce suffering and give people the "
                      "opportunity to live healthier lives. "
                      "Your support can help someone receive "
                      "care when they need it.",

                      textAlign: TextAlign.center,

                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 13,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // =====================================================
            // CTA
            // =====================================================

            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 18),

              child: Container(
                width: double.infinity,

                padding: const EdgeInsets.all(24),

                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      primaryGreen,
                      secondGreen,
                    ],
                  ),

                  borderRadius:
                      BorderRadius.circular(22),

                  boxShadow: [
                    BoxShadow(
                      color:
                          primaryGreen.withValues(alpha: 0.20),
                      blurRadius: 15,
                      offset:
                          const Offset(0, 6),
                    ),
                  ],
                ),

                child: Column(
                  children: [

                    const Icon(
                      Icons.volunteer_activism_rounded,
                      color: Colors.white,
                      size: 46,
                    ),

                    const SizedBox(height: 11),

                    const Text(
                      "Help Someone Get Medical Care",
                      textAlign: TextAlign.center,

                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      "Your contribution can help provide "
                      "medical support to someone in need.",

                      textAlign: TextAlign.center,

                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 18),

                  
                  ],
                ),
              ),
            ),

            const SizedBox(height: 35),

            // =====================================================
            // SUPPORT CTA
            // =====================================================

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF087F5B), Color(0xFF099268)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF087F5B).withValues(alpha: 0.25),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.local_hospital_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Support Medical Care",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Your donation helps patients access essential "
                      "medicines and treatment they cannot afford.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton.icon(
                        onPressed: () => Get.toNamed(
                          '/donate',
                          arguments: {'donationType': 'Medical Aid'},
                        ),
                        icon: const Icon(Icons.favorite_rounded, size: 18),
                        label: const Text(
                          "Donate Now",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD4A017),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // =====================================================
            // FOOTER
            // =====================================================

            Container(
              width: double.infinity,

              padding:
                  const EdgeInsets.symmetric(
                vertical: 28,
                horizontal: 20,
              ),

              color: darkGreen,

              child: Column(
                children: [

                  Container(
                    width: 60,
                    height: 60,

                    padding:
                        const EdgeInsets.all(6),

                    decoration: BoxDecoration(
                      color: Colors.white,

                      borderRadius:
                          BorderRadius.circular(15),
                    ),

                    child: Image.asset(
                      "assets/logo.png",
                      fit: BoxFit.contain,
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    "Afridi Welfare Trust",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    "Serving Humanity With Love & Care",
                    textAlign: TextAlign.center,

                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 12,
                    ),
                  ),

                  const SizedBox(height: 18),

                  const Divider(
                    color: Colors.white24,
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "© 2026 Afridi Welfare Trust",
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =============================================================
  // SECTION TITLE
  // =============================================================

  Widget _sectionTitle(
    String title,
    String subtitle,
  ) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 18),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Row(
            children: [

              Container(
                width: 5,
                height: 28,

                decoration: BoxDecoration(
                  color: primaryGreen,

                  borderRadius:
                      BorderRadius.circular(10),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  title,

                  style: const TextStyle(
                    color: primaryGreen,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 5),

          Padding(
            padding:
                const EdgeInsets.only(left: 15),

            child: Text(
              subtitle,

              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =============================================================
  // MEDICAL ITEM
  // =============================================================

  Widget _medicalItem(
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Container(
      margin:
          const EdgeInsets.only(bottom: 12),

      padding:
          const EdgeInsets.all(12),

      decoration: BoxDecoration(
        color:
            const Color(0xFFF7F9F8),

        borderRadius:
            BorderRadius.circular(14),
      ),

      child: Row(
        children: [

          Container(
            width: 45,
            height: 45,

            decoration: BoxDecoration(
              color:
                  const Color(0xFFE8F5E9),

              shape: BoxShape.circle,
            ),

            child: Icon(
              icon,
              color: primaryGreen,
              size: 23,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                Text(
                  title,

                  style: const TextStyle(
                    fontWeight:
                        FontWeight.bold,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  subtitle,

                  style: TextStyle(
                    color:
                        Colors.grey.shade600,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons.check_circle_rounded,
            color: primaryGreen,
            size: 21,
          ),
        ],
      ),
    );
  }

  // =============================================================
  // IMPACT ITEM
  // =============================================================

  Widget _impactItem(
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Expanded(
      child: Column(
        children: [

          Icon(
            icon,
            color: primaryGreen,
            size: 30,
          ),

          const SizedBox(height: 7),

          Text(
            title,

            textAlign:
                TextAlign.center,

            style: const TextStyle(
              fontWeight:
                  FontWeight.bold,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            subtitle,

            textAlign:
                TextAlign.center,

            style: TextStyle(
              color:
                  Colors.grey.shade600,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  // =============================================================
  // DIVIDER
  // =============================================================

  Widget _verticalDivider() {
    return Container(
      height: 48,
      width: 1,
      color: Colors.grey.shade200,
    );
  }

  // =============================================================
  // HELP STEP
  // =============================================================

  Widget _helpStep({
    required String number,
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      margin:
          const EdgeInsets.only(bottom: 12),

      padding:
          const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(18),

        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withValues(alpha: 0.04),

            blurRadius: 10,

            offset:
                const Offset(0, 4),
          ),
        ],
      ),

      child: Row(
        children: [

          Container(
            width: 52,
            height: 52,

            decoration: BoxDecoration(
              color: lightGreen,
              shape: BoxShape.circle,
            ),

            child: Icon(
              icon,
              color: primaryGreen,
              size: 26,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                Row(
                  children: [

                    Text(
                      number,

                      style:
                          const TextStyle(
                        color: primaryGreen,
                        fontSize: 11,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(width: 8),

                    Expanded(
                      child: Text(
                        title,

                        style:
                            const TextStyle(
                          fontSize: 15,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 5),

                Text(
                  description,

                  style: TextStyle(
                    color:
                        Colors.grey.shade600,
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

