import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HoldContent extends StatefulWidget {
  final String? accessToken;
  final int? patronId;

  const HoldContent({Key? key, this.accessToken, this.patronId}) : super(key: key);

  @override
  _HoldContentState createState() => _HoldContentState();
}

class _HoldContentState extends State<HoldContent> {
  List<Map<String, dynamic>> holdCards = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHoldData();
  }

  Future<void> _fetchHoldData() async {
    if (widget.accessToken == null || widget.patronId == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer ${widget.accessToken}',
    };

    final response = await http.get(
      Uri.parse('https://demo.bestbookbuddies.com/api/v1/holds'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> holds = json.decode(response.body);

      for (var hold in holds) {
        final biblioId = hold['biblio_id'];
        final status = hold['status'] ?? 'Pending';

        if (biblioId != null) {
          await _fetchBibliosData(biblioId, hold, status);
        }
      }

      setState(() {
        isLoading = false;
      });
    } else {
      print('Failed to load hold data: ${response.statusCode}');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchBibliosData(int biblioId, Map<String, dynamic> hold,
      String status) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer ${widget.accessToken}',
    };

    final response = await http.get(
      Uri.parse('https://demo.bestbookbuddies.com/api/v1/biblios/$biblioId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final biblioData = json.decode(utf8.decode(response.bodyBytes));
      final title = biblioData['title'] ?? 'Unknown Title';
      final author = biblioData['author'] ?? 'Unknown Author';
      final isbn = biblioData['isbn'] ?? '';

      String imageUrl = 'https://pick2read.com/assets/images/not_found.png';
      if (isbn.isNotEmpty) {
        imageUrl = await _fetchBookImage(isbn);
      }

      setState(() {
        holdCards.add({
          "hold_id": hold["hold_id"],
          'title': title,
          'author': author,
          'isbn': isbn,
          'image': imageUrl,
          'hold_date': hold['hold_date'] ?? 'Unknown',
          'pickup_library': hold['pickup_library_id'] ?? 'Unknown',
          'priority': hold['priority']?.toString() ?? 'Unknown',
          'status': status,
        });
      });
    } else {
      print('Failed to load biblios data: ${response.statusCode}');
    }
  }

  Future<void> _deleteHold(int index) async {
    final holdCard = holdCards[index];
    final holdId = holdCard['hold_id'];

    if (holdId == null || widget.accessToken == null) {
      return;
    }

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${widget.accessToken}',
    };

    final response = await http.delete(
      Uri.parse('https://demo.bestbookbuddies.com/api/v1/holds/$holdId'),
      headers: headers,
    );

    if (response.statusCode == 204) {
      setState(() {
        holdCards.removeAt(index);
      });
    } else {
      print("Failed to delete hold: ${response.statusCode}");
    }
  }

  Future<String> _fetchBookImage(String isbn) async {
    final response = await http.get(
      Uri.parse('https://www.googleapis.com/books/v1/volumes?q=isbn:$isbn'),
    );

    if (response.statusCode == 200) {
      final googleBooksData = json.decode(response.body);
      final items = googleBooksData['items'] as List<dynamic>?;

      if (items != null && items.isNotEmpty) {
        final volumeInfo = items[0]['volumeInfo'];
        final imageLinks = volumeInfo['imageLinks'];
        if (imageLinks != null && imageLinks['thumbnail'] != null) {
          return imageLinks['thumbnail'];
        }
      }
    }
    return 'https://pick2read.com/assets/images/not_found.png';
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (holdCards.isEmpty) {
      return const Center(child: Text("No Holds Available"));
    }

    return ListView.builder(
      itemCount: holdCards.length,
      itemBuilder: (context, index) {
        final holdCard = holdCards[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0), // Rounded corners
          ),
          elevation: 8.0, // Box shadow effect
          shadowColor: Colors.black.withOpacity(0.3), // Shadow color
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF61CEFF), // Same as background start color
                  Color(0xFF009A90), // Same as background end color
                ],
                stops: [0.0, 1.0],
              ), // Adjusted gradient to suit the background
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Stack(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (holdCard['image'] != null && holdCard['image'] != '')
                        Image.network(
                          holdCard['image'],
                          width: 80,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      const SizedBox(width: 16.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Title: ${holdCard['title']}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white, // Text color change
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              "Author: ${holdCard['author']}",
                              style: const TextStyle(color: Colors.white),
                            ),
                            Text(
                              "Hold Date: ${holdCard['hold_date']}",
                              style: const TextStyle(color: Colors.white),
                            ),
                            Text(
                              "Status: ${holdCard['status']}",
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await _deleteHold(index);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
