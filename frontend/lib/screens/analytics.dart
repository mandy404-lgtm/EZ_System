import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/services/user_service.dart';
import 'package:http/http.dart' as http;

class Analytics extends StatefulWidget {
  const Analytics({super.key});

<<<<<<< HEAD
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
=======
  // 🤖 AI OUTPUT (replace later with GLM API)
  final String recommendation =
      "Increase price by 5% on high-demand products and introduce bundle promotions for slow-moving items.";

  final String explanation =
      "Cost increased due to inflation and supplier price adjustment. Demand remains stable but price sensitivity is increasing in customers.";

  final String tradeOff =
      "Price vs Demand:\n"
      "- Higher price → lower demand but higher margin\n"
      "- Lower price → higher demand but lower margin\n\n"
      "Cost vs Profit:\n"
      "- Increasing cost reduces profit margin\n"
      "- Optimizing pricing can recover 12–18% profit";

  final String forecast =
      "📈 Next 7 Days Forecast:\n"
      "• Revenue: +15% if price adjusted\n"
      "• Demand: +10% during weekend\n"
      "• Profit: +18% improvement potential";

  final String impact =
      "💥 AI Impact Summary\n\n"
      "💰 Revenue\nRM20,000 → RM24,000\n+20% ↑\n\n"
      "💵 Profit\nRM5,000 → RM10,500\n+110% ↑\n\n"
      "💸 Cost\nRM15,000 → RM13,500\n-10% ↓\n\n"
      "⏱️ Time Saved\n5 hrs/week → 30 mins/week\n-90% ↓";
>>>>>>> 2b11b5c212a31e8bcaabfdbdd2dc9714091abd9e

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

<<<<<<< HEAD
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
=======
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Z.AI GLM Intelligence System",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            _card(
              title: "AI Recommendation",
              content: recommendation,
              icon: Icons.lightbulb,
              color: Colors.green,
            ),

            const SizedBox(height: 12),

            _card(
              title: "Trade-Off Analysis",
              content: tradeOff,
              icon: Icons.balance,
              color: Colors.orange,
            ),

            const SizedBox(height: 12),

            _card(
              title: "Explanation (GLM Reasoning)",
              content: explanation,
              icon: Icons.psychology,
              color: Colors.blue,
            ),

            const SizedBox(height: 12),

            _card(
              title: "Forecast",
              content: forecast,
              icon: Icons.trending_up,
              color: Colors.purple,
            ),

            const SizedBox(height: 12),

            // 💥 IMPACT ANALYSIS (SAME STYLE AS FORECAST)
            _card(
              title: "AI Impact Analysis",
              content:
                  "💰 Revenue\nRM20,000 → RM24,000 (+20%)\n\n"
                  "💵 Profit\nRM5,000 → RM10,500 (+110%)\n\n"
                  "💸 Cost\nRM15,000 → RM13,500 (-10%)\n\n"
                  "⏱️ Time Saved\n5 hrs/week → 30 mins/week (-90%)",
              icon: Icons.insights,
              color: Colors.redAccent,
            ),
          ],
        ),
>>>>>>> 2b11b5c212a31e8bcaabfdbdd2dc9714091abd9e
      ),
    );
  }

<<<<<<< HEAD
  // 🧠 AI CARD UI
  Widget _aiCard({
=======
  // 🧠 REUSABLE CARD
  Widget _card({
>>>>>>> 2b11b5c212a31e8bcaabfdbdd2dc9714091abd9e
    required String title,
    required String content,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),

        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
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
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
