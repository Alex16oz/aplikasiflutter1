// lib/pages/user_profile_page.dart
import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart'; // Import the AppDrawer

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

  static const String routeName = '/user-profile';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
      ),
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column( // Wrap Card and Button in a Column
          children: <Widget>[
            Card(
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Profile Picture on the left
                    const CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage('https://via.placeholder.com/150'), // Placeholder image
                      // You can also use AssetImage for local images:
                      // backgroundImage: AssetImage('assets/profile_pic.png'),
                    ),
                    const SizedBox(width: 16.0), // Spacing between picture and text
                    // User details on the right
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min, // To make the column wrap content
                        children: <Widget>[
                          _buildUserInfoRow(icon: Icons.account_circle, label: 'UserID:', value: 'user123'),
                          const SizedBox(height: 8.0),
                          _buildUserInfoRow(icon: Icons.person, label: 'Username:', value: 'john_doe'),
                          const SizedBox(height: 8.0),
                          _buildUserInfoRow(icon: Icons.lock, label: 'Password:', value: '********'), // Masked password
                          const SizedBox(height: 8.0),
                          _buildUserInfoRow(icon: Icons.email, label: 'Email:', value: 'john.doe@example.com'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16.0), // Spacing between Card and Button
            // Edit Profile Button
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Implement edit profile functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Edit Profile button pressed')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.black, // Text color for the button
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                ),
                child: const Text('Edit Profile'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget to build a row for user info with an icon
  Widget _buildUserInfoRow({required IconData icon, required String label, required String value}) {
    return Row(
      children: <Widget>[
        Icon(icon, size: 20.0, color: Colors.grey[700]),
        const SizedBox(width: 8.0),
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 8.0),
        Expanded( // To allow text to wrap if it's too long
          child: Text(
            value,
            style: const TextStyle(fontSize: 16),
            overflow: TextOverflow.ellipsis, // Handle long text
          ),
        ),
      ],
    );
  }
}