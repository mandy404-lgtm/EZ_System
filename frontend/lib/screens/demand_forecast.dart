import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/user_service.dart';

class ForecastScreen extends StatefulWidget {
  @override
  State<ForecastScreen> createState() => _ForecastScreenState();
}

class _ForecastScreenState extends State<ForecastScreen> {
  Map? data;
  bool loading = true;

  final String baseUrl = "http://10.0.2.2:8000";

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {

  final userId = await UserService.getUserId();

  final res = await http.get(
    Uri.parse("http://10.0.2.2:8000/demand-forecast?user_id=$userId"),
  );

  setState(() {
    data = jsonDecode(res.body);
    loading = false;
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Demand Forecast"), backgroundColor: Colors.green),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("📊 Forecast: ${data!['forecast']} units"),
                  SizedBox(height: 10),
                  Text("📈 Trend: ${data!['trend']}"),
                  SizedBox(height: 10),
                  Text("🎯 Confidence: ${data!['confidence']}"),
                  SizedBox(height: 10),
                  Text("🧠 Explanation: ${data!['explanation']}"),
                ],
              ),
            ),
    );
  }
}