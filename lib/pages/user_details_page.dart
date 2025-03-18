import 'package:flutter/material.dart';
import 'package:drivewise/services/api_service.dart';

class UserDetailsPage extends StatefulWidget {
  const UserDetailsPage({super.key});

  @override
  _UserDetailsPageState createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _vehicleController = TextEditingController();

  String? _selectedVehicleType;
  final List<String> _vehicleTypes = ['Car', 'Truck', 'Motorcycle', 'SUV', 'Van'];

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
  }

  Future<void> _loadUserEmail() async {
    String? email = await ApiService.getUserEmail();
    if (email != null) {
      setState(() {
        _emailController.text = email;
      });
    }
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _submitDetails() {
    if (_formKey.currentState!.validate()) {
      Map<String, String> userDetails = {
        "name": _nameController.text,
        "email": _emailController.text,
        "phone": _phoneController.text,
        "location": _locationController.text,
        "vehicle": _vehicleController.text,
        "vehicleType": _selectedVehicleType ?? ""
      };

      print(userDetails);
      _toggleEdit();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Details saved successfully!')),
      );
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.orange),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
      filled: true,
      fillColor: Colors.grey[200],
    );
  }

  Widget _buildProfileHeader() {
    return Row(
      children: [
        const CircleAvatar(
          radius: 35,
          backgroundImage: AssetImage("assets/images/profile_placeholder.png"),
          backgroundColor: Colors.grey,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_nameController.text.isNotEmpty ? _nameController.text : "Charlotte King",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(_emailController.text.isNotEmpty ? _emailController.text : "@johnkinggraphics",
                  style: const TextStyle(fontSize: 14, color: Colors.grey)),
            ],
          ),
        ),
        ElevatedButton(
          onPressed: _isEditing ? _submitDetails : _toggleEdit,
          style: ElevatedButton.styleFrom(
            backgroundColor: _isEditing ? Colors.green : Colors.redAccent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          ),
          child: Text(_isEditing ? 'Save Changes' : 'Edit Profile',
              style: const TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileHeader(),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration('Name', Icons.person),
                validator: (value) => value!.isEmpty ? 'Enter your name' : null,
                enabled: _isEditing,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _emailController,
                decoration: _inputDecoration('Email', Icons.email),
                readOnly: true,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _phoneController,
                decoration: _inputDecoration('Phone Number', Icons.phone),
                keyboardType: TextInputType.phone,
                validator: (value) => value!.isEmpty || value.length != 10 ? 'Enter valid phone number' : null,
                enabled: _isEditing,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _locationController,
                decoration: _inputDecoration('Location', Icons.location_on),
                validator: (value) => value!.isEmpty ? 'Enter your location' : null,
                enabled: _isEditing,
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                value: _selectedVehicleType,
                decoration: _inputDecoration('Vehicle Type', Icons.directions_car),
                items: _vehicleTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                onChanged: _isEditing ? (value) => setState(() => _selectedVehicleType = value) : null,
                validator: (value) => value == null ? 'Select vehicle type' : null,
                disabledHint: Text(_selectedVehicleType ?? 'Select vehicle type'),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _vehicleController,
                decoration: _inputDecoration('Vehicle Details (e.g., VIN)', Icons.confirmation_number),
                validator: (value) => value!.isEmpty ? 'Enter vehicle details' : null,
                enabled: _isEditing,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _vehicleController.dispose();
    super.dispose();
  }
}