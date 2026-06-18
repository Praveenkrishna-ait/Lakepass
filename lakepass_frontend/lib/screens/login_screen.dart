import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import '../utils/constants.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
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
  void dispose() { _animCtrl.dispose(); _emailController.dispose(); _passwordController.dispose(); super.dispose(); }

  void _submit() async {
    setState(() { _isLoading = true; _errorMessage = null; });
    final success = await Provider.of<AuthProvider>(context, listen: false)
        .login(_emailController.text.trim(), _passwordController.text);
    if (success && mounted) { Navigator.pop(context); }
    else if (mounted) { setState(() { _errorMessage = 'Invalid email or password. Please try again.'; _isLoading = false; }); }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: isWide ? _wideLayout() : _mobileLayout(),
    );
  }

  Widget _wideLayout() {
    return Row(
      children: [
        // Left: Dark branding panel
        Expanded(
          flex: 5,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
              ),
            ),
            child: Stack(
              children: [
                Positioned(top: -80, right: -80, child: Container(
                  width: 350, height: 350,
                  decoration: BoxDecoration(shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [AppColors.accent.withOpacity(0.1), Colors.transparent])),
                )),
                FadeTransition(
                  opacity: _fadeAnim,
                  child: Padding(
                    padding: const EdgeInsets.all(64),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(children: [
                          Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(10)),
                            child: const Icon(Icons.sailing, color: Colors.white, size: 22)),
                          const SizedBox(width: 12),
                          const Text('LakePass', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.5)),
                        ]),
                        const SizedBox(height: 48),
                        const Text('Your marina,\nyour way.', style: TextStyle(fontSize: 48, fontWeight: FontWeight.w800, color: Colors.white, height: 1.1, letterSpacing: -1.5)),
                        const SizedBox(height: 20),
                        Text('Book premium marina slips instantly.\nNo hidden fees. No complications.', style: TextStyle(fontSize: 17, color: Colors.white.withOpacity(0.55), height: 1.7)),
                        const SizedBox(height: 48),
                        Row(children: [
                          _featurePill(Icons.bolt, 'Instant Booking'),
                          const SizedBox(width: 12),
                          _featurePill(Icons.shield_rounded, 'Secure Payment'),
                          const SizedBox(width: 12),
                          _featurePill(Icons.headset_mic_rounded, '24/7 Support'),
                        ]),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Right: Form
        Expanded(flex: 4, child: Center(child: SingleChildScrollView(child: _formPanel()))),
      ],
    );
  }

  Widget _mobileLayout() {
    return Center(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: _formPanel()));
  }

  Widget _featurePill(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: AppColors.accent, size: 16),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
      ]),
    );
  }

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
            const Text('Welcome back', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.5)),
            const SizedBox(height: 6),
            const Text('Sign in to your LakePass account', style: TextStyle(fontSize: 15, color: AppColors.textSecondary)),
            const SizedBox(height: 36),

            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(14),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.error.withOpacity(0.3)),
                ),
                child: Row(children: [
                  const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 20),
                  const SizedBox(width: 10),
                  Expanded(child: Text(_errorMessage!, style: const TextStyle(color: AppColors.error, fontSize: 14))),
                ]),
              ),
            ],

            _inputLabel('Email address'),
            const SizedBox(height: 8),
            _inputField(controller: _emailController, hint: 'you@example.com', icon: Icons.mail_outline_rounded, keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 20),
            _inputLabel('Password'),
            const SizedBox(height: 8),
            _inputField(
              controller: _passwordController, hint: '••••••••', icon: Icons.lock_outline_rounded,
              obscure: _obscurePassword,
              suffixIcon: IconButton(
                icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.textMuted, size: 20),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.accent,
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Forgot password?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.cta, foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Sign In', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: GestureDetector(
                onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                child: RichText(
                  text: const TextSpan(
                    text: "Don't have an account? ",
                    style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                    children: [TextSpan(text: 'Sign up', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w700))],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputLabel(String text) {
    return Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary));
  }

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
