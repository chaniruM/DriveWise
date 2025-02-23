import 'package:flutter/material.dart';

class RegisterVehiclePage extends StatefulWidget {
  @override
  _RegisterVehicleScreenState createState() => _RegisterVehicleScreenState();
}

class _RegisterVehicleScreenState extends State<RegisterVehiclePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _regNumberController = TextEditingController();
  final TextEditingController _makeController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _mileageController = TextEditingController();

  DateTime _licenseDateExpiry = DateTime.now().add(Duration(days: 365));
  DateTime _insuranceDateExpiry = DateTime.now().add(Duration(days: 365));

  @override
  void dispose() {
    _nicknameController.dispose();
    _regNumberController.dispose();
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _mileageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register New Vehicle',),
        foregroundColor: Colors.white, // Sets both title and icon color
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Vehicle Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),

              TextFormField(
                controller: _nicknameController,
                decoration: InputDecoration(
                  labelText: 'Nickname',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a nickname';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12),

              TextFormField(
                controller: _regNumberController,
                decoration: InputDecoration(
                  labelText: 'Registration Number',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter registration number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12),

              TextFormField(
                controller: _makeController,
                decoration: InputDecoration(
                  labelText: 'Make',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter vehicle make';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12),

              TextFormField(
                controller: _modelController,
                decoration: InputDecoration(
                  labelText: 'Model',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter vehicle model';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12),

              TextFormField(
                controller: _yearController,
                decoration: InputDecoration(
                  labelText: 'Year',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter vehicle year';
                  }
                  try {
                    int year = int.parse(value);
                    if (year < 1900 || year > DateTime.now().year + 1) {
                      return 'Please enter a valid year';
                    }
                  } catch (e) {
                    return 'Please enter a valid year';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12),

              TextFormField(
                controller: _mileageController,
                decoration: InputDecoration(
                  labelText: 'Current Mileage (km)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter current mileage';
                  }
                  try {
                    int mileage = int.parse(value);
                    if (mileage < 0) {
                      return 'Mileage cannot be negative';
                    }
                  } catch (e) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),

              Text(
                'Important Dates',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),

              _buildDatePicker(
                label: 'License Expiry Date',
                selectedDate: _licenseDateExpiry,
                onDateChanged: (date) {
                  setState(() {
                    _licenseDateExpiry = date;
                  });
                },
              ),
              SizedBox(height: 12),

              _buildDatePicker(
                label: 'Insurance Expiry Date',
                selectedDate: _insuranceDateExpiry,
                onDateChanged: (date) {
                  setState(() {
                    _insuranceDateExpiry = date;
                  });
                },
              ),
              SizedBox(height: 24),

              Text(
                'Vehicle Specifications',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),

              _buildSpecificationField('Engine Oil'),
              SizedBox(height: 12),
              _buildSpecificationField('Transmission Oil'),
              SizedBox(height: 12),
              _buildSpecificationField('Oil Filter'),
              SizedBox(height: 12),
              _buildSpecificationField('Fuel Filter'),
              SizedBox(height: 12),
              _buildSpecificationField('Coolant'),
              SizedBox(height: 24),

              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Here, you would implement saving the vehicle data
                    // For now, just show a success message and navigate back
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Vehicle registered successfully!')),
                    );
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text('Register Vehicle'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime selectedDate,
    required Function(DateTime) onDateChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[700],
            ),
          ),
          TextButton(
            onPressed: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(Duration(days: 365 * 5)),
              );
              if (picked != null && picked != selectedDate) {
                onDateChanged(picked);
              }
            },
            child: Text(
              '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecificationField(String label) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
    );
  }
}