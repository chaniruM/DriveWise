import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:drivewise/pages/login_screen.dart';

class TokenService {
  static Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("auth_token");
  }

  static Future<void> saveToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("auth_token", token);
  }

  static Future<void> clearToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("auth_token");
    await prefs.remove("user_email");
  }

  static Future<void> logout(BuildContext context) async {
    await clearToken(); // Remove token and user email
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (route) => false, // Remove all previous routes
    );
  }

  static Future<bool> isTokenExpired() async {
    String? token = await getToken();
    if (token == null) return true;

    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;

      final payload =
          json.decode(utf8.decode(base64.decode(base64.normalize(parts[1]))));
      final expiry = payload["exp"] * 1000;
      final now = DateTime.now().millisecondsSinceEpoch;

      if (now > expiry) {
        return true; // Token expired
      }

      // Refresh token if it's about to expire in 5 minutes
      if ((expiry - now) < 5 * 60 * 1000) {
        await refreshAuthToken();
      }

      return false;
    } catch (e) {
      return true;
    }
  }

  static Future<void> refreshAuthToken() async {
    String? token = await getToken();
    if (token == null) return;

    final response = await http.post(
      Uri.parse("http://192.168.154.131:5000/api/auth/refresh"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      final newToken = jsonDecode(response.body)["token"];
      await saveToken(newToken);
    } else {
      await clearToken();
    }
  }
}
