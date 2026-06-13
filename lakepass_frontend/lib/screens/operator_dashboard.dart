import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import '../services/marina_service.dart';
import '../utils/constants.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Operator Dashboard'),
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
                        const Text('Register New Marina', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Marina Name', filled: true, fillColor: AppColors.background)),
                        const SizedBox(height: 16),
                        TextField(controller: _locController, decoration: const InputDecoration(labelText: 'Location', filled: true, fillColor: AppColors.background)),
                        const SizedBox(height: 16),
                        TextField(controller: _descController, maxLines: 3, decoration: const InputDecoration(labelText: 'Description', filled: true, fillColor: AppColors.background)),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _createMarina,
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.background),
                            child: const Text('Create Marina'),
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
                      const Text('Your Marinas', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      if (_myMarinas.isEmpty)
                         const Text('You have not created any marinas yet.', style: TextStyle(color: AppColors.textSecondary)),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _myMarinas.length,
                          itemBuilder: (context, index) {
                            final marina = _myMarinas[index];
                            return Card(
                              color: AppColors.surface,
                              margin: const EdgeInsets.only(bottom: 16),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                title: Text(marina['name'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                subtitle: Text(marina['location'] ?? ''),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.push(context, MaterialPageRoute(builder: (_) => AnalyticsScreen(marinaId: marina['id'], marinaName: marina['name'])));
                                      },
                                      child: const Text('Analytics', style: TextStyle(color: AppColors.primary, fontSize: 16)),
                                    ),
                                    const SizedBox(width: 16),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(context, MaterialPageRoute(builder: (_) => ManageSlipsScreen(
                                          marinaId: marina['id'],
                                          marinaName: marina['name'],
                                        )));
                                      },
                                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.background),
                                      child: const Text('Manage Slips'),
                                    ),
                                  ],
                                ),
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
