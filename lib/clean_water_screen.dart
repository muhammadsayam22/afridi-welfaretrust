import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'database/db_helper.dart';
import 'models/project_model.dart';
import 'widgets/database_program_grid.dart';


class CleanWaterScreen extends StatelessWidget {
  const CleanWaterScreen({super.key});

  static const Color primaryGreen = Color(0xFF087F5B);
  static const Color secondGreen = Color(0xFF12B886);
  static const Color darkGreen = Color(0xFF063B2B);
  static const Color lightGreen = Color(0xFFE8F5E9);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),

      appBar: AppBar(
        backgroundColor: primaryGreen,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Clean Water",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [

            // ================= HERO =================
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 100 : 24,
                vertical: isDesktop ? 70 : 45,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primaryGreen,
                    secondGreen,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: isDesktop
                  ? Row(
                      children: [
                        Expanded(
                          child: _heroContent(context),
                        ),
                        const SizedBox(width: 50),
                        Expanded(
                          child: _waterIllustration(),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        _heroContent(context),
                        const SizedBox(height: 30),
                        _waterIllustration(),
                      ],
                    ),
            ),

            // ================= MISSION =================
            _sectionContainer(
              child: Column(
                children: [
                  _sectionTitle(
                    "Clean Water For Everyone",
                    "Safe water is essential for healthy families and strong communities.",
                  ),

                  const SizedBox(height: 25),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: isDesktop
                        ? Row(
                            children: [
                              _bigWaterIcon(),
                              const SizedBox(width: 30),
                              Expanded(
                                child: _missionText(),
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              _bigWaterIcon(),
                              const SizedBox(height: 20),
                              _missionText(),
                            ],
                          ),
                  ),
                ],
              ),
            ),

            // ================= PROGRAMS =================
            _sectionContainer(
              backgroundColor: Colors.white,
              child: Column(
                children: [
                  _sectionTitle(
                    "Our Water Programs",
                    "We work to provide reliable access to safe and clean water.",
                  ),

                  const SizedBox(height: 30),

                  DatabaseProgramGrid<CleanWater>(
                    loader: DbHelper.instance.getCleanWaterProjects(),
                    selector: (item) => ProgramRecord(
                      title: item.title,
                      description: item.description,
                      image: item.image,
                    ),
                    fallbackIcon: Icons.water_drop_rounded,
                    fallbackColor: secondGreen,
                  ),
                ],
              ),
            ),

            
            _sectionContainer(
              child: Column(
                children: [
                  _sectionTitle(
                    "What We Provide",
                    "Our clean water support focuses on practical community needs.",
                  ),

                  const SizedBox(height: 30),

                  GridView.count(
                    crossAxisCount: isDesktop ? 4 : 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: isDesktop ? 1.3 : 1.05,
                    children: [
                      _waterItem(
                        Icons.water_drop,
                        "Safe Drinking Water",
                      ),
                      _waterItem(
                        Icons.filter_alt,
                        "Water Filters",
                      ),
                      _waterItem(
                        Icons.storage_rounded,
                        "Water Storage",
                      ),
                      _waterItem(
                        Icons.clean_hands_rounded,
                        "Hygiene Awareness",
                      ),
                    ],
                  ),
                ],
              ),
            ),

          
            _sectionContainer(
              backgroundColor: Colors.white,
              child: Column(
                children: [
                  _sectionTitle(
                    "Our Impact",
                    "Every clean-water project can improve health and dignity.",
                  ),

                  const SizedBox(height: 30),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 30,
                      horizontal: 15,
                    ),
                    decoration: BoxDecoration(
                      color: lightGreen,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: isDesktop
                        ? Row(
                            children: [
                              Expanded(
                                child: _impactItem(
                                  "500+",
                                  "Families Supported",
                                  Icons.family_restroom,
                                ),
                              ),
                              _verticalDivider(),
                              Expanded(
                                child: _impactItem(
                                  "20+",
                                  "Water Projects",
                                  Icons.water,
                                ),
                              ),
                              _verticalDivider(),
                              Expanded(
                                child: _impactItem(
                                  "10+",
                                  "Communities Helped",
                                  Icons.groups,
                                ),
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              _impactItem(
                                "500+",
                                "Families Supported",
                                Icons.family_restroom,
                              ),
                              const SizedBox(height: 25),
                              _impactItem(
                                "20+",
                                "Water Projects",
                                Icons.water,
                              ),
                              const SizedBox(height: 25),
                              _impactItem(
                                "10+",
                                "Communities Helped",
                                Icons.groups,
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),

            
            _sectionContainer(
              child: Column(
                children: [
                  _sectionTitle(
                    "How We Help",
                    "From identifying needs to delivering water support.",
                  ),

                  const SizedBox(height: 35),

                  GridView.count(
                    crossAxisCount: isDesktop ? 4 : 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 18,
                    mainAxisSpacing: 18,
                    childAspectRatio: isDesktop ? 1 : 0.85,
                    children: [
                      _helpStep(
                        "01",
                        Icons.search_rounded,
                        "Identify Need",
                        "We identify communities and families that need water support.",
                      ),

                      _helpStep(
                        "02",
                        Icons.assessment_rounded,
                        "Understand",
                        "We understand the water and hygiene challenges they face.",
                      ),

                      _helpStep(
                        "03",
                        Icons.handshake_rounded,
                        "Arrange Support",
                        "We arrange suitable water resources and solutions.",
                      ),

                      _helpStep(
                        "04",
                        Icons.volunteer_activism_rounded,
                        "Deliver Help",
                        "We work to provide practical and sustainable assistance.",
                      ),
                    ],
                  ),
                ],
              ),
            ),

          
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 100 : 24,
                vertical: 55,
              ),
              color: darkGreen,
              child: Column(
                children: [
                  const Icon(
                    Icons.water_drop_rounded,
                    color: Colors.white,
                    size: 55,
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    "Why Clean Water Matters",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 750,
                    ),
                    child: const Text(
                      "Access to clean water helps families maintain better health, "
                      "improve hygiene, support children and build healthier communities.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        height: 1.7,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ================= DONATE CTA =================
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.symmetric(
                horizontal: 25,
                vertical: 40,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    secondGreen,
                    primaryGreen,
                  ],
                ),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.volunteer_activism_rounded,
                    color: Colors.white,
                    size: 50,
                  ),

                  const SizedBox(height: 15),

                  const Text(
                    "Help Us Provide Clean Water",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "Your contribution can help bring safe water to families in need.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 25),

                  // ================= SUPPORT CTA =================

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
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.water_drop_rounded,
                            color: Colors.white,
                            size: 40,
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "Support Clean Water Projects",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Your donation builds wells and filtration "
                            "systems for communities without clean water.",
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
                                arguments: {'donationType': 'Clean Water'},
                              ),
                              icon: const Icon(Icons.favorite_rounded,
                                  size: 18),
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

                  const SizedBox(height: 25),

                  
                ],
              ),
            ),

            // ================= FOOTER =================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 25,
                vertical: 35,
              ),
              color: const Color(0xFF042A20),
              child: Column(
                children: [
                  Container(
                    height: 65,
                    width: 65,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Image.asset(
                      "assets/logo.png",
                      fit: BoxFit.contain,
                    ),
                  ),

                  const SizedBox(height: 15),

                  const Text(
                    "Afridi Welfare Trust",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "Together For Humanity",
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Divider(
                    color: Colors.white24,
                  ),

                  const SizedBox(height: 15),

                  const Text(
                    "© 2026 Afridi Welfare Trust. All Rights Reserved.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
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

  // ================= HERO CONTENT =================

  Widget _heroContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "CLEAN WATER FOR EVERYONE",
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),

        const SizedBox(height: 15),

        const Text(
          "Safe Water,\nHealthier Communities",
          style: TextStyle(
            color: Colors.white,
            fontSize: 38,
            height: 1.15,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 18),

        const Text(
          "We believe every family deserves access to safe and clean water. "
          "Together, we can make clean water accessible to those who need it most.",
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16,
            height: 1.6,
          ),
        ),

        const SizedBox(height: 28),

       
      ],
    );
  }

  // ================= WATER ILLUSTRATION =================

  Widget _waterIllustration() {
    return Container(
      height: 260,
      width: 260,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.25),
          width: 2,
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.water_drop_rounded,
          color: Colors.white,
          size: 130,
        ),
      ),
    );
  }

  // ================= MISSION TEXT =================

  Widget _missionText() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Water Is Life",
          style: TextStyle(
            color: darkGreen,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),

        SizedBox(height: 12),

        Text(
          "Clean water is one of the most basic needs of every human being. "
          "Our goal is to support families and communities by improving access "
          "to safe drinking water and essential water resources.",
          style: TextStyle(
            color: Colors.black54,
            fontSize: 15,
            height: 1.7,
          ),
        ),
      ],
    );
  }

  // ================= BIG WATER ICON =================

  Widget _bigWaterIcon() {
    return Container(
      height: 110,
      width: 110,
      decoration: BoxDecoration(
        color: lightGreen,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.water_drop_rounded,
        color: primaryGreen,
        size: 60,
      ),
    );
  }

  // ================= WATER ITEM =================

  Widget _waterItem(
    IconData icon,
    String title,
  ) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: primaryGreen,
            size: 38,
          ),

          const SizedBox(height: 12),

          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: darkGreen,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // ================= IMPACT ITEM =================

  Widget _impactItem(
    String number,
    String title,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          color: primaryGreen,
          size: 32,
        ),

        const SizedBox(height: 10),

        Text(
          number,
          style: const TextStyle(
            color: darkGreen,
            fontSize: 27,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 5),

        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  // ================= HELP STEP =================

  Widget _helpStep(
    String number,
    IconData icon,
    String title,
    String description,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: primaryGreen.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Text(
              number,
              style: TextStyle(
                color: primaryGreen.withValues(alpha: 0.25),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Icon(
            icon,
            color: primaryGreen,
            size: 35,
          ),

          const SizedBox(height: 12),

          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: darkGreen,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            description,
            textAlign: TextAlign.center,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 11.5,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // ================= SECTION TITLE =================

  Widget _sectionTitle(
    String title,
    String subtitle,
  ) {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: darkGreen,
            fontSize: 27,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 10),

        Container(
          height: 4,
          width: 55,
          decoration: BoxDecoration(
            color: secondGreen,
            borderRadius: BorderRadius.circular(10),
          ),
        ),

        const SizedBox(height: 12),

        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  // ================= SECTION CONTAINER =================

  Widget _sectionContainer({
    required Widget child,
    Color backgroundColor = const Color(0xFFF7F9F8),
  }) {
    return Container(
      width: double.infinity,
      color: backgroundColor,
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 55,
      ),
      child: child,
    );
  }

  // ================= DIVIDER =================

  Widget _verticalDivider() {
    return Container(
      height: 70,
      width: 1,
      color: primaryGreen.withValues(alpha: 0.15),
    );
  }
}