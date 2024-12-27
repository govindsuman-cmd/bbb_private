import 'package:bbb_mobile_app/CustomWidget/background_widget.dart';
import 'package:bbb_mobile_app/CustomWidget/footer_tab.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Charges extends StatefulWidget {
  const Charges({super.key});

  @override
  State<Charges> createState() => _ChargesState();
}

class _ChargesState extends State<Charges> {
  List<Map<String, dynamic>> feeEntries = [];
  double totalDue = 0.0;
  bool isLoading = true;
  String? accessToken;
  int? patronId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      accessToken = prefs.getString('access_token');
      patronId = prefs.getInt('patron_id');
    });

    if (accessToken != null && patronId != null) {
      _fetchFeeDueData();
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchFeeDueData() async {
    if (accessToken == null || patronId == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };

    final response = await http.get(
      Uri.parse(
          'https://demo.bestbookbuddies.com/api/v1/patrons/$patronId/account/debits'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> feeData = json.decode(response.body);
      double total = 0.0;

      for (var feeItem in feeData) {
        final amountOutstanding = feeItem['amount_outstanding'] ?? 0.0;
        if (amountOutstanding > 0) {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Charges Details"),
        backgroundColor: const Color(0xFF009A90),
        centerTitle: true,
        elevation: 0,
      ),
      body: BackgroundWidget(
        child: Column(
          children: [
            // Main content section with padding
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 25),
                    const Text(
                      "Your Charges",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Loading or Fee Data
                    if (isLoading)
                      const Center(child: CircularProgressIndicator())
                    else
                      if (feeEntries.isEmpty)
                        const Center(child: Text("No Fees Due"))
                      else
                      // Table displaying fee entries
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Table(
                                  columnWidths: const {
                                    0: FlexColumnWidth(2),
                                    1: FlexColumnWidth(4),
                                    2: FlexColumnWidth(2),
                                  },
                                  children: [
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
                                // Total Due Below the Table
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12.0, horizontal: 8.0),
                                  decoration: const BoxDecoration(
                                    color: Colors.grey,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment
                                        .spaceBetween,
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

                                const SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: () {
                                    print("Pay Now clicked");
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF009A90),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 15.0,
                                      horizontal: 20.0,
                                    ),
                                    textStyle: const TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  child: const Text(
                                    "Pay Now",
                                    style: TextStyle(
                                      color: Colors.white, // Set the text color to white
                                    ),
                                  ),
                                ),

                              ],
                            ),
                          ),
                        ),
                  ],
                ),
              ),
            ),
            // Footer tab at the bottom
            const FooterTab(),
          ],
        ),
      ),
    );
  }
}