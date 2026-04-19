import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Analytics extends StatefulWidget {
  @override
  State<Analytics> createState() => _AnalyticsState();
}

class _AnalyticsState extends State<Analytics> {
  Map? inflation;
  Map? forecast;
  Map? competitor;

  bool isLoading = true;

  final String baseUrl = "http://10.0.2.2:8000";

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final infl = await http.get(Uri.parse("$baseUrl/inflation-analysis"));
    final fore = await http.get(Uri.parse("$baseUrl/demand-forecast"));
    final comp = await http.get(Uri.parse("$baseUrl/competitor-benchmark"));

    setState(() {
      inflation = jsonDecode(infl.body);
      forecast = jsonDecode(fore.body);
      competitor = jsonDecode(comp.body);
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("AI Analytics"),
        backgroundColor: Colors.green,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [

                  // ---------------- INFLATION ----------------
                  _card(
                    "📈 Inflation Intelligence",
                    [
                      "Rate: ${inflation!['rate']}%",
                      "Impact: ${inflation!['impact']}",
                      "AI: ${inflation!['recommendation']}",
                      "Reason: ${inflation!['explanation']}",
                    ],
                    Colors.orange.shade50,
                  ),

                  SizedBox(height: 15),

                  // ---------------- DEMAND ----------------
                  _card(
                    "📊 Demand Forecast",
                    [
                      "Forecast: ${forecast!['forecast']} units",
                      "Trend: ${forecast!['trend']}",
                      "Confidence: ${forecast!['confidence']}",
                      "AI: ${forecast!['explanation']}",
                    ],
                    Colors.blue.shade50,
                  ),

                  SizedBox(height: 15),

                  // ---------------- COMPETITOR ----------------
                  _card(
                    "🆚 Competitor Benchmark",
                    [
                      "Your Price: RM ${competitor!['your_price']}",
                      "Market Price: RM ${competitor!['market_price']}",
                      "Gap: ${competitor!['gap']}",
                      "AI: ${competitor!['recommendation']}",
                      "Reason: ${competitor!['explanation']}",
                    ],
                    Colors.green.shade50,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _card(String title, List<String> items, Color color) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          ...items.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(e),
              )),
        ],
      ),
    );
  }
}