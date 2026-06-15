import 'package:flutter/material.dart';
import '../services/marina_service.dart';
import '../utils/constants.dart';
import '../widgets/sea_background.dart';
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Find Marinas', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SeaBackground(
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  TextField(
                    onChanged: _onSearch,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search Marinas...',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                      prefixIcon: const Icon(Icons.search, color: Colors.white),
                      filled: true,
                      fillColor: Colors.black.withOpacity(0.4),
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: _filteredMarinas.isEmpty
                      ? const Center(child: Text('No marinas found.', style: TextStyle(color: Colors.white, fontSize: 18)))
                      : GridView.builder(
                          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 380,
                            mainAxisExtent: 280,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                          ),
                          itemCount: _filteredMarinas.length,
                          itemBuilder: (context, index) {
                            final marina = _filteredMarinas[index];
                            // Different high-quality marina/ship images for each card
                            final List<String> marinaImages = [
                              'https://images.unsplash.com/photo-1567899378494-47b22a2ae96a?w=600&auto=format&fit=crop',
                              'https://images.unsplash.com/photo-1549693578-d683be217e58?w=600&auto=format&fit=crop',
                              'https://images.unsplash.com/photo-1500514966906-fe245eea9344?w=600&auto=format&fit=crop',
                              'https://images.unsplash.com/photo-1544551763-77ef2d0cfc6c?w=600&auto=format&fit=crop',
                              'https://images.unsplash.com/photo-1520490182-41ee35bb4a27?w=600&auto=format&fit=crop',
                              'https://images.unsplash.com/photo-1534430480872-3498386e7856?w=600&auto=format&fit=crop',
                            ];
                            final imageUrl = marinaImages[index % marinaImages.length];
                            return GestureDetector(
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MarinaDetailsScreen(marina: marina))),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.network(imageUrl, fit: BoxFit.cover,
                                      errorBuilder: (ctx, err, st) => Container(color: AppColors.surface)),
                                    // Gradient overlay
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                                        ),
                                      ),
                                    ),
                                    // Card content
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
                            );
                          },
                        ),
                  )
                ],
              ),
            ),
      ),
    );
  }
}
