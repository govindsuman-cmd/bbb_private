import 'dart:convert';
import 'package:bbb_mobile_app/CustomWidget/background_widget.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'all_products_screen.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  List<dynamic> categories = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      final response =
      await http.get(Uri.parse('https://api.escuelajs.co/api/v1/categories'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          setState(() {
            categories = data;
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = "Unexpected response format.";
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = "Failed to load categories (HTTP ${response.statusCode}).";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "An error occurred while fetching categories: $e";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        backgroundColor: const Color(0xFF009A90),
      ),
      body: BackgroundWidget(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage != null
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: fetchCategories,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF009A90),
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        )
            : ListView.builder(
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return ListTile(
              leading: category['image'] != null
                  ? Image.network(
                category['image'],
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              )
                  : const Icon(Icons.category),
              title: Text(category['name'] ?? 'Unnamed Category'),

            );
          },
        ),
      ),
    );
  }
}