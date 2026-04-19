import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f6f8),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // 🔷 TITLE
            const SizedBox(height: 20),
            const Text(
              "Business Overview",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const Text(
              "Your business performance at a glance",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 20),

            // 🔷 REVENUE CARD
            _statCard(
              title: "Total Revenue",
              value: "\$328,000",
              color: Colors.green,
              subtitle: "12.5% from last month",
              icon: Icons.attach_money,
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _statCard(
                    title: "Total Cost",
                    value: "\$198,000",
                    color: Colors.red,
                    subtitle: "6.2%",
                    icon: Icons.trending_down,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _statCard(
                    title: "Net Profit",
                    value: "\$130,000",
                    color: Colors.green,
                    subtitle: "18.3%",
                    icon: Icons.trending_up,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 🔷 CHART
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Sales Trend",
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    height: 200,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(show: false),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            isCurved: true,
                            color: Colors.green,
                            barWidth: 3,
                            dotData: FlDotData(show: true),
                            spots: const [
                              FlSpot(0, 45),
                              FlSpot(1, 52),
                              FlSpot(2, 48),
                              FlSpot(3, 61),
                              FlSpot(4, 55),
                              FlSpot(5, 67),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 🔷 AI INSIGHTS TITLE
            const Text(
              "AI Insights",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            _aiCard(
              color: Colors.orange,
              title: "Cost Alert: Inflation Impact",
              desc:
                  "Your costs have increased by 6% due to inflation over the past quarter.",
              icon: Icons.warning,
            ),

            _aiCard(
              color: Colors.green,
              title: "Demand Forecast",
              desc:
                  "Demand expected to rise by 15% next week due to seasonal trends.",
              icon: Icons.trending_up,
            ),

            _aiCard(
              color: Colors.amber,
              title: "Pricing Alert",
              desc:
                  "You are priced 12% higher than market average. This may impact sales.",
              icon: Icons.trending_down,
            ),
          ],
        ),
      ),
    );
  }

  // 📊 STAT CARD
  Widget _statCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
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
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            style: TextStyle(color: color),
          ),
        ],
      ),
    );
  }

  // 🤖 AI CARD
  Widget _aiCard({
    required Color color,
    required String title,
    required String desc,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style:
                        const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Text(
                  desc,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}