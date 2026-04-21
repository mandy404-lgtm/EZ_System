import 'package:flutter/material.dart';

class Alerts extends StatelessWidget {
  const Alerts({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Alerts"), backgroundColor: Colors.green),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _alert("Inflation Alert", "Cost increasing by 6%", true),
          _alert("Low Stock", "Product A is running low", false),
          _alert("Demand Surge", "High demand expected next week", true),
        ],
      ),
    );
  }

  Widget _alert(String title, String desc, bool high) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: high ? Colors.red.shade50 : Colors.yellow.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 5),
          Text(desc),
        ],
      ),
    );
  }
}
