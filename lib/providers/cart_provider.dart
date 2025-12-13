import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

class CartProvider extends ChangeNotifier {
  List<CartItem> items = [];

  // Mengubah signature: kini menerima calculatedPrice
  void add(Product product, {required double calculatedPrice, String size = "M"}) { 
    // Mencari item yang sama berdasarkan product ID DAN ukuran (size)
    final index = items.indexWhere((it) => it.product.id == product.id && it.size == size);

    if (index >= 0) {
      items[index].qty++;
    } else {
      items.add(CartItem(
        product: product, 
        size: size,
        price: calculatedPrice, // Gunakan harga yang dihitung
      ));
    }
    notifyListeners();
  }

  void changeQty(CartItem item, int value) {
    item.qty += value;
    if (item.qty <= 0) items.remove(item);
    notifyListeners();
  }

  // Mengubah perhitungan total: menggunakan item.price
  double get total =>
      items.fold(0, (sum, it) => sum + it.price * it.qty); 

  void clear() {
    items.clear();
    notifyListeners();
  }
}