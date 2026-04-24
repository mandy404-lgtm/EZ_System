import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../models/product.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  late Future<List<Product>> _productsFuture;

  // 控制器
  final nameController = TextEditingController();
  final costController = TextEditingController();
  final priceController = TextEditingController();
  final stockController = TextEditingController();
  final searchController = TextEditingController();

  String searchQuery = "";
  String? editingId;
  bool showForm = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _productsFuture = _fetchProducts();
    });
  }

  Future<List<Product>> _fetchProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id') ?? "";
    return await ApiService.getProducts(userId);
  }

  // ================= 核心：保存/更新产品 =================
  Future<void> handleSave() async {
    if (_isSaving) return;

    final prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString('user_id');

    if (userId == null) {
      _showError("User session expired. Please re-login.");
      return;
    }

    final String name = nameController.text.trim();
    final double? cost = double.tryParse(costController.text.trim());
    final double? price = double.tryParse(priceController.text.trim());
    final int? stock = int.tryParse(stockController.text.trim());

    if (name.isEmpty || cost == null || price == null || stock == null) {
      _showError("Please fill all fields with valid numbers");
      return;
    }

    setState(() => _isSaving = true);

    final data = {
      "user_id": userId,
      "product_id": editingId ?? "P${DateTime.now().millisecondsSinceEpoch}",
      "product_name": name,
      "cost_price": cost,
      "selling_price": price,
      "stock": stock,
    };

    bool success = editingId != null
        ? await ApiService.updateProduct(data)
        : await ApiService.addProduct(data);

    setState(() => _isSaving = false);

    if (success) {
      _refresh();
      setState(() {
        showForm = false;
        editingId = null;
      });
      _clearInputs();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Success: Product data synced")),
      );
    } else {
      _showError("Database sync failed.");
    }
  }

  // ================= 快捷操作：售出与补货 =================
  Future<void> handleSaleAction(Product p) async {
    final int? qty = await showQuantityDialog(context, "Record Sale", "Confirm Sell", Colors.green);
    if (qty == null || qty <= 0) return;

    if (p.stock < qty) {
      _showError("Not enough stock!");
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final data = {
      "user_id": prefs.getString('user_id'),
      "product_id": p.id,
      "quantity": qty,
      "price": p.price,
      "cost": p.cost,
    };

    if (await ApiService.recordSale(data)) {
      _refresh();
    }
  }

  Future<void> handleRestock(Product p) async {
    final int? qty = await showQuantityDialog(context, "Restock Inventory", "Add Units", Colors.blue);
    if (qty == null || qty <= 0) return;

    if (await ApiService.updateStock({"product_id": p.id, "adjustment": qty})) {
      _refresh();
    }
  }

  // ================= UI 构建 =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Stock Inventory"),
        backgroundColor: Colors.green.shade800,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green.shade800,
        onPressed: () {
          setState(() {
            showForm = !showForm;
            if (!showForm) {
              editingId = null;
              _clearInputs();
            }
          });
        },
        child: Icon(showForm ? Icons.close : Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          if (showForm) _buildForm(),
          Expanded(child: _buildList()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: "Search your products...",
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (val) => setState(() => searchQuery = val.toLowerCase()),
      ),
    );
  }

  Widget _buildForm() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(editingId == null ? "✨ Add New Product" : "📝 Edit Product",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            TextField(controller: nameController, decoration: const InputDecoration(labelText: "Product Name")),
            Row(
              children: [
                Expanded(child: TextField(controller: costController, decoration: const InputDecoration(labelText: "Cost (RM)"), keyboardType: TextInputType.number)),
                const SizedBox(width: 15),
                Expanded(child: TextField(controller: priceController, decoration: const InputDecoration(labelText: "Price (RM)"), keyboardType: TextInputType.number)),
              ],
            ),
            TextField(controller: stockController, decoration: const InputDecoration(labelText: "Current Stock"), keyboardType: TextInputType.number),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSaving ? null : handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade800,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("SYNC TO DATABASE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    return FutureBuilder<List<Product>>(
      future: _productsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text("No products yet. Click '+' to add."));

        final list = snapshot.data!.where((p) => p.name.toLowerCase().contains(searchQuery)).toList();

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final p = list[index];
            final bool isLowStock = p.stock < 5;
            final double profit = p.price - (p.cost ?? 0);

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text("Price: RM ${p.price.toStringAsFixed(2)} | Profit: RM ${profit.toStringAsFixed(2)}"),
                    const SizedBox(height: 2),
                    Text(
                      "Stock Level: ${p.stock}",
                      style: TextStyle(
                        color: isLowStock ? Colors.red : Colors.green.shade700,
                        fontWeight: isLowStock ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                        icon: const Icon(Icons.add_box, color: Colors.blue),
                        onPressed: () => handleRestock(p),
                        tooltip: "Restock"),
                    IconButton(
                        icon: const Icon(Icons.sell, color: Colors.green),
                        onPressed: () => handleSaleAction(p),
                        tooltip: "Sell"),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.orange),
                      onPressed: () {
                        setState(() {
                          editingId = p.id;
                          nameController.text = p.name;
                          priceController.text = p.price.toString();
                          costController.text = (p.cost ?? 0.0).toString();
                          stockController.text = p.stock.toString();
                          showForm = true;
                        });
                      },
                    ),
                    IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => handleDelete(p.id)),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ================= 辅助工具方法 =================
  void _clearInputs() {
    nameController.clear();
    costController.clear();
    priceController.clear();
    stockController.clear();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> handleDelete(String productId) async {
    bool confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Product?"),
        content: const Text("This data will be removed permanently."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Delete", style: TextStyle(color: Colors.red))),
        ],
      ),
    ) ?? false;

    if (confirm && await ApiService.deleteProduct(productId)) {
      _refresh();
    }
  }

  Future<int?> showQuantityDialog(BuildContext context, String title, String actionLabel, Color themeColor) async {
    int quantity = 1;
    return showDialog<int>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(title),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(icon: const Icon(Icons.remove), onPressed: () => setDialogState(() => quantity > 1 ? quantity-- : null)),
              Text("$quantity", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              IconButton(icon: const Icon(Icons.add), onPressed: () => setDialogState(() => quantity++)),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: themeColor),
              onPressed: () => Navigator.pop(ctx, quantity),
              child: Text(actionLabel, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}