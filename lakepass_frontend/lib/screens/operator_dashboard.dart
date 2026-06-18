import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import '../services/marina_service.dart';
import '../utils/constants.dart';
import 'manage_slips_screen.dart';
import 'analytics_screen.dart';
import '../widgets/glass_card.dart';

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

  Widget _inputField(TextEditingController controller, String label, IconData icon, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Enter $label',
            hintStyle: const TextStyle(color: AppColors.textMuted),
            prefixIcon: Icon(icon, color: AppColors.textMuted, size: 20),
            filled: true,
            fillColor: AppColors.backgroundAlt,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundAlt,
      appBar: AppBar(
        title: const Text('Operator Dashboard', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        backgroundColor: AppColors.background,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(height: 1, color: AppColors.border)),
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
        : Padding(
            padding: const EdgeInsets.all(32.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left panel: form
                SizedBox(
                  width: 340,
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(children: [
                          Container(width: 20, height: 3, decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(2))),
                          const SizedBox(width: 10),
                          const Text('NEW MARINA', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.accent, letterSpacing: 1.5)),
                        ]),
                        const SizedBox(height: 12),
                        const Text('Register Marina', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.5)),
                        const SizedBox(height: 24),
                        _inputField(_nameController, 'Marina Name', Icons.anchor),
                        const SizedBox(height: 16),
                        _inputField(_locController, 'Location', Icons.location_on),
                        const SizedBox(height: 16),
                        _inputField(_descController, 'Description', Icons.description, maxLines: 3),
                        const SizedBox(height: 28),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _createMarina,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.cta,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                            child: const Text('Create Marina', style: TextStyle(fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 32),
                // Right panel: marinas
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Container(width: 20, height: 3, decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(2))),
                        const SizedBox(width: 10),
                        const Text('PORTFOLIO', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.accent, letterSpacing: 1.5)),
                      ]),
                      const SizedBox(height: 12),
                      const Text('Your Marinas', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.5)),
                      const SizedBox(height: 24),
                      if (_myMarinas.isEmpty)
                        const Text('You have not created any marinas yet.', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                      Expanded(
                        child: GridView.builder(
                          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 400,
                            mainAxisExtent: 340,
                            crossAxisSpacing: 24,
                            mainAxisSpacing: 24,
                          ),
                          itemCount: _myMarinas.length,
                          itemBuilder: (context, index) {
                            final marina = _myMarinas[index];
                            final imageUrl = _marinaImages[index % _marinaImages.length];
                            return TweenAnimationBuilder(
                              tween: Tween<double>(begin: 0, end: 1),
                              duration: Duration(milliseconds: 400 + (index * 80)),
                              curve: Curves.easeOutCubic,
                              builder: (context, double value, child) => Transform.translate(
                                offset: Offset(0, 30 * (1 - value)), child: Opacity(opacity: value, child: child)),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.border),
                                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Image.network(imageUrl, width: double.infinity, fit: BoxFit.cover,
                                          errorBuilder: (ctx, err, st) => Container(color: AppColors.backgroundAlt)),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(marina['name'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                                          const SizedBox(height: 6),
                                          Row(children: [
                                            const Icon(Icons.location_on, color: AppColors.accent, size: 14),
                                            const SizedBox(width: 4),
                                            Text(marina['location'] ?? '', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                                          ]),
                                          const SizedBox(height: 16),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: OutlinedButton(
                                                  onPressed: () => Navigator.push(context, MaterialPageRoute(
                                                    builder: (_) => AnalyticsScreen(marinaId: marina['id'], marinaName: marina['name']))),
                                                  style: OutlinedButton.styleFrom(
                                                    foregroundColor: AppColors.textPrimary,
                                                    side: const BorderSide(color: AppColors.border),
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                                  ),
                                                  child: const Text('Analytics'),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: ElevatedButton(
                                                  onPressed: () => Navigator.push(context, MaterialPageRoute(
                                                    builder: (_) => ManageSlipsScreen(marinaId: marina['id'], marinaName: marina['name']))),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: AppColors.cta,
                                                    foregroundColor: Colors.white,
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                                    elevation: 0,
                                                  ),
                                                  child: const Text('Manage', style: TextStyle(fontWeight: FontWeight.w700)),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
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
    );
  }
}
