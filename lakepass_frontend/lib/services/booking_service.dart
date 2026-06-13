import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookingService {
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<Map<String, dynamic>> createBooking(int slipId, String startDate, String endDate) async {
    try {
      final token = await _getToken();
      if (token == null) return {'error': 'User not logged in'};

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/bookings'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode({'slip_id': slipId, 'start_date': startDate, 'end_date': endDate}),
      );

      if (response.statusCode == 201) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        final err = jsonDecode(response.body);
        return {'error': err['msg'] ?? 'Failed to book slip'};
      }
    } catch (e) {
      return {'error': 'Network error'};
    }
  }

  static Future<bool> cancelBooking(int bookingId) async {
    try {
      final token = await _getToken();
      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}/bookings/$bookingId/cancel'),
        headers: {'Authorization': 'Bearer $token'},
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<List<dynamic>> getMyBookings() async {
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/bookings/my-bookings'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
