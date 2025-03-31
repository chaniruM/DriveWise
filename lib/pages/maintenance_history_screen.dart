import 'package:flutter/material.dart';
import '../services/vehicle_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class MaintenanceHistoryScreen extends StatefulWidget {

  final String vehicleId;
  const MaintenanceHistoryScreen({Key? key, required this.vehicleId}) : super(key: key);

  @override
  _MaintenanceHistoryScreenState createState() => _MaintenanceHistoryScreenState();
}

class _MaintenanceHistoryScreenState extends State<MaintenanceHistoryScreen> {
  List<Map<String, dynamic>> _maintenanceHistory = [];
  final VehicleService vehicleService = VehicleService();
  final String baseUrl = 'YOUR_BASE_URL'; // Replace with your base URL

  @override
  void initState() {
    super.initState();
    _fetchMaintenanceHistory();
  }

  Future<void> _fetchMaintenanceHistory() async {
    try {
      debugPrint('Fetching all maintenance history');
      final history = await VehicleService().fetchMaintenanceHistory(vehicleId: widget.vehicleId);
      debugPrint('Fetched history: $history');
      setState(() {
        _maintenanceHistory = history;
      });
    } catch (e) {
      debugPrint('Error fetching maintenance history: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Maintenance History'),
        backgroundColor: Colors.teal,
        elevation: 5,
      ),
      body: _maintenanceHistory.isEmpty
          ? Center(child: Text('No maintenance records found'))
          : ListView.builder(
        itemCount: _maintenanceHistory.length,
        itemBuilder: (context, index) {
          final record = _maintenanceHistory[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text('Date: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(record['date']))}'),
              subtitle: Text(
                  'Mileage at Service: ${record['mileageAtService']}\n'
                  'Next Service Mileage: ${record['nextService']}\n'
                  'Engine Oil: ${record['engine_oil']}\n'
                  'Transmission Oil: ${record['transmission_oil']}\n'
                  'Air Filter: ${record['airfilters']}\n'
                  'Brake Fluid: ${record['brakeoil']}'),
            ),
          );
        },
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../services/vehicle_service.dart';
//
//
// class MaintenanceHistoryScreen extends StatefulWidget {
//   final String vehicleId;
//
//   MaintenanceHistoryScreen({required this.vehicleId});
//
//   @override
//   _MaintenanceHistoryScreenState createState() => _MaintenanceHistoryScreenState();
// }
//
// class _MaintenanceHistoryScreenState extends State<MaintenanceHistoryScreen> {
//   List<Map<String, dynamic>> _maintenanceHistory = [];
//   final VehicleService vehicleService = VehicleService();
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchMaintenanceHistory();
//   }
//
//   Future<void> _fetchMaintenanceHistory() async {
//     try {
//       debugPrint('Fetching maintenance history for vehicleId: ${widget.vehicleId}');
//       final history = await vehicleService.fetchMaintenanceHistory(widget.vehicleId);
//       debugPrint('Fetched history: $history');
//       setState(() {
//         _maintenanceHistory = history;
//       });
//     } catch (e) {
//       debugPrint('Error fetching maintenance history: $e');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Maintenance History'),
//         backgroundColor: Colors.teal,
//         elevation: 5,
//       ),
//       body: _maintenanceHistory.isEmpty
//           ? Center(child: Text('No maintenance records found'))
//           : ListView.builder(
//         itemCount: _maintenanceHistory.length,
//         itemBuilder: (context, index) {
//           final record = _maintenanceHistory[index];
//           return Card(
//             margin: const EdgeInsets.all(8.0),
//             child:
//             ListTile(
//               title: Text('Date: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(record['date']))}'),
//               subtitle: Text('Odometer: ${record['odometer']}\n'
//                   'Engine Oil: ${record['engine_oil']}\n'
//                   'Transmission Oil: ${record['transmission_oil']}\n'
//                   'Air Filter: ${record['airfilters']}\n'
//                   'Brake Fluid: ${record['brakeoil']}'),
//             ),
//             // ListTile(
//             //   title: Text('Date: ${record['date']}'),
//             //   subtitle: Text('Odometer: ${record['odometer']}\n'
//             //       'Engine Oil: ${record['engine_oil']}\n'
//             //       'Transmission Oil: ${record['transmission_oil']}\n'
//             //       'Air Filter: ${record['airfilters']}\n'
//             //       'Brake Fluid: ${record['brakeoil']}'),
//             // ),
//           );
//         },
//       ),
//     );
//   }
// }