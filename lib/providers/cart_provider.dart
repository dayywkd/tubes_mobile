import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

class CartProvider extends ChangeNotifier {
  List<CartItem> items = [];
  String? tableId;

  void setTable(String id) {
    tableId = id;
    notifyListeners();
  }

  void add(Product product, {String size = "M"}) {
    final index = items.indexWhere((it) => it.product.id == product.id && it.size == size);

    if (index >= 0) {
      items[index].qty++;
    } else {
      items.add(CartItem(product: product, size: size));
    }
    notifyListeners();
  }

  void changeQty(CartItem item, int value) {
    item.qty += value;
    if (item.qty <= 0) items.remove(item);
    notifyListeners();
  }

  double get total =>
      items.fold(0, (sum, it) => sum + it.product.price * it.qty);

  void clear() {
    items.clear();
    tableId = null;
    notifyListeners();
  }
}
