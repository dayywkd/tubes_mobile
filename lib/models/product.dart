// lib/models/product.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class Product {
  final String id;
  final String name;
  final String subtitle;
  final double price;
  final String category;
  final String imageUrl;

  Product({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.price,
    required this.category,
    required this.imageUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    String url = json["image_url"]?.toString() ?? "";

    // Logika untuk mengubah nama file menjadi URL publik Supabase
    if (url.isNotEmpty && !url.startsWith("http")) {
      url = Supabase.instance.client.storage
          .from('coffe_images') // [Periksa: Pastikan nama bucket ini sudah benar!]
          .getPublicUrl(url);
    }

    return Product(
      id: json["id"].toString(),
      name: json["name"] ?? "",
      subtitle: json["subtitle"] ?? "",
      price: double.tryParse(json["price"].toString()) ?? 0,
      category: json["category"] ?? "",
      imageUrl: url,
    );
  }
}
