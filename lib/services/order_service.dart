// lib/services/order_service.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/cart_item.dart';

class OrderService {
  
  // KONTROL DEBUGGING: ATUR KE TRUE UNTUK SIMULASI KEGAGALAN
  static bool _forceFailure = false; 

  static Future<bool> sendOrder({
    required String tableId,
    required List<CartItem> items,
  }) async {
    try {
      
      // LOGIKA DEBUGGING: Simulasikan kegagalan jika diaktifkan
      if (_forceFailure) {
        debugPrint("SIMULASI: Pengiriman pesanan GAGAL (karena _forceFailure=true)");
        await Future.delayed(const Duration(seconds: 1)); 
        return false; 
      }
      
      final client = Supabase.instance.client;

      // 1. Persiapan data item untuk disimpan di kolom 'items_jsonb'
      final itemsPayload = items
          .map((e) => {
                "product_id": e.product.id,
                "name": e.product.name,
                "qty": e.qty,
                "size": e.size,
                "price": e.product.price,
              })
          .toList();

      // 2. Hitung total
      final totalAmount = items.fold<double>(
        0.0,
        (sum, item) => sum + (item.product.price * item.qty),
      );

      // 3. Kirim data ke tabel 'orders' di Supabase
      final response = await client
          .from('orders') 
          .insert({
              'table_id': tableId, // Menggunakan ID 'CASHIER-ORDER'
              'total': totalAmount,
              'items_jsonb': itemsPayload, 
          });
      
      // 4. Periksa respons dari Supabase
      if (response == null || response.error != null) {
          debugPrint("Supabase Insert Error: ${response.error?.message}");
          return false;
      }
      
      debugPrint("ORDER SENT SUCCESSFULLY to Supabase: Table $tableId, Total $totalAmount");
      
      return true;

    } catch (e) {
      debugPrint("Order error: $e");
      return false;
    }
  }
}