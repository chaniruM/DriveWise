import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:drivewise/services/token_service.dart';
import 'package:drivewise/widgets/sessionExpiredScreen.dart';
import 'package:http_parser/http_parser.dart';

class ApiService {
  // Update baseUrl to include only the domain and port, not the /api/auth part
  static const String baseUrl = "http://172.20.10.3:5001";

  // This makes it easier to create URLs for different API endpoints
  static String _apiUrl(String endpoint) => "$baseUrl$endpoint";
  // Helper method to get full image URL
  static String getImageUrl(String path) {
    // If the path already contains the full URL, return it as is
    if (path.startsWith('http')) {
      return path;
    }
    // Otherwise, construct the full URL
    return "$baseUrl/$path";
  }
  // **Save email to SharedPreferences**
  static Future<void> saveUserEmail(String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_email', email);
  }

  static Future<String?> getUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_email');
  }

  static Future<void> saveUserId(String userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', userId);
  }

  static Future<String?> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  static Future<void> clearUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
  }

  static Future<Map<String, dynamic>> register(String username, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(_apiUrl("/api/auth/register")),
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

  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(_apiUrl("/api/auth/login")),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData.containsKey("token")) {
          await TokenService.saveToken(responseData["token"]);
          await saveUserEmail(email);
          if (responseData.containsKey("user") && responseData["user"].containsKey("id")) {
            await saveUserId(responseData["user"]["id"]);
          }
        }
        return responseData;
      } else {
        return {"error": true, "message": jsonDecode(response.body)["message"] ?? "Failed to log in"};
      }
    } catch (e) {
      return {"error": true, "message": e.toString()};
    }
  }

  // Generic GET request handler with token check and error handling
  static Future<http.Response> getRequest(String endpoint, BuildContext context) async {
    String? token = await TokenService.getToken();

    if (token == null) {
      _handleUnauthorized(context);
      throw Exception("No authentication token found");
    }

    final response = await http.get(
      Uri.parse(_apiUrl("/api/$endpoint")),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 401) {
      _handleUnauthorized(context);
      throw Exception("Unauthorized");
    }

    return response;
  }

  // Generic POST request handler with token check and error handling
  static Future<http.Response> postRequest(
      String endpoint,
      Map<String, dynamic> data,
      BuildContext context
      ) async {
    String? token = await TokenService.getToken();

    if (token == null) {
      _handleUnauthorized(context);
      throw Exception("No authentication token found");
    }

    final response = await http.post(
      Uri.parse(_apiUrl("/api/$endpoint")),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 401) {
      _handleUnauthorized(context);
      throw Exception("Unauthorized");
    }

    return response;
  }

  // Upload profile image
  static Future<Map<String, dynamic>> uploadProfileImage(
      File imageFile,
      BuildContext context
      ) async {
    String? token = await TokenService.getToken();

    if (token == null) {
      _handleUnauthorized(context);
      throw Exception("No authentication token found");
    }

    try {
      // Create multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(_apiUrl("/api/user/upload-profile-image")),
      );

      // Add token authorization
      request.headers.addAll({
        "Authorization": "Bearer $token",
      });

      // Determine file extension
      String filename = imageFile.path.split('/').last;
      String extension = filename.split('.').last.toLowerCase();
      MediaType contentType;

      // Set the appropriate content type based on file extension
      switch (extension) {
        case 'jpg':
        case 'jpeg':
          contentType = MediaType('image', 'jpeg');
          break;
        case 'png':
          contentType = MediaType('image', 'png');
          break;
        default:
          contentType = MediaType('image', 'jpeg'); // Default to jpeg
      }

      // Create the file multipart
      var imageStream = http.ByteStream(imageFile.openRead());
      var length = await imageFile.length();

      var imageUpload = http.MultipartFile(
        'profileImage',
        imageStream,
        length,
        filename: filename,
        contentType: contentType,
      );

      // Add file to request
      request.files.add(imageUpload);

      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return {
          'success': true,
          ...jsonDecode(response.body),
        };
      } else if (response.statusCode == 401) {
        _handleUnauthorized(context);
        throw Exception("Unauthorized");
      } else {
        return {
          'success': false,
          'message': jsonDecode(response.body)['message'] ?? 'Failed to upload image',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Helper method to handle unauthorized access
  static void _handleUnauthorized(BuildContext context) {
    TokenService.clearToken();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SessionExpiredScreen()),
    );
  }
}
