import 'package:bbb_mobile_app/CustomWidget/custom_tab_bar.dart';
import 'package:bbb_mobile_app/CustomWidget/tab_content.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bbb_mobile_app/CustomWidget/background_widget.dart';
import 'package:bbb_mobile_app/CustomWidget/footer_tab.dart';

class YourSummary extends StatefulWidget {
  const YourSummary({super.key});

  @override
  State<YourSummary> createState() => _YourSummaryState();
}

class _YourSummaryState extends State<YourSummary> with SingleTickerProviderStateMixin {
  String? accessToken;
  int? patron_id;
  List<dynamic> cards = [];
  bool isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _loadData();
    _tabController = TabController(length: 4, vsync: this);
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      accessToken = prefs.getString('access_token');
      patron_id = prefs.getInt('patron_id');
    });
    if (accessToken != null && patron_id != null) {
      await _fetchCheckoutData();
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _fetchCheckoutData() async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'x-koha-query': '{"patron_id": { "=":"$patron_id"} }',
      'Accept-Charset': 'utf-8',
      'Authorization': 'Bearer $accessToken',
    };

    final response = await http.get(
      Uri.parse('https://demo.bestbookbuddies.com/api/v1/checkouts'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> checkoutData = json.decode(response.body);
      if (checkoutData.isNotEmpty) {
        for (var checkoutItem in checkoutData) {
          int itemId = checkoutItem['item_id'];
          String rawDueDate = checkoutItem['due_date'] ?? 'Unknown Due Date';

          String dueDate = 'Unknown Due Date';
          bool isOverdue = false;
          int checkOutId=checkoutItem["checkout_id"];
          if (rawDueDate != 'Unknown Due Date') {
            try {
              final DateTime parsedDate = DateTime.parse(rawDueDate);
              dueDate = DateFormat('dd/MM/yyyy').format(parsedDate);
              isOverdue = parsedDate.isBefore(DateTime.now());
            } catch (e) {
              print('Error parsing date: $e');
            }
          }

          await _fetchItemData(itemId, dueDate, isOverdue,checkOutId);
        }
      }
    } else {
      print('Failed to load checkout data: ${response.statusCode}');
    }
  }

  Future<void> _fetchItemData(int itemId, String dueDate, bool isOverdue, int checkOutId) async {
    final response = await http.get(
      Uri.parse('https://demo.bestbookbuddies.com/api/v1/items/$itemId'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final itemData = json.decode(response.body);
      final biblioId = itemData['biblio_id'];

      await _fetchBibliosData(biblioId, dueDate, isOverdue, checkOutId);
    } else {
      print('Failed to load item data: ${response.statusCode}');
    }
  }

  Future<void> _fetchBibliosData(int biblioId, String dueDate, bool isOverdue, int checkOutId) async {
    final response = await http.get(
      Uri.parse('https://demo.bestbookbuddies.com/api/v1/biblios/$biblioId'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final bibliosData = json.decode(response.body);
      final isbn = bibliosData['isbn'] ?? 'Unknown ISBN';

      String? imageUrl;
      if (isbn != 'Unknown ISBN') {
        imageUrl = await _fetchImageFromGoogleBooks(isbn);
      }

      setState(() {
        cards.add({
          'title': bibliosData['title'] ?? 'Unknown Title',
          'author': bibliosData['author'] ?? 'Unknown Author',
          'isbn': isbn,
          'pages': bibliosData['pages'] ?? 'Unknown Pages',
          'image': imageUrl ?? '',
          'due_date': dueDate,
          'checkout_id':checkOutId,
          'isOverdue': isOverdue,
        });
      });
    } else {
      print('Failed to load biblios data: ${response.statusCode}');
    }
  }

  Future<String?> _fetchImageFromGoogleBooks(String isbn) async {
    final response = await http.get(
      Uri.parse('https://www.googleapis.com/books/v1/volumes?q=isbn:$isbn'),
    );

    if (response.statusCode == 200) {
      final googleBooksData = json.decode(response.body);
      final items = googleBooksData['items'] as List<dynamic>?;

      if (items != null && items.isNotEmpty) {
        final volumeInfo = items[0]['volumeInfo'];
        final imageLinks = volumeInfo['imageLinks'];
        return imageLinks?['thumbnail'];
      }
    } else {
      print('Failed to load image from Google Books API: ${response.statusCode}');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final overdueCards = cards.where((card) => card['isOverdue'] == true).toList();
    final currentCheckouts = cards.where((card) => card['isOverdue'] == false).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Summary"),
      ),
      body: BackgroundWidget(
        child: Column(
          children: [
            const SizedBox(height: 20.0),
            CustomTabBar(
              tabController: _tabController,
              tabTitles: const ['Checkout(s)', 'Overdue', 'Holds', 'Fee Due'],
            ),
            const SizedBox(height: 18.0),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  TabContent(title: "Checkout(s)", content: currentCheckouts),
                  TabContent(title: "Overdue", content: overdueCards),
                  TabContent(title: "Holds", content: []),
                  TabContent(title: "Fee Due", content: []),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: FooterTab(),
    );
  }
}
