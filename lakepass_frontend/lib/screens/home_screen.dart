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

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final _searchController = TextEditingController();
  List<dynamic> _marinas = [];
  bool _isLoadingMarinas = true;
  late AnimationController _heroCtrl;
  late Animation<double> _heroFade;
  late Animation<Offset> _heroSlide;
  bool _navElevated = false;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _heroCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _heroFade = CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOut);
    _heroSlide = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
        .animate(CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOutCubic));
    _heroCtrl.forward();
    _fetchFeaturedMarinas();
    _scrollController.addListener(() {
      final elevated = _scrollController.offset > 50;
      if (elevated != _navElevated) setState(() => _navElevated = elevated);
    });
  }

  @override
  void dispose() {
    _heroCtrl.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchFeaturedMarinas() async {
    final marinas = await MarinaService.getAllMarinas();
    if (mounted) setState(() { _marinas = marinas; _isLoadingMarinas = false; });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          ListView(
            controller: _scrollController,
            padding: EdgeInsets.zero,
            cacheExtent: 0,
            children: [
              _buildHero(),
              ScrollReveal(child: _buildLogoBanner()),
              _buildFeaturedSection(), // Removed ScrollReveal wrapper here
              ScrollReveal(child: _buildHowItWorks()),
              ScrollReveal(child: _buildStatsSection()),
              _buildFooter(),
            ],
          ),
          _buildNavBar(auth),
        ],
      ),
    );
  }

  // ── NAV BAR ──
  Widget _buildNavBar(AuthProvider auth) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: _navElevated ? Colors.white.withOpacity(0.95) : Colors.transparent,
        border: Border(
          bottom: BorderSide(
            color: _navElevated ? AppColors.border : Colors.transparent,
          ),
        ),
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: _navElevated ? 20 : 0, sigmaY: _navElevated ? 20 : 0),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              child: Row(
                children: [
                  // Logo
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.sailing, color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Text('LakePass', style: TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 20,
                      color: _navElevated ? AppColors.textPrimary : Colors.white,
                      letterSpacing: -0.5,
                    )),
                  ]),
                  const Spacer(),
                  if (!auth.isAuthenticated) ...[
                    _navLink('Login', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()))),
                    const SizedBox(width: 24),
                    _ctaButton('Get Started', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen()))),
                  ] else ...[
                    _navLink('Dashboard', () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (_) => auth.role == 'operator' ? const OperatorDashboard() : const CustomerDashboard(),
                      ));
                    }),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        CircleAvatar(radius: 12, backgroundColor: AppColors.accent, child: const Icon(Icons.person, color: Colors.white, size: 14)),
                        const SizedBox(width: 8),
                        Text(auth.name ?? 'User', style: TextStyle(
                          color: _navElevated ? AppColors.textPrimary : Colors.white,
                          fontSize: 14, fontWeight: FontWeight.w600,
                        )),
                      ]),
                    ),
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed: () => auth.logout(),
                      child: Text('Logout', style: TextStyle(color: _navElevated ? AppColors.textMuted : Colors.white70, fontSize: 14)),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _navLink(String text, VoidCallback onTap) {
    return TextButton(
      onPressed: onTap,
      child: Text(text, style: TextStyle(
        color: _navElevated ? AppColors.textSecondary : Colors.white,
        fontSize: 15, fontWeight: FontWeight.w500,
      )),
    );
  }

  Widget _ctaButton(String text, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        elevation: 0,
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
    );
  }

  // ── HERO SECTION ──
  Widget _buildHero() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF0F172A)],
        ),
      ),
      child: Stack(
        children: [
          // Subtle grid pattern overlay
          Positioned.fill(
            child: Opacity(
              opacity: 0.04,
              child: Image.network(
                'https://images.unsplash.com/photo-1544551763-46a013bb70d5?q=80&w=2070&auto=format&fit=crop',
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Glow effects
          Positioned(top: -100, right: -100, child: Container(
            width: 400, height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [AppColors.accent.withOpacity(0.12), Colors.transparent]),
            ),
          )),
          Positioned(bottom: -50, left: -50, child: Container(
            width: 300, height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [AppColors.glowBlue.withOpacity(0.08), Colors.transparent]),
            ),
          )),
          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(60, 140, 60, 80),
            child: SlideTransition(
              position: _heroSlide,
              child: FadeTransition(
                opacity: _heroFade,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Section tag
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.accent.withOpacity(0.25)),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle)),
                        const SizedBox(width: 8),
                        const Text('The #1 Marina Booking Platform', style: TextStyle(color: AppColors.accent, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                      ]),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Book Your Perfect\nMarina Slip, Instantly',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 60, fontWeight: FontWeight.w800, color: Colors.white, height: 1.1, letterSpacing: -2),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Premium marina reservations made simple. Find, compare, and book\nslips at top-rated locations worldwide.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, color: Colors.white.withOpacity(0.55), height: 1.6, letterSpacing: -0.2),
                    ),
                    const SizedBox(height: 48),
                    _buildSearchBar(),
                    const SizedBox(height: 36),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _heroBadge(Icons.location_on_rounded, '500+ Locations'),
                        const SizedBox(width: 20),
                        _heroBadge(Icons.bolt_rounded, 'Instant Booking'),
                        const SizedBox(width: 20),
                        _heroBadge(Icons.shield_rounded, 'Secure Payments'),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: AppColors.accent, size: 16),
        const SizedBox(width: 8),
        Text(text, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13, fontWeight: FontWeight.w500)),
      ]),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 640),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Icon(Icons.search_rounded, color: Colors.white.withOpacity(0.4), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white, fontSize: 15),
              decoration: InputDecoration(
                hintText: 'Search marinas by name or location...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                fillColor: Colors.transparent,
                filled: true,
              ),
              onSubmitted: (val) => Navigator.push(context, MaterialPageRoute(builder: (_) => SearchScreen(initialQuery: val))),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SearchScreen(initialQuery: _searchController.text))),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
              elevation: 0,
            ),
            child: const Text('Search', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  // ── LOGO / TRUST BANNER ──
  Widget _buildLogoBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: const BoxDecoration(
        color: AppColors.backgroundAlt,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          Text('TRUSTED BY MARINERS WORLDWIDE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 2)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _trustLogo(Icons.anchor_rounded, 'MarinaHub'),
              const SizedBox(width: 48),
              _trustLogo(Icons.directions_boat_rounded, 'BoatDock'),
              const SizedBox(width: 48),
              _trustLogo(Icons.water_rounded, 'AquaSlips'),
              const SizedBox(width: 48),
              _trustLogo(Icons.sailing_rounded, 'SailPoint'),
              const SizedBox(width: 48),
              _trustLogo(Icons.pool_rounded, 'HarborPro'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _trustLogo(IconData icon, String name) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, color: AppColors.textMuted, size: 22),
      const SizedBox(width: 8),
      Text(name, style: const TextStyle(color: AppColors.textMuted, fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: -0.3)),
    ]);
  }

  // ── FEATURED SECTION ──
  Widget _buildFeaturedSection() {
    if (_marinas.isEmpty && !_isLoadingMarinas) return const SizedBox();

    final List<String> marinaImages = [
      'https://images.unsplash.com/photo-1567899378494-47b22a2ae96a?w=800&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1549693578-d683be217e58?w=800&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1500514966906-fe245eea9344?w=800&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1544551763-77ef2d0cfc6c?w=800&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1520490182-41ee35bb4a27?w=800&auto=format&fit=crop',
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 80),
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ScrollReveal(child: _sectionLabel('FEATURED')),
          const SizedBox(height: 12),
          ScrollReveal(
            delay: const Duration(milliseconds: 100),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Featured Marinas', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -1)),
                  const SizedBox(height: 8),
                  Text('Handpicked premium locations for your next voyage', style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
                ]),
                TextButton.icon(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen())),
                  icon: const Text('View all marinas', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600)),
                  label: const Icon(Icons.arrow_forward_rounded, color: AppColors.accent, size: 16),
                ),
              ],
            ),
          ),
          const SizedBox(height: 36),
          if (_isLoadingMarinas)
            const Center(child: CircularProgressIndicator(color: AppColors.accent))
          else
            SizedBox(
              height: 380,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _marinas.length > 6 ? 6 : _marinas.length,
                itemBuilder: (context, index) {
                  final marina = _marinas[index];
                  final imageUrl = marinaImages[index % marinaImages.length];
                  return ScrollReveal(
                    delay: Duration(milliseconds: 600 + (index * 200)),
                    child: _marinaCard(marina, imageUrl),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Row(children: [
      Container(width: 20, height: 3, decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 10),
      Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.accent, letterSpacing: 1.5)),
    ]);
  }

  Widget _marinaCard(dynamic marina, String imageUrl) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MarinaDetailsScreen(marina: marina))),
      child: Container(
        width: 320,
        margin: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          color: AppColors.surface,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            SizedBox(
              height: 200,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(imageUrl, fit: BoxFit.cover,
                      errorBuilder: (ctx, err, st) => Container(color: AppColors.backgroundAlt)),
                  Positioned(
                    top: 12, right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('Available', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(marina['name'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: -0.3), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Row(children: [
                    const Icon(Icons.location_on_rounded, color: AppColors.accent, size: 14),
                    const SizedBox(width: 4),
                    Expanded(child: Text(marina['location'] ?? 'Location N/A', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13), overflow: TextOverflow.ellipsis)),
                  ]),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MarinaDetailsScreen(marina: marina))),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.cta,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                      ),
                      child: const Text('View Slips →', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
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

  // ── HOW IT WORKS ──
  Widget _buildHowItWorks() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 80),
      color: AppColors.backgroundAlt,
      child: Column(
        children: [
          _sectionLabel('PROCESS'),
          const SizedBox(height: 12),
          const Text('How LakePass Works', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -1)),
          const SizedBox(height: 8),
          Text('Three simple steps to your perfect marina experience', style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
          const SizedBox(height: 56),
          Row(
            children: [
              Expanded(child: _stepCard('01', 'Search & Discover', 'Browse hundreds of verified marinas with detailed specs, reviews and real-time availability.', Icons.search_rounded)),
              const SizedBox(width: 24),
              Expanded(child: _stepCard('02', 'Book Instantly', 'Select your dates, choose your slip, and confirm your booking in under 60 seconds.', Icons.bolt_rounded)),
              const SizedBox(width: 24),
              Expanded(child: _stepCard('03', 'Enjoy the Water', 'Show up, dock your boat, and enjoy premium amenities. It\'s that simple.', Icons.sailing_rounded)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stepCard(String number, String title, String desc, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.accent, size: 24),
              ),
              Text(number, style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: AppColors.border, letterSpacing: -2)),
            ],
          ),
          const SizedBox(height: 24),
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: -0.3)),
          const SizedBox(height: 10),
          Text(desc, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.6)),
        ],
      ),
    );
  }

  // ── STATS SECTION (dark) ──
  Widget _buildStatsSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 80),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statBlock('500+', 'Marina Locations', Icons.anchor_rounded),
          _statDivider(),
          _statBlock('10,000+', 'Happy Boaters', Icons.people_rounded),
          _statDivider(),
          _statBlock('4.9 / 5', 'Average Rating', Icons.star_rounded),
          _statDivider(),
          _statBlock('24/7', 'Customer Support', Icons.headset_mic_rounded),
        ],
      ),
    );
  }

  Widget _statBlock(String value, String label, IconData icon) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, color: AppColors.accent, size: 28),
      const SizedBox(height: 14),
      Text(value, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -1)),
      const SizedBox(height: 6),
      Text(label, style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.5), fontWeight: FontWeight.w500)),
    ]);
  }

  Widget _statDivider() => Container(width: 1, height: 60, color: Colors.white.withOpacity(0.1));

  // ── FOOTER ──
  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 48),
      color: const Color(0xFF030712),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(6)),
              child: const Icon(Icons.sailing, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 10),
            const Text('LakePass', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Colors.white, letterSpacing: -0.5)),
          ]),
          Text('© 2026 LakePass. All rights reserved.', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13)),
        ],
      ),
    );
  }
}

class ScrollReveal extends StatefulWidget {
  final Widget child;
  final Duration delay;
  const ScrollReveal({super.key, required this.child, this.delay = Duration.zero});
  @override
  State<ScrollReveal> createState() => _ScrollRevealState();
}

class _ScrollRevealState extends State<ScrollReveal> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    // Extended duration for more visible movement
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    // Increased offset for a larger sliding effect
    _slide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutQuint));
    
    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: widget.child,
      ),
    );
  }
}
