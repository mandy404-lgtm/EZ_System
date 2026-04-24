import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Analytics extends StatefulWidget {
  const Analytics({super.key});

  @override
  State<Analytics> createState() => _AnalyticsState();
}

class _AnalyticsState extends State<Analytics> {
  // ===================== 状态变量 =====================
  bool _isLoading = false;
  String recommendation = "Click 'Trigger AI' to analyze your business.";
  String tradeOff = "Calculating...";
  String reasoning = "Waiting for data analysis...";
  String conversionRate = "0.0%";
  String stockStatus = "Checking...";

  // 建议：实际开发中通过构造函数传入这些 ID
  final String productId = "P1777040303230"; 
  final String userId = "U1776955390504";

  // ===================== API 调用 =====================
  Future<void> _triggerAI() async {
    setState(() => _isLoading = true);

    try {
      // 1. 调用后端接口。注意：确保 URL 与你 main.py 定义的路由一致
      // 建议使用你的局域网 IP (如 192.168.x.x) 如果是在真机调试
      final response = await http.post(
        Uri.parse("http://10.0.2.2:8000/analytics/trigger-ai/$userId/$productId"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // 🌟 核心逻辑：从后端返回的 'data' 字段中提取 AI 分析结果
        // 假设你的后端返回了包含 ai_insight, conversion_rate 等字段的对象
        final aiResult = data['data']; 

        setState(() {
          // 将后端 AI 生成的内容映射到 UI
          recommendation = aiResult['ai_insight'] ?? "Strategy: Increase marketing exposure.";
          reasoning = aiResult['ai_reasoning'] ?? "Based on your current sales trend and stock turnover.";
          
          // 格式化转化率显示
          double cr = (aiResult['conversion_rate'] ?? 0.0) * 100;
          conversionRate = "${cr.toStringAsFixed(2)}%";
          
          tradeOff = aiResult['stock_status'] ?? "Balanced";
          stockStatus = aiResult['stock_status'] == "Low" ? "Reorder Soon" : "Optimal";
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("🚀 Intelligence Generated Successfully!"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Analysis Failed: $e"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f6f8),
      appBar: AppBar(
        title: const Text("AI Business Insights", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ================= AI 触发按钮 =================
            _aiTriggerButton(),

            const SizedBox(height: 24),

            /// ================= 核心指标 (新增展示) =================
            const Text(
              "📊 Real-time Performance",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _smallCard(
                    title: "Conversion Rate",
                    value: conversionRate,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _smallCard(
                    title: "Inventory Status",
                    value: stockStatus,
                    color: stockStatus == "Reorder Soon" ? Colors.red : Colors.green,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            /// ================= AI RECOMMENDATION =================
            const Text(
              "🧠 AI Strategic Action",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _card(
              icon: Icons.auto_graph,
              color: Colors.orange,
              title: "Recommendation",
              desc: recommendation,
            ),

            const SizedBox(height: 20),

            /// ================= EXPLANATION =================
            const Text(
              "📉 LLM Reasoning",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _card(
              icon: Icons.psychology,
              color: Colors.blue,
              title: "Why this works?",
              desc: reasoning,
            ),
          ],
        ),
      ),
    );
  }

  // --- UI 组件保持简洁漂亮 ---

  Widget _aiTriggerButton() {
    return InkWell(
      onTap: _isLoading ? null : _triggerAI,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _isLoading 
                ? [Colors.grey, Colors.blueGrey] 
                : [const Color(0xFF6366F1), const Color(0xFFA855F7)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Center(
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.bolt, color: Colors.white),
                    SizedBox(width: 12),
                    Text(
                      "ACTIVATE AI ANALYSIS",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _card({required IconData icon, required Color color, required String title, required String desc}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.blueGrey)),
                const SizedBox(height: 6),
                Text(desc, style: const TextStyle(color: Colors.black87, fontSize: 13, height: 1.5)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _smallCard({required String title, required String value, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}