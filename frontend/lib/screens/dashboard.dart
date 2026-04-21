import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/user_service.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late Future<Map<String, dynamic>> dashboardData;

  final String baseUrl = "http://10.0.2.2:8000";

  @override
  void initState() {
    super.initState();
    dashboardData = fetchDashboard();
  }

  // 📡 FETCH DATA FROM API
  Future<Map<String, dynamic>> fetchDashboard() async {

  final userId = await UserService.getUserId();

  final res = await http.get(
    Uri.parse("http://10.0.2.2:8000/dashboard/$userId"),
  );

  return jsonDecode(res.body);
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f6f8),

      appBar: AppBar(
        title: const Text("Business Overview"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),

      body: FutureBuilder<Map<String, dynamic>>(
        future: dashboardData,
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

          double revenue = data['revenue']?.toDouble() ?? 0;
          double cost = data['cost']?.toDouble() ?? 0;
          double profit = data['profit']?.toDouble() ?? 0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const SizedBox(height: 10),

                // 💰 REVENUE CARD
                _card(
                  "Total Revenue",
                  "RM ${revenue.toStringAsFixed(2)}",
                  Icons.attach_money,
                  Colors.green,
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _card(
                        "Profit",
                        "RM ${profit.toStringAsFixed(2)}",
                        Icons.trending_up,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _card(
                        "Cost",
                        "RM ${cost.toStringAsFixed(2)}",
                        Icons.money_off,
                        Colors.orange,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                const Text(
                  "AI Insights",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                // 🧠 INSIGHTS (simple logic for now)
                _aiCard(
                  "Profit Insight",
                  profit > 0
                      ? "Your business is profitable. Keep optimizing pricing."
                      : "You are currently at a loss. Consider reducing costs.",
                  Colors.green,
                ),

                _aiCard(
                  "Revenue Insight",
                  "Total revenue generated is RM ${revenue.toStringAsFixed(2)}.",
                  Colors.blue,
                ),

                _aiCard(
                  "Cost Insight",
                  "Total cost incurred is RM ${cost.toStringAsFixed(2)}.",
                  Colors.orange,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // 📦 CARD UI
  Widget _card(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 8),
              Text(title,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // 🧠 AI CARD
  Widget _aiCard(String title, String desc, Color color) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(Icons.lightbulb, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Text(desc),
              ],
            ),
          )
        ],
      ),
    );
  }
}