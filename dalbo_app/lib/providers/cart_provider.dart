import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../models/menu_item.dart';

class CartProvider extends ChangeNotifier {
  // All items must be from the same restaurant
  int?             restaurantId;
  String?          restaurantName;
  List<CartItem>   items = [];

  int get itemCount => items.fold(0, (sum, i) => sum + i.quantity);

  double get totalUsd => items.fold(0.0, (sum, i) => sum + i.subtotalUsd);

  bool get isEmpty => items.isEmpty;

  void addItem(MenuItem menuItem, int restaurantId, String restaurantName) {
    // If adding from a different restaurant, clear the cart first
    if (this.restaurantId != null && this.restaurantId != restaurantId) {
      items.clear();
    }
    this.restaurantId   = restaurantId;
    this.restaurantName = restaurantName;

    final existing = items.where((c) => c.item.id == menuItem.id);
    if (existing.isNotEmpty) {
      existing.first.quantity++;
    } else {
      items.add(CartItem(item: menuItem));
    }
    notifyListeners();
  }

  void removeItem(int menuItemId) {
    final idx = items.indexWhere((c) => c.item.id == menuItemId);
    if (idx == -1) return;
    if (items[idx].quantity > 1) {
      items[idx].quantity--;
    } else {
      items.removeAt(idx);
      if (items.isEmpty) restaurantId = null;
    }
    notifyListeners();
  }

  void clear() {
    items.clear();
    restaurantId   = null;
    restaurantName = null;
    notifyListeners();
  }

  List<Map<String, dynamic>> toOrderItems() =>
    items.map((c) => c.toOrderJson()).toList();
}
