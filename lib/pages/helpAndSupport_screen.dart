import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// Global function to launch URLs with better error handling
Future<void> _launchUrl(BuildContext context, String url) async {
  try {
    print("Attempting to launch: $url");
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      print("Failed to launch URL: $url");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Could not launch $url")),
        );
      }
    }
  } catch (e) {
    print("Launch error: $e");
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error launching URL: ${e.toString()}")),
      );
    }
  }
}

// FAQs Screen
class FAQsScreen extends StatelessWidget {
  const FAQsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Colors.orange;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "FAQs",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // FAQs Icon in the middle of the page
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          Icons.question_answer,
                          size: 120,
                          color: primaryColor,
                        ),
                        Positioned(
                          right: 12,
                          top: 12,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Title and subtitle
                  const Text(
                    "Frequently Asked Questions",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "Find answers to the most commonly asked questions",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),

            // FAQ Items - Reusing existing code
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  _buildFaqItem(
                    question: "How do I reset my password?",
                    answer:
                        "You can reset your password by going to the Login screen and tapping on 'Forgot Password', then following the instructions sent to your email.",
                  ),
                  _buildFaqItem(
                    question: "How to enable dark mode?",
                    answer:
                        "Go to Settings > App Settings and toggle the 'Dark Theme' option.",
                  ),
                  _buildFaqItem(
                    question: "How can I update my profile information?",
                    answer:
                        "Go to Settings > Edit Profile to update your personal information.",
                  ),
                  _buildFaqItem(
                    question: "Is my data secure?",
                    answer:
                        "Yes. We use industry-standard encryption and secure protocols to protect your data. For more information, visit our Privacy Policy.",
                  ),
                  _buildFaqItem(
                    question: "How do I delete my account?",
                    answer:
                        "Please contact our support team to request account deletion.",
                  ),

                  const SizedBox(height: 20),
                  // Contact Support button
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: primaryColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.support_agent,
                              color: primaryColor,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              "Need more help?",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "If you can't find what you're looking for, our customer support team is ready to assist you.",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ContactSupportScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              "CONTACT SUPPORT",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildFaqItem({required String question, required String answer}) {
    return ExpansionTile(
      title: Text(
        question,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(answer),
        ),
      ],
    );
  }
}

// Contact Support Screen - Keeping this unchanged from your original code
class ContactSupportScreen extends StatefulWidget {
  const ContactSupportScreen({Key? key}) : super(key: key);

  @override
  _ContactSupportScreenState createState() => _ContactSupportScreenState();
}

class _ContactSupportScreenState extends State<ContactSupportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  // Updated email launcher function with better error handling
  void _launchEmail(String email) async {
    try {
      print("Attempting to launch email to: $email");
      final Uri uri = Uri(
        scheme: 'mailto',
        path: email,
        query:
            'subject=${Uri.encodeComponent(_subjectController.text.isNotEmpty ? _subjectController.text : "Support Request")}&body=${Uri.encodeComponent(_messageController.text)}',
      );
      if (!await launchUrl(uri)) {
        print("Failed to launch email");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Could not launch email app")),
          );
        }
      }
    } catch (e) {
      print("Email launch error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error launching email: ${e.toString()}")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Contact Support",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "How can we help you?",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _subjectController,
                decoration: const InputDecoration(
                  labelText: "Subject",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter a subject";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _messageController,
                decoration: const InputDecoration(
                  labelText: "Message",
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 10,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your message";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Send the form data directly via email
                      _launchEmail("drivewise.care@gmail.com");
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    backgroundColor: Colors.orange,
                  ),
                  child: const Text(
                    "Submit",
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              const Text(
                "Other ways to reach us:",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.email, color: Colors.orange.shade700),
                title: const Text("Email Support"),
                subtitle: const Text("drivewise.care@gmail.com"),
                onTap: () => _launchEmail("drivewise.care@gmail.com"),
              ),
              ListTile(
                leading: Icon(Icons.language, color: Colors.blue.shade700),
                title: const Text("Website"),
                subtitle: const Text("Visit our website"),
                onTap: () =>
                    _launchUrl(context, "https://www.drivewiselk.com/"),
              ),
              const SizedBox(height: 8),
              const Text(
                'Connect with us on Social Media',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.purple),
                title: const Text("Instagram"),
                subtitle: const Text("Follow us on Instagram"),
                onTap: () => _launchUrl(
                    context, "https://www.instagram.com/__drivewise__"),
              ),
              ListTile(
                leading: const Icon(Icons.facebook, color: Colors.blue),
                title: const Text("Facebook"),
                subtitle: const Text("Like & Follow us"),
                onTap: () => _launchUrl(context,
                    "https://www.facebook.com/share/162b7jrFa2/?mibextid=wwXIfr"),
              ),
              ListTile(
                leading: const Icon(Icons.link_rounded, color: Colors.indigo),
                title: const Text("LinkedIn"),
                subtitle: const Text("Connect with us"),
                onTap: () => _launchUrl(
                    context, "https://www.linkedin.com/company/drivewise-lk"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// App Tutorial Screen - Keeping this unchanged from your original code
class AppTutorialScreen extends StatefulWidget {
  const AppTutorialScreen({Key? key}) : super(key: key);

  @override
  _AppTutorialScreenState createState() => _AppTutorialScreenState();
}

class _AppTutorialScreenState extends State<AppTutorialScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 5;

  final List<Map<String, String>> _tutorialData = [
    {
      'title': 'Welcome to DriveWise',
      'description': 'Your companion for smarter vehicle maintenance and care.',
      'icon': 'directions_car',
    },
    {
      'title': 'Vehicle Specifications',
      'description':
          'Lookup engine oil type, transmission fluid, and other specifications based on your vehicle make, model, year, or VIN.',
      'icon': 'search',
    },
    {
      'title': 'Maintenance Tracking',
      'description':
          'Create and monitor maintenance schedules by logging odometer readings, service intervals, and important expiration dates.',
      'icon': 'build',
    },
    {
      'title': 'Price Comparison',
      'description':
          'Compare prices from local retailers for recommended products and find nearby stores for your purchases.',
      'icon': 'attach_money',
    },
    {
      'title': 'Alerts & History',
      'description':
          'Get timely reminders for upcoming service needs and keep a complete maintenance history log for your vehicle.',
      'icon': 'notifications',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "DriveWise Tutorial",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              "Skip",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page;
                });
              },
              itemCount: _totalPages,
              itemBuilder: (context, index) {
                IconData iconData;
                switch (_tutorialData[index]['icon']) {
                  case 'directions_car':
                    iconData = Icons.directions_car;
                    break;
                  case 'search':
                    iconData = Icons.search;
                    break;
                  case 'build':
                    iconData = Icons.build;
                    break;
                  case 'attach_money':
                    iconData = Icons.attach_money;
                    break;
                  case 'notifications':
                    iconData = Icons.notifications;
                    break;
                  default:
                    iconData = Icons.info;
                }

                return Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        iconData,
                        size: 100,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(height: 32),
                      Text(
                        _tutorialData[index]['title']!,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _tutorialData[index]['description']!,
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Dots indicator
                Row(
                  children: List.generate(
                    _totalPages,
                    (index) => Container(
                      width: 10,
                      height: 10,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentPage == index
                            ? Theme.of(context).primaryColor
                            : Colors.grey,
                      ),
                    ),
                  ),
                ),
                // Navigation buttons
                _currentPage < _totalPages - 1
                    ? ElevatedButton(
                        onPressed: () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: const Text("Next"),
                      )
                    : ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("Get Started"),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Function to launch app store for rating with better error handling
Future<void> launchAppRating(BuildContext context) async {
  try {
    // For Android
    const String packageName = 'com.example.drivewise';
    print("Attempting to launch app store for rating: $packageName");

    final Uri uri = Uri.parse('market://details?id=$packageName');
    final Uri fallbackUri =
        Uri.parse('https://play.google.com/store/apps/details?id=$packageName');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (await canLaunchUrl(fallbackUri)) {
      await launchUrl(fallbackUri);
    } else {
      print("Could not launch app store for rating");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not open app store")),
        );
      }
    }
  } catch (e) {
    print('Could not launch app store: $e');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error opening app store: ${e.toString()}")),
      );
    }
  }
}
