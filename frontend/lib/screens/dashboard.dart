import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  // 📦 MOCK DATA (replace API later)
  double revenue = 328000;
  double cost = 198000;

  double get profit => revenue - cost;

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

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            /// 💰 REVENUE
            _kpiCard(
              title: "Total Revenue",
              value: "RM ${revenue.toStringAsFixed(2)}",
              icon: Icons.attach_money,
              color: Colors.green,
            ),

            const SizedBox(height: 12),

            /// PROFIT + COST
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

            /// 🧠 AI INSIGHTS
            const Text(
              "AI Insights",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            _aiCard(
              icon: Icons.insights,
              iconBg: profit > 0
                  ? Colors.green.shade100
                  : Colors.red.shade100,
              iconColor: profit > 0 ? Colors.green : Colors.red,
              title: "Profit Insight",
              desc: profit > 0
                  ? "Your business is profitable. Keep going."
                  : "You are in loss. Reduce cost or increase price.",
              action: "View more →",
            ),

            _aiCard(
              icon: Icons.trending_up,
              iconBg: Colors.blue.shade100,
              iconColor: Colors.blue,
              title: "Revenue Insight",
              desc: "Total revenue is RM ${revenue.toStringAsFixed(2)}.",
              action: "View analysis →",
            ),

            _aiCard(
              icon: Icons.warning_amber_rounded,
              iconBg: Colors.amber.shade100,
              iconColor: Colors.amber,
              title: "Cost Insight",
              desc: "Total cost is RM ${cost.toStringAsFixed(2)}.",
              action: "Optimize cost →",
            ),
          ],
        ),
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
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 12),
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
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 13,
                  ),
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
