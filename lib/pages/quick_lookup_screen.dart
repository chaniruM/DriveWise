import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'vehicle_spec_screen.dart';

class QuickLookupScreen extends StatefulWidget {
  @override
  _QuickLookupScreenState createState() => _QuickLookupScreenState();
}

class _QuickLookupScreenState extends State<QuickLookupScreen> {
  final List<String> makes = ['Toyota', 'BMW', 'Audi', 'Nissan', 'Mercedes', 'Land Rover', 'Mazda', 'Honda'];
  final Map<String, List<String>> models = {
    'Toyota': ['Axio', 'Corolla', 'Camry'],
    'BMW': ['X5', 'X3', 'M3'],
    'Audi': ['A3', 'A4', 'Q7'],
    'Nissan': ['Altima', 'Skyline', 'Juke'],
    'Mercedes': ['C-Class', 'E-Class', 'S-Class'],
    'Land Rover': ['Defender', 'Discovery', 'Range Rover'],
    'Mazda': ['CX-5', 'Mazda3', 'RX-8'],
    'Honda': ['Civic', 'Accord', 'CR-V'],
  };
  final List<String> years = ['2024', '2023', '2022', '2021', '2020'];
  final List<String> engines = ['1.5L', '2.0L', '3.0L Turbo', 'Electric'];

  String? selectedMake;
  String? selectedModel;
  String? selectedYear;
  String? selectedEngine;

  final _formKey = GlobalKey<FormState>(); // Form key for validation

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF030B23),
        title: Text(
          'DriveWise',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 26,
            fontStyle: FontStyle.italic,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: const Color(0xFF0D1128),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey, // Wrap with Form for validation
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Quick Lookup',
                  style: TextStyle(fontSize: 15, color: Colors.white),
                ),
                SizedBox(
                  height: 270,

                  child: Center(
                    child: Lottie.asset(
                      'assets/animations/car_animation.json',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                buildDropdown('Make:', makes, selectedMake, (value) {
                  setState(() {
                    selectedMake = value;
                    selectedModel = null;
                  });
                }),
                const SizedBox(height: 10),
                buildDropdown('Model:', selectedMake != null ? models[selectedMake!] ?? [] : [], selectedModel, (value) {
                  setState(() => selectedModel = value);
                }),
                const SizedBox(height: 10),
                buildDropdown('Year:', years, selectedYear, (value) {
                  setState(() => selectedYear = value);
                }),
                const SizedBox(height: 10),
                buildDropdown('Engine:', engines, selectedEngine, (value) {
                  setState(() => selectedEngine = value);
                }),
                const SizedBox(height: 20),
                const Center(child: Text("Or", style: TextStyle(color: Colors.white))),
                const SizedBox(height: 20),

                TextField(
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    labelText: 'VIN',
                    labelStyle: const TextStyle(color: Colors.black),
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[700],
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {},
                  child: const Text('Open Camera'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VehicleSpecScreen(
                            make: selectedMake!,
                            model: selectedModel!,
                            year: selectedYear!,
                            engine: selectedEngine!,
                          ),
                        ),
                      );
                    }
                  },

                  child: const Text('Search'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildDropdown(String label, List<String> items, String? selectedValue, ValueChanged<String?> onChanged) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Text(
            label,
            style: const TextStyle(color: Colors.white60),
          ),
        ),
        Expanded(
          flex: 2,
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              hintText: 'Select Option',
              hintStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: Colors.grey[200],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide.none,
              ),
            ),
            value: selectedValue,
            items: items.map((item) {
              return DropdownMenuItem(
                value: item,
                child: Text(item, style: const TextStyle(color: Colors.black)),
              );
            }).toList(),
            onChanged: onChanged,
            validator: (value) => value == null ? 'Please select $label' : null, // Validation
          ),
        ),
      ],
    );
  }
}
