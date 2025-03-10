import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Change to your actual backend IP address or domain name
  static const String baseUrl = "http://localhost:5000/api/auth"; // Corrected 'authh' to 'auth'

  // Login User
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      // Check if the response is successful
      if (response.statusCode == 200) {
        // Decode and return the response body
        return jsonDecode(response.body);
      } else {
        // Handle error response
        return {
          "error": true,
          "message": jsonDecode(response.body)["message"] ?? "Failed to log in",
        };
      }
    } catch (e) {
      // Handle any exceptions
      return {
        "error": true,
        "message": e.toString(),
      };
    }
  }

  // Register User
  static Future<Map<String, dynamic>> register(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"name": name, "email": email, "password": password}),
      );

      // Check if the response is successful
      if (response.statusCode == 200) {
        // Decode and return the response body
        return jsonDecode(response.body);
      } else {
        // Handle error response
        return {
          "error": true,
          "message": jsonDecode(response.body)["message"] ?? "Failed to register",
        };
      }
    } catch (e) {
      // Handle any exceptions
      return {
        "error": true,
        "message": e.toString(),
      };
    }
  }
}
