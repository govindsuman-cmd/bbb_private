import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bbb_mobile_app/CustomWidget/background_widget.dart';
import 'package:bbb_mobile_app/CustomWidget/footer_tab.dart';

class ReadHistory extends StatefulWidget {
  const ReadHistory({super.key});

  @override
  _ReadHistoryState createState() => _ReadHistoryState();
}

class _ReadHistoryState extends State<ReadHistory> {
  late String accessToken;
  late int patronId;
  List<Map<String, dynamic>> cardData = [];  // Store final card data

  @override
  void initState() {
    super.initState();
    _fetchAccessTokenAndPatronId();
  }

  // Fetch the access token and patron ID from shared preferences
  Future<void> _fetchAccessTokenAndPatronId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      accessToken = prefs.getString('access_token') ?? '';
      patronId = prefs.getInt('patron_id') ?? 0;
    });
    if (accessToken.isNotEmpty && patronId != 0) {
      _fetchCheckoutData();
    }
  }

  // Fetch checkout data from the API
  Future<void> _fetchCheckoutData() async {
    final url = Uri.parse('https://demo.bestbookbuddies.com/api/v1/checkouts/?checked_in=1');
    final headers = {
      'x-koha-query': '{"patron_id": {"=": "$patronId"}}',
      'Authorization': 'Bearer $accessToken',
    };

    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        List<dynamic> checkoutData = json.decode(response.body);
        for (var item in checkoutData) {
          await _fetchItemDetails(item['item_id']);
        }
      } else {
        // Handle error
        print('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  // Fetch item details using item_id and get biblio_id
  Future<void> _fetchItemDetails(int itemId) async {
    final url = Uri.parse('https://demo.bestbookbuddies.com/api/v1/items/$itemId');
    final headers = {
      'Authorization': 'Bearer $accessToken',
    };

    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        var itemData = json.decode(response.body);
        var biblioId = itemData['biblio_id'];
        await _fetchBiblioDetails(biblioId);
      } else {
        print('Failed to load item details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching item details: $e');
    }
  }

  // Fetch bibliographic data using biblio_id
  Future<void> _fetchBiblioDetails(int biblioId) async {
    final url = Uri.parse('https://demo.bestbookbuddies.com/api/v1/biblios/$biblioId');
    final headers = {
      'Authorization': 'Bearer $accessToken',
    };

    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        var biblioData = json.decode(response.body);
        _addCardData(biblioData);
      } else {
        print('Failed to load biblio details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching biblio details: $e');
    }
  }

  // Add biblio data to cardData list
  void _addCardData(Map<String, dynamic> biblioData) {
    setState(() {
      cardData.add({
        'title': biblioData['title'] ?? 'Unknown Title',
        'author': biblioData['author'] ?? 'Unknown Author',
        'publisher': biblioData['publisher'] ?? 'Unknown Publisher',
        'pages': biblioData['pages'] ?? 'N/A',
        'publication_year': biblioData['publication_year'] ?? 'Unknown Year',
        'isbn': biblioData['isbn'] ?? 'N/A',
        'abstract': biblioData['abstract'] ?? 'No abstract available',
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Reading History",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF009A90),
      ),
      body: BackgroundWidget(
        child: Column(
          children: [
            Expanded(
              child: cardData.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                itemCount: cardData.length,
                itemBuilder: (context, index) {
                  var item = cardData[index];
                  return Card(
                    margin: const EdgeInsets.all(10.0),
                    elevation: 5.0,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Title: ${item['title']}',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 5.0),
                          Text(
                            'Author: ${item['author']}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 5.0),
                          Text(
                            'Publisher: ${item['publisher']}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 5.0),
                          Text(
                            'Pages: ${item['pages']}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 5.0),
                          Text(
                            'Publication Year: ${item['publication_year']}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 5.0),
                          Text(
                            'ISBN: ${item['isbn']}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 5.0),
                          Text(
                            'Abstract: ${item['abstract']}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const FooterTab(),
          ],
        ),
      ),
    );
  }
}
