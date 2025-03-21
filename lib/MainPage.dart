import 'dart:async';
import 'package:drivewise/main.dart';
import 'package:drivewise/pages/store_locator.dart';
import 'package:drivewise/widgets/BottomNavigationBar.dart';
import 'package:flutter/material.dart';
import 'package:drivewise/services/token_service.dart';
import 'package:drivewise/pages/login_screen.dart';
import 'pages/my_cars.dart';
import 'pages/user_details_page.dart';
import 'pages/read_speed.dart';
import 'pages/home_page.dart';
import 'pages/settings_screen.dart';
import 'pages/error_codes.dart';
import 'package:drivewise/widgets/sessionExpiredScreen.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  Timer? _timer;
  int _currentIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    MyCarsPage(),
    OBD2Screen(),
    UserDetailsPage(),
    TroubleCodePage(),
  ];

  @override
  void initState() {
    super.initState();
    _startTokenCheck();
  }

  void _startTokenCheck() {
    _timer = Timer.periodic(Duration(minutes: 1), (timer) async {
      bool isExpired = await TokenService.isTokenExpired();
      if (isExpired) {
        await TokenService.clearToken();
        _navigateToLogin();
      }
    });
  }

  void _navigateToLogin() {
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => SessionExpiredScreen()),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _onPageSelected(int index) {
    if (index < _pages.length) {
      setState(() {
        _currentIndex = index;
      });
    }
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
            onTap: () {},
            child: CircleAvatar(
              child: Icon(Icons.settings, color: Colors.white),
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
                  Image.asset('assets/images/logo.png', height: 90, width: 150),
                  SizedBox(height: 40),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.orange),
              title: const Text('Profile'),
              onTap: () {
                _onPageSelected(3);
                Navigator.pop(context);
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
              leading: const Icon(Icons.location_pin, color: Colors.orange),
              title: const Text('Store Locator'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => StoreLocator()),
                );
              },
            ),
            // ListTile(
            //   leading: const Icon(Icons.error, color: Colors.orange),
            //   title: const Text('Trouble Codes'),
            //   onTap: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(builder: (context) => TroubleCodePage()),
            //     );
            //   },
            // ),
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
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
      body: _pages[_currentIndex],
    bottomNavigationBar: BottomNavigationWidget(onItemSelected: _onPageSelected),
      // bottomNavigationBar: BottomNavigationBar(
      //   backgroundColor:
      //       Theme.of(context).bottomNavigationBarTheme.backgroundColor ??
      //           Colors.black,
      //   selectedItemColor: Colors.orange,
      //   unselectedItemColor: Colors.grey,
      //   items: [
      //     BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      //     BottomNavigationBarItem(
      //         icon: Icon(Icons.directions_car), label: 'My Cars'),
      //     BottomNavigationBarItem(icon: Icon(Icons.bluetooth), label: 'OBD-II'),
      //     BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      //   ],
      //   currentIndex: _currentIndex,
      //   onTap: _onPageSelected,
      // ),
    );
  }
}
