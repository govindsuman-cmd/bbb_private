import 'package:bbb_mobile_app/CustomWidget/background_widget.dart';
import 'package:flutter/material.dart';

class ProductDetailScreen extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    // Access the product ID
    final productId = product['id'];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          product['title'] ?? 'Product Details',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF009A90),
        elevation: 2,
      ),
      body: BackgroundWidget( // Wrap the body with BackgroundWidget
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Images Section
                if (product['images'] != null && product['images'].isNotEmpty)
                  Container(
                    height: 300,
                    margin: const EdgeInsets.only(bottom: 16.0),
                    child: PageView.builder(
                      itemCount: product['images'].length,
                      itemBuilder: (context, index) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(12.0),
                          child: Image.network(
                            product['images'][index],
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 16),
                // Product Title
                Text(
                  product['title'],
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                // Display Product ID
                Text(
                  'Product ID: $productId', // Display the product ID
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                // Price and Category Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Price: \$${product['price'] ?? 'N/A'}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    if (product['category'] != null)
                      Chip(
                        backgroundColor: const Color(0xFFE0F7FA),
                        label: Text(
                          product['category']['name'],
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF009A90),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                // Divider for Separation
                const Divider(color: Colors.grey),
                const SizedBox(height: 16),
                // Description Section
                const Text(
                  'Product Description',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  product['description'] ?? 'No Description Available',
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 16),
                // Divider for Separation
                const Divider(color: Colors.grey),
                // Buy Now Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14.0),
                      backgroundColor: const Color(0xFF009A90),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onPressed: () {
                      // Add Buy Now action
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Buy Now functionality coming soon!")),
                      );
                    },
                    child: const Text(
                      'Buy Now',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}