import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:drivewise/providers/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drivewise/providers/theme_provider.dart';


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

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: const Color(0xFFE95B15),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        color: isDarkMode ? const Color(0xFF030B23) : Colors.white,
        child: Column(
          children: [
            _buildSwitchTile(
              title: "Dark Mode",
              value: isDarkMode,
              onChanged: (bool value) {
                themeProvider.toggleTheme(); // Toggle dark mode globally
              },
            ),
            _buildSwitchTile(
              title: "Enable Notifications",
              value: _notificationsEnabled,
              onChanged: (bool value) {
                setState(() {
                  _notificationsEnabled = value;
                  _savePreferences('notifications', value);
                });
              },
              activeColor: Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required bool value,
    required Function(bool) onChanged,
    Color activeColor = Colors.orange,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isDarkMode = themeProvider.isDarkMode;

    return Card(
      color: isDarkMode ? const Color(0xFF030B23) : Colors.white,
      elevation: 4,
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: activeColor,
        ),
      ),
    );
  }
}
