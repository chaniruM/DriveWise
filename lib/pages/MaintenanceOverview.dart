import 'package:flutter/material.dart';
import '../models/vehicle.dart';

class MaintenanceOverview extends StatefulWidget {
  final Vehicle vehicle;

  const MaintenanceOverview({super.key, required this.vehicle});

  @override
  _MaintenanceOverviewState createState() => _MaintenanceOverviewState();
}

class _MaintenanceOverviewState extends State<MaintenanceOverview> {
  DateTime? selectedDate;
  final TextEditingController odometerController = TextEditingController();
  final Map<String, bool> replacements = {
    'Engine Oil': false,
    'Transmission Oil': false,
    'Oil Filter': false,
    'Brake Fluid': false,
    'Coolant': false,
  };

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
        title: Text('${widget.vehicle.nickname} Maintenance Overview'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: () {},
              child: const Text('Service Details'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Date: '),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context),
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        selectedDate == null
                            ? 'Select Date'
                            : '${selectedDate!.toLocal()}'.split(' ')[0],
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Odometer: '),
                Expanded(
                  child: TextField(
                    controller: odometerController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter mileage',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.camera_alt),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(onPressed: () {}, child: const Text('Use OBD-II')),
                ElevatedButton(onPressed: () {}, child: const Text('Open Camera')),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Replacements',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ...replacements.keys.map((key) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: replacements[key],
                        onChanged: (bool? value) {
                          setState(() {
                            replacements[key] = value ?? false;
                          });
                        },
                      ),
                      Text(key),
                    ],
                  ),
                  DropdownButton<String>(
                    hint: const Text('Select product used'),
                    items: ['Brand A', 'Brand B', 'Brand C']
                        .map((String value) => DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    ))
                        .toList(),
                    onChanged: (String? newValue) {},
                  ),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}