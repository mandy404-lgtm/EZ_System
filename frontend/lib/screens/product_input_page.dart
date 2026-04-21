import 'package:flutter/material.dart';
import 'dashboard.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/user_service.dart';

class ProductInputPage extends StatefulWidget {
  const ProductInputPage({super.key});

  @override
  State<ProductInputPage> createState() => _ProductInputPageState();
}

class _ProductInputPageState extends State<ProductInputPage> {
  final nameController = TextEditingController();
  final costController = TextEditingController();
  final priceController = TextEditingController();
  final stockController = TextEditingController();
  final salesController = TextEditingController();

  void submitData() async {

  final userId = await UserService.getUserId();

  await http.post(
    Uri.parse("http://10.0.2.2:8000/sales"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "user_id": userId,
      "product_name": nameController.text,
      "cost": double.parse(costController.text),
      "price": double.parse(priceController.text),
      "units_sold": int.parse(salesController.text),
    }),
  );

  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const Dashboard()),
  );
}

  Widget field(String label, TextEditingController c, TextInputType type) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Product Input")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            field("Product Name", nameController, TextInputType.text),
            field("Cost Price", costController, TextInputType.number),
            field("Selling Price", priceController, TextInputType.number),
            field("Stock Quantity", stockController, TextInputType.number),
            field("Units Sold", salesController, TextInputType.number),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: submitData,
              child: const Text("Analyze Data"),
            )
          ],
        ),
      ),
    );
  }
}