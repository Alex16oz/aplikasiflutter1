// lib/pages/user_profile_page.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/app_drawer.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  static const String routeName = '/user-profile';

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final _supabase = Supabase.instance.client;

  String _userId = '...';
  String _username = '...';
  String _email = '...';

  // Form keys
  final _passwordFormKey = GlobalKey<FormState>();
  final _usernameFormKey = GlobalKey<FormState>();
  final _emailFormKey = GlobalKey<FormState>();

  // Controllers
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _newUsernameController = TextEditingController();
  final _newEmailController = TextEditingController();

  // Visibility toggles
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Safely get arguments passed from another page
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      setState(() {
        _userId = args['id'] ?? '...';
        _username = args['username'] ?? '...';
        _email = args['email'] ?? '...';
      });
    }
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _newUsernameController.dispose();
    _newEmailController.dispose();
    super.dispose();
  }

  // --- Dialog for changing password ---
  Future<void> _showEditPasswordDialog() async {
    _passwordFormKey.currentState?.reset();
    _newPasswordController.clear();
    _confirmPasswordController.clear();
    setState(() {
      _isNewPasswordVisible = false;
      _isConfirmPasswordVisible = false;
    });

    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Edit Password'),
            content: Form(
              key: _passwordFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _newPasswordController,
                    decoration: InputDecoration(
                      labelText: 'New Password',
                      suffixIcon: IconButton(
                        icon: Icon(_isNewPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: () => setDialogState(
                                () => _isNewPasswordVisible = !_isNewPasswordVisible),
                      ),
                    ),
                    obscureText: !_isNewPasswordVisible,
                    validator: (value) {
                      if (value == null || value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Confirm New Password',
                      suffixIcon: IconButton(
                        icon: Icon(_isConfirmPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: () => setDialogState(() =>
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                      ),
                    ),
                    obscureText: !_isConfirmPasswordVisible,
                    validator: (value) {
                      if (value != _newPasswordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () async {
                  if (_passwordFormKey.currentState!.validate()) {
                    try {
                      await _supabase.auth.updateUser(UserAttributes(
                          password: _newPasswordController.text));
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text('Password changed successfully!')));
                        Navigator.of(dialogContext).pop();
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Failed to change password: $e'),
                            backgroundColor: Colors.red));
                      }
                    }
                  }
                },
                child: const Text('Save'),
              ),
            ],
          );
        });
      },
    );
  }

  // --- Dialog for changing username ---
  Future<void> _showEditUsernameDialog() async {
    _newUsernameController.text = _username;
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Edit Username'),
          content: Form(
            key: _usernameFormKey,
            child: TextFormField(
              controller: _newUsernameController,
              decoration: const InputDecoration(labelText: 'New Username'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a username';
                }
                return null;
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (_usernameFormKey.currentState!.validate()) {
                  try {
                    await _supabase.from('profiles').update(
                        {'username': _newUsernameController.text}).eq('id', _userId);
                    if (mounted) {
                      setState(() {
                        _username = _newUsernameController.text;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Username updated!')));
                      Navigator.of(dialogContext).pop();
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Failed to update username: $e'),
                          backgroundColor: Colors.red));
                    }
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // --- Dialog for changing email ---
  Future<void> _showEditEmailDialog() async {
    _newEmailController.text = _email;
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Edit Email'),
          content: Form(
            key: _emailFormKey,
            child: TextFormField(
              controller: _newEmailController,
              decoration: const InputDecoration(labelText: 'New Email'),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || !value.contains('@')) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (_emailFormKey.currentState!.validate()) {
                  try {
                    await _supabase.auth.updateUser(
                        UserAttributes(email: _newEmailController.text));
                    if (mounted) {
                      setState(() {
                        _email = _newEmailController.text;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text(
                              'Confirmation links sent to both old and new emails.')));
                      Navigator.of(dialogContext).pop();
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Failed to update email: $e'),
                          backgroundColor: Colors.red));
                    }
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Dropdown options for editing profile
    final List<String> editOptions = ['Edit Username', 'Edit Password', 'Edit Email'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
      ),
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Card(
              elevation: 4.0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: <Widget>[
                    const CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage('https://via.placeholder.com/150'), // Placeholder image
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          _buildUserInfoRow(
                              icon: Icons.person,
                              label: 'Username:',
                              value: _username),
                          const SizedBox(height: 8.0),
                          _buildUserInfoRow(
                              icon: Icons.email,
                              label: 'Email:',
                              value: _email),
                          const SizedBox(height: 8.0),
                          _buildUserInfoRow(
                              icon: Icons.lock,
                              label: 'Password:',
                              value: '********'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    hint: const Text('Edit Profile', style: TextStyle(color: Colors.black)),
                    icon: const Icon(Icons.edit, color: Colors.black),
                    onChanged: (String? newValue) {
                      if (newValue == 'Edit Username') _showEditUsernameDialog();
                      if (newValue == 'Edit Password') _showEditPasswordDialog();
                      if (newValue == 'Edit Email') _showEditEmailDialog();
                    },
                    items: editOptions.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
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

  Widget _buildUserInfoRow(
      {required IconData icon, required String label, required String value}) {
    return Row(
      children: <Widget>[
        Icon(icon, size: 20.0, color: Colors.grey[700]),
        const SizedBox(width: 8.0),
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 8.0),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 16),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}