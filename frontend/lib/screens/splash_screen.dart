import 'package:flutter/material.dart';
import 'dart:async';
import '../api_routes/auth-repository.dart';

class LogoScreen extends StatefulWidget {
  const LogoScreen({super.key});

  @override
  State<LogoScreen> createState() => _LogoScreenState();
}

class _LogoScreenState extends State<LogoScreen> {
  final _authRepository = AuthRepository();
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    // Show logo for minimum of 3 seconds, then check auth and navigate
    Timer(const Duration(seconds: 3), () {
      if (mounted && !_hasNavigated) {
        _checkAuthAndNavigate();
      }
    });
  }

  Future<void> _checkAuthAndNavigate() async {
    if (_hasNavigated) return;
    _hasNavigated = true;

    try {
      // Get authentication token
      final token = await _authRepository.getToken();

      if (!mounted) return;

      if (token == null) {
        // No token, go to welcome screen
        Navigator.of(context).pushReplacementNamed('/welcome');
        return;
      }

      // We have a token, check user role
      final result = await _authRepository.checkAuthStatus();

      if (!mounted) return;

      if (result == null) {
        // Token is invalid, go to welcome screen
        Navigator.of(context).pushReplacementNamed('/welcome');
        return;
      }

      final user = result['user'];
      if (user != null && user.role == 'admin') {
        // Admin user goes to admin screen
        Navigator.of(context).pushReplacementNamed('/admin', arguments: user);
      } else {
        // Regular user goes to home screen
        Navigator.of(context).pushReplacementNamed('/home', arguments: user);
      }
    } catch (e) {
      print('Error during authentication check: $e');
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/welcome');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          // Apply the radial gradient
          gradient: RadialGradient(
            colors: [Color(0xFFF7B733), Color(0xFFFF7904)],
            center: Alignment.center,
            radius: 0.8,
            focal: Alignment.center,
            focalRadius: 0.2,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'assets/images/LOGO.png', // Replace with the actual path to your logo image
                width: 180, // Adjust the width of the logo
                height: 180, // Adjust the height of the logo
              ),
            ],
          ),
        ),
      ),
    );
  }
}
