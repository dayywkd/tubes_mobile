// lib/services/product_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product.dart';

class ProductService {
  static Future<List<Product>> getProducts() async {
    try {
      final client = Supabase.instance.client;

      print("🔄 Fetching products from Supabase...");

      // Supabase Flutter 2.x: select() langsung return List<dynamic>
      final data = await client
          .from('products')
          .select()
          .order('name', ascending: true);

      print("✅ Products fetched successfully: ${data.length} items");

      return data.map((item) {
        return Product.fromJson(Map<String, dynamic>.from(item));
      }).toList();
    } catch (e) {
      print("❌ ERROR fetching products: $e");
      return []; // fallback agar UI tidak crash
    }
  }
}
