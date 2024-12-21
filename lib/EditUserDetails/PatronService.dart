import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PatronService {
  static const String apiUrl = 'https://your-api-url.com'; // Replace with your actual API URL

  // Method to fetch patron data using patron_id and access_token from shared preferences
  static Future<Map<String, dynamic>?> fetchPatronData(String patronId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('access_token');

    if (accessToken == null) {
      throw Exception("Access token is not available");
    }

    final response = await http.get(
      Uri.parse('$apiUrl/patrons/$patronId'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      // Parse the JSON data from the API response
      final Map<String, dynamic> data = json.decode(response.body);
      return data;
    } else {
      // Handle errors (like 401 Unauthorized, 404 Not Found, etc.)
      throw Exception("Failed to load patron data: ${response.body}");
    }
  }

  // Method to update patron data using patron_id and access_token from shared preferences
  static Future<bool> updatePatronData(String patronId, Map<String, dynamic> updatedData) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('access_token');

    if (accessToken == null) {
      throw Exception("Access token is not available");
    }

    final response = await http.put(
      Uri.parse('$apiUrl/patrons/$patronId'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: json.encode(updatedData),
    );

    if (response.statusCode == 200) {
      // If the update is successful, return true
      return true;
    } else {
      // Handle errors (like 401 Unauthorized, 400 Bad Request, etc.)
      print("Error updating data: ${response.body}");
      throw Exception("Failed to update patron data: ${response.body}");
    }
  }
}
