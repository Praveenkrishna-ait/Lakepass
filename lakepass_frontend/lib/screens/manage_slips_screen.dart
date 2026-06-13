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
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Slip created successfully!'), backgroundColor: Colors.green));
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result?['error'] ?? 'Failed to create slip'), backgroundColor: AppColors.error));
      }
    }
    
    _fetchSlips();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Slips: ${widget.marinaName}'),
        backgroundColor: AppColors.surface,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Add New Slip', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Slip Name (e.g. A-12)', filled: true, fillColor: AppColors.background)),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: TextField(controller: _lengthController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Length (ft)', filled: true, fillColor: AppColors.background))),
                            const SizedBox(width: 16),
                            Expanded(child: TextField(controller: _widthController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Width (ft)', filled: true, fillColor: AppColors.background))),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextField(controller: _priceController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Price per night (\$)', filled: true, fillColor: AppColors.background)),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _createSlip,
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.background),
                            child: const Text('Create Slip'),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Current Slips', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      if (_slips.isEmpty) 
                         const Text('No slips added yet.', style: TextStyle(color: AppColors.textSecondary)),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _slips.length,
                          itemBuilder: (context, index) {
                            final slip = _slips[index];
                            return Card(
                              color: AppColors.surface,
                              margin: const EdgeInsets.only(bottom: 16),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                title: Text(slip['name'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                subtitle: Text('${slip['length']}ft x ${slip['width']}ft'),
                                trailing: Text('\$${slip['price_per_night']}/night', style: const TextStyle(fontSize: 18, color: AppColors.primary, fontWeight: FontWeight.bold)),
                              ),
                            );
                          },
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
    );
  }
}
