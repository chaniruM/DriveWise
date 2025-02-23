// import 'package:drivewise/pages/user_details_page.dart';
// import 'package:drivewise/pages/home_page.dart';
// import 'package:flutter/material.dart';
//
// class MyCarsPage extends StatelessWidget {
//   const MyCarsPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('My Cars'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             Expanded(
//               child: GridView.builder(
//                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 2,
//                   crossAxisSpacing: 16.0,
//                   mainAxisSpacing: 16.0,
//                 ),
//                 itemCount: 4,
//                 itemBuilder: (context, index) {
//                   return GestureDetector(
//                     onTap: () {
//                       // Navigate to the vehicle information page
//                       print('Vehicle $index tapped');
//                     },
//                     child: Card(
//                       elevation: 4.0,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10.0),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Expanded(
//                             child: Image.asset(
//                               'assets/car_placeholder.png', // Replace with image
//                               fit: BoxFit.cover,
//                             ),
//                           ),
//                           const SizedBox(height: 8.0),
//                           Text(
//                             'Vehicle ${index + 1}',
//                             style: const TextStyle(
//                               fontSize: 16.0,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//             const SizedBox(height: 16.0),
//             ElevatedButton(
//               onPressed: () {
//                 // Navigate to add new vehicle page or show add vehicle dialog
//                 print('Add New Vehicle tapped');
//               },
//               child: const Text('Add New Vehicle'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'package:drivewise/pages/register_vehicle_page.dart';
import 'package:drivewise/pages/vehicle_datails_page.dart';
import 'package:flutter/material.dart';
import '../models/vehicle.dart';
import '../widgets/vehicle_card.dart';
// import 'register_vehicle_screen.dart';
// import 'vehicle_details_page.dart';

class MyCarsPage extends StatelessWidget {
  // Dummy data for demonstration purposes
  final List<Vehicle> vehicles = [
    Vehicle(
      id: '1',
      nickname: 'City Cruiser',
      imageUrl: 'https://www.fmdt.info/vehicle/toyota/2019/corolla-32-white.png',
      registrationNumber: 'ABC-1234',
      make: 'Toyota',
      model: 'Corolla',
      year: 2019,
      currentMileage: 25000,
      licenseDateExpiry: DateTime(2023, 12, 31),
      insuranceDateExpiry: DateTime(2023, 10, 15),
      specifications: {
        'Engine Oil': '5W-30',
        'Transmission Oil': 'ATF WS',
        'Oil Filter': 'TOYOTA Genuine 90915-YZZF2',
        'Fuel Filter': 'TOYOTA Genuine 23300-21010',
        'Coolant': 'TOYOTA Super Long Life Coolant',
      },
    ),
    Vehicle(
      id: '2',
      nickname: 'Weekend Ride',
      imageUrl: 'https://di-honda-enrollment.s3.amazonaws.com/2020-civic-sedan/model-image-2020-civic-sedan-front.png',
      registrationNumber: 'XYZ-5678',
      make: 'Honda',
      model: 'Civic',
      year: 2020,
      currentMileage: 15000,
      licenseDateExpiry: DateTime(2024, 2, 28),
      insuranceDateExpiry: DateTime(2024, 3, 15),
      specifications: {
        'Engine Oil': '0W-20',
        'Transmission Oil': 'Honda ATF DW-1',
        'Oil Filter': 'Honda Genuine 15400-PLM-A02',
        'Fuel Filter': 'Honda Genuine 17048-SHJ-A30',
        'Coolant': 'Honda Long Life Antifreeze/Coolant Type 2',
      },
    ),
  ];

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: Text('My Cars'),
  //     ),
  //     body: Padding(
  //       padding: const EdgeInsets.all(16.0),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text(
  //             'Your Vehicles',
  //             style: TextStyle(
  //               fontSize: 24,
  //               fontWeight: FontWeight.bold,
  //             ),
  //           ),
  //           SizedBox(height: 16),
  //           Expanded(
  //             child: GridView.builder(
  //               gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
  //                 crossAxisCount: 2,
  //                 crossAxisSpacing: 16,
  //                 mainAxisSpacing: 16,
  //                 childAspectRatio: 0.75,
  //               ),
  //               itemCount: vehicles.length,
  //               itemBuilder: (context, index) {
  //                 return VehicleCard(
  //                   vehicle: vehicles[index],
  //                   onTap: () {
  //                     Navigator.push(
  //                       context,
  //                       MaterialPageRoute(
  //                         builder: (context) => VehicleDetailsPage(vehicle: vehicles[index]),
  //                       ),
  //                     );
  //                   },
  //                 );
  //               },
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //     floatingActionButton: FloatingActionButton(
  //       onPressed: () {
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(builder: (context) => RegisterVehiclePage()),
  //         );
  //       },
  //       child: Icon(Icons.add),
  //       tooltip: 'Register New Vehicle',
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Cars',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.white,),
            onPressed: () {
              // Search functionality would go here
            },
          ),
        ],
      ),
      body: Container(
        color: Theme.of(context).colorScheme.background,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with greeting
            Container(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, Driver!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Your Vehicles',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),

            // Vehicle grid
            Expanded(
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 500),
                child: vehicles.isEmpty ? _buildEmptyState(context) : _buildVehicleGrid(context),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            _createRoute(RegisterVehiclePage()),
          ).then((_) {
            // Refresh UI after returning from registration page
          });
        },
        icon: Icon(Icons.add),
        label: Text('Add Vehicle'),
        elevation: 4,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.directions_car_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.7),
          ),
          SizedBox(height: 16),
          Text(
            'No vehicles added yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Tap the + button to add your first vehicle',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleGrid(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.75,
        ),
        itemCount: vehicles.length,
        itemBuilder: (context, index) {
          // Add staggered animation for grid items
          return AnimatedOpacity(
            opacity: 1.0,
            duration: Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            child: AnimatedPadding(
              padding: EdgeInsets.all(0),
              duration: Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              child: VehicleCard(
                vehicle: vehicles[index],
                onTap: () {
                  Navigator.push(
                    context,
                    _createRoute(VehicleDetailsPage(vehicle: vehicles[index])),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  // Custom page route with transition animation
  PageRouteBuilder _createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        var tween = Tween(begin: begin, end: end)
            .chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      transitionDuration: Duration(milliseconds: 400),
    );
  }
}