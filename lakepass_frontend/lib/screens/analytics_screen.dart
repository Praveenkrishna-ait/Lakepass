import 'package:flutter/material.dart';
import '../services/analytics_service.dart';
import '../services/booking_service.dart';
import '../utils/constants.dart';

class AnalyticsScreen extends StatefulWidget {
  final int marinaId;
  final String marinaName;

  const AnalyticsScreen({super.key, required this.marinaId, required this.marinaName});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _analytics;
  List<dynamic> _bookings = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final analytics = await AnalyticsService.getAnalytics(widget.marinaId);
    final bookings = await AnalyticsService.getMarinaBookings(widget.marinaId);
    setState(() {
      _analytics = analytics;
      _bookings = bookings;
      _isLoading = false;
    });
  }

  void _cancelBooking(int bookingId) async {
    final success = await BookingService.cancelBooking(bookingId);
    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking cancelled successfully'), backgroundColor: Colors.green));
      }
      _fetchData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.marinaName} Analytics & Occupancy'), backgroundColor: AppColors.surface),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
                        child: Column(
                          children: [
                            const Text('Total Revenue', style: TextStyle(fontSize: 18, color: AppColors.textSecondary)),
                            const SizedBox(height: 8),
                            Text('\$${_analytics?['total_revenue'] ?? 0}', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.greenAccent)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
                        child: Column(
                          children: [
                            const Text('Confirmed Bookings', style: TextStyle(fontSize: 18, color: AppColors.textSecondary)),
                            const SizedBox(height: 8),
                            Text('${_analytics?['total_bookings'] ?? 0}', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.primary)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text('Top Performing Slips', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      ...((_analytics?['popular_slips'] as List<dynamic>?) ?? []).map((slip) => 
                        Card(
                          color: AppColors.surface,
                          child: ListTile(
                            title: Text(slip['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                            trailing: Text('${slip['booking_count']} bookings'),
                          )
                        )
                      ),
                    ],
                  )
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Recent Reservations', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      if (_bookings.isEmpty) const Text('No reservations yet.', style: TextStyle(color: AppColors.textSecondary)),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _bookings.length,
                          itemBuilder: (context, index) {
                            final b = _bookings[index];
                            final isConfirmed = b['status'] == 'confirmed';
                            return Card(
                              color: AppColors.surface,
                              margin: const EdgeInsets.only(bottom: 16),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                title: Text('${b['customer_name']} (Slip: ${b['slip_name']})', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                subtitle: Text('Dates: ${b['start_date'].toString().split('T')[0]} to ${b['end_date'].toString().split('T')[0]}\nStatus: ${b['status'].toString().toUpperCase()}'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('\$${b['total_price']}', style: const TextStyle(fontSize: 20, color: AppColors.primary, fontWeight: FontWeight.bold)),
                                    if (isConfirmed) ...[
                                      const SizedBox(width: 16),
                                      IconButton(icon: const Icon(Icons.cancel, color: AppColors.error), onPressed: () => _cancelBooking(b['id'])),
                                    ]
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
              ],
            ),
          )
    );
  }
}
