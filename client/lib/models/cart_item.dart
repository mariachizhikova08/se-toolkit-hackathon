class CartItem {
  final int dessertId;
  final String dessertName;
  int quantity;
  final double price;

  CartItem({
    required this.dessertId,
    required this.dessertName,
    required this.quantity,
    required this.price,
  });

  double get totalPrice => quantity * price;

  Map<String, dynamic> toJson() {
    return {
      'dessert_id': dessertId,
      'name': dessertName,
      'quantity': quantity,
      'price': price,
    };
  }
}
