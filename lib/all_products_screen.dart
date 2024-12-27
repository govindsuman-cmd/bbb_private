import 'dart:convert';
import 'package:bbb_mobile_app/Books/single_book_details.dart';
import 'package:bbb_mobile_app/CustomWidget/background_widget.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AllProductsScreen extends StatefulWidget {
  final String title;

  const AllProductsScreen({
    super.key,
    required this.title,
  });

  @override
  State<AllProductsScreen> createState() => _AllProductsScreenState();
}

class _AllProductsScreenState extends State<AllProductsScreen> {
  List<dynamic> products = [];
  List<dynamic> filteredProducts = [];
  int currentPage = 1;
  bool isLoading = false;

  static const String baseUrl = "https://demo.bestbookbuddies.com/api/v1/biblios";

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchProducts();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  Future<String> fetchThumbnail(String isbn) async {
    try {
      final url = Uri.parse('https://www.googleapis.com/books/v1/volumes?q=isbn:$isbn');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['totalItems'] > 0) {
          return data['items'][0]['volumeInfo']['imageLinks']['thumbnail'] ??
              'https://d1csarkz8obe9u.cloudfront.net/posterpreviews/book-cover-design-template-92c3f6e44971e2b7224afdb9bdac6356_screen.jpg?ts=1730154692';
        }
      }
    } catch (e) {
      print('Error fetching thumbnail: $e');
    }

    return 'https://pick2read.com/assets/images/not_found.png';
  }

  Future<void> fetchProducts() async {
    try {
      setState(() {
        isLoading = true;
      });

      final url = Uri.parse(baseUrl).replace(queryParameters: {
        '_order_by': '-biblio_id',
        '_page': currentPage.toString(),
        '_per_page': '10',
      });

      final headers = await _getHeaders();

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final fetchedProducts = json.decode(utf8.decode(response.bodyBytes)) as List<dynamic>;

        for (var product in fetchedProducts) {
          final isbn = product['isbn'] ?? '';
          if (isbn.isNotEmpty) {
            product['image_url'] = await fetchThumbnail(isbn);
          }
        }

        setState(() {
          products = fetchedProducts;
          filteredProducts = fetchedProducts; // Initialize filtered list with all products
        });
      } else {
        print('Error: ${response.statusCode} ${response.reasonPhrase}');
        throw Exception('Failed to load products');
      }
    } catch (e) {
      print('Error fetching products: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void goToNextPage() {
    setState(() {
      currentPage++;
    });
    fetchProducts();
  }

  void goToPreviousPage() {
    if (currentPage > 1) {
      setState(() {
        currentPage--;
      });
      fetchProducts();
    }
  }

  void _onSearchChanged() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      filteredProducts = products.where((product) {
        String title = product['title']?.toLowerCase() ?? '';
        String author = product['author']?.toLowerCase() ?? '';
        return title.contains(query) || author.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF009A90),
      ),
      body: BackgroundWidget(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: 'Search by Title or Author',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: filteredProducts.length,
                itemBuilder: (context, index) {
                  final product = filteredProducts[index];
                  final title = product['title'] ?? 'Untitled';
                  final isbn = product['isbn'] ?? 'N/A';
                  final author = product['author'] ?? 'Unknown';
                  final biblioId = product['biblio_id'] ?? '';
                  final publication_place = product['publication_place'] ?? '';
                  final publication_year = product['publication_year'] ?? '';

                  String imageUrl = product['image_url'] ??
                      'https://pick2read.com/assets/images/not_found.png';

                  return GestureDetector(
                    onTap: () {
                      if (biblioId != null && biblioId > 0) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SingleBookDetails(
                              biblioId: biblioId,
                            ),
                          ),
                        );
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.all(8.0),
                      child: Card(
                        elevation: 4.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: SizedBox(
                          height: 220,
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.network(
                                  imageUrl,
                                  height: 220,
                                  width: 150,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        title.length > 13
                                            ? '${title.substring(0, 13)}...'
                                            : title,
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'ISBN: $isbn',
                                        style: const TextStyle(color: Colors.grey),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Publication Details: $publication_place $publication_year',
                                        style: const TextStyle(color: Colors.grey),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        'Author: ${author.length > 7 ? '${author.substring(0, 7)}...' : author}',
                                        style: const TextStyle(color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: currentPage > 1 ? goToPreviousPage : null,
                    child: const Text('Previous'),
                  ),
                  ElevatedButton(
                    onPressed: filteredProducts.isNotEmpty ? goToNextPage : null,
                    child: const Text('Next'),
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
