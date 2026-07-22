import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/theme.dart';
import '../models/menu_item.dart';

class MenuItemCard extends StatelessWidget {
  final MenuItem    item;
  final int         quantity; // how many are currently in cart
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const MenuItemCard({
    super.key,
    required this.item,
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Food photo
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: item.photoUrl,
                width: 80, height: 80, fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  width: 80, height: 80, color: AppColors.divider,
                ),
                errorWidget: (_, __, ___) => Container(
                  width: 80, height: 80, color: AppColors.divider,
                  child: const Icon(Icons.fastfood, color: AppColors.textLight),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Name, description, price
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textDark),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                  if (item.description.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(item.description,
                      style: const TextStyle(fontSize: 12, color: AppColors.textMid),
                      maxLines: 2, overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text('\$${item.priceUsd.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primary)),
                      const SizedBox(width: 6),
                      Text(AppConstants.toSls(item.priceUsd),
                        style: const TextStyle(fontSize: 12, color: AppColors.textMid)),
                    ],
                  ),
                ],
              ),
            ),

            // Add / remove controls
            Column(
              children: [
                if (quantity > 0) ...[
                  _circleBtn(Icons.remove, onRemove, outline: true),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text('$quantity', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  ),
                ],
                _circleBtn(Icons.add, onAdd),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _circleBtn(IconData icon, VoidCallback cb, {bool outline = false}) {
    return GestureDetector(
      onTap: cb,
      child: Container(
        width: 30, height: 30,
        decoration: BoxDecoration(
          color: outline ? Colors.white : AppColors.primary,
          border: Border.all(color: AppColors.primary, width: 1.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: outline ? AppColors.primary : Colors.white),
      ),
    );
  }
}
