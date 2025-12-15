import 'package:flutter/material.dart';
import 'package:shop/constants.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late TextEditingController _searchController;
  final List<String> _recentSearches = ["Nike Shoes", "Adidas Jacket", "Blue T-shirt"];
  List<String> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }
    
    // Mock search results
    final mockProducts = [
      "Nike Air Max Shoes",
      "Adidas Running Shoes",
      "Blue Denim Jacket",
      "White Cotton T-shirt",
      "Black Leather Belt",
      "Summer Sunglasses",
    ];
    
    setState(() {
      _searchResults = mockProducts
          .where((item) => item.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(defaultPadding),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search products...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _searchController.clear();
                          _performSearch("");
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(defaultBorderRadious),
                ),
              ),
              onChanged: _performSearch,
            ),
          ),
          Expanded(
            child: _searchResults.isEmpty && _searchController.text.isEmpty
                ? ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(defaultPadding),
                        child: Text(
                          "Recent Searches",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      ..._recentSearches.map((search) => ListTile(
                            leading: const Icon(Icons.history),
                            title: Text(search),
                            onTap: () {
                              _searchController.text = search;
                              _performSearch(search);
                            },
                          )),
                    ],
                  )
                : _searchResults.isEmpty
                    ? Center(
                        child: Text(
                          "No products found",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      )
                    : ListView.builder(
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: const Icon(Icons.shopping_bag),
                            title: Text(_searchResults[index]),
                            subtitle: const Text("View details"),
                            onTap: () {
                              // Navigate to product details
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
