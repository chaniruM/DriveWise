import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:drivewise/providers/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drivewise/widgets/logout_dialogs.dart';
import 'package:drivewise/pages/user_details_page.dart';
import 'package:drivewise/pages/change_password_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'helpAndSupport_screen.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications') ?? true;
    });
  }

  Future<void> _savePreferences(String key, bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  // Add this function to launch app store or play store for rating
  Future<void> launchAppRating() async {
    // For Android
    const String androidPackageName = 'com.yourcompany.drivewise';
    final Uri androidUrl = Uri.parse('market://details?id=$androidPackageName');
    final Uri androidFallbackUrl = Uri.parse(
        'https://play.google.com/store/apps/details?id=$androidPackageName');

    // For iOS
    const String iOSAppId = 'your-ios-app-id';
    final Uri iOSUrl = Uri.parse('https://apps.apple.com/app/id$iOSAppId');

    // Try to launch the appropriate URL based on platform
    try {
      if (Theme.of(context).platform == TargetPlatform.android) {
        if (await canLaunchUrl(androidUrl)) {
          await launchUrl(androidUrl);
        } else {
          await launchUrl(androidFallbackUrl);
        }
      } else if (Theme.of(context).platform == TargetPlatform.iOS) {
        await launchUrl(iOSUrl);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open app store: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Settings",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Account Settings Section
            Text(
              "Account Settings",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            _buildNavigationTile(
              title: "Edit Profile",
              icon: Icons.person,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserDetailsPage()),
                );
              },
            ),
            _buildNavigationTile(
              title: "Change your password",
              icon: Icons.lock,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ChangePasswordScreen()),
                );
              },
            ),
            _buildNavigationTile(
              title: "Security & Privacy",
              icon: Icons.security,
              onTap: () {
                // Navigate to Security & Privacy screen
                print("Navigate to Security & Privacy");
              },
            ),

            const SizedBox(height: 24),

            // App Settings Section
            Text(
              "App Settings",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            _buildSwitchTile(
              title: "Dark Theme",
              icon: isDarkMode ? Icons.dark_mode : Icons.light_mode,
              value: isDarkMode,
              onChanged: (bool value) {
                themeProvider.toggleTheme(); // Toggle dark mode globally
              },
            ),
            _buildSwitchTile(
              title: "Enable Notifications",
              icon: Icons.notifications,
              value: _notificationsEnabled,
              onChanged: (bool value) {
                setState(() {
                  _notificationsEnabled = value;
                  _savePreferences('notifications', value);
                });
              },
              activeColor: Colors.green,
            ),
            // Add this after your existing sections in the build method
            const SizedBox(height: 24),

            // Help & Support Section
            Text(
              "Help & Support",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            _buildNavigationTile(
              title: "FAQs",
              icon: Icons.question_answer,
              onTap: () {
                // Navigate to FAQs screen (using the full implementation)
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FAQsScreen()),
                );
              },
            ),
            _buildNavigationTile(
              title: "Contact Support",
              icon: Icons.support_agent,
              onTap: () {
                // Navigate to Contact Support screen (using the full implementation)
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ContactSupportScreen()),
                );
              },
            ),

            _buildNavigationTile(
              title: "App Tutorial",
              icon: Icons.help_outline,
              onTap: () {
                // Launch app tutorial (using the full implementation)
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AppTutorialScreen()),
                );
              },
            ),
            _buildNavigationTile(
              title: "Rate Us",
              icon: Icons.star_rate,
              onTap: () {
                // Open app store or play store for rating
                launchAppRating();
              },
            ),

            const SizedBox(height: 24),

            // Logout Section
            Text(
              "Account Actions",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            _buildActionTile(
              title: "Logout",
              icon: Icons.logout,
              iconColor: Colors.red,
              textColor: Colors.red,
              onTap: () {
                showLogoutDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required IconData icon,
    required bool value,
    required Function(bool) onChanged,
    Color activeColor = Colors.orange,
    Color titleColor = Colors.black,
  }) {
    final theme = Theme.of(context);
    final effectiveTitleColor =
        theme.brightness == Brightness.dark && titleColor == Colors.black
            ? Colors.white
            : titleColor;

    return Card(
      color: theme.cardColor,
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon,
            color:
                titleColor == Colors.red ? titleColor : theme.iconTheme.color),
        title: Text(
          title,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: effectiveTitleColor,
            fontWeight:
                titleColor == Colors.red ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: activeColor,
        ),
      ),
    );
  }

  Widget _buildNavigationTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return Card(
      color: theme.cardColor,
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: theme.iconTheme.color),
        title: Text(
          title,
          style: theme.textTheme.bodyLarge,
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    Color iconColor = Colors.black,
    Color textColor = Colors.black,
  }) {
    final theme = Theme.of(context);
    final effectiveIconColor =
        theme.brightness == Brightness.dark && iconColor == Colors.black
            ? Colors.white
            : iconColor;
    final effectiveTextColor =
        theme.brightness == Brightness.dark && textColor == Colors.black
            ? Colors.white
            : textColor;

    return Card(
      color: theme.cardColor,
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: effectiveIconColor),
        title: Text(
          title,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: effectiveTextColor,
            fontWeight:
                textColor == Colors.red ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
