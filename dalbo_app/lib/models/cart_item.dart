import 'menu_item.dart';

class CartItem {
  final MenuItem item;
  int quantity;

  CartItem({required this.item, this.quantity = 1});

  double get subtotalUsd => item.priceUsd * quantity;

  Map<String, dynamic> toOrderJson() => {
    'menu_item_id': item.id,
    'quantity':     quantity,
  };
}
