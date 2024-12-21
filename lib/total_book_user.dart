import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TotalBookUser extends StatefulWidget {
  const TotalBookUser({Key? key}) : super(key: key);

  @override
  State<TotalBookUser> createState() => _TotalBookUserState();
}

class _TotalBookUserState extends State<TotalBookUser> {
  int totalBooks = 0;
  int totalUsers = 0;
  bool isLoading = true;
  bool isError = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<String?> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  Future<void> _fetchData() async {
    final accessToken = await _getAccessToken();

    if (accessToken == null) {
      setState(() {
        isLoading = false;
        isError = true;
      });
      return;
    }

    try {
      final bookResponse = await http.get(
        Uri.parse('https://demo.bestbookbuddies.com/api/v1/items'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );
      if (bookResponse.statusCode == 200) {
        final totalBooksHeader = bookResponse.headers['x-base-total-count'];
        setState(() {
          totalBooks = totalBooksHeader != null ? int.parse(totalBooksHeader) : 0;
        });
      } else {
        throw Exception('Failed to load books');
      }

      final userResponse = await http.get(
        Uri.parse('https://demo.bestbookbuddies.com/api/v1/patrons'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );
      if (userResponse.statusCode == 200) {
        final usersData = userResponse.headers['x-base-total-count'];
        setState(() {
          totalUsers = usersData != null ? int.parse(usersData) : 0;
        });
      } else {
        throw Exception('Failed to load users');
      }
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        isError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : isError
          ? const Center(child: Text('Failed to load data. Please try again.'))
          : Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStatCard(
              icon: Icons.menu_book_outlined,
              color: Colors.blue,
              label: 'Books',
              count: totalBooks,
            ),
            const SizedBox(width: 40),
            // Total Users Card
            _buildStatCard(
              icon: Icons.supervised_user_circle_rounded,
              color: const Color(0xFFFF484C), // #FF484C Red
              label: 'Users',
              count: totalUsers,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color color,
    required String label,
    required int count,
  }) {
    return Row(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Icon(
              icon,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$count',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
