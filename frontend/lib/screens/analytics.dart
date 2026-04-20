import 'package:flutter/material.dart';

class Analytics extends StatelessWidget {
  const Analytics({super.key});

  // 🔥 Dummy AI OUTPUT (later replace with Z.AI GLM response)
  final String recommendation =
      "Reduce selling price to RM69 or introduce bundle offer to increase sales volume.";

  final String explanation =
      "Your product is priced 15% higher than competitors. Demand is decreasing due to market competition and inflation pressure on consumers.";

  final String tradeOff =
      "Option 1: Reduce price → +18% sales, -5% profit margin\n"
      "Option 2: Keep price → stable margin, but -12% sales risk\n"
      "Option 3: Bundle offer → balanced profit & demand";

  final String forecast =
      "Next 7 days forecast:\n"
      "• Sales: +12% if price reduced\n"
      "• Demand: increasing during weekend peak\n"
      "• Stock risk: moderate overstock if no action taken";

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
      body: SingleChildScrollView(
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
          ],
        ),
      ),
    );
  }

  // 🧠 AI CARD WIDGET
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