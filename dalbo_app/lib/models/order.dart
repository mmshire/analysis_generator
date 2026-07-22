class Order {
  final int    id;
  final int    restaurantId;
  final String restaurantName;
  final String restaurantPhoto;
  final String status;
  final String deliveryAddress;
  final String paymentMethod;
  final double totalUsd;
  final DateTime createdAt;
  final List<OrderItem> items;

  const Order({
    required this.id,
    required this.restaurantId,
    required this.restaurantName,
    required this.restaurantPhoto,
    required this.status,
    required this.deliveryAddress,
    required this.paymentMethod,
    required this.totalUsd,
    required this.createdAt,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> j) => Order(
    id:              j['id'],
    restaurantId:    j['restaurant_id'],
    restaurantName:  j['restaurant_name'] ?? '',
    restaurantPhoto: j['restaurant_photo'] ?? '',
    status:          j['status'] ?? 'placed',
    deliveryAddress: j['delivery_address'] ?? '',
    paymentMethod:   j['payment_method'] ?? 'cash_on_delivery',
    totalUsd:        (j['total_usd'] ?? 0).toDouble(),
    createdAt:       DateTime.parse(j['created_at']),
    items:           (j['items'] as List<dynamic>? ?? [])
                       .map((i) => OrderItem.fromJson(i))
                       .toList(),
  );
}

class OrderItem {
  final int    id;
  final String name;
  final int    quantity;
  final double priceUsd;

  const OrderItem({required this.id, required this.name, required this.quantity, required this.priceUsd});

  factory OrderItem.fromJson(Map<String, dynamic> j) => OrderItem(
    id:       j['id'],
    name:     j['name'] ?? '',
    quantity: j['quantity'],
    priceUsd: (j['price_usd'] ?? 0).toDouble(),
  );
}
