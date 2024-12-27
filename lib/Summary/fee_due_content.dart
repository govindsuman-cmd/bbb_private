import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FeeDueContent extends StatefulWidget {
  final String? accessToken;
  final int? patronId;

  const FeeDueContent({Key? key, this.accessToken, this.patronId})
      : super(key: key);

  @override
  _FeeDueContentState createState() => _FeeDueContentState();
}

class _FeeDueContentState extends State<FeeDueContent> {
  List<Map<String, dynamic>> feeEntries = [];
  double totalDue = 0.0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFeeDueData();
  }

  Future<void> _fetchFeeDueData() async {
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
      Uri.parse(
          'https://demo.bestbookbuddies.com/api/v1/patrons/${widget.patronId}/account/debits'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> feeData = json.decode(response.body);
      double total = 0.0;

      for (var feeItem in feeData) {
        final amountOutstanding = feeItem['amount_outstanding'] ?? 0.0;
        if (amountOutstanding > 0) {  // Only include if amount_outstanding > 0
          final amount = feeItem['amount'] ?? 0.0;
          total += amount;

          feeEntries.add({
            'date': _formatDate(feeItem['date']),
            'description': feeItem['description'] ?? 'No Description',
            'amount': amount.toStringAsFixed(2),
          });
        }
      }

      setState(() {
        totalDue = total;
        isLoading = false;
      });
    } else {
      print('Failed to load fee due data: ${response.statusCode}');
      setState(() {
        isLoading = false;
      });
    }
  }


  String _formatDate(String? rawDate) {
    if (rawDate == null) return 'Unknown Date';
    try {
      final DateTime parsedDate = DateTime.parse(rawDate);
      return '${parsedDate.day}/${parsedDate.month}/${parsedDate.year}';
    } catch (e) {
      return 'Unknown Date';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (feeEntries.isEmpty) {
      return const Center(child: Text("No Fees Due"));
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Table
          Table(
            columnWidths: const {
              0: FlexColumnWidth(2),
              1: FlexColumnWidth(4),
              2: FlexColumnWidth(2),
            },
            children: [
              // Table Header
              const TableRow(
                decoration: BoxDecoration(
                  color: Color(0xFF009A90),
                ),
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      "Date",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      "Description",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      "Amount",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              // Table Rows
              ...feeEntries.map(
                    (entry) => TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        entry['date'],
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(entry['description']),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "₹${entry['amount']}",
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Total Due
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
            decoration: const BoxDecoration(
              color: Colors.grey,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total Due",
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "₹${totalDue.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
