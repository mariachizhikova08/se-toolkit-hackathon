import 'package:flutter/foundation.dart';
import '../models/dessert.dart';
import '../models/cart_item.dart';

class CartService extends ChangeNotifier {
  final Map<int, CartItem> _items = {};

  List<CartItem> get items => _items.values.toList();
  int get itemCount => _items.values.fold(0, (sum, item) => sum + item.quantity);
  double get totalPrice => _items.values.fold(0, (sum, item) => sum + item.totalPrice);
  bool get isEmpty => _items.isEmpty;

  void addToCart(Dessert dessert, {int quantity = 1}) {
    if (_items.containsKey(dessert.id)) {
      _items[dessert.id]!.quantity += quantity;
    } else {
      _items[dessert.id] = CartItem(
        dessertId: dessert.id,
        dessertName: dessert.name,
        quantity: quantity,
        price: dessert.price,
      );
    }
    notifyListeners();
  }

  void removeFromCart(int dessertId) {
    _items.remove(dessertId);
    notifyListeners();
  }

  void updateQuantity(int dessertId, int quantity) {
    if (_items.containsKey(dessertId)) {
      if (quantity <= 0) {
        _items.remove(dessertId);
      } else {
        _items[dessertId]!.quantity = quantity;
      }
      notifyListeners();
    }
  }

  void increment(int dessertId) {
    if (_items.containsKey(dessertId)) {
      _items[dessertId]!.quantity++;
      notifyListeners();
    }
  }

  void decrement(int dessertId) {
    if (_items.containsKey(dessertId)) {
      if (_items[dessertId]!.quantity <= 1) {
        _items.remove(dessertId);
      } else {
        _items[dessertId]!.quantity--;
      }
      notifyListeners();
    }
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  List<Map<String, dynamic>> toOrderItems() {
    return _items.values.map((item) => item.toJson()).toList();
  }
}
