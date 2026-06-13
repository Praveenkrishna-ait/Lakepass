import 'package:flutter/material.dart';
import '../services/marina_service.dart';
import '../utils/constants.dart';
import 'marina_details_screen.dart';

class SearchScreen extends StatefulWidget {
  final String initialQuery;
  const SearchScreen({super.key, this.initialQuery = ''});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  bool _isLoading = true;
  List<dynamic> _allMarinas = [];
  List<dynamic> _filteredMarinas = [];

  @override
  void initState() {
    super.initState();
    _fetchMarinas();
  }

  Future<void> _fetchMarinas() async {
    final marinas = await MarinaService.getAllMarinas();
    setState(() {
      _allMarinas = marinas;
      if (widget.initialQuery.isNotEmpty) {
        _filteredMarinas = _allMarinas.where((m) => m['name'].toString().toLowerCase().contains(widget.initialQuery.toLowerCase()) || 
           (m['location']?.toString().toLowerCase().contains(widget.initialQuery.toLowerCase()) ?? false)).toList();
      } else {
        _filteredMarinas = _allMarinas;
      }
      _isLoading = false;
    });
  }

  void _onSearch(String query) {
    setState(() {
      _filteredMarinas = _allMarinas.where((m) => m['name'].toString().toLowerCase().contains(query.toLowerCase()) || 
         (m['location']?.toString().toLowerCase().contains(query.toLowerCase()) ?? false)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Marinas'),
        backgroundColor: AppColors.surface,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                TextField(
                  onChanged: _onSearch,
                  decoration: const InputDecoration(
                    hintText: 'Search Marinas...',
                    prefixIcon: Icon(Icons.search),
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: _filteredMarinas.isEmpty 
                    ? const Center(child: Text('No marinas found.', style: TextStyle(color: AppColors.textSecondary, fontSize: 18)))
                    : ListView.builder(
                        itemCount: _filteredMarinas.length,
                        itemBuilder: (context, index) {
                          final marina = _filteredMarinas[index];
                          return Card(
                            color: AppColors.surface,
                            margin: const EdgeInsets.only(bottom: 16),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(24),
                              title: Text(marina['name'], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                              subtitle: Text(marina['location'] ?? '', style: const TextStyle(fontSize: 16)),
                              trailing: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => MarinaDetailsScreen(marina: marina)));
                                },
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.background),
                                child: const Text('View Slips'),
                              ),
                            ),
                          );
                        },
                      ),
                )
              ],
            ),
          ),
    );
  }
}
