import 'package:flutter/material.dart';
import 'pages/my_cars.dart';
import 'pages/user_details_page.dart';
import 'pages/read_speed.dart'; // OBD2Screen
import 'pages/home_page.dart'; // HomePage


class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    HomePage(),       // Home Page
    MyCarsPage(),     // My Cars Page
    OBD2Screen(),     // OBD-II Page
    UserDetailsPage() // User Profile Page
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
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
            icon: const Icon(Icons.menu,color: Colors.white,),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings,color: Colors.white,),
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
              decoration: BoxDecoration(color: Colors.black),
              child: Column(
                children: [
                  Image.asset('assets/images/logo.png', height: 90,width: 150,), // App logo
                  SizedBox(height: 40),

                ],
              ),
            ),

            ListTile(
              leading: const Icon(Icons.person,color: Colors.orange,),
              title: const Text('Profile'),
              onTap: () {
                setState(() {
                  _currentIndex = 0;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.store,color: Colors.orange,),
              title: const Text('Register Supplier'),
              onTap: () {
                setState(() {
                  _currentIndex = 1;
                });
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: const Icon(Icons.directions_car,color: Colors.orange,),
              title: const Text('My Vehicles'),
              onTap: () {
                setState(() {
                  _currentIndex = 2;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.login,color: Colors.orange,),
              title: const Text('Supplier Login'),
              onTap: () {
                setState(() {
                  _currentIndex = 3;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.login,color: Colors.orange,),
              title: const Text('Workshop Login'),
              onTap: () {
                setState(() {
                  _currentIndex = 4;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.history,color: Colors.orange,),
              title: const Text('Inquiry History'),
              onTap: () {
                setState(() {
                  _currentIndex = 5;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.play_circle_fill,color: Colors.orange,),
              title: const Text('Youtube Video'),
              onTap: () {
                setState(() {
                  _currentIndex = 6;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.contact_phone_rounded,color: Colors.orange,),
              title: const Text('Contact Us'),
              onTap: () {
                setState(() {
                  _currentIndex = 7;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip,color: Colors.orange,),
              title: const Text('Privacy Policy'),
              onTap: () {
                setState(() {
                  _currentIndex = 8;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share,color: Colors.orange,),
              title: const Text('Share'),
              onTap: () {
                setState(() {
                  _currentIndex = 9;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout,color: Colors.orange,),
              title: const Text('Logout'),
              onTap: () {
                setState(() {
                  _currentIndex = 10;
                });
                Navigator.pop(context);
              },
            ),
            // const Divider(),
            // ListTile(
            //   leading: const Icon(Icons.info),
            //   title: const Text('About'),
            //   onTap: () {
            //     // Navigate to About page (implement this)
            //   },
            // ),
          ],
        ),
      ),

      body: _pages[_currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.black87,
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

