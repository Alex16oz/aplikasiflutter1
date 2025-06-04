// lib/pages/user_profile_page.dart
import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart'; // Import the AppDrawer

class UserProfilePage extends StatefulWidget { // Changed to StatefulWidget
  const UserProfilePage({super.key});

  static const String routeName = '/user-profile';

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> { // Created State
  // Placeholder for dropdown value, not strictly needed if not displaying selected item in button
  // String? _selectedAction;

  // Define the dropdown items
  final List<String> _editOptions = [
    'Edit Password',
    'Edit Username',
    'Edit Email'
  ];

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
            // Edit Profile DropdownButton
            Align(
              alignment: Alignment.centerRight,
              child: Container( // Wrap DropdownButton in a Container for styling if needed
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: DropdownButtonHideUnderline( // Removes the default underline
                  child: DropdownButton<String>(
                    hint: const Text(
                      'Edit Profile',
                      style: TextStyle(color: Colors.black), // Match ElevatedButton text color
                    ),
                    // value: _selectedAction, // Uncomment if you want to display the selected item
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.black), // Dropdown arrow color
                    iconSize: 24,
                    isExpanded: false, // Set to true if you want the dropdown to expand to container width
                    dropdownColor: Theme.of(context).primaryColorLight, // Background color of dropdown menu
                    style: const TextStyle(color: Colors.black, fontSize: 16), // Text style for items
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        // setState(() {
                        //   _selectedAction = newValue; // Update the selected action
                        // });
                        // TODO: Implement navigation or action based on selected option
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('$newValue selected')),
                        );
                        // Example:
                        // if (newValue == 'Edit Password') {
                        //   // Navigate to edit password page
                        // } else if (newValue == 'Edit Username') {
                        //   // Navigate to edit username page
                        // } else if (newValue == 'Edit Email') {
                        //   // Navigate to edit email page
                        // }
                      }
                    },
                    items: _editOptions.map<DropdownMenuItem<String>>((String value) {
                      IconData iconData;
                      if (value == 'Edit Password') {
                        iconData = Icons.lock_open_outlined;
                      } else if (value == 'Edit Username') {
                        iconData = Icons.person_outline;
                      } else { // Edit Email
                        iconData = Icons.email_outlined;
                      }
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Row(
                          children: <Widget>[
                            Icon(iconData, color: Colors.black54, size: 20), // Icon for the item
                            const SizedBox(width: 8),
                            Text(value),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
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