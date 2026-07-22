import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../models/menu_item.dart';
import '../../models/restaurant.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../services/api_service.dart';
import '../../widgets/menu_item_card.dart';

class RestaurantScreen extends StatefulWidget {
  const RestaurantScreen({super.key});

  @override
  State<RestaurantScreen> createState() => _RestaurantScreenState();
}

class _RestaurantScreenState extends State<RestaurantScreen> {
  Map<String, List<MenuItem>> _byCategory = {};
  bool   _loading = true;
  String? _error;

  late Restaurant _restaurant;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _restaurant = ModalRoute.of(context)!.settings.arguments as Restaurant;
    _load();
  }

  Future<void> _load() async {
    final api = context.read<AuthProvider>().api;
    try {
      final data = await api.getRestaurantDetail(_restaurant.id);
      final items = (data['menu'] as List).map((j) => MenuItem.fromJson(j)).toList();
      final cats  = <String, List<MenuItem>>{};
      for (final item in items) {
        cats.putIfAbsent(item.category, () => []).add(item);
      }
      setState(() { _byCategory = cats; _loading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart    = context.watch<CartProvider>();
    final total   = cart.restaurantId == _restaurant.id ? cart.totalUsd : 0.0;
    final hasCart = cart.restaurantId == _restaurant.id && cart.itemCount > 0;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Hero photo header
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: CachedNetworkImage(
                imageUrl: _restaurant.photoUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: AppColors.divider),
              ),
            ),
          ),

          // Restaurant info
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(_restaurant.name,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textDark))),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _restaurant.isOpen ? AppColors.success.withOpacity(0.1) : AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _restaurant.isOpen ? '● Open' : '● Closed',
                          style: TextStyle(
                            color: _restaurant.isOpen ? AppColors.success : AppColors.error,
                            fontWeight: FontWeight.w600, fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(_restaurant.cuisineType, style: const TextStyle(color: AppColors.textMid)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: Color(0xFFFFC107), size: 16),
                      const SizedBox(width: 2),
                      Text(_restaurant.rating.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(width: 16),
                      const Icon(Icons.access_time_rounded, size: 14, color: AppColors.textMid),
                      const SizedBox(width: 3),
                      Text('${_restaurant.deliveryTimeMin} min delivery',
                        style: const TextStyle(color: AppColors.textMid, fontSize: 13)),
                    ],
                  ),
                  const Divider(height: 24),
                  const Text('Menu', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),

          // Menu items grouped by category
          if (_loading)
            const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
          else if (_error != null)
            SliverFillRemaining(child: Center(child: Text(_error!)))
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final categories = _byCategory.keys.toList();
                  final category   = categories[index];
                  final items      = _byCategory[category]!;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(category,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textMid)),
                        ),
                        ...items.map((item) {
                          final qty = cart.restaurantId == _restaurant.id
                            ? (cart.items.where((c) => c.item.id == item.id).isEmpty
                                ? 0
                                : cart.items.firstWhere((c) => c.item.id == item.id).quantity)
                            : 0;
                          return MenuItemCard(
                            item:     item,
                            quantity: qty,
                            onAdd:    () => cart.addItem(item, _restaurant.id, _restaurant.name),
                            onRemove: () => cart.removeItem(item.id),
                          );
                        }),
                      ],
                    ),
                  );
                },
                childCount: _byCategory.length,
              ),
            ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ),

      // Floating cart button
      bottomNavigationBar: hasCart
        ? SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.cart),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: AppColors.primaryDark, borderRadius: BorderRadius.circular(6)),
                      child: Text('${cart.itemCount}', style: const TextStyle(fontWeight: FontWeight.w700)),
                    ),
                    const Text('View Cart'),
                    Text('\$${total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
          )
        : null,
    );
  }
}
