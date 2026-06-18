import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  String? _userId;
  String? _role;
  String? _name;

  bool get isAuthenticated => _token != null;
  String? get role => _role;
  String? get token => _token;
  String? get name => _name;
  String? get userId => _userId;

  Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        _userId = data['user']['id'].toString();
        _role = data['user']['role'];
        _name = data['user']['name'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);
        await prefs.setString('role', _role!);
        await prefs.setString('name', _name!);
        await prefs.setString('userId', _userId!);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Login Error: $e');
      return false;
    }
  }

  Future<bool> register(String name, String email, String password, String role) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email, 'password': password, 'role': role}),
      );
      
      if (response.statusCode == 201) {
        return await login(email, password);
      }
      return false;
    } catch (e) {
      print('Registration Error: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/auth/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message'] ?? 'Reset email sent successfully.'};
      }
      return {'success': false, 'message': data['message'] ?? data['error'] ?? 'Failed to send reset email.'};
    } catch (e) {
      print('ForgotPassword Error: $e');
      return {'success': false, 'message': 'Network error. Please try again.'};
    }
  }

  void logout() async {
    _token = null;
    _userId = null;
    _role = null;
    _name = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }

  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('token')) return;

    _token = prefs.getString('token');
    _role = prefs.getString('role');
    _name = prefs.getString('name');
    _userId = prefs.getString('userId');
    notifyListeners();
  }
}
