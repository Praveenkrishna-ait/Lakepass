import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/marina_service.dart';
import '../utils/constants.dart';
import '../widgets/sea_background.dart';

class ManageSlipsScreen extends StatefulWidget {
  final int marinaId;
  final String marinaName;

  const ManageSlipsScreen({super.key, required this.marinaId, required this.marinaName});

  @override
  State<ManageSlipsScreen> createState() => _ManageSlipsScreenState();
}

class _ManageSlipsScreenState extends State<ManageSlipsScreen> {
  bool _isLoading = true;
  List<dynamic> _slips = [];

  final _nameController = TextEditingController();
  final _lengthController = TextEditingController();
  final _widthController = TextEditingController();
  final _priceController = TextEditingController();

  final List<String> _slipImages = [
    'https://images.unsplash.com/photo-1567899378494-47b22a2ae96a?w=600&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1549693578-d683be217e58?w=600&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1500514966906-fe245eea9344?w=600&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1544551763-77ef2d0cfc6c?w=600&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1520490182-41ee35bb4a27?w=600&auto=format&fit=crop',
  ];

  @override
  void initState() {
    super.initState();
    _fetchSlips();
  }

  Future<void> _fetchSlips() async {
    final slips = await MarinaService.getSlips(widget.marinaId);
    setState(() {
      _slips = slips;
      _isLoading = false;
    });
  }

  void _createSlip() async {
    if (_nameController.text.isEmpty || _priceController.text.isEmpty) return;
    setState(() => _isLoading = true);

    final length = int.tryParse(_lengthController.text) ?? 0;
    final width = int.tryParse(_widthController.text) ?? 0;
    final price = double.tryParse(_priceController.text) ?? 0.0;

    final result = await MarinaService.createSlip(widget.marinaId, _nameController.text, length, width, price);

    if (result != null && result['success'] == true) {
      _nameController.clear();
      _lengthController.clear();
      _widthController.clear();
      _priceController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Slip created successfully!'), backgroundColor: Colors.green),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result?['error'] ?? 'Failed to create slip'), backgroundColor: AppColors.error),
        );
      }
    }
    _fetchSlips();
  }

  Widget _glassField(TextEditingController controller, String label, IconData icon,
      {TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
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
        title: Text('Manage Slips: ${widget.marinaName}',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                              const Text('Add New Slip',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                              const SizedBox(height: 16),
                              _glassField(_nameController, 'Slip Name (e.g. A-12)', Icons.directions_boat),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(child: _glassField(_lengthController, 'Length (ft)', Icons.swap_horiz, keyboardType: TextInputType.number)),
                                  const SizedBox(width: 12),
                                  Expanded(child: _glassField(_widthController, 'Width (ft)', Icons.swap_vert, keyboardType: TextInputType.number)),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _glassField(_priceController, 'Price/night (₹)', Icons.currency_rupee, keyboardType: TextInputType.number),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: _createSlip,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: AppColors.background,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: const Text('Create Slip', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  // Right panel: image slip cards
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Current Slips',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 16),
                        if (_slips.isEmpty)
                          const Text('No slips added yet.', style: TextStyle(color: Colors.white70)),
                        Expanded(
                          child: GridView.builder(
                            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 340,
                              mainAxisExtent: 220,
                              crossAxisSpacing: 20,
                              mainAxisSpacing: 20,
                            ),
                            itemCount: _slips.length,
                            itemBuilder: (context, index) {
                              final slip = _slips[index];
                              final imageUrl = _slipImages[index % _slipImages.length];
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
                                      padding: const EdgeInsets.all(18),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Text(slip['name'],
                                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                                          const SizedBox(height: 4),
                                          Row(children: [
                                            const Icon(Icons.straighten, color: AppColors.primary, size: 14),
                                            const SizedBox(width: 4),
                                            Text('${slip['length']}ft × ${slip['width']}ft',
                                                style: const TextStyle(color: Colors.white70, fontSize: 13)),
                                          ]),
                                          const SizedBox(height: 4),
                                          Row(children: [
                                            const Icon(Icons.currency_rupee, color: AppColors.primary, size: 16),
                                            Text('${slip['price_per_night']}/night',
                                                style: const TextStyle(fontSize: 16, color: AppColors.primary, fontWeight: FontWeight.bold)),
                                          ]),
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
