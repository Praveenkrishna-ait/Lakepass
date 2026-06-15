import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';
import '../services/auth_provider.dart';
import '../services/marina_service.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'operator_dashboard.dart';
import 'customer_dashboard.dart';
import 'search_screen.dart';
import 'marina_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  List<dynamic> _marinas = [];
  bool _isLoadingMarinas = true;

  @override
  void initState() {
    super.initState();
    _fetchFeaturedMarinas();
  }

  Future<void> _fetchFeaturedMarinas() async {
    final marinas = await MarinaService.getAllMarinas();
    if (mounted) {
      setState(() {
        _marinas = marinas;
        _isLoadingMarinas = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('LakePass', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: AppColors.primary)),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (!auth.isAuthenticated) ...[
            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
              },
              child: const Text('Login', style: TextStyle(color: Colors.white, fontSize: 16)),
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
              child: const Text('Dashboard', style: TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text('Hi, ${auth.name ?? "User"}', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            TextButton(
              onPressed: () {
                auth.logout();
              },
              child: const Text('Logout', style: TextStyle(color: AppColors.error, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 16),
          ]
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Stunning Sea Background Image
          Image.network(
            'https://images.unsplash.com/photo-1544551763-46a013bb70d5?q=80&w=2070&auto=format&fit=crop',
            fit: BoxFit.cover,
          ),
          // Dark Gradient Overlay for text readability
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.background.withOpacity(0.8),
                  AppColors.background.withOpacity(0.3),
                  AppColors.background.withOpacity(0.7),
                ],
              ),
            ),
          ),
          // Main Content
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 80), // Increased top spacer to push content down properly from AppBar
                  const Icon(Icons.sailing, size: 56, color: AppColors.primary),
                  const SizedBox(height: 12),
                  const Text(
                    'Find Your Perfect Marina Slip',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Book instantly. No hidden fees. Enjoy the water.',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Glassmorphism Search Card
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.surface.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
                        ),
                        width: 600,
                        child: Column(
                          children: [
                            SizedBox(
                              height: 50,
                              child: TextField(
                                controller: _searchController,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: 'Search Marinas (e.g. Miami, FL)',
                                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                                  prefixIcon: const Icon(Icons.search, color: Colors.white70),
                                  filled: true,
                                  fillColor: Colors.black.withOpacity(0.2),
                                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => SearchScreen(initialQuery: _searchController.text)));
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: AppColors.background,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  elevation: 8,
                                ),
                                child: const Text('Search Availability', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 60), // Increased space to move Featured Marinas further below
                  // Popular Marinas Section
                  if (_marinas.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Featured Marinas',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 260, // Restored vertical height for better card proportion
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        itemCount: _marinas.length > 5 ? 5 : _marinas.length,
                        itemBuilder: (context, index) {
                          final marina = _marinas[index];
                          final List<String> marinaImages = [
                            'https://images.unsplash.com/photo-1567899378494-47b22a2ae96a?w=600&auto=format&fit=crop',
                            'https://images.unsplash.com/photo-1549693578-d683be217e58?w=600&auto=format&fit=crop',
                            'https://images.unsplash.com/photo-1500514966906-fe245eea9344?w=600&auto=format&fit=crop',
                            'https://images.unsplash.com/photo-1544551763-77ef2d0cfc6c?w=600&auto=format&fit=crop',
                            'https://images.unsplash.com/photo-1520490182-41ee35bb4a27?w=600&auto=format&fit=crop',
                          ];
                          final imageUrl = marinaImages[index % marinaImages.length];

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => MarinaDetailsScreen(marina: marina)));
                            },
                            child: Container(
                              width: 320, // Adjusted width for better landscape proportion
                              margin: const EdgeInsets.only(right: 20),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.network(imageUrl, fit: BoxFit.cover,
                                      errorBuilder: (ctx, err, st) => Container(color: AppColors.surface)),
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Text(marina['name'], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                                          const SizedBox(height: 4),
                                          Row(children: [
                                            const Icon(Icons.location_on, color: AppColors.primary, size: 16),
                                            const SizedBox(width: 4),
                                            Text(marina['location'] ?? '', style: const TextStyle(color: Colors.white70, fontSize: 14)),
                                          ]),
                                          const SizedBox(height: 12),
                                          SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton(
                                              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MarinaDetailsScreen(marina: marina))),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: AppColors.primary,
                                                foregroundColor: AppColors.background,
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                padding: const EdgeInsets.symmetric(vertical: 10),
                                              ),
                                              child: const Text('View Slips', style: TextStyle(fontWeight: FontWeight.bold)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 40),
                  ]
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
