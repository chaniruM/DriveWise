import 'package:flutter/material.dart';

class ProductRec extends StatefulWidget {
  const ProductRec({Key? key}) : super(key: key);

  @override
  _ProductRecState createState() => _ProductRecState();
}

class _ProductRecState extends State<ProductRec> {
  String selectedCategory = 'All';

  void updateCategory(String category) {
    setState(() {
      selectedCategory = category;
    });
    Navigator.pop(context);
  }

  // Reusable widget for product grid items
  Widget productGrid(List<String> imagePaths, List<String> productNames) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      crossAxisSpacing: 20,
      mainAxisSpacing: 20,
      childAspectRatio: 0.6,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: List.generate(imagePaths.length, (index) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF000000),
                Color(0xFF9F4A19),
                Color(0xFFE95B15),
              ],
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
                  child: Image.asset(imagePaths[index], fit: BoxFit.contain),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFE95B15),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(15),
                    bottom: Radius.circular(15),
                  ),
                ),
                alignment: Alignment.centerLeft,
                child: Text(
                  productNames[index],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // Reusable section for category with grid
  Widget categorySection(String category, String imagePath, List<String> imagePaths, List<String> productNames) {
    return Column(
      children: [
        CategorySection(title: category, imagePath: imagePath),
        const SectionTitle(title: 'Products'),
        productGrid(imagePaths, productNames),
        const SizedBox(height: 20),
      ],
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

            if (selectedCategory == 'All' || selectedCategory == 'Engine Oil') ...[
              categorySection('Engine Oil', 'assets/images/engine_oil.jpg.png', [
                'assets/images/toyota_motor_oil.png',
                'assets/images/another_image_1.png',
                'assets/images/another_image_2.png',
                'assets/images/another_image_3.png',
                'assets/images/another_image_4.png',
              ], [
                'Toyota Motor Oil 10W30',
                'Product 2',
                'Product 3',
                'Product 4',
                'Product 5',
              ]),
            ],

            if (selectedCategory == 'All' || selectedCategory == 'Transmission Oil') ...[
              categorySection('Transmission Oil', 'assets/images/transmission_oil.png', [
                'assets/images/Toyota_WS_AT_Fluid.png',
                'assets/images/another_image_1.png',
                'assets/images/another_image_2.png',
                'assets/images/another_image_3.png',
                'assets/images/another_image_4.png',
              ], [
                'Toyota WS AT Fluid',
                'Product 2',
                'Product 3',
                'Product 4',
                'Product 5',
              ]),
            ],

            if (selectedCategory == 'All' || selectedCategory == 'Oil Filters') ...[
              categorySection('Oil Filters', 'assets/images/oil_filters.jpg', [
                'assets/images/oil_filter_90915-10003.png',
                'assets/images/another_image_1.png',
                'assets/images/another_image_2.png',
                'assets/images/another_image_3.png',
                'assets/images/another_image_4.png',
              ], [
                '90915-10003',
                'Product 2',
                'Product 3',
                'Product 4',
                'Product 5',
              ]),
            ],

            if (selectedCategory == 'All' || selectedCategory == 'Tyres') ...[
              categorySection('Tyres', 'assets/images/tyres.jpg', [
                'assets/images/185/65/15.png',
                'assets/images/another_image_1.png',
                'assets/images/another_image_2.png',
                'assets/images/another_image_3.png',
                'assets/images/another_image_4.png',
              ], [
                '185/65/15',
                'Product 2',
                'Product 3',
                'Product 4',
                'Product 5',
              ]),
            ],

            if (selectedCategory == 'All' || selectedCategory == 'Break Fluid') ...[
              categorySection('Break Fluid', 'assets/images/break_fluid.png', [
                'assets/images/Dot_3.png',
                'assets/images/another_image_1.png',
                'assets/images/another_image_2.png',
                'assets/images/another_image_3.png',
                'assets/images/another_image_4.png',
              ], [
                'Dot 3',
                'Product 2',
                'Product 3',
                'Product 4',
                'Product 5',
              ]),
            ],
          ],
        ),
      ),
    );
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF030B23),
      title: const Text(
        'Recommendations',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 26,
          fontStyle: FontStyle.italic,
        ),
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class SearchAndFilterBar extends StatelessWidget {
  final Function(String) onFilterSelected;

  const SearchAndFilterBar({required this.onFilterSelected, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search...",
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[350],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(85),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 9),
          ElevatedButton.icon(
            onPressed: () => showFilterDialog(context, onFilterSelected),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrange,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
            ),
            icon: const Icon(Icons.filter_list, color: Colors.white),
            label: const Text("Filters", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

void showFilterDialog(BuildContext context, Function(String) onFilterSelected) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select Category', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ...['All', 'Engine Oil', 'Transmission Oil', 'Oil Filters', 'Tyres', 'Break Fluid'].map((category) => ListTile(
              title: Text(category),
              trailing: const Icon(Icons.arrow_forward_ios, size: 18),
              onTap: () => onFilterSelected(category),
            )),
          ],
        ),
      );
    },
  );
}

class CategorySection extends StatelessWidget {
  final String title;
  final String imagePath;
  const CategorySection({required this.title, required this.imagePath, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Opacity(
          opacity: 0.80,
          child: Image.asset(
            imagePath,
            width: double.infinity,
            height: 150,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.error, size: 100, color: Colors.red),
          ),
        ),
        Positioned.fill(
          child: Align(
            alignment: Alignment.center,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [Shadow(blurRadius: 2.0, color: Colors.black, offset: Offset(2, 2))],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle({required this.title, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      child: Align(
        alignment: Alignment.centerLeft, // Align to the left
        child: Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
    );
  }
}


class BrandGrid extends StatelessWidget {
  final List<String> images;
  const BrandGrid({required this.images, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: images.map((imagePath) => BrandCard(imagePath: imagePath)).toList(),
    );
  }
}

class BrandCard extends StatelessWidget {
  final String imagePath;

  const BrandCard({required this.imagePath, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.asset(
          imagePath,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) =>
          const Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
        ),
      ),
    );
  }
}