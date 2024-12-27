import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PlaceHoldWidget extends StatefulWidget {
  final String bookTitle;
  final String bookAuthor;
  final int biblioId;

  const PlaceHoldWidget({
    Key? key,
    required this.bookTitle,
    required this.bookAuthor,
    required this.biblioId,
  }) : super(key: key);

  @override
  _PlaceHoldWidgetState createState() => _PlaceHoldWidgetState();
}

class _PlaceHoldWidgetState extends State<PlaceHoldWidget> {
  bool isChecked = false;
  bool showMoreOptions = false;
  List<Map<String, String>> libraryLocations = [];
  String? selectedLocationName;
  String? selectedLibraryId;
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    fetchLibraryLocations();
  }

  Future<String> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token') ?? '';
  }

  Future<int> _getPatronId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('patron_id') ?? 0;
  }

  Future<void> fetchLibraryLocations() async {
    try {
      final accessToken = await _getAccessToken();
      final patronId = await _getPatronId();
      final url = Uri.parse('https://demo.bestbookbuddies.com/api/v1/libraries');



      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body) as List;
        setState(() {
          libraryLocations = decodedResponse.map((library) {
            return {
              'name': library['name'] as String,
              'library_id': library['library_id'] as String,
            };
          }).toList();

          if (libraryLocations.isNotEmpty) {
            selectedLocationName = libraryLocations[0]['name'];
            selectedLibraryId = libraryLocations[0]['library_id'];
          }
        });
      } else {
        throw Exception('Failed to fetch library locations');
      }
    } catch (e) {
      print('Error fetching library locations: $e');
    }
  }


  Future<void> placeHold() async {
    if (!isChecked || selectedLibraryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a location and agree to place hold.')),
      );
      return;
    }

    try {
      final accessToken = await _getAccessToken();
      final patronId = await _getPatronId();
      final url = Uri.parse('https://demo.bestbookbuddies.com/api/v1/holds');
      final payload = {
        "biblio_id": widget.biblioId,
        "patron_id": patronId,
        "pickup_library_id": selectedLibraryId,
      };

      print('Sending payload: $payload');

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode(payload),
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hold placed successfully!')),
        );
        Navigator.pop(context);
      } else {
        throw Exception('Failed to place hold. Response: ${response.body}');
      }
    } catch (e) {
      print('Error placing hold: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error placing hold: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20),
          const Text(
            'Placing a hold',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: isChecked,
                onChanged: (bool? value) {
                  setState(() {
                    isChecked = value ?? false;
                  });
                },
                activeColor: const Color(0xFF009A90),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    const Text(
                      'Place hold on',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      ' ${widget.bookTitle}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'by ${widget.bookAuthor}',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Pick up location:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButton<String>(
                isExpanded: true,
                value: selectedLocationName,
                hint: const Text('Select a location'),
                underline: const SizedBox(),
                items: libraryLocations.map((location) {
                  return DropdownMenuItem<String>(
                    value: location['name'],
                    child: Text(location['name']!),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    selectedLocationName = value;
                    // Find the corresponding library_id
                    selectedLibraryId = libraryLocations
                        .firstWhere((location) => location['name'] == value)['library_id'];
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: placeHold,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF009A90),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                'Confirm Hold',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
