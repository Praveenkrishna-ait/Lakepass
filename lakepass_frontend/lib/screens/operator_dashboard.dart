import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import '../services/marina_service.dart';
import '../utils/constants.dart';
import '../widgets/sea_background.dart';
import 'manage_slips_screen.dart';
import 'analytics_screen.dart';

class OperatorDashboard extends StatefulWidget {
  const OperatorDashboard({super.key});

  @override
  State<OperatorDashboard> createState() => _OperatorDashboardState();
}

class _OperatorDashboardState extends State<OperatorDashboard> {
  bool _isLoading = true;
  List<dynamic> _myMarinas = [];

  final _nameController = TextEditingController();
  final _locController = TextEditingController();
  final _descController = TextEditingController();

  final List<String> _marinaImages = [
    'https://images.unsplash.com/photo-1567899378494-47b22a2ae96a?w=600&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1549693578-d683be217e58?w=600&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1500514966906-fe245eea9344?w=600&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1544551763-77ef2d0cfc6c?w=600&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1520490182-41ee35bb4a27?w=600&auto=format&fit=crop',
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _fetchMarinas());
  }

  Future<void> _fetchMarinas() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final allMarinas = await MarinaService.getAllMarinas();
    setState(() {
      _myMarinas = allMarinas.where((m) => m['operator_id'].toString() == auth.userId.toString()).toList();
      _isLoading = false;
    });
  }

  void _createMarina() async {
    if (_nameController.text.isEmpty) return;
    setState(() => _isLoading = true);
    await MarinaService.createMarina(_nameController.text, _locController.text, _descController.text);
    _nameController.clear();
    _locController.clear();
    _descController.clear();
    _fetchMarinas();
  }

  Widget _glassField(TextEditingController controller, String label, IconData icon, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
        prefixIcon: Icon(icon, color: Colors.white70),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        filled: true,
        fillColor: Colors.black.withOpacity(0.2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Operator Dashboard', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SeaBackground(
        child: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left panel: glassmorphism form
                  SizedBox(
                    width: 300,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.surface.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withOpacity(0.2)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('Register New Marina',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                              const SizedBox(height: 16),
                              _glassField(_nameController, 'Marina Name', Icons.anchor),
                              const SizedBox(height: 12),
                              _glassField(_locController, 'Location', Icons.location_on),
                              const SizedBox(height: 12),
                              _glassField(_descController, 'Description', Icons.description, maxLines: 3),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: _createMarina,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: AppColors.background,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: const Text('Create Marina', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  // Right panel: image-based marina cards
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Your Marinas',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 16),
                        if (_myMarinas.isEmpty)
                          const Text('You have not created any marinas yet.', style: TextStyle(color: Colors.white70)),
                        Expanded(
                          child: GridView.builder(
                            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 380,
                              mainAxisExtent: 260,
                              crossAxisSpacing: 20,
                              mainAxisSpacing: 20,
                            ),
                            itemCount: _myMarinas.length,
                            itemBuilder: (context, index) {
                              final marina = _myMarinas[index];
                              final imageUrl = _marinaImages[index % _marinaImages.length];
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(20),
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
                                          colors: [Colors.transparent, Colors.black.withOpacity(0.85)],
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Text(marina['name'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                                          const SizedBox(height: 4),
                                          Row(children: [
                                            const Icon(Icons.location_on, color: AppColors.primary, size: 14),
                                            const SizedBox(width: 4),
                                            Text(marina['location'] ?? '', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                                          ]),
                                          const SizedBox(height: 12),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: OutlinedButton(
                                                  onPressed: () => Navigator.push(context, MaterialPageRoute(
                                                    builder: (_) => AnalyticsScreen(marinaId: marina['id'], marinaName: marina['name']))),
                                                  style: OutlinedButton.styleFrom(
                                                    foregroundColor: Colors.white,
                                                    side: const BorderSide(color: Colors.white54),
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                  ),
                                                  child: const Text('Analytics'),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: ElevatedButton(
                                                  onPressed: () => Navigator.push(context, MaterialPageRoute(
                                                    builder: (_) => ManageSlipsScreen(marinaId: marina['id'], marinaName: marina['name']))),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: AppColors.primary,
                                                    foregroundColor: AppColors.background,
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                  ),
                                                  child: const Text('Manage', style: TextStyle(fontWeight: FontWeight.bold)),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
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
  }
}
