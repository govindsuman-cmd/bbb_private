import 'package:bbb_mobile_app/EditUserDetails/edit_user_detials.dart';
import 'package:flutter/material.dart';

class DrawerContent extends StatelessWidget {
  const DrawerContent({super.key, required this.logout, required this.userInfo});

  final VoidCallback logout;
  final Map<String, dynamic> userInfo;

  @override
  Widget build(BuildContext context) {
    final String firstName = userInfo['firstname'] ?? '';
    final String surname = userInfo['surname'] ?? '';
    final String middlename= userInfo['middle_name'] ?? '';
    final String userName = '$firstName $middlename $surname'.trim();


    final String initials = '${firstName.isNotEmpty ? firstName[0].toUpperCase() : ''}${surname.isNotEmpty ? surname[0].toUpperCase() : ''}';

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(
          decoration: const BoxDecoration(
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: const Color(0xFF009A90),
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // User name text
              Text(
                userName.isEmpty ? "Guest" : userName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        // Home
        ListTile(
          leading: const Icon(Icons.home),
          title: const Text("Home"),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        // My Account (Dropdown)
        ExpansionTile(
          leading: const Icon(Icons.account_circle),
          title: const Text("My Account"),
          children: [
            ListTile(
              title: const Text("Summary"),
              onTap: () {

              },
            ),
            ListTile(
              title: const Text("Personal Details"),
              onTap: () {
                Navigator.push(context,
                  MaterialPageRoute(builder: (context)=>const EditUserDetailsScreen())
                );
              },
            ),
            ListTile(
              title: const Text("Charges"),
              onTap: () {

              },
            ),
            ListTile(
              title: const Text("Change Password"),
              onTap: () {

              },
            ),
            ListTile(
              title: const Text("Reading History"),
              onTap: () {

              },
            ),
            ListTile(
              title: const Text("Purchase Suggestions"),
              onTap: () {

              },
            ),
            ListTile(
              title: const Text("Discharge"),
              onTap: () {

              },
            ),
          ],
        ),
        // Advanced Search
        ListTile(
          leading: const Icon(Icons.search),
          title: const Text("Advanced Search"),
          onTap: () {
            // Handle navigation for Advanced Search
          },
        ),

        ListTile(
          leading: const Icon(Icons.camera_alt),
          title: const Text("Search Book By Barcode"),
          onTap: () {
          },
        ),
        // About Library
        // About Library (Dropdown)
        ExpansionTile(
          leading: const Icon(Icons.info),
          title: const Text("About Library"),
          children: [
            ListTile(
              title: const Text("About Us"),
              onTap: () {
                // Handle navigation for About Us
              },
            ),
            ListTile(
              title: const Text("Rules & Regulation"),
              onTap: () {
                // Handle navigation for Rules & Regulation
              },
            ),
            ListTile(
              title: const Text("Contact Us"),
              onTap: () {
                // Handle navigation for Contact Us
              },
            ),
          ],
        ),


        ListTile(
          leading: const Icon(Icons.info_outline),
          title: const Text("About App"),
          onTap: () {

          },
        ),
        // Settings
        ListTile(
          leading: const Icon(Icons.settings),
          title: const Text("Setting"),
          onTap: () {

          },
        ),
        // Logout
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text("Logout"),
          onTap: logout,
        ),
      ],
    );
  }
}