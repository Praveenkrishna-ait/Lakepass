import 'package:flutter/material.dart';
import '../services/marina_service.dart';
import '../utils/constants.dart';

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

  Widget _inputField(TextEditingController controller, String label, IconData icon, {TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
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
        title: Text('Manage Slips: ${widget.marinaName}', style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
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
                          const Text('NEW SLIP', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.accent, letterSpacing: 1.5)),
                        ]),
                        const SizedBox(height: 12),
                        const Text('Add Slip Details', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.5)),
                        const SizedBox(height: 24),
                        _inputField(_nameController, 'Slip Name (e.g. A-12)', Icons.directions_boat),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: _inputField(_lengthController, 'Length (ft)', Icons.swap_horiz, keyboardType: TextInputType.number)),
                            const SizedBox(width: 12),
                            Expanded(child: _inputField(_widthController, 'Width (ft)', Icons.swap_vert, keyboardType: TextInputType.number)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _inputField(_priceController, 'Price/night (\$)', Icons.attach_money, keyboardType: TextInputType.number),
                        const SizedBox(height: 28),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _createSlip,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.cta,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                            child: const Text('Create Slip', style: TextStyle(fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 32),
                // Right panel: slips
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Container(width: 20, height: 3, decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(2))),
                        const SizedBox(width: 10),
                        const Text('INVENTORY', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.accent, letterSpacing: 1.5)),
                      ]),
                      const SizedBox(height: 12),
                      const Text('Current Slips', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.5)),
                      const SizedBox(height: 24),
                      if (_slips.isEmpty)
                        const Text('No slips added yet.', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                      Expanded(
                        child: GridView.builder(
                          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 360,
                            mainAxisExtent: 280,
                            crossAxisSpacing: 24,
                            mainAxisSpacing: 24,
                          ),
                          itemCount: _slips.length,
                          itemBuilder: (context, index) {
                            final slip = _slips[index];
                            final imageUrl = _slipImages[index % _slipImages.length];
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
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(slip['name'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                                              Text('\$${slip['price_per_night']}/night', style: const TextStyle(fontSize: 16, color: AppColors.textPrimary, fontWeight: FontWeight.w800)),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Row(children: [
                                            const Icon(Icons.straighten, color: AppColors.textSecondary, size: 14),
                                            const SizedBox(width: 4),
                                            Text('${slip['length']}ft × ${slip['width']}ft', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                                          ]),
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
