import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const baseUrl = "http://10.0.2.2:8000";

  // LOGIN
  static Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('user_id', data['user_id']);
      return true;
    }
    return false;
  }

  // GET DASHBOARD
  static Future getDashboard(userId) async {}

  // ADD SALES
  static Future addSales(data) async {}

  // GET AI RESULT
  static Future getAI(data) async {}
}
