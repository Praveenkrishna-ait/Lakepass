import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class PaymentService {
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  /// Step 1: Create a Razorpay order on the backend
  static Future<Map<String, dynamic>> createOrder({
    required int slipId,
    required String startDate,
    required String endDate,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) return {'error': 'User not logged in'};

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/payments/create-order'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'slip_id': slipId,
          'start_date': startDate,
          'end_date': endDate,
        }),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        final err = jsonDecode(response.body);
        return {'error': err['msg'] ?? 'Failed to create payment order'};
      }
    } catch (e) {
      return {'error': 'Network error: $e'};
    }
  }

  /// Step 2: Verify payment on the backend after Razorpay checkout
  static Future<Map<String, dynamic>> verifyPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
    required int slipId,
    required String startDate,
    required String endDate,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) return {'error': 'User not logged in'};

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/payments/verify'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'razorpay_order_id': razorpayOrderId,
          'razorpay_payment_id': razorpayPaymentId,
          'razorpay_signature': razorpaySignature,
          'slip_id': slipId,
          'start_date': startDate,
          'end_date': endDate,
        }),
      );

      if (response.statusCode == 201) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        final err = jsonDecode(response.body);
        return {'error': err['msg'] ?? 'Payment verification failed'};
      }
    } catch (e) {
      return {'error': 'Network error: $e'};
    }
  }
}
