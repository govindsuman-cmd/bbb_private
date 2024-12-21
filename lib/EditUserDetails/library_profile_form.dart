import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class LibraryProfileForm extends StatefulWidget {
  final TabController? tabController;

  const LibraryProfileForm({super.key, this.tabController});

  @override
  _LibraryProfileFormState createState() => _LibraryProfileFormState();
}

class _LibraryProfileFormState extends State<LibraryProfileForm> {
  String _userName = '';
  String _cardNumber = "";
  String _expirationDate = '';
  String _categoryId = "";
  String _categoryDescription = "";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final int? patronId = prefs.getInt('patron_id');
      final String? accessToken = prefs.getString('access_token');

      if (patronId == null || accessToken == null) {
        throw Exception("Patron ID or Access Token not found in local storage.");
      }

      final response = await http.get(
        Uri.parse('https://demo.bestbookbuddies.com/api/v1/patrons/$patronId'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode != 200) {
        throw Exception("Failed to fetch user profile data.");
      }

      final data = json.decode(response.body);
      final String firstName = data['firstname'] ?? '';
      final String middleName = data['middle_name'] ?? '';
      final String surname = data['surname'] ?? '';
      final String expiryDate = data['expiry_date'] ?? '';
      final String cardNumber = data['cardnumber'] ?? '';
      final String categoryId = data['category_id'] ?? '';

      setState(() {
        _userName = '$firstName $middleName $surname';
        _cardNumber = cardNumber;
        _expirationDate = expiryDate;
        _categoryId = categoryId;
      });

      await _fetchCategoryDescription(categoryId, accessToken!);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  Future<void> _fetchCategoryDescription(String categoryId, String accessToken) async {
    try {
      final response = await http.get(
        Uri.parse('https://demo.bestbookbuddies.com/api/v1/authorised_value_categories/app_patcat/authorised_values'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode != 200) {
        throw Exception("Failed to fetch category descriptions.");
      }

      final List<dynamic> categories = json.decode(response.body);
      final matchingCategory = categories.firstWhere(
            (category) => category['value'] == categoryId,
        orElse: () => null,
      );

      setState(() {
        _categoryDescription = matchingCategory?['description'] ?? "Unknown Category";
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 500,
            padding: const EdgeInsets.all(26.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 8,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextField(
                  controller: TextEditingController(text: _cardNumber),
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Library Card Number',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: TextEditingController(text: _userName),
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'User Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: TextEditingController(text: _expirationDate),
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Expiration Date',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: TextEditingController(text: 'Central Library'),
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Home Library',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: TextEditingController(text: _categoryDescription),
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 35),
                Center(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (widget.tabController != null &&
                            widget.tabController!.index < 3) {
                          widget.tabController!.animateTo(widget.tabController!.index + 1);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF009A90),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: const Text(
                        'Next',
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
