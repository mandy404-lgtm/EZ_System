import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';

class Analytics extends StatefulWidget {
  const Analytics({super.key});

  @override
  State<Analytics> createState() => _AnalyticsState();
}

class _AnalyticsState extends State<Analytics> {
  // ===================== 状态变量 =====================
  bool _isLoading = false;
  bool _isLoadingProducts = true;
  bool _isGlobalLoading = false;

  String recommendation = "Click 'Trigger AI' to analyze your business.";
  String tradeOff = "Calculating...";
  String reasoning = "Waiting for data analysis...";
  String conversionRate = "0.0%";
  String stockStatus = "Checking...";
  String forecast30d = "Calculating trend...";
  String impactSummary = "Waiting for analysis...";

  List<Product> _products = [];
  Product? _selectedProduct;
  String _userId = "";

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 每次页面依赖改变（例如从另一个页面返回）时，尝试重新加载产品列表
    _loadProducts();
  }

  // ===================== 数据加载逻辑 =====================

  Future<void> _loadProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // 这里的 ID 逻辑与 UMHackathon 2026 数据库匹配
      _userId = prefs.getString('user_id') ?? "U1776955390504";

      final response = await http.get(
        Uri.parse("http://10.0.2.2:8000/products/$_userId"),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _products = data.map((item) => Product.fromJson(item)).toList();
            _isLoadingProducts = false;
            if (_products.isNotEmpty) {
              _selectedProduct = _products.first;
            }
          });
        }
      }
    } catch (e) {
      debugPrint("Load Products Error: $e");
      if (mounted) setState(() => _isLoadingProducts = false);
    }
  }

  Future<void> _triggerAI() async {
    if (_selectedProduct == null) return;
    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(
          "http://10.0.2.2:8000/analytics/trigger-ai/$_userId/${_selectedProduct!.id}",
        ),
      );

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);

        print("------- BACKEND RAW DATA -------");
        print(decodedData);
        print("--------------------------------");

        final aiResult = decodedData['data'];

        // 🌟 修正：确保这个 if 块在 statusCode == 200 的内部
        if (aiResult != null && mounted) {
          setState(() {
            // --- 1. 基础指标计算 ---
            double totalSales = (aiResult['total_sales'] ?? 0).toDouble();
            double totalViews = (aiResult['total_views'] ?? 0).toDouble();
            double calculatedCR = totalViews > 0
                ? (totalSales / totalViews)
                : 0.0;
            conversionRate = "${(calculatedCR * 100).toStringAsFixed(1)}%";
            stockStatus = aiResult['stock_status'] ?? "Optimal";

            // --- 2. AI 深度分析字段 (兼容不同 Key 名) ---
            recommendation =
                aiResult['ai_recommendation'] ??
                aiResult['recommendation'] ??
                "Strategy pending...";
            reasoning =
                aiResult['glm_reasoning'] ??
                aiResult['reasoning'] ??
                "Analyzing history...";
            tradeOff =
                aiResult['trade_off_analysis'] ??
                aiResult['trade_off'] ??
                "None";
            forecast30d = aiResult['forecast_30d']?.toString() ?? "N/A";
            impactSummary = aiResult['impact_summary'] ?? "Stable";
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("🚀 Intelligence Generated!"),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        debugPrint("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("AI Trigger Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Analysis Failed: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _triggerGlobalAI() async {
    setState(() => _isGlobalLoading = true);
    try {
      final response = await http.post(
        Uri.parse("http://10.0.2.2:8000/analytics/trigger-store-ai/$_userId"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        if (mounted) _showGlobalReportDialog(data);
      }
    } catch (e) {
      debugPrint("Global AI Error: $e");
    } finally {
      if (mounted) setState(() => _isGlobalLoading = false);
    }
  }

  // ===================== UI 构建 =====================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f6f8),
      appBar: AppBar(
        title: const Text(
          "AI Business Insights",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.blue),
            onPressed: () => _loadProducts(), // 手动点击刷新列表
          ),
          IconButton(
            icon: _isGlobalLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(
                    Icons.analytics_outlined,
                    color: Colors.deepPurple,
                  ),
            onPressed: _isGlobalLoading ? null : _triggerGlobalAI,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoadingProducts
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProductSelector(),
                  const SizedBox(height: 16),
                  _aiTriggerButton(),
                  const SizedBox(height: 24),
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
                          color: stockStatus == "Low"
                              ? Colors.red
                              : Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "🧠 AI Business Intelligence",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _glowCard(
                    icon: Icons.auto_graph,
                    color: Colors.orange,
                    title: "Strategic Action",
                    content: recommendation,
                    subContent: "Impact: $impactSummary",
                    subIcon: Icons.bolt,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _infoBox(
                          title: "30D Forecast",
                          value: forecast30d,
                          icon: Icons.timeline,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _infoBox(
                          title: "Trade-off",
                          value: tradeOff,
                          icon: Icons.balance,
                          color: Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _card(
                    icon: Icons.psychology,
                    color: Colors.indigo,
                    title: "LLM Reasoning",
                    desc: reasoning,
                  ),
                  const SizedBox(height: 30),
                  _buildGlobalReportEntry(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  // --- 抽取的小组件 ---

  Widget _buildProductSelector() {
    if (_products.isEmpty) return const Text("No products available.");
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: DropdownButtonFormField<Product>(
          isExpanded: true, // 防止长文本溢出
          value: _selectedProduct,
          decoration: const InputDecoration(
            labelText: "Analyze Product",
            border: OutlineInputBorder(),
          ),
          items: _products
              .map(
                (p) => DropdownMenuItem(
                  value: p,
                  child: Text(p.name, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: (val) => setState(() => _selectedProduct = val),
        ),
      ),
    );
  }

  Widget _buildGlobalReportEntry() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.deepPurple.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.deepPurple.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          const Text(
            "Looking for the Big Picture?",
            style: TextStyle(
              color: Colors.deepPurple,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _isGlobalLoading ? null : _triggerGlobalAI,
            icon: const Icon(Icons.leaderboard),
            label: Text(
              _isGlobalLoading ? "Synthesizing..." : "GENERATE CEO REPORT",
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // 这里的 _smallCard, _glowCard, _infoBox, _card 组件保留你原来的实现即可，逻辑无误。
  // 注意：由于字数限制，内部重复的 UI 代码略，建议保持原样。

  void _showGlobalReportDialog(Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("CEO Strategic Report"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("Overall Summary"),
              Text(data['overall_summary'] ?? "No data"),
              const Divider(),
              _buildSectionTitle("Health Score"),
              Text(
                "${data['financial_health_score'] ?? 0}/100",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Text(
    title,
    style: const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
      color: Colors.indigo,
    ),
  );

  Widget _aiTriggerButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _triggerAI,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6366F1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                "ACTIVATE AI ANALYSIS",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _card({
    required IconData icon,
    required Color color,
    required String title,
    required String desc,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(desc, style: const TextStyle(fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _smallCard({
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(title),
          Text(
            value,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _infoBox({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
          Text(title),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _glowCard({
    required IconData icon,
    required Color color,
    required String title,
    required String content,
    required String subContent,
    required IconData subIcon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 10),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          Text(content),
          const Divider(),
          Row(
            children: [
              Icon(subIcon, size: 14),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  subContent,
                  style: TextStyle(color: color, fontSize: 12),
                  softWrap: true, // 允许换行))])
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
