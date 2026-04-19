import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class InflationScreen extends StatefulWidget {
  @override
  State<InflationScreen> createState() => _InflationScreenState();
}

class _InflationScreenState extends State<InflationScreen> {
  Map? data;
  bool loading = true;

  final String baseUrl = "http://10.0.2.2:8000";

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final res = await http.get(Uri.parse("$baseUrl/inflation-analysis"));
    setState(() {
      data = jsonDecode(res.body);
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Inflation Intelligence"), backgroundColor: Colors.green),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("📈 Inflation Rate: ${data!['rate']}%"),
                  SizedBox(height: 10),
                  Text("⚠️ Impact: ${data!['impact']}"),
                  SizedBox(height: 10),
                  Text("💡 Recommendation: ${data!['recommendation']}"),
                  SizedBox(height: 10),
                  Text("🧠 Reasoning: ${data!['explanation']}"),
                ],
              ),
            ),
    );
  }
}