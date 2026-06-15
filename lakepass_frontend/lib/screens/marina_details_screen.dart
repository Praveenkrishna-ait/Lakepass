import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import '../services/marina_service.dart';
import '../services/payment_service.dart';
import '../services/razorpay_web.dart';
import '../utils/constants.dart';
import '../widgets/sea_background.dart';
import 'login_screen.dart';

class MarinaDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> marina;
  const MarinaDetailsScreen({super.key, required this.marina});

  @override
  State<MarinaDetailsScreen> createState() => _MarinaDetailsScreenState();
}

class _MarinaDetailsScreenState extends State<MarinaDetailsScreen> {
  bool _isLoading = true;
  List<dynamic> _slips = [];

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
    final slips = await MarinaService.getSlips(widget.marina['id']);
    setState(() {
      _slips = slips;
      _isLoading = false;
    });
  }

  void _showBookingDialog(BuildContext context, dynamic slip) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (!auth.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login as a customer to book a slip')),
      );
      Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      return;
    }

    DateTime startDate = DateTime.now();
    DateTime endDate = DateTime.now().add(const Duration(days: 1));
    bool isProcessing = false;

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            int days = endDate.difference(startDate).inDays;
            if (days <= 0) days = 1;
            final pricePerNight = double.tryParse(slip['price_per_night'].toString()) ?? 0.0;
            final total = days * pricePerNight;

            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    width: 500,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.surface.withOpacity(0.85),
                          AppColors.background.withOpacity(0.95),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1.5),
                      boxShadow: [
                        BoxShadow(color: AppColors.primary.withOpacity(0.15), blurRadius: 40, spreadRadius: 5),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ── Header image banner ──
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                          child: Stack(
                            children: [
                              Image.network(
                                'https://images.unsplash.com/photo-1567899378494-47b22a2ae96a?w=600&auto=format&fit=crop',
                                height: 160, width: double.infinity, fit: BoxFit.cover,
                                errorBuilder: (ctx, err, st) => Container(height: 160, color: AppColors.surface),
                              ),
                              Container(
                                height: 160,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                                    colors: [Colors.transparent, AppColors.background.withOpacity(0.9)],
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 16, left: 20,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(slip['name'],
                                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white,
                                        shadows: [Shadow(blurRadius: 8, color: Colors.black54)])),
                                    Row(children: [
                                      const Icon(Icons.anchor, color: AppColors.primary, size: 14),
                                      const SizedBox(width: 4),
                                      Text(widget.marina['name'],
                                        style: const TextStyle(fontSize: 14, color: Colors.white70)),
                                    ]),
                                  ],
                                ),
                              ),
                              Positioned(
                                top: 12, right: 12,
                                child: GestureDetector(
                                  onTap: () => Navigator.pop(ctx),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.4),
                                      shape: BoxShape.circle,
                                    ),
                                    padding: const EdgeInsets.all(6),
                                    child: const Icon(Icons.close, color: Colors.white, size: 18),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ── Slip specs row ──
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    _specChip(Icons.straighten, '${slip['length']}ft', 'Length'),
                                    _divider(),
                                    _specChip(Icons.swap_vert, '${slip['width']}ft', 'Width'),
                                    _divider(),
                                    _specChip(Icons.currency_rupee, '${slip['price_per_night']}', 'Per Night'),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),

                              // ── Date pickers ──
                              const Text('SELECT DATES',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 1.5)),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _dateTile(
                                      label: 'Check-In',
                                      date: startDate,
                                      icon: Icons.flight_land,
                                      onTap: () async {
                                        final picked = await showDatePicker(
                                          context: context, initialDate: startDate,
                                          firstDate: DateTime.now(), lastDate: DateTime(2030),
                                        );
                                        if (picked != null) setState(() {
                                          startDate = picked;
                                          if (endDate.isBefore(startDate.add(const Duration(days: 1)))) {
                                            endDate = startDate.add(const Duration(days: 1));
                                          }
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _dateTile(
                                      label: 'Check-Out',
                                      date: endDate,
                                      icon: Icons.flight_takeoff,
                                      onTap: () async {
                                        final picked = await showDatePicker(
                                          context: context, initialDate: endDate,
                                          firstDate: startDate.add(const Duration(days: 1)), lastDate: DateTime(2030),
                                        );
                                        if (picked != null) setState(() => endDate = picked);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),

                              // ── Price summary ──
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('$days night${days > 1 ? 's' : ''} × ₹$pricePerNight',
                                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                                        const SizedBox(height: 4),
                                        const Text('Total Amount',
                                          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 15)),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        const Icon(Icons.currency_rupee, color: AppColors.primary, size: 26),
                                        Text(total.toStringAsFixed(2),
                                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primary)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text('  Secure payment via Razorpay',
                                style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                              const SizedBox(height: 20),

                              // ── Action button ──
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton.icon(
                                  onPressed: (isProcessing || endDate.isBefore(startDate)) ? null : () async {
                                    setState(() => isProcessing = true);
                                    final startStr = startDate.toIso8601String().split('T')[0];
                                    final endStr = endDate.toIso8601String().split('T')[0];

                                    final orderResult = await PaymentService.createOrder(
                                      slipId: slip['id'], startDate: startStr, endDate: endStr,
                                    );

                                    if (orderResult['error'] != null) {
                                      setState(() => isProcessing = false);
                                      if (!ctx.mounted) return;
                                      Navigator.pop(ctx);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(orderResult['error']), backgroundColor: AppColors.error),
                                      );
                                      return;
                                    }

                                    final orderData = orderResult['data'];
                                    openRazorpayCheckout(
                                      key: orderData['key_id'], amount: orderData['amount'],
                                      currency: orderData['currency'], orderId: orderData['order_id'],
                                      description: 'Booking: ${slip['name']} at ${widget.marina['name']}',
                                      prefillName: auth.name,
                                      onSuccess: (rzpOrderId, rzpPaymentId, rzpSignature) async {
                                        final verifyResult = await PaymentService.verifyPayment(
                                          razorpayOrderId: rzpOrderId, razorpayPaymentId: rzpPaymentId,
                                          razorpaySignature: rzpSignature, slipId: slip['id'],
                                          startDate: startStr, endDate: endStr,
                                        );
                                        if (!ctx.mounted) return;
                                        Navigator.pop(ctx);
                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                          content: Text(verifyResult['success'] == true
                                              ? '✅ Payment Successful! Booking Confirmed!'
                                              : 'Payment received but verification failed: ${verifyResult['error']}'),
                                          backgroundColor: verifyResult['success'] == true ? Colors.green : AppColors.error,
                                          duration: const Duration(seconds: 4),
                                        ));
                                      },
                                      onError: (error) {
                                        setState(() => isProcessing = false);
                                        if (!ctx.mounted) return;
                                        Navigator.pop(ctx);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Payment failed: $error'), backgroundColor: AppColors.error),
                                        );
                                      },
                                      onCancel: () => setState(() => isProcessing = false),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: AppColors.background,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    elevation: 8,
                                    shadowColor: AppColors.primary.withOpacity(0.5),
                                  ),
                                  icon: isProcessing
                                      ? const SizedBox(width: 20, height: 20,
                                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.background))
                                      : const Icon(Icons.payment_rounded, size: 22),
                                  label: Text(isProcessing ? 'Processing...' : 'Pay & Book Now',
                                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _specChip(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 18),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 15)),
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
      ],
    );
  }

  Widget _divider() => Container(height: 36, width: 1, color: AppColors.primary.withOpacity(0.2));

  Widget _dateTile({required String label, required DateTime date, required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface.withOpacity(0.6),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, color: AppColors.primary, size: 14),
              const SizedBox(width: 4),
              Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
            ]),
            const SizedBox(height: 6),
            Text('${date.day} ${_monthName(date.month)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            Text('${date.year}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  String _monthName(int month) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return months[month - 1];
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(widget.marina['name'],
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.marina['description'] ?? 'No description available.',
                      style: const TextStyle(fontSize: 18, color: Colors.white70),
                    ),
                    const SizedBox(height: 24),
                    const Text('Available Slips',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 16),
                    if (_slips.isEmpty)
                      const Text('No slips available for this marina.',
                          style: TextStyle(color: Colors.white70)),
                    Expanded(
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 420,
                          mainAxisExtent: 300,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                        ),
                        itemCount: _slips.length,
                        itemBuilder: (context, index) {
                          final slip = _slips[index];
                          final imageUrl = _slipImages[index % _slipImages.length];
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.network(imageUrl, fit: BoxFit.cover,
                                    errorBuilder: (ctx, err, st) =>
                                        Container(color: AppColors.surface)),
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [Colors.transparent, Colors.black.withOpacity(0.85)],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(slip['name'],
                                          style: const TextStyle(
                                              fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                                      const SizedBox(height: 4),
                                      Row(children: [
                                        const Icon(Icons.straighten, color: AppColors.primary, size: 16),
                                        const SizedBox(width: 4),
                                        Text('${slip['length']}ft × ${slip['width']}ft',
                                            style: const TextStyle(color: Colors.white70, fontSize: 14)),
                                      ]),
                                      const SizedBox(height: 6),
                                      Row(children: [
                                        const Icon(Icons.currency_rupee, color: AppColors.primary, size: 18),
                                        Text('${slip['price_per_night']}/night',
                                            style: const TextStyle(
                                                fontSize: 18, color: AppColors.primary, fontWeight: FontWeight.bold)),
                                      ]),
                                      const SizedBox(height: 12),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          onPressed: () => _showBookingDialog(context, slip),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.primary,
                                            foregroundColor: AppColors.background,
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10)),
                                          ),
                                          child: const Text('Book Now',
                                              style: TextStyle(fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
