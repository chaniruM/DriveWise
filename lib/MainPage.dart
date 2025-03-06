import 'package:drivewise/main.dart';
import 'package:drivewise/widgets/BottomNavigationBar.dart';
import 'package:flutter/material.dart';
import 'pages/my_cars.dart';
import 'pages/user_details_page.dart';
import 'pages/read_speed.dart';
import 'pages/home_page.dart';
import 'pages/quick_lookup_screen.dart';


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
    UserDetailsPage(),  // Profile page
    QuickLookupScreen(),// Quick Lookup page
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
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              // Navigate to settings page (implement this)
            },
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
              leading: const Icon(Icons.store, color: Colors.orange),
              title: const Text('Quick Lookup'),
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
              leading: const Icon(Icons.logout, color: Colors.orange),
              title: const Text('Log Out'),
              onTap: () {
                _onPageSelected(8);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),

      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationWidget(onItemSelected: _onPageSelected),
    );
  }
}