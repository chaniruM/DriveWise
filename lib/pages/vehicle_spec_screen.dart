import 'package:flutter/material.dart';

class VehicleSpecScreen extends StatelessWidget {
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
      body: SingleChildScrollView(
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
                '$make $model $year',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Image.asset(
              'assets/images/car.png',
              height: 150,
            ),
            const SizedBox(height: 10),
            SpecItem(title: 'Engine', value: engine),
            SpecItem(title: 'Engine Oil', value: '10W30'),
            SpecItem(title: 'Transmission Oil', value: 'Toyota WS AT Fluid'),
            SpecItem(title: 'Oil Filter', value: '90915-10003'),
            SpecItem(title: 'Tyres', value: '185/65/15'),
            SpecItem(title: 'Brake Fluid', value: 'Dot 3'),
            SpecItem(title: 'Coolant Type', value: 'OAT'),
            SpecItem(title: 'Battery', value: '12V 45Ah'),
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
