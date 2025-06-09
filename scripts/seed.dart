// scripts/seed.dart
import 'package:supabase/supabase.dart';
import 'dart:io';

// --- Configuration ---
// Replace with your project's URL and Service Role Key
// IMPORTANT: Keep your Service Role Key secure and do not expose it in client-side code.
// It's used here because seeding is a privileged, one-time operation.
const supabaseUrl = 'https://sgnavqdkkglhesglhrdi.supabase.co';
const supabaseSvcKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNnbmF2cWRra2dsaGVzZ2xocmRpIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc0ODQ4NzIzMSwiZXhwIjoyMDY0MDYzMjMxfQ.0xmtVi7hVg70sX3TAAMIQb-Rhe7jTmT4iU9YlNbrF6g'; // Find this in your Supabase project settings (API -> Project API keys)

// --- User Data to Seed ---
final List<Map<String, dynamic>> seedUsers = [
  {
    'email': 'admin.user@example.com',
    'password': 'password123',
    'username': 'AdminUser',
    'role': 'Admin'
  },
  {
    'email': 'operator.user@example.com',
    'password': 'password123',
    'username': 'OperatorUser',
    'role': 'Operator'
  },
  {
    'email': 'warehouse.user@example.com',
    'password': 'password123',
    'username': 'WarehouseUser',
    'role': 'Warehouse Staff'
  },
  // Add more users here...
];


Future<void> main() async {
  // Initialize the Supabase client with the service role key for admin privileges.
  final supabase = SupabaseClient(supabaseUrl, supabaseSvcKey);

  print('Seeding users...');

  for (final user in seedUsers) {
    try {
      // Use the admin method to create a user without signing them in.
      // This is better for seeding than signUp().
      final createdUser = await supabase.auth.admin.createUser(
          AdminUserAttributes(
            email: user['email'],
            password: user['password'],
            // The `data` field here becomes `raw_user_meta_data` in your trigger.
            userMetadata: {
              'username': user['username'],
              'role': user['role']
            },
            emailConfirm: true, // Auto-confirm the email for simplicity.
          )
      );

      print('✅ Successfully created user: ${createdUser.user?.email}');

    } on AuthException catch (e) {
      print('❌ Error creating user ${user['email']}: ${e.message}');
    } catch (e) {
      print('❌ An unexpected error occurred for user ${user['email']}: $e');
    }
  }

  print('\nSeeding complete!');
  exit(0);
}