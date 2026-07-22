import 'package:flutter/material.dart';
import '../models/order.dart';
import '../services/api_service.dart';

class OrderProvider extends ChangeNotifier {
  List<Order> history  = [];
  Order?      current;   // the order being tracked right now
  bool        loading  = false;
  String?     error;

  Future<void> loadHistory(ApiService api) async {
    loading = true; error = null; notifyListeners();
    try {
      history = await api.getOrderHistory();
    } catch (e) {
      error = e.toString();
    }
    loading = false; notifyListeners();
  }

  Future<Order?> placeOrder({
    required ApiService api,
    required int restaurantId,
    required List<Map<String, dynamic>> items,
    required String deliveryAddress,
    double? lat,
    double? lng,
    String paymentMethod = 'cash_on_delivery',
  }) async {
    loading = true; error = null; notifyListeners();
    try {
      final order = await api.createOrder(
        restaurantId: restaurantId,
        items: items,
        deliveryAddress: deliveryAddress,
        lat: lat,
        lng: lng,
        paymentMethod: paymentMethod,
      );
      current = order;
      history.insert(0, order);
      loading = false; notifyListeners();
      return order;
    } catch (e) {
      error = e.toString();
      loading = false; notifyListeners();
      return null;
    }
  }

  Future<void> refreshOrder(ApiService api, int orderId) async {
    try {
      current = await api.getOrder(orderId);
      notifyListeners();
    } catch (_) {}
  }
}
