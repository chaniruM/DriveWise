// vehicle_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class VehicleService {
  final String baseUrl = 'http://192.168.1.110:5001/api'; // Replace with your actual API URL

  Future<List<String>> fetchMakes() async {
    final response = await http.get(Uri.parse('$baseUrl/makes'));
    if (response.statusCode == 200) {
      return List<String>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to load makes');
    }
  }

  Future<List<String>> fetchModels(String make) async {
    final response = await http.get(Uri.parse('$baseUrl/models/$make'));
    if (response.statusCode == 200) {
      return List<String>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to load models');
    }
  }

  Future<List<String>> fetchEngines(String make, String model) async {
    final response = await http.get(Uri.parse('$baseUrl/engines/$make/$model'));
    if (response.statusCode == 200) {
      return List<String>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to load engines');
    }
  }

  Future<List<String>> fetchYears(String make, String model, String engine) async {
    final response = await http.get(Uri.parse('$baseUrl/years/$make/$model/$engine'));
    if (response.statusCode == 200) {
      // return List<String>.from(json.decode(response.body));
      List<dynamic> yearList = json.decode(response.body);
      List<String> stringYears = yearList.map((year) => year.toString()).toList();
      return stringYears;
    } else {
      throw Exception('Failed to load years');
    }
  }

  Future<List<String>> fetchBrands() async {
    final response = await http.get(Uri.parse('$baseUrl/brands'));
    if (response.statusCode == 200) {
      return List<String>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to load makes');
    }
  }

  Future<void> registerVehicle({
    required String userId,
    required String make,
    required String model,
    required String engineType,
    required String year,
    required String registrationNumber,
    required double odometerReading,
    required double nextServiceReading,
    required DateTime licenseExpiryDate,
    required DateTime insuranceExpiryDate,
    required DateTime emmissionsExpiryDate,
    required String preferredBrand,
    required String nickname,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/addVehicle'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'userId': userId,
        'make': make,
        'model': model,
        'engine_type': engineType,
        'year': year,
        'registration_number': registrationNumber,
        'odometer_reading': odometerReading,
        'next_service_reading': nextServiceReading,
        'license_expiry_date': licenseExpiryDate.toIso8601String(),
        'insurance_expiry_date': insuranceExpiryDate.toIso8601String(),
        'emmissions_expiry_date': emmissionsExpiryDate.toIso8601String(),
        'preferred_brand': preferredBrand,
        'nickname': nickname,
      }),
    );

    if (response.statusCode == 201) {
      // Vehicle registered successfully
      print('Vehicle registered successfully');
    } else {
      throw Exception('Failed to register vehicle');
    }
  }
}