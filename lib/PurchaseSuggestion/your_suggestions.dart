import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class YourSuggestions extends StatefulWidget {
  const YourSuggestions({Key? key}) : super(key: key);

  @override
  _YourSuggestionsState createState() => _YourSuggestionsState();
}

class _YourSuggestionsState extends State<YourSuggestions> {
  List<dynamic> suggestions = [];
  List<dynamic> filteredSuggestions = [];
  bool isLoading = true;
  String? errorMessage;
  final TextEditingController searchController = TextEditingController();
  Map<int, bool> selectedRows = {};
  bool isAllSelected = false;
  ScrollController _scrollController = ScrollController(); // Add ScrollController

  @override
  void initState() {
    super.initState();
    fetchSuggestions();
    searchController.addListener(_onSearch);
  }

  Future<void> fetchSuggestions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');

      if (accessToken == null) {
        setState(() {
          isLoading = false;
          errorMessage = "Access token not found.";
        });
        return;
      }

      final response = await http.get(
        Uri.parse('https://demo.bestbookbuddies.com/api/v1/suggestions'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          suggestions = data;
          filteredSuggestions = data;
          isLoading = false;
          // Initialize selection state
          selectedRows = {for (var item in data) item["suggestion_id"]: false};
        });
      } else {
        setState(() {
          errorMessage = "Failed to fetch data: ${response.reasonPhrase}";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "An error occurred: $e";
        isLoading = false;
      });
    }
  }

  void _onSearch() {
    final query = searchController.text.toLowerCase();

    setState(() {
      if (query.isEmpty) {
        filteredSuggestions = suggestions;
      } else {
        filteredSuggestions = suggestions.where((suggestion) {
          final title = (suggestion['title'] ?? '').toLowerCase();
          return title.contains(query);
        }).toList();
      }
    });
  }

  void _toggleAllSelections(bool? value) {
    setState(() {
      isAllSelected = value ?? false;
      for (var key in selectedRows.keys) {
        selectedRows[key] = isAllSelected;
      }
    });
  }

  void _toggleSelection(int id, bool? value) {
    setState(() {
      selectedRows[id] = value ?? false;
      isAllSelected = selectedRows.values.every((isSelected) => isSelected);
    });
  }

  Future<void> _deleteSelectedSuggestions() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token');

    if (accessToken == null) {
      setState(() {
        errorMessage = "Access token not found.";
      });
      return;
    }

    final selectedIds = selectedRows.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    if (selectedIds.isEmpty) {
      setState(() {
        errorMessage = "No suggestions selected for deletion.";
      });
      return;
    }

    // Perform DELETE requests for each selected suggestion
    for (var id in selectedIds) {
      final response = await http.delete(
        Uri.parse('https://demo.bestbookbuddies.com/api/v1/suggestions/$id'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 204) {
        // Successfully deleted
        setState(() {
          suggestions.removeWhere((suggestion) => suggestion["suggestion_id"] == id);
          filteredSuggestions = List.from(suggestions); // Refresh filtered suggestions
          selectedRows.remove(id); // Remove from selected rows
        });
      } else {
        setState(() {
          errorMessage = "Failed to delete suggestion with ID $id: ${response.reasonPhrase}";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : errorMessage != null
        ? Center(child: Text(errorMessage!))
        : Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: "Search By Keywords",
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
        ),
        Expanded( // Use Expanded to allow scrolling inside a Column
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal, // Horizontal scrolling
            child: Scrollbar(
              controller: _scrollController, // Use the controller here
              thumbVisibility: true, // Always show the thumb
              thickness: 8.0, // Adjust thickness of the scrollbar
              radius: Radius.circular(4), // Rounded edges for scrollbar thumb
              child: SingleChildScrollView(
                controller: _scrollController, // Pass the controller here as well
                scrollDirection: Axis.vertical, // Vertical scrolling
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Table Header
                    Container(
                      color: const Color(0xFF009A90),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      child: Row(
                        children: [
                          Checkbox(
                            value: isAllSelected,
                            onChanged: _toggleAllSelections,
                            checkColor: Colors.white,
                          ),
                          const SizedBox(
                            width: 200,
                            child: Text(
                              "Summary",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 140,
                            child: Text(
                              "Suggested On",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 100,
                            child: Text(
                              "Status",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Table Body
                    Column(
                      children: filteredSuggestions.map((suggestion) {
                        final suggestionId = suggestion["suggestion_id"];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          child: Row(
                            children: [
                              Checkbox(
                                value: selectedRows[suggestionId] ?? false,
                                onChanged: (value) =>
                                    _toggleSelection(suggestionId, value),
                              ),
                              SizedBox(
                                width: 199,
                                child: Text(
                                  suggestion["title"] ?? "N/A",
                                  style: const TextStyle(fontSize: 14),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              ),
                              SizedBox(
                                width: 140,
                                child: Text(
                                  suggestion["suggestion_date"] ?? "N/A",
                                  style: const TextStyle(fontSize: 14),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(
                                width: 100,
                                child: Text(
                                  suggestion["status"] ?? "N/A",
                                  style: const TextStyle(fontSize: 14),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: _deleteSelectedSuggestions,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red, // You can change the button color if needed
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.delete,
                  color: Colors.white,
                  size: 30.0, // Set the size of the icon here
                ),
                SizedBox(width: 8.0), // Space between icon and text
                Text(
                  "Delete Selected Suggestions",
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
