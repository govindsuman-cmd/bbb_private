import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BookItemDetails extends StatefulWidget {
  final int biblioId;

  const BookItemDetails({Key? key, required this.biblioId}) : super(key: key);

  @override
  _BookItemDetailsState createState() => _BookItemDetailsState();
}

class _BookItemDetailsState extends State<BookItemDetails> {
  bool isLoading = true;
  List<dynamic> itemDetails = [];
  List<bool> dropdownStates = []; // Track the state of each dropdown

  static const String baseUrl = "https://demo.bestbookbuddies.com/api/v1/biblios/";

  Future<String> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token') ?? '';
  }

  Future<void> fetchItemDetails() async {
    try {
      setState(() {
        isLoading = true;
      });

      final accessToken = await _getAccessToken();
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $accessToken',
      };

      final url = Uri.parse('$baseUrl${widget.biblioId}/items');
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final decodedResponse = utf8.decode(response.bodyBytes);
        setState(() {
          itemDetails = json.decode(decodedResponse);
          dropdownStates = List.filled(itemDetails.length, false); // Initialize dropdown states
        });
      } else {
        throw Exception('Failed to load item details');
      }
    } catch (e) {
      print('Error fetching item details: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchItemDetails();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: itemDetails.isNotEmpty
            ? List.generate(itemDetails.length, (index) {
          final item = itemDetails[index];
          final externalId = item['external_id'];
          final availability = item['damaged_status'] == 0 ? 'Available' : 'Unavailable';

          return Column(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    dropdownStates[index] = !dropdownStates[index];
                  });
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Item $externalId - $availability",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      Icon(
                        dropdownStates[index] ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              ),
              // Show table only if the dropdown is open
              if (dropdownStates[index])
                Column(
                  children: [
                    Container(
                      color: Colors.white, // Table background color
                      child: Column(
                        children: [
                          // Table heading with custom background color
                          Container(
                            color: Color(0xFF009A90), // Heading background color
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text(
                                  "Item Type",
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "Branch",
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "Call Number",
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          // Item details row
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(item['item_type_id'] ?? 'N/A'),
                                Text(item['home_library_id'] ?? 'N/A'),
                                Text(item['callnumber'] ?? 'N/A'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          );
        })
            : [
          const Center(
            child: Text("No items available."),
          ),
        ],
      ),
    );
  }
}
