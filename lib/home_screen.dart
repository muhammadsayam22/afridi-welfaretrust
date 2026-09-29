
import 'package:afridiwelfaretrust/clean_water_screen.dart';
import 'package:afridiwelfaretrust/education_screen.dart';
import 'package:afridiwelfaretrust/food_screen.dart';
import 'package:afridiwelfaretrust/medical_screen.dart';
import 'package:afridiwelfaretrust/utils/app_routes.dart';
import 'package:afridiwelfaretrust/donate_screen.dart';
import 'package:afridiwelfaretrust/volunteer_screen.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:get/get.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _scaleAnimation = Tween<double>(
      begin: 0.96,
      end: 1.04,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 6.28319,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.linear,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),

      // ==========================================================
      // APP BAR
      // ==========================================================

      appBar: AppBar(
        backgroundColor: const Color(0xFF087F5B),
        elevation: 0,
        centerTitle: false,

        iconTheme: const IconThemeData(
          color: Colors.white,
        ),

        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              padding: const EdgeInsets.all(5),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),

              child: Image.asset(
                'assets/logo.png',
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(width: 10),

            const Expanded(
              child: Text(
                'Afridi Welfare Trust',
                overflow: TextOverflow.ellipsis,

                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),

      // ==========================================================
      // DRAWER
      // ==========================================================

      drawer: Drawer(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                top: 55,
                bottom: 25,
              ),

              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF087F5B),
                    Color(0xFF099268),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),

              child: Column(
                children: [
                  Container(
                    width: 95,
                    height: 95,
                    padding: const EdgeInsets.all(5),

                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),

                    child: ClipOval(
                      child: Image.asset(
                        'assets/logo.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  const Text(
                    'Afridi Welfare Trust',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    'Serving Humanity With Love & Care',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [

            _drawerItem(
              icon: Icons.home_rounded,
              title: 'Home',
              selected: true,
              onTap: () {
                Navigator.pop(context);
              },
            ),

            _drawerItem(
              icon: Icons.info_outline_rounded,
              title: 'About Us',
              onTap: () {
                Get.toNamed(AppRoutes.about);
              },
            ),

            _drawerItem(
              icon: Icons.volunteer_activism_rounded,
              title: 'Donate',
              iconColor: Colors.red,
              onTap: () {
                Get.toNamed(AppRoutes.donate);
              },
            ),

            _drawerItem(
              icon: Icons.groups_rounded,
              title: 'Volunteer',
              onTap: () {
                Get.toNamed(AppRoutes.volunteer);
              },
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 4),
              child: Divider(height: 1),
            ),

            _drawerItem(
              icon: Icons.school_rounded,
              title: 'Education',
              onTap: () {
                Get.toNamed(AppRoutes.education);
              },
            ),

            _drawerItem(
              icon: Icons.restaurant_rounded,
              title: 'Food',
              onTap: () {
                Get.toNamed(AppRoutes.food);
              },
            ),

            _drawerItem(
              icon: Icons.local_hospital_rounded,
              title: 'Medical',
              onTap: () {
                Get.toNamed(AppRoutes.medical);
              },
            ),

            _drawerItem(
              icon: Icons.water_drop_rounded,
              title: 'Clean Water',
              onTap: () {
                Get.toNamed(AppRoutes.water);
              },
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 4),
              child: Divider(height: 1),
            ),

            _drawerItem(
              icon: Icons.phone_in_talk_rounded,
              title: 'Contact Us',
              onTap: () {
                Get.toNamed(AppRoutes.contact);
              },
            ),

            _drawerItem(
              icon: Icons.settings_rounded,
              title: 'Settings',
              onTap: () {
                Get.toNamed(AppRoutes.settings);
              },
            ),

                    const Divider(),

                    const Padding(
                      padding: EdgeInsets.only(
                        bottom: 20,
                        top: 5,
                      ),

                      child: Text(
                        'Afridi Welfare Trust',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // ==========================================================
      // BODY
      // ==========================================================

      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const SizedBox(height: 18),

            // ======================================================
            // HERO
            // ======================================================

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),

              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),

                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF087F5B),
                      Color(0xFF099268),
                    ],

                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),

                  borderRadius: BorderRadius.circular(25),

                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF087F5B)
                          .withValues(alpha: 0.25),

                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),

                child: Row(
                  children: [
                    Expanded(
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
                              color: Colors.white
                                  .withValues(alpha: 0.15),

                              borderRadius:
                                  BorderRadius.circular(30),
                            ),

                            child: const Text(
                              'TOGETHER FOR HUMANITY',

                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ),

                          const SizedBox(height: 14),

                          const Text(
                            'Making A Difference,\nOne Life At A Time',

                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              height: 1.15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 10),

                          const Text(
                            'Helping communities through education, '
                            'food, healthcare and essential support.',

                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (width > 650)
                      const Padding(
                        padding: EdgeInsets.only(left: 20),

                        child: Icon(
                          Icons.volunteer_activism_rounded,
                          size: 120,
                          color: Colors.white24,
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 35),

            // ======================================================
            // TIKTOK STYLE PROFILE CAROUSEL
            // EACH IMAGE HAS ITS OWN CONTAINER
            // ======================================================

            Center(
              child: AnimatedBuilder(
                animation: _animationController,

                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,

                    child: Transform.rotate(
                      angle: _rotationAnimation.value * 0.01,

                      child: child,
                    ),
                  );
                },

                child: CarouselSlider(
                  items: [
                    'assets/afridiwelfare1.png',
                    'assets/afridiwelfare2.png',
                    'assets/afridiwelfare3.png',
                  ].map((image) {

                    // ==========================================
                    // EVERY IMAGE HAS ITS OWN CONTAINER
                    // ==========================================

                    return Container(
                      width: 210,
                      height: 210,

                      decoration: BoxDecoration(
                        shape: BoxShape.circle,

                        gradient:
                            const SweepGradient(
                          colors: [
                            Color(0xFF00C853),
                            Color(0xFF12B886),
                            Color(0xFF087F5B),
                            Color(0xFF00C853),
                          ],
                        ),

                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00C853)
                                .withValues(alpha: 0.35),

                            blurRadius: 22,
                            spreadRadius: 4,
                          ),
                        ],
                      ),

                      padding: const EdgeInsets.all(5),

                      child: ClipOval(
                        child: Image.asset(
                          image,

                          width: 200,
                          height: 200,

                          fit: BoxFit.cover,

                          errorBuilder:
                              (context, error, stackTrace) {
                            return const Center(
                              child: Icon(
                                Icons.image_not_supported,
                                size: 50,
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  }).toList(),

                  options: CarouselOptions(
                    height: 220,

                    viewportFraction: 0.75,

                    autoPlay: true,

                    autoPlayInterval:
                        const Duration(seconds: 2),

                    autoPlayAnimationDuration:
                        const Duration(milliseconds: 900),

                    autoPlayCurve:
                        Curves.easeInOut,

                    enableInfiniteScroll: true,

                    scrollDirection:
                        Axis.horizontal,

                    pauseAutoPlayOnTouch: true,

                    enlargeCenterPage: true,

                    enlargeFactor: 0.15,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 18),

            const Center(
              child: Text(
                'Afridi Welfare Trust',

                style: TextStyle(
                  color: Color(0xFF087F5B),
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 5),

            const Center(
              child: Text(
                'Serving Humanity With Love & Care',

                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                ),
              ),
            ),

            const SizedBox(height: 35),

            // ======================================================
            // SERVICES
            // ======================================================

            _sectionTitle(
              'Our Services',
              'Supporting people and communities in need',
            ),

            const SizedBox(height: 18),

            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 18),

              child: LayoutBuilder(
                builder: (context, constraints) {
                  final columns =
                      constraints.maxWidth >= 800 ? 3 : 2;

                  return GridView.count(
                    shrinkWrap: true,

                    physics:
                        const NeverScrollableScrollPhysics(),

                    crossAxisCount: columns,

                    crossAxisSpacing: 13,
                    mainAxisSpacing: 13,

                    childAspectRatio: 1.15,

                    children: [
                      _serviceCard(
                        context,
                        Icons.school_rounded,
                        'Education',
                        'Learning support',
                        Colors.blue,
                        const EducationScreen(),
                      ),

                      _serviceCard(
                        context,
                        Icons.restaurant_rounded,
                        'Food',
                        'Food assistance',
                        Colors.orange,
                        const FoodScreen(),
                      ),

                      _serviceCard(
                        context,
                        Icons.local_hospital_rounded,
                        'Medical',
                        'Healthcare support',
                        Colors.red,
                        const MedicalScreen(),
                      ),

                      _serviceCard(
                        context,
                        Icons.water_drop_rounded,
                        'Clean Water',
                        'Safe water access',
                        Colors.cyan,
                        const CleanWaterScreen(),
                      ),

                      _serviceCard(
                        context,
                        Icons.volunteer_activism_rounded,
                        'Donate',
                        'Help someone today',
                        Colors.green,
                        const DonateScreen(),
                      ),

                      _serviceCard(
                        context,
                        Icons.groups_rounded,
                        'Volunteer',
                        'Join our mission',
                        Colors.purple,
                        const VolunteerScreen(),
                      ),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 35),

            // ======================================================
            // FOOTER
            // ======================================================

            Container(
              width: double.infinity,

              padding: const EdgeInsets.only(
                top: 28,
                bottom: 25,
                left: 20,
                right: 20,
              ),

              color: const Color(0xFF063B2B),

              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    padding: const EdgeInsets.all(6),

                    decoration:
                        BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(15),
                    ),

                    child: Image.asset(
                      'assets/logo.png',
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'Afridi Welfare Trust',

                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    'Serving Humanity With Love & Care',

                    textAlign: TextAlign.center,

                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 12,
                    ),
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    '© 2026 Afridi Welfare Trust',

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

  // ================================================================
  // SECTION TITLE
  // ================================================================

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
                  color: const Color(0xFF087F5B),
                  borderRadius:
                      BorderRadius.circular(10),
                ),
              ),

              const SizedBox(width: 10),

              Text(
                title,

                style: const TextStyle(
                  color: Color(0xFF087F5B),
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
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

  // ================================================================
  // SERVICE CARD
  // ================================================================

  Widget _serviceCard(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Color color,
    Widget page,
  ) {
    return InkWell(
      borderRadius:
          BorderRadius.circular(20),

      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => page,
          ),
        );
      },

      child: Container(
        padding:
            const EdgeInsets.all(15),

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius:
              BorderRadius.circular(20),

          boxShadow: [
            BoxShadow(
              color: Colors.black
                  .withValues(alpha: 0.06),

              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            Container(
              width: 55,
              height: 55,

              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),

              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              title,

              textAlign: TextAlign.center,

              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF263238),
              ),
            ),

            const SizedBox(height: 4),

            Text(
              subtitle,

              textAlign: TextAlign.center,

              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // DRAWER ITEM
  // ================================================================

  Widget _drawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    bool selected = false,
  }) {
    return Container(
      margin:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 3,
      ),

      decoration: BoxDecoration(
        color: selected
            ? const Color(0xFFE8F5E9)
            : Colors.transparent,

        borderRadius:
            BorderRadius.circular(12),
      ),

      child: ListTile(
        leading: Icon(
          icon,
          color: iconColor ??
              const Color(0xFF087F5B),
        ),

        title: Text(
          title,

          style: TextStyle(
            fontSize: 14,

            fontWeight: selected
                ? FontWeight.bold
                : FontWeight.w500,

            color: selected
                ? const Color(0xFF087F5B)
                : Colors.black87,
          ),
        ),

        trailing: selected
            ? const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: Color(0xFF087F5B),
              )
            : null,

        onTap: onTap,
      ),
    );
  }
}
