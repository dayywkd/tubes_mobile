import 'package:hive/hive.dart';

part 'product_hive.g.dart';

@HiveType(typeId: 1)
class ProductHive {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String category;

  @HiveField(3)
  final double price;

  @HiveField(4)
  final String imageUrl;

  ProductHive({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.imageUrl,
  });
}
