// lib/pages/user_profile_page.dart
import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart'; // Import the AppDrawer

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  static const String routeName = '/user-profile';

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final List<String> _editOptions = [
    'Edit Password',
    'Edit Username',
    'Edit Email'
  ];

  // State variables for user profile data displayed on the card
  String _userId = 'user123'; // Assuming UserID is not editable for now
  String _username = 'john_doe';
  String _email = 'john.doe@example.com';
  // Password is not displayed directly, so no state variable for it here

  // Controllers for forms
  final _passwordFormKey = GlobalKey<FormState>();
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final _usernameFormKey = GlobalKey<FormState>();
  final TextEditingController _newUsernameController = TextEditingController();

  final _emailFormKey = GlobalKey<FormState>();
  final TextEditingController _newEmailController = TextEditingController();

  // State variables for password visibility
  bool _isCurrentPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;


  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _newUsernameController.dispose();
    _newEmailController.dispose();
    super.dispose();
  }

  Future<void> _showEditPasswordDialog() async {
    // Reset visibility states when dialog is opened
    setState(() {
      _isCurrentPasswordVisible = false;
      _isNewPasswordVisible = false;
      _isConfirmPasswordVisible = false;
    });
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button!
      builder: (BuildContext dialogContext) {
        // Use StatefulBuilder to manage state within the dialog (for password visibility)
        return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: const Text('Edit Password'),
                content: SingleChildScrollView(
                  child: Form(
                    key: _passwordFormKey,
                    child: ListBody(
                      children: <Widget>[
                        TextFormField(
                          controller: _currentPasswordController,
                          decoration: InputDecoration(
                            labelText: 'Current Password',
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isCurrentPasswordVisible ? Icons.visibility : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setDialogState(() {
                                  _isCurrentPasswordVisible = !_isCurrentPasswordVisible;
                                });
                              },
                            ),
                          ),
                          obscureText: !_isCurrentPasswordVisible,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter current password';
                            }
                            // TODO: Add validation against actual current password
                            if (value != "password") { // Example current password
                              return 'Incorrect current password';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _newPasswordController,
                          decoration: InputDecoration(
                            labelText: 'New Password',
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isNewPasswordVisible ? Icons.visibility : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setDialogState(() {
                                  _isNewPasswordVisible = !_isNewPasswordVisible;
                                });
                              },
                            ),
                          ),
                          obscureText: !_isNewPasswordVisible,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter new password';
                            }
                            if (value.length < 6) {
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
                              icon: Icon(
                                _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setDialogState(() {
                                  _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                                });
                              },
                            ),
                          ),
                          obscureText: !_isConfirmPasswordVisible,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm new password';
                            }
                            if (value != _newPasswordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Cancel'),
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      _clearPasswordControllers();
                    },
                  ),
                  ElevatedButton(
                    child: const Text('Save'),
                    onPressed: () {
                      if (_passwordFormKey.currentState!.validate()) {
                        // TODO: Implement password change logic with backend
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Password successfully changed (simulated)')),
                        );
                        Navigator.of(dialogContext).pop();
                        _clearPasswordControllers();
                      }
                    },
                  ),
                ],
              );
            }
        );
      },
    );
  }

  void _clearPasswordControllers() {
    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();
  }

  Future<void> _showEditUsernameDialog() async {
    _newUsernameController.text = _username; // Pre-fill with current username
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Edit Username'),
          content: SingleChildScrollView(
            child: Form(
              key: _usernameFormKey,
              child: ListBody(
                children: <Widget>[
                  TextFormField(
                    controller: _newUsernameController,
                    decoration: const InputDecoration(labelText: 'New Username'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter new username';
                      }
                      if (value.length < 3) {
                        return 'Username must be at least 3 characters';
                      }
                      // TODO: Add further username validation (e.g., availability)
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _newUsernameController.clear();
              },
            ),
            ElevatedButton(
              child: const Text('Save'),
              onPressed: () {
                if (_usernameFormKey.currentState!.validate()) {
                  // Implement username change logic
                  setState(() {
                    _username = _newUsernameController.text;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Username changed to: $_username')),
                  );
                  Navigator.of(dialogContext).pop();
                  // _newUsernameController.clear(); // No need to clear if pre-filled and successfully saved
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditEmailDialog() async {
    _newEmailController.text = _email; // Pre-fill with current email
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Edit Email'),
          content: SingleChildScrollView(
            child: Form(
              key: _emailFormKey,
              child: ListBody(
                children: <Widget>[
                  TextFormField(
                    controller: _newEmailController,
                    decoration: const InputDecoration(labelText: 'New Email'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter new email';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }
                      // TODO: Add further email validation (e.g., availability)
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _newEmailController.clear();
              },
            ),
            ElevatedButton(
              child: const Text('Save'),
              onPressed: () {
                if (_emailFormKey.currentState!.validate()) {
                  // Implement email change logic
                  setState(() {
                    _email = _newEmailController.text;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Email changed to: $_email')),
                  );
                  Navigator.of(dialogContext).pop();
                  // _newEmailController.clear(); // No need to clear if pre-filled and successfully saved
                }
              },
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage('https://via.placeholder.com/150'),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          _buildUserInfoRow(icon: Icons.account_circle, label: 'UserID:', value: _userId),
                          const SizedBox(height: 8.0),
                          _buildUserInfoRow(icon: Icons.person, label: 'Username:', value: _username),
                          const SizedBox(height: 8.0),
                          _buildUserInfoRow(icon: Icons.lock, label: 'Password:', value: '********'), // Password display remains masked
                          const SizedBox(height: 8.0),
                          _buildUserInfoRow(icon: Icons.email, label: 'Email:', value: _email),
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
                    hint: const Text(
                      'Edit Profile',
                      style: TextStyle(color: Colors.black),
                    ),
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
                    iconSize: 24,
                    dropdownColor: Theme.of(context).primaryColorLight,
                    style: const TextStyle(color: Colors.black, fontSize: 16),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        // Clear password controllers specifically before opening password dialog
                        if (newValue == 'Edit Password') {
                          _clearPasswordControllers();
                          _showEditPasswordDialog();
                        } else if (newValue == 'Edit Username') {
                          _showEditUsernameDialog();
                        } else if (newValue == 'Edit Email') {
                          _showEditEmailDialog();
                        }
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
                            Icon(iconData, color: Colors.black54, size: 20),
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