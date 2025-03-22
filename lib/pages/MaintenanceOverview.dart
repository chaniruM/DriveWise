import 'package:flutter/material.dart';
import '../models/vehicle.dart';
// import '../services/vehicle_service.dart';

class MaintenanceOverview extends StatefulWidget {
  @override
  _MaintenanceOverviewState createState() => _MaintenanceOverviewState();
}

class _MaintenanceOverviewState extends State<MaintenanceOverview> {
  DateTime? selectedDate;
  final TextEditingController odometerController = TextEditingController();
  final Map<String, bool> replacements = {
    'Engine Oil': false,
    'Transmission Oil': false,
    'Oil Filter': false,
    'Brake Fluid': false,
    'Coolant': false,
  };

  String? selectedVehicleId;
  List<Map<String, dynamic>> userVehicles = [];
  // final VehicleService vehicleService = VehicleService();

  @override
  void initState() {
    super.initState();
    fetchUserVehicles();
  }

  Future<void> fetchUserVehicles() async {
    try {
      // final data = await vehicleService.fetchUserVehicles();
      setState(() {
        // userVehicles = vehicleService.extractVehicles(data);
      });
    } catch (e) {
      print('Error fetching user vehicles: $e');
    }
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Maintenance Overview',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal,
        elevation: 5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            DropdownButton<String>(
              value: selectedVehicleId,
              hint: const Text('Select Vehicle'),
              onChanged: (String? newValue) {
                setState(() {
                  selectedVehicleId = newValue;
                });
              },
              items: userVehicles.map<DropdownMenuItem<String>>((Map<String, dynamic> vehicle) {
                return DropdownMenuItem<String>(
                  value: vehicle['id'],
                  child: Text(vehicle['name']),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Date:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context),
                    child: Container(
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey, width: 1.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        selectedDate == null
                            ? 'Select Date'
                            : '${selectedDate!.toLocal()}'.split(' ')[0],
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today, color: Colors.teal),
                  onPressed: () => _selectDate(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Odometer:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Expanded(
                  child: TextField(
                    controller: odometerController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.teal, width: 1.5),
                      ),
                      hintText: 'Enter mileage',
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Replacements',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal),
            ),
            ...replacements.keys.map((key) {
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: replacements[key],
                            activeColor: Colors.teal,
                            onChanged: (bool? value) {
                              setState(() {
                                replacements[key] = value ?? false;
                              });
                            },
                          ),
                          Text(key, style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                      DropdownButton<String>(
                        hint: const Text('Select product used', style: TextStyle(fontSize: 14)),
                        items: ['Caltex', 'TOYOTA', 'TOTACHE']
                            .map((String value) => DropdownMenuItem<String>(
                          value: value,
                          child: Text(value, style: const TextStyle(fontSize: 14)),
                        ))
                            .toList(),
                        onChanged: (String? newValue) {},
                        style: const TextStyle(color: Colors.black),
                        dropdownColor: Colors.white,
                        elevation: 4,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
      backgroundColor: Colors.grey[100],
    );
  }
}
//
// import 'package:flutter/material.dart';
// import '../models/vehicle.dart';
//
// class MaintenanceOverview extends StatefulWidget {
//   @override
//   _MaintenanceOverviewState createState() => _MaintenanceOverviewState();
// }
//
// class _MaintenanceOverviewState extends State<MaintenanceOverview> {
//   DateTime? selectedDate;
//   final TextEditingController odometerController = TextEditingController();
//   final Map<String, bool> replacements = {
//     'Engine Oil': false,
//     'Transmission Oil': false,
//     'Oil Filter': false,
//     'Brake Fluid': false,
//     'Coolant': false,
//   };
//
//   void _selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2100),
//     );
//     if (picked != null && picked != selectedDate) {
//       setState(() {
//         selectedDate = picked;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Maintenance Overview',
//             style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//         backgroundColor: Colors.teal,
//         elevation: 5,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const SizedBox(height: 16),
//             Row(
//               children: [
//                 const Text('Date:',
//                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//                 Expanded(
//                   child: InkWell(
//                     onTap: () => _selectDate(context),
//                     child: Container(
//                       padding: const EdgeInsets.all(12.0),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         border: Border.all(color: Colors.grey, width: 1.5),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Text(
//                         selectedDate == null
//                             ? 'Select Date'
//                             : '${selectedDate!.toLocal()}'.split(' ')[0],
//                         style: const TextStyle(fontSize: 16),
//                       ),
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.calendar_today, color: Colors.teal),
//                   onPressed: () => _selectDate(context),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             Row(
//               children: [
//                 const Text('Odometer:',
//                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//                 Expanded(
//                   child: TextField(
//                     controller: odometerController,
//                     keyboardType: TextInputType.number,
//                     decoration: InputDecoration(
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(8),
//                         borderSide: const BorderSide(color: Colors.teal, width: 1.5),
//                       ),
//                       hintText: 'Enter mileage',
//                       filled: true,
//                       fillColor: Colors.white,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20),
//             const Text(
//               'Replacements',
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal),
//             ),
//             ...replacements.keys.map((key) {
//               return Card(
//                 elevation: 2,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Row(
//                         children: [
//                           Checkbox(
//                             value: replacements[key],
//                             activeColor: Colors.teal,
//                             onChanged: (bool? value) {
//                               setState(() {
//                                 replacements[key] = value ?? false;
//                               });
//                             },
//                           ),
//                           Text(key, style: const TextStyle(fontSize: 16)),
//                         ],
//                       ),
//                       DropdownButton<String>(
//                         hint: const Text('Select product used', style: TextStyle(fontSize: 14)),
//                         items: ['Caltex', 'TOYOTA', 'TOTACHE']
//                             .map((String value) => DropdownMenuItem<String>(
//                           value: value,
//                           child: Text(value, style: const TextStyle(fontSize: 14)),
//                         ))
//                             .toList(),
//                         onChanged: (String? newValue) {},
//                         style: const TextStyle(color: Colors.black),
//                         dropdownColor: Colors.white,
//                         elevation: 4,
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             }).toList(),
//           ],
//         ),
//       ),
//       backgroundColor: Colors.grey[100],
//     );
//   }
// }
