import 'package:bbb_mobile_app/CustomWidget/background_widget.dart';
import 'package:bbb_mobile_app/CustomWidget/footer_tab.dart';
import 'package:flutter/material.dart';
import 'your_suggestions.dart';
import 'create_new.dart';

class PurchaseSuggestionScreen extends StatelessWidget {
  const PurchaseSuggestionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Number of tabs
      child: Scaffold(
        body: BackgroundWidget(
          child: Column(
            children: [
              Container(
                color: const Color(0xFF009A90),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: const Column(
                  children: [
                    SizedBox(height: 55),
                    TabBar(
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white70,
                      indicatorColor: Colors.white,
                      tabs: [
                        Tab(text: "Your Suggestions"),
                        Tab(text: "+ Create New"),
                      ],
                    ),
                  ],
                ),
              ),
              const Expanded(
                child: TabBarView(
                  children: [
                    YourSuggestions(),
                    CreateNew(),
                  ],
                ),
              ),
              // Footer Tab
              const FooterTab(),
            ],
          ),
        ),
      ),
    );
  }
}
