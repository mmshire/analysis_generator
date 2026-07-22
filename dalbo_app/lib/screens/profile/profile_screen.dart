import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../models/order.dart';
import '../../core/constants.dart';
import 'dart:async';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadHistory());
  }

  Future<void> _loadHistory() async {
    final auth   = context.read<AuthProvider>();
    final orders = context.read<OrderProvider>();
    await orders.loadHistory(auth.api);
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Log out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Log out', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await context.read<AuthProvider>().logout();
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.phoneLogin, (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth   = context.watch<AuthProvider>();
    final orders = context.watch<OrderProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: ListView(
        children: [
          // Profile header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Text(
                    (auth.name?.isNotEmpty == true ? auth.name![0] : auth.phone?[0] ?? '?').toUpperCase(),
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.primary),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(auth.name ?? 'No name set',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                      Text(auth.phone ?? '',
                        style: const TextStyle(color: AppColors.textMid)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Order history
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: const Text('Order History',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          ),
          const SizedBox(height: 8),

          if (orders.loading)
            const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
          else if (orders.history.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: Text("You haven't placed any orders yet",
                style: TextStyle(color: AppColors.textMid))),
            )
          else
            ...orders.history.map((order) => _OrderHistoryTile(order: order)),

          const Divider(height: 32),

          // Logout
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: const Text('Log out', style: TextStyle(color: AppColors.error)),
            onTap: _logout,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _OrderHistoryTile extends StatelessWidget {
  final Order order;
  const _OrderHistoryTile({required this.order});

  Color get _statusColor {
    switch (order.status) {
      case 'delivered':   return AppColors.success;
      case 'cancelled':   return AppColors.error;
      default:            return AppColors.primary;
    }
  }

  String get _statusLabel {
    switch (order.status) {
      case 'placed':           return 'Order Placed';
      case 'accepted':         return 'Accepted';
      case 'preparing':        return 'Preparing';
      case 'rider_on_the_way': return 'On the Way';
      case 'delivered':        return 'Delivered';
      case 'cancelled':        return 'Cancelled';
      default:                 return order.status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: AppColors.divider,
          child: const Text('🍽️'),
        ),
        title: Text(order.restaurantName, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('\$${order.totalUsd.toStringAsFixed(2)}  ·  ${AppConstants.toSls(order.totalUsd)}',
              style: const TextStyle(color: AppColors.textMid, fontSize: 12)),
            const SizedBox(height: 3),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(_statusLabel,
                style: TextStyle(color: _statusColor, fontSize: 11, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textLight),
        onTap: () => Navigator.pushNamed(context, AppRoutes.orderTracking, arguments: order),
      ),
    );
  }
}
