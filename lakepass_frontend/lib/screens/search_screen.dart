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
  void initState() { super.initState(); _fetchMarinas(); }

  Future<void> _fetchMarinas() async {
    final marinas = await MarinaService.getAllMarinas();
    setState(() {
      _allMarinas = marinas;
      if (widget.initialQuery.isNotEmpty) {
        _filteredMarinas = _allMarinas.where((m) => m['name'].toString().toLowerCase().contains(widget.initialQuery.toLowerCase()) ||
           (m['location']?.toString().toLowerCase().contains(widget.initialQuery.toLowerCase()) ?? false)).toList();
      } else { _filteredMarinas = _allMarinas; }
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
      backgroundColor: AppColors.backgroundAlt,
      appBar: AppBar(
        title: const Text('Find Marinas', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        backgroundColor: AppColors.background,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(height: 1, color: AppColors.border)),
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
        : Padding(
            padding: const EdgeInsets.all(32),
            child: Column(children: [
              // Search bar
              Container(
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                child: TextField(
                  onChanged: _onSearch,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Search Marinas...', hintStyle: const TextStyle(color: AppColors.textMuted),
                    prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                    border: InputBorder.none, enabledBorder: InputBorder.none, focusedBorder: InputBorder.none,
                    filled: true, fillColor: Colors.transparent,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: _filteredMarinas.isEmpty
                  ? const Center(child: Text('No marinas found.', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)))
                  : GridView.builder(
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 380, mainAxisExtent: 320, crossAxisSpacing: 24, mainAxisSpacing: 24),
                      itemCount: _filteredMarinas.length,
                      itemBuilder: (context, index) {
                        final marina = _filteredMarinas[index];
                        final List<String> marinaImages = [
                          'https://images.unsplash.com/photo-1567899378494-47b22a2ae96a?w=600&auto=format&fit=crop',
                          'https://images.unsplash.com/photo-1549693578-d683be217e58?w=600&auto=format&fit=crop',
                          'https://images.unsplash.com/photo-1500514966906-fe245eea9344?w=600&auto=format&fit=crop',
                          'https://images.unsplash.com/photo-1544551763-77ef2d0cfc6c?w=600&auto=format&fit=crop',
                          'https://images.unsplash.com/photo-1520490182-41ee35bb4a27?w=600&auto=format&fit=crop',
                        ];
                        final imageUrl = marinaImages[index % marinaImages.length];
                        return TweenAnimationBuilder(
                          tween: Tween<double>(begin: 0, end: 1),
                          duration: Duration(milliseconds: 400 + (index * 80)),
                          curve: Curves.easeOutCubic,
                          builder: (context, double value, child) => Transform.translate(
                            offset: Offset(0, 30 * (1 - value)), child: Opacity(opacity: value, child: child)),
                          child: GestureDetector(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MarinaDetailsScreen(marina: marina))),
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.surface, borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.border),
                                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Expanded(
                                  child: Image.network(imageUrl, width: double.infinity, fit: BoxFit.cover,
                                    errorBuilder: (ctx, err, st) => Container(color: AppColors.backgroundAlt)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Text(marina['name'], style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                                    const SizedBox(height: 6),
                                    Row(children: [
                                      const Icon(Icons.location_on, color: AppColors.accent, size: 14),
                                      const SizedBox(width: 4),
                                      Text(marina['location'] ?? '', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                                    ]),
                                    const SizedBox(height: 12),
                                    SizedBox(width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MarinaDetailsScreen(marina: marina))),
                                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.cta, foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), padding: const EdgeInsets.symmetric(vertical: 10)),
                                        child: const Text('View Slips', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                                      ),
                                    ),
                                  ]),
                                ),
                              ]),
                            ),
                          ),
                        );
                      },
                    ),
              ),
            ]),
          ),
    );
  }
}
