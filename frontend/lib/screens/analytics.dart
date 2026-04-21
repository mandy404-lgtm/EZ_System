import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/services/user_service.dart';
import 'package:http/http.dart' as http;

class Analytics extends StatefulWidget {
  const Analytics({super.key});

  @override
 State<Analytics> createState() => _AnalyticsState();
}

class _AnalyticsState extends State<Analytics> {
  final String baseUrl = "http://10.0.2.2:8000";

  late Future<Map<String, dynamic>> aiData;

  @override
  void initState() {
    super.initState();
    aiData = getAI();
  }

  // 📡 CALL AI API
  Future<Map<String, dynamic>> getAI() async {

  final userId = await UserService.getUserId();

  final res = await http.post(
    Uri.parse("http://10.0.2.2:8000/ai/recommendation"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "user_id": userId
    }),
  );

  return jsonDecode(res.body);
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f6f8),

      appBar: AppBar(
        title: const Text("AI Decision Engine"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),

      body: FutureBuilder<Map<String, dynamic>>(
        future: aiData,
        builder: (context, snapshot) {

          // 🔄 LOADING
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // ❌ ERROR
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final data = snapshot.data!;

          final recommendation = data["recommendation"] ?? "No recommendation";
          final explanation = data["explanation"] ?? "No explanation";
          final tradeOff = data["trade_off"] ?? "No trade-off data";
          final forecast = data["forecast"] ?? "No forecast available";
          final confidence = data["confidence"] ?? 0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const Text(
                  "Z.AI GLM Business Intelligence",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 20),

                // 💡 RECOMMENDATION
                _aiCard(
                  title: "Recommendation",
                  content: recommendation,
                  icon: Icons.lightbulb,
                  color: Colors.green,
                ),

                const SizedBox(height: 12),

                // 🧠 EXPLANATION
                _aiCard(
                  title: "Explanation",
                  content: explanation,
                  icon: Icons.psychology,
                  color: Colors.blue,
                ),

                const SizedBox(height: 12),

                // ⚖️ TRADE OFF
                _aiCard(
                  title: "Trade-Off Analysis",
                  content: tradeOff,
                  icon: Icons.balance,
                  color: Colors.orange,
                ),

                const SizedBox(height: 12),

                // 🔮 FORECAST
                _aiCard(
                  title: "Forecast",
                  content: forecast,
                  icon: Icons.trending_up,
                  color: Colors.purple,
                ),

                const SizedBox(height: 12),

                // 🎯 CONFIDENCE
                _aiCard(
                  title: "Confidence Score",
                  content: "${(confidence * 100).toStringAsFixed(1)}%",
                  icon: Icons.verified,
                  color: Colors.teal,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // 🧠 AI CARD UI
  Widget _aiCard({
    required String title,
    required String content,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          )
        ],
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 6),

                Text(
                  content,
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}