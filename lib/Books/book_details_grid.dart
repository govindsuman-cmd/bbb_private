import 'package:flutter/material.dart';

class BookDetailsGrid extends StatelessWidget {
  final Map<String, dynamic> bookDetails;

  const BookDetailsGrid({Key? key, required this.bookDetails}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[200],
      ),
      child: Column(
        children: [
          _buildDetailsRow(
            'Publication Details',
            '${bookDetails["publication_place"] ?? "Unknown"} ${bookDetails["publication_year"] ?? ""}',
            'ISBN',
            bookDetails['isbn'],
          ),
          const SizedBox(height: 10),
          _buildDetailsRow('Edition', bookDetails['edition'], 'Subject(s)', bookDetails['subject']),
          const SizedBox(height: 10),
          _buildDetailsRow('Number of Pages', bookDetails['number_of_pages']?.toString(), 'Language', bookDetails['language']),
          const SizedBox(height: 10),
          _buildDetailsRow('Classification', bookDetails['classification'], "", ''),
        ],
      ),
    );
  }

  Widget _buildDetailsRow(String label1, String? value1, String label2, String? value2) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label1, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Text(value1 ?? 'N/A'),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label2, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Text(value2 ?? 'N/A'),
            ],
          ),
        ),
      ],
    );
  }
}
