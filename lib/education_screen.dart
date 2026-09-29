
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'database/db_helper.dart';
import 'models/project_model.dart';
import 'widgets/database_program_grid.dart';

class EducationScreen extends StatelessWidget {
  const EducationScreen({super.key});

  static const Color primaryGreen = Color(0xFF087F5B);
  static const Color lightGreen = Color(0xFFE8F5E9);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        title: const Row(
          children: [
            Icon(
              Icons.school_rounded,
              size: 27,
            ),
            SizedBox(width: 10),
            Text(
              "Education",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),

      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

          

            Padding(
              padding: const EdgeInsets.all(18),

              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),

                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF087F5B),
                      Color(0xFF12B886),
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),

                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius:
                                  BorderRadius.circular(30),
                            ),

                            child: const Text(
                              "EDUCATION FOR EVERYONE",
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
                            "Building Brighter\nFutures Through Education",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              height: 1.15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 12),

                          const Text(
                            "We believe every child deserves access "
                            "to quality education, learning resources "
                            "and a better future.",
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

                        child: Icon(
                          Icons.school_rounded,
                          size: 125,
                          color: Colors.white.withValues(alpha: 0.18),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // =====================================================
            // INTRODUCTION
            // =====================================================

            _sectionTitle(
              "Our Education Mission",
              "Creating opportunities through learning",
            ),

            const SizedBox(height: 15),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),

              child: Container(
                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),

                child: Column(
                  children: [

                    Container(
                      width: 65,
                      height: 65,

                      decoration: BoxDecoration(
                        color: lightGreen,
                        shape: BoxShape.circle,
                      ),

                      child: const Icon(
                        Icons.menu_book_rounded,
                        color: primaryGreen,
                        size: 32,
                      ),
                    ),

                    const SizedBox(height: 14),

                    const Text(
                      "Education Changes Lives",
                      textAlign: TextAlign.center,

                      style: TextStyle(
                        color: primaryGreen,
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      "Afridi Welfare Trust works to help children "
                      "and families who face difficulties accessing "
                      "education. Our goal is to remove barriers "
                      "and give deserving students a chance to learn, "
                      "grow and build a successful future.",

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
            // PROGRAMS
            // =====================================================

            _sectionTitle(
              "Our Education Programs",
              "Ways we support students and communities",
            ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),

              child: DatabaseProgramGrid<Education>(
                loader: DbHelper.instance.getEducationProjects(),
                selector: (item) => ProgramRecord(
                  title: item.title,
                  description: item.description,
                  image: item.image,
                ),
                fallbackIcon: Icons.school_rounded,
                fallbackColor: Colors.blue,
              ),
            ),

            const SizedBox(height: 32),

            // =====================================================
            // IMPACT
            // =====================================================

            _sectionTitle(
              "Our Education Impact",
              "Every opportunity can make a difference",
            ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),

              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 22,
                  horizontal: 10,
                ),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),

                child: Row(
                  children: [

                    _impactItem(
                      Icons.school_rounded,
                      "Students",
                      "Supported",
                    ),

                    _verticalDivider(),

                    _impactItem(
                      Icons.menu_book_rounded,
                      "Books",
                      "Provided",
                    ),

                    _verticalDivider(),

                    _impactItem(
                      Icons.workspace_premium_rounded,
                      "Future",
                      "Empowered",
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
              "Our approach to supporting education",
            ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),

              child: Column(
                children: [

                  _helpStep(
                    number: "01",
                    icon: Icons.search_rounded,
                    title: "Identify Need",
                    description:
                        "We identify children and families who "
                        "need educational support.",
                  ),

                  _helpStep(
                    number: "02",
                    icon: Icons.fact_check_rounded,
                    title: "Understand Their Situation",
                    description:
                        "We understand their educational needs "
                        "and available resources.",
                  ),

                  _helpStep(
                    number: "03",
                    icon: Icons.volunteer_activism_rounded,
                    title: "Provide Support",
                    description:
                        "We provide appropriate educational "
                        "assistance and learning resources.",
                  ),

                  _helpStep(
                    number: "04",
                    icon: Icons.trending_up_rounded,
                    title: "Build a Better Future",
                    description:
                        "We aim to create long-term opportunities "
                        "through education.",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // =====================================================
            // WHY EDUCATION
            // =====================================================

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),

              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),

                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),

                  borderRadius: BorderRadius.circular(22),

                  border: Border.all(
                    color: const Color(0xFFB7E4C7),
                  ),
                ),

                child: Column(
                  children: [

                    const Icon(
                      Icons.lightbulb_rounded,
                      color: primaryGreen,
                      size: 42,
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      "Why Education Matters",
                      textAlign: TextAlign.center,

                      style: TextStyle(
                        color: primaryGreen,
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      "Education opens doors to opportunities, "
                      "improves confidence and helps communities "
                      "build a stronger and more sustainable future.",

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
              padding: const EdgeInsets.symmetric(horizontal: 18),

              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),

                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF087F5B),
                      Color(0xFF12B886),
                    ],
                  ),

                  borderRadius: BorderRadius.circular(22),

                  boxShadow: [
                    BoxShadow(
                      color: primaryGreen.withValues(alpha: 0.20),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),

                child: Column(
                  children: [

                    const Icon(
                      Icons.volunteer_activism_rounded,
                      color: Colors.white,
                      size: 45,
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      "Help a Child Build a Better Future",
                      textAlign: TextAlign.center,

                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      "Your support can help provide education "
                      "and learning opportunities to someone in need.",

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
                      Icons.school_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Support Our Education Work",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Your donation helps children continue their "
                      "education with books and learning materials.",
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
                          arguments: {'donationType': 'Education Fund'},
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

              padding: const EdgeInsets.symmetric(
                vertical: 28,
                horizontal: 20,
              ),

              color: const Color(0xFF063B2B),

              child: Column(
                children: [

                  Container(
                    width: 60,
                    height: 60,

                    padding: const EdgeInsets.all(6),

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

  // ===========================================================
  // SECTION TITLE
  // ===========================================================

  Widget _sectionTitle(
    String title,
    String subtitle,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

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
            padding: const EdgeInsets.only(left: 15),

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

  // ===========================================================
  // IMPACT ITEM
  // ===========================================================

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

            textAlign: TextAlign.center,

            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            subtitle,

            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================
  // DIVIDER
  // ===========================================================

  Widget _verticalDivider() {
    return Container(
      height: 48,
      width: 1,
      color: Colors.grey.shade200,
    );
  }

  // ===========================================================
  // HELP STEP
  // ===========================================================

  Widget _helpStep({
    required String number,
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(18),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
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

                      style: const TextStyle(
                        color: primaryGreen,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(width: 8),

                    Expanded(
                      child: Text(
                        title,

                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 5),

                Text(
                  description,

                  style: TextStyle(
                    color: Colors.grey.shade600,
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

