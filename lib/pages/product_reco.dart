import 'package:flutter/material.dart';
import '../services/product_rec_service.dart';
import '../widgets/search_and_filter.dart';
import 'package:http/http.dart' as http;


class ProductRec extends StatefulWidget {
  const ProductRec({Key? key}) : super(key: key);

  @override
  _ProductRecState createState() => _ProductRecState();
}

class _ProductRecState extends State<ProductRec> {
  String selectedCategory = 'engine_oil';
  List<dynamic> products = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    setState(() => isLoading = true);
    try {
      List<dynamic> allProducts = await ProductRecService.getProducts(selectedCategory);
      print('Fetched products: $allProducts');

      if (mounted) {
        setState(() {
          products = allProducts;
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

  Widget productGrid() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (products.isEmpty) {
      return const Center(child: Text("No products found"));
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 0.6,
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SearchAndFilterBar(onFilterSelected: updateCategory),
            const SectionTitle(title: 'Products'),
            productGrid(),
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
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(9.0),
              child: Image.network(
                product['imageUrl'] ?? '',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported, size: 50, color: Colors.white),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFFE95B15),
              borderRadius: BorderRadius.vertical(top: Radius.circular(15), bottom: Radius.circular(15)),
            ),
            alignment: Alignment.centerLeft,
            child: Text(
              product['name'] ?? 'No Name',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
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
