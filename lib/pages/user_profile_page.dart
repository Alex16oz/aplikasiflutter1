import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart'; // Import the AppDrawer

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
      ),
      drawer: const AppDrawer(), // Add the AppDrawer
      body: const Center(
        child: Text(
          'User Profile Page Content',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}