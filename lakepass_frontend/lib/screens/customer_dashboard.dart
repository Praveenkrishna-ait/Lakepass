import 'package:flutter/material.dart';
import '../services/booking_service.dart';
import '../utils/constants.dart';

class CustomerDashboard extends StatefulWidget {
  const CustomerDashboard({super.key});

  @override
  State<CustomerDashboard> createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends State<CustomerDashboard> {
  bool _isLoading = true;
  List<dynamic> _myBookings = [];

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    final bookings = await BookingService.getMyBookings();
    setState(() {
      _myBookings = bookings;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Bookings'), backgroundColor: AppColors.surface),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _myBookings.isEmpty
            ? const Center(
                child: Text('No bookings found. Start searching for slips!', style: TextStyle(color: AppColors.textSecondary, fontSize: 18)),
              )
            : Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Your Reservations', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    const SizedBox(height: 24),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _myBookings.length,
                        itemBuilder: (context, index) {
                          final booking = _myBookings[index];
                          return Card(
                            color: AppColors.surface,
                            margin: const EdgeInsets.only(bottom: 16),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(24),
                              title: Text('${booking['marina_name'] ?? 'Marina'} - Slip ${booking['slip_name'] ?? booking['slip_id']}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text('Dates: ${booking['start_date'].toString().split('T')[0]} to ${booking['end_date'].toString().split('T')[0]}\nStatus: ${booking['status'].toString().toUpperCase()}', style: const TextStyle(fontSize: 16, height: 1.5, color: AppColors.textSecondary)),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('\$${booking['total_price']}', style: const TextStyle(fontSize: 24, color: AppColors.primary, fontWeight: FontWeight.bold)),
                                  if (booking['status'] == 'confirmed') ...[
                                    const SizedBox(width: 16),
                                    ElevatedButton(
                                      onPressed: () async {
                                        await BookingService.cancelBooking(booking['id']);
                                        _fetchBookings();
                                      },
                                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
                                      child: const Text('Cancel'),
                                    ),
                                  ]
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  ],
                ),
              ),
    );
  }
}
