import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../themes/color.dart';
import '../widgets/success_auth.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  void _toggleVisibility(bool isConfirm) {
    setState(() {
      if (isConfirm) {
        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
      } else {
        _isPasswordVisible = !_isPasswordVisible;
      }
    });
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => SuccessDialog(
            imagePath: 'assets/images/happy_star.png',
            title: 'Congratulations',
            message: 'You are now registered!',
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
    );
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final response = await http.post(
      Uri.parse('http://localhost:8000/api/auth/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'password': _passwordController.text.trim(),
        'confirm_password': _confirmPasswordController.text.trim(),
      }),
    );

    setState(() => _isLoading = false);

    if (response.statusCode == 200) {
      _showSuccessDialog(context);
    } else {
      final error = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error['detail'] ?? 'Signup failed.')),
      );
    }
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool isPassword = false,
    bool isVisible = false,
    void Function()? onToggle,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && !isVisible,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon:
            isPassword
                ? IconButton(
                  icon: Icon(
                    isVisible ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: onToggle,
                )
                : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: Colors.grey,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Create an Account",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 24),
                  _buildTextField(
                    label: "Name",
                    controller: _nameController,
                    validator:
                        (value) =>
                            value == null || value.trim().isEmpty
                                ? "Name is required"
                                : null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: "Email",
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty)
                        return "Email is required";
                      final emailRegex = RegExp(
                        r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}\$",
                      );
                      if (!emailRegex.hasMatch(value.trim()))
                        return "Enter a valid email";
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: "Password",
                    controller: _passwordController,
                    isPassword: true,
                    isVisible: _isPasswordVisible,
                    onToggle: () => _toggleVisibility(false),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty)
                        return "Password is required";
                      if (value.trim().length < 8)
                        return "Minimum 8 characters";
                      if (!RegExp(r'[A-Z]').hasMatch(value))
                        return "Must contain an uppercase letter";
                      if (!RegExp(r'[a-z]').hasMatch(value))
                        return "Must contain a lowercase letter";
                      if (!RegExp(r'[0-9]').hasMatch(value))
                        return "Must contain a number";
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: "Confirm Password",
                    controller: _confirmPasswordController,
                    isPassword: true,
                    isVisible: _isConfirmPasswordVisible,
                    onToggle: () => _toggleVisibility(true),
                    validator:
                        (value) =>
                            value != _passwordController.text
                                ? "Passwords do not match"
                                : null,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _signup,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: AppColors.primaryColor,
                    ),
                    child:
                        _isLoading
                            ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation(
                                  Colors.white,
                                ),
                              ),
                            )
                            : const Text("Sign Up"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
