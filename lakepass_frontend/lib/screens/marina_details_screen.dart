import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import '../services/marina_service.dart';
import '../services/payment_service.dart';
import '../services/razorpay_web.dart';
import '../utils/constants.dart';
import 'login_screen.dart';
import '../widgets/glass_card.dart';

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
      barrierColor: Colors.black.withOpacity(0.5),
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
              child: Container(
                width: 500,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 40, spreadRadius: 5)],
                ),
                clipBehavior: Clip.antiAlias,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header image banner
                      Stack(
                        children: [
                          Image.network(
                            'https://images.unsplash.com/photo-1567899378494-47b22a2ae96a?w=600&auto=format&fit=crop',
                            height: 160, width: double.infinity, fit: BoxFit.cover,
                            errorBuilder: (ctx, err, st) => Container(height: 160, color: AppColors.backgroundAlt),
                          ),
                          Container(
                            height: 160,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                                colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 20, left: 24,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(slip['name'], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white)),
                                const SizedBox(height: 4),
                                Row(children: [
                                  const Icon(Icons.anchor, color: AppColors.accent, size: 14),
                                  const SizedBox(width: 6),
                                  Text(widget.marina['name'], style: const TextStyle(fontSize: 14, color: Colors.white70)),
                                ]),
                              ],
                            ),
                          ),
                          Positioned(
                            top: 16, right: 16,
                            child: GestureDetector(
                              onTap: () => Navigator.pop(ctx),
                              child: Container(
                                decoration: BoxDecoration(color: Colors.black.withOpacity(0.4), shape: BoxShape.circle),
                                padding: const EdgeInsets.all(8),
                                child: const Icon(Icons.close, color: Colors.white, size: 18),
                              ),
                            ),
                          ),
                        ],
                      ),

                      Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Slip specs
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                              decoration: BoxDecoration(
                                color: AppColors.backgroundAlt,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _specChip(Icons.straighten, '${slip['length']}ft', 'Length'),
                                  _divider(),
                                  _specChip(Icons.swap_vert, '${slip['width']}ft', 'Width'),
                                  _divider(),
                                  _specChip(Icons.attach_money, '\$${slip['price_per_night']}', 'Per Night'),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Date pickers
                            const Text('SELECT DATES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.accent, letterSpacing: 1.5)),
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
                                const SizedBox(width: 16),
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
                            const SizedBox(height: 32),

                            // Price summary
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppColors.backgroundAlt,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('$days night${days > 1 ? 's' : ''} × \$${pricePerNight.toStringAsFixed(0)}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                                      const SizedBox(height: 4),
                                      const Text('Total Amount', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
                                    ],
                                  ),
                                  Text('\$${total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.lock, size: 12, color: AppColors.textMuted),
                                const SizedBox(width: 6),
                                Text('Secure payment via Razorpay', style: TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w500)),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Action button
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
                                  backgroundColor: AppColors.cta,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  elevation: 0,
                                ),
                                icon: isProcessing
                                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                    : const Icon(Icons.payment_rounded, size: 20),
                                label: Text(isProcessing ? 'Processing...' : 'Pay & Book Now', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
        Icon(icon, color: AppColors.textSecondary, size: 20),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontSize: 15)),
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      ],
    );
  }

  Widget _divider() => Container(height: 40, width: 1, color: AppColors.border);

  Widget _dateTile({required String label, required DateTime date, required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, color: AppColors.textSecondary, size: 14),
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
            ]),
            const SizedBox(height: 8),
            Text('${date.day} ${_monthName(date.month)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            Text('${date.year}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
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
      backgroundColor: AppColors.backgroundAlt,
      appBar: AppBar(
        title: Text(widget.marina['name'], style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        backgroundColor: AppColors.background,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(height: 1, color: AppColors.border)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero section
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceDark,
                      image: DecorationImage(
                        image: NetworkImage('https://images.unsplash.com/photo-1544551763-46a013bb70d5?q=80&w=2070&auto=format&fit=crop'),
                        fit: BoxFit.cover,
                        opacity: 0.3,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 80),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Container(width: 20, height: 3, decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(2))),
                          const SizedBox(width: 10),
                          const Text('MARINA DETAILS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.accent, letterSpacing: 1.5)),
                        ]),
                        const SizedBox(height: 16),
                        Text(widget.marina['name'], style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -1)),
                        const SizedBox(height: 8),
                        Row(children: [
                          const Icon(Icons.location_on, color: AppColors.accent, size: 18),
                          const SizedBox(width: 8),
                          Text(widget.marina['location'] ?? 'Location unavailable', style: const TextStyle(fontSize: 18, color: Colors.white70)),
                        ]),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: 600,
                          child: Text(
                            widget.marina['description'] ?? 'No description available for this marina.',
                            style: const TextStyle(fontSize: 16, color: Colors.white70, height: 1.6),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Slips grid
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 60),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Container(width: 20, height: 3, decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(2))),
                          const SizedBox(width: 10),
                          const Text('AVAILABILITY', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.accent, letterSpacing: 1.5)),
                        ]),
                        const SizedBox(height: 12),
                        const Text('Available Slips', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.5)),
                        const SizedBox(height: 32),
                        
                        if (_slips.isEmpty)
                          const Text('No slips currently available for this marina.', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                        
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 400,
                            mainAxisExtent: 380,
                            crossAxisSpacing: 24,
                            mainAxisSpacing: 24,
                          ),
                          itemCount: _slips.length,
                          itemBuilder: (context, index) {
                            final slip = _slips[index];
                            final imageUrl = _slipImages[index % _slipImages.length];
                            return TweenAnimationBuilder(
                              tween: Tween<double>(begin: 0, end: 1),
                              duration: Duration(milliseconds: 400 + (index * 80)),
                              curve: Curves.easeOutCubic,
                              builder: (context, double value, child) => Transform.translate(
                                offset: Offset(0, 30 * (1 - value)), child: Opacity(opacity: value, child: child)),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.border),
                                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Image.network(imageUrl, width: double.infinity, fit: BoxFit.cover,
                                        errorBuilder: (ctx, err, st) => Container(color: AppColors.backgroundAlt)),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(24),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(slip['name'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                                          const SizedBox(height: 8),
                                          Row(children: [
                                            const Icon(Icons.straighten, color: AppColors.textSecondary, size: 16),
                                            const SizedBox(width: 6),
                                            Text('${slip['length']}ft × ${slip['width']}ft', style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                                          ]),
                                          const SizedBox(height: 16),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  const Text('Per night', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                                  Text('\$${slip['price_per_night']}', style: const TextStyle(fontSize: 24, color: AppColors.textPrimary, fontWeight: FontWeight.w800)),
                                                ],
                                              ),
                                              ElevatedButton(
                                                onPressed: () => _showBookingDialog(context, slip),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: AppColors.cta,
                                                  foregroundColor: Colors.white,
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                                  elevation: 0,
                                                ),
                                                child: const Text('Book', style: TextStyle(fontWeight: FontWeight.w700)),
                                              ),
                                            ],
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
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
