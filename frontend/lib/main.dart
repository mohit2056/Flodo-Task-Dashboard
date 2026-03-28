import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/task_list_screen.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

// ... existing imports

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flodo Task Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        // 👇 Premium Deep Deep Dark Background (SaaS vibe) 👇
        scaffoldBackgroundColor: const Color(0xFF0A0E17), 
        primaryColor: Colors.deepPurpleAccent,
        appBarTheme: const AppBarTheme(
          // AppBar transparent rahega taaki background blobs dikhein
          backgroundColor: Colors.transparent, 
          elevation: 0,
          titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white),
        ),
        colorScheme: const ColorScheme.dark(
          primary: Colors.deepPurpleAccent,
          secondary: Colors.cyanAccent, // Good contrast with purple
        ),
      ),
      home: const TaskListScreen(),
    );
  }
}