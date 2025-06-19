// lib/pages/login_page.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dashboard_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  static const String routeName = '/login';

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _passwordVisible = false; // Untuk mengganti visibilitas password

  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _redirectOnSession();
  }

  /// Memeriksa sesi aktif dan mengarahkan ke dashboard jika ditemukan.
  Future<void> _redirectOnSession() async {
    // Memberi sedikit jeda untuk memastikan widget sudah siap
    await Future.delayed(Duration.zero);

    if (!mounted) return;

    try {
      final session = _supabase.auth.currentSession;
      if (session != null) {
        // Jika sesi ditemukan, ambil data profil pengguna
        final profileResponse = await _supabase
            .from('profiles')
            .select()
            .eq('id', session.user.id)
            .single();

        // Alihkan ke halaman dashboard dengan membawa data pengguna
        Navigator.pushReplacementNamed(
          context,
          DashboardPage.routeName,
          arguments: {
            ...profileResponse,
            'email': session.user.email,
          },
        );
      }
    } catch (e) {
      // Jika terjadi error (misal: profil tidak ditemukan), biarkan pengguna di halaman login.
    }
  }

  Future<void> _handleAuth() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // --- PROSES MASUK ---
      await _supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (mounted) {
        // Ambil profil pengguna setelah berhasil otentikasi
        final userId = _supabase.auth.currentUser!.id;

        // **PERBAIKAN**: Gunakan .maybeSingle() untuk mencegah error jika profil hilang.
        final profileResponse = await _supabase
            .from('profiles')
            .select()
            .eq('id', userId)
            .maybeSingle();

        // **PERBAIKAN**: Periksa apakah profil ada sebelum navigasi.
        if (profileResponse == null) {
          throw const PostgrestException(
            message:
            'Login berhasil, tetapi profil pengguna tidak ditemukan. Silakan hubungi administrator.',
          );
        }

        // Navigasi ke dashboard dengan data pengguna dan profil
        Navigator.pushReplacementNamed(
          context,
          DashboardPage.routeName,
          arguments: {
            ...profileResponse, // Berisi id, username, role
            'email':
            _supabase.auth.currentUser!.email, // Tambahkan email dari auth user
          },
        );
      }
    } on AuthException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal masuk: ${error.message}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } on PostgrestException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.message),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan tidak terduga: $error'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _forgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Silakan masukkan email Anda untuk mereset kata sandi.')),
      );
      return;
    }
    try {
      await _supabase.auth.resetPasswordForEmail(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Tautan reset kata sandi telah dikirim! Periksa email Anda.')),
        );
      }
    } on AuthException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.message),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Icon(
                  Icons.lock_outline,
                  size: 80,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 20),
                Text(
                  'Selamat Datang Kembali!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Masuk untuk melanjutkan',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 40),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'Masukkan email Anda',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        !value.contains('@')) {
                      return 'Harap masukkan email yang valid';
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 20.0),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Kata Sandi',
                    hintText: 'Masukkan kata sandi Anda',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _passwordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _passwordVisible = !_passwordVisible;
                        });
                      },
                    ),
                  ),
                  obscureText: !_passwordVisible,
                  validator: (value) {
                    if (value == null || value.isEmpty || value.length < 6) {
                      return 'Kata sandi minimal 6 karakter';
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) => _handleAuth(),
                  textInputAction: TextInputAction.done,
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _forgotPassword,
                      child: Text(
                        'Lupa Kata Sandi?',
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20.0),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                  onPressed: _handleAuth,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    textStyle:
                    const TextStyle(fontSize: 18, color: Colors.black),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Masuk'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}