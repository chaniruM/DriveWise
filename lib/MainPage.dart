import 'package:drivewise/main.dart';
import 'package:drivewise/widgets/BottomNavigationBar.dart';
import 'package:flutter/material.dart';
import 'pages/my_cars.dart';
import 'pages/user_details_page.dart';
import 'pages/read_speed.dart';
import 'pages/home_page.dart';
import 'pages/settings_screen.dart';
import 'pages/login_screen.dart';
import 'pages/error_codes.dart';


class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    HomePage(),         // Home page
    MyCarsPage(),       // My Cars
    OBD2Screen(),       // OBD-2
    UserDetailsPage(),
    TroubleCodePage(),// Profile page
  ];

  void _onPageSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyApp.primaryDarkBlue,
        title: const Center(
          child: Text(
            'DriveWise App',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 26,
              fontStyle: FontStyle.italic,
              color: Colors.white,
            ),
          ),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {

            },
            child: CircleAvatar(
              backgroundColor: Colors.orange,
              child: Icon(Icons.person, color: Colors.white),
            ),
          ),
        ],
      ),

      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: MyApp.primaryDarkBlue),
              child: Column(
                children: [
                  Image.asset('assets/images/logo.png', height: 90, width: 150), // App logo
                  SizedBox(height: 40),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.orange),
              title: const Text('Profile'),
              onTap: () {
                _onPageSelected(3);
                Navigator.pop(context); // Close the drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.directions_car, color: Colors.orange),
              title: const Text('My Vehicles'),
              onTap: () {
                _onPageSelected(1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.history, color: Colors.orange),
              title: const Text('Trouble Codes'),
              onTap: () {
                _onPageSelected(4);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.contact_phone_rounded, color: Colors.orange),
              title: const Text('Contact Us'),
              onTap: () {
                _onPageSelected(5);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip, color: Colors.orange),
              title: const Text('Privacy Policy'),
              onTap: () {
                _onPageSelected(6);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share, color: Colors.orange),
              title: const Text('Share'),
              onTap: () {
                _onPageSelected(7);
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: const Icon(Icons.settings, color: Colors.orange),
              title: const Text('Settings'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsScreen()),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.logout, color: Colors.orange),
              title: const Text('Log Out'),
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                      (route) => false, // Removes all previous routes from the stack
                );
              },
            ),
          ],
        ),
      ),

      body: _pages[_currentIndex],
      // bottomNavigationBar: BottomNavigationWidget(onItemSelected: _onPageSelected),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor ?? Colors.black,
        selectedItemColor: Colors.orange, // Ensure it's visible
        unselectedItemColor: Colors.grey, // Ensure visibility
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.directions_car), label: 'My Cars'),
          BottomNavigationBarItem(icon: Icon(Icons.bluetooth), label: 'OBD-II'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _currentIndex,
        onTap: _onPageSelected,
      ),

    );
  }
}