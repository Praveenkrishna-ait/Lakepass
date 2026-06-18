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

  Widget _statCard(String label, String value, Color valueColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary, letterSpacing: 0.5)),
          const SizedBox(height: 12),
          Text(value, style: TextStyle(fontSize: 40, fontWeight: FontWeight.w800, color: valueColor, letterSpacing: -1)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundAlt,
      appBar: AppBar(
        title: Text('${widget.marinaName} Analytics', style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        backgroundColor: AppColors.background,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(height: 1, color: AppColors.border)),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
        : Padding(
            padding: const EdgeInsets.all(32.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Container(width: 20, height: 3, decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(2))),
                        const SizedBox(width: 10),
                        const Text('OVERVIEW', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.accent, letterSpacing: 1.5)),
                      ]),
                      const SizedBox(height: 24),
                      _statCard('Total Revenue', '\$${_analytics?['total_revenue'] ?? 0}', AppColors.success),
                      const SizedBox(height: 24),
                      _statCard('Confirmed Bookings', '${_analytics?['total_bookings'] ?? 0}', AppColors.textPrimary),
                      const SizedBox(height: 32),
                      const Text('Top Performing Slips', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                      const SizedBox(height: 16),
                      ...((_analytics?['popular_slips'] as List<dynamic>?) ?? []).map((slip) => 
                        Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: ListTile(
                            title: Text(slip['name'], style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: AppColors.backgroundAlt, borderRadius: BorderRadius.circular(20)),
                              child: Text('${slip['booking_count']} bookings', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                            ),
                          )
                        )
                      ),
                    ],
                  )
                ),
                const SizedBox(width: 40),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Container(width: 20, height: 3, decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(2))),
                        const SizedBox(width: 10),
                        const Text('RECENT ACTIVITY', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.accent, letterSpacing: 1.5)),
                      ]),
                      const SizedBox(height: 24),
                      if (_bookings.isEmpty) const Text('No reservations yet.', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _bookings.length,
                          itemBuilder: (context, index) {
                            final b = _bookings[index];
                            final isConfirmed = b['status'] == 'confirmed';
                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.border),
                                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2))],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(b['customer_name'] ?? 'Customer', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Icon(Icons.directions_boat_outlined, size: 14, color: AppColors.textSecondary),
                                              const SizedBox(width: 4),
                                              Text('Slip: ${b['slip_name']}', style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                                              const SizedBox(width: 16),
                                              const Icon(Icons.calendar_today, size: 14, color: AppColors.textSecondary),
                                              const SizedBox(width: 4),
                                              Text('${b['start_date'].toString().split('T')[0]} to ${b['end_date'].toString().split('T')[0]}', style: const TextStyle(color: AppColors.textSecondary)),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: isConfirmed ? AppColors.success.withOpacity(0.1) : AppColors.warning.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(b['status'].toString().toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: isConfirmed ? AppColors.success : AppColors.warning)),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text('\$${b['total_price']}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                                        if (isConfirmed) ...[
                                          const SizedBox(height: 12),
                                          OutlinedButton.icon(
                                            onPressed: () => _cancelBooking(b['id']),
                                            icon: const Icon(Icons.cancel, size: 16),
                                            label: const Text('Cancel'),
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: AppColors.error,
                                              side: BorderSide(color: AppColors.error.withOpacity(0.3)),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                            ),
                                          ),
                                        ],
                                      ],
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
                )
              ],
            ),
          )
    );
  }
}
