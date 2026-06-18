import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import '../utils/constants.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _role = 'customer';
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() { _animCtrl.dispose(); _nameController.dispose(); _emailController.dispose(); _passwordController.dispose(); super.dispose(); }

  void _submit() async {
    if (_nameController.text.trim().isEmpty || _emailController.text.trim().isEmpty || _passwordController.text.isEmpty) {
      setState(() => _errorMessage = 'Please fill in all fields.'); return;
    }
    setState(() { _isLoading = true; _errorMessage = null; });
    final errorMessage = await Provider.of<AuthProvider>(context, listen: false)
        .register(_nameController.text.trim(), _emailController.text.trim(), _passwordController.text, _role);
    if (errorMessage == null && mounted) { Navigator.pop(context); }
    else if (mounted) { setState(() { _errorMessage = errorMessage ?? 'Registration failed.'; _isLoading = false; }); }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;
    return Scaffold(backgroundColor: AppColors.background, body: isWide ? _wideLayout() : _mobileLayout());
  }

  Widget _wideLayout() {
    return Row(children: [
      Expanded(flex: 4, child: Center(child: SingleChildScrollView(child: _formPanel()))),
      Expanded(
        flex: 5,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF0F172A), Color(0xFF1E293B)]),
          ),
          child: Stack(children: [
            Positioned(bottom: -60, left: -60, child: Container(width: 300, height: 300,
              decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [AppColors.accent.withOpacity(0.1), Colors.transparent])))),
            FadeTransition(
              opacity: _fadeAnim,
              child: Padding(
                padding: const EdgeInsets.all(64),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                  Row(children: [
                    Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.sailing, color: Colors.white, size: 22)),
                    const SizedBox(width: 12),
                    const Text('LakePass', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.5)),
                  ]),
                  const SizedBox(height: 48),
                  const Text('Join thousands\nof mariners.', style: TextStyle(fontSize: 48, fontWeight: FontWeight.w800, color: Colors.white, height: 1.1, letterSpacing: -1.5)),
                  const SizedBox(height: 20),
                  Text('Create your free account and start\nbooking premium marina slips today.', style: TextStyle(fontSize: 17, color: Colors.white.withOpacity(0.55), height: 1.7)),
                  const SizedBox(height: 48),
                  Row(children: [
                    _stat('500+', 'Marinas'),
                    const SizedBox(width: 40),
                    _stat('10k+', 'Bookings'),
                    const SizedBox(width: 40),
                    _stat('4.9★', 'Rating'),
                  ]),
                ]),
              ),
            ),
          ]),
        ),
      ),
    ]);
  }

  Widget _stat(String value, String label) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.accent)),
      const SizedBox(height: 2),
      Text(label, style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.5))),
    ]);
  }

  Widget _mobileLayout() => Center(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: _formPanel()));

  Widget _formPanel() {
    return FadeTransition(
      opacity: _fadeAnim,
      child: Container(
        width: 420,
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Transform.translate(
              offset: const Offset(-8, 0),
              child: TextButton.icon(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.accent,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.arrow_back_rounded, size: 18),
                label: const Text('Back to Home', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Create account', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.5)),
            const SizedBox(height: 6),
            const Text('Join LakePass for free today', style: TextStyle(fontSize: 15, color: AppColors.textSecondary)),
            const SizedBox(height: 32),

            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(14), margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(color: AppColors.error.withOpacity(0.08), borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.error.withOpacity(0.3))),
                child: Row(children: [
                  const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 20),
                  const SizedBox(width: 10),
                  Expanded(child: Text(_errorMessage!, style: const TextStyle(color: AppColors.error, fontSize: 14))),
                ]),
              ),
            ],

            _inputLabel('Full Name'), const SizedBox(height: 8),
            _inputField(controller: _nameController, hint: 'John Doe', icon: Icons.person_outline_rounded),
            const SizedBox(height: 16),
            _inputLabel('Email Address'), const SizedBox(height: 8),
            _inputField(controller: _emailController, hint: 'you@example.com', icon: Icons.mail_outline_rounded, keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 16),
            _inputLabel('Password'), const SizedBox(height: 8),
            _inputField(controller: _passwordController, hint: '••••••••', icon: Icons.lock_outline_rounded, obscure: _obscurePassword,
              suffixIcon: IconButton(icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.textMuted, size: 20),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword))),
            const SizedBox(height: 16),
            _inputLabel('I am a...'), const SizedBox(height: 10),
            Row(children: [
              Expanded(child: _roleButton('customer', Icons.directions_boat_outlined, 'Customer')),
              const SizedBox(width: 12),
              Expanded(child: _roleButton('operator', Icons.anchor_rounded, 'Operator')),
            ]),
            const SizedBox(height: 28),

            SizedBox(width: double.infinity, height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.cta, foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
                child: _isLoading
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Create Account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 20),
            Center(child: GestureDetector(
              onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
              child: RichText(text: const TextSpan(text: 'Already have an account? ', style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                children: [TextSpan(text: 'Sign in', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w700))])),
            )),
          ],
        ),
      ),
    );
  }

  Widget _roleButton(String value, IconData icon, String label) {
    final selected = _role == value;
    return GestureDetector(
      onTap: () => setState(() => _role = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent.withOpacity(0.08) : AppColors.backgroundAlt,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? AppColors.accent : AppColors.border, width: selected ? 2 : 1),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: selected ? AppColors.accent : AppColors.textMuted, size: 22),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(color: selected ? AppColors.accent : AppColors.textSecondary, fontWeight: FontWeight.w600, fontSize: 13)),
        ]),
      ),
    );
  }

  Widget _inputLabel(String text) => Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary));

  Widget _inputField({required TextEditingController controller, required String hint, required IconData icon,
    bool obscure = false, TextInputType? keyboardType, Widget? suffixIcon}) {
    return TextField(
      controller: controller, obscureText: obscure, keyboardType: keyboardType,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint, hintStyle: const TextStyle(color: AppColors.textMuted),
        prefixIcon: Icon(icon, color: AppColors.textMuted, size: 20), suffixIcon: suffixIcon,
        filled: true, fillColor: AppColors.backgroundAlt,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
      ),
    );
  }
}
