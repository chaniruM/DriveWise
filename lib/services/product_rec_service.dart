//product_rec_service
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:drivewise/pages/product_reco.dart';

class ProductRecService {
  static Future<List<dynamic>> getProducts(String category) async {
    try {
      print('hello');
      final response = await http.get(
          Uri.parse(
              'http://192.168.207.56:5001/api/products?category=$category')
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Failed with status: ${response.statusCode}, body: ${response
            .body}');
        throw Exception('Failed to load products');
      }
    } catch (e) {
      print('Error fetching products: $e');
      return [];
    }
  }
}

