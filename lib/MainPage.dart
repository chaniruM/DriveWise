import 'package:flutter/material.dart';
import 'pages/my_cars.dart';
import 'pages/user_details_page.dart';
import 'pages/read_speed.dart';  // Your OBD2Page
import 'pages/home_page.dart';   // The existing HomePage

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    HomePage(),        // HomePage
    MyCarsPage(),      // MyCarsPage
    OBD2Screen(),      // OBD2Screen
    UserDetailsPage(), // UserDetailsPage
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('DriveWise App')),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            // Have to add the menu options here
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Have to add setting options here
            },
          ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car),
            label: 'My Cars',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bluetooth),
            label: 'OBD-II',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
