import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CompetitorScreen extends StatefulWidget {
  @override
  State<CompetitorScreen> createState() => _CompetitorScreenState();
}

class _CompetitorScreenState extends State<CompetitorScreen> {
  Map? data;
  bool loading = true;

  final String baseUrl = "http://10.0.2.2:8000";

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final res = await http.get(Uri.parse("$baseUrl/competitor-benchmark"));
    setState(() {
      data = jsonDecode(res.body);
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Competitor Benchmark"), backgroundColor: Colors.green),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("💰 Your Price: RM ${data!['your_price']}"),
                  SizedBox(height: 10),
                  Text("🏷 Market Price: RM ${data!['market_price']}"),
                  SizedBox(height: 10),
                  Text("📉 Gap: ${data!['gap']}"),
                  SizedBox(height: 10),
                  Text("💡 Recommendation: ${data!['recommendation']}"),
                  SizedBox(height: 10),
                  Text("🧠 Explanation: ${data!['explanation']}"),
                ],
              ),
            ),
    );
  }
}