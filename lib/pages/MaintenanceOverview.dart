import 'package:flutter/material.dart';
import '../services/vehicle_service.dart';

class MaintenanceOverview extends StatefulWidget {
  @override
  _MaintenanceOverviewState createState() => _MaintenanceOverviewState();
}

class _MaintenanceOverviewState extends State<MaintenanceOverview> {
  String _selectedVehicle = '';
  String? _vehicleReference = '';
  List<Map<String, dynamic>> _vehicles = [];
  DateTime? selectedDate;
  final TextEditingController odometerController = TextEditingController();
  final Map<String, bool> replacements = {
    'Engine Oil': false,
    'Transmission Oil': false,
    'Oil Filter': false,
    'Brake Fluid': false,
    // Removed 'Coolant'
  };

  // Store fetched data for each replacement type
  final Map<String, List<Map<String, dynamic>>> replacementData = {
    'Engine Oil': [],
    'Transmission Oil': [],
    'Oil Filter': [],
    'Brake Fluid': [],
    // Removed 'Coolant'
  };

  // Store selected products for each replacement
  final Map<String, String?> selectedProducts = {
    'Engine Oil': null,
    'Transmission Oil': null,
    'Oil Filter': null,
    'Brake Fluid': null,
    // Removed 'Coolant'
  };

  final VehicleService vehicleService = VehicleService();

  @override
  void initState() {
    super.initState();
    fetchUserVehicles();
    _loadVehicles();
    _fetchReplacementData(); // Fetch data for all replacement types
  }

  // Fetch data for all replacement types
  Future<void> _fetchReplacementData() async {
    try {
      final engineOils = await vehicleService.fetchEngineOils();
      final transmissionOils = await vehicleService.fetchTransmissionOils();
      final oilFilters = await vehicleService.fetchOilFilters();
      final brakeFluids = await vehicleService.fetchBrakeFluids();

      // Debug prints
      print('Engine Oils: $engineOils');
      print('Transmission Oils: $transmissionOils');
      print('Oil Filters: $oilFilters');
      print('Brake Fluids: $brakeFluids');

      setState(() {
        replacementData['Engine Oil'] = engineOils;
        replacementData['Transmission Oil'] = transmissionOils;
        replacementData['Oil Filter'] = oilFilters;
        replacementData['Brake Fluid'] = brakeFluids;
      });
    } catch (e) {
      debugPrint('Error fetching replacement data: $e');
    }
  }

  Future<void> _loadVehicles() async {
    try {
      final data = await vehicleService.fetchUserVehicles();
      if (mounted) {
        setState(() {
          _vehicles = VehicleService().extractVehicles(data);
          if (_vehicles.isNotEmpty) {
            _selectedVehicle = _vehicles[0]['name'];
            _vehicleReference = _vehicles[0]['vehicleRef'];
          }
        });
      }
    } catch (e) {
      debugPrint('Error in _loadVehicles: $e');
      rethrow;
    }
  }

  void _onVehicleChanged(String? newValue) {
    if (newValue != null) {
      setState(() {
        _selectedVehicle = newValue;
      });
    }
  }

  Future<void> fetchUserVehicles() async {
    try {
      final data = await vehicleService.fetchUserVehicles();
      setState(() {
        _vehicles = vehicleService.extractVehicles(data);
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
            _buildVehicleSelector(),
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
                      if (replacementData[key]!.isEmpty)
                        const Text('No products available', style: TextStyle(fontSize: 14))
                      else
                        DropdownButton<String>(
                          hint: const Text('Select product used', style: TextStyle(fontSize: 14)),
                          value: selectedProducts[key],
                          items: replacementData[key]!.map((product) {
                            return DropdownMenuItem<String>(
                              value: product['id'], // Use the product ID as the value
                              child: Text(product['name'], style: const TextStyle(fontSize: 14)), // Use only the name
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedProducts[key] = newValue;
                            });
                          },
                          style: const TextStyle(color: Colors.black),
                          dropdownColor: Colors.white,
                          elevation: 4,
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (_vehicleReference == null || selectedDate == null || odometerController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields')),
                  );
                  return;
                }

                try {
                  await VehicleService().saveMaintenanceRecord(
                    vehicleId: _vehicleReference!,
                    date: selectedDate!,
                    odometer: double.parse(odometerController.text),
                    engineOil: selectedProducts['Engine Oil'] ?? 'N/A',
                    transmissionOil: selectedProducts['Transmission Oil'] ?? 'N/A',
                    airFilter: selectedProducts['Oil Filter'] ?? 'N/A',
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Maintenance record saved successfully')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to save maintenance record: $e')),
                  );
                }
              },
              child: const Text('Save Maintenance Record'),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.grey[100],
    );
  }

  Widget _buildVehicleSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(5),
        ),
        child: DropdownButton<String>(
          value: _selectedVehicle,
          icon: const Icon(Icons.arrow_drop_down),
          isExpanded: true,
          underline: Container(),
          onChanged: _onVehicleChanged,
          items: _vehicles.map<DropdownMenuItem<String>>((vehicle) {
            return DropdownMenuItem<String>(
              value: vehicle['name'],
              child: Text(vehicle['name']),
            );
          }).toList(),
        ),
      ),
    );
  }
}
// import 'package:flutter/material.dart';
// import '../services/vehicle_service.dart';
//
// class MaintenanceOverview extends StatefulWidget {
//   @override
//   _MaintenanceOverviewState createState() => _MaintenanceOverviewState();
// }
//
// class _MaintenanceOverviewState extends State<MaintenanceOverview> {
//   List<Map<String, dynamic>> engineOils = [];
//   String _selectedVehicle = '';
//   String? _vehicleReference = '';
//   List<Map<String, dynamic>> _vehicles = [];
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
//   String? selectedVehicleId;
//   List<Map<String, dynamic>> userVehicles = [];
//   final VehicleService vehicleService = VehicleService();
//
//   // Add a map to store selected products for each replacement
//   final Map<String, String?> selectedProducts = {
//     'Engine Oil': null,
//     'Transmission Oil': null,
//     'Oil Filter': null,
//     'Brake Fluid': null,
//     'Coolant': null,
//   };
//
//   @override
//   void initState() {
//     super.initState();
//     fetchUserVehicles();
//     _loadVehicles();
//   }
//
//   Future<void> _loadVehicles() async {
//     try {
//       final data = await VehicleService().fetchUserVehicles();
//       if (mounted) {
//         setState(() {
//           _vehicles = VehicleService().extractVehicles(data);
//           if (_vehicles.isNotEmpty) {
//             print(_vehicles);
//             _selectedVehicle = _vehicles[0]['name'];
//             _vehicleReference = _vehicles[0]['vehicleRef'];
//           }
//         });
//       }
//     } catch (e) {
//       debugPrint('Error in _loadVehicles: $e');
//       rethrow;
//     }
//   }
//
//   void _onVehicleChanged(String? newValue) {
//     if (newValue != null) {
//       setState(() {
//         _selectedVehicle = newValue;
//       });
//     }
//   }
//
//   Future<void> fetchUserVehicles() async {
//     try {
//       final data = await vehicleService.fetchUserVehicles();
//       setState(() {
//         userVehicles = vehicleService.extractVehicles(data);
//       });
//     } catch (e) {
//       print('Error fetching user vehicles: $e');
//     }
//   }
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
//             _buildVehicleSelector(),
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
//                         value: selectedProducts[key],
//                         items: ['Caltex', 'TOYOTA', 'TOTACHE']
//                             .map((String value) => DropdownMenuItem<String>(
//                           value: value,
//                           child: Text(value, style: const TextStyle(fontSize: 14)),
//                         ))
//                             .toList(),
//                         onChanged: (String? newValue) {
//                           setState(() {
//                             selectedProducts[key] = newValue;
//                           });
//                         },
//                         style: const TextStyle(color: Colors.black),
//                         dropdownColor: Colors.white,
//                         elevation: 4,
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             }).toList(),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () async {
//                 // print(_vehicleReference);
//                 if (_vehicleReference == null || selectedDate == null || odometerController.text.isEmpty) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text('Please fill all fields')),
//                   );
//                   return;
//                 }
//
//                 try {
//                   await VehicleService().saveMaintenanceRecord(
//                     vehicleId: _vehicleReference!,
//                     date: selectedDate!,
//                     odometer: double.parse(odometerController.text),
//                     engineOil: selectedProducts['Engine Oil'] ?? 'N/A',
//                     transmissionOil: selectedProducts['Transmission Oil'] ?? 'N/A',
//                     airFilter: selectedProducts['Oil Filter'] ?? 'N/A',
//                   );
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text('Maintenance record saved successfully')),
//                   );
//                 } catch (e) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(content: Text('Failed to save maintenance record: $e')),
//                   );
//                 }
//               },
//               child: const Text('Save Maintenance Record'),
//             ),
//           ],
//         ),
//       ),
//       backgroundColor: Colors.grey[100],
//     );
//   }
//
//   Widget _buildVehicleSelector() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 10),
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 16),
//         decoration: BoxDecoration(
//           color: Colors.grey[300],
//           borderRadius: BorderRadius.circular(5),
//         ),
//         child: DropdownButton<String>(
//           value: _selectedVehicle,
//           icon: const Icon(Icons.arrow_drop_down),
//           isExpanded: true,
//           underline: Container(),
//           onChanged: _onVehicleChanged,
//           items: _vehicles.map<DropdownMenuItem<String>>((vehicle) {
//             return DropdownMenuItem<String>(
//               value: vehicle['name'],
//               child: Text(vehicle['name']),
//             );
//           }).toList(),
//         ),
//       ),
//     );
//   }
// }