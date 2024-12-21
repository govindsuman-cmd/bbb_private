import 'package:flutter/material.dart';
import 'library_profile_form.dart';
import 'personal_details_form.dart';
import 'main_address_form.dart';
import 'contact_info_form.dart';
import 'package:bbb_mobile_app/CustomWidget/background_widget.dart';
import 'package:bbb_mobile_app/CustomWidget/footer_tab.dart';

class EditUserDetailsScreen extends StatefulWidget {
  const EditUserDetailsScreen({super.key});

  @override
  State<EditUserDetailsScreen> createState() => _EditUserDetailsScreenState();
}

class _EditUserDetailsScreenState extends State<EditUserDetailsScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _tabController = TabController(length: 4, vsync: this);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Personal Details'),
      ),
      body: SafeArea(
        child: BackgroundWidget(
          child: _tabController == null
              ? const Center(child: CircularProgressIndicator())
              : Column(
            children: [
              // TabBar connected to the TabController
              TabBar(
                controller: _tabController,
                isScrollable: true,
                tabs: const [
                  Tab(text: 'Library Profile'),
                  Tab(text: 'Personal Details'),
                  Tab(text: 'Main Address'),
                  Tab(text: 'Contact Info'),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(

                child: TabBarView(
                  controller: _tabController,
                  children: [
                    LibraryProfileForm(tabController: _tabController),
                    PersonalDetailsForm(tabController: _tabController),
                    MainAddressForm(tabController: _tabController),
                    ContactInfoForm(tabController: _tabController),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const FooterTab(),
    );
  }

  @override
  void dispose() {
    _tabController?.dispose(); // Dispose only if it's initialized
    super.dispose();
  }
}
