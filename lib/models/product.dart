import 'package:hive/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
part 'product.g.dart';

@HiveType(typeId: 1)
class Product {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String subtitle;

  @HiveField(3)
  final double price;

  @HiveField(4)
  final String category;

  @HiveField(5)
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

    if (url.isNotEmpty && !url.startsWith("http")) {
      url = Supabase.instance.client.storage
          .from('coffe_images') // <-- bucket name MUST match
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
