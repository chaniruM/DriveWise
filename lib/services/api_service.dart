import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:flutter/material.dart';
import 'package:drivewise/services/token_service.dart';
import 'package:drivewise/pages/login_screen.dart';

class ApiService {

  // Change to your actual backend IP address or domain name
  //static const String baseUrl = "http://10.0.2.2:5001/api/auth";


  static const String baseUrl = "http://192.168.154.131:5000/api/auth";
  // static const String baseUrl = "http://192.168.1.16:5000/api/auth";// Update for production
  // **Save email to SharedPreferences**
  static Future<void> saveUserEmail(String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_email', email);
  }

  // **Get saved email**
  static Future<String?> getUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_email');
  }

  // **Register User**
  static Future<Map<String, dynamic>> register(String username, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": username, "email": email, "password": password}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {"error": true, "message": jsonDecode(response.body)["message"] ?? "Failed to register"};
      }
    } catch (e) {
      return {"error": true, "message": e.toString()};
    }
  }

  // **Login User**
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData.containsKey("token")) {
          await TokenService.saveToken(responseData["token"]); // Save token securely
          await saveUserEmail(email); // Save email
        }
        return responseData;
      } else {
        return {"error": true, "message": jsonDecode(response.body)["message"] ?? "Failed to log in"};
      }
    } catch (e) {
      return {"error": true, "message": e.toString()};
    }
  }

  // **General GET request**
  static Future<http.Response> getRequest(String endpoint, BuildContext context) async {
    String? token = await TokenService.getToken();
    final response = await http.get(
      Uri.parse("$baseUrl/$endpoint"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 401) {
      await TokenService.clearToken();
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LoginScreen()));
    }

    return response;
  }

  // **General POST request**
  static Future<http.Response> postRequest(String endpoint, Map<String, dynamic> data, BuildContext context) async {
    String? token = await TokenService.getToken();
    final response = await http.post(
      Uri.parse("$baseUrl/$endpoint"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 401) {
      await TokenService.clearToken();
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LoginScreen()));
    }

    return response;
  }
}
