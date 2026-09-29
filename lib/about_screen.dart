
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F5),

      appBar: AppBar(
        title: const Text(
          "About Us",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.green.shade700,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            // ================= HEADER =================

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                vertical: 30,
                horizontal: 20,
              ),
              decoration: BoxDecoration(
                color: Colors.green.shade700,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(35),
                  bottomRight: Radius.circular(35),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.white,
                      backgroundImage:
                          AssetImage("assets/afriditrust.png"),
                    ),
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    "Afridi Welfare Trust",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "Serving Humanity with Love and Care",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // ================= WHO WE ARE =================

            sectionTitle(
              icon: Icons.info_outline,
              title: "Who We Are",
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    "Afridi Welfare Trust is a non-profit organization dedicated to serving humanity and supporting deserving communities. "
                    "We work to provide essential support to underprivileged families through education, food distribution, healthcare, "
                    "clean drinking water and emergency relief programs.\n\n"
                    "Our mission is to bring positive change to society by helping people in need and creating opportunities for a better and brighter future.",
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.7,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ================= MISSION =================

            infoCard(
              icon: Icons.flag,
              title: "Our Mission",
              description:
                  "To serve humanity without discrimination and provide education, healthcare, food, clean drinking water and emergency assistance to deserving people.",
            ),

            const SizedBox(height: 15),

            // ================= VISION =================

            infoCard(
              icon: Icons.visibility,
              title: "Our Vision",
              description:
                  "To build a society where every individual has equal opportunities for education, healthcare, basic necessities and a better future.",
            ),

            const SizedBox(height: 25),

            // ================= OBJECTIVES =================

            sectionTitle(
              icon: Icons.track_changes,
              title: "Our Objectives",
            ),

            objectiveCard(
              Icons.school,
              "Education",
              "Support deserving students with educational opportunities and learning resources.",
            ),

            objectiveCard(
              Icons.restaurant,
              "Food Distribution",
              "Provide food packages and meals to needy families and communities.",
            ),

            objectiveCard(
              Icons.local_hospital,
              "Healthcare",
              "Help deserving people access essential medical care and health services.",
            ),

            objectiveCard(
              Icons.water_drop,
              "Clean Water",
              "Support clean drinking water projects for communities facing water shortages.",
            ),

            objectiveCard(
              Icons.volunteer_activism,
              "Emergency Relief",
              "Provide immediate assistance to families affected by emergencies and disasters.",
            ),

            objectiveCard(
              Icons.people,
              "Community Support",
              "Work together with volunteers and donors to create positive social change.",
            ),

            const SizedBox(height: 25),

            // ================= VALUES =================

            sectionTitle(
              icon: Icons.favorite,
              title: "Our Values",
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      valueRow(
                        Icons.favorite,
                        "Compassion",
                        "We care for people and support those in need.",
                      ),

                      const Divider(),

                      valueRow(
                        Icons.handshake,
                        "Trust",
                        "We believe in honesty, transparency and responsibility.",
                      ),

                      const Divider(),

                      valueRow(
                        Icons.people,
                        "Equality",
                        "We believe everyone deserves dignity and equal opportunities.",
                      ),

                      const Divider(),

                      valueRow(
                        Icons.volunteer_activism,
                        "Service",
                        "We are committed to serving humanity with dedication.",
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // ================= SUPPORT BUTTON =================

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Get.toNamed('/donate');
                      },
                      icon: const Icon(
                        Icons.favorite,
                        color: Colors.white,
                      ),
                      label: const Text(
                        "Support Our Mission",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Get.toNamed('/volunteer');
                      },
                      icon: const Icon(
                        Icons.volunteer_activism,
                        color: Colors.green,
                      ),
                      label: const Text(
                        "Become a Volunteer",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Colors.green,
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // ================= FOOTER =================

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                vertical: 25,
                horizontal: 20,
              ),
              color: Colors.green.shade700,
              child: const Column(
                children: [
                  Icon(
                    Icons.volunteer_activism,
                    color: Colors.white,
                    size: 35,
                  ),

                  SizedBox(height: 10),

                  Text(
                    "Afridi Welfare Trust",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 6),

                  Text(
                    "Serving Humanity with Love and Care",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),

                  SizedBox(height: 12),

                  Text(
                    "© 2026 Afridi Welfare Trust\nAll Rights Reserved",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white60,
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

  // ================= SECTION TITLE =================

  static Widget sectionTitle({
    required IconData icon,
    required String title,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 8,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.green.shade700,
            size: 27,
          ),

          const SizedBox(width: 10),

          Text(
            title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade800,
            ),
          ),
        ],
      ),
    );
  }

  // ================= INFO CARD =================

  static Widget infoCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(15),
          leading: CircleAvatar(
            radius: 27,
            backgroundColor: Colors.green.shade700,
            child: Icon(
              icon,
              color: Colors.white,
              size: 28,
            ),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ================= OBJECTIVE CARD =================

  static Widget objectiveCard(
    IconData icon,
    String title,
    String description,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 6,
      ),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(12),
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Colors.green.shade700,
              size: 28,
            ),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              description,
              style: const TextStyle(
                height: 1.4,
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Widget valueRow(
    IconData icon,
    String title,
    String description,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: Colors.green.shade700,
          child: Icon(
            icon,
            color: Colors.white,
            size: 22,
          ),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

