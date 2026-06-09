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

  double get totalAmount => _items.fold<double>(
        0,
        (sum, entry) => sum + (entry.product.price * entry.quantity),
      );

  int quantityFor(ProductModel product) {
    final index = _items.indexWhere((entry) => entry.product.id == product.id);
    if (index < 0) {
      return 0;
    }

    return _items[index].quantity;
  }

  void addProduct(ProductModel product, {int quantity = 1}) {
    if (quantity <= 0) {
      return;
    }

    final index = _items.indexWhere((entry) => entry.product.id == product.id);
    if (index >= 0) {
      _items[index].quantity += quantity;
      _items[index].lastAddedAt = DateTime.now();
    } else {
      _items.add(
        CartEntry(
          product: product,
          quantity: quantity,
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
