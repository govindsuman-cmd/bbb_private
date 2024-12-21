import 'package:bbb_mobile_app/Authentication/library_account_details_screen.dart';
import 'package:bbb_mobile_app/CustomWidget/background_widget.dart';
import 'package:flutter/material.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  String? _gender = 'Male'; // Default gender selection

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // Prevent resizing of the screen when keyboard is shown
      body: SafeArea(
        child: BackgroundWidget( // Use BackgroundWidget here
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
                  const SizedBox(height: 20), // Add some spacing after the logo

                  // Add the "Create Account" heading here
                  const Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // First Name Field
                  TextField(
                    controller: firstNameController,
                    decoration: InputDecoration(
                      labelText: 'First Name',
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 18.0, horizontal: 16.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Last Name Field
                  TextField(
                    controller: lastNameController,
                    decoration: InputDecoration(
                      labelText: 'Last Name',
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 18.0, horizontal: 16.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Date of Birth Field
                  TextField(
                    controller: dobController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Date of Birth',
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 18.0, horizontal: 16.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                      suffixIcon: const Icon(Icons.calendar_today),
                    ),
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (pickedDate != null) {
                        dobController.text =
                        "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                      }
                    },
                  ),
                  const SizedBox(height: 20),

                  // Address Field
                  TextField(
                    controller: addressController,
                    decoration: InputDecoration(
                      labelText: 'Address',
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 18.0, horizontal: 16.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Gender Selection
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Gender',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          Radio<String>(
                            value: 'Male',
                            groupValue: _gender,
                            onChanged: (String? value) {
                              setState(() {
                                _gender = value;
                              });
                            },
                          ),
                          const Text('Male'),
                          const SizedBox(width: 20),
                          Radio<String>(
                            value: 'Female',
                            groupValue: _gender,
                            onChanged: (String? value) {
                              setState(() {
                                _gender = value;
                              });
                            },
                          ),
                          const Text('Female'),
                          const SizedBox(width: 20),
                          Radio<String>(
                            value: 'Others',
                            groupValue: _gender,
                            onChanged: (String? value) {
                              setState(() {
                                _gender = value;
                              });
                            },
                          ),
                          const Text('Others'),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LibraryAccountDetailsScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 19),
                      backgroundColor: const Color(0xFF009A90),
                      textStyle: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w800),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Create Account'),
                  ),

                  const SizedBox(height: 20),

                  // Already have an account? Login row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Already have an account? ',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // Navigate back to the login screen
                        },
                        child: const Text(
                          'Login',
                          style: TextStyle(fontSize: 16, color: Colors.blue),
                        ),
                      ),
                    ],
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