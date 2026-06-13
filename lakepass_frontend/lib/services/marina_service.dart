import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MarinaService {
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<List<dynamic>> getAllMarinas() async {
    try {
      final response = await http.get(Uri.parse('${ApiConstants.baseUrl}/marinas'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>?> createMarina(String name, String location, String description) async {
    try {
      final token = await _getToken();
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/marinas'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode({'name': name, 'location': location, 'description': description}),
      );
      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<List<dynamic>> getSlips(int marinaId) async {
    try {
      final response = await http.get(Uri.parse('${ApiConstants.baseUrl}/slips/marina/$marinaId'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>?> createSlip(int marinaId, String name, int length, int width, double price) async {
    try {
      final token = await _getToken();
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/slips'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode({'marina_id': marinaId, 'name': name, 'length': length, 'width': width, 'price_per_night': price}),
      );
      if (response.statusCode == 201) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        try {
          return {'success': false, 'error': jsonDecode(response.body)['msg'] ?? 'Unknown error'};
        } catch(_) {
          return {'success': false, 'error': 'Server Error: ${response.statusCode}'};
        }
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error'};
    }
  }
}
