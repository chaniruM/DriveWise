import 'package:flutter/material.dart';

class RegisterVehiclePage extends StatefulWidget {
  @override
  _RegisterVehicleScreenState createState() => _RegisterVehicleScreenState();
}

class _RegisterVehicleScreenState extends State<RegisterVehiclePage> {
  final _formKey = GlobalKey<FormState>();
  String? selectedMake, selectedModel, selectedYear, selectedEngine;
  final TextEditingController _vinController = TextEditingController();
  final TextEditingController _regNumberController = TextEditingController();
  DateTime? _licenseExpiryDate;
  DateTime? _insuranceExpiryDate;

  // Service Information Fields
  TextEditingController _odometerController = TextEditingController();
  TextEditingController _nextServiceController = TextEditingController();

  // Slider Values
  double _dailyTravelDistance = 100;
  double _longestTripDistance = 200;

  // Radio Button Groups
  int? _vehicleUsageFrequency; // Group for "How often do you use this vehicle?"
  int? _longTripFrequency;     // Group for "How often do you go on such excursions?"

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register New Vehicle'),
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: Color(0xFF030B23),
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Generic Information Section
                Text(
                  'Generic Information',
                  style: TextStyle(
                    color: Colors.orangeAccent,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildDropdownRow('Make', ['Toyota', 'Honda', 'Ford'], (val) => setState(() => selectedMake = val)),
                SizedBox(height: 16), // Add space between dropdowns
                _buildDropdownRow('Model', ['Model X', 'Civic', 'Mustang'], (val) => setState(() => selectedModel = val)),
                SizedBox(height: 16), // Add space between dropdowns
                _buildDropdownRow('Year', ['2023', '2022', '2021'], (val) => setState(() => selectedYear = val)),
                SizedBox(height: 16), // Add space between dropdowns
                _buildDropdownRow('Engine', ['V6', 'V8', 'Electric'], (val) => setState(() => selectedEngine = val)),

                SizedBox(height: 20),
                Center(child: Text('Or', style: TextStyle(color: Colors.white, fontSize: 16))),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _vinController,
                        decoration: _inputDecoration('VIN'),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {},
                      child: Text('Open Camera'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orangeAccent,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20),
                _buildTextField('Registration No', _regNumberController, (value) {
                  if (value == null || value.isEmpty) {
                    return 'Registration number is required';
                  }
                  if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value)) {
                    return 'Registration number should be alphanumeric';
                  }
                  return null;
                }),
                SizedBox(height: 16),
                _buildDatePicker('Revenue License Expiry Date', _licenseExpiryDate, (date) {
                  if (date == null) return 'Please select a valid date';
                  return null;
                }),
                SizedBox(height: 16),
                _buildDatePicker('Insurance Renewal Date', _insuranceExpiryDate, (date) {
                  if (date == null) return 'Please select a valid date';
                  return null;
                }),

                // Service Information Section
                SizedBox(height: 20),
                Text(
                  "Service Information",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orangeAccent),
                ),
                SizedBox(height: 10),

                // Odometer
                _buildTextField('Odometer', _odometerController, (value) {
                  if (value == null || value.isEmpty) {
                    return 'Odometer is required';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                }),

                // Buttons for OBD2 or Camera
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {},
                      child: Text("Use OBD2"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orangeAccent, // Button color
                      ),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {},
                      child: Text("Open Camera"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orangeAccent, // Button color
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                // Next Service
                _buildTextField('Next Service', _nextServiceController, (value) {
                  if (value == null || value.isEmpty) {
                    return 'Next service date is required';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                }),
                SizedBox(height: 10),

                ElevatedButton(
                  onPressed: () {},
                  child: Text("Open Camera"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent, // Button color
                  ),
                ),
                SizedBox(height: 20),

                // Revenue License Expiry Date Picker
                _buildDatePicker("Revenue License Expiry Date", _licenseExpiryDate, (date) {
                  setState(() {
                    _licenseExpiryDate = date;
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

                // Travel Information
                Text(
                  "How much do you travel in this vehicle on a regular day?",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                Slider(
                  value: _dailyTravelDistance,
                  min: 0,
                  max: 500,
                  divisions: 50,
                  label: "${_dailyTravelDistance.toStringAsFixed(0)} km",
                  onChanged: (value) {
                    setState(() {
                      _dailyTravelDistance = value;
                    });
                  },
                  activeColor: Colors.orangeAccent, // Set the active color
                  inactiveColor: Colors.white54,
                ),
                SizedBox(height: 16),

                Text(
                  "How often do you use this vehicle?",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                Column(
                  children: [
                    RadioListTile<int>(
                      title: Text("Once a week", style: TextStyle(color: Colors.white)),
                      value: 1,
                      groupValue: _vehicleUsageFrequency,
                      onChanged: (int? value) {
                        setState(() {
                          _vehicleUsageFrequency = value;
                        });
                      },
                      tileColor: Colors.white, // Change the background color of the tile
                      activeColor: Colors.orange,
                    ),
                    RadioListTile<int>(
                      title: Text("2-4 days a week", style: TextStyle(color: Colors.white)),
                      value: 2,
                      groupValue: _vehicleUsageFrequency,
                      onChanged: (int? value) {
                        setState(() {
                          _vehicleUsageFrequency = value;
                        });
                      },
                      tileColor: Colors.white, // Change the background color of the tile
                      activeColor: Colors.orange,
                    ),
                    RadioListTile<int>(
                      title: Text("4-6 days a week", style: TextStyle(color: Colors.white)),
                      value: 3,
                      groupValue: _vehicleUsageFrequency,
                      onChanged: (int? value) {
                        setState(() {
                          _vehicleUsageFrequency = value;
                        });
                      },
                      tileColor: Colors.white, // Change the background color of the tile
                      activeColor: Colors.orange,
                    ),
                    RadioListTile<int>(
                      title: Text("Daily", style: TextStyle(color: Colors.white)),
                      value: 4,
                      groupValue: _vehicleUsageFrequency,
                      onChanged: (int? value) {
                        setState(() {
                          _vehicleUsageFrequency = value;
                        });
                      },
                      tileColor: Colors.white, // Change the background color of the tile
                      activeColor: Colors.orange,
                    ),
                  ],
                ),

                SizedBox(height: 16),

                Text(
                  "What is the longest trip you would take?",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                Slider(
                  value: _longestTripDistance,
                  min: 0,
                  max: 800,
                  divisions: 50,
                  label: "${_longestTripDistance.toStringAsFixed(0)} km",
                  onChanged: (value) {
                    setState(() {
                      _longestTripDistance = value;
                    });
                  },
                  activeColor: Colors.orangeAccent, // Set the active color
                  inactiveColor: Colors.white54,
                ),
                SizedBox(height: 16),

                Text(
                  "How often do you go on such excursions?",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                Column(
                  children: [
                    RadioListTile<int>(
                      title: Text("Frequently", style: TextStyle(color: Colors.white)),
                      value: 1,
                      groupValue: _longTripFrequency,
                      onChanged: (int? value) {
                        setState(() {
                          _longTripFrequency = value;
                        });
                      },
                      tileColor: Colors.white, // Change the background color of the tile
                      activeColor: Colors.orange,
                    ),
                    RadioListTile<int>(
                      title: Text("Once a week", style: TextStyle(color: Colors.white)),
                      value: 2,
                      groupValue: _longTripFrequency,
                      onChanged: (int? value) {
                        setState(() {
                          _longTripFrequency = value;
                        });
                      },
                      tileColor: Colors.white, // Change the background color of the tile
                      activeColor: Colors.orange,
                    ),
                    RadioListTile<int>(
                      title: Text("Once a month", style: TextStyle(color: Colors.white)),
                      value: 3,
                      groupValue: _longTripFrequency,
                      onChanged: (int? value) {
                        setState(() {
                          _longTripFrequency = value;
                        });
                      },
                      tileColor: Colors.white, // Change the background color of the tile
                      activeColor: Colors.orange,
                    ),
                    RadioListTile<int>(
                      title: Text("Rare", style: TextStyle(color: Colors.white)),
                      value: 4,
                      groupValue: _longTripFrequency,
                      onChanged: (int? value) {
                        setState(() {
                          _longTripFrequency = value;
                        });
                      },
                      tileColor: Colors.white, // Change the background color of the tile
                      activeColor: Colors.orange,
                    ),
                  ],
                ),

                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // Form is valid, handle registration logic
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
            onChanged: onChanged,
          ),
        ),
      ],
    );
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
          validator: validator,
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
}

