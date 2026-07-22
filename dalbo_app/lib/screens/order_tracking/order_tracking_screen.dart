import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../models/order.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';

class OrderTrackingScreen extends StatefulWidget {
  const OrderTrackingScreen({super.key});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  Timer?  _timer;
  Order?  _order;
  bool    _initialized = false;

  // Status pipeline in order
  static const _statuses = [
    ('placed',          '🛎️',  'Order Placed',      'We received your order'),
    ('accepted',        '✅',  'Accepted',           'The restaurant accepted your order'),
    ('preparing',       '👨‍🍳', 'Preparing',          'Your food is being prepared'),
    ('rider_on_the_way','🛵',  'Rider on the Way',   'Your rider is heading to you'),
    ('delivered',       '🎉',  'Delivered!',         'Enjoy your meal!'),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _order = ModalRoute.of(context)!.settings.arguments as Order?
               ?? context.read<OrderProvider>().current;
      // Poll for status updates every 15 seconds
      _timer = Timer.periodic(const Duration(seconds: 15), (_) => _refresh());
    }
  }

  Future<void> _refresh() async {
    if (_order == null) return;
    final api = context.read<AuthProvider>().api;
    await context.read<OrderProvider>().refreshOrder(api, _order!.id);
    final updated = context.read<OrderProvider>().current;
    if (updated != null && mounted) setState(() => _order = updated);
  }

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  int get _currentStatusIndex {
    final idx = _statuses.indexWhere((s) => s.$1 == (_order?.status ?? 'placed'));
    return idx < 0 ? 0 : idx;
  }

  @override
  Widget build(BuildContext context) {
    if (_order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Track Order')),
        body: const Center(child: Text('Order not found')),
      );
    }
    final statusIdx = _currentStatusIndex;
    final isDelivered = _order!.status == 'delivered';

    return Scaffold(
      appBar: AppBar(
        title: Text('Order #${_order!.id}'),
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (_) => false),
            child: const Text('Home'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Big status emoji + label
          Center(
            child: Column(
              children: [
                Text(_statuses[statusIdx].$2, style: const TextStyle(fontSize: 72)),
                const SizedBox(height: 8),
                Text(_statuses[statusIdx].$3,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                const SizedBox(height: 4),
                Text(_statuses[statusIdx].$4,
                  style: const TextStyle(color: AppColors.textMid)),
              ],
            ),
          ),

          const SizedBox(height: 36),

          // Progress steps
          ..._statuses.asMap().entries.map((entry) {
            final i    = entry.key;
            final step = entry.value;
            final done   = i <= statusIdx;
            final active = i == statusIdx;

            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  // Circle indicator
                  Column(
                    children: [
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: done ? AppColors.primary : AppColors.divider,
                          border: active ? Border.all(color: AppColors.primaryDark, width: 3) : null,
                        ),
                        child: Center(
                          child: done
                            ? const Icon(Icons.check, color: Colors.white, size: 18)
                            : Text('${i + 1}', style: const TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w600)),
                        ),
                      ),
                      if (i < _statuses.length - 1)
                        Container(
                          width: 2, height: 32,
                          color: i < statusIdx ? AppColors.primary : AppColors.divider,
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(step.$3,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: done ? AppColors.textDark : AppColors.textLight,
                            )),
                          Text(step.$4,
                            style: TextStyle(
                              fontSize: 12,
                              color: done ? AppColors.textMid : AppColors.textLight,
                            )),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 16),

          // Order summary card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_order!.restaurantName,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                const SizedBox(height: 4),
                Text(_order!.deliveryAddress,
                  style: const TextStyle(color: AppColors.textMid, fontSize: 13)),
                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total', style: TextStyle(fontWeight: FontWeight.w600)),
                    Text('\$${_order!.totalUsd.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary, fontSize: 16)),
                  ],
                ),
              ],
            ),
          ),

          if (isDelivered) ...[
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (_) => false),
              child: const Text('Order Again'),
            ),
          ],
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
