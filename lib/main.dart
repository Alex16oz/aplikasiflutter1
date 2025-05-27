import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter AppBar Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SimplePageWithAppBar(),
    );
  }
}

class SimplePageWithAppBar extends StatelessWidget {
  const SimplePageWithAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Simple Page'),
        backgroundColor: Colors.amber,
        elevation: 8.0,
        centerTitle: true,
      ),
      body: const Center(
        // The main content of the page

      ),
    );
  }
}
