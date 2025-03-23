import 'package:drivewise/pages/my_cars.dart';
import 'package:drivewise/services/vehicle_service.dart';
import 'package:flutter/material.dart';

class RegisterVehiclePage extends StatefulWidget {
  @override
  _RegisterVehicleScreenState createState() => _RegisterVehicleScreenState();
}

class _RegisterVehicleScreenState extends State<RegisterVehiclePage> {
  final _formKey = GlobalKey<FormState>();
  String? selectedMake, selectedModel, selectedYear, selectedEngine, selectedBrand;
  final TextEditingController _regNumberController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  DateTime? _licenseExpiryDate;
  DateTime? _insuranceExpiryDate;
  DateTime? _emmissionsExpiryDate;

  // Service Information Fields
  TextEditingController _odometerController = TextEditingController();
  TextEditingController _nextServiceController = TextEditingController();

  // Lists for dropdown options
  List<String> makes = [];
  List<String> models = [];
  List<String> engineTypes = [];
  List<String> years = [];

  @override
  void initState() {
    super.initState();
    _loadMakes();
  }

  Future<void> _loadMakes() async {
    try {
      List<String> fetchedMakes = await VehicleService().fetchMakes();
      setState(() {
        makes = fetchedMakes;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> _loadModels(String make) async {
    try {
      List<String> fetchedModels = await VehicleService().fetchModels(make);
      setState(() {
        models = fetchedModels;
        selectedModel = null;
        engineTypes = [];
        years = [];
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> _loadEngines(String make, String model) async {
    try {
      List<String> fetchedEngines = await VehicleService().fetchEngines(make, model);
      setState(() {
        engineTypes = fetchedEngines;
        selectedEngine = null;
        years = [];
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> _loadYears(String make, String model, String engine) async {
    try {
      List<String> fetchedYears = await VehicleService().fetchYears(make, model, engine);
      setState(() {
        years = fetchedYears;
        selectedYear = null;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register New Vehicle'),
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: const Color(0xFF030B23),
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Generic Information Section
                const Text(
                  'Generic Information',
                  style: TextStyle(
                    color: Colors.orangeAccent,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),

                _buildDropdownRow(
                    'Make',
                    makes,
                    (val) {
                      setState(() => selectedMake = val);
                      if (val != null) _loadModels(val);
                    }
                ),
                SizedBox(height: 16),

                // Model Dropdown
                _buildDropdownRow(
                    'Model',
                    models,
                    (val){
                      setState(() => selectedModel = val);
                      if (val != null && selectedMake != null) _loadEngines(selectedMake!, val);
                    },
                ),
                const SizedBox(height: 16),

                // Engine Dropdown
                _buildDropdownRow(
                    'Engine',
                    engineTypes,
                    (val) {
                      setState(() => selectedEngine = val);
                      if (val != null && selectedMake != null && selectedModel != null) {
                        _loadYears(selectedMake!, selectedModel!, val);
                      }
                    },
                ),
                const SizedBox(height: 16),

                // Year Dropdown
                _buildDropdownRow(
                    'Year',
                    years,
                    (val) => setState(() => selectedYear = val),
                ),


                const SizedBox(height: 20),
                _buildTextField('Registration No', _regNumberController, (value) {
                  if (value == null || value.isEmpty) {
                    return 'Registration number is required';
                  }
                  if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value)) {
                    return 'Registration number should be alphanumeric';
                  }
                  return null;
                }),

                // Service Information Section
                const SizedBox(height: 20),
                const Text(
                  "Service Information",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orangeAccent),
                ),
                SizedBox(height: 10),

                // Odometer
                _buildTextField('Current Odometer Reading', _odometerController, (value) {
                  if (value == null || value.isEmpty) {
                    return 'Odometer is required';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                }),

                SizedBox(height: 20),

                // Next Service
                _buildTextField('Next Service Mileage', _nextServiceController, (value) {
                  if (value == null || value.isEmpty) {
                    return 'Next service date is required';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                }),
                SizedBox(height: 10),


                // Revenue License Expiry Date Picker
                _buildDatePicker("Revenue License Expiry Date", _licenseExpiryDate, (date) {
                  setState(() {
                    _licenseExpiryDate = date;
                  });
                }),

                SizedBox(height: 16),

                // Emissions Test Expiry Date Picker
                _buildDatePicker("Emissions Test Expiry Date", _emmissionsExpiryDate, (date) {
                  setState(() {
                    _emmissionsExpiryDate = date;
                  });
                }),

                SizedBox(height: 16),

                // Insurance Renewal Date Picker
                _buildDatePicker("Insurance Renewal Date", _insuranceExpiryDate, (date) {
                  setState(() {
                    _insuranceExpiryDate = date;
                  });
                }),

                SizedBox(height: 20),

                _buildDropdownRow('Brand', ['Toyota', 'Totachi', 'LukOil', 'Caltex', 'Valvoline'], (val) => setState(() => selectedBrand = val)),
                SizedBox(height: 16),

                _buildTextField('Nickname', _nicknameController, (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nickname is required';
                  }
                  if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value)) {
                    return 'Nickname should be alphanumeric';
                  }
                  return null;
                }),

                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _registerVehicle();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent, // Button color
                    ),
                    child: Text("Register Vehicle"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownRow(String label, List<String> items, Function(String?) onChanged) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text('$label:', style: TextStyle(color: Colors.white, fontSize: 16)),
        ),
        Expanded(
          flex: 3,
          child: DropdownButtonFormField<String>(
            decoration: _inputDecoration('Select option'),
            dropdownColor: Colors.black,
            style: TextStyle(color: Colors.white),
            items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            // onChanged: enabled ? onChanged : null,
            onChanged: onChanged,
            value: _getDropdownValue(label), // Get appropriate value based on label
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a $label';
              }
              return null;
            },
            isExpanded: true,
          ),
        ),
      ],
    );
  }

  String? _getDropdownValue(String label) {
    switch (label) {
      case 'Make':
        return selectedMake;
      case 'Model':
        return selectedModel;
      case 'Engine':
        return selectedEngine;
      case 'Year':
        return selectedYear;
      default:
        return null;
    }
  }

  Widget _buildTextField(String label, TextEditingController controller, String? Function(String?)? validator) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label:', style: TextStyle(color: Colors.white, fontSize: 16)),
        SizedBox(height: 5),
        TextFormField(
          controller: controller,
          decoration: _inputDecoration('Enter $label'),
          style: TextStyle(color: Colors.white),
          validator: label == 'Registration No'
              ? (value) {
            if (value == null || value.isEmpty) {
              return 'Registration number is required';
            }
            if (!RegExp(r'^[A-Z]{2,3}\s\d{4}$').hasMatch(value)) {
              return 'Registration number must be in the format: CAM 6584';
            }
            return null;
          }
              : validator, // Use the provided validator for other fields
        ),
        SizedBox(height: 10),
      ],
    );
  }

  Widget _buildDatePicker(String label, DateTime? selectedDate, Function(DateTime) onDateChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label:', style: TextStyle(color: Colors.white, fontSize: 16)),
        SizedBox(height: 5),
        GestureDetector(
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: selectedDate ?? DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime(2100),
            );
            if (pickedDate != null) onDateChanged(pickedDate);
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white54),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedDate == null
                      ? 'Select date'
                      : '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                  style: TextStyle(color: Colors.white),
                ),
                Icon(Icons.calendar_today, color: Colors.white),
              ],
            ),
          ),
        ),
        SizedBox(height: 10),
      ],
    );
  }

  InputDecoration _inputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.white54),
      filled: true,
      fillColor: Color(0xFF2A2A2A),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }

  Future<void> _registerVehicle() async {
    if (_formKey.currentState!.validate()) {
      // Parse odometer and next service mileage
      double odometer = double.parse(_odometerController.text);
      double nextService = double.parse(_nextServiceController.text);

      // Validate next service mileage against odometer
      if (nextService <= odometer) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Next service mileage must be greater than current odometer reading.')),
        );
        return; // Stop the registration process
      }
      try {
        await VehicleService().registerVehicle(
          make: selectedMake!,
          model: selectedModel!,
          engineType: selectedEngine!,
          year: selectedYear!,
          registrationNumber: _regNumberController.text,
          odometerReading: double.parse(_odometerController.text),
          nextServiceReading: double.parse(_nextServiceController.text),
          licenseExpiryDate: _licenseExpiryDate!,
          insuranceExpiryDate: _insuranceExpiryDate!,
          emmissionsExpiryDate: _emmissionsExpiryDate!,
          preferredBrand: selectedBrand!,
          nickname: _nicknameController.text,
        );

        // Show a success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Vehicle registered successfully!')),
        );

        // navigate to my cars screen after successful registration
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyCarsPage()));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to register vehicle: $e')),
        );
      }
    }
  }
}

