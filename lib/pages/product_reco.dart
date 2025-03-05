import 'package:flutter/material.dart';


class QuickLookupProRec extends StatelessWidget {
  final String engineOilGrade;
  final String engineOilCapacity;

  const QuickLookupProRec({
    required this.engineOilGrade,
    required this.engineOilCapacity,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF030B23),
        title: const Text(
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Quick Lookup / Vehicle Specification / Products',
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 10),
              const Text(
                'Engine Oil',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.orange),
              ),
              const SizedBox(height: 10),
              Center(
                child: Image.asset(
                  'assets/images/engine_oil.jpg.png', // Ensure this file exists in assets
                  height: 150,
                  errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.error, size: 100, color: Colors.red),
                ),
              ),
              const SizedBox(height: 10),
              Text('Grade: $engineOilGrade', style: const TextStyle(fontSize: 16)),
              Text('Capacity: $engineOilCapacity', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 20),
              const Text(
                'Brands',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange),
              ),
              const SizedBox(height: 10),
              GridView.count(
                shrinkWrap: true, // Fix issue inside Column
                physics: const NeverScrollableScrollPhysics(), // Prevent nested scrolling issues
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  brandCard('Toyota', 'assets/images/toyota.png'),
                  brandCard('Valvoline', 'assets/images/valvoline.png'),
                  brandCard('Lukoil', 'assets/images/lukoil.png'),
                  brandCard('Mobil', 'assets/images/mobil.png'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget brandCard(String brandName, String imagePath) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              height: 60,
              errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            Text(
              brandName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
