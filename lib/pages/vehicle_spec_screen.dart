import 'package:flutter/material.dart';
import 'package:drivewise/services/vehicle_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

class VehicleSpecScreen extends StatefulWidget {
  final String make;
  final String model;
  final String year;
  final String engine;

  const VehicleSpecScreen({
    Key? key,
    required this.make,
    required this.model,
    required this.year,
    required this.engine,
  }) : super(key: key);

  @override
  _VehicleSpecScreenState createState() => _VehicleSpecScreenState();
}

class _VehicleSpecScreenState extends State<VehicleSpecScreen> {
  final VehicleService _vehicleService = VehicleService();
  Map<String, dynamic> vehicleSpecs = {};
  bool isLoading = true;
  String? errorMessage;
  String? imageUrl;

  @override
  void initState() {
    super.initState();
    _loadVehicleSpecs();
  }

  Future<void> _loadVehicleSpecs() async {
    try {
      // First try to load the vehicle specs
      final specs = await _vehicleService.fetchVehicleSpecs(
        widget.make,
        widget.model,
        widget.year,
        widget.engine,
      );

      // If no image URL is in specs or it's invalid, try to get a generic one
      if (!specs.containsKey('imageUrl') ||
          specs['imageUrl'] == null ||
          specs['imageUrl'].toString().isEmpty) {

        // Try to get a fallback image separately
        final fallbackImageUrl = await _vehicleService.fetchVehicleImage(
            widget.make,
            widget.model
        );

        if (fallbackImageUrl != null && fallbackImageUrl.isNotEmpty) {
          specs['imageUrl'] = fallbackImageUrl;
        }
      }

      setState(() {
        vehicleSpecs = specs;
        imageUrl = specs['imageUrl'];
        // Debug the image URL
        print('Image URL set to: $imageUrl');
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load vehicle specifications: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'DriveWise',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 26,
            fontStyle: FontStyle.italic,
          ),
        ),
        backgroundColor: Color(0xFF030B23),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: const Color(0xFF0D1128),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.deepOrange))
          : errorMessage != null
          ? Center(
        child: Text(
          errorMessage!,
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Quick Lookup/Vehicle Specification',
              style: TextStyle(fontSize: 15, color: Colors.white),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                '${widget.make} ${widget.model} ${widget.year}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Improved vehicle image container with debug info
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(12),
              ),
              child: imageUrl != null && imageUrl!.isNotEmpty
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: imageUrl!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Colors.deepOrange),
                        SizedBox(height: 8),
                        Text(
                          'Loading image...',
                          style: TextStyle(color: Colors.white54),
                        ),
                      ],
                    ),
                  ),
                  errorWidget: (context, url, error) {
                    // Debug the error
                    print('Image error: $error for URL: $url');
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.directions_car,
                            color: Colors.white54,
                            size: 80,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Image could not be loaded',
                            style: TextStyle(color: Colors.white54),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              )
                  : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.directions_car,
                      color: Colors.white54,
                      size: 80,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'No image available',
                      style: TextStyle(color: Colors.white54),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
            SpecItem(title: 'Engine', value: vehicleSpecs['engine'] ?? 'Not specified'),
            SpecItem(title: 'Engine Oil', value: vehicleSpecs['engineOil'] ?? 'Not specified'),
            SpecItem(title: 'Transmission Oil', value: vehicleSpecs['transmissionOil'] ?? 'Not specified'),
            SpecItem(title: 'Oil Filter', value: vehicleSpecs['oilFilter'] ?? 'Not specified'),
            SpecItem(title: 'Brake Fluid', value: vehicleSpecs['brakeOil'] ?? 'Not specified'),
            SpecItem(title: 'Coolant Type', value: vehicleSpecs['coolant'] ?? 'Not specified'),
          ],
        ),
      ),
    );
  }
}

class SpecItem extends StatelessWidget {
  final String title;
  final String value;

  const SpecItem({Key? key, required this.title, required this.value})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }
}