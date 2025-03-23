//product_rec_service
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:drivewise/pages/product_reco.dart';

class ProductRecService {
  static Future<List<dynamic>> getProducts(String category) async {
    try {
      print('Fetching products for category: $category');
      final response = await http.get(
          Uri.parse('http://192.168.207.56:5000/api/products')
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Ensure category exists in response
        if (data.containsKey(category) && data[category] is List) {
          return data[category]; // Correctly return the list
        } else {
          print('Category "$category" not found in response');
          return [];
        }
      } else {
        print('Failed with status: ${response.statusCode}, body: ${response.body}');
        throw Exception('Failed to load products');
      }
    } catch (e) {
      print('Error fetching products: $e');
      return [];
    }
  }
}










