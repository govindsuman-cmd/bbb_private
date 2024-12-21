import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TabContent extends StatelessWidget {
  final String title;
  final List<dynamic> content;

  const TabContent({
    Key? key,
    required this.title,
    required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: content.isEmpty
              ? const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.info_outline, size: 50, color: Colors.grey),
                SizedBox(height: 8),
                Text(
                  'No content available',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          )
              : ListView.builder(
            itemCount: content.length,
            itemBuilder: (context, index) {
              final card = content[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                elevation: 5.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Container(
                  height: 200,
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      card['image'] != null && card['image'].isNotEmpty
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          card['image'],
                          width: 100,
                          height: 190,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image, size: 80),
                        ),
                      )
                          : const Icon(
                          Icons.book, size: 80, color: Colors.grey),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              card['title'] ?? 'No title',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Author: ${card['author'] ?? 'Unknown Author'}',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            Text(
                              'ISBN: ${card['isbn'] ?? 'Unknown ISBN'}',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            Text(
                              'Pages: ${card['pages'] ?? 'Unknown Pages'}',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            Text(
                              'Due Date: ${card['due_date'] ??
                                  'Unknown Due Date'}',
                              style: TextStyle(
                                color: card['isOverdue'] == true
                                    ? Colors.red
                                    : Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: ElevatedButton(
                                onPressed: () {
                                  _showRenewDialog(context, card);
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                                child: const Text('Renew'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Show confirmation dialog
  void _showRenewDialog(BuildContext context, Map<String, dynamic> card) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Are you sure you want to renew?'),
          content: Text('Do you want to renew the item: ${card['title']}?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('NO'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _renewItem(context, card);
              },
              child: const Text('YES'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _renewItem(BuildContext context,
      Map<String, dynamic> card) async {
    final checkoutId = card['checkout_id'];
    final apiUrl = 'https://demo.bestbookbuddies.com/api/v1/checkouts/$checkoutId/allows_renewal';

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? accessToken = prefs.getString('access_token');

    if (accessToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('No access token found. Please login again.')),
      );
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
          // Pass access token in the header
        },
      );

      // Print the response status code and body for debugging
      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item renewed successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to renew item: ${response.statusCode}')),
        );
      }
    } catch (e) {
      // Print the error to track the issue
      print('Error renewing item: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error renewing item: $e')),
      );
    }
  }
}
