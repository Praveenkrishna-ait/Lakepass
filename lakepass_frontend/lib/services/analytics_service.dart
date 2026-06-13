import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AnalyticsService {
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<Map<String, dynamic>?> getAnalytics(int marinaId) async {
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/analytics/$marinaId'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<List<dynamic>> getMarinaBookings(int marinaId) async {
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/bookings/marina/$marinaId'),
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
