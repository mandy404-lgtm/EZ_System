import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://10.0.2.2:8000";

  static Future<Map> getDashboard() async {
    final res = await http.get(Uri.parse("$baseUrl/dashboard"));
    return jsonDecode(res.body);
  }

  static Future<Map> getInflation() async {
    final res = await http.get(Uri.parse("$baseUrl/inflation-analysis"));
    return jsonDecode(res.body);
  }

  static Future<Map> getForecast() async {
    final res = await http.get(Uri.parse("$baseUrl/demand-forecast"));
    return jsonDecode(res.body);
  }

  static Future<Map> getCompetitor() async {
    final res = await http.get(Uri.parse("$baseUrl/competitor-benchmark"));
    return jsonDecode(res.body);
  }
}