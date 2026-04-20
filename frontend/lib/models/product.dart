class ProductData {
  final String name;
  final double cost;
  final double price;
  final int stock;
  final int unitsSold;

  ProductData({
    required this.name,
    required this.cost,
    required this.price,
    required this.stock,
    required this.unitsSold,
  });

  double get revenue => price * unitsSold;

  double get profit => (price - cost) * unitsSold;

  int get remainingStock => stock - unitsSold;
}