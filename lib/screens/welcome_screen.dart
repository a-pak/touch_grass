import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:touch_grass/controllers/home_tab_controller.dart';
import 'package:touch_grass/screens/home_screen.dart';
import 'package:touch_grass/services/login_service.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final LoginService _loginService = LoginService();
  bool _isRegisterMode = false;
  bool _isSubmitting = false;

  static final RegExp _usernamePattern = RegExp(r'^[a-zA-Z0-9_]+$');

  Future<void> _onLogin() async {
    final String username = _usernameController.text.trim();
    final String password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      _showSnackBar('Please enter a username and password');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _loginService.login(username: username, password: password);

      if (!mounted) {
        return;
      }

      homeTabIndexNotifier.value = 0;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const HomeScreen(title: 'Touch Grass'),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      _showSnackBar(_authErrorMessage(error));
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String? _validateRegisterFields() {
    final String username = _usernameController.text.trim();
    final String password = _passwordController.text.trim();

    if (username.length < 3 || username.length > 32) {
      return 'Username must be 3 to 32 characters long.';
    }

    if (!_usernamePattern.hasMatch(username)) {
      return 'Username can only contain letters, numbers, and underscores.';
    }

    if (password.length < 8 || password.length > 32) {
      return 'Password must be 8 to 32 characters long.';
    }

    return null;
  }

  Future<void> _onRegister() async {
    final String? validationError = _validateRegisterFields();
    if (validationError != null) {
      _showSnackBar(validationError);
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _loginService.register(
        username: _usernameController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isRegisterMode = false;
        _passwordController.clear();
      });

      _showSnackBar('Registration successful. You can now log in.');
    } catch (error) {
      if (!mounted) {
        return;
      }
      _showSnackBar(_authErrorMessage(error));
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _openRegisterView() {
    setState(() {
      _isRegisterMode = true;
    });
  }

  void _backToLoginView() {
    setState(() {
      _isRegisterMode = false;
      _passwordController.clear();
    });
  }

  String _authErrorMessage(Object error) {
    if (error is DioException) {
      final dynamic detail = error.response?.data;
      if (detail is Map<String, dynamic> && detail['detail'] is String) {
        return detail['detail'] as String;
      }
      return 'Could not reach the server. Please try again.';
    }
    return 'Something went wrong. Please try again.';
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/background.png', fit: BoxFit.cover),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Image.asset('assets/logo.png'),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Container(
                        padding: const EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Column(
                          children: [
                            const SizedBox(height: 16),
                            TextField(
                              controller: _usernameController,
                              decoration: const InputDecoration(
                                labelText: 'Username',
                                hintText: 'Enter your name',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.person),
                              ),
                              onSubmitted: (_) =>
                                  _isRegisterMode ? _onRegister() : _onLogin(),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                labelText: 'Password',
                                hintText: 'Enter your password',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.lock),
                              ),
                              onSubmitted: (_) =>
                                  _isRegisterMode ? _onRegister() : _onLogin(),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: _isSubmitting
                                  ? null
                                  : (_isRegisterMode ? _onRegister : _onLogin),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                              child: _isSubmitting
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      _isRegisterMode ? 'Register' : 'Login',
                                    ),
                            ),
                            const SizedBox(height: 8),
                            if (!_isRegisterMode)
                              TextButton(
                                onPressed: _isSubmitting
                                    ? null
                                    : _openRegisterView,
                                child: const Text('Register as a new user'),
                              ),
                            if (_isRegisterMode)
                              TextButton(
                                onPressed: _isSubmitting
                                    ? null
                                    : _backToLoginView,
                                child: const Text('Back'),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
