import 'package:drivewise/pages/read_speed.dart';
import 'package:flutter/material.dart';
import 'my_cars.dart';
import 'user_details_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Center(child: Text('DriveWise App')),
      //   leading: IconButton(
      //     icon: const Icon(Icons.menu),
      //     onPressed: () {
      //       // Handle menu actions
      //     },
      //   ),
      //   actions: [
      //     IconButton(
      //       icon: const Icon(Icons.settings),
      //       onPressed: () {
      //         // Navigate to settings
      //       },
      //     ),
      //   ],
      // ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Upcoming Services',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                height: 100,
                color: Colors.blue[50],
                child: const Center(
                  child: Text('No upcoming services at the moment.'),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Recent Searches',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                height: 100,
                color: Colors.green[50],
                child: const Center(
                  child: Text('Your recent searches will appear here.'),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Promotional Materials',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                height: 100,
                color: Colors.red[50],
                child: const Center(
                  child: Text('Check out our latest promotions here!'),
                ),
              ),
            ),
          ],
        ),
      ),
    //   bottomNavigationBar: BottomNavigationBar(
    //     selectedItemColor: Colors.blue,
    //     unselectedItemColor: Colors.grey,
    //     items: const [
    //       BottomNavigationBarItem(
    //         icon: Icon(Icons.home),
    //         label: 'Home',
    //       ),
    //       BottomNavigationBarItem(
    //         icon: Icon(Icons.directions_car),
    //         label: 'My Cars',
    //       ),
    //       BottomNavigationBarItem(
    //         icon: Icon(Icons.schedule),
    //         label: 'Schedules',
    //       ),
    //       BottomNavigationBarItem(
    //         icon: Icon(Icons.person),
    //         label: 'Profile',
    //       ),
    //       BottomNavigationBarItem(
    //         icon: Icon(Icons.bluetooth),
    //         label: 'OBD-II',
    //       ),
    //     ],
    //     currentIndex: 0, // Highlight the home tab by default
    //     onTap: (index) {
    //       switch (index) {
    //         case 0:
    //         // Stay on HomePage
    //           break;
    //         case 1:
    //           Navigator.push(
    //             context,
    //             MaterialPageRoute(builder: (context) => MyCarsPage()),
    //           );
    //           break;
    //         case 2:
    //           break;
    //         case 3:
    //           Navigator.push(
    //             context,
    //             MaterialPageRoute(builder: (context) => UserDetailsPage()),
    //           );
    //           break;
    //         case 4:
    //           Navigator.push(
    //             context,
    //             MaterialPageRoute(builder: (context) => OBD2Screen()), // Navigate to OBD-II screen
    //           );
    //           break;
    //       }
    //     },
    //   ),
    );
  }
}
