import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ContactInfoForm extends StatefulWidget {
  final TabController? tabController;

  const ContactInfoForm({super.key, this.tabController});

  @override
  _ContactInfoFormState createState() => _ContactInfoFormState();
}

class _ContactInfoFormState extends State<ContactInfoForm> {
  bool _isEditing = false;
  bool _isLoading = true;
  Map<String, dynamic> _contactData = {};

  @override
  void initState() {
    super.initState();
    _fetchContactData();
  }

  // Fetch contact data from the API
  Future<void> _fetchContactData() async {
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
          _contactData = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch contact data');
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog("Error fetching contact data: $error");
    }
  }

  Future<void> _updateContactInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final int? patronId = prefs.getInt('patron_id');
      final String? accessToken = prefs.getString('access_token');
      if (patronId == null) {
        throw Exception("patronId not found in local storage");
      }

      final url = Uri.parse('https://demo.bestbookbuddies.com/api/v1/patrons/$patronId');
      final payload = {
        "phone": _contactData['phone'],
        "secondary_phone": _contactData['secondary_phone'],
        "email": _contactData['primary_email'],
        "secondary_email": _contactData['secondary_email'],
        "category_id": _contactData['category_id'],
        "library_id": _contactData['library_id'],
        "surname": _contactData['surname']
      };

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken'
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        _showSuccessDialog("Contact information updated successfully");
      } else {
        throw Exception('Failed to update contact information');
      }
    } catch (error) {
      _showErrorDialog("Error updating contact information: $error");
    }
  }

  // Show error dialog
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

  // Handle Submit action
  void _handleSubmit() {
    if (_isEditing) {
      _updateContactInfo();
    }
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
      child: Column(
        children: [
          Container(
            height: 490,
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
            child: Column(
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
                  controller: TextEditingController(text: _contactData['phone']),
                  decoration: const InputDecoration(
                    labelText: 'Primary Phone',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => _contactData['phone'] = value,
                ),
                const SizedBox(height: 16),
                TextField(
                  enabled: _isEditing,
                  controller: TextEditingController(text: _contactData['secondary_phone']),
                  decoration: const InputDecoration(
                    labelText: 'Secondary Phone',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => _contactData['secondary_phone'] = value,
                ),
                const SizedBox(height: 16),
                TextField(
                  enabled: _isEditing,
                  controller: TextEditingController(text: _contactData['primary_email']),
                  decoration: const InputDecoration(
                    labelText: 'Primary Email Id',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => _contactData['primary_email'] = value,
                ),
                const SizedBox(height: 16),
                TextField(
                  enabled: _isEditing,
                  controller: TextEditingController(text: _contactData['secondary_email']),
                  decoration: const InputDecoration(
                    labelText: 'Secondary Email Id',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => _contactData['secondary_email'] = value,
                ),
                const SizedBox(height: 35),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!_isEditing && widget.tabController?.index != 0)
                      SizedBox(
                        width: 150,
                        child: ElevatedButton(
                          onPressed: () {
                            if (widget.tabController != null &&
                                widget.tabController!.index > 0) {
                              widget.tabController!.animateTo(
                                  widget.tabController!.index - 1);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF009A90),
                            side: const BorderSide(color: Color(0xFF009A90)),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          child: const Text(
                            'Previous',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(width: 20),
                    if (_isEditing)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Cancel button
                          SizedBox(
                            width: 150,
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _isEditing = false; // Exit editing mode
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
                          // Submit button
                          SizedBox(
                            width: 150,
                            child: ElevatedButton(
                              onPressed: _handleSubmit,
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
