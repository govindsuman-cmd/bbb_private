import 'package:bbb_mobile_app/CustomWidget/advanced_search_dropup.dart';
import 'package:bbb_mobile_app/EditUserDetails/edit_user_detials.dart';
import 'package:bbb_mobile_app/Summary/your_summary.dart';
import 'package:bbb_mobile_app/home.dart';
import 'package:flutter/material.dart';

class FooterTab extends StatefulWidget {
  const FooterTab({super.key});

  @override
  State<FooterTab> createState() => _FooterTabState();
}

class _FooterTabState extends State<FooterTab> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (_selectedIndex == 0){
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }else if (_selectedIndex == 2) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => const AdvancedSearchDropup(),
      );
    } else if (_selectedIndex == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const YourSummary()),
      );
    }  else if (_selectedIndex == 4) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const EditUserDetailsScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.qr_code_scanner),
          label: 'Barcode',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Search',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.view_list),
          label: 'Summary',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_circle),
          label: 'Profile',
        ),
      ],
    );
  }
}
