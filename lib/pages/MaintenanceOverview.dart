import 'package:flutter/material.dart';
import '../services/vehicle_service.dart';
import 'maintenance_history_screen.dart';

class MaintenanceOverview extends StatefulWidget {
  @override
  _MaintenanceOverviewState createState() => _MaintenanceOverviewState();
}

class _MaintenanceOverviewState extends State<MaintenanceOverview> {
  String _selectedVehicle = '';
  String _vehicleReference = '';
  List<Map<String, dynamic>> _vehicles = [];
  DateTime? selectedDate;
  final TextEditingController mileageAtService = TextEditingController();
  final TextEditingController nextServiceController = TextEditingController();
  final Map<String, bool> replacements = {
    'Engine Oil': false,
    'Transmission Oil': false,
    'Oil Filter': false,
    'Brake Fluid': false,
  };


  // Store fetched data for each replacement type
  final Map<String, List<Map<String, dynamic>>> replacementData = {
    'Engine Oil': [],
    'Transmission Oil': [],
    'Oil Filter': [],
    'Brake Fluid': [],
  };

  // Store selected products for each replacement
  final Map<String, String?> selectedProducts = {
    'Engine Oil': null,
    'Transmission Oil': null,
    'Oil Filter': null,
    'Brake Fluid': null,
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

  // void _onVehicleChanged(String? newValue) {
  //   if (newValue != null) {
  //     setState(() {
  //       _selectedVehicle = newValue;
  //     });
  //   }
  // }
  void _onVehicleChanged(String? newValue) {
    if (newValue != null) {
      final selectedVehicle = _vehicles.firstWhere((vehicle) => vehicle['name'] == newValue);
      setState(() {
        _selectedVehicle = newValue;
        _vehicleReference = selectedVehicle['vehicleRef']; // Update vehicleRef
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
                const Text('Mileage at Service:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Expanded(
                  child: TextField(
                    controller: mileageAtService,
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
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Next Service:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Expanded(
                  child: TextField(
                    controller: nextServiceController,
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
                        Expanded( // Use Expanded here
                          child: DropdownButton<String>(
                            isExpanded: true, // Add isExpanded: true
                            hint: const Text('Select product used', style: TextStyle(fontSize: 14)),
                            value: selectedProducts[key],
                            items: replacementData[key]!.map((product) {
                              return DropdownMenuItem<String>(
                                value: product['name'],
                                child: Expanded( // Use Expanded here
                                  child: Text(
                                    product['name'],
                                    style: const TextStyle(fontSize: 14),
                                    overflow: TextOverflow.ellipsis, // Truncate long text
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedProducts[key] = newValue;
                                print(selectedProducts);
                              });
                            },
                            style: const TextStyle(color: Colors.black),
                            dropdownColor: Colors.white,
                            elevation: 4,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    if (selectedDate == null || nextServiceController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill all fields')),
                      );
                      return;
                    }

                    try {
                      await VehicleService().saveMaintenanceRecord(
                        vehicleId: _vehicleReference,
                        date: selectedDate!,
                        mileageAtService: double.parse(mileageAtService.text),
                        nextService: double.parse(nextServiceController.text),
                        engineOil: selectedProducts['Engine Oil'] ?? 'N/A',
                        transmissionOil: selectedProducts['Transmission Oil'] ?? 'N/A',
                        airFilter: selectedProducts['Oil Filter'] ?? 'N/A',
                        brakeFluid: selectedProducts['Brake Fluid'] ?? 'N/A',
                      );

                      // Update next service mileage
                      await VehicleService().updateNextServiceMileage(
                        vehicleId: _vehicleReference,
                        nextServiceMileage: double.parse(nextServiceController.text),
                      );

                      setState(() {
                        selectedDate = null;
                        mileageAtService.clear();
                        nextServiceController.clear();

                        // Reset checkboxes
                        replacements.forEach((key, value) {
                          replacements[key] = false;
                        });

                        // Reset selected products
                        selectedProducts.forEach((key, value) {
                          selectedProducts[key] = null;
                        });
                      });

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
                ElevatedButton(
                  onPressed: () {
                    if (_vehicleReference == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select a vehicle')),
                      );
                      return;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MaintenanceHistoryScreen(vehicleId: _vehicleReference,),
                      ),
                    );
                  },
                  child: const Text('Check History'),
                ),
              ],
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