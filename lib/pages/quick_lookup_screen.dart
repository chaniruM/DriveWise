import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:image_picker/image_picker.dart';
import 'vehicle_spec_screen.dart';
import 'package:drivewise/services/vehicle_service.dart';

class QuickLookupScreen extends StatefulWidget {
  @override
  _QuickLookupScreenState createState() => _QuickLookupScreenState();
}

class _QuickLookupScreenState extends State<QuickLookupScreen> {
  final _formKey = GlobalKey<FormState>();
  final VehicleService _vehicleService = VehicleService();
  String? selectedMake,
      selectedModel,
      selectedYear,
      selectedEngine,
      selectedBrand;

  // Lists for dropdown options
  List<String> makes = [];
  Map<String, List<String>> models = {};
  List<String> engineTypes = [];
  List<String> years = [];
  List<String> brands = [];
  String vinNumber = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => isLoading = true);

    try {
      // Load makes
      makes = await _vehicleService.fetchMakes();

      // Load brands for preferred brand dropdown
      brands = await _vehicleService.fetchBrands();

      setState(() => isLoading = false);
    } catch (e) {
      print('Error loading initial data: $e');
      setState(() => isLoading = false);
    }
  }

  // Load models when make is selected
  Future<void> _loadModels(String make) async {
    setState(() => isLoading = true);

    try {
      final modelsList = await _vehicleService.fetchModels(make);
      setState(() {
        models[make] = modelsList;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading models: $e');
      setState(() => isLoading = false);
    }
  }

  // Load engines when model is selected
  Future<void> _loadEngines(String make, String model) async {
    setState(() => isLoading = true);

    try {
      engineTypes = await _vehicleService.fetchEngines(make, model);
      setState(() => isLoading = false);
    } catch (e) {
      print('Error loading engines: $e');
      setState(() => isLoading = false);
    }
  }

  // Load years when engine is selected
  Future<void> _loadYears(String make, String model, String engine) async {
    setState(() => isLoading = true);

    try {
      years = await _vehicleService.fetchYears(make, model, engine);
      setState(() => isLoading = false);
    } catch (e) {
      print('Error loading years: $e');
      setState(() => isLoading = false);
    }
  }

  // Open camera and capture image
  Future<void> _openCamera() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? photo = await picker.pickImage(source: ImageSource.camera);

      if (photo != null) {
        // Here you would add VIN detection logic
        // For now, just show a message that the image was captured
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image captured. Processing VIN...')),
        );

        // Simulating VIN detection (replace with actual OCR implementation)
        // setState(() => vinNumber = 'Detected VIN would appear here');
      }
    } catch (e) {
      print('Error capturing image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to open camera: $e')),
      );
    }
  }

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
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.deepOrange))
          : Padding(
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
                          selectedEngine = null;
                          selectedYear = null;
                        });
                        if (value != null) {
                          _loadModels(value);
                        }
                      }),
                      const SizedBox(height: 10),
                      buildDropdown(
                          'Model:',
                          selectedMake != null
                              ? models[selectedMake] ?? []
                              : [],
                          selectedModel, (value) {
                        setState(() {
                          selectedModel = value;
                          selectedEngine = null;
                          selectedYear = null;
                        });
                        if (selectedMake != null && value != null) {
                          _loadEngines(selectedMake!, value);
                        }
                      }),
                      const SizedBox(height: 10),
                      buildDropdown('Engine:', engineTypes, selectedEngine,
                          (value) {
                        setState(() => selectedEngine = value);
                        if (selectedMake != null &&
                            selectedModel != null &&
                            value != null) {
                          _loadYears(selectedMake!, selectedModel!, value);
                        }
                      }),
                      const SizedBox(height: 10),
                      buildDropdown('Year:', years, selectedYear, (value) {
                        setState(() => selectedYear = value);
                      }),
                      const SizedBox(height: 20),
                      const Center(
                          child: Text("Or",
                              style: TextStyle(color: Colors.white))),
                      const SizedBox(height: 20),
                      TextField(
                        style: const TextStyle(color: Colors.black),
                        onChanged: (value) {
                          setState(() => vinNumber = value);
                        },
                        decoration: InputDecoration(
                          labelText: 'VIN',
                          labelStyle: const TextStyle(color: Colors.black),
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 12),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[700],
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _openCamera,
                        child: const Text('Open Camera'),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          if (vinNumber.isNotEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content:
                                      Text('Searching for VIN: $vinNumber')),
                            );
                          } else if (_formKey.currentState!.validate()) {
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

  Widget buildDropdown(String label, List<String> items, String? selectedValue,
      ValueChanged<String?> onChanged) {
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
            validator: (value) =>
                value == null ? 'Please select $label' : null, // Validation
          ),
        ),
      ],
    );
  }
}
