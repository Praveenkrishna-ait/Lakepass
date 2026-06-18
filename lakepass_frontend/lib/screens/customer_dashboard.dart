import 'package:flutter/material.dart';
import '../services/booking_service.dart';
import '../utils/constants.dart';
import '../widgets/glass_card.dart';

class CustomerDashboard extends StatefulWidget {
  const CustomerDashboard({super.key});
  @override
  State<CustomerDashboard> createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends State<CustomerDashboard> {
  bool _isLoading = true;
  List<dynamic> _myBookings = [];

  @override
  void initState() { super.initState(); _fetchBookings(); }

  Future<void> _fetchBookings() async {
    final bookings = await BookingService.getMyBookings();
    setState(() { _myBookings = bookings; _isLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundAlt,
      appBar: AppBar(
        title: const Text('My Bookings', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        backgroundColor: AppColors.background,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(height: 1, color: AppColors.border)),
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
        : _myBookings.isEmpty
          ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.sailing_rounded, size: 64, color: AppColors.textMuted),
              const SizedBox(height: 16),
              const Text('No bookings yet', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              const Text('Start searching for slips to make your first booking!', style: TextStyle(color: AppColors.textSecondary)),
            ]))
          : Padding(
              padding: const EdgeInsets.all(32),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(width: 20, height: 3, decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(2))),
                  const SizedBox(width: 10),
                  const Text('RESERVATIONS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.accent, letterSpacing: 1.5)),
                ]),
                const SizedBox(height: 12),
                const Text('Your Reservations', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.5)),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView.builder(
                    itemCount: _myBookings.length,
                    itemBuilder: (context, index) {
                      final booking = _myBookings[index];
                      return TweenAnimationBuilder(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: Duration(milliseconds: 400 + (index * 100)),
                        curve: Curves.easeOutCubic,
                        builder: (context, double value, child) => Transform.translate(
                          offset: Offset(0, 30 * (1 - value)), child: Opacity(opacity: value, child: child)),
                        child: GlassCard(
                          padding: const EdgeInsets.all(24),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              Expanded(child: Text(
                                '${booking['marina_name'] ?? 'Marina'} - Slip ${booking['slip_name'] ?? booking['slip_id']}',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary), overflow: TextOverflow.ellipsis)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: booking['status'] == 'confirmed' ? AppColors.success.withOpacity(0.1) : AppColors.warning.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: booking['status'] == 'confirmed' ? AppColors.success : AppColors.warning)),
                                child: Text(booking['status'].toString().toUpperCase(),
                                  style: TextStyle(color: booking['status'] == 'confirmed' ? AppColors.success : AppColors.warning, fontWeight: FontWeight.w700, fontSize: 11)),
                              ),
                            ]),
                            const SizedBox(height: 16),
                            Row(children: [
                              const Icon(Icons.calendar_today, color: AppColors.textMuted, size: 16),
                              const SizedBox(width: 8),
                              Text('${booking['start_date'].toString().split('T')[0]} to ${booking['end_date'].toString().split('T')[0]}',
                                style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                            ]),
                            const SizedBox(height: 16),
                            Divider(color: AppColors.border, height: 1),
                            const SizedBox(height: 16),
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              Text('\$${booking['total_price']}', style: const TextStyle(fontSize: 24, color: AppColors.textPrimary, fontWeight: FontWeight.w800)),
                              if (booking['status'] == 'confirmed') ...[
                                ElevatedButton.icon(
                                  onPressed: () async { await BookingService.cancelBooking(booking['id']); _fetchBookings(); },
                                  icon: const Icon(Icons.cancel, size: 16),
                                  label: const Text('Cancel'),
                                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), elevation: 0),
                                ),
                              ],
                            ]),
                          ]),
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
