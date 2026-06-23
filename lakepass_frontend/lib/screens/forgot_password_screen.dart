import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import '../utils/constants.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;
  String? _errorMessage;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _errorMessage = 'Please enter a valid email address.');
      return;
    }
    setState(() { _isLoading = true; _errorMessage = null; });
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final result = await auth.forgotPassword(email);
    setState(() => _isLoading = false);
    if (result['success'] == true) {
      setState(() => _emailSent = true);
    } else {
      setState(() => _errorMessage = result['message']);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: isWide ? _wideLayout() : _mobileLayout(),
    );
  }

  Widget _mobileLayout() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: _formPanel(),
      ),
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
                Positioned(
                  top: -80, right: -80,
                  child: Container(
                    width: 350, height: 350,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(colors: [AppColors.accent.withOpacity(0.1), Colors.transparent]),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -60, left: -60,
                  child: Container(
                    width: 250, height: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(colors: [AppColors.accent.withOpacity(0.06), Colors.transparent]),
                    ),
                  ),
                ),
                FadeTransition(
                  opacity: _fadeAnim,
                  child: Padding(
                    padding: const EdgeInsets.all(64),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(children: [
                          Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(10)),
                            child: const Icon(Icons.sailing, color: Colors.white, size: 22),
                          ),
                          const SizedBox(width: 12),
                          const Text('LakePass', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.5)),
                        ]),
                        const SizedBox(height: 64),
                        Container(
                          width: 72, height: 72,
                          decoration: BoxDecoration(
                            color: AppColors.accent.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(Icons.lock_reset_rounded, color: AppColors.accent, size: 36),
                        ),
                        const SizedBox(height: 28),
                        const Text('Password\nRecovery', style: TextStyle(fontSize: 44, fontWeight: FontWeight.w800, color: Colors.white, height: 1.1, letterSpacing: -1.2)),
                        const SizedBox(height: 16),
                        Text(
                          'Enter your registered email and we\'ll\nsend you a secure reset link.',
                          style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.5), height: 1.7),
                        ),
                        const SizedBox(height: 48),
                        _infoTile(Icons.shield_rounded, 'Secure Reset Link', 'Expires after 15 minutes'),
                        const SizedBox(height: 16),
                        _infoTile(Icons.mail_rounded, 'Check Your Inbox', 'Look in spam if not received'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Right: Form
        Expanded(
          flex: 4,
          child: Center(
            child: SingleChildScrollView(child: _formPanel()),
          ),
        ),
      ],
    );
  }

  Widget _infoTile(IconData icon, String title, String sub) {
    return Row(children: [
      Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.accent, size: 18),
      ),
      const SizedBox(width: 14),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
        Text(sub, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)),
      ]),
    ]);
  }

  Widget _formPanel() {
    return FadeTransition(
      opacity: _fadeAnim,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        width: double.infinity,
        padding: const EdgeInsets.all(40),
        child: _emailSent ? _successPanel() : _inputForm(),
      ),
    );
  }

  Widget _successPanel() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.mark_email_read_rounded, color: Colors.green.shade600, size: 38),
        ),
        const SizedBox(height: 24),
        const Text('Check your inbox!', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.5)),
        const SizedBox(height: 10),
        Text(
          'We\'ve sent a password reset link to\n${_emailController.text.trim()}',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 15, color: AppColors.textSecondary, height: 1.6),
        ),
        const SizedBox(height: 8),
        Text(
          'The link expires in 15 minutes. Check your spam folder if you don\'t see it.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: AppColors.textMuted),
        ),
        const SizedBox(height: 36),
        SizedBox(
          width: double.infinity, height: 52,
          child: ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.cta, foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            icon: const Icon(Icons.arrow_back_rounded, size: 18),
            label: const Text('Back to Sign In', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => setState(() { _emailSent = false; _emailController.clear(); }),
          style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
          child: const Text('Try a different email', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ),
      ],
    );
  }

  Widget _inputForm() {
    return Column(
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
            label: const Text('Back to Sign In', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          ),
        ),
        const SizedBox(height: 24),
        const Text('Forgot password?', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.5)),
        const SizedBox(height: 6),
        const Text('Enter your email to receive a reset link', style: TextStyle(fontSize: 15, color: AppColors.textSecondary)),
        const SizedBox(height: 32),

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

        const Text('Email address', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          onSubmitted: (_) => _submit(),
          decoration: InputDecoration(
            hintText: 'you@example.com',
            hintStyle: const TextStyle(color: AppColors.textMuted),
            prefixIcon: const Icon(Icons.mail_outline_rounded, color: AppColors.textMuted, size: 20),
            filled: true,
            fillColor: AppColors.backgroundAlt,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.accent, width: 1.5)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
        const SizedBox(height: 28),

        SizedBox(
          width: double.infinity, height: 52,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.cta, foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: _isLoading
                ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Send Reset Link', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: Text(
            'Remember your password? Sign in instead.',
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
        ),
      ],
    );
  }
}
