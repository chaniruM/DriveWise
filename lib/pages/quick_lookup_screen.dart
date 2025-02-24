import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'vehicle_spec_screen.dart';

class QuickLookupScreen extends StatefulWidget {
  @override
  _QuickLookupScreenState createState() => _QuickLookupScreenState();
}

class _QuickLookupScreenState extends State<QuickLookupScreen> {
  // Dropdown data
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

  // Selected values
  String? selectedMake;
  String? selectedModel;
  String? selectedYear;
  String? selectedEngine;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1128), // Background color from the image
      drawer: Drawer(
        backgroundColor: const Color(0xFF0D1128), // Background color from the image
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              const Text(
                'Quick Lookup',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
              SizedBox(
                height: 170,
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
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'VIN',
                  labelStyle: const TextStyle(color: Colors.white),
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => VehicleSpecScreen()),
                  );
                },
                child: const Text('Search'),
              ),
            ],
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
            style: const TextStyle(color: Colors.white),
          ),
        ),
        Expanded(
          flex: 2,
          child: DropdownButtonFormField(
            dropdownColor: Colors.grey[300],
            decoration: InputDecoration(
              hintText: 'Select Option',
              hintStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: Colors.grey[200],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            ),
            value: selectedValue,
            items: items.map((item) {
              return DropdownMenuItem(
                value: item,
                child: Text(item, style: const TextStyle(color: Colors.black)),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
