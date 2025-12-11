import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/cart_item.dart';

class OrderService {
  static Future<bool> sendOrder({
    required String tableId,
    required List<CartItem> items,
  }) async {
    try {
      final payload = {
        "table_id": tableId,
        "items": items
            .map((e) => {
                  "product_id": e.product.id,
                  "name": e.product.name,
                  "qty": e.qty,
                  "size": e.size,
                  "price": e.product.price
                })
            .toList(),
        "total": items.fold<double>(
          0.0,
          (sum, item) => sum + (item.product.price * item.qty),
        ),
      };

      // TODO: GANTI URL API SERVER KASIR ANDA
      // final url = Uri.parse("https://example.com/api/order");

      debugPrint("SENDING ORDER: ${jsonEncode(payload)}");

      // SIMULASI
      await Future.delayed(const Duration(seconds: 1));
      return true;

      // KIRIM KE SERVER ASLI
      // final res = await http.post(
      //   url,
      //   body: jsonEncode(payload),
      //   headers: {"Content-Type": "application/json"},
      // );
      // return res.statusCode == 200;
    } catch (e) {
      debugPrint("Order error: $e");
      return false;
    }
  }
}
