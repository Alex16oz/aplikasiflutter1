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
        // Using a specific hex color for the primary color
        primaryColor: const Color(0xFF1EF1C9), // A deep blue color
        // You can further define your color scheme if needed:
        // colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0D47A1)),
        // useMaterial3: true, // Optional: to use Material 3 design
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
        // Using a specific hex color for the AppBar background
        backgroundColor: const Color(0xFF1EF1C9), // Amber color
        elevation: 8.0,
        centerTitle: true,
        // IconTheme for AppBar icons, if needed, can be set here or in ThemeData
        // iconTheme: IconThemeData(color: const Color(0xFFFFFFFF)), // Example: White icons
        // titleTextStyle: TextStyle(color: const Color(0xFF000000)), // Example: Black title
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: const Text(
                'John Doe',
                style: TextStyle(
                  // Using a specific hex color for text
                  color: Color(0xFFFFFFFF), // White color
                  fontWeight: FontWeight.bold,
                ),
              ),
              accountEmail: const Text(
                'john.doe@example.com',
                style: TextStyle(
                  // Using a specific hex color with opacity for text
                  color: Color(0xB3FFFFFF), // White color with 70% opacity
                ),
              ),
              currentAccountPicture: CircleAvatar(
                // Using a specific hex color for the avatar background
                backgroundColor: const Color(0xFFFFFFFF), // White color
                child: Icon(
                  Icons.person,
                  size: 50.0,
                  // Using a specific hex color for the icon
                  color: const Color(0xFF1976D2), // A medium blue color
                ),
              ),
              decoration: BoxDecoration(
                // Using a specific hex color for the header background
                color: const Color(0xFF1976D2), // A medium blue color
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () {
                print('Dashboard tapped');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('User Profile'),
              onTap: () {
                print('User Profile tapped');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_circle_outline),
              title: const Text('Attendance'),
              onTap: () {
                print('Attendance tapped');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.store_mall_directory),
              title: const Text('Warehouse'),
              onTap: () {
                print('Warehouse tapped');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('Schedule'),
              onTap: () {
                print('Schedule tapped');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.build_circle_outlined),
              title: const Text('Spareparts'),
              onTap: () {
                print('Spareparts tapped');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long),
              title: const Text('Repair Reports'),
              onTap: () {
                print('Repair Reports tapped');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.warning_amber_outlined),
              title: const Text('Damage Reports'),
              onTap: () {
                print('Damage Reports tapped');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                print('Settings tapped');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About'),
              onTap: () {
                print('About tapped');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: const Center(
        child: Text(
          'Swipe right or tap the icon to open the drawer!',
          style: TextStyle(fontSize: 18.0),
        ),
      ),
    );
  }
}