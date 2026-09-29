
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'database/db_helper.dart';
import 'models/project_model.dart';
import 'widgets/database_program_grid.dart';


class FoodScreen extends StatelessWidget {
  const FoodScreen({super.key});

  static const Color primaryGreen = Color(0xFF087F5B);
  static const Color secondGreen = Color(0xFF12B886);
  static const Color darkGreen = Color(0xFF063B2B);
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
              Icons.restaurant_rounded,
              size: 27,
            ),

            SizedBox(width: 10),

            Text(
              "Food Support",
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
                              "FOOD FOR THOSE IN NEED",
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
                            "No One Should\nGo To Bed Hungry",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 27,
                              height: 1.15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 12),

                          const Text(
                            "Together we can provide food, ration "
                            "and meals to families and communities "
                            "who need our support.",
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
                              Icons.restaurant_rounded,
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

        

            _sectionTitle(
              "Our Food Mission",
              "Fighting hunger with compassion",
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
                        color: const Color(0xFFFFF3E0),
                        shape: BoxShape.circle,
                      ),

                      child: const Icon(
                        Icons.restaurant_rounded,
                        color: Colors.orange,
                        size: 35,
                      ),
                    ),

                    const SizedBox(height: 14),

                    const Text(
                      "Food Is a Basic Need",
                      textAlign: TextAlign.center,

                      style: TextStyle(
                        color: primaryGreen,
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      "Afridi Welfare Trust aims to support "
                      "families and individuals facing food "
                      "insecurity. Through food distribution "
                      "and ration assistance, we work to bring "
                      "relief and dignity to people in need.",

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
            // FOOD PROGRAMS
            // =====================================================

            _sectionTitle(
              "Our Food Programs",
              "Different ways we provide food assistance",
            ),

            const SizedBox(height: 16),

            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 18),

              child: DatabaseProgramGrid<Food>(
                loader: DbHelper.instance.getFoodProjects(),
                selector: (item) => ProgramRecord(
                  title: item.title,
                  description: item.description,
                  image: item.image,
                ),
                fallbackIcon: Icons.restaurant_rounded,
                fallbackColor: Colors.orange,
              ),
            ),

            const SizedBox(height: 32),

            // =====================================================
            // FOOD ITEMS
            // =====================================================

            _sectionTitle(
              "What We Provide",
              "Basic food essentials for families",
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

                    _foodItem(
                      Icons.grain_rounded,
                      "Rice & Flour",
                      "Essential household staples",
                    ),

                    _foodItem(
                      Icons.local_grocery_store_rounded,
                      "Cooking Essentials",
                      "Basic items for daily meals",
                    ),

                    _foodItem(
                      Icons.breakfast_dining_rounded,
                      "Breakfast Items",
                      "Food for a healthy start",
                    ),

                    _foodItem(
                      Icons.shopping_basket_rounded,
                      "Monthly Ration",
                      "Regular food support packages",
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
              "Our Food Impact",
              "Every meal brings hope",
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
                      "Families",
                      "Supported",
                    ),

                    _verticalDivider(),

                    _impactItem(
                      Icons.restaurant_rounded,
                      "Meals",
                      "Provided",
                    ),

                    _verticalDivider(),

                    _impactItem(
                      Icons.shopping_basket_rounded,
                      "Ration",
                      "Distributed",
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
              "Our food assistance process",
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
                    title: "Identify Families",
                    description:
                        "We identify families and individuals "
                        "who need food assistance.",
                  ),

                  _helpStep(
                    number: "02",
                    icon: Icons.fact_check_rounded,
                    title: "Understand Their Needs",
                    description:
                        "We understand their situation and "
                        "the type of food support required.",
                  ),

                  _helpStep(
                    number: "03",
                    icon: Icons.shopping_basket_rounded,
                    title: "Prepare Food Support",
                    description:
                        "We arrange suitable food packages "
                        "or meal assistance.",
                  ),

                  _helpStep(
                    number: "04",
                    icon: Icons.favorite_rounded,
                    title: "Deliver With Dignity",
                    description:
                        "We aim to provide assistance with "
                        "care, respect and compassion.",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // =====================================================
            // WHY FOOD SUPPORT
            // =====================================================

            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 18),

              child: Container(
                width: double.infinity,

                padding: const EdgeInsets.all(23),

                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),

                  borderRadius:
                      BorderRadius.circular(22),

                  border: Border.all(
                    color: const Color(0xFFFFE082),
                  ),
                ),

                child: Column(
                  children: [

                    Container(
                      width: 62,
                      height: 62,

                      decoration: const BoxDecoration(
                        color: Colors.orange,
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
                      "Why Food Support Matters",
                      textAlign: TextAlign.center,

                      style: TextStyle(
                        color: Color(0xFFE65100),
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      "A food package can provide relief to a "
                      "family during a difficult time. Your "
                      "support can help ensure that people "
                      "have access to basic food necessities.",

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
            // DONATION CTA
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
                      "Help Feed a Family",
                      textAlign: TextAlign.center,

                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      "Your support can help provide food "
                      "and essential ration to families in need.",

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
                      Icons.restaurant_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Help Us Fight Hunger",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Your donation provides ration packages and warm "
                      "meals for families in need.",
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
                          arguments: {'donationType': 'Food Relief'},
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
  // FOOD ITEM
  // =============================================================

  Widget _foodItem(
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
        color: const Color(0xFFF7F9F8),

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

            textAlign: TextAlign.center,

            style: const TextStyle(
              fontWeight:
                  FontWeight.bold,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            subtitle,

            textAlign: TextAlign.center,

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
  // VERTICAL DIVIDER
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