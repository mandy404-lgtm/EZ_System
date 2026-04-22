import 'dart:convert'; // 用于 jsonEncode 和 jsonDecode
import 'package:frontend/models/product.dart';
import 'package:http/http.dart' as http; // 用于发送网络请求
import 'package:shared_preferences/shared_preferences.dart'; // 用于本地存储 user_id
import 'package:flutter/foundation.dart';

class ApiService {
  static const baseUrl = "http://10.0.2.2:8000";

  // --- 1. 登录 (修正类型) ---
  static Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        if (data['user_id'] != null) {
          // ✅ 关键修正：使用 setString 而不是 setInt
          await prefs.setString('user_id', data['user_id'].toString());
          return true;
        }
      }
      return false;
    } catch (e) {
      rethrow; 
    }
  }

  // --- 2. 注册 (修正类型) ---
  static Future<bool> register(String email, String password, String businessName) async {
  try {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "user_id": "U${DateTime.now().millisecondsSinceEpoch}", // 生成随机ID
        "email": email,
        "password": password,
        "business_name": businessName, // ✅ 这里的 Key 必须和后端的 RegisterRequest 一致
      }),
    );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['user_id'] != null) {
          final prefs = await SharedPreferences.getInstance();
          // ✅ 关键修正：使用 setString
          await prefs.setString('user_id', data['user_id'].toString());
          return true;
        }
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }

  // --- 3. 获取用户资料 (参数改为 String) ---
  static Future<Map<String, dynamic>> getUserProfile(String userId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/users/$userId"), 
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load profile");
    }
  }

  // --- 4. 更新用户资料 (参数改为 String) ---
  static Future<bool> updateProfile(String userId, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse("$baseUrl/users/$userId"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    return response.statusCode == 200;
  }
  
  // --- 5. Dashboard (确保参数也是 String) ---
  // 1. Fetch Dashboard Data (Revenue and Cost)
  static Future<Map<String, dynamic>> getDashboard(String userId) async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/dashboard/$userId"));
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        // Return default values if server fails
        return {"revenue": 0.0, "cost": 0.0};
      }
    } catch (e) {
      print("Dashboard API Error: $e");
      return {"revenue": 0.0, "cost": 0.0};
    }
  }

  // 2. Fetch AI Forecast Data
  static Future<Map<String, dynamic>> getForecast() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/dashboard/demand-forecast"));
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          "forecast": 0,
          "trend": "unknown",
          "explanation": "Could not retrieve AI data."
        };
      }
    } catch (e) {
      print("Forecast API Error: $e");
      return {"forecast": 0, "trend": "error", "explanation": "Connection failed."};
    }
  }

static Future<List<Product>> getProducts(String userId) async {
  try {
    final response = await http.get(Uri.parse("$baseUrl/products/$userId"));
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((item) => Product.fromJson(item)).toList();
    }
    return []; // Return empty list instead of null on 404/500
  } catch (e) {
    print("Fetch Error: $e");
    return [];
  }
}


static Future<bool> addProduct(Map<String, dynamic> data) async {
  try {
    final response = await http.post(
      Uri.parse("$baseUrl/products/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
    // 只有返回 200 才算成功
    return response.statusCode == 200;
  } catch (e) {
    debugPrint("Add Product Error: $e");
    return false;
  }
}
  static Future<bool> updateProduct(Map<String, dynamic> productData) async {
    try {
      final String productId = productData['product_id'];
      final response = await http.put(
        Uri.parse("$baseUrl/products/$productId"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(productData),
      );
      return response.statusCode == 200; // Returns true if updated successfully
    } catch (e) {
      print("Update Product Error: $e");
      return false;
    }
  }

  static Future<bool> recordSale(Map<String, dynamic> data) async {
  try {
    final response = await http.post(
      Uri.parse("$baseUrl/sales/record"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
    return response.statusCode == 200;
  } catch (e) {
    debugPrint("Record Sale Error: $e");
    return false;
  }
}

static Future<List<dynamic>> getAlerts(String userId) async {
  try {
    final response = await http.get(
      Uri.parse("$baseUrl/alerts/$userId"), // 假设后端路由是 /alerts/{user_id}
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return [];
  } catch (e) {
    print("Alerts API Error: $e");
    return [];
  }
}

}

