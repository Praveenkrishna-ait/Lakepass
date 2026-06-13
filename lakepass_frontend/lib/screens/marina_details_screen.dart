import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import '../services/marina_service.dart';
import '../services/payment_service.dart';
import '../services/razorpay_web.dart';
import '../utils/constants.dart';
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please login as a customer to book a slip')));
      Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      return;
    }

    DateTime startDate = DateTime.now();
    DateTime endDate = DateTime.now().add(const Duration(days: 1));
    bool isProcessing = false;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            int days = endDate.difference(startDate).inDays;
            if (days <= 0) days = 1;
            final pricePerNight = double.tryParse(slip['price_per_night'].toString()) ?? 0.0;
            final total = days * pricePerNight;

            return AlertDialog(
              backgroundColor: AppColors.surface,
              title: Text('Book ${slip['name']}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${widget.marina['name']} - ${slip['length']}ft x ${slip['width']}ft'),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          final picked = await showDatePicker(context: context, initialDate: startDate, firstDate: DateTime.now(), lastDate: DateTime(2030));
                          if (picked != null) {
                            setState(() {
                              startDate = picked;
                              if (endDate.isBefore(startDate)) {
                                endDate = startDate.add(const Duration(days: 1));
                              }
                            });
                          }
                        },
                        child: const Text('Start Date'),
                      ),
                      const SizedBox(width: 8),
                      Text('${startDate.toLocal()}'.split(' ')[0])
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          final picked = await showDatePicker(context: context, initialDate: endDate, firstDate: startDate, lastDate: DateTime(2030));
                          if (picked != null) setState(() => endDate = picked);
                        },
                        child: const Text('End Date'),
                      ),
                      const SizedBox(width: 8),
                      Text('${endDate.toLocal()}'.split(' ')[0])
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Icon(Icons.currency_rupee, color: AppColors.primary, size: 22),
                      const SizedBox(width: 4),
                      Text(
                        '${total.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'You will be redirected to Razorpay to complete payment.',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                ElevatedButton.icon(
                  onPressed: (isProcessing || endDate.isBefore(startDate)) ? null : () async {
                    setState(() => isProcessing = true);

                    final startStr = startDate.toIso8601String().split('T')[0];
                    final endStr = endDate.toIso8601String().split('T')[0];

                    // Step 1: Create Razorpay order on backend
                    final orderResult = await PaymentService.createOrder(
                      slipId: slip['id'],
                      startDate: startStr,
                      endDate: endStr,
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

                    // Step 2: Open Razorpay Checkout popup
                    openRazorpayCheckout(
                      key: orderData['key_id'],
                      amount: orderData['amount'],
                      currency: orderData['currency'],
                      orderId: orderData['order_id'],
                      description: 'Booking: ${slip['name']} at ${widget.marina['name']}',
                      prefillName: auth.name,
                      onSuccess: (razorpayOrderId, razorpayPaymentId, razorpaySignature) async {
                        // Step 3: Verify payment on backend
                        final verifyResult = await PaymentService.verifyPayment(
                          razorpayOrderId: razorpayOrderId,
                          razorpayPaymentId: razorpayPaymentId,
                          razorpaySignature: razorpaySignature,
                          slipId: slip['id'],
                          startDate: startStr,
                          endDate: endStr,
                        );

                        if (!ctx.mounted) return;
                        Navigator.pop(ctx);

                        if (verifyResult['success'] == true) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('✅ Payment Successful! Booking Confirmed!'),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 4),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Payment received but verification failed: ${verifyResult['error']}'),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                      },
                      onError: (error) {
                        setState(() => isProcessing = false);
                        if (!ctx.mounted) return;
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Payment failed: $error'), backgroundColor: AppColors.error),
                        );
                      },
                      onCancel: () {
                        setState(() => isProcessing = false);
                        // User dismissed the popup — don't close the dialog, let them retry
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.background,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  icon: isProcessing
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.background))
                      : const Icon(Icons.payment),
                  label: Text(isProcessing ? 'Processing...' : 'Pay & Book'),
                )
              ],
            );
          }
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.marina['name']), backgroundColor: AppColors.surface),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.marina['description'] ?? 'No description available', style: const TextStyle(fontSize: 18, color: AppColors.textSecondary)),
                const SizedBox(height: 32),
                const Text('Available Slips', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                if (_slips.isEmpty)
                  const Text('No slips available for this marina.', style: TextStyle(color: AppColors.textSecondary)),
                Expanded(
                  child: ListView.builder(
                    itemCount: _slips.length,
                    itemBuilder: (context, index) {
                      final slip = _slips[index];
                      return Card(
                        color: AppColors.surface,
                        margin: const EdgeInsets.only(bottom: 16),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(24),
                          title: Text(slip['name'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          subtitle: Text('${slip['length']}ft x ${slip['width']}ft'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('₹${slip['price_per_night']}/night', style: const TextStyle(fontSize: 20, color: AppColors.primary, fontWeight: FontWeight.bold)),
                              const SizedBox(width: 24),
                              ElevatedButton(
                                onPressed: () => _showBookingDialog(context, slip),
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.background),
                                child: const Text('Book Now'),
                              )
                            ],
                          )
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          )
    );
  }
}
