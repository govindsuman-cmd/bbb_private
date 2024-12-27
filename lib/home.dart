import 'dart:async';
import 'package:bbb_mobile_app/CustomWidget/background_widget.dart';
import 'package:bbb_mobile_app/Provider/provider.dart';
import 'package:bbb_mobile_app/total_book_user.dart'; // Import the TotalBookUser widget
import '/CustomWidget/footer_tab.dart';
import 'package:bbb_mobile_app/drawer_content.dart';
import 'package:bbb_mobile_app/popular_genres.dart';
import 'package:bbb_mobile_app/top_circulating_books.dart';
import 'package:flutter/material.dart';
import 'package:bbb_mobile_app/new_arrivals.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  late stt.SpeechToText _speech;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _startListening() async {
    bool available = await _speech.initialize(
      onStatus: (status) => debugPrint('Speech Status: $status'),
      onError: (errorNotification) =>
          debugPrint('Speech Error: $errorNotification'),
    );

    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (result) {
          setState(() {
            _searchController.text = result.recognizedWords;
          });
        },
      );
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  void _logout(BuildContext context) {
    debugPrint("User logged out");
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final userInfo = Provider.of<UserInfoProvider>(context).userInfo;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF009A90),
        toolbarHeight: 130,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                    color: Colors.white,
                  ),
                ),
                const Expanded(
                  child: Text(
                    "ABC Library",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_searchController.text.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                });
                              },
                            ),
                          IconButton(
                            icon: Icon(_isListening ? Icons.mic_off : Icons.mic),
                            onPressed: () {
                              if (_isListening) {
                                _stopListening();
                              } else {
                                _startListening();
                              }
                            },
                          ),
                        ],
                      ),
                      hintText: "Search...",
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 0.0,
                        horizontal: 15.0,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.tune),
                  color: Colors.white,
                  onPressed: () => debugPrint("Filter icon clicked"),
                ),
              ],
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 2 / 3,
          child: DrawerContent(
            logout: () => _logout(context),
            userInfo: userInfo,
          ),
        ),
      ),
      body: BackgroundWidget(
        child: SingleChildScrollView(
          child: Column(
            children: [
              NewArrivals(searchQuery: _searchController.text),
              TopCirculatingBooks(searchQuery: _searchController.text),
              TotalBookUser(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const FooterTab(),
    );
  }
}
