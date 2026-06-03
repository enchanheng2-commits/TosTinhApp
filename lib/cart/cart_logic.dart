import 'package:flutter/material.dart';

import '../models/product_model.dart';

class CartEntry {
  final ProductModel product;
  int quantity;
  DateTime lastAddedAt;

  CartEntry({
    required this.product,
    required this.quantity,
    required this.lastAddedAt,
  });
}

class CartLogic extends ChangeNotifier {
  final List<CartEntry> _items = [];

  List<CartEntry> get items => List.unmodifiable(_items);

  int get totalItems =>
      _items.fold<int>(0, (sum, entry) => sum + entry.quantity);

  void addProduct(ProductModel product) {
    final index = _items.indexWhere((entry) => entry.product.id == product.id);
    if (index >= 0) {
      _items[index].quantity += 1;
      _items[index].lastAddedAt = DateTime.now();
    } else {
      _items.add(
        CartEntry(
          product: product,
          quantity: 1,
          lastAddedAt: DateTime.now(),
        ),
      );
    }
    notifyListeners();
  }

  void removeProduct(ProductModel product) {
    final index = _items.indexWhere((entry) => entry.product.id == product.id);
    if (index < 0) {
      return;
    }

    if (_items[index].quantity > 1) {
      _items[index].quantity -= 1;
      _items[index].lastAddedAt = DateTime.now();
    } else {
      _items.removeAt(index);
    }
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
