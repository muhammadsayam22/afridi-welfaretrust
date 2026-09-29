import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'database/db_helper.dart';
import 'models/contact_model.dart';
import 'theme/app_colors.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {

  final TextEditingController nameController =
      TextEditingController();

  final TextEditingController phoneController =
      TextEditingController();

  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController messageController =
      TextEditingController();

  final TextEditingController subjectController =
      TextEditingController();

  static const String orgPhone = "(091) 5253089";
  static const String orgEmail = "afriditrust@hotmail.com";
  static const String orgFacebook = "https://facebook.com/afridiwelfaretrust";
  static const String whatsappNumber = "923000000000";

  final RegExp emailRegExp = RegExp(
    r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,4}$',
  );

  @override
  void dispose() {

    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    messageController.dispose();
    subjectController.dispose();

    super.dispose();
  }

  Future<void> _launch(String uri) async {
    final Uri parsed = Uri.parse(uri);
    try {
      final bool launched = await launchUrl(
        parsed,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        showMessage("Could not open this link on your device");
      }
    } catch (_) {
      showMessage("This feature is not available on your device");
    }
  }


  void sendMessage() {

    String name = nameController.text.trim();
    String phone = phoneController.text.trim();
    String email = emailController.text.trim();
    String subject = subjectController.text.trim();
    String message = messageController.text.trim();


    // Name check
    if (name.isEmpty) {

      showMessage(
        "Please enter your name",
      );

      return;
    }


    // Phone check
    if (phone.isEmpty) {

      showMessage(
        "Please enter your phone number",
      );

      return;
    }


    // Email check
    if (email.isEmpty) {

      showMessage(
        "Please enter your email address",
      );

      return;
    }

    if (!emailRegExp.hasMatch(email)) {

      showMessage(
        "Please enter a valid email address",
      );

      return;
    }

    // Message check
    if (message.isEmpty) {

      showMessage(
        "Please enter your message",
      );

      return;
    }

    _saveMessage(
      name: name,
      phone: phone,
      email: email,
      subject: subject,
      message: message,
    );
  }

  Future<void> _saveMessage({
    required String name,
    required String phone,
    required String email,
    required String subject,
    required String message,
  }) async {
    final contact = ContactMessage(
      name: name,
      phone: phone,
      email: email,
      subject: subject,
      message: message,
      createdAt: DateTime.now().toIso8601String(),
    );

    try {
      final id = await DbHelper.instance.insertContact(contact);
      if (!mounted) return;

      if (id == null) {
        _showBackendMessage();
        return;
      }

      // Success dialog

      showDialog(
        context: context,

        builder: (context) {

          return AlertDialog(

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),

            title: const Row(
              children: [

                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                ),

                SizedBox(width: 10),

                Text(
                  "Message Sent",
                ),

              ],
            ),

            content: const Text(
              "Thank you for contacting "
              "Afridi Welfare Trust.\n\n"
              "We will get back to you as soon as possible.",
            ),

            actions: [

              TextButton(

                onPressed: () {

                  Navigator.pop(context);

                  // Clear form

                  nameController.clear();
                  phoneController.clear();
                  emailController.clear();
                  messageController.clear();
                  subjectController.clear();

                },

                child: const Text(
                  "OK",
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            ],
          );
        },
      );
    } catch (_) {
      if (!mounted) return;
      _showBackendMessage();
    }
  }

  void _showBackendMessage() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text("Something Went Wrong"),
        content: const Text(
          "We could not save your message right now. "
          "Please try again later.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }




  void showMessage(String message) {

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xFFF5F9F5),


      appBar: AppBar(

        backgroundColor: Colors.green.shade700,

        centerTitle: true,

        elevation: 0,

        title: const Text(
          "Contact Us",
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

          onPressed: () {

            Navigator.pop(context);

          },
        ),
      ),


      

      body: SingleChildScrollView(

        child: Padding(

          padding: const EdgeInsets.all(18),

          child: Column(

            children: [


    

              Container(

                width: double.infinity,

                padding: const EdgeInsets.symmetric(
                  vertical: 30,
                  horizontal: 20,
                ),

                decoration: BoxDecoration(

                  gradient: LinearGradient(

                    colors: [
                      Colors.green.shade800,
                      Colors.green.shade400,
                    ],

                    begin: Alignment.topLeft,

                    end: Alignment.bottomRight,
                  ),

                  borderRadius: BorderRadius.circular(22),

                  boxShadow: [

                    BoxShadow(
                      color: Colors.green.withValues(alpha: 0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),

                  ],
                ),

                child: const Column(

                  children: [

                    Icon(
                      Icons.contact_phone,
                      color: Colors.white,
                      size: 60,
                    ),

                    SizedBox(height: 12),

                    Text(
                      "Contact Afridi Welfare Trust",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 8),

                    Text(
                      "We are here to listen and help",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                      ),
                    ),

                  ],
                ),
              ),


              const SizedBox(height: 25),


      

              const Align(

                alignment: Alignment.centerLeft,

                child: Text(
                  "Contact Information",
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),


              const SizedBox(height: 15),




              contactCard(
                icon: Icons.phone,
                title: "Phone",
                value: "+92 300 0000000",
              ),


              const SizedBox(height: 12),


    

              contactCard(
                icon: Icons.email,
                title: "Email",
                value: "info@afridiwelfare.com",
              ),


              const SizedBox(height: 12),




              contactCard(
                icon: Icons.location_on,
                title: "Office Address",
                value:
                    "Khyber Pakhtunkhwa, Pakistan",
              ),


              const SizedBox(height: 12),

contactCard(
                icon: Icons.access_time,
                title: "Working Hours",
                value:
                    "Monday - Saturday\n9:00 AM - 5:00 PM",
              ),

              const SizedBox(height: 30),

              // ================= QUICK CONTACT =================
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Quick Contact",
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth >= 700 ? 4 : 2;
                  return GridView.count(
                    crossAxisCount: columns,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.35,
                    children: [
                      _socialButton(
                        icon: Icons.call_rounded,
                        label: "Call Us",
                        color: AppColors.primary,
                        onTap: () => _launch('tel:$orgPhone'),
                      ),
                      _socialButton(
                        icon: Icons.chat_rounded,
                        label: "WhatsApp",
                        color: Colors.green,
                        onTap: _openWhatsApp,
                      ),
                      _socialButton(
                        icon: Icons.facebook_rounded,
                        label: "Facebook",
                        color: Colors.blue,
                        onTap: () => _launch(orgFacebook),
                      ),
                      _socialButton(
                        icon: Icons.email_rounded,
                        label: "Email Us",
                        color: Colors.orange,
                        onTap: () => _launch('mailto:$orgEmail'),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 30),


              const Align(

                alignment: Alignment.centerLeft,

                child: Text(
                  "Send Us a Message",
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),


              const SizedBox(height: 15),


              textField(
                controller: nameController,
                label: "Full Name",
                hint: "Enter your name",
                icon: Icons.person,
              ),


              const SizedBox(height: 15),


              

              textField(
                controller: phoneController,
                label: "Phone Number",
                hint: "Enter your phone number",
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
              ),


              const SizedBox(height: 15),


              textField(
                controller: emailController,
                label: "Email Address",
                hint: "Enter your email",
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
              ),


              const SizedBox(height: 15),


              textField(
                controller: subjectController,
                label: "Subject",
                hint: "Enter the subject",
                icon: Icons.subject,
              ),


              const SizedBox(height: 15),


        

              TextField(

                controller: messageController,

                maxLines: 5,

                decoration: InputDecoration(

                  labelText: "Message",

                  hintText:
                      "Write your message here...",

                  prefixIcon: const Padding(

                    padding: EdgeInsets.only(
                      bottom: 80,
                    ),

                    child: Icon(
                      Icons.message,
                      color: Colors.green,
                    ),
                  ),

                  filled: true,

                  fillColor: Colors.white,

                  border: OutlineInputBorder(

                    borderRadius:
                        BorderRadius.circular(15),

                    borderSide: BorderSide.none,
                  ),

                  enabledBorder:
                      OutlineInputBorder(

                    borderRadius:
                        BorderRadius.circular(15),

                    borderSide: BorderSide(
                      color: Colors.grey.shade300,
                    ),
                  ),

                  focusedBorder:
                      OutlineInputBorder(

                    borderRadius:
                        BorderRadius.circular(15),

                    borderSide:
                        const BorderSide(
                      color: Colors.green,
                      width: 2,
                    ),
                  ),
                ),
              ),


              const SizedBox(height: 25),



              SizedBox(

                width: double.infinity,

                height: 55,

                child: ElevatedButton.icon(

                  onPressed: sendMessage,

                  icon: const Icon(
                    Icons.send,
                  ),

                  label: const Text(
                    "Send Message",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  style:
                      ElevatedButton.styleFrom(

                    backgroundColor:
                        Colors.green.shade700,

                    foregroundColor:
                        Colors.white,

                    elevation: 5,

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),


              const SizedBox(height: 25),


  

              Container(

                width: double.infinity,

                padding: const EdgeInsets.all(15),

                decoration: BoxDecoration(

                  color: Colors.green.shade50,

                  borderRadius:
                      BorderRadius.circular(15),

                  border: Border.all(
                    color: Colors.green.shade100,
                  ),
                ),

                child: const Row(

                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    Icon(
                      Icons.info_outline,
                      color: Colors.green,
                    ),

                    SizedBox(width: 10),

                    Expanded(

                      child: Text(
                        "For donations, volunteering or "
                        "general information, please "
                        "contact us using the details above.",
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ),

                  ],
                ),
              ),


              const SizedBox(height: 30),


              Container(

                width: double.infinity,

                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(

                  color: Colors.green.shade700,

                  borderRadius:
                      BorderRadius.circular(18),
                ),

                child: const Column(

                  children: [

                    Icon(
                      Icons.volunteer_activism,
                      color: Colors.white,
                      size: 35,
                    ),

                    SizedBox(height: 8),

                    Text(
                      "Afridi Welfare Trust",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 5),

                    Text(
                      "Serving Humanity with Love and Care",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),

                    SizedBox(height: 10),

                    Text(
                      "© 2026 Afridi Welfare Trust",
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                      ),
                    ),

                  ],
                ),
              ),


              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }

  Widget contactCard({
    required IconData icon,
    required String title,
    required String value,
  }) {

    return Container(

      width: double.infinity,

      padding: const EdgeInsets.all(15),

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius:
            BorderRadius.circular(16),

        boxShadow: [

          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),

        ],
      ),

      child: Row(

        children: [

          Container(

            width: 55,
            height: 55,

            decoration: BoxDecoration(

              color: Colors.green.shade50,

              borderRadius:
                  BorderRadius.circular(14),
            ),

            child: Icon(
              icon,
              color: Colors.green.shade700,
              size: 28,
            ),
          ),

          const SizedBox(width: 15),

          Expanded(

            child: Column(

              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget textField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType =
        TextInputType.text,
  }) {

    return TextField(

      controller: controller,

      keyboardType: keyboardType,

      decoration: InputDecoration(

        labelText: label,

        hintText: hint,

        prefixIcon: Icon(
          icon,
          color: Colors.green,
        ),

        filled: true,

        fillColor: Colors.white,

        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(15),

          borderSide: BorderSide.none,
        ),

        enabledBorder:
            OutlineInputBorder(

          borderRadius:
              BorderRadius.circular(15),

          borderSide: BorderSide(
            color: Colors.grey.shade300,
          ),
        ),

        focusedBorder:
            OutlineInputBorder(

          borderRadius:
              BorderRadius.circular(15),

          borderSide:
              const BorderSide(
            color: Colors.green,
            width: 2,
          ),
        ),
      ),
    );
  }

  Widget _socialButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF263238),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openWhatsApp() async {
    // Try opening WhatsApp directly, otherwise fall back to the web link.
    final Uri direct = Uri.parse(
      'whatsapp://send?phone=$whatsappNumber',
    );
    final Uri fallback = Uri.parse(
      'https://wa.me/$whatsappNumber',
    );

    try {
      final bool canDirect =
          await canLaunchUrl(direct);
      if (canDirect) {
        await launchUrl(direct);
      } else {
        final bool launched =
            await launchUrl(fallback);
        if (!launched) {
          showMessage("Could not open WhatsApp");
        }
      }
    } catch (_) {
      try {
        await _launch('https://wa.me/$whatsappNumber');
      } catch (_) {
        showMessage("WhatsApp is not available on this device");
      }
    }
  }
}