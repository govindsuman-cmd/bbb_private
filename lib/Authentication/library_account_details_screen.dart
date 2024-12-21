import 'package:flutter/material.dart';
import 'package:bbb_mobile_app/CustomWidget/background_widget.dart';

class LibraryAccountDetailsScreen extends StatefulWidget {
  const LibraryAccountDetailsScreen({super.key});

  @override
  State<LibraryAccountDetailsScreen> createState() => _LibraryAccountDetailsScreenState();
}

class _LibraryAccountDetailsScreenState extends State<LibraryAccountDetailsScreen> {
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  String? selectedLibrary;
  String? selectedCategory;

  final List<String> libraries = ["Library A", "Library B", "Library C"];
  final List<String> categories = ["B-Tech", "B-Com", "MBA", "B-Sc"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: BackgroundWidget(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 80),
                  const Center(
                    child: Image(image: AssetImage('assets/bbb_logo.png')),
                  ),
                  const SizedBox(height: 20),

                  // Add the "Create Account" heading here
                  const Text(
                    'Library Account Details',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Card Number Field
                  TextField(
                    controller: cardNumberController,
                    decoration: InputDecoration(
                      labelText: 'Card Number',
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 18.0, horizontal: 16.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Email Field
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Your Email',
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 18.0, horizontal: 16.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Phone Number Field
                  TextField(
                    controller: phoneController,
                    decoration: InputDecoration(
                      labelText: 'Your Phone Number',
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 18.0, horizontal: 16.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Select Library Dropdown
                  DropdownButtonFormField<String>(
                    value: selectedLibrary,
                    items: libraries.map((String library) {
                      return DropdownMenuItem<String>(
                        value: library,
                        child: Text(library),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      labelText: 'Select Library',
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 18.0, horizontal: 16.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                    ),
                    onChanged: (String? newLibrary) {
                      setState(() {
                        selectedLibrary = newLibrary;
                      });
                    },
                  ),
                  const SizedBox(height: 20),

                  // Select Category Dropdown
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    items: categories.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      labelText: 'Select Category',
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 18.0, horizontal: 16.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                    ),
                    onChanged: (String? newCategory) {
                      setState(() {
                        selectedCategory = newCategory;
                      });
                    },
                  ),
                  const SizedBox(height: 40),

                  // Submit Button
                  ElevatedButton(
                    onPressed: () {
                      // Show a confirmation dialog
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            content: const Text(
                              'Are you sure you want to Renew?',
                              style: TextStyle(fontSize: 18),
                            ),
                            actionsAlignment: MainAxisAlignment.spaceEvenly, // Align buttons
                            actions: [
                              // "No" Button
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop(); // Close the dialog
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white, // White background
                                  foregroundColor: const Color(0xFF009A90),
                                  side: const BorderSide(color: Color(0xFF009A90)), // Green border
                                ),
                                child: const Text('No'),
                              ),
                              // "Yes" Button
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop(); // Close the dialog
                                  // Proceed with form submission
                                  print('Card Number: ${cardNumberController.text}');
                                  print('Email: ${emailController.text}');
                                  print('Phone: ${phoneController.text}');
                                  print('Library: $selectedLibrary');
                                  print('Category: $selectedCategory');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF009A90), // Green background
                                  foregroundColor: Colors.white, // White text
                                ),
                                child: const Text('Yes'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 19),
                      backgroundColor: const Color(0xFF009A90),
                      textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Submit'),
                  ),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}