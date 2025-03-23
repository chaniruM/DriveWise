// vehicle_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class VehicleService {
  final String userId = '67dfe1b4b61717925db0a7e2';
  final String baseUrl = 'http://192.168.8.100:5001/api';

  // Fetch user's vehicles
  Future<Map<String, dynamic>> fetchUserVehicles() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/vehicles/$userId'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data;
      } else {
        throw Exception('Failed to load vehicles: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in fetchUserVehicles: $e');
      rethrow;
    }
  }

  // Extract vehicles from API response
  List<Map<String, dynamic>> extractVehicles(Map<String, dynamic> data) {
    final List<dynamic> vehicles = data['vehicles'];

    return vehicles.map((vehicle) => {
      'name': vehicle['nickname'] ?? '${vehicle['make']} ${vehicle['model']}', // Fallback if nickname is null
      'year': vehicle['year'] ?? 0,
      'mileage': (vehicle['currentMileage'] ?? 0).toDouble(),
      'id': vehicle['id'] ?? '',
      'vehicleRef': vehicle['vehicleRef'] ?? '',
      'next_service': (vehicle['nextService'] ?? 0).toDouble()
    }).toList();
  }

  // Extract upcoming events from API response
  List<Map<String, dynamic>> extractUpcomingEvents(Map<String, dynamic> data) {
    final List<dynamic> upcomingEvents = data['upcomingEvents'] ?? [];

    return upcomingEvents.map((event) => {
      'date': event['date'] != null ? DateTime.parse(event['date']) : null,
      'event': event['type'] ?? 'Unknown Event',
      'vehicle': event['vehicle'] ?? 'Unknown Vehicle',
      'mileageDifference': (event['mileageDifference'] ?? 0).toDouble(),
    }).toList();
  }

  // Update vehicle mileage
  Future<void> updateMileage({
    // required String userId,
    required String vehicleId,
    required double mileage,
  }) async {
    // Debug prints
    print("Updating mileage for vehicle ID: $vehicleId");
    print("New mileage: $mileage");

    final response = await http.put(
      Uri.parse('$baseUrl/updateMileage'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'userId': userId,
        'vehicleId': vehicleId,
        'mileage': mileage,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update mileage: ${response.body}');
    }
  }

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
    // required String userId,
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
      print('Vehicle registered successfully');
    } else {
      throw Exception('Failed to register vehicle');
    }
  }

  Future<void> removeVehicle({
    required String vehicleId,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/removeUserVehicle'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'userId': userId,
          'vehicleId': vehicleId,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to remove vehicle: ${response.body}');
      }
    } catch (e) {
      print('Error in removeVehicle: $e');
      rethrow;
    }
  }
  Future<void> saveMaintenanceRecord({
    required String vehicleId,
    required DateTime date,
    required double odometer,
    required String engineOil,
    required String transmissionOil,
    required String airFilter,
    required String brakeFluid,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/saveMaintenanceRecord'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'vehicleId': vehicleId,
        'date': date.toIso8601String(),
        'odometer': odometer,
        'engineOil': engineOil,
        'transmissionOil': transmissionOil,
        'airFilter': airFilter,
        'brakeFluid': brakeFluid,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to save maintenance record: ${response.body}');
    }
  }

  // Add this method to vehicle_service.dart
  Future<List<Map<String, dynamic>>> fetchEngineOils() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/engineOils'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('Failed to load engine oils: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in fetchEngineOils: $e');
      rethrow;
    }
  }
  // Add these methods to vehicle_service.dart
  Future<List<Map<String, dynamic>>> fetchTransmissionOils() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/transmissionOils'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('Failed to load transmission oils: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in fetchTransmissionOils: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchOilFilters() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/oilFilters'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('Failed to load oil filters: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in fetchOilFilters: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchBrakeFluids() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/brakeFluids'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('Failed to load brake fluids: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in fetchBrakeFluids: $e');
      rethrow;
    }
  }
  // Future<List<Map<String, dynamic>>> fetchMaintenanceHistory(String vehicleId) async {
  //   try {
  //     final response = await http.get(Uri.parse('$baseUrl/maintenanceHistory/$vehicleId'));
  //     if (response.statusCode == 200) {
  //       final List<dynamic> data = jsonDecode(response.body);
  //       return List<Map<String, dynamic>>.from(data);
  //     } else {
  //       throw Exception('Failed to load maintenance history: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('Error in fetchMaintenanceHistory: $e');
  //     rethrow;
  //   }
  // }

  Future<List<Map<String, dynamic>>> fetchMaintenanceHistory() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/maintenanceHistory')); // Removed vehicleId
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('Failed to load maintenance history: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in fetchMaintenanceHistory: $e');
      rethrow;
    }
  }
  // Future<List<Map<String, dynamic>>> fetchMaintenanceHistory(String vehicleId) async {
  //   try {
  //     final response = await http.get(Uri.parse('$baseUrl/maintenanceHistory/$vehicleId'));
  //     if (response.statusCode == 200) {
  //       final List<dynamic> data = jsonDecode(response.body);
  //       return List<Map<String, dynamic>>.from(data);
  //     } else {
  //       throw Exception('Failed to load maintenance history: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('Error in fetchMaintenanceHistory: $e');
  //     rethrow;
  //   }
  // }

}