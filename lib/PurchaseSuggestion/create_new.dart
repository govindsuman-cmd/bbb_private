import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class CreateNew extends StatefulWidget {
  const CreateNew({Key? key}) : super(key: key);

  @override
  _CreateNewState createState() => _CreateNewState();
}

class _CreateNewState extends State<CreateNew> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController authorController = TextEditingController();
  final TextEditingController isbnController = TextEditingController();
  final TextEditingController publisherCodeController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final TextEditingController copyrightDateController = TextEditingController();

  String? selectedItemType;
  String? selectedLibraryId;
  List<Map<String, dynamic>> libraries = [];
  List<String> itemTypes = [];
  String? accessToken;
  int? patronId;

  @override
  void initState() {
    super.initState();
    _loadSharedPreferences();
    _fetchItemTypes();
    _fetchLibraries();
  }

  _loadSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      accessToken = prefs.getString('access_token');
      patronId = prefs.getInt('patron_id');
    });
  }

  Future<void> _fetchItemTypes() async {
    if (accessToken == null) return;
    try {
      var response = await http.get(
        Uri.parse('https://demo.bestbookbuddies.com/api/v1/authorised_value_categories/app_itemtype/authorised_values'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          itemTypes = data.map((e) => e['description'] as String).toList();
        });
      } else {
        print('Failed to fetch item types: ${response.body}');
      }
    } catch (e) {
      print('Error fetching item types: $e');
    }
  }

  Future<void> _fetchLibraries() async {
    if (accessToken == null) return;
    try {
      var response = await http.get(
        Uri.parse('https://demo.bestbookbuddies.com/api/v1/libraries'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          libraries = data.map((e) => {"name": e["name"], "id": e["library_id"]}).toList();
        });
      } else {
        print('Failed to fetch libraries: ${response.body}');
      }
    } catch (e) {
      print('Error fetching libraries: $e');
    }
  }

  void clearFields() {
    titleController.clear();
    authorController.clear();
    isbnController.clear();
    publisherCodeController.clear();
    quantityController.clear();
    noteController.clear();
    copyrightDateController.clear();
    setState(() {
      selectedItemType = null;
      selectedLibraryId = null;
    });
  }

  Future<void> submitForm() async {
    if (accessToken == null || patronId == null) {
      _showSnackBar('Access token or patron ID not found.');
      return;
    }

    // Validate copyright_date (YYYY format)
    String copyrightDate = copyrightDateController.text;
    if (!RegExp(r'^\d{4}$').hasMatch(copyrightDate)) {
      _showSnackBar('Copyright Date must be in YYYY format.');
      return;
    }

    String suggestionDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    Map<String, dynamic> data = {
      "title": titleController.text,
      "author": authorController.text,
      "copyright_date": copyrightDate, // Include user input for copyright_date
      "isbn": int.tryParse(isbnController.text) ?? 0,
      "item_type": selectedItemType,
      "library_id": selectedLibraryId,
      "publisher_code": publisherCodeController.text,
      "quantity": int.tryParse(quantityController.text) ?? 1,
      "note": noteController.text,
      "suggested_by": patronId,
      "suggestion_date": suggestionDate,
    };

    try {
      var response = await http.post(
        Uri.parse('https://demo.bestbookbuddies.com/api/v1/suggestions'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        _showSnackBar('Suggestion submitted successfully!');
        clearFields();
      } else {
        _showSnackBar('Failed to submit suggestion.');
        print('Response: ${response.body}');
      }
    } catch (e) {
      _showSnackBar('Error submitting suggestion: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25.0),
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Create New Suggestion Here',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                _buildTextField(titleController, 'Title'),
                _buildTextField(authorController, 'Author'),
                _buildTextField(isbnController, 'ISBN', isNumeric: true),
                _buildTextField(copyrightDateController, 'Publication Year (YYYY)', isNumeric: true),
                _buildDropdown(
                  label: "Select Item Type",
                  value: selectedItemType,
                  onChanged: (value) {
                    setState(() {
                      selectedItemType = value;
                    });
                  },
                  items: itemTypes,
                ),
                _buildLibraryDropdown(),
                _buildTextField(publisherCodeController, 'Publisher Code'),
                _buildTextField(quantityController, 'Quantity', isNumeric: true),
                _buildNoteField(noteController),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: clearFields,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF009A90)),
                        backgroundColor: Colors.white,
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Color(0xFF009A90)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF009A90),
                      ),
                      child: Text(
                        'Submit',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLibraryDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: "Select Library",
          border: OutlineInputBorder(),
        ),
        value: selectedLibraryId,
        onChanged: (value) {
          setState(() {
            selectedLibraryId = value;
          });
        },
        items: libraries
            .map(
              (library) => DropdownMenuItem<String>(
            value: library["id"].toString(),
            child: Text(library["name"]),
          ),
        )
            .toList(),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool isNumeric = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      ),
    );
  }

  Widget _buildNoteField(TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: 'Note',
          border: OutlineInputBorder(),
        ),
        maxLines: 5,
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    String? value,
    required ValueChanged<String?> onChanged,
    required List<String> items,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        value: value,
        onChanged: onChanged,
        items: items
            .map((item) => DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        ))
            .toList(),
      ),
    );
  }
}
