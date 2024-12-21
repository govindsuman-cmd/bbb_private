import 'package:bbb_mobile_app/Books/book_item_detials.dart';
import 'package:bbb_mobile_app/Books/place_hold_widget.dart';
import 'package:bbb_mobile_app/CustomWidget/background_widget.dart';
import 'package:bbb_mobile_app/CustomWidget/footer_tab.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'book_details_grid.dart';

class SingleBookDetails extends StatefulWidget {
  final int biblioId;

  const SingleBookDetails({Key? key, required this.biblioId}) : super(key: key);

  @override
  _SingleBookDetailsState createState() => _SingleBookDetailsState();
}

class _SingleBookDetailsState extends State<SingleBookDetails> {
  bool isLoading = true;
  Map<String, dynamic> bookDetails = {};
  String bookImageUrl = '';

  static const String baseUrl = "https://demo.bestbookbuddies.com/api/v1/biblios/";

  Future<String> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token') ?? '';
  }

  Future<void> fetchBookDetails() async {
    print(widget.biblioId);
    try {
      setState(() {
        isLoading = true;
      });

      final accessToken = await _getAccessToken();
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'x-koha-query': jsonEncode({"isbn": {"-not_like": "null"}}),
        'Accept-Charset': 'utf-8',
        'Authorization': 'Bearer $accessToken',
      };

      final url = Uri.parse('$baseUrl${widget.biblioId}');
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final decodedResponse = utf8.decode(response.bodyBytes);
        setState(() {
          bookDetails = json.decode(decodedResponse);
        });

        final isbn = bookDetails['isbn'];
        if (isbn != null && isbn.isNotEmpty) {
          await fetchBookImage(isbn);
        }
      } else {
        throw Exception('Failed to load book details');
      }
    } catch (e) {
      print('Error fetching book details: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchBookImage(String isbn) async {
    try {
      final url = Uri.parse('https://www.googleapis.com/books/v1/volumes?q=isbn:$isbn');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['totalItems'] > 0) {
          final imageUrl = data['items'][0]['volumeInfo']['imageLinks']['thumbnail'];
          setState(() {
            bookImageUrl = imageUrl ?? '';
          });
        }
      }
    } catch (e) {
      print('Error fetching book image: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchBookDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Details'),
        backgroundColor: const Color(0xFF009A90),
      ),
      body: BackgroundWidget(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Book Image
                    Container(
                      width: 151,
                      height: 230,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            blurRadius: 8.0,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: bookImageUrl.isNotEmpty
                            ? Image.network(
                          bookImageUrl,
                          fit: BoxFit.cover,
                        )
                            : const Center(child: CircularProgressIndicator()),
                      ),
                    ),
                    const SizedBox(width: 20),
                    // Book Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bookDetails['title'] ?? 'Title not available',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF333333),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'By: ${bookDetails['author'] ?? 'Unknown'}',
                            style: const TextStyle(
                              fontSize: 18,
                              color: Color(0xFF555555),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'ISBN: ${bookDetails['isbn'] ?? 'N/A'}',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF777777),
                            ),
                          ),
                          const SizedBox(height: 65),
                          ElevatedButton(
                            onPressed: () {
                              print(widget.biblioId);
                              showModalBottomSheet(
                                context: context,
                                shape: const RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.vertical(top: Radius.circular(16)),
                                ),
                                isScrollControlled: true,
                                builder: (BuildContext context) {
                                  return PlaceHoldWidget(
                                    bookTitle: bookDetails['title'] ?? 'Unknown Title',
                                    bookAuthor: bookDetails['author'] ?? 'Unknown Author',
                                    biblioId:widget.biblioId,
                                  );
                                },
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF009A90),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Place Hold',
                                  style: TextStyle(fontSize: 25, color: Colors.white),
                                ),
                                SizedBox(width: 8),
                                Icon(
                                  Icons.bookmark,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                BookDetailsGrid(bookDetails: bookDetails),
                BookItemDetails(biblioId:widget.biblioId)
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const FooterTab(),
    );
  }
}
