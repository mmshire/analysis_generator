import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _addressCtrl = TextEditingController();
  String _paymentMethod = 'cash_on_delivery';
  bool   _placing = false;

  @override
  void dispose() { _addressCtrl.dispose(); super.dispose(); }

  Future<void> _placeOrder() async {
    if (_addressCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a delivery address')),
      );
      return;
    }
    setState(() => _placing = true);

    final auth  = context.read<AuthProvider>();
    final cart  = context.read<CartProvider>();
    final orders = context.read<OrderProvider>();

    final order = await orders.placeOrder(
      api:             auth.api,
      restaurantId:    cart.restaurantId!,
      items:           cart.toOrderItems(),
      deliveryAddress: _addressCtrl.text.trim(),
      paymentMethod:   _paymentMethod,
    );

    if (!mounted) return;
    setState(() => _placing = false);

    if (order != null) {
      cart.clear();
      Navigator.pushNamedAndRemoveUntil(
        context, AppRoutes.orderTracking, (r) => r.settings.name == AppRoutes.home,
        arguments: order,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(orders.error ?? 'Failed to place order'), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    if (cart.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Cart')),
        body: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🛒', style: TextStyle(fontSize: 64)),
              SizedBox(height: 16),
              Text('Your cart is empty', style: TextStyle(color: AppColors.textMid, fontSize: 16)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Cart — ${cart.restaurantName ?? ""}'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Items ──────────────────────────────────────────────────────
          ...cart.items.map((cartItem) => Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(cartItem.item.name,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                        Text('\$${cartItem.item.priceUsd.toStringAsFixed(2)} × ${cartItem.quantity}',
                          style: const TextStyle(color: AppColors.textMid, fontSize: 13)),
                      ],
                    ),
                  ),
                  // Qty controls
                  Row(
                    children: [
                      _iconBtn(Icons.remove, () => cart.removeItem(cartItem.item.id)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text('${cartItem.quantity}',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                      ),
                      _iconBtn(Icons.add, () => cart.addItem(cartItem.item, cart.restaurantId!, cart.restaurantName!)),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Text('\$${cartItem.subtotalUsd.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary)),
                ],
              ),
            ),
          )),

          const SizedBox(height: 20),

          // ── Delivery address ─────────────────────────────────────────
          const Text('Delivery address', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 8),
          TextField(
            controller: _addressCtrl,
            maxLines: 2,
            decoration: const InputDecoration(
              hintText: 'e.g. 26 June Road, near the market, Hargeisa',
              prefixIcon: Icon(Icons.location_on_outlined),
            ),
          ),

          const SizedBox(height: 20),

          // ── Payment method ──────────────────────────────────────────
          const Text('Payment method', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 8),

          // Cash on delivery (enabled)
          _PaymentOption(
            icon: '💵',
            label: 'Cash on Delivery',
            selected: _paymentMethod == 'cash_on_delivery',
            onTap: () => setState(() => _paymentMethod = 'cash_on_delivery'),
          ),
          // Zaad (coming soon — greyed out, plug in WaafiPay later)
          _PaymentOption(
            icon: '📱',
            label: 'Zaad Mobile Money',
            sublabel: 'Coming soon',
            selected: false,
            enabled: false,
            onTap: () {},
          ),
          _PaymentOption(
            icon: '📱',
            label: 'eDahab',
            sublabel: 'Coming soon',
            selected: false,
            enabled: false,
            onTap: () {},
          ),

          const SizedBox(height: 24),

          // ── Order summary ────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              children: [
                _SummaryRow('Subtotal', '\$${cart.totalUsd.toStringAsFixed(2)}'),
                const _SummaryRow('Delivery fee', 'Free'),
                const Divider(height: 20),
                _SummaryRow(
                  'Total',
                  '\$${cart.totalUsd.toStringAsFixed(2)}  (${AppConstants.toSls(cart.totalUsd)})',
                  bold: true,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          _placing
            ? const Center(child: CircularProgressIndicator())
            : ElevatedButton(
                onPressed: _placeOrder,
                child: const Text('Place Order'),
              ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback cb) => GestureDetector(
    onTap: cb,
    child: Container(
      width: 28, height: 28,
      decoration: BoxDecoration(border: Border.all(color: AppColors.divider), borderRadius: BorderRadius.circular(6)),
      child: Icon(icon, size: 16, color: AppColors.textDark),
    ),
  );
}

class _PaymentOption extends StatelessWidget {
  final String icon, label;
  final String? sublabel;
  final bool selected, enabled;
  final VoidCallback onTap;

  const _PaymentOption({
    required this.icon, required this.label, required this.selected, required this.onTap,
    this.sublabel, this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.5,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary.withOpacity(0.05) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.divider,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 12),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
                  if (sublabel != null)
                    Text(sublabel!, style: const TextStyle(color: AppColors.textMid, fontSize: 12)),
                ],
              )),
              if (selected) const Icon(Icons.check_circle, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label, value;
  final bool bold;
  const _SummaryRow(this.label, this.value, {this.bold = false});

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontWeight: bold ? FontWeight.w700 : FontWeight.normal,
      fontSize:   bold ? 16 : 14,
      color:      bold ? AppColors.textDark : AppColors.textMid,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label, style: style), Text(value, style: style)],
      ),
    );
  }
}
