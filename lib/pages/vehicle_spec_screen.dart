import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: VehicleSpecScreen(
      make: 'Toyota',
      model: 'Corolla',
      year: '2020',
      engine: '1.8L 4-Cylinder',
    ),
  ));
}

class VehicleSpecScreen extends StatelessWidget {
  final String make;
  final String model;
  final String year;
  final String engine;

  const VehicleSpecScreen({
    required this.make,
    required this.model,
    required this.year,
    required this.engine,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('$make $model $year')),
      body: SingleChildScrollView( // Allows scrolling for smaller screens
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Quick Lookup/Vehicle Specification',
              style: TextStyle(fontSize: 15, color: Colors.black),
            ),
            Center(
              child: Text(
                '$make $model $year',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Image.asset(
              'assets/images/car.png', // Ensure image is correctly placed
              height: 150,
            ),
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

  const SpecItem({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }
}
