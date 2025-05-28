import 'package:flutter/material.dart';
import 'pages/dashboard_page.dart'; // Import DashboardPage

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App Demo',
      theme: ThemeData(
        primaryColor: const Color(0xFF1EF1C9), // Your theme color
        appBarTheme: const AppBarTheme( // Consistent AppBar styling
          backgroundColor: Color(0xFF1EF1C9),
          foregroundColor: Colors.black, // Color for title text and icons in AppBar
          elevation: 8.0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.black, // Explicitly set title text color
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        // If you want to use Material 3 features and theming:
        // colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1EF1C9)),
        // useMaterial3: true,
      ),
      home: const DashboardPage(), // DashboardPage is now the home screen
      debugShowCheckedModeBanner: false, // Optional: removes the debug banner
    );
  }
}