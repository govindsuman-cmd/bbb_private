import 'dart:convert';
import 'package:bbb_mobile_app/Books/single_book_details.dart';
import 'package:bbb_mobile_app/all_top_circulating_books.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TopCirculatingBooks extends StatefulWidget {
  final String searchQuery;

  const TopCirculatingBooks({super.key, required this.searchQuery});

  @override
  State<TopCirculatingBooks> createState() => _TopCirculatingBooksState();
}

class _TopCirculatingBooksState extends State<TopCirculatingBooks> {
  List<dynamic> biblios = [];
  Map<String, String> bookImages = {};

  final String defaultImageUrl =
      'https://pick2read.com/assets/images/not_found.png';

  @override
  void initState() {
    super.initState();
    fetchBiblios();
  }

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token') ?? '';
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'x-koha-query': jsonEncode({"isbn": {"-not_like": "null"}}),
      'Accept-Charset': 'utf-8',
      'Authorization': 'Bearer $accessToken',
    };
  }

  Future<void> fetchBiblios() async {
    final headers = await _getHeaders();
    final uri = Uri.parse('https://demo.bestbookbuddies.com/api/v1/biblios')
        .replace(queryParameters: {
      '_order_by': '+biblio_id',
      '_page': '1',
      '_per_page': '10',
    });

    try {
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final responseBody = utf8.decode(response.bodyBytes);
        final responseData = json.decode(responseBody);

        setState(() {
          biblios = responseData ?? [];
        });

        for (var biblio in biblios) {
          final isbn = biblio['isbn'] ?? '';
          if (isbn.isNotEmpty) {
            fetchBookImage(isbn);
          }
        }
      } else {
        print('Failed to load biblios: ${response.statusCode}');
        throw Exception('Failed to load biblios');
      }
    } catch (e) {
      print('Error fetching biblios: $e');
    }
  }

  Future<void> fetchBookImage(String isbn) async {
    final uri = Uri.parse('https://www.googleapis.com/books/v1/volumes')
        .replace(queryParameters: {'q': 'isbn:$isbn'});

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData is! Map) {
          throw Exception('Unexpected JSON format');
        }
        if (responseData['totalItems'] > 0) {
          final thumbnail = responseData['items'][0]['volumeInfo']['imageLinks']
          ['thumbnail'];
          setState(() {
            bookImages[isbn] = thumbnail;
          });
        }
      } else {
        print('Failed to fetch book image: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching book image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> filteredBiblios = biblios.where((biblio) {
      String title = biblio['title'] ?? '';
      String author = biblio['author'] ?? '';
      String searchQuery = widget.searchQuery.toLowerCase();
      return title.toLowerCase().contains(searchQuery) ||
          author.toLowerCase().contains(searchQuery);
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Top Circulating',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AllTopCirculatingBooks(
                        title: 'Top Circulating',
                      ),
                    ),
                  );
                },
                child: const Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF009A90),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 240,
            child: filteredBiblios.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: filteredBiblios.length,
              itemBuilder: (context, index) {
                if (index >= filteredBiblios.length) {
                  return Container();
                }

                var biblio = filteredBiblios[index];
                String title = biblio['title'] ?? 'Untitled';
                String author = biblio['author'] ?? 'Unknown';
                String isbn = biblio['isbn'] ?? '';
                int biblioId = biblio['biblio_id'] ?? 0;

                String imageUrl = bookImages[isbn] ?? defaultImageUrl;

                String truncatedTitle = title.length > 15
                    ? '${title.substring(0, 12)}...'
                    : title;
                String truncatedAuthor = author.length > 7
                    ? '${author.substring(0, 7)}...'
                    : author;

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SingleBookDetails(
                          biblioId: biblioId,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 150,
                            height: 160, // Fixed height for image container
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(10),
                              image: DecorationImage(
                                image: NetworkImage(imageUrl),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: imageUrl == defaultImageUrl
                                ? const Center(
                              child: Icon(
                                Icons.book,
                                size: 50,
                                color: Colors.grey,
                              ),
                            )
                                : null,
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxHeight: 40,
                                maxWidth: 40
                              ),
                              child: Text(
                                truncatedTitle,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1, // Allow at most 2 lines for title
                                softWrap: true, // Allow wrapping for complex scripts like Malayalam
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              'Author: $truncatedAuthor',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
