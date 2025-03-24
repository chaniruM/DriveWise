import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/product_rec_service.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProductRec extends StatefulWidget {
  const ProductRec({Key? key}) : super(key: key);

  @override
  _ProductRecState createState() => _ProductRecState();
}

class _ProductRecState extends State<ProductRec> {
  String selectedCategory = 'engine_oil';
  List<dynamic> products = [];
  bool isLoading = false;

  String selectedBrand = 'All';
  double minPrice = 0;
  double maxPrice = 10000;

  Map<String, List<dynamic>> categorizedProducts = {
    'engine_oil': [],
    'transmission_oil': [],
    'brake_oil': [],
    'Coolants': [],
    'oil_filter': [],
  };

  // List<String> brands = ['All', 'Brand A', 'Brand B', 'Brand C'];



  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    setState(() => isLoading = true);
    try {
      List<String> categories = ['engine_oil', 'transmission_oil', 'brake_oil', 'Coolants', 'oil_filter'];
      Map<String, List<dynamic>> fetchedProducts = {};

      for (String category in categories) {
        fetchedProducts[category] = await ProductRecService.getProducts(category);
      }

      if (mounted) {
        setState(() {
          categorizedProducts = fetchedProducts;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching products: $e');
      if (mounted) {
        setState(() => isLoading = false);
      }
    }

  }




  void updateCategory(String category) {
    setState(() {
      selectedCategory = category;
    });
    fetchProducts();
    Navigator.pop(context);
  }

  Widget productGrid(List<dynamic> products) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (products.isEmpty) {
      return const Center(child: Text("No products found"));
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 0.65,
      ),

      itemCount: products.length,
      itemBuilder: (context, index) {
        var product = products[index];
        return ProductCard(product: product);
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle(title: 'Engine Oils'),
            productGrid(categorizedProducts['engine_oil'] ?? []),

            const SectionTitle(title: 'Transmission Oils'),
            productGrid(categorizedProducts['transmission_oil'] ?? []),

            const SectionTitle(title: 'Brake Oils'),
            productGrid(categorizedProducts['brake_oil'] ?? []),

            const SectionTitle(title: 'Coolants'),
            productGrid(categorizedProducts['Coolants'] ?? []),

            const SectionTitle(title: 'Oil Filters'),
            productGrid(categorizedProducts['oil_filter'] ?? []),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final dynamic product;
  const ProductCard({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String productName = product['name'] ?? 'No Name';
    String brand = product['brand'] ?? 'Unknown Brand';
    String volume = product['volume'] != null ? "${product['volume']}" : 'N/A';
    String price = product['price'] != null ? "LKR ${product['price']}" : 'Price not available';

    return Container(
      padding: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF000000), Color(0xFF9F4A19), Color(0xFFE95B15)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(7.0),
              child: Image.network(
                product['imageUrl'] ?? '',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.image_not_supported, size: 50, color: Colors.white),
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(0xFFE95B15),
              borderRadius: BorderRadius.vertical(top: Radius.circular(15), bottom: Radius.circular(15)),
            ),

            alignment: Alignment.centerLeft,
            child: Column(
              children: [
                Text(
                  "$brand $productName",
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  "Volume: $volume",
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
                Text(
                  price,
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


// Define CustomAppBar inside the same file
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text("Products"),
      backgroundColor: Color(0xFFE95B15),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// Define SectionTitle inside the same file
class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}