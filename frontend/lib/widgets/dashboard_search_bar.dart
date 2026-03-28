import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async'; // 👇 Timer ke liye import kiya
import '../providers/search_provider.dart';

class DashboardSearchBar extends ConsumerStatefulWidget {
  const DashboardSearchBar({super.key});

  @override
  ConsumerState<DashboardSearchBar> createState() => _DashboardSearchBarState();
}

class _DashboardSearchBarState extends ConsumerState<DashboardSearchBar> {
  Timer? _debounce; // 👇 Timer variable

  @override
  void dispose() {
    _debounce?.cancel(); // Memory leak se bachne ke liye
    super.dispose();
  }

  // 👇 Yahan hai asli Magic (Debouncing Logic) 👇
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    // 👇 Ye print turant chalega jaise hi tu keyboard pe button dabayega
    print("User is typing: $query (Timer Reset)"); 
    
    _debounce = Timer(const Duration(milliseconds: 300), () {
      // 👇 Ye print tabhi chalega jab tu 300ms ke liye type karna band karega
      print("🚀 300ms OVER! Searching for: $query"); 
      ref.read(searchQueryProvider.notifier).state = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 45,
      child: TextField(
        style: const TextStyle(color: Colors.white),
        onChanged: _onSearchChanged, // 👇 Yahan function connect kiya
        decoration: InputDecoration(
          hintText: 'Search tasks...',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
          prefixIcon: const Icon(Icons.search, color: Colors.white54),
          filled: true,
          fillColor: Colors.black.withOpacity(0.3),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.cyanAccent),
          ),
        ),
      ),
    );
  }
}