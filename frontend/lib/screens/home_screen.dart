import 'package:flutter/material.dart';

import 'product_input_page.dart';
import 'analytics.dart';
import 'alerts.dart';
import 'profile.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onLogout;

  const HomeScreen({super.key, required this.onLogout});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int index = 0;

  @override
  Widget build(BuildContext context) {

    final pages = [
      const ProductInputPage(), // ✅ INPUT FIRST (IMPORTANT)
       Analytics(),
       Alerts(),
      ProfilePage(onLogout: widget.onLogout),
    ];

    return Scaffold(
      backgroundColor: const Color(0xfff5f6f8),
      body: pages[index],

      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
            )
          ],
        ),

        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _nav(Icons.input, "Input", 0),       // 🔥 changed
            _nav(Icons.analytics, "Analytics", 1),
            _nav(Icons.warning, "Alerts", 2),
            _nav(Icons.person, "Profile", 3),
          ],
        ),
      ),
    );
  }

  Widget _nav(IconData icon, String label, int i) {
    bool selected = index == i;

    return GestureDetector(
      onTap: () => setState(() => index = i),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: selected ? Colors.green : Colors.grey,
          ),
          Text(
            label,
            style: TextStyle(
              color: selected ? Colors.green : Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}