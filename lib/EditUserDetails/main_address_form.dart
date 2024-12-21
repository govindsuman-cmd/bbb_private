import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MainAddressForm extends StatefulWidget {
  final TabController? tabController;

  const MainAddressForm({super.key, this.tabController});

  @override
  State<MainAddressForm> createState() => _MainAddressFormState();
}

class _MainAddressFormState extends State<MainAddressForm> {
  bool _isEditing = false;
  bool _isLoading = true;
  Map<String, dynamic> _formData = {};

  @override
  void initState() {
    super.initState();
    _fetchAddressData();
  }

  // Fetch address data from the API
  Future<void> _fetchAddressData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final int? patronId = prefs.getInt('patron_id');
      final String? accessToken = prefs.getString('access_token');
      if (patronId == null) {
        throw Exception("patronId not found in local storage");
      }

      final response = await http.get(
        Uri.parse('https://demo.bestbookbuddies.com/api/v1/patrons/$patronId'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        setState(() {
          _formData = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch address data');
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog("Error fetching address data: $error");
    }
  }

  // Update address data
  Future<void> _updateAddressData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final int? patronId = prefs.getInt('patron_id');
      final String? accessToken = prefs.getString('access_token');
      if (patronId == null) {
        throw Exception("patronId not found in local storage");
      }

      // Prepare payload based on the data fetched
      Map<String, dynamic> payload = {
        "address": _formData['address'] ?? '',
        "altaddress_address": _formData['altaddress_address'] ?? '',
        "city": _formData['city'] ?? '',
        "state": _formData['state'] ?? '',
        "country": _formData['country'] ?? '',
        "postal_code": _formData['postal_code'] ?? '',
        "category_id": _formData['category_id'] ?? 'RS',  // Defaulting to 'RS' if not found
        "library_id": _formData['library_id'] ?? 'CL',  // Defaulting to 'CL' if not found
        "surname": _formData['surname'] ?? '',
      };

      final url = Uri.parse('https://demo.bestbookbuddies.com/api/v1/patrons/$patronId');
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken'
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        _showSuccessDialog("Address data updated successfully");
      } else {
        throw Exception('Failed to update address data');
      }
    } catch (error) {
      _showErrorDialog("Error updating address data: $error");
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Success'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() {
                _isEditing = false;
              });
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(26.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 8,
                    blurRadius: 5,
                    offset: const Offset(0, 3), // Shadow position
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(
                        Icons.edit_square,
                        color: Color(0xFF009A90),
                        size: 30,
                      ),
                      onPressed: () {
                        setState(() {
                          _isEditing = !_isEditing;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    enabled: _isEditing,
                    controller:
                    TextEditingController(text: _formData['address']),
                    decoration: const InputDecoration(
                      labelText: 'Address',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => _formData['address'] = value,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    enabled: _isEditing,
                    controller: TextEditingController(
                        text: _formData['altaddress_address']),
                    decoration: const InputDecoration(
                      labelText: 'Address 2',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) =>
                    _formData['altaddress_address'] = value,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          enabled: _isEditing,
                          controller:
                          TextEditingController(text: _formData['city']),
                          decoration: const InputDecoration(
                            labelText: 'City',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) => _formData['city'] = value,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          enabled: _isEditing,
                          controller:
                          TextEditingController(text: _formData['state']),
                          decoration: const InputDecoration(
                            labelText: 'State',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) => _formData['state'] = value,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Postal Code and Country in the same row
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          enabled: _isEditing,
                          controller: TextEditingController(
                              text: _formData['postal_code']),
                          decoration: const InputDecoration(
                            labelText: 'Postal Code',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) =>
                          _formData['postal_code'] = value,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          enabled: _isEditing,
                          controller: TextEditingController(
                              text: _formData['country']),
                          decoration: const InputDecoration(
                            labelText: 'Country',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) => _formData['country'] = value,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_isEditing)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 150,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _isEditing = false;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        SizedBox(
                          width: 150,
                          child: ElevatedButton(
                            onPressed: _updateAddressData,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF009A90),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            child: const Text(
                              'Submit',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
