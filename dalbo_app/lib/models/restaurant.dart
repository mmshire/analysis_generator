class Restaurant {
  final int    id;
  final String name;
  final String cuisineType;
  final String photoUrl;
  final int    deliveryTimeMin;
  final bool   isOpen;
  final String address;
  final double rating;

  const Restaurant({
    required this.id,
    required this.name,
    required this.cuisineType,
    required this.photoUrl,
    required this.deliveryTimeMin,
    required this.isOpen,
    required this.address,
    required this.rating,
  });

  factory Restaurant.fromJson(Map<String, dynamic> j) => Restaurant(
    id:              j['id'],
    name:            j['name'],
    cuisineType:     j['cuisine_type'] ?? '',
    photoUrl:        j['photo_url'] ?? '',
    deliveryTimeMin: j['delivery_time_min'] ?? 30,
    isOpen:          j['is_open'] ?? false,
    address:         j['address'] ?? '',
    rating:          (j['rating'] ?? 4.0).toDouble(),
  );
}
