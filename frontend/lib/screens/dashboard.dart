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
                _kpiCard(
                  title: "Total Revenue",
                  value: "RM ${revenue.toStringAsFixed(2)}",
                  icon: Icons.attach_money,
                  color: Colors.green,
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _kpiCard(
                        title: "Profit",
                        value: "RM ${profit.toStringAsFixed(2)}",
                        icon: Icons.trending_up,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _kpiCard(
                        title: "Cost",
                        value: "RM ${cost.toStringAsFixed(2)}",
                        icon: Icons.money_off,
                        color: Colors.orange,
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
                  icon: Icons.warning_amber_rounded,
                  iconBg: profit > 0
                      ? Colors.green.shade100
                      : Colors.orange.shade100,
                  iconColor: profit > 0 ? Colors.green : Colors.orange,
                  title: "Profit Insight",
                  desc: profit > 0
                      ? "Your business is profitable. Keep optimizing pricing."
                      : "You are currently at a loss. Consider reducing costs.",
                  action: "View detailed analysis →",
                ),

                _aiCard(
                  icon: Icons.trending_up,
                  iconBg: Colors.blue.shade100,
                  iconColor: Colors.blue,
                  title: "Revenue Insight",
                  desc:
                      "Total revenue generated is RM ${revenue.toStringAsFixed(2)}.",
                  action: "View forecast →",
                ),

                _aiCard(
                  icon: Icons.trending_down,
                  iconBg: Colors.amber.shade100,
                  iconColor: Colors.amber.shade700,
                  title: "Cost Insight",
                  desc: "Total cost incurred is RM ${cost.toStringAsFixed(2)}.",
                  action: "View comparison →",
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // 📊 KPI CARD
  Widget _kpiCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ICON
          Icon(icon, color: color, size: 28),

          const SizedBox(height: 10),

          /// TITLE
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13)),

          const SizedBox(height: 5),

          /// VALUE
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // 🤖 AI CARD
  Widget _aiCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String desc,
    required String action,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ICON
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor),
          ),

          const SizedBox(width: 12),

          /// TEXT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 5),

                Text(
                  desc,
                  style: const TextStyle(color: Colors.black87, fontSize: 13),
                ),

                const SizedBox(height: 8),

                Text(
                  action,
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
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
