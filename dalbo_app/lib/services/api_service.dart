import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants.dart';
import '../models/restaurant.dart';
import '../models/order.dart';

/// All calls to the Dalbo backend go through this class.
class ApiService {
  final String? token;
  ApiService({this.token});

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };

  Uri _url(String path) => Uri.parse('${AppConstants.apiBaseUrl}$path');

  // ── Auth ──────────────────────────────────────────────────────────────────

  Future<void> sendOtp(String phone) async {
    final res = await http.post(_url('/auth/send-otp'),
      headers: _headers, body: jsonEncode({'phone': phone}));
    _check(res);
  }

  Future<Map<String, dynamic>> verifyOtp(String phone, String code) async {
    final res = await http.post(_url('/auth/verify-otp'),
      headers: _headers, body: jsonEncode({'phone': phone, 'code': code}));
    return _check(res);
  }

  Future<Map<String, dynamic>> updateProfile(String name) async {
    final res = await http.patch(_url('/auth/profile'),
      headers: _headers, body: jsonEncode({'name': name}));
    return _check(res);
  }

  // ── Restaurants ──────────────────────────────────────────────────────────

  Future<List<Restaurant>> getRestaurants() async {
    final res = await http.get(_url('/restaurants'), headers: _headers);
    final List data = _check(res);
    return data.map((j) => Restaurant.fromJson(j)).toList();
  }

  Future<Map<String, dynamic>> getRestaurantDetail(int id) async {
    final res = await http.get(_url('/restaurants/$id'), headers: _headers);
    return _check(res);
  }

  // ── Orders ───────────────────────────────────────────────────────────────

  Future<Order> createOrder({
    required int restaurantId,
    required List<Map<String, dynamic>> items,
    required String deliveryAddress,
    double? lat,
    double? lng,
    String paymentMethod = 'cash_on_delivery',
    String? notes,
  }) async {
    final res = await http.post(_url('/orders'), headers: _headers,
      body: jsonEncode({
        'restaurant_id':    restaurantId,
        'items':            items,
        'delivery_address': deliveryAddress,
        'delivery_lat':     lat,
        'delivery_lng':     lng,
        'payment_method':   paymentMethod,
        'notes':            notes,
      }));
    return Order.fromJson(_check(res));
  }

  Future<List<Order>> getOrderHistory() async {
    final res = await http.get(_url('/orders'), headers: _headers);
    final List data = _check(res);
    return data.map((j) => Order.fromJson(j)).toList();
  }

  Future<Order> getOrder(int id) async {
    final res = await http.get(_url('/orders/$id'), headers: _headers);
    return Order.fromJson(_check(res));
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  dynamic _check(http.Response res) {
    final body = jsonDecode(res.body);
    if (res.statusCode >= 200 && res.statusCode < 300) return body;
    throw ApiException(
      body['error'] ?? 'Something went wrong (${res.statusCode})',
      res.statusCode,
    );
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  const ApiException(this.message, this.statusCode);

  @override
  String toString() => message;
}
