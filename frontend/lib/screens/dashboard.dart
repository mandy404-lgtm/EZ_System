import 'package:flutter/material.dart';
import 'package:frontend/models/product.dart';


class Dashboard extends StatelessWidget {
  final ProductData product;

  const Dashboard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f6f8),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const SizedBox(height: 20),

            const Text(
              "Business Overview",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            // 💰 REVENUE
            _card(
              "Total Revenue",
              "RM ${product.revenue.toStringAsFixed(2)}",
              Icons.attach_money,
              Colors.green,
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _card(
                    "Profit",
                    "RM ${product.profit.toStringAsFixed(2)}",
                    Icons.trending_up,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _card(
                    "Stock",
                    "${product.remainingStock} units",
                    Icons.inventory_2,
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

            _aiCard(
              "Pricing Insight",
              "Your pricing vs cost shows ${(product.price - product.cost).toStringAsFixed(2)} margin per unit.",
              Colors.green,
            ),

            _aiCard(
              "Stock Insight",
              product.remainingStock < 50
                  ? "Low stock warning: consider restocking soon."
                  : "Stock level is healthy.",
              Colors.orange,
            ),

            _aiCard(
              "Revenue Insight",
              "Based on sales, total revenue generated is RM ${product.revenue.toStringAsFixed(2)}.",
              Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

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