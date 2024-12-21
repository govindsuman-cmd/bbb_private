import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PersonalDetailsForm extends StatefulWidget {
  final TabController? tabController;

  const PersonalDetailsForm({super.key, this.tabController});

  @override
  State<PersonalDetailsForm> createState() => _PersonalDetailsFormState();
}

class _PersonalDetailsFormState extends State<PersonalDetailsForm> {
  String _selectedGender = 'Male';
  bool _isEditing = false;
  bool _isLoading = true;
  Map<String, dynamic> _formData = {};
  DateTime? _selectedDOB; // To store the selected Date of Birth

  @override
  void initState() {
    super.initState();
    _fetchPatronData();
  }

  Future<void> _fetchPatronData() async {
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
          _selectedGender = _formData['gender'] == 'M'
              ? 'Male'
              : _formData['gender'] == 'F'
              ? 'Female'
              : 'Other';

          // Fetch date_of_birth from API response and parse it
          if (_formData['date_of_birth'] != null) {
            _selectedDOB = DateTime.parse(_formData['date_of_birth']);
          }

          _isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch data');
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog("Error fetching data: $error");
    }
  }

  Future<void> _updatePatronData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final int? patronId = prefs.getInt('patron_id');
      final String? accessToken = prefs.getString('access_token');
      if (patronId == null) {
        throw Exception("patronId not found in local storage");
      }

      // Update the payload with category_id and library_id from _formData
      final updatedData = {
        'firstname': _formData['firstname'],
        'middle_name': _formData['middle_name'],
        'surname': _formData['surname'],
        'gender': _formData['gender'],
        'date_of_birth': _formData['date_of_birth'],
        'category_id': _formData['category_id'], // Fetch from the API response
        'library_id': _formData['library_id'], // Fetch from the API response
      };

      final url = Uri.parse('https://demo.bestbookbuddies.com/api/v1/patrons/$patronId');
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken'
        },
        body: jsonEncode(updatedData),
      );

      if (response.statusCode == 200) {
        _showSuccessDialog("Data updated successfully");
      } else {
        throw Exception('Failed to update data');
      }
    } catch (error) {
      _showErrorDialog("Error updating data: $error");
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDOB ?? DateTime.now(), // Set to the fetched DOB or current date
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDOB) {
      setState(() {
        _selectedDOB = picked;
        _formData['date_of_birth'] = _selectedDOB!.toIso8601String(); // Update the date_of_birth
      });
    }
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
                    TextEditingController(text: _formData['firstname']),
                    decoration: const InputDecoration(
                      labelText: 'First Name',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => _formData['firstname'] = value,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    enabled: _isEditing,
                    controller:
                    TextEditingController(text: _formData['middle_name']),
                    decoration: const InputDecoration(
                      labelText: 'Middle Name',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => _formData['middle_name'] = value,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    enabled: _isEditing,
                    controller: TextEditingController(text: _formData['surname']),
                    decoration: const InputDecoration(
                      labelText: 'Surname',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => _formData['surname'] = value,
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: _isEditing ? () => _selectDate(context) : null,
                    child: AbsorbPointer(
                      child: TextField(
                        enabled: false,
                        controller: TextEditingController(
                            text: _formData['updated_on']),
                        decoration: const InputDecoration(
                          labelText: 'Select Date of Birth',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Gender',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Radio<String>(
                              value: 'Male',
                              groupValue: _selectedGender,
                              onChanged: _isEditing
                                  ? (value) {
                                setState(() {
                                  _selectedGender = value!;
                                  _formData['gender'] = 'M';
                                });
                              }
                                  : null,
                            ),
                            const Text('Male'),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            Radio<String>(
                              value: 'Female',
                              groupValue: _selectedGender,
                              onChanged: _isEditing
                                  ? (value) {
                                setState(() {
                                  _selectedGender = value!;
                                  _formData['gender'] = 'F';
                                });
                              }
                                  : null,
                            ),
                            const Text('Female'),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            Radio<String>(
                              value: 'Other',
                              groupValue: _selectedGender,
                              onChanged: _isEditing
                                  ? (value) {
                                setState(() {
                                  _selectedGender = value!;
                                  _formData['gender'] = 'O';
                                });
                              }
                                  : null,
                            ),
                            const Text('Other'),
                          ],
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
                            onPressed: _updatePatronData,
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
