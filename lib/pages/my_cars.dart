import 'dart:convert';
import 'package:drivewise/services/vehicle_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

import 'package:drivewise/pages/register_vehicle_page.dart';
import 'package:drivewise/pages/vehicle_datails_page.dart';
import 'package:flutter/material.dart';
import '../models/vehicle.dart';
import '../services/notification_service.dart';
import '../widgets/vehicle_card.dart';

class MyCarsPage extends StatefulWidget {
  @override
  _MyCarsPageState createState() => _MyCarsPageState();
}

class _MyCarsPageState extends State<MyCarsPage> {
  List<Vehicle> vehicles = [];
  bool isLoading = true;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    fetchVehicles();
  }

  Future<void> fetchVehicles() async {
    setState(() {
      isLoading = true;
    });

    try {
      final data = await VehicleService().fetchUserVehicles();
      final List<dynamic> vehiclesData = data['vehicles'];

      setState(() {
        vehicles = vehiclesData.map((vehicleData) => Vehicle.fromJson(vehicleData)).toList();
        isLoading = false;
      });

      final NotiService notiService = NotiService();
      await notiService.initNotifications();

      // schedule reminders
      for (var vehicle in vehicles) {
        DateTime licenseExpiryDate = vehicle.licenseDateExpiry;
        DateTime reminderDate = licenseExpiryDate.subtract(Duration(days: 7)); // Notify 7 days before expiry

        if (reminderDate.isAfter(DateTime.now())) {
          await notiService.scheduleNotification(
            id: vehicle.id.hashCode,
            title: "License Expiry Reminder",
            body: "Your vehicle (${vehicle.nickname}) license expires soon!",
            scheduledDate: reminderDate,
          );
        } else {
          print("License reminder date is in the past. Skipping notification for ${vehicle.nickname}");
        }

        DateTime emissionsExpiryDate = vehicle.emmissionsExpiry;
        reminderDate = emissionsExpiryDate.subtract(Duration(days: 7)); // Notify 7 days before expiry

        if (reminderDate.isAfter(DateTime.now())) {
          await notiService.scheduleNotification(
            id: vehicle.id.hashCode + 1, // Different ID for each notification type
            title: "Emissions Test Reminder",
            body: "Your vehicle (${vehicle.nickname}) emissions certificate expires soon!",
            scheduledDate: reminderDate,
          );
        } else {
          print("Emissions reminder date is in the past. Skipping notification for ${vehicle.nickname}");
        }

        DateTime insuranceExpiryDate = vehicle.insuranceDateExpiry;
        reminderDate = insuranceExpiryDate.subtract(Duration(days: 7)); // Notify 7 days before expiry

        if (reminderDate.isAfter(DateTime.now())) {
          await notiService.scheduleNotification(
            id: vehicle.id.hashCode + 2, // Different ID for each notification type
            title: "Insurance Expiry Reminder",
            body: "Your vehicle (${vehicle.nickname}) insurance expires soon!",
            scheduledDate: reminderDate,
          );
        } else {
          print("Insurance reminder date is in the past. Skipping notification for ${vehicle.nickname}");
        }
      }

    } catch (error) {
      print('Error fetching vehicles: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

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