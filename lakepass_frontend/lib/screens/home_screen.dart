import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';
import '../services/auth_provider.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'operator_dashboard.dart';
import 'customer_dashboard.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('LakePass', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: AppColors.primary)),
        centerTitle: false,
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          if (!auth.isAuthenticated) ...[
            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
              },
              child: const Text('Login', style: TextStyle(color: AppColors.textPrimary, fontSize: 16)),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.background,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Sign Up', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 16),
          ] else ...[
            TextButton(
              onPressed: () {
                if (auth.role == 'operator') {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const OperatorDashboard()));
                } else {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerDashboard()));
                }
              },
              child: const Text('Dashboard', style: TextStyle(color: AppColors.primary, fontSize: 16)),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text('Hi, ${auth.name ?? "User"}', style: const TextStyle(color: AppColors.textPrimary, fontSize: 16)),
              ),
            ),
            TextButton(
              onPressed: () {
                auth.logout();
              },
              child: const Text('Logout', style: TextStyle(color: AppColors.error, fontSize: 16)),
            ),
            const SizedBox(width: 16),
          ]
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.sailing, size: 80, color: AppColors.primary),
              const SizedBox(height: 24),
              const Text(
                'Find Your Perfect Marina Slip',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Book instantly. No hidden fees. Enjoy the water.',
                style: TextStyle(
                  fontSize: 20,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 48),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                width: 500,
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Search Marinas (e.g. Miami, FL)',
                        hintStyle: TextStyle(color: AppColors.textSecondary),
                        prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => SearchScreen(initialQuery: _searchController.text)));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.background,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Search Availability', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
