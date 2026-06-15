import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import '../utils/constants.dart';
import '../widgets/sea_background.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _role = 'customer';
  bool _isLoading = false;
  String? _errorMessage;

  void _submit() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final success = await Provider.of<AuthProvider>(context, listen: false).register(
      _nameController.text,
      _emailController.text,
      _passwordController.text,
      _role,
    );

    if (success && mounted) {
      Navigator.pop(context); // Go back
    } else {
      setState(() {
        _errorMessage = 'Registration failed. Please try again.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Create Account', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SeaBackground(
        useGlassmorphism: true,
        glassMaxWidth: 450,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.person_add, size: 60, color: AppColors.primary),
            const SizedBox(height: 16),
            const Text('Join LakePass', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 24),
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.error.withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.error),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_errorMessage!, style: const TextStyle(color: Colors.white))),
                  ],
                ),
              ),
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Full Name',
                labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
                prefixIcon: const Icon(Icons.person, color: Colors.white70),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                filled: true,
                fillColor: Colors.black.withOpacity(0.2),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
                prefixIcon: const Icon(Icons.email, color: Colors.white70),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                filled: true,
                fillColor: Colors.black.withOpacity(0.2),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
                prefixIcon: const Icon(Icons.lock, color: Colors.white70),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                filled: true,
                fillColor: Colors.black.withOpacity(0.2),
              ),
            ),
            const SizedBox(height: 16),
            Theme(
              data: Theme.of(context).copyWith(
                canvasColor: AppColors.surface, // Background for dropdown items
              ),
              child: DropdownButtonFormField<String>(
                value: _role,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Account Type',
                  labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
                  prefixIcon: const Icon(Icons.badge, color: Colors.white70),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  filled: true,
                  fillColor: Colors.black.withOpacity(0.2),
                ),
                items: const [
                  DropdownMenuItem(value: 'customer', child: Text('Customer', style: TextStyle(color: Colors.white))),
                  DropdownMenuItem(value: 'operator', child: Text('Marina Operator', style: TextStyle(color: Colors.white))),
                ],
                onChanged: (val) {
                  setState(() {
                    _role = val!;
                  });
                },
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.background,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 8,
                ),
                child: _isLoading ? const CircularProgressIndicator(color: AppColors.background) : const Text('Sign Up', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
              },
              child: const Text('Already have an account? Login', style: TextStyle(color: Colors.white70, fontSize: 16)),
            )
          ],
        ),
      ),
    );
  }
}
