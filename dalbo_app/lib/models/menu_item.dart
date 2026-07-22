class MenuItem {
  final int    id;
  final int    restaurantId;
  final String name;
  final String description;
  final double priceUsd;
  final String photoUrl;
  final String category;
  final bool   isAvailable;

  const MenuItem({
    required this.id,
    required this.restaurantId,
    required this.name,
    required this.description,
    required this.priceUsd,
    required this.photoUrl,
    required this.category,
    required this.isAvailable,
  });

  factory MenuItem.fromJson(Map<String, dynamic> j) => MenuItem(
    id:           j['id'],
    restaurantId: j['restaurant_id'],
    name:         j['name'],
    description:  j['description'] ?? '',
    priceUsd:     (j['price_usd'] ?? 0).toDouble(),
    photoUrl:     j['photo_url'] ?? '',
    category:     j['category'] ?? '',
    isAvailable:  j['is_available'] ?? true,
  );
}
