import 'package:flutter/material.dart';

import '../models/product_model.dart';

class FavoriteEntry {
  final ProductModel product;
  DateTime favoritedAt;

  FavoriteEntry({
    required this.product,
    required this.favoritedAt,
  });
}

class FavoriteLogic extends ChangeNotifier {
  final List<FavoriteEntry> _items = [];

  List<FavoriteEntry> get items => List.unmodifiable(_items);

  int get totalFavorites => _items.length;

  bool isFavorited(ProductModel product) {
    return _items.any((entry) => entry.product.id == product.id);
  }

  bool toggleFavorite(ProductModel product) {
    final index = _items.indexWhere((entry) => entry.product.id == product.id);
    if (index >= 0) {
      _items.removeAt(index);
      notifyListeners();
      return false;
    }

    _items.add(
      FavoriteEntry(
        product: product,
        favoritedAt: DateTime.now(),
      ),
    );
    notifyListeners();
    return true;
  }

  void removeFavorite(ProductModel product) {
    _items.removeWhere((entry) => entry.product.id == product.id);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
